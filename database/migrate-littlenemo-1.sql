SET SESSION sql_mode='STRICT_ALL_TABLES';

-- Change type is a numeric enum with symbols defined in code.  0 is "UNKNOWN".
ALTER TABLE oi_changeset ADD COLUMN change_type tinyint(2) NOT NULL default 0,
                         ADD INDEX (change_type);

-- Initialize the column properly.  Most change types match one table exactly, so
-- the inner join serves the role of the where clause.  Issues are more complicated.

-- 1 is "PUBLISHER"
UPDATE oi_changeset c INNER JOIN oi_publisher_revision r ON c.id=r.changeset_id
    SET c.change_type=1;

-- 2 is "BRAND"
UPDATE oi_changeset c INNER JOIN oi_brand_revision r ON c.id=r.changeset_id
    SET c.change_type=2;

-- 3 is "INDICIA_PUBLISHER"
UPDATE oi_changeset c INNER JOIN oi_indicia_publisher_revision r
    ON c.id=r.changeset_id
    SET c.change_type=3;

-- 4 is "SERIES"
UPDATE oi_changeset c INNER JOIN oi_series_revision r ON c.id=r.changeset_id
    SET c.change_type=4;

-- 5 is "ISSUE_ADD", 6 is "ISSUE"
UPDATE oi_changeset c
    INNER JOIN oi_issue_revision r ON r.changeset_id=c.id
    LEFT OUTER JOIN gcd_issue i ON r.issue_id=i.id
    SET c.change_type=IF(i.id IS NULL OR r.created <= i.created, 5, 6);

-- 7 is "COVER",
UPDATE oi_changeset c INNER JOIN oi_cover_revision r ON c.id=r.changeset_id
    SET c.change_type=7;

