-- Add issue title field.
ALTER TABLE gcd_issue
    ADD COLUMN on_sale_date varchar(10) DEFAULT NULL,
    ADD COLUMN on_sale_date_uncertain tinyint(1) NOT NULL DEFAULT 0;
ALTER TABLE oi_issue_revision
    ADD COLUMN year_on_sale int(11) DEFAULT NULL,
    ADD COLUMN month_on_sale int(11) DEFAULT NULL,
    ADD COLUMN day_on_sale int(11) DEFAULT NULL,
    ADD COLUMN on_sale_date_uncertain tinyint(1) NOT NULL DEFAULT 0;
UPDATE gcd_issue
    SET key_date = REPLACE(key_date, '.', '-');
UPDATE oi_issue_revision
    SET key_date = REPLACE(key_date, '.', '-');
