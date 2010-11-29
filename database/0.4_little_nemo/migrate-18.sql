-- Populate the "most recently updated index" table.  Only stats for allindexes
-- and for german language indexes are supported at the time of this release.

SET SESSION sql_mode='STRICT_ALL_TABLES';

INSERT INTO gcd_recent_indexed_issue (issue_id, language_id, created)
    SELECT i.id, NULL, MAX(i.modified) as max_mod FROM oi_changeset c
        INNER JOIN oi_issue_revision ir ON c.id = ir.changeset_id
        INNER JOIN gcd_issue i on ir.issue_id = i.id
    WHERE i.is_indexed = 1 AND i.deleted = 0 AND change_type = 6
    GROUP BY i.id
    ORDER BY max_mod DESC
    LIMIT 5;

SET @german=(SELECT id FROM gcd_language WHERE code = 'de');
INSERT INTO gcd_recent_indexed_issue (issue_id, language_id, created)
    SELECT i.id, s.language_id, MAX(i.modified) as max_mod FROM oi_changeset c
        INNER JOIN oi_issue_revision ir ON c.id = ir.changeset_id
        INNER JOIN gcd_issue i on ir.issue_id = i.id
        INNER JOIN gcd_series s on i.series_id = s.id
    WHERE i.is_indexed = 1 AND i.deleted = 0 AND change_type = 6 AND
        s.language_id=@german
    GROUP BY i.id, s.language_id
    ORDER BY max_mod DESC
    LIMIT 5;

