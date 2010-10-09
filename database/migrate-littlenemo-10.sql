SET SESSION sql_mode='STRICT_ALL_TABLES';

ALTER TABLE gcd_series
    ADD COLUMN classification_id integer default NULL AFTER name,
    ADD FOREIGN KEY (classification_id) REFERENCES gcd_classification (id);

ALTER TABLE oi_series_revision
    ADD COLUMN classification_id integer default NULL AFTER name,
    ADD FOREIGN KEY (classification_id) REFERENCES gcd_classification (id);

