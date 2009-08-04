SET SESSION sql_mode='STRICT_ALL_TABLES';

-- BEGIN Table restructuring statements
-- And yes, reording columns in mysql is somewhat pointless, but this just
-- makes things show up much nicer in test queries of the SELECT(*) form and
-- lines up a bit better with how the code is organized (although that won't be
-- kept in strict correspondence).  Plus we have to rename nearly all of the
-- columns anyway.

ALTER TABLE Countries RENAME data_country,
    CHANGE COLUMN ID id int(11) NOT NULL auto_increment FIRST,
    CHANGE COLUMN code code varchar(10) NOT NULL UNIQUE,
    CHANGE COLUMN country name varchar(255) NOT NULL,
    CONVERT TO CHARACTER SET utf8;

ALTER TABLE Languages RENAME data_language,
    CHANGE COLUMN ID id int(11) NOT NULL auto_increment FIRST,
    CHANGE COLUMN code code varchar(10) NOT NULL UNIQUE,
    CHANGE COLUMN language name varchar(255) NOT NULL,
    CONVERT TO CHARACTER SET utf8;

ALTER TABLE publishers RENAME data_publisher,
                       DROP COLUMN Connection,
                       DROP COLUMN NextID,
                       DROP COLUMN Updated,
                       DROP COLUMN AlphaSortCode,
                       DROP COLUMN ImprintCount,
    CHANGE COLUMN ID id int(11) NOT NULL auto_increment FIRST,
    CHANGE COLUMN PubName name varchar(255) NOT NULL AFTER id,
    CHANGE COLUMN CountryID country_id int(11) default NULL AFTER name,
    CHANGE COLUMN YearBegan year_began int(11) default NULL AFTER country_id,
    CHANGE COLUMN YearEnded year_ended int(11) default NULL
        AFTER year_began,
    CHANGE COLUMN Notes notes mediumtext AFTER year_ended,
    CHANGE COLUMN web url varchar(255) default NULL AFTER notes,
    CHANGE COLUMN Master is_master tinyint(1) NOT NULL AFTER url,
    ADD COLUMN is_company tinyint(1) NOT NULL AFTER is_master,
    ADD COLUMN is_brand tinyint(1) NOT NULL AFTER is_company,
    ADD COLUMN is_distributor tinyint(1) NOT NULL AFTER is_brand,
    CHANGE COLUMN BookCount series_count int(11) NOT NULL default 0
        AFTER is_distributor,
    CHANGE COLUMN IssueCount item_count int(11) NOT NULL default 0
        AFTER series_count,
    CHANGE COLUMN Created created datetime NOT NULL
        default '1901-01-01 00:00:00' AFTER item_count,
    CHANGE COLUMN Modified modified datetime NOT NULL
        default '1901-01-01 00:00:00' AFTER created,
    -- This last column  will be dropped after further migration.
    CHANGE COLUMN ParentID parent_id int(11) default NULL AFTER modified,
    CONVERT TO CHARACTER SET utf8;

ALTER TABLE series RENAME data_series,
                   DROP COLUMN Crossref,
                   DROP COLUMN CrossrefID,
                   DROP COLUMN `File`,
                   DROP COLUMN InitDist,
                   DROP COLUMN Included,
                   DROP COLUMN Indexers,
                   DROP COLUMN LstChang,
                   DROP COLUMN oldID,
                   DROP COLUMN SelfCount,
                   DROP COLUMN Themes,
                   DROP COLUMN UpdateDist,
                   DROP COLUMN CounCode,
                   DROP COLUMN Frst_Iss,
                   DROP COLUMN Last_Iss,
                   DROP COLUMN PubDates,
                   DROP COLUMN Pub_Name,
    CHANGE COLUMN ID id int(11) NOT NULL auto_increment FIRST,
    CHANGE COLUMN Bk_Name name varchar(255) NOT NULL AFTER id,
    CHANGE COLUMN Format format varchar(255) default NULL AFTER name,
    CHANGE COLUMN Yr_Began year_began int(11) NOT NULL AFTER format,
    CHANGE COLUMN Yr_Ended year_ended int(11) default NULL AFTER year_began,
    ADD COLUMN classification_id int(11) NOT NULL default 1 AFTER year_ended,
    CHANGE COLUMN LangCode language_code varchar(3) default NULL
        AFTER classification_id,
    ADD COLUMN language_id int(11) default NULL
        AFTER language_code,
    CHANGE COLUMN Tracking tracking_notes mediumtext
        AFTER language_id,
    CHANGE COLUMN Notes notes mediumtext AFTER tracking_notes,
    CHANGE COLUMN HasGallery has_gallery tinyint(1) NOT NULL default 0
        AFTER notes,
    CHANGE COLUMN OpenReserve open_reserve int(11) default NULL
        AFTER has_gallery,
    CHANGE COLUMN Issuecount item_count int(11) NOT NULL default 0
        AFTER open_reserve,
    CHANGE COLUMN Created created datetime NOT NULL
        default '1901-01-01 00:00:00' AFTER item_count,
    CHANGE COLUMN Modified modified datetime NOT NULL
        default '1901-01-01 00:00:00' AFTER created,
    -- These last few columns will be dropped after some migration.
    CHANGE COLUMN ModTime modification_time time NOT NULL AFTER modified,
    CHANGE COLUMN PubID publisher_id int(11) NOT NULL
        AFTER modification_time,
    MODIFY COLUMN imprint_id int(11) default NULL
        AFTER publisher_id,
    CHANGE COLUMN Pub_Note publication_notes mediumtext
        AFTER imprint_id,
    CONVERT TO CHARACTER SET utf8,
    ADD INDEX classification (classification_id),
    ADD INDEX series_language (language_id);

ALTER TABLE issues RENAME data_item,
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
                   DROP COLUMN Bk_Name,
                   DROP COLUMN Yr_Began,
                   DROP COLUMN Pub_Name,
    CHANGE COLUMN ID id int(11) NOT NULL auto_increment FIRST,
    CHANGE COLUMN SeriesID series_id int(11) NOT NULL AFTER id,
    CHANGE COLUMN Pub_Date publication_date varchar(255) default NULL
        AFTER series_id,
    ADD COLUMN publication_year int(11) default NULL AFTER publication_date,
    ADD COLUMN publication_year_inferred tinyint(1) NOT NULL default 0
        AFTER publication_year,
    ADD COLUMN publication_second_year int(11) default NULL
        AFTER publication_year_inferred,
    ADD COLUMN publication_second_year_inferred tinyint(1) NOT NULL default 0
        AFTER publication_second_year,
    ADD COLUMN publication_month_id int(11) default NULL
        AFTER publication_second_year_inferred,
    ADD COLUMN publication_month_inferred tinyint(1) NOT NULL default 0
        AFTER publication_month_id,
    ADD COLUMN publication_month_modifier enum('early', 'mid', 'late')
        default NULL AFTER publication_month_id,
    ADD COLUMN publication_month_modifier_inferred tinyint(1) NOT NULL
        default 0 AFTER publication_month_modifier,
    ADD COLUMN publication_day int(11) default NULL
        AFTER publication_month_inferred,
    ADD COLUMN publication_day_inferred tinyint(1) NOT NULL default 0
        AFTER publication_day,
    ADD COLUMN indicia_frequency varchar(255) default NULL
        AFTER publication_day_inferred,
    ADD COLUMN size_id int(11) default NULL AFTER indicia_frequency,
    ADD COLUMN height decimal(10, 3) default NULL AFTER size_id,
    ADD COLUMN width decimal(10, 3) default NULL AFTER height,
    ADD COLUMN size_in_metric tinyint(1) default 1 AFTER width,
    ADD COLUMN interior_paper_id int(11) default NULL AFTER size_in_metric,
    ADD COLUMN cover_paper_id int(11) default NULL AFTER interior_paper_id,
    ADD COLUMN binding_id int(11) default NULL AFTER cover_paper_id,
    CHANGE COLUMN Price price varchar(255) default NULL
        AFTER binding_id,
    CHANGE COLUMN Pg_Cnt page_count varchar(10) default NULL AFTER price,
    CHANGE COLUMN Editing editing mediumtext AFTER page_count,
    CHANGE COLUMN Notes notes mediumtext
        AFTER editing,
    CHANGE COLUMN storycount sequence_count int(11) NOT NULL default 0
        AFTER notes,
    CHANGE COLUMN created created datetime NOT NULL
        default '1901-01-01 00:00:00' AFTER sequence_count,
    CHANGE COLUMN Modified modified datetime NOT NULL
        default '1901-01-01 00:00:00' AFTER created,
    -- These last columns will be dropped after some migration.
    -- Descriptor needs to be NULLable for migration of [nn]/nn values.
    CHANGE COLUMN ModTime modification_time time NOT NULL AFTER modified,
    CHANGE COLUMN Issue descriptor varchar(50) default NULL
        AFTER modification_time,
    CHANGE COLUMN VolumeNum volume int(11) default NULL
        AFTER descriptor,
    CHANGE COLUMN Key_Date key_date varchar(10) default NULL
        AFTER volume,
    CHANGE COLUMN IndexStatus index_status int(11) NOT NULL default 0
        AFTER key_date,
    CHANGE COLUMN ReserveStatus reservation_status int(11) NOT NULL default 0
        AFTER index_status,
    CONVERT TO CHARACTER SET utf8,
    ADD INDEX item_pub_year (publication_year),
    ADD INDEX item_pub_month_id (publication_month_id),
    ADD INDEX item_pub_month_mod (publication_month_modifier),
    ADD INDEX item_pub_day (publication_day),
    ADD INDEX item_indicia_freq (indicia_frequency),
    ADD INDEX item_size (size_id);

ALTER TABLE stories RENAME data_sequence,
                    DROP COLUMN rel_year,
                    DROP COLUMN LstChang,
                    DROP COLUMN InitDist,
                    DROP COLUMN IssueCount,
                    DROP COLUMN Key_Date,
                    DROP COLUMN Pub_Date,
                    DROP COLUMN Price,
                    DROP COLUMN SeriesID,
                    DROP COLUMN Issue,
                    DROP COLUMN Yr_Began,
                    DROP COLUMN Bk_Name,
                    DROP COLUMN Pub_Name,
    CHANGE COLUMN ID id int(11) NOT NULL auto_increment FIRST,
    CHANGE COLUMN Title title varchar(255) default NULL AFTER id,
    ADD COLUMN title_inferred tinyint(1) NOT NULL default 0 AFTER title,
    CHANGE COLUMN Feature feature varchar(255) default NULL
        AFTER title_inferred,
    CHANGE COLUMN Seq_No sort_code int(11) NOT NULL AFTER feature,
    CHANGE COLUMN Pg_Cnt page_count varchar(10) default NULL AFTER sort_code,
    CHANGE COLUMN `Type` `type` varchar(50) default NULL AFTER page_count,
    ADD COLUMN type_id int(11) default NULL AFTER `type`,
    ADD COLUMN color_type_id int(11) default NULL AFTER type_id,
    CHANGE COLUMN JobNo job_number varchar(25) default NULL AFTER color_type_id,
    CHANGE COLUMN Script script mediumtext AFTER job_number,
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
    -- item_id will be dropped after migrating to a many-to-many design.
    CHANGE COLUMN ModTime modification_time time NOT NULL AFTER modified,
    CHANGE COLUMN IssueID item_id int(11) NOT NULL AFTER modified,
    CONVERT TO CHARACTER SET utf8,
    ADD INDEX sequence_type (type_id),
    ADD INDEX key_title_inferred (title_inferred),
    ADD INDEX sequence_genre (genre);

ALTER TABLE covers RENAME resource_cover,
                   DROP COLUMN variant_code,
                   DROP COLUMN variant_text,
                   DROP COLUMN is_master,
                   DROP COLUMN Count,
                   DROP COLUMN Coverage,
                   DROP COLUMN CoversThisTitle,
                   DROP COLUMN Pub_Name,
                   DROP COLUMN Bk_Name,
                   DROP COLUMN Yr_Began,
    CHANGE COLUMN ID id int(11) NOT NULL auto_increment FIRST,
    CHANGE COLUMN IssueID item_id int(11) NOT NULL AFTER id,
    ADD COLUMN sequence_id int(11) default NULL AFTER item_id,
    CHANGE COLUMN HasImage has_image tinyint(1) NOT NULL default 0
        AFTER sequence_id,
    CHANGE COLUMN Marked marked tinyint(1) NOT NULL default 0 AFTER has_image,
    ADD COLUMN small_image_id int(11) default NULL AFTER marked,
    ADD COLUMN medium_image_id int(11) default NULL AFTER small_image_id,
    ADD COLUMN large_image_id int(11) default NULL AFTER medium_image_id,
    CHANGE COLUMN contributor contributor varchar(255) default NULL
        AFTER large_image_id,
    CHANGE COLUMN Created created datetime NOT NULL
        default '1901-01-01 00:00:00' AFTER contributor,
    CHANGE COLUMN Modified modified datetime NOT NULL
        default '1901-01-01 00:00:00' AFTER created,
    -- Columns to be dropped after further migration.
    -- Item descriptor needs to be NULLable for migration of [nn]/nn values.
    CHANGE COLUMN CreTime creation_time time NOT NULL default 0 AFTER modified,
    CHANGE COLUMN ModTime modification_time time NOT NULL default 0
        AFTER creation_time,
    CHANGE COLUMN Issue item_descriptor varchar(50) default NULL
        AFTER modification_time,
    CHANGE COLUMN SeriesID series_id int(11) NOT NULL AFTER item_descriptor,
    CHANGE COLUMN covercode location_code varchar(50) NOT NULL AFTER series_id,
    CHANGE COLUMN c1 has_small tinyint(1) NOT NULL default 0
        AFTER location_code,
    CHANGE COLUMN c2 has_medium tinyint(1) NOT NULL default 0 AFTER has_small,
    CHANGE COLUMN c4 has_large tinyint(1) NOT NULL default 0 AFTER has_medium,
    CHANGE COLUMN gfxserver server_version int(11) NOT NULL default 1
        AFTER has_large,
    CONVERT TO CHARACTER SET utf8;

-- ----------------------------------------------------------------------------
-- OI and Account Management tables.
-- ----------------------------------------------------------------------------

ALTER TABLE Indexers RENAME accounts_indexer,
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
    ADD COLUMN name_order tinyint(1) default 0 AFTER family_name,
    CHANGE COLUMN userlevel user_level int(11) NOT NULL default 0
        AFTER name_order,
    CHANGE COLUMN Active active tinyint(1) NOT NULL default 1
        AFTER user_level,
    CHANGE COLUMN Message message mediumtext AFTER active,
    CHANGE COLUMN DateCreated created datetime NOT NULL
        default '1901-01-01 00:00:00' AFTER message,
    CHANGE COLUMN DateMod modified datetime NOT NULL
        default '1901-01-01 00:00:00' AFTER created,
    CONVERT TO CHARACTER SET utf8;

ALTER TABLE Reservations RENAME oi_reservation,
    CHANGE COLUMN ID id int(11) NOT NULL auto_increment,
    CHANGE COLUMN IndexerID indexer_id int(11) NOT NULL,
    CHANGE COLUMN IssueID item_id int(11) NOT NULL,
    CHANGE COLUMN Status status int(11) NOT NULL,
    CHANGE COLUMN IndexType index_type int(11) NOT NULL AFTER status,
    CHANGE COLUMN Expires expires date default NULL AFTER index_type,
    CHANGE COLUMN Created created datetime default '1901-01-01 00:00:00'
        AFTER expires,
    CONVERT TO CHARACTER SET utf8;

ALTER TABLE IndexCredit RENAME oi_series_credit,
                        DROP COLUMN `Comment`,
    CHANGE COLUMN ID id int(11) NOT NULL auto_increment,
    CHANGE COLUMN IndexerID indexer_id int(11) NOT NULL,
    CHANGE COLUMN SeriesID series_id int(11) NOT NULL,
    CHANGE COLUMN Run run varchar(255) default NULL,
    CHANGE COLUMN Notes notes mediumtext AFTER run,
    ADD COLUMN created datetime NOT NULL
        default '1901-01-01 00:00:00' AFTER notes,
    CHANGE COLUMN DateMod modified datetime NOT NULL
        default '1901-01-01 00:00:00' AFTER created,
    CONVERT TO CHARACTER SET utf8;

