ALTER TABLE gcd_story ADD `deleted` bool NOT NULL DEFAULT false,
    ADD INDEX(deleted);
ALTER TABLE gcd_cover DROP COLUMN variant_text, DROP COLUMN variant_code;
DELETE FROM gcd_cover where has_image = 0;
ALTER TABLE gcd_cover DROP COLUMN has_image;
ALTER TABLE gcd_cover ADD `deleted` bool NOT NULL DEFAULT false,
    ADD INDEX(deleted);
ALTER TABLE gcd_indexer ADD `notify_on_approve` bool NOT NULL DEFAULT false,
   ADD `collapse_compare_view` bool NOT NULL DEFAULT false;
ALTER TABLE gcd_brand ADD `deleted` bool NOT NULL DEFAULT false,
    ADD INDEX(deleted);
ALTER TABLE gcd_issue ADD `deleted` bool NOT NULL DEFAULT false,
    ADD INDEX(deleted);
ALTER TABLE gcd_series ADD `deleted` bool NOT NULL DEFAULT false,
    ADD INDEX(deleted);
ALTER TABLE gcd_publisher ADD `deleted` bool NOT NULL DEFAULT false,
    ADD INDEX(deleted);
ALTER TABLE gcd_indicia_publisher ADD `deleted` bool NOT NULL DEFAULT false,
    ADD INDEX(deleted);

-- Make existing "deleted" column NOT NULL on revision tables, and add index.
ALTER TABLE oi_publisher_revision
    MODIFY COLUMN deleted TINYINT(1) NOT NULL default 0,
    ADD INDEX(deleted);
ALTER TABLE oi_brand_revision
    MODIFY COLUMN deleted TINYINT(1) NOT NULL default 0,
    ADD INDEX(deleted);
ALTER TABLE oi_indicia_publisher_revision
    MODIFY COLUMN deleted TINYINT(1) NOT NULL default 0,
    ADD INDEX(deleted);
ALTER TABLE oi_series_revision
    MODIFY COLUMN deleted TINYINT(1) NOT NULL default 0,
    ADD INDEX(deleted);
ALTER TABLE oi_issue_revision
    MODIFY COLUMN deleted TINYINT(1) NOT NULL default 0,
    ADD INDEX(deleted);
ALTER TABLE oi_story_revision
    MODIFY COLUMN deleted TINYINT(1) NOT NULL default 0,
    ADD INDEX(deleted);
ALTER TABLE oi_cover_revision
    MODIFY COLUMN deleted TINYINT(1) NOT NULL default 0,
    ADD INDEX(deleted);

