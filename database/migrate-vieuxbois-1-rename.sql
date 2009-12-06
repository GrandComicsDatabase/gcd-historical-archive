SET SESSION sql_mode='STRICT_ALL_TABLES';

-- BEGIN Table restructuring statements
-- And yes, reording columns in mysql is somewhat pointless, but this just
-- makes things show up much nicer in test queries of the SELECT(*) form and
-- lines up a bit better with how the code is organized (although that won't be
-- kept in strict correspondence).  Plus we have to rename nearly all of the
-- columns anyway.

SET foreign_key_checks = 0;

ALTER TABLE Countries RENAME gcd_country,
    CHANGE COLUMN ID id int(11) NOT NULL auto_increment FIRST,
    CHANGE COLUMN code code varchar(10) NOT NULL UNIQUE,
    CHANGE COLUMN country name varchar(255) NOT NULL,
    CONVERT TO CHARACTER SET utf8;

ALTER TABLE Languages RENAME gcd_language,
    CHANGE COLUMN ID id int(11) NOT NULL auto_increment FIRST,
    CHANGE COLUMN code code varchar(10) NOT NULL UNIQUE,
    CHANGE COLUMN language name varchar(255) NOT NULL,
    CONVERT TO CHARACTER SET utf8;

-- Due to restrictions on updates and subqueries, we need temporary tables
-- in order to fix several things that correlate publishers and imprints.
-- Then fix imprint counts.
CREATE TEMPORARY TABLE imprints (id int(11), publisher_id int(11));
INSERT INTO imprints (id, publisher_id)
    SELECT ID, ParentID FROM publishers
        WHERE ParentID IS NOT NULL AND ParentID != 0;
UPDATE publishers SET ImprintCount=
    (SELECT COUNT(*) FROM imprints WHERE imprints.publisher_id=publishers.ID);

UPDATE publishers SET Notes='' WHERE Notes IS NULL;
UPDATE publishers SET web='' WHERE web IS NULL;
ALTER TABLE publishers RENAME gcd_publisher,
    CHANGE COLUMN ID id int(11) NOT NULL auto_increment FIRST,
    CHANGE COLUMN PubName name varchar(255) NOT NULL AFTER id,
    CHANGE COLUMN CountryID country_id int(11) NOT NULL AFTER name,
    CHANGE COLUMN YearBegan year_began int(11) default NULL AFTER country_id,
    CHANGE COLUMN YearEnded year_ended int(11) default NULL
        AFTER year_began,
    CHANGE COLUMN Notes notes longtext NOT NULL AFTER year_ended,
    CHANGE COLUMN web url varchar(255) NOT NULL default '' AFTER notes,
    CHANGE COLUMN Master is_master tinyint(1) NOT NULL AFTER url,
    CHANGE COLUMN ParentID parent_id int(11) default NULL
        AFTER is_master,
    CHANGE COLUMN ImprintCount imprint_count int(11) NOT NULL default 0
        AFTER parent_id,
    ADD COLUMN brand_count int(11) NOT NULL default 0 AFTER imprint_count,
    ADD COLUMN indicia_publisher_count int(11) NOT NULL default 0 AFTER brand_count,
    CHANGE COLUMN BookCount series_count int(11) NOT NULL default 0
        AFTER indicia_publisher_count,
    CHANGE COLUMN IssueCount issue_count int(11) NOT NULL default 0
        AFTER series_count,
    CHANGE COLUMN Created created datetime NOT NULL
        default '1901-01-01 00:00:00' AFTER series_count,
    CHANGE COLUMN Modified modified datetime NOT NULL
        default '1901-01-01 00:00:00' AFTER created,
    ADD INDEX (country_id),
    ADD INDEX (brand_count),
    ADD INDEX (indicia_publisher_count),
    ADD FOREIGN KEY (country_id) REFERENCES gcd_country (id),
    ADD FOREIGN KEY (parent_id) REFERENCES gcd_publisher (id);

UPDATE gcd_publisher SET url=CONCAT('http://', url)
    WHERE url IS NOT NULL AND url != '' AND url NOT LIKE 'http://%';

CREATE TABLE gcd_indicia_publisher (
    id int(11) NOT NULL auto_increment,
    name varchar(255) NOT NULL,
    parent_id int(11) NOT NULL,
    country_id int(11) NOT NULL,
    year_began int(11) default NULL,
    year_ended int(11) default NULL,
    is_surrogate tinyint(1) NOT NULL default 0,
    notes longtext,
    url varchar(255) NOT NULL default '',
    issue_count int(11) NOT NULL default 0,
    created datetime NOT NULL,
    modified datetime NOT NULL,
    reserved tinyint(1) NOT NULL default 0,
    PRIMARY KEY (id),
    KEY (name),
    KEY (parent_id),
    KEY (country_id),
    KEY (year_began),
    KEY (is_surrogate),
    KEY (reserved),
    FOREIGN KEY (parent_id) REFERENCES gcd_publisher (id),
    FOREIGN KEY (country_id) REFERENCES gcd_country (id)
) ENGINE=InnoDB;

CREATE TABLE gcd_brand (
    id int(11) NOT NULL auto_increment,
    name varchar(255) NOT NULL,
    parent_id int(11) NOT NULL,
    year_began int(11) default NULL,
    year_ended int(11) default NULL,
    notes longtext,
    url varchar(255) default NULL,
    issue_count int(11) NOT NULL default 0,
    created datetime NOT NULL,
    modified datetime NOT NULL,
    reserved tinyint(1) NOT NULL default 0,
    PRIMARY KEY (id),
    KEY (name),
    KEY (parent_id),
    KEY (year_began),
    KEY (reserved),
    FOREIGN KEY (parent_id) REFERENCES gcd_publisher (id)
) ENGINE=InnoDB;

UPDATE series SET Pub_Note='' WHERE Pub_Note IS NULL;
ALTER TABLE series RENAME gcd_series,
                   DROP COLUMN Pub_Name,
                   DROP COLUMN Frst_Iss,
                   DROP COLUMN Last_Iss,
    CHANGE COLUMN ID id int(11) NOT NULL auto_increment FIRST,
    CHANGE COLUMN Bk_Name name varchar(255) NOT NULL AFTER id,
    CHANGE COLUMN Format format varchar(255) NOT NULL default '' AFTER name,
    CHANGE COLUMN Yr_Began year_began int(11) NOT NULL AFTER format,
    CHANGE COLUMN Yr_Ended year_ended int(11) default NULL AFTER year_began,
    CHANGE COLUMN PubDates publication_dates varchar(255) NOT NULL default ''
        AFTER year_ended,
    ADD COLUMN first_issue_id int(11) default NULL AFTER publication_dates,
    ADD COLUMN last_issue_id int(11) default NULL AFTER first_issue_id,
    ADD COLUMN is_current tinyint(1) NOT NULL default 0 AFTER last_issue_id,
    CHANGE COLUMN PubID publisher_id int(11) NOT NULL AFTER is_current,
    MODIFY COLUMN imprint_id int(11) default NULL AFTER publisher_id,
    CHANGE COLUMN CounCode country_code varchar(4) default NULL AFTER imprint_id,
    ADD COLUMN country_id int(11) NOT NULL AFTER country_code,
    CHANGE COLUMN LangCode language_code varchar(3) default NULL AFTER country_id,
    ADD COLUMN language_id int(11) NOT NULL AFTER language_code,
    CHANGE COLUMN Tracking tracking_notes longtext NOT NULL AFTER language_id,
    CHANGE COLUMN Notes notes longtext NOT NULL AFTER tracking_notes,
    CHANGE COLUMN Pub_Note publication_notes longtext NOT NULL AFTER notes,
    CHANGE COLUMN HasGallery has_gallery tinyint(1) NOT NULL default 0
        AFTER publication_notes,
    CHANGE COLUMN OpenReserve open_reserve int(11) default NULL AFTER has_gallery,
    CHANGE COLUMN Issuecount issue_count int(11) NOT NULL default 0
        AFTER open_reserve,
    CHANGE COLUMN Created created datetime NOT NULL
        default '1901-01-01 00:00:00' AFTER issue_count,
    CHANGE COLUMN Modified modified datetime NOT NULL
        default '1901-01-01 00:00:00' AFTER created,
    ADD FOREIGN KEY (imprint_id) REFERENCES gcd_publisher (id),
    ADD FOREIGN KEY (publisher_id) REFERENCES gcd_publisher (id);

UPDATE gcd_series SET language_code = 'zxx' WHERE id = 31796;
UPDATE gcd_series SET language_code = 'se' WHERE id = 36187;
UPDATE gcd_series SET language_code = 'sma' WHERE id = 36188;
UPDATE gcd_series SET language_code = 'smj' WHERE id = 36189;
UPDATE gcd_series SET language_code = 'en' WHERE language_code in ('us, ee');

-- Yes, this illustrates the silliness of using a numeric foreign key here,
-- but now is not the time to go through the code and restructure the relation.
UPDATE gcd_series s INNER JOIN gcd_language l ON s.language_code = l.code
    SET s.language_id = l.id;
UPDATE gcd_series s INNER JOIN gcd_country c ON s.country_code = c.code
    SET s.country_id = c.id;
ALTER TABLE gcd_series DROP COLUMN country_code, DROP COLUMN language_code;

UPDATE issues SET Pub_Date='' WHERE Pub_Date IS NULL;
UPDATE issues SET Key_Date='' WHERE Key_Date IS NULL;
UPDATE issues SET Price='' WHERE Price IS NULL;
ALTER TABLE issues RENAME gcd_issue,
                   DROP COLUMN Bk_Name,
                   DROP COLUMN Yr_Began,
                   DROP COLUMN Pub_Name,
                   DROP COLUMN storycount,
    CHANGE COLUMN ID id int(11) NOT NULL auto_increment FIRST,
    CHANGE COLUMN Issue `number` varchar(50) NOT NULL AFTER id,
    CHANGE COLUMN VolumeNum volume int(11) default NULL AFTER `number`,
    ADD COLUMN no_volume tinyint(1) NOT NULL default 0 AFTER volume,
    ADD COLUMN display_volume_with_number tinyint(1) NOT NULL default 0
        AFTER no_volume,
    CHANGE COLUMN SeriesID series_id int(11) NOT NULL
        AFTER display_volume_with_number,
    ADD COLUMN indicia_publisher_id int(11) default NULL AFTER series_id,
    ADD COLUMN brand_id int(11) default NULL AFTER indicia_publisher_id,
    CHANGE COLUMN Pub_Date publication_date varchar(255) default NULL
        AFTER brand_id,
    CHANGE COLUMN Key_Date key_date varchar(10) default NULL
        AFTER publication_date,
    ADD COLUMN sort_code int(11) unsigned NOT NULL default 0 AFTER key_date,
    CHANGE COLUMN Price price varchar(255) default NULL AFTER sort_code,
    ADD COLUMN page_count decimal(10, 3) default NULL AFTER price,
    ADD COLUMN page_count_uncertain tinyint(1) NOT NULL default 0 AFTER page_count,
    ADD COLUMN indicia_frequency varchar(255) NOT NULL default ''
        AFTER page_count_uncertain,
    ADD COLUMN editing longtext NOT NULL AFTER indicia_frequency,
    ADD COLUMN no_editing tinyint(1) NOT NULL default 0 AFTER editing,
    ADD COLUMN notes longtext NOT NULL AFTER no_editing,
    ADD COLUMN story_type_count int(11) NOT NULL default 0 AFTER notes,
    CHANGE COLUMN IndexStatus index_status int(11) NOT NULL default 0
        AFTER story_type_count,
    CHANGE COLUMN ReserveStatus reserve_status int(11) NOT NULL default 0
        AFTER index_status,
    CHANGE COLUMN ReserveCheck reserve_check int(11) default NULL
        AFTER reserve_status,
    CHANGE COLUMN created created datetime NOT NULL
        default '1901-01-01 00:00:00' AFTER reserve_check,
    CHANGE COLUMN Modified modified datetime NOT NULL
        default '1901-01-01 00:00:00' AFTER created,
    ADD INDEX (no_volume),
    ADD INDEX (display_volume_with_number),
    ADD INDEX (indicia_publisher_id),
    ADD INDEX (brand_id),
    ADD INDEX (no_editing),
    ADD INDEX (story_type_count),
    ADD INDEX (reserve_check),
    ADD FOREIGN KEY (series_id) REFERENCES gcd_series (id),
    ADD FOREIGN KEY (indicia_publisher_id) REFERENCES gcd_indicia_publisher (id),
    ADD FOREIGN KEY (brand_id) REFERENCES gcd_brand (id);

ALTER TABLE gcd_series
    ADD FOREIGN KEY (country_id) REFERENCES gcd_country (id),
    ADD FOREIGN KEY (language_id) REFERENCES gcd_language (id),
    ADD FOREIGN KEY (first_issue_id) REFERENCES gcd_issue (id),
    ADD FOREIGN KEY (last_issue_id) REFERENCES gcd_issue (id);

-- Drop indexes we're not using for search (because they don't help the kind of
-- searching we do) because they are quite expensive.
ALTER TABLE stories RENAME gcd_story,
                    DROP INDEX Seq_No,
                    DROP INDEX Title,
                    DROP INDEX Feature,
                    DROP INDEX JobNo,
    CHANGE COLUMN ID id int(11) NOT NULL auto_increment FIRST,
    CHANGE COLUMN Title title varchar(255) NOT NULL default '' AFTER id,
    ADD COLUMN title_inferred tinyint(1) NOT NULL default 0 AFTER title,
    CHANGE COLUMN Feature feature varchar(255) NOT NULL AFTER title_inferred,
    CHANGE COLUMN Seq_No sequence_number int(11) NOT NULL AFTER feature,
    CHANGE COLUMN Pg_Cnt page_count decimal(10, 3) default NULL
        AFTER sequence_number,
    CHANGE COLUMN `Type` `type` varchar(50) default NULL AFTER page_count_uncertain,
    ADD COLUMN type_id int(11) NOT NULL AFTER `type`,
    CHANGE COLUMN JobNo job_number varchar(25) NOT NULL default '' AFTER `type_id`,
    CHANGE COLUMN IssueID issue_id int(11) NOT NULL,
    CHANGE COLUMN Script script longtext NOT NULL AFTER issue_id,
    CHANGE COLUMN Pencils pencils longtext NOT NULL AFTER script,
    CHANGE COLUMN Inks inks longtext NOT NULL AFTER pencils,
    CHANGE COLUMN Colors colors longtext NOT NULL AFTER inks,
    CHANGE COLUMN Letters letters longtext NOT NULL AFTER colors,
    CHANGE COLUMN Editing editing longtext NOT NULL AFTER letters,
    ADD COLUMN no_editing tinyint(1) NOT NULL default 0 AFTER no_letters,
    CHANGE COLUMN Genre genre varchar(255) NOT NULL default '' AFTER editing,
    CHANGE COLUMN Char_App characters longtext NOT NULL AFTER genre,
    CHANGE COLUMN Synopsis synopsis longtext NOT NULL AFTER characters,
    CHANGE COLUMN Reprints reprint_notes longtext NOT NULL AFTER synopsis,
    CHANGE COLUMN Notes notes longtext NOT NULL AFTER reprint_notes,
    CHANGE COLUMN Created created datetime NOT NULL
        default '1901-01-01 00:00:00' AFTER reprint_notes,
    CHANGE COLUMN Modified modified datetime NOT NULL
        default '1901-01-01 00:00:00' AFTER created,
    ADD INDEX (no_editing),
    ADD FOREIGN KEY (issue_id) REFERENCES gcd_issue (id);

ALTER TABLE covers RENAME gcd_cover,
                   DROP COLUMN c1,
                   DROP COLUMN c2,
                   DROP COLUMN c4,
                   DROP COLUMN is_master,
                   DROP COLUMN Count,
                   DROP COLUMN Coverage,
                   DROP COLUMN CoversThisTitle,
                   DROP COLUMN Pub_Name,
                   DROP COLUMN Bk_Name,
                   DROP COLUMN Yr_Began,
                   DROP COLUMN Issue,
    CHANGE COLUMN ID id int(11) NOT NULL auto_increment FIRST,
    CHANGE COLUMN IssueID issue_id int(11) NOT NULL AFTER id,
    CHANGE COLUMN covercode code varchar(50) NOT NULL AFTER issue_id,
    CHANGE COLUMN HasImage has_image tinyint(1) NOT NULL default 0
        AFTER code,
    CHANGE COLUMN Marked marked tinyint(1) NOT NULL default 0 AFTER has_image,
    CHANGE COLUMN contributor contributor varchar(255) default NULL
        AFTER marked,
    CHANGE COLUMN gfxserver server_version int(11) NOT NULL default 1
        AFTER contributor,
    CHANGE COLUMN SeriesID series_id int(11) NOT NULL AFTER server_version,
    CHANGE COLUMN Created created datetime NOT NULL
        default '1901-01-01 00:00:00' AFTER series_id,
    CHANGE COLUMN Modified modified datetime NOT NULL
        default '1901-01-01 00:00:00' AFTER created,
    ADD FOREIGN KEY (issue_id) REFERENCES gcd_issue (id),
    ADD FOREIGN KEY (series_id) REFERENCES gcd_series (id);

-- ----------------------------------------------------------------------------
-- Move to numeric issue sort codes on the actual issue table.
-- Leave the existing codes in place for now as filesystem locators.
-- ----------------------------------------------------------------------------
CREATE TEMPORARY TABLE sort_helper (
    id int(11) NOT NULL auto_increment,
    cover_id int(11),
    issue_id int(11),
    PRIMARY KEY (id) 
);

INSERT INTO sort_helper (cover_id, issue_id)
    SELECT c.id, i.id FROM gcd_cover c INNER JOIN gcd_issue i
                                  ON c.issue_id = i.id
                ORDER BY c.series_id, c.code, i.key_date;

UPDATE gcd_issue i INNER JOIN sort_helper h ON i.id = h.issue_id
    SET i.sort_code=h.id;

ALTER TABLE gcd_issue ADD INDEX (sort_code),
                      ADD UNIQUE series_id_sort_code (series_id, sort_code);

-- ----------------------------------------------------------------------------
-- OI and Account Management tables.  Leave in gcd app for simplicity.
-- ----------------------------------------------------------------------------

-- There's only one indexer without a country, and he is inactive and has
-- no credits.  Statistically speaking, probably American (and his name yeilds
-- no clues to the contrary).  So just go with that with apologies if incorrect.
UPDATE Indexers SET country_id=(SELECT id FROM gcd_country WHERE code = 'us')
    WHERE country_id IS NULL;

ALTER TABLE Indexers RENAME gcd_indexer,
    CHANGE COLUMN ID id int(11) NOT NULL auto_increment,
    MODIFY COLUMN country_id int(11) NOT NULL,
    MODIFY COLUMN user_id int(11) NOT NULL,
    MODIFY COLUMN mentor_id int(11) default NULL,
    ADD FOREIGN KEY (country_id) REFERENCES gcd_country (id),
    ADD FOREIGN KEY (user_id) REFERENCES auth_user (id),
    ADD FOREIGN KEY (mentor_id) REFERENCES auth_user (id);

-- Set correct new indexer limits.  Set extremely high non-new indexer limits
-- as the Board has not yet set official ones.
UPDATE gcd_indexer SET max_reservations=1, max_ongoing=0 WHERE is_new = 1;
UPDATE gcd_indexer SET max_reservations=500, max_ongoing=100 WHERE is_new = 0;

ALTER TABLE Indexers_languages ENGINE=InnoDB;
ALTER TABLE Indexers_languages RENAME gcd_indexer_languages,
    ADD FOREIGN KEY (indexer_id) REFERENCES gcd_indexer (id),
    ADD FOREIGN KEY (language_id) REFERENCES gcd_language (id);

UPDATE Reservations SET Expires='1901-01-01' WHERE Expires = '0000-00-00';
ALTER TABLE Reservations RENAME gcd_reservation,
                         DROP IndexType,
    CHANGE COLUMN ID id int(11) NOT NULL auto_increment,
    CHANGE COLUMN IndexerID indexer_id int(11) NOT NULL,
    CHANGE COLUMN IssueID issue_id int(11) NOT NULL,
    CHANGE COLUMN `Status` `status` int(11) NOT NULL,
    CHANGE COLUMN Expires expires date default NULL AFTER `status`,
    CHANGE COLUMN Created created datetime
        default '1901-01-01 00:00:00' AFTER expires,
    ADD FOREIGN KEY (issue_id) REFERENCES gcd_issue (id),
    ADD FOREIGN KEY (indexer_id) REFERENCES gcd_indexer (id);

-- We apparently have numerous issues reserved that don't actually exist.
DELETE r FROM gcd_reservation r LEFT OUTER JOIN gcd_issue i ON i.id=r.issue_id
    WHERE i.id IS NULL;

ALTER TABLE IndexCredit RENAME gcd_series_indexers,
                        DROP COLUMN `Comment`,
    CHANGE COLUMN ID id int(11) NOT NULL auto_increment,
    CHANGE COLUMN IndexerID indexer_id int(11) NOT NULL,
    CHANGE COLUMN SeriesID series_id int(11) NOT NULL,
    CHANGE COLUMN Run run varchar(255) default NULL,
    CHANGE COLUMN Notes notes longtext AFTER run,
    CHANGE COLUMN DateMod modified datetime NOT NULL
        default '1901-01-01 00:00:00' AFTER notes,
    ADD FOREIGN KEY (series_id) REFERENCES gcd_series (id),
    ADD FOREIGN KEY (indexer_id) REFERENCES gcd_indexer (id);

ALTER TABLE Errors RENAME gcd_error;
 
-- Remove cover upload permission from the incorrect place we had it.
-- Should be attached to the profile table like other indexer-based permissions.
DELETE FROM auth_group_permissions WHERE permission_id =
    (SELECT id FROM auth_permission WHERE codename='can_upload_cover');
DELETE FROM auth_permission WHERE codename='can_upload_cover';

-- ----------------------------------------------------------------------------
-- Fix issue-wide editor credits and notes.
-- Must be done after initial ALTER TABLEs because old
-- issues.Editing field is smaller.
-- This duplicates the notes in the issue and covers story fields, as debate
-- on the mailing lists determined that the notes can easily apply to either,
-- or both, and that no usage was sufficiently prevalent to enforce.
-- GCD contributors will just have to adjust the notes manually to remove
-- duplication.
--
-- Note that while we're technically not ceratain about all cover page counts
-- being "1" (in fact, wraparounds and gatefolds are definitely not "1"), it's
-- not worth flagging the whole database as uncertain.  We'll just fix those
-- as we go along manually.
-- ----------------------------------------------------------------------------
UPDATE gcd_issue INNER JOIN gcd_story
                         ON gcd_story.issue_id=gcd_issue.id
    SET gcd_issue.page_count=gcd_story.page_count,
        gcd_issue.page_count_uncertain=gcd_story.page_count_uncertain,
        gcd_issue.editing=gcd_story.editing,
        gcd_issue.notes=gcd_story.notes
    WHERE gcd_story.sequence_number = 0;
UPDATE gcd_story SET page_count=1, page_count_uncertain=0,
                     editing='', no_editing=1
    WHERE sequence_number = 0;

UPDATE gcd_story SET editing='', no_editing=1
    WHERE editing IS NULL OR editing IN ('', 'none', 'n/a', 'NA', 'nessuno');
UPDATE gcd_issue SET editing='', no_editing=1
    WHERE editing IN ('none', 'n/a', 'NA', 'nessuno');
UPDATE gcd_issue SET editing='' WHERE editing IS NULL;

-- ----------------------------------------------------------------------------
-- Factor out sequence type and set up inferred title flag.
-- Leave sort code not null and not unique until after it's populated.
-- ----------------------------------------------------------------------------

CREATE TABLE gcd_story_type (
    id int(11) auto_increment NOT NULL,
    name varchar(50) NOT NULL UNIQUE,
    sort_code int(11),
    PRIMARY KEY (id),
    KEY type_name (name)
) ENGINE=InnoDB;

INSERT INTO gcd_story_type (name) SELECT DISTINCT `type` FROM gcd_story;

UPDATE gcd_story_type t INNER JOIN gcd_story q ON t.name=q.`type`
    SET q.type_id=t.id;
UPDATE gcd_story_type SET sort_code=1 WHERE name='story';
UPDATE gcd_story_type SET sort_code=2 WHERE name='text story';
UPDATE gcd_story_type SET sort_code=3 WHERE name='text article';
UPDATE gcd_story_type SET sort_code=4 WHERE name='photo story';
UPDATE gcd_story_type SET sort_code=5 WHERE name='cover';
UPDATE gcd_story_type SET sort_code=6, name='cover reprint (on interior page)'
    WHERE name='cover reprint';
UPDATE gcd_story_type SET sort_code=7 WHERE name='cartoon';
UPDATE gcd_story_type SET sort_code=8, name='illustration' WHERE name='pinup';
UPDATE gcd_story_type SET sort_code=9, name='advertisement' WHERE name='ad';
UPDATE gcd_story_type SET sort_code=10, name='promo (ad from the publisher)'
    WHERE name='promo';
UPDATE gcd_story_type SET sort_code=11, name='public service announcement'
    WHERE name='psa';
UPDATE gcd_story_type SET sort_code=12 WHERE name='activity';
UPDATE gcd_story_type SET sort_code=13, name='biography (nonfictional)'
    WHERE name='bio';
UPDATE gcd_story_type SET sort_code=14, name='character profile'
    WHERE name='profile';
UPDATE gcd_story_type SET sort_code=15,
                          name='foreword, introduction, preface, afterword'
    WHERE name='foreword';
UPDATE gcd_story_type SET sort_code=16 WHERE name='credits';
UPDATE gcd_story_type SET sort_code=17 WHERE name='recap';
UPDATE gcd_story_type SET sort_code=18, name='letters page' WHERE name='letters';
UPDATE gcd_story_type SET sort_code=19, name='insert or dust jacket'
    WHERE name='insert';
UPDATE gcd_story_type SET sort_code=20 WHERE name='filler';
UPDATE gcd_story_type SET sort_code=21,
                          name='(backcovers) *do not use* / *please fix*'
    WHERE name='backcovers';

ALTER TABLE gcd_story_type
    MODIFY COLUMN sort_code int(11) NOT NULL UNIQUE;
ALTER TABLE gcd_story DROP COLUMN `type`,
    ADD INDEX (type_id),
    ADD FOREIGN KEY (type_id) REFERENCES gcd_story_type (id);

UPDATE gcd_story SET title_inferred = 1,
    title=TRIM(LEADING '[' FROM (SELECT TRIM(TRAILING ']' FROM title)))
    WHERE title LIKE '[%]';

SET @story_type=(SELECT id FROM gcd_story_type WHERE name = 'story');
UPDATE gcd_issue SET story_type_count=(
    SELECT COUNT(*) FROM gcd_story
        WHERE (issue_id = gcd_issue.id AND type_id = @story_type));

-- ----------------------------------------------------------------------------
-- Proper reprint tables!
-- ----------------------------------------------------------------------------

CREATE TABLE gcd_reprint (
    id int(11) NOT NULL auto_increment,
    source_id int(11) NOT NULL,
    target_id int(11) NOT NULL,
    notes longtext,
    reserved tinyint(1) NOT NULL default 0,
    PRIMARY KEY (id),
    KEY reprint_from (`source_id`),
    KEY reprint_to (`target_id`),
    KEY (reserved),
    FOREIGN KEY (source_id) REFERENCES gcd_story(id),
    FOREIGN KEY (target_id) REFERENCES gcd_story(id)
) ENGINE=InnoDB;

CREATE TABLE gcd_reprint_to_issue (
    id int(11) NOT NULL auto_increment,
    source_id int(11) NOT NULL,
    target_issue_id int(11) NOT NULL,
    notes longtext,
    reserved tinyint(1) NOT NULL default 0,
    PRIMARY KEY (id),
    KEY reprint_to_issue_from (`source_id`),
    KEY reprint_to_issue_to (`target_issue_id`),
    KEY (reserved),
    FOREIGN KEY (source_id) REFERENCES gcd_story(id),
    FOREIGN KEY (target_issue_id) REFERENCES gcd_issue(id)
) ENGINE=InnoDB;

CREATE TABLE gcd_reprint_from_issue (
    id int(11) NOT NULL auto_increment,
    source_issue_id int(11) NOT NULL,
    target_id int(11) NOT NULL,
    notes longtext,
    reserved tinyint(1) NOT NULL default 0,
    PRIMARY KEY (id),
    KEY reprint_to_issue_from (`source_issue_id`),
    KEY reprint_to_issue_to (`target_id`),
    KEY (reserved),
    FOREIGN KEY (source_issue_id) REFERENCES gcd_issue(id),
    FOREIGN KEY (target_id) REFERENCES gcd_story(id)
) ENGINE=InnoDB;

CREATE TABLE gcd_issue_reprint (
    id int(11) NOT NULL auto_increment,
    source_issue_id int(11) NOT NULL,
    target_issue_id int(11) NOT NULL,
    notes longtext,
    reserved tinyint(1) NOT NULL default 0,
    PRIMARY KEY (id),
    KEY issue_from (`source_issue_id`),
    KEY issue_to (`target_issue_id`),
    KEY (reserved)
) ENGINE=InnoDB;

-- Add the first Migration data table, and populate it so we can use
-- -- a proper OneToOne field in Django.

CREATE TABLE migration_story_status (
    id int(11) NOT NULL auto_increment,
    story_id int(11) NOT NULL,
    reprint_needs_inspection tinyint(1) default NULL,
    reprint_confirmed tinyint(1) default NULL,
    reprint_original_notes longtext,
    PRIMARY KEY (id),
    KEY key_reprint_needs_inspection (`reprint_needs_inspection`),
    KEY key_reprint_confirmed (`reprint_confirmed`),
    KEY key_reprint_notes (`reprint_original_notes`(255))
) ENGINE=InnoDB;

INSERT INTO migration_story_status (story_id)
    SELECT id FROM gcd_story;

-- ----------------------------------------------------------------------------
-- Series to series linking
-- ----------------------------------------------------------------------------

CREATE TABLE gcd_series_relationship_type (
    id int(11) auto_increment NOT NULL,
    name varchar(100) NOT NULL,
    description longtext,
    reserved tinyint(1) NOT NULL default 0,
    notes longtext,
    PRIMARY KEY (id),
    KEY key_name (name)
) ENGINE=InnoDB;

INSERT INTO gcd_series_relationship_type (name)
    VALUES ('numbering');

CREATE TABLE gcd_series_relationship (
    id int(11) auto_increment NOT NULL,
    source_id int(11) NOT NULL,
    target_id int(11) NOT NULL,
    source_issue_id int(11) default NULL,
    target_issue_id int(11) default NULL,
    link_type_id int(11) NOT NULL,
    notes longtext,
    PRIMARY KEY (id),
    KEY key_source (source_id),
    KEY key_target (target_id),
    KEY key_issue_source (source_issue_id),
    KEY key_issue_target (target_issue_id)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- Statistics
-- ----------------------------------------------------------------------------

CREATE TABLE gcd_count_stats (
  id int(11) NOT NULL auto_increment,
  name varchar(40) NOT NULL UNIQUE,
  count int(11) default NULL,
  PRIMARY KEY  (id),
  KEY name_index (name)
) ENGINE=InnoDB;

INSERT INTO gcd_count_stats (name, count) VALUES
    ('publishers', (SELECT COUNT(*) FROM gcd_publisher WHERE is_master = 1)),
    ('brands', (SELECT COUNT(*) FROM gcd_brand)),
    ('indicia publishers', (SELECT COUNT(*) FROM gcd_indicia_publisher)),
    ('series', (SELECT COUNT(*) FROM gcd_series)),
    ('issues', (SELECT COUNT(*) FROM gcd_issue)),
    ('issue indexes', (SELECT COUNT(*) FROM gcd_issue WHERE story_type_count > 0)),
    ('covers', (SELECT COUNT(*) FROM gcd_cover WHERE has_image = 1)),
    ('stories', (SELECT COUNT(*) from gcd_story));

-- Fix publisher and imprint count stuff that was ignored earlier when we
-- had different plans for those fields.  Do imprints first because of the small
-- number of publishers that are both master publishers and imprints.  We want
-- those to have the numbers match thier publisher counts, not imprint counts.

-- But first, set to NULL imprint_ids that point to nowhere.  How do we still have
-- these in the DB?

UPDATE gcd_series s LEFT OUTER JOIN gcd_publisher p ON s.imprint_id = p.id
    SET s.imprint_id=NULL WHERE p.id IS NULL and s.imprint_id IS NOT NULL;

UPDATE gcd_publisher p SET p.series_count=
    (SELECT COUNT(*) FROM gcd_series s WHERE s.imprint_id = p.id)
    WHERE p.parent_id IS NOT NULL;

UPDATE gcd_publisher p SET p.issue_count=
    (SELECT SUM(s.issue_count) FROM gcd_series s WHERE s.imprint_id = p.id)
    WHERE p.parent_id IS NOT NULL;
UPDATE gcd_publisher p SET p.issue_count=0
    WHERE p.series_count = 0 AND p.parent_id IS NOT NULL;

UPDATE gcd_publisher p SET p.series_count=
    (SELECT COUNT(*) FROM gcd_series s WHERE s.publisher_id = p.id)
    WHERE p.is_master = 1;

UPDATE gcd_publisher p SET p.issue_count=
    (SELECT SUM(s.issue_count) FROM gcd_series s WHERE s.publisher_id = p.id)
    WHERE p.is_master = 1;
UPDATE gcd_publisher p SET p.issue_count=0
    WHERE p.series_count = 0 AND p.is_master = 1;

SET @fixme=(SELECT id FROM gcd_country WHERE code='xx');
UPDATE gcd_publisher i INNER JOIN gcd_publisher p ON i.parent_id = p.id
    SET i.country_id=p.country_id WHERE i.country_id = @fixme;

SET foreign_key_checks = 1;

