SET SESSION sql_mode='STRICT_ALL_TABLES';

ALTER TABLE gcd_issue
    ADD COLUMN no_brand tinyint(1) default 0 AFTER brand_id,
    ADD INDEX (no_brand);

ALTER TABLE oi_issue_revision
    ADD COLUMN no_brand tinyint(1) default 0 AFTER brand_id,
    ADD INDEX (no_brand);

