ALTER TABLE gcd_series
    ADD COLUMN is_comics_publication tinyint(1) NOT NULL default 1;

ALTER TABLE oi_series_revision
    ADD COLUMN is_comics_publication tinyint(1) NOT NULL default 1;
