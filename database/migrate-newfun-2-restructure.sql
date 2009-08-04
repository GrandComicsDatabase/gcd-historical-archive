SET SESSION sql_mode='STRICT_ALL_TABLES';

-- ----------------------------------------------------------------------------
-- Fix all datetime fields.
-- ----------------------------------------------------------------------------

-- There's one series with a modified date way in the future.
-- Add a day to NOW() because the production server is in Norway
-- and the dev server is in Arkansas.
UPDATE data_series SET modified=created
    WHERE modified > DATE_ADD(NOW(), INTERVAL 1 DAY);
UPDATE data_series
    SET modified=DATE_ADD(modified, INTERVAL modification_time SECOND);
UPDATE data_item
    SET modified=DATE_ADD(modified, INTERVAL modification_time SECOND);
UPDATE data_sequence
    SET modified=DATE_ADD(modified, INTERVAL modification_time SECOND);

-- As always the covers table is a mess.  First fix invalid days/months.
-- There has to be a better way to do this, but I can't find it.
-- Using DATE_ADD with a zero month or day produces NULL.
UPDATE resource_cover
    SET modified=CONCAT(YEAR(modified), '-01-', DAY(modified))
    WHERE MONTH(modified) = 0;
UPDATE resource_cover
    SET modified=CONCAT(YEAR(modified), '-', MONTH(modified), '-01')
    WHERE DAY(modified) = 0;
UPDATE resource_cover
    SET created=CONCAT(YEAR(created), '-01-', DAY(created))
    WHERE MONTH(created) = 0;
UPDATE resource_cover
    SET created=CONCAT(YEAR(created), '-', MONTH(created), '-01')
    WHERE DAY(created) = 0;
-- Next fix dates in the future.
UPDATE resource_cover SET created = '1901-01-01 00:00:00'
    WHERE created > DATE_ADD(NOW(), INTERVAL 1 DAY);
UPDATE resource_cover SET modified=created
    WHERE modified > DATE_ADD(NOW(), INTERVAL 1 DAY);
-- Now do the actual field migration.
UPDATE resource_cover
    SET modified=DATE_ADD(modified, INTERVAL modification_time SECOND);
UPDATE resource_cover
    SET created=DATE_ADD(created, INTERVAL creation_time SECOND);

-- ----------------------------------------------------------------------------
-- Fix issue-wide editor credits and notes.
-- Must be done after initial ALTER TABLEs because old
-- issues.Editing field is smaller.
-- ----------------------------------------------------------------------------

UPDATE data_item INNER JOIN data_sequence
                         ON data_sequence.item_id=data_item.id
    SET data_item.page_count=data_sequence.page_count,
        data_item.editing=data_sequence.editing,
        data_item.notes=data_sequence.notes
    WHERE data_sequence.sort_code = 0;
UPDATE data_sequence SET page_count=1, editing=NULL
    WHERE sort_code = 0;

-- ----------------------------------------------------------------------------
-- Factor out sequence type and set up inferred title flag.
-- ----------------------------------------------------------------------------

CREATE TABLE data_sequence_type (
    id int(11) auto_increment NOT NULL,
    name varchar(50) NOT NULL UNIQUE,
    PRIMARY KEY (id),
    KEY type_name (name)
);

INSERT INTO data_sequence_type (name) SELECT DISTINCT `type` FROM data_sequence;

UPDATE data_sequence_type t INNER JOIN data_sequence q ON t.name=q.`type`
    SET q.type_id=t.id;

UPDATE data_sequence SET title_inferred = 1,
    title=TRIM(LEADING '[' FROM (SELECT TRIM(TRAILING ']' FROM title)))
    WHERE title LIKE '[%]';

CREATE TABLE data_item_sequence (
    id int(11) NOT NULL auto_increment,
    item_id int(11) NOT NULL,
    sequence_id int(11) NOT NULL,
    sort_code int(11) NOT NULL,
    PRIMARY KEY (id),
    KEY key_item (item_id),
    KEY key_sequence (sequence_id)
);

INSERT INTO data_item_sequence (item_id, sequence_id, sort_code)
    SELECT item_id, id, sort_code from data_sequence;

-- ----------------------------------------------------------------------------
-- Proper reprint tables!
-- ----------------------------------------------------------------------------

CREATE TABLE data_reprint (
    id int(11) NOT NULL auto_increment,
    source_id int(11) NOT NULL,
    target_id int(11) NOT NULL,
    notes mediumtext,
    PRIMARY KEY (id),
    KEY reprint_from (`source_id`),
    KEY reprint_to (`target_id`)
);

CREATE TABLE data_reprint_to_item (
    id int(11) NOT NULL auto_increment,
    source_id int(11) NOT NULL,
    target_item_id int(11) NOT NULL,
    notes mediumtext,
    PRIMARY KEY (id),
    KEY reprint_to_item_from (`source_id`),
    KEY reprint_to_item_to (`target_item_id`)
);

CREATE TABLE data_reprint_from_item (
    id int(11) NOT NULL auto_increment,
    source_item_id int(11) NOT NULL,
    target_id int(11) NOT NULL,
    notes mediumtext,
    PRIMARY KEY (id),
    KEY reprint_to_item_from (`source_item_id`),
    KEY reprint_to_item_to (`target_id`)
);

CREATE TABLE data_item_reprint (
    id int(11) NOT NULL auto_increment,
    source_item_id int(11) NOT NULL,
    target_item_id int(11) NOT NULL,
    notes mediumtext,
    PRIMARY KEY (id),
    KEY item_from (`source_item_id`),
    KEY item_to (`target_item_id`)
);

-- Add the first Migration data table, and populate it so we can use
-- a proper OneToOne field in Django.

CREATE TABLE migration_sequence_status (
    id int(11) NOT NULL auto_increment,
    sequence_id int(11) NOT NULL,
    reprint_needs_inspection tinyint(1) default NULL,
    reprint_confirmed tinyint(1) default NULL,
    reprint_original_notes mediumtext,
    PRIMARY KEY (id),
    KEY key_reprint_needs_inspection (`reprint_needs_inspection`),
    KEY key_reprint_confirmed (`reprint_confirmed`),
    KEY key_reprint_notes (`reprint_original_notes`(255))
);

INSERT INTO migration_sequence_status (sequence_id)
    SELECT id FROM data_sequence;

-- ----------------------------------------------------------------------------
-- Better publisher/brand/etc. organization.
-- ----------------------------------------------------------------------------

-- Issue-level publishers and publisher emblems.

CREATE TABLE data_address (
    id int(11) auto_increment NOT NULL,
    address mediumtext,
    country_id int(11) NOT NULL,
    PRIMARY KEY (id),
    KEY key_address (address(255)),
    KEY key_country (country_id)
);

-- At the moment, we only have one type of series level publisher,
-- and nothing that remotely resembles a consensus on how additional
-- series-level publishers should be treated.  So no type field for now,
-- and no multiple link tables (which is what we do for items) either.
-- Note that imprints stay on the series table directly as they are legacy
-- and will be dropped so no point adding a type or table for them.

CREATE TABLE data_series_publisher (
    id int(11) auto_increment NOT NULL,
    series_id int(11) NOT NULL,
    publisher_id int(11) NOT NULL,
    uncertain tinyint(1) NOT NULL default 0,
    inferred tinyint(1) NOT NULL default 0,
    notes mediumtext,
    PRIMARY KEY (id),
    KEY key_series_id (series_id),
    KEY key_publisher_id (publisher_id)
);

-- This table is for publishing companies.

CREATE TABLE data_item_publisher (
    id int(11) auto_increment NOT NULL,
    item_id int(11) NOT NULL,
    publisher_id int(11) NOT NULL,
    uncertain tinyint(1) NOT NULL default 0,
    inferred tinyint(1) NOT NULL default 0,
    notes mediumtext,
    PRIMARY KEY (id),
    KEY key_item_id (item_id),
    KEY key_publisher_id (publisher_id)
);

CREATE TABLE data_item_brand (
    id int(11) auto_increment NOT NULL,
    item_id int(11) NOT NULL,
    brand_id int(11) NOT NULL,
    emblem_id int(11) default NULL,
    notes mediumtext,
    PRIMARY KEY (id),
    KEY key_item_id (item_id),
    KEY key_brand_id (brand_id),
    KEY key_emblem_id (emblem_id)
);

CREATE TABLE data_item_distributor (
    id int(11) auto_increment NOT NULL,
    item_id int(11) NOT NULL,
    distributor_id int(11) NOT NULL,
    emblem_id int(11) default NULL,
    code varchar(50) default NULL,
    source_id int(11) NOT NULL,
    notes mediumtext,
    PRIMARY KEY (id),
    KEY key_item (item_id),
    KEY key_dist (distributor_id),
    KEY key_emblem (emblem_id),
    KEY key_code (code)
);

-- Associates publishers (primarily but not necessarily only brands) with
-- images/logos/emblems of some sort.

CREATE TABLE data_publisher_emblem (
    id int(11) auto_increment NOT NULL,
    publisher_id int(11) NOT NULL,
    emblem_id int(11) NOT NULL,
    PRIMARY KEY (id),
    KEY key_publisher_id (publisher_id),
    KEY key_emblem_id (emblem_id)
);

CREATE TABLE data_address_purpose (
    id int(11) auto_increment NOT NULL,
    name varchar(100) NOT NULL,
    description mediumtext,
    PRIMARY KEY (id),
    KEY key_name (name)
);

CREATE TABLE data_publisher_address (
    id int(11) auto_increment NOT NULL,
    publisher_id int(11) NOT NULL,
    address_id int(11) NOT NULL,
    notes mediumtext,
    PRIMARY KEY (id),
    KEY key_publisher_id (publisher_id),
    KEY key_address_id (address_id)
);

CREATE TABLE data_item_publisher_address (
    id int(11) auto_increment NOT NULL,
    item_publisher_id int(11) NOT NULL,
    publisher_address_id int(11) NOT NULL,
    purpose_id int(11) NOT NULL,
    PRIMARY KEY (id),
    KEY key_item (item_publisher_id),
    KEY key_address (publisher_address_id)
);

CREATE TABLE data_publisher_relationship_type (
    id int(11) auto_increment NOT NULL,
    name varchar(100) NOT NULL,
    description mediumtext,
    PRIMARY KEY (id),
    KEY key_name (name)
);

CREATE TABLE data_publisher_relationship (
    id int(11) auto_increment NOT NULL,
    relating_id int(11) NOT NULL,
    related_id int(11) NOT NULL,
    link_type_id int(11) NOT NULL,
    notes mediumtext,
    PRIMARY KEY (id),
    KEY key_relating (relating_id),
    KEY key_related (related_id)
);

INSERT INTO data_publisher_relationship_type (name, description) VALUES
    ('legacy parent',
     'Parent relationship between old-schema Master Publishers and Imprints');

-- This relies on only one row existing in the type table.
INSERT INTO data_publisher_relationship (relating_id, related_id, link_type_id)
    SELECT p.parent_id, p.id, t.id
        FROM data_publisher p CROSS JOIN data_publisher_relationship_type t
        WHERE p.parent_id IS NOT NULL;

ALTER TABLE data_publisher
    ADD INDEX country (country_id),
    ADD INDEX is_company (is_company),
    ADD INDEX is_brand (is_brand);

-- ----------------------------------------------------------------------------
-- Series to series linking
-- ----------------------------------------------------------------------------

CREATE TABLE data_series_relationship_type (
    id int(11) auto_increment NOT NULL,
    name varchar(100) NOT NULL,
    description mediumtext,
    PRIMARY KEY (id),
    KEY key_name (name)
);

INSERT INTO data_series_relationship_type (name)
    VALUES ('numbering');

CREATE TABLE data_series_relationship (
    id int(11) auto_increment NOT NULL,
    source_id int(11) NOT NULL,
    target_id int(11) NOT NULL,
    source_item_id int(11) default NULL,
    target_item_id int(11) default NULL,
    link_type_id int(11) NOT NULL,
    notes mediumtext,
    PRIMARY KEY (id),
    KEY key_source (source_id),
    KEY key_target (target_id),
    KEY key_item_source (source_item_id),
    KEY key_item_target (target_item_id)
);

-- ----------------------------------------------------------------------------
-- Issue to series join table, plus descriptors.
-- ----------------------------------------------------------------------------

CREATE TABLE data_series_item (
    id int(11) auto_increment NOT NULL,
    item_id int(11) NOT NULL,
    series_id int(11) NOT NULL,
    sort_code int(11) NOT NULL,
    PRIMARY KEY (id),
    KEY key_sort_code(sort_code),
    KEY key_item_id(item_id),
    KEY key_series_id(series_id)
);

-- Descriptors are so generic that we need a flexible set of names for them.
-- The group flags may not be needed given that they are so
-- classification-dependent.

CREATE TABLE data_descriptor_label (
    id int(11) auto_increment NOT NULL,
    name varchar(255) NOT NULL,
    for_item tinyint(1) NOT NULL default 1,
    for_group tinyint(1) NOT NULL default 0,
    PRIMARY KEY (id),
    KEY key_name (name),
    KEY key_item (for_item),
    KEY key_group (for_group)
);

INSERT INTO data_descriptor_label (name, for_item, for_group) VALUES
    ('issue', 1, 0),
    ('volume', 1, 1),
    ('book', 1, 0),
    ('sbn', 1, 0),
    ('isbn', 1, 0),
    ('issn', 0, 1),
    ('prog', 1, 0),
    ('title', 1, 1),
    ('anno', 0, 1);
    -- Need a bunch more values here, no doubt.

-- Only use the standard ones for now, and confirm the rest later.
-- Even with 2000AD series (by name), only some actualy use 'prog'.
SET @label_issue=(SELECT id FROM data_descriptor_label WHERE name='issue');
SET @label_volume=(SELECT id FROM data_descriptor_label WHERE name='volume');

-- Both descriptors and series names can be drawn from many sources, both
-- on or outside of a given item.  This table sets up the allowed sources,
-- using the inferred flag to indicate variations on "made up".

CREATE TABLE data_source (
    id int(11) auto_increment NOT NULL,
    name varchar(255) NOT NULL,
    is_inferred tinyint(1) NOT NULL default 0,
    PRIMARY KEY (id),
    KEY key_name (name)
);

INSERT INTO data_source (name, is_inferred) VALUES
    ('indicia', 0),
    ('cover', 0),
    ('gcd assigned', 1),
    ('external', 1);
    -- Not a complete list, but will do until we have a policy for how
    -- fine-grained we really want this.  Only indicia and possibly
    -- gcd assigned are needed for migration.

SET @source_indicia=(SELECT id FROM data_source WHERE name = 'indicia');

-- Allow for multiple series names.
-- Only one per series should be "primary", although it may be
-- from any source.  That name will be most prominently displayed by the UI.

CREATE TABLE data_series_name (
    id int(11) auto_increment NOT NULL,
    series_id int(11) NOT NULL,
    value varchar(255) NOT NULL,
    source_id int(11) NOT NULL,
    is_primary tinyint(1) NOT NULL default 1,
    PRIMARY KEY (id),
    KEY key_value (value),
    KEY key_source (source_id),
    KEY key_primary (is_primary)
);

INSERT INTO data_series_name (series_id, value, source_id, is_primary)
    SELECT id, name, @source_indicia, 1 FROM data_series;

-- Allow specifiation of which series name(s) appear on a given item.
-- The application should only allow joins where the series_id on the
-- related series_item matches the one on the related series_name.
-- Nothing to put in this table yet.

CREATE TABLE data_series_item_name (
    id int(11) auto_increment NOT NULL,
    series_item_id int(11) NOT NULL,
    series_name_id int(11) NOT NULL,
    source_id int(11) NOT NULL,
    PRIMARY KEY (id),
    KEY key_item (series_item_id),
    KEY key_name (series_name_id),
    KEY key_source (source_id)
);

-- Allow multiple issue/volume/book numbers/titles/whatever.
-- The application will narrow down possibilities to make the interface
-- more clear based on scope, label and the series classification.

CREATE TABLE data_item_descriptor (
    id int(11) auto_increment NOT NULL,
    series_item_id int(11) NOT NULL,
    scope enum('item', 'group') NOT NULL default 'item',
    label_id int(11) NOT NULL,
    source_id int(11) NOT NULL,
    value varchar(255) default NULL,
    PRIMARY KEY (id),
    KEY key_series_item (series_item_id),
    KEY key_scope (scope),
    KEY key_label (label_id),
    KEY key_source (source_id),
    KEY key_value (value)
);

-- It would be great to handle the v1#1 style numbers here, but it's just
-- a big pain, and better done in python code.

-- Do handle the easiest "no number" cases.  This will result
-- in a NULL issue-labeled descriptor, which the UI can reinterpret
-- into [nn] or whatever is appropriate.
UPDATE data_item SET descriptor=NULL WHERE descriptor IN ('nn', '[nn]');

INSERT INTO data_item_descriptor
    (series_item_id, scope, label_id, source_id, value)
    SELECT id, 'item', @label_issue, @source_indicia, descriptor FROM data_item
    UNION   
    SELECT id, 'group', @label_volume, @source_indicia, volume FROM data_item;

-- Most of the confirm flags will be cleared by python scripts, leaving the
-- rest for human processing.
CREATE TABLE migration_series_item_status (
    id int(11) auto_increment NOT NULL,
    series_item_id int(11) NOT NULL,
    issue_descriptor_confirmed tinyint(1) NOT NULL,
    volume_descriptor_confirmed tinyint(1) NOT NULL,
    PRIMARY KEY (id),
    KEY key_series_item (series_item_id),
    KEY key_issue_descriptor (issue_descriptor_confirmed),
    KEY key_volume_descriptor (volume_descriptor_confirmed)
);

INSERT INTO migration_series_item_status
    (series_item_id, issue_descriptor_confirmed, volume_descriptor_confirmed)
    SELECT id, 0, 0 FROM data_series_item;

-- ----------------------------------------------------------------------------
-- Set up the image table, and fix the cover table.
-- ----------------------------------------------------------------------------

-- Image table with cover table adjustments.
-- This includes a temp_cover_id and temp_cover_type to make data population
-- and linking easier.  They both get dropped by the end of this script.

CREATE TABLE resource_file (
    id int(11) auto_increment NOT NULL,
    server varchar(100) NOT NULL,
    path varchar(512) NOT NULL,
    temp_cover_id int(11),
    temp_cover_type int(2),
    PRIMARY KEY (id),
    KEY cover_id(temp_cover_id),
    KEY cover_type(temp_cover_type)
);

-- Deal with missing cover entries.  Descriptor is copied only because it is
-- NOT NULL with no default and still around because we needed it for other
-- migration code.  It's dropped further down.
INSERT INTO resource_cover
    (item_id, series_id, item_descriptor, location_code,
     has_image, created, modified)
    SELECT i.id, i.series_id, i.descriptor, '000', 0, NOW(), NOW()
        FROM data_item i LEFT OUTER JOIN resource_cover c ON i.id=c.item_id
        WHERE c.id IS NULL;

-- Fix missing default setting of sequence_id from previous script.
-- Only do this for covers matching issues that have a sequence 0 already.
UPDATE resource_cover c INNER JOIN data_item i ON c.item_id=i.id
                        INNER JOIN data_item_sequence q ON i.id=q.item_id AND
                                                           q.sort_code=0
    SET c.sequence_id=q.id;

SET @doubled_covers_issue=
    (SELECT id FROM data_item WHERE descriptor='*GCD DOUBLED COVERS ISSUE');
SET @null_issue=
    (SELECT id FROM data_item WHERE descriptor='*GCD NULL ISSUE');
SET @orphan_covers_issue=
    (SELECT id FROM data_item WHERE descriptor='*GCD ORPHAN COVERS ISSUE');
SET @vanished_issue_covers_issue=
    (SELECT id FROM data_item WHERE descriptor='*GCD VANISHED ISS. COVERS');
SET @vanished_issues_issue=
    (SELECT id FROM data_item WHERE descriptor='*GCD VANISHED ISSUES');

CREATE TEMPORARY TABLE sort_helper (
    id int(11) NOT NULL auto_increment,
    cover_id int(11),
    item_id int(11),
    PRIMARY KEY (id) 
);

INSERT INTO sort_helper (cover_id, item_id)
    SELECT c.id, i.id FROM resource_cover c LEFT OUTER JOIN data_item i
                                  ON c.item_id = i.id
                ORDER BY c.series_id, c.location_code, i.key_date;

UPDATE data_series_item i INNER JOIN sort_helper h ON i.item_id = h.item_id
    SET i.sort_code=h.id
        WHERE i.id NOT IN (@doubled_covers_issue);

-- Convert location columns into image table entries.

INSERT INTO resource_file (server, path, temp_cover_id, temp_cover_type)
    SELECT IF(server_version = 1, 'www.comics.org', 'www.gcdcovers.com'),
           CONCAT('/graphics/covers/',
                  CAST(series_id AS CHAR),
                  '/',
                  CAST(series_id AS CHAR),
                  '_',
                  location_code,
                  '.jpg'),
            id,
            1
        FROM resource_cover WHERE has_small = 1
    UNION
    SELECT IF(server_version = 1, 'www.comics.org', 'www.gcdcovers.com'),
           CONCAT('/graphics/covers/',
                  CAST(series_id AS CHAR),
                  '/200/',
                  CAST(series_id AS CHAR),
                  '_2_',
                  location_code,
                  '.jpg'),
            id,
            2
        FROM resource_cover WHERE has_medium = 1
    UNION
    SELECT IF(server_version = 1, 'www.comics.org', 'www.gcdcovers.com'),
           CONCAT('/graphics/covers/',
                  CAST(series_id AS CHAR),
                  '/400/',
                  CAST(series_id AS CHAR),
                  '_4_',
                  location_code,
                  '.jpg'),
            id,
            4
        FROM resource_cover WHERE has_large = 1;

-- Link the entries back to the cover table, then drop the helper columns.

UPDATE resource_cover c INNER JOIN resource_file f ON c.id = f.temp_cover_id
    SET c.small_image_id=f.id WHERE c.has_small = 1 AND f.temp_cover_type = 1;

UPDATE resource_cover c INNER JOIN resource_file f ON c.id = f.temp_cover_id
    SET c.medium_image_id=f.id WHERE c.has_medium = 1 AND f.temp_cover_type = 2;

UPDATE resource_cover c INNER JOIN resource_file f ON c.id = f.temp_cover_id
    SET c.large_image_id=f.id WHERE c.has_large = 1 AND f.temp_cover_type = 4;

-- ----------------------------------------------------------------------------
-- Set up the Price tables.  Migration for this is best done in Python.
-- Must handle both decimal and non-decimal currency.
-- ----------------------------------------------------------------------------

CREATE TABLE data_currency (
    id int(11) NOT NULL auto_increment,
    code char(3) NOT NULL,
    name varchar(255) NOT NULL,
    PRIMARY KEY (id),
    KEY key_code (code)
);

CREATE TABLE data_price_type (
    id int(11) NOT NULL auto_increment,
    name varchar(100) NOT NULL,
    description mediumtext,
    PRIMARY KEY (id),
    KEY key_name (name)
);

INSERT INTO data_price_type (name)
    VALUES ('standard'), ('newsstand'), ('subscription');

CREATE TABLE data_item_price (
    id int(11) NOT NULL auto_increment,
    value decimal(10,3) default NULL,
    non_decimal_value varchar(25) default NULL,
    currency_id int(11) NOT NULL,
    country_id int(11) default NULL,
    notes mediumtext,
    PRIMARY KEY (id),
    KEY value (value),
    KEY non_decimal (non_decimal_value),
    KEY currency (currency_id),
    KEY country (country_id)
);

-- ----------------------------------------------------------------------------
-- Set up issue migration tracking so we can drop some weird fields that
-- probably aren't needed and shouldn't be on the core issue table anyway.
-- ----------------------------------------------------------------------------

CREATE TABLE migration_item_status (
    id int(11) NOT NULL auto_increment,
    item_id int(11) NOT NULL,
    index_status int(11),
    reservation_status int(11),
    key_date varchar(10),
    PRIMARY KEY (id),
    KEY index_status (index_status),
    KEY reservation_status (reservation_status),
    KEY key_date (key_date)
);

INSERT INTO migration_item_status
    (item_id, index_status, reservation_status, key_date)
    SELECT id, index_status, reservation_status, key_date FROM data_item;

-- ----------------------------------------------------------------------------
-- Series migration tracking and other series-level fixes.
-- ----------------------------------------------------------------------------

-- Track whether we've figured out if a series' name is its true indicia
-- name or one of our exceptions or attempts to deal with ambiguity.

CREATE TABLE migration_series_status (
    id int(11) NOT NULL auto_increment,
    series_id int(11) NOT NULL,
    name_source_confirmed tinyint(1) NOT NULL default 0,
    open_reserve int(11) default NULL,
    PRIMARY KEY (id),
    KEY key_series (series_id),
    KEY key_name_source (name_source_confirmed)
);

INSERT INTO migration_series_status (series_id, open_reserve)
    SELECT id, open_reserve FROM data_series;

-- Use a real language code.
UPDATE data_series s INNER JOIN data_language l ON s.language_code = l.code
    SET s.language_id = l.id;

-- Do publishers correctly.  Leave imprints alone as we'll just drop them ASAP
-- anyway and it makes things more complicated to account for them any better.
INSERT INTO data_series_publisher (publisher_id, series_id, notes)
    SELECT publisher_id, id, publication_notes FROM data_series;

-- ----------------------------------------------------------------------------
-- Add the classification table for series.
-- ----------------------------------------------------------------------------

CREATE TABLE data_classification (
    id int(11) auto_increment NOT NULL,
    name varchar(255) NOT NULL,
    description mediumtext,
    PRIMARY KEY (id),
    KEY key_name (name)
);

-- Just a few ideas to start with, will most likely change.
INSERT INTO data_classification (name) VALUES
    ('unclassified'),
    ('periodical/pamphlet series'),
    ('pamphlet one-shot'),
    ('series of books'),
    ('single book');

-- ----------------------------------------------------------------------------
-- Final alter statements to drop columns that are no longer needed.
-- ----------------------------------------------------------------------------

ALTER TABLE data_publisher
    DROP COLUMN parent_id;

ALTER TABLE data_series
    DROP COLUMN language_code,
    DROP COLUMN publication_notes,
    DROP COLUMN publisher_id,
    DROP COLUMN open_reserve,
    DROP COLUMN modification_time;

ALTER TABLE data_item
    DROP COLUMN series_id,
    DROP COLUMN descriptor,
    DROP COLUMN volume,
    DROP COLUMN key_date,
    DROP COLUMN index_status,
    DROP COLUMN reservation_status,
    DROP COLUMN modification_time;

ALTER TABLE data_sequence
    DROP COLUMN item_id,
    DROP COLUMN sort_code,
    DROP COLUMN `type`,
    DROP COLUMN modification_time;

ALTER TABLE resource_file
    DROP COLUMN temp_cover_id,
    DROP COLUMN temp_cover_type;

ALTER TABLE resource_cover
    DROP COLUMN has_small,
    DROP COLUMN has_medium,
    DROP COLUMN has_large,
    DROP COLUMN server_version,
    DROP COLUMN location_code,
    DROP COLUMN item_descriptor,
    DROP COLUMN creation_time,
    DROP COLUMN modification_time;

