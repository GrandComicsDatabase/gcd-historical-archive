-- Index the "is_current" flag as it is searched from the publisher page.

ALTER TABLE gcd_series ADD INDEX (is_current);

-- Get rid of some legacy columns that we have no plans to use.  This also
-- gets rid of their indexes, which are expensive.
-- Add various expected flag columns and the barcode field, and index them.
ALTER TABLE gcd_issue
    DROP COLUMN index_status,
    DROP COLUMN reserve_status,
    DROP COLUMN reserve_check,
    ADD COLUMN no_indicia_frequency tinyint(1) NOT NULL default 0
        AFTER indicia_frequency,
    ADD COLUMN no_isbn tinyint(1) NOT NULL default 0 AFTER valid_isbn,
    ADD COLUMN barcode varchar(38) NOT NULL default '',
    ADD COLUMN no_barcode tinyint(1) NOT NULL default 0,
    ADD COLUMN on_sale_date date default NULL,
    ADD KEY (no_indicia_frequency),
    ADD KEY (no_isbn),
    ADD KEY (barcode),
    ADD KEY (no_barcode),
    ADD KEY (on_sale_date);

-- Add the fields to the revision table.  Do not index them because we
-- do not search the revision tables on these fields.
ALTER TABLE oi_issue_revision
    ADD COLUMN no_indicia_frequency tinyint(1) NOT NULL default 0
        AFTER indicia_frequency,
    ADD COLUMN no_isbn tinyint(1) NOT NULL default 0 AFTER isbn,
    ADD COLUMN barcode varchar(38) NOT NULL default '',
    ADD COLUMN no_barcode tinyint(1) NOT NULL default 0,
    ADD COLUMN on_sale_date date default NULL;

-- Add series level flag fields.  These might not get used, but can
-- easily be dropped in that case.  Having them here gives us ease of
-- deployment if they get approved.  For now, assume we're not searching these.
ALTER TABLE gcd_series
    ADD COLUMN has_indicia_frequency tinyint(1) NOT NULL default 1,
    ADD COLUMN has_isbn tinyint(1) NOT NULL default 1,
    ADD COLUMN has_barcode tinyint(1) NOT NULL default 1;

ALTER TABLE oi_series_revision
    ADD COLUMN has_indicia_frequency tinyint(1) NOT NULL default 1,
    ADD COLUMN has_isbn tinyint(1) NOT NULL default 1,
    ADD COLUMN has_barcode tinyint(1) NOT NULL default 1;

-- Add the new date fields and the uncertainty flags for all date fields to
-- all three publisher-type tables.
ALTER TABLE gcd_publisher
    ADD COLUMN year_began_uncertain tinyint(1) NOT NULL default 0,
    ADD COLUMN year_ended_uncertain tinyint(1) NOT NULL default 0,
    ADD COLUMN entity_began int(11) default NULL,
    ADD COLUMN entity_ended int(11) default NULL,
    ADD COLUMN entity_began_uncertain tinyint(1) NOT NULL default 0,
    ADD COLUMN entity_ended_uncertain tinyint(1) NOT NULL default 0,
    ADD KEY (year_began_uncertain),
    ADD KEY (year_ended_uncertain),
    ADD KEY (entity_began),
    ADD KEY (entity_ended),
    ADD KEY (entity_began_uncertain),
    ADD KEY (entity_ended_uncertain);

ALTER TABLE oi_publisher_revision
    ADD COLUMN year_began_uncertain tinyint(1) NOT NULL default 0,
    ADD COLUMN year_ended_uncertain tinyint(1) NOT NULL default 0,
    ADD COLUMN entity_began int(11) default NULL,
    ADD COLUMN entity_ended int(11) default NULL,
    ADD COLUMN entity_began_uncertain tinyint(1) NOT NULL default 0,
    ADD COLUMN entity_ended_uncertain tinyint(1) NOT NULL default 0;

ALTER TABLE gcd_brand
    ADD COLUMN year_began_uncertain tinyint(1) NOT NULL default 0,
    ADD COLUMN year_ended_uncertain tinyint(1) NOT NULL default 0,
    ADD COLUMN entity_began int(11) default NULL,
    ADD COLUMN entity_ended int(11) default NULL,
    ADD COLUMN entity_began_uncertain tinyint(1) NOT NULL default 0,
    ADD COLUMN entity_ended_uncertain tinyint(1) NOT NULL default 0,
    ADD KEY (year_began_uncertain),
    ADD KEY (year_ended_uncertain),
    ADD KEY (entity_began),
    ADD KEY (entity_ended),
    ADD KEY (entity_began_uncertain),
    ADD KEY (entity_ended_uncertain);

ALTER TABLE oi_brand_revision
    ADD COLUMN year_began_uncertain tinyint(1) NOT NULL default 0,
    ADD COLUMN year_ended_uncertain tinyint(1) NOT NULL default 0,
    ADD COLUMN entity_began int(11) default NULL,
    ADD COLUMN entity_ended int(11) default NULL,
    ADD COLUMN entity_began_uncertain tinyint(1) NOT NULL default 0,
    ADD COLUMN entity_ended_uncertain tinyint(1) NOT NULL default 0;

ALTER TABLE gcd_indicia_publisher
    ADD COLUMN year_began_uncertain tinyint(1) NOT NULL default 0,
    ADD COLUMN year_ended_uncertain tinyint(1) NOT NULL default 0,
    ADD COLUMN entity_began int(11) default NULL,
    ADD COLUMN entity_ended int(11) default NULL,
    ADD COLUMN entity_began_uncertain tinyint(1) NOT NULL default 0,
    ADD COLUMN entity_ended_uncertain tinyint(1) NOT NULL default 0,
    ADD KEY (year_began_uncertain),
    ADD KEY (year_ended_uncertain),
    ADD KEY (entity_began),
    ADD KEY (entity_ended),
    ADD KEY (entity_began_uncertain),
    ADD KEY (entity_ended_uncertain);

ALTER TABLE oi_indicia_publisher_revision
    ADD COLUMN year_began_uncertain tinyint(1) NOT NULL default 0,
    ADD COLUMN year_ended_uncertain tinyint(1) NOT NULL default 0,
    ADD COLUMN entity_began int(11) default NULL,
    ADD COLUMN entity_ended int(11) default NULL,
    ADD COLUMN entity_began_uncertain tinyint(1) NOT NULL default 0,
    ADD COLUMN entity_ended_uncertain tinyint(1) NOT NULL default 0;

