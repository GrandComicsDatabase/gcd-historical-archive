-- Add issue on-sale field.
ALTER TABLE gcd_issue
    ADD COLUMN on_sale_date varchar(10) DEFAULT NULL,
    ADD COLUMN on_sale_date_uncertain tinyint(1) NOT NULL DEFAULT 0,
    ADD INDEX (on_sale_date);
ALTER TABLE oi_issue_revision
    ADD COLUMN year_on_sale int(11) DEFAULT NULL,
    ADD COLUMN month_on_sale int(11) DEFAULT NULL,
    ADD COLUMN day_on_sale int(11) DEFAULT NULL,
    ADD COLUMN on_sale_date_uncertain tinyint(1) NOT NULL DEFAULT 0;
UPDATE gcd_issue
    SET key_date = REPLACE(key_date, '.', '-');
UPDATE oi_issue_revision
    SET key_date = REPLACE(key_date, '.', '-');

-- Add series level flag for volume
ALTER TABLE gcd_series
    ADD COLUMN has_volume tinyint(1) NOT NULL default 1;

ALTER TABLE oi_series_revision
    ADD COLUMN has_volume tinyint(1) NOT NULL default 1;
