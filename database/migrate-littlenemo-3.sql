ALTER TABLE gcd_story ADD `deleted` bool NOT NULL DEFAULT false;
ALTER TABLE gcd_cover DROP COLUMN variant_text, DROP COLUMN variant_code;
DELETE FROM gcd_cover where has_image = 0;
ALTER TABLE gcd_cover DROP COLUMN has_image;
ALTER TABLE gcd_cover ADD `deleted` bool NOT NULL DEFAULT false;
ALTER TABLE gcd_indexer ADD `notify_on_approve` bool NOT NULL DEFAULT false;