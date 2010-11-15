ALTER TABLE oi_cover_revision
    ADD COLUMN is_wraparound BOOL NOT NULL DEFAULT 0,
    ADD COLUMN front_left INT(11) DEFAULT NULL,
    ADD COLUMN front_right INT(11) DEFAULT NULL,
    ADD COLUMN front_top INT(11) DEFAULT NULL,
    ADD COLUMN front_bottom INT(11) DEFAULT NULL;

ALTER TABLE gcd_cover
    ADD COLUMN is_wraparound BOOL NOT NULL DEFAULT 0,
    ADD COLUMN front_left INT(11) DEFAULT NULL,
    ADD COLUMN front_right INT(11) DEFAULT NULL,
    ADD COLUMN front_top INT(11) DEFAULT NULL,
    ADD COLUMN front_bottom INT(11) DEFAULT NULL;
