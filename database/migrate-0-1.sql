SET SESSION sql_mode='STRICT_ALL_TABLES';

ALTER DATABASE CHARACTER SET utf8;

-- Several tables have pathological all-NULL entries.
DELETE FROM Indexers WHERE ID=409;
DELETE FROM IndexCredit WHERE IndexerID IS NULL AND SeriesID IS NULL;
DELETE FROM publishers WHERE ID=3915;
DELETE FROM series WHERE ID=11253;
DELETE FROM issues WHERE ID=310423;

-- Also there are several made-up countries,
-- one of which duplicates a real code (Syria vs Syrania).
DELETE FROM Countries WHERE code IN ('LW', 'XX', 'X2');
DELETE FROM Countries WHERE country = 'Syrania';

-- And "delete me's" and some "message" entries asking for indexers' emails.
DELETE FROM issues WHERE SeriesID=20759;
DELETE FROM series WHERE ID=20759;
DELETE FROM publishers WHERE ID IN (4064, 1789);

-- Former "delete me" series whose (nearly 75,000) covers were left behind.
-- The others might as well hook up to orphan/null/vanished entries instead.
DELETE FROM covers WHERE SeriesID IN (29713, 16030);

-- There are various NULL foreign keys that need fixing.
-- Make these easy to find since we don't know where they really go.
INSERT INTO publishers (PubName, Notes, Master, YearBegan)
    VALUES ('*GCD NULL PUBLISHER',
            'Publisher for series with no publisher in the DB', 1, '0000');
INSERT INTO publishers (PubName, Notes, Master, YearBegan)
    VALUES ('*GCD VANISHED PUBLISHERS',
            'Publisher for series whose publisher is not in the DB', 1, '0000');
INSERT INTO publishers (PubName, Notes, Master, YearBegan)
    VALUES ('*GCD VANISHED PARENT PUBLISHERS',
            'Publisher for imprints whose publisher is not in the DB',
            1, '0000');
INSERT INTO series (Bk_Name, Yr_Began, LangCode, CounCode, Notes)
    VALUES ('*GCD NULL SERIES', '0000', 'en', 'us',
            'Series for issues with no series in the DB');
INSERT INTO series (Bk_Name, Yr_Began, LangCode, CounCode, Notes)
    VALUES ('*GCD VANISHED SERIES', '0000', 'en', 'us',
            'Series for issues whose series is not in the DB');
INSERT INTO series (Bk_Name, Yr_Began, LangCode, CounCode, Notes)
    VALUES ('*GCD VANISHED SERIES FOR COVERS', '0000', 'en', 'us',
            'Series for covers whose series is not in the DB');
INSERT INTO issues (issue, Notes) VALUES ('*GCD NULL ISSUE',
    'Issue for stories with no issue in the DB');
INSERT INTO issues (issue, Notes) VALUES ('*GCD VANISHED ISSUES',
    'Issue for stories whose issue is not in the DB');
INSERT INTO issues (issue, Notes) VALUES ('*GCD ORPHAN COVERS ISSUE',
    'Issue for covers with no issue in the DB');
INSERT INTO issues (issue, Notes) VALUES ('*GCD DOUBLED COVERS ISSUE',
    'Issue for covers with multiple issue matches by "issue" field in the DB');
INSERT INTO issues (issue, Notes) VALUES ('*GCD VANISHED ISS. COVERS',
    'Issue for covers whose issue is not in the DB');

-- One publisher is listed as an imprint but with parentID of 0.  Make master.
-- This must be done before series table imprint/publisher fix and before the
-- vanished parent publisher fix (as 0 isn't vanished, just wrong).
UPDATE publishers SET Master=1 WHERE Master=0 AND ParentID=0;

-- Fix the one NULL Master value.  It has a parent, so it must not be Master.
-- Check that Master is really NULL in case this is fixed in a later dump.
UPDATE publishers SET Master=0 WHERE ID=3342 and Master is NULL;

-- Due to restrictions on updates and subqueries, we need temporary tables
-- in order to fix several things that correlate publishers and imprints.
-- This gets used further down.
CREATE TEMPORARY TABLE imprints (id int(11), publisher_id int(11));
INSERT INTO imprints (id, publisher_id)
    SELECT ID, ParentID FROM publishers
        WHERE ParentID IS NOT NULL AND ParentID != 0;

-- TODO: Fix publishers acting as both imprints and masters.

UPDATE series SET PubID=
    (SELECT ID FROM publishers WHERE PubName='*GCD NULL PUBLISHER')
    WHERE PubID IS NULL;
UPDATE series SET PubID=
    (SELECT ID FROM publishers WHERE PubName='*GCD VANISHED PUBLISHERS')
    WHERE (SELECT ID FROM publishers WHERE publishers.ID=series.PubID) IS NULL;

UPDATE issues SET SeriesID=
    (SELECT ID FROM series WHERE Bk_Name='*GCD NULL SERIES')
    WHERE SeriesID IS NULL;
UPDATE issues SET SeriesID=
    (SELECT ID FROM series WHERE Bk_Name='*GCD VANISHED SERIES')
    WHERE (SELECT ID FROM series WHERE series.ID=issues.SeriesID) IS NULL;

UPDATE stories SET IssueID=
    (SELECT ID FROM issues WHERE Issue='*GCD NULL ISSUE')
    WHERE IssueID IS NULL;
UPDATE stories SET IssueID=
    (SELECT ID FROM issues WHERE Issue='*GCD VANISHED ISSUES')
    WHERE (SELECT ID FROM issues WHERE issues.ID=stories.IssueID) IS NULL;

-- The covers table is a mess.  These must be in order.
-- Even after this, series ID, issue ID and issue are likely to disagree.

-- First, do something about covers that can't be resolved to a single issue.
UPDATE covers SET IssueID=
    (SELECT ID FROM issues WHERE Issue='*GCD DOUBLED COVERS ISSUE')
    WHERE IssueID IS NULL AND
        (SELECT COUNT(*) FROM issues WHERE issues.SeriesID=covers.SeriesID AND
                                           issues.issue=covers.Issue) > 1;
-- Next, do something about covers that don't match any issue.
UPDATE covers SET IssueID=
    (SELECT ID FROM issues WHERE Issue='*GCD ORPHAN COVERS ISSUE')
    WHERE IssueID IS NULL AND
        (SELECT COUNT(*) FROM issues WHERE issues.SeriesID=covers.SeriesID AND
                                           issues.issue=covers.Issue) < 1;
-- Series links that go nowhere.
UPDATE covers LEFT OUTER JOIN series ON covers.SeriesID = series.ID
    SET covers.SeriesID=
        (SELECT ID FROM series WHERE Bk_Name='*GCD VANISHED SERIES FOR COVERS')
    WHERE series.ID IS NULL;

-- Issue links that go nowhere.
-- Note that we do not later set covers.Issue so do it here.
UPDATE covers LEFT OUTER JOIN issues ON covers.IssueID = issues.ID
    SET covers.IssueID=
        (SELECT ID FROM issues WHERE issues.issue='*GCD VANISHED ISS. COVERS'),
        covers.Issue='*GCD VANISHED ISS. COVERS'
    WHERE issues.ID IS NULL;

-- Finally, fix the remaining, fixable keys.
UPDATE covers SET IssueID=
    (SELECT issues.ID from issues WHERE issues.SeriesID=covers.SeriesID AND
                                        issues.issue=covers.Issue)
    WHERE IssueID IS NULL;
    
-- Many of the cached counts and names are invalid, so fix all.
-- Counts are assembled bottom-up for counts that skip levels.
UPDATE issues SET storycount=
    (SELECT COUNT(*) FROM stories WHERE stories.IssueID = issues.ID);
UPDATE series SET series.Issuecount=
    (SELECT COUNT(*) FROM issues WHERE issues.SeriesID = series.ID);
UPDATE publishers SET BookCount=
    (SELECT COUNT(*) FROM series WHERE series.PubID = publishers.ID);
UPDATE publishers SET IssueCount=
    (SELECT SUM(series.Issuecount) FROM series
        WHERE series.PubID = publishers.ID);
-- Some publishers have no series and therefore the issue count ends up NULL
UPDATE publishers SET IssueCount=0 where BookCount=0;


-- Some series have imprints as their master publishers.  Fix this.
-- No such series currently also have a valid imprint value.
UPDATE series INNER JOIN publishers ON series.PubID=publishers.ID
    SET series.PubID=publishers.ParentID, series.imprint_id=publishers.ID
    WHERE publishers.Master=0;

-- Fix imprint counts.
UPDATE publishers SET ImprintCount=
    (SELECT COUNT(*) FROM imprints WHERE imprints.publisher_id=publishers.ID);

-- Names are copied top-down for copies that skip levels.
-- Doing these one at a time is much faster than setting multiple columns,
-- each with their own subquery.

UPDATE series SET Pub_Name=
    (SELECT PubName FROM publishers WHERE publishers.ID=series.PubID);

UPDATE issues SET Pub_Name=
    (SELECT Pub_Name FROM series WHERE series.ID=issues.SeriesID);
UPDATE issues SET Bk_Name=
    (SELECT Bk_Name FROM series WHERE series.ID=issues.SeriesID);
UPDATE issues SET Yr_Began=
    (SELECT Yr_Began FROM series WHERE series.ID=issues.SeriesID);

UPDATE stories SET SeriesID=
    (SELECT SeriesID from issues WHERE issues.ID=stories.IssueID);
UPDATE stories SET Pub_Name=
    (SELECT Pub_Name from issues WHERE issues.ID=stories.IssueID);
UPDATE stories SET Bk_Name=
    (SELECT Bk_Name from issues WHERE issues.ID=stories.IssueID);
UPDATE stories SET Yr_Began=
    (SELECT Yr_Began from issues WHERE issues.ID=stories.IssueID);
UPDATE stories SET Issue=
    (SELECT Issue from issues WHERE issues.ID=stories.IssueID);

-- This messes up our nice alter table grouping, but there's no way to
-- do this without two alter statements, because we want to make this NOT NULL
-- and the existing column is too short for the basic assignment.
ALTER TABLE stories MODIFY COLUMN Pub_Date varchar(255) default NULL;
UPDATE stories SET Pub_Date=
    (SELECT Pub_Date from issues WHERE issues.ID=stories.IssueID);

-- Do not set covers.Issue based on covers.IssueID as covers.Issue may
-- be the more correct entry.
UPDATE covers SET Pub_Name=
    (SELECT Pub_Name FROM series WHERE series.ID=covers.SeriesID);
UPDATE covers SET Bk_Name=
    (SELECT Bk_Name FROM series WHERE series.ID=covers.SeriesID);
UPDATE covers SET Yr_Began=
    (SELECT Yr_Began from series WHERE series.ID=covers.SeriesID);

-- BEGIN Table restructuring statements
-- And yes, reording columns in mysql is somewhat pointless, but this just
-- makes things show up much nicer in test queries of the SELECT(*) form and
-- line up a bit better with how the code is organized (although that won't be
-- kept in strict correspondence).  Plus we have to rename nearly all of the
-- columns anyway.

ALTER TABLE Countries RENAME core_country,
    CHANGE COLUMN ID id int(11) NOT NULL auto_increment FIRST,
    CHANGE COLUMN code code varchar(10) NOT NULL,
    CHANGE COLUMN country name varchar(255) NOT NULL,
    CONVERT TO CHARACTER SET utf8;

ALTER TABLE Languages RENAME core_language,
    CHANGE COLUMN ID id int(11) NOT NULL auto_increment FIRST,
    CHANGE COLUMN code code varchar(10) NOT NULL,
    CHANGE COLUMN language name varchar(255) NOT NULL,
    CONVERT TO CHARACTER SET utf8;

UPDATE IndexCredit SET DateMod='0001-01-01' WHERE DateMod IS NULL;
ALTER TABLE IndexCredit RENAME core_seriescredit,
                        DROP COLUMN `Comment`,
    CHANGE COLUMN ID id int(11) NOT NULL auto_increment,
    CHANGE COLUMN IndexerID indexer_id int(11) NOT NULL,
    CHANGE COLUMN SeriesID series_id int(11) NOT NULL,
    CHANGE COLUMN Run run varchar(255) default NULL,
    CHANGE COLUMN Notes notes mediumtext AFTER run,
    ADD COLUMN created date NOT NULL default '0001-01-01' AFTER notes,
    CHANGE COLUMN DateMod modified date NOT NULL default '0001-01-01'
        AFTER created,
    CONVERT TO CHARACTER SET utf8;


UPDATE Indexers SET DateCreated='0001-01-01' WHERE DateCreated IS NULL;
UPDATE Indexers SET DateMod='0001-01-01' WHERE DateMod IS NULL;
ALTER TABLE Indexers RENAME core_indexer,
                     DROP COLUMN Name,
                     DROP COLUMN loginkey,
                     DROP COLUMN loginlock,
                     DROP COLUMN `session`,
                     DROP COLUMN expert,
    CHANGE COLUMN ID id int(11) NOT NULL auto_increment,
    CHANGE COLUMN username username varchar(255) NOT NULL AFTER id,
    CHANGE COLUMN password password varchar(255) NOT NULL AFTER username,
    CHANGE COLUMN Country country_code varchar(255) default NULL AFTER password,
    CHANGE COLUMN eMail email varchar(255) default NULL AFTER country_code,
    CHANGE COLUMN FirstName given_name varchar(255) default NULL AFTER email,
    CHANGE COLUMN LastName family_name varchar(255) default NULL
        AFTER given_name,
    ADD COLUMN name_order tinyint(1) default 0
        COMMENT 'Controls name display.  For future language/culture expansion.'
        AFTER family_name,
    CHANGE COLUMN userlevel user_level int(11) NOT NULL default 0
        AFTER name_order,
    CHANGE COLUMN Active active tinyint(1) NOT NULL default 1
        AFTER user_level,
    CHANGE COLUMN Message message mediumtext AFTER active,
    CHANGE COLUMN DateCreated created date NOT NULL default '0001-01-01'
        AFTER message,
    CHANGE COLUMN DateMod modified date NOT NULL default '0001-01-01'
        AFTER created,
    CONVERT TO CHARACTER SET utf8;


-- ************ PUBLISHERS *************

UPDATE publishers SET Modified=Created WHERE Created IS NOT NULL AND
                                             Modified IS NULL;
UPDATE publishers SET Created='0001-01-01' WHERE Created IS NULL;
UPDATE publishers SET Modified='0001-01-01' WHERE Modified IS NULL;

ALTER TABLE publishers RENAME core_publisher,
                       DROP COLUMN Connection,
                       DROP COLUMN NextID,
                       DROP COLUMN Updated,
    CHANGE COLUMN ID id int(11) NOT NULL auto_increment FIRST,
    CHANGE COLUMN PubName name varchar(255) NOT NULL AFTER id,
    CHANGE COLUMN CountryID country_id int(11) default NULL AFTER name,
    CHANGE COLUMN YearBegan year_began int(11) default NULL AFTER country_id,
    CHANGE COLUMN YearEnded year_ended int(11) default NULL
        COMMENT 'Frequently 9999 as the UI wont allow NULL for current pubs.'
        AFTER year_began,
    CHANGE COLUMN Notes notes longtext AFTER year_ended,
    CHANGE COLUMN web url varchar(255) default NULL AFTER notes,
    CHANGE COLUMN Master master tinyint(1) NOT NULL
        COMMENT 'Only Master publishers may have "imprints"'
        AFTER url,
    CHANGE COLUMN ParentID parent_id int(11) default NULL
        COMMENT 'All imprints, indicia publishers, etc. have a parent id.'
        AFTER master,
    CHANGE COLUMN AlphaSortCode alpha_sort_code varchar(1) default NULL
        COMMENT 'Used to group related publishers in a sort, may go away.'
        AFTER parent_id,
    CHANGE COLUMN ImprintCount imprint_count int(11) NOT NULL default 0
        AFTER alpha_sort_code,
    CHANGE COLUMN BookCount series_count int(11) NOT NULL default 0
        AFTER imprint_count,
    CHANGE COLUMN IssueCount issue_count int(11) NOT NULL default 0
        AFTER series_count,
    CHANGE COLUMN Created created date NOT NULL AFTER issue_count,
    CHANGE COLUMN Modified modified date NOT NULL AFTER created,
    CONVERT TO CHARACTER SET utf8;

-- ************ SERIES *************

-- There's one really pathological series with a PubDates of 1988 and
-- otherwise all blank/null/zero values.
UPDATE series SET Created='0001-01-01' WHERE created IS NULL;
UPDATE series SET Modified=Created WHERE Modified IS NULL;
UPDATE series SET ModTime=0 WHERE ModTime IS NULL;
UPDATE series SET HasGallery=0 WHERE HasGallery IS NULL;

ALTER TABLE series RENAME core_series,
                   DROP COLUMN Crossref,
                   DROP COLUMN CrossrefID,
                   DROP COLUMN `File`,
                   DROP COLUMN Included,
                   DROP COLUMN Indexers,
                   DROP COLUMN LstChang,
                   DROP COLUMN oldID,
                   DROP COLUMN SelfCount,
                   DROP COLUMN Themes,
                   DROP COLUMN UpdateDist,
    CHANGE COLUMN ID id int(11) NOT NULL auto_increment FIRST,
    CHANGE COLUMN Bk_Name name varchar(255) NOT NULL AFTER id,
    CHANGE COLUMN Format format varchar(255) default NULL AFTER name,
    CHANGE COLUMN Yr_Began year_began int(11) NOT NULL AFTER format,
    CHANGE COLUMN Yr_Ended year_ended int(11) default NULL AFTER year_began,
    CHANGE COLUMN PubDates publication_dates varchar(255) default NULL
        AFTER year_ended,
    CHANGE COLUMN CounCode country_code varchar(4) default NULL
        COMMENT 'Should be replaced with country_id to core_country table.'
        AFTER publication_dates,
    CHANGE COLUMN LangCode language_code varchar(3) default NULL
        COMMENT 'Should be replaced with language_id to core_language table.'
        AFTER country_code,
    CHANGE COLUMN PubID publisher_id int(11) NOT NULL
        COMMENT 'Should only link to Master publishers.'
        AFTER language_code,
    MODIFY COLUMN imprint_id int(11) default NULL
        COMMENT 'Should only link to non-Master publishers.'
        AFTER publisher_id,
    CHANGE COLUMN Frst_Iss first_issue varchar(25) default NULL
        AFTER imprint_id,
    CHANGE COLUMN Last_Iss last_issue varchar(25) default NULL
        AFTER first_issue,
    CHANGE COLUMN Pub_Note publication_notes mediumtext
        COMMENT 'Another attempt to capture imprint and other publisher data'
        AFTER last_issue,
    CHANGE COLUMN Tracking tracking_notes mediumtext
        COMMENT 'For tracking numbering across series re-names.'
        AFTER publication_notes,
    CHANGE COLUMN Notes notes mediumtext AFTER tracking_notes,
    CHANGE COLUMN HasGallery has_gallery tinyint(1) NOT NULL default 0
        COMMENT 'Not entirely sure if this field is accurate or useful.'
        AFTER notes,
    CHANGE COLUMN OpenReserve open_reserve int(11) default NULL
        COMMENT 'Ignore unless you are implementing the indexing system.'
        AFTER has_gallery,
    CHANGE COLUMN Issuecount issue_count int(11) NOT NULL default 0
        AFTER open_reserve,
    CHANGE COLUMN Pub_Name publisher_name varchar(255) NOT NULL
        COMMENT 'publisher table denormalization'
        AFTER issue_count,
    CHANGE COLUMN Created created date NOT NULL AFTER publisher_name,
    CHANGE COLUMN Modified modified date NOT NULL AFTER created,
    CHANGE COLUMN ModTime modification_time time NOT NULL AFTER modified,
    CONVERT TO CHARACTER SET utf8;


-- ************ ISSUE *************

UPDATE issues SET created='0001-01-01' WHERE created IS NULL;
UPDATE issues SET Modified=Created WHERE Modified IS NULL;
UPDATE issues SET ModTime=0 WHERE ModTime IS NULL;
UPDATE issues SET IndexStatus=0 WHERE IndexStatus IS NULL;
UPDATE issues SET ReserveStatus=0 WHERE ReserveStatus IS NULL;
UPDATE issues SET VolumeNum=NULL WHERE VolumeNum = 0 AND
    Issue NOT IN ('0', '00', '0A', '0B', '0 Part A', '0 Part B') AND
    ISSUE NOT LIKE '0 [_]' AND Issue NOT LIKE '0/%';

ALTER TABLE issues RENAME core_issue,
                   DROP COLUMN Char_App,
                   DROP COLUMN Colors,
                   DROP COLUMN CoverCheck,
                   DROP COLUMN CoverCount,
                   DROP COLUMN Feature,
                   DROP COLUMN Genre,
                   DROP COLUMN InitDist,
                   DROP COLUMN Inks,
                   DROP COLUMN isUpdated,
                   DROP COLUMN Letters,
                   DROP COLUMN LstChang,
                   DROP COLUMN Pencils,
                   DROP COLUMN rel_year,
                   DROP COLUMN Reprints,
                   DROP COLUMN ReserveCheck,
                   DROP COLUMN Seq_No,
                   DROP COLUMN Script,
                   DROP COLUMN SelfCount,
                   DROP COLUMN Synopsis,
                   DROP COLUMN SeriesLink,
                   DROP COLUMN Title,
                   DROP COLUMN `Type`,
                   DROP COLUMN UpdateDist,
    CHANGE COLUMN ID id int(11) NOT NULL auto_increment FIRST,
    CHANGE COLUMN Issue `number` varchar(50) NOT NULL
        COMMENT 'Varchar to support "numbers" like "5a", "Winter Special".'
        AFTER id,
    CHANGE COLUMN VolumeNum volume int(11) default NULL
        COMMENT 'Rarely correct, often also in issue i.e. as "v1#1".'
        AFTER `number`,
    CHANGE COLUMN SeriesID series_id int(11) NOT NULL AFTER volume,
    CHANGE COLUMN Key_Date key_date varchar(10) default NULL
        COMMENT 'Format YYYY.MM.DD' AFTER series_id,
    CHANGE COLUMN Pub_Date publication_date varchar(255) default NULL
        COMMENT 'As in comic, but no abbreviations.  Not always proper date.'
        AFTER key_date,
    CHANGE COLUMN Price price varchar(255) default NULL
        COMMENT 'Format: decimal followed by ISO code, but often is not.'
        AFTER publication_date,
    CHANGE COLUMN Pg_Cnt page_count varchar(10) default NULL AFTER price,
    CHANGE COLUMN Editing editing mediumtext AFTER page_count,
    CHANGE COLUMN IndexStatus index_status int(11) NOT NULL default 0
        COMMENT 'Ignore unless you are implementing the indexing system.'
        AFTER editing,
    CHANGE COLUMN ReserveStatus reserve_status int(11) NOT NULL default 0
        COMMENT 'Ignore unless you are implementing the indexing system.'
        AFTER index_status,
    CHANGE COLUMN Notes notes mediumtext
        COMMENT 'May also have notes for sequence 0.' AFTER reserve_status,
    CHANGE COLUMN storycount sequence_count int(11) NOT NULL default 0
        AFTER notes,
    CHANGE COLUMN Bk_Name series_name varchar(255) NOT NULL
        COMMENT 'series table denormalization' AFTER sequence_count,
    CHANGE COLUMN Yr_Began year_began int(11) NOT NULL
        COMMENT 'series table denormalization' AFTER series_name,
    CHANGE COLUMN Pub_Name publisher_name varchar(255) NOT NULL
        COMMENT 'publisher table denormalization' AFTER year_began,
    CHANGE COLUMN created created date NOT NULL AFTER publisher_name,
    CHANGE COLUMN Modified modified date NOT NULL AFTER created,
    CHANGE COLUMN ModTime modification_time time NOT NULL AFTER modified,
    CONVERT TO CHARACTER SET utf8;

-- ************ SEQUENCE *************

UPDATE stories SET Created='0001-01-01' WHERE created IS NULL;
UPDATE stories SET Modified=Created WHERE Modified IS NULL;
UPDATE stories SET ModTime=0 WHERE ModTime IS NULL;

ALTER TABLE stories RENAME core_sequence,
                    DROP COLUMN rel_year,
                    DROP COLUMN LstChang,
                    DROP COLUMN InitDist,
                    DROP COLUMN IssueCount,
    CHANGE COLUMN ID id int(11) NOT NULL auto_increment FIRST,
    CHANGE COLUMN Title title varchar(255) default NULL AFTER id,
    CHANGE COLUMN Feature feature varchar(255) default NULL
        COMMENT 'Feature name, not featured character.' AFTER title,
    CHANGE COLUMN Seq_No `number` int(11) NOT NULL
        COMMENT 'Sequence zero is always the (first) cover.' AFTER feature,
    CHANGE COLUMN Pg_Cnt page_count varchar(10) default NULL AFTER `number`,
    CHANGE COLUMN `Type` `type` varchar(50) default NULL AFTER page_count,
    CHANGE COLUMN JobNo job_number varchar(25) default NULL
        COMMENT 'Strictly speaking, not always a number.' AFTER `type`,
    CHANGE COLUMN Script script mediumtext AFTER job_number,
    CHANGE COLUMN Pencils pencils mediumtext AFTER script,
    CHANGE COLUMN Inks inks mediumtext AFTER pencils,
    CHANGE COLUMN Colors colors mediumtext AFTER inks,
    CHANGE COLUMN Letters letters mediumtext AFTER colors,
    CHANGE COLUMN Editing editing mediumtext AFTER letters,
    CHANGE COLUMN Genre genre varchar(255) default NULL AFTER editing,
    CHANGE COLUMN Char_App characters mediumtext AFTER genre,
    CHANGE COLUMN Synopsis synopsis mediumtext AFTER characters,
    CHANGE COLUMN Reprints reprints mediumtext AFTER synopsis,
    CHANGE COLUMN Notes notes mediumtext AFTER reprints,
    CHANGE COLUMN IssueID issue_id int(11) NOT NULL AFTER notes,
    CHANGE COLUMN SeriesID series_id int(11) NOT NULL
        COMMENT 'issue table denormalization.' AFTER issue_id,
    CHANGE COLUMN Issue issue_number varchar(50) NOT NULL
        COMMENT 'issue table denormalization.' AFTER series_id,
    CHANGE COLUMN Bk_Name series_name varchar(255) NOT NULL
        COMMENT 'series table denormalization' AFTER issue_number,
    CHANGE COLUMN Yr_Began year_began int(11) NOT NULL
        COMMENT 'series table denormalization' AFTER series_name,
    CHANGE COLUMN Pub_Name publisher_name varchar(255) NOT NULL
        COMMENT 'publisher table denormalization' AFTER year_began,
    CHANGE COLUMN Created created date NOT NULL AFTER publisher_name,
    CHANGE COLUMN Modified modified date NOT NULL AFTER created,
    CHANGE COLUMN ModTime modification_time time NOT NULL AFTER modified,
    CONVERT TO CHARACTER SET utf8;

-- *********** COVERS ************

UPDATE covers SET Marked=0 WHERE Marked IS NULL;
UPDATE covers SET Created='0001-01-01' WHERE created IS NULL;
UPDATE covers SET Modified=Created WHERE Modified IS NULL;
UPDATE covers SET CreTime=0 WHERE CreTime IS NULL;
UPDATE covers SET ModTime=CreTime WHERE ModTime IS NULL;

ALTER TABLE covers RENAME core_cover,
                   DROP COLUMN variant_code,
                   DROP COLUMN variant_text,
                   DROP COLUMN is_master,
                   DROP COLUMN Count,
                   DROP COLUMN Coverage,
                   DROP COLUMN CoversThisTitle,
    CHANGE COLUMN ID id int(11) NOT NULL auto_increment FIRST,
    CHANGE COLUMN IssueID issue_id int(11) NOT NULL AFTER id,
    CHANGE COLUMN Issue issue_number varchar(50) NOT NULL
        COMMENT 'From the issue table.'
        AFTER issue_id,
    CHANGE COLUMN SeriesID series_id int(11) NOT NULL AFTER issue_number,
    ADD COLUMN sequence_id int(11) default NULL
        COMMENT 'Will be NULL for issues with no sequences indexed.'
        AFTER series_id,
    ADD COLUMN sequence_number int(11) default NULL
        COMMENT 'Zero until we have a way to add images to other sequences.'
        AFTER sequence_id,
    CHANGE COLUMN covercode sort_code varchar(50) NOT NULL
        AFTER sequence_number,
    CHANGE COLUMN HasImage has_image tinyint(1) NOT NULL
        COMMENT 'May be dropped if has_* fields are sufficient.'
        AFTER sort_code,
    CHANGE COLUMN Marked marked tinyint(1) NOT NULL default 0
        COMMENT 'If 1, cover has been marked for replacement' AFTER has_image,
    CHANGE COLUMN c1 has_small tinyint(1) NOT NULL default 0 AFTER marked,
    CHANGE COLUMN c2 has_medium tinyint(1) NOT NULL default 0 AFTER has_small,
    CHANGE COLUMN c4 has_large tinyint(1) NOT NULL default 0 AFTER has_medium,
    CHANGE COLUMN gfxserver server_version int(11) NOT NULL default 1
        AFTER has_large,
    CHANGE COLUMN contributor contributor varchar(255) default NULL
        AFTER server_version,
    CHANGE COLUMN Pub_Name publisher_name varchar(255) NOT NULL
        COMMENT 'publisher table denormalization' AFTER contributor,
    CHANGE COLUMN Bk_Name series_name varchar(255) NOT NULL
        COMMENT 'series table denormalization' AFTER publisher_name,
    CHANGE COLUMN Yr_Began year_began int(11) NOT NULL
        COMMENT 'series table denormalization' AFTER series_name,
    CHANGE COLUMN Created created date NOT NULL default '0001-01-01'
        AFTER year_began,
    CHANGE COLUMN CreTime creation_time time NOT NULL default 0 AFTER created,
    CHANGE COLUMN Modified modified date NOT NULL default '0001-01-01'
        AFTER creation_time,
    CHANGE COLUMN Modtime modification_time time NOT NULL default 0
        AFTER modified,
    CONVERT TO CHARACTER SET utf8;

-- Fix issue-wide editor credits and notes.
-- Must be done after ALTER TABLE because old issues.Editing field is smaller.
UPDATE core_issue INNER JOIN core_sequence
                          ON core_sequence.issue_id=core_issue.id
    SET core_issue.page_count=core_sequence.page_count,
        core_issue.editing=core_sequence.editing,
        core_issue.notes=core_sequence.notes
    WHERE core_sequence.`number`=0;
UPDATE core_sequence SET page_count=1, editing=NULL, notes=NULL
    WHERE `number`=0;


-- Reservation table- last-minute addition, no data fixup.
ALTER TABLE Reservations RENAME core_reservation,
    CHANGE COLUMN ID id int(11) NOT NULL auto_increment,
    CHANGE COLUMN IndexerID indexer_id int(11) NOT NULL,
    CHANGE COLUMN IssueID issue_id int(11) NOT NULL,
    CHANGE COLUMN Status status int(11) NOT NULL,
    CHANGE COLUMN IndexType index_type int(11) NOT NULL AFTER status,
    CHANGE COLUMN Expires expires date default NULL AFTER index_type,
    CHANGE COLUMN Created created date default NULL AFTER expires,
    CONVERT TO CHARACTER SET utf8;

