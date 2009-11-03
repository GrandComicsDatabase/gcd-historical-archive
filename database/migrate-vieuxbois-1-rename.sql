SET SESSION sql_mode='STRICT_ALL_TABLES';

BEGIN;

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

ALTER TABLE publishers RENAME gcd_publisher,
    CHANGE COLUMN ID id int(11) NOT NULL auto_increment FIRST,
    CHANGE COLUMN PubName name varchar(255) NOT NULL AFTER id,
    CHANGE COLUMN CountryID country_id int(11) NOT NULL AFTER name,
    CHANGE COLUMN YearBegan year_began int(11) default NULL AFTER country_id,
    CHANGE COLUMN YearEnded year_ended int(11) default NULL
        AFTER year_began,
    CHANGE COLUMN Notes notes mediumtext AFTER year_ended,
    CHANGE COLUMN web url varchar(255) default NULL AFTER notes,
    CHANGE COLUMN Master is_master tinyint(1) NOT NULL AFTER url,
    CHANGE COLUMN ParentID parent_id int(11) default NULL
        -- KEY -- REFERENCES gcd_publisher (id)
        AFTER is_master,
    CHANGE COLUMN ImprintCount imprint_count int(11) NOT NULL default 0
        AFTER parent_id,
    CHANGE COLUMN BookCount series_count int(11) NOT NULL default 0
        AFTER imprint_count,
    CHANGE COLUMN IssueCount issue_count int(11) NOT NULL default 0
        AFTER series_count,
    CHANGE COLUMN Created created datetime NOT NULL
        default '1901-01-01 00:00:00' AFTER series_count,
    CHANGE COLUMN Modified modified datetime NOT NULL
        default '1901-01-01 00:00:00' AFTER created,
    ADD INDEX (country_id),
    ADD FOREIGN KEY (country_id) REFERENCES gcd_country (id),
    ADD FOREIGN KEY (parent_id) REFERENCES gcd_publisher (id);

ALTER TABLE series RENAME gcd_series,
                   DROP COLUMN Pub_Name,
    CHANGE COLUMN ID id int(11) NOT NULL auto_increment FIRST,
    CHANGE COLUMN Bk_Name name varchar(255) NOT NULL AFTER id,
    CHANGE COLUMN Format format varchar(255) default NULL AFTER name,
    CHANGE COLUMN Yr_Began year_began int(11) NOT NULL AFTER format,
    CHANGE COLUMN Yr_Ended year_ended int(11) default NULL AFTER year_began,
    CHANGE COLUMN PubDates publication_dates varchar(255) NOT NULL default ''
        AFTER year_ended,
    CHANGE COLUMN Frst_Iss first_issue varchar(50) default NULL
        AFTER publication_dates,
    CHANGE COLUMN Last_Iss last_issue varchar(50) default NULL AFTER first_issue,
    CHANGE COLUMN PubID publisher_id int(11) NOT NULL AFTER last_issue,
    MODIFY COLUMN imprint_id int(11) default NULL AFTER publisher_id,
    CHANGE COLUMN CounCode country_code varchar(4) default NULL AFTER imprint_id,
    ADD COLUMN country_id int(11) NOT NULL AFTER country_code,
    CHANGE COLUMN LangCode language_code varchar(3) default NULL AFTER country_id,
    ADD COLUMN language_id int(11) NOT NULL AFTER language_code,
    CHANGE COLUMN Tracking tracking_notes mediumtext AFTER language_id,
    CHANGE COLUMN Notes notes mediumtext AFTER tracking_notes,
    CHANGE COLUMN Pub_Note publication_notes mediumtext AFTER notes,
    CHANGE COLUMN HasGallery has_gallery tinyint(1) NOT NULL default 0
        AFTER publication_notes,
    CHANGE COLUMN OpenReserve open_reserve int(11) default NULL AFTER has_gallery,
    CHANGE COLUMN Issuecount issue_count int(11) NOT NULL default 0
        AFTER open_reserve,
    CHANGE COLUMN Created created datetime NOT NULL
        default '1901-01-01 00:00:00' AFTER issue_count,
    CHANGE COLUMN Modified modified datetime NOT NULL
        default '1901-01-01 00:00:00' AFTER created,
    ADD INDEX (country_id),
    ADD INDEX (language_id),
    ADD FOREIGN KEY (country_id) REFERENCES gcd_country (id),
    ADD FOREIGN KEY (language_id) REFERENCES gcd_language (id),
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

ALTER TABLE issues RENAME gcd_issue,
                   DROP COLUMN Bk_Name,
                   DROP COLUMN Yr_Began,
                   DROP COLUMN Pub_Name,
    CHANGE COLUMN ID id int(11) NOT NULL auto_increment FIRST,
    CHANGE COLUMN Issue `number` varchar(50) NOT NULL AFTER id,
    CHANGE COLUMN VolumeNum volume int(11) default NULL AFTER `number`,
    CHANGE COLUMN SeriesID series_id int(11) NOT NULL AFTER volume,
    CHANGE COLUMN Pub_Date publication_date varchar(255) default NULL
        AFTER series_id,
    CHANGE COLUMN Key_Date key_date varchar(10) default NULL AFTER publication_date,
    ADD COLUMN sort_code int(11) unsigned NOT NULL default 0 AFTER key_date,
    CHANGE COLUMN Price price varchar(255) default NULL AFTER sort_code,
    CHANGE COLUMN storycount story_count int(11) NOT NULL default 0 AFTER price,
    CHANGE COLUMN IndexStatus index_status int(11) NOT NULL default 0
        AFTER story_count,
    CHANGE COLUMN ReserveStatus reserve_status int(11) NOT NULL default 0
        AFTER index_status,
    CHANGE COLUMN ReserveCheck reserve_check int(11) default NULL
        AFTER reserve_status,
    CHANGE COLUMN created created datetime NOT NULL
        default '1901-01-01 00:00:00' AFTER reserve_check,
    CHANGE COLUMN Modified modified datetime NOT NULL
        default '1901-01-01 00:00:00' AFTER created,
    ADD INDEX (reserve_check),
    ADD FOREIGN KEY (series_id) REFERENCES gcd_series (id);

ALTER TABLE stories RENAME gcd_story,
    CHANGE COLUMN ID id int(11) NOT NULL auto_increment FIRST,
    CHANGE COLUMN Title title varchar(255) default NULL AFTER id,
    CHANGE COLUMN Feature feature varchar(255) default NULL AFTER title,
    CHANGE COLUMN Seq_No sequence_number int(11) NOT NULL AFTER feature,
    CHANGE COLUMN Pg_Cnt page_count decimal(10, 4) default NULL
        AFTER sequence_number,
    CHANGE COLUMN `Type` `type` varchar(50) default NULL AFTER page_count,
    CHANGE COLUMN JobNo job_number varchar(25) default NULL AFTER `type`,
    CHANGE COLUMN IssueID issue_id int(11) NOT NULL,
    CHANGE COLUMN Script script mediumtext AFTER issue_id,
    CHANGE COLUMN Pencils pencils mediumtext AFTER script,
    CHANGE COLUMN Inks inks mediumtext AFTER pencils,
    CHANGE COLUMN Colors colors mediumtext AFTER inks,
    CHANGE COLUMN Letters letters mediumtext AFTER colors,
    CHANGE COLUMN Editing editing mediumtext AFTER letters,
    CHANGE COLUMN Genre genre varchar(255) default NULL AFTER editing,
    CHANGE COLUMN Char_App characters mediumtext AFTER genre,
    CHANGE COLUMN Synopsis synopsis mediumtext AFTER characters,
    CHANGE COLUMN Reprints reprint_notes mediumtext AFTER synopsis,
    CHANGE COLUMN Notes notes mediumtext AFTER reprint_notes,
    CHANGE COLUMN Created created datetime NOT NULL
        default '1901-01-01 00:00:00' AFTER reprint_notes,
    CHANGE COLUMN Modified modified datetime NOT NULL
        default '1901-01-01 00:00:00' AFTER created,
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
                      ADD UNIQUE (series_id, sort_code);

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

ALTER TABLE IndexCredit RENAME gcd_series_indexers,
                        DROP COLUMN `Comment`,
    CHANGE COLUMN ID id int(11) NOT NULL auto_increment,
    CHANGE COLUMN IndexerID indexer_id int(11) NOT NULL,
    CHANGE COLUMN SeriesID series_id int(11) NOT NULL,
    CHANGE COLUMN Run run varchar(255) default NULL,
    CHANGE COLUMN Notes notes mediumtext AFTER run,
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

SET foreign_key_checks = 1;

COMMIT;

