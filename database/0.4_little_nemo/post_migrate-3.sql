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
    ADD KEY (no_indicia_frequency),
    ADD KEY (no_isbn);

-- Add the fields to the revision table.  Do not index them because we
-- do not search the revision tables on these fields.
ALTER TABLE oi_issue_revision
    ADD COLUMN no_indicia_frequency tinyint(1) NOT NULL default 0
        AFTER indicia_frequency,
    ADD COLUMN no_isbn tinyint(1) NOT NULL default 0 AFTER isbn;

-- Add the new date fields and the uncertainty flags for all date fields to
-- all three publisher-type tables.
ALTER TABLE gcd_publisher
    ADD COLUMN year_began_uncertain tinyint(1) NOT NULL default 0,
    ADD COLUMN year_ended_uncertain tinyint(1) NOT NULL default 0,
    ADD KEY (year_began_uncertain),
    ADD KEY (year_ended_uncertain);

ALTER TABLE oi_publisher_revision
    ADD COLUMN year_began_uncertain tinyint(1) NOT NULL default 0,
    ADD COLUMN year_ended_uncertain tinyint(1) NOT NULL default 0;

ALTER TABLE gcd_brand
    ADD COLUMN year_began_uncertain tinyint(1) NOT NULL default 0,
    ADD COLUMN year_ended_uncertain tinyint(1) NOT NULL default 0,
    ADD KEY (year_began_uncertain),
    ADD KEY (year_ended_uncertain);

ALTER TABLE oi_brand_revision
    ADD COLUMN year_began_uncertain tinyint(1) NOT NULL default 0,
    ADD COLUMN year_ended_uncertain tinyint(1) NOT NULL default 0;

ALTER TABLE gcd_indicia_publisher
    ADD COLUMN year_began_uncertain tinyint(1) NOT NULL default 0,
    ADD COLUMN year_ended_uncertain tinyint(1) NOT NULL default 0,
    ADD KEY (year_began_uncertain),
    ADD KEY (year_ended_uncertain);

ALTER TABLE oi_indicia_publisher_revision
    ADD COLUMN year_began_uncertain tinyint(1) NOT NULL default 0,
    ADD COLUMN year_ended_uncertain tinyint(1) NOT NULL default 0;

