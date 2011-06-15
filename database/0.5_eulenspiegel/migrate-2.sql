-- Add issue title field.
ALTER TABLE gcd_issue
    ADD COLUMN title varchar(255) NOT NULL default '',
    ADD COLUMN no_title tinyint(1) NOT NULL default 0,
    ADD KEY (title);

ALTER TABLE oi_issue_revision
    ADD COLUMN title varchar(255) NOT NULL default '',
    ADD COLUMN no_title tinyint(1) NOT NULL default 1;

-- Add series level flag fields, series year uncertain, sort_name
ALTER TABLE gcd_series
    ADD COLUMN sort_name varchar(255) NOT NULL after name,
    ADD COLUMN has_indicia_frequency tinyint(1) NOT NULL default 1,
    aDD COLUMN has_isbn tinyint(1) NOT NULL default 1,
    ADD COLUMN has_barcode tinyint(1) NOT NULL default 1,
    ADD COLUMN has_issue_title tinyint(1) NOT NULL default 0,
    ADD COLUMN year_began_uncertain tinyint(1) NOT NULL default 0 after year_began,
    ADD COLUMN year_ended_uncertain tinyint(1) NOT NULL default 0 after year_ended,
    ADD KEY sort_name (sort_name);
UPDATE gcd_series SET sort_name=name;

ALTER TABLE oi_series_revision
    ADD COLUMN has_indicia_frequency tinyint(1) NOT NULL default 1,
    ADD COLUMN has_isbn tinyint(1) NOT NULL default 1,
    ADD COLUMN has_barcode tinyint(1) NOT NULL default 1,
    ADD COLUMN has_issue_title tinyint(1) NOT NULL default 0,
    ADD COLUMN year_began_uncertain tinyint(1) NOT NULL default 0 after year_began,     
    ADD COLUMN year_ended_uncertain tinyint(1) NOT NULL default 0 after year_ended,
    ADD COLUMN leading_article tinyint(1) NOT NULL DEFAULT '0' after name;

