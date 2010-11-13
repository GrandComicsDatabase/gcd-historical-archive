UPDATE gcd_country SET name = 'United Kingdom' WHERE code = 'gb';
UPDATE gcd_indexer SET country_id = 75 WHERE country_id = 223;
UPDATE gcd_indicia_publisher SET country_id = 75 WHERE country_id = 223;
UPDATE gcd_publisher SET country_id = 75 WHERE country_id = 223;
UPDATE gcd_series SET country_id = 75 WHERE country_id = 223;
UPDATE oi_indicia_publisher_revision SET country_id = 75 WHERE country_id = 223;
UPDATE oi_publisher_revision SET country_id = 75 WHERE country_id = 223;
UPDATE oi_series_revision SET country_id = 75 WHERE country_id = 223;
DELETE FROM gcd_country WHERE code = 'uk';