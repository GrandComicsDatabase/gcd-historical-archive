SET SESSION sql_mode='STRICT_ALL_TABLES';

ALTER TABLE oi_changeset
    ADD COLUMN imps integer NOT NULL default 0 AFTER change_type;

ALTER TABLE gcd_indexer
    ADD COLUMN imps integer NOT NULL default 0 AFTER registration_expires;

