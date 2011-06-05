UPDATE gcd_issue i INNER JOIN gcd_series s ON i.series_id=s.id
    SET i.no_isbn=1 WHERE s.year_ended < 1970 OR
        (i.key_date != '' AND SUBSTR(i.key_date, 1, 4) < 1970);

-- This will cause the no_isbn field to appear to be set automatically
-- whenever a key_date before 1970 is flagged.  This may cause one or two
-- odd-looking changes but should be pretty much correct.

UPDATE oi_issue_revision i INNER JOIN gcd_series s ON i.series_id=s.id
    SET i.no_isbn=1 WHERE s.year_ended < 1970 OR
        (i.key_date != '' AND SUBSTR(i.key_date, 1, 4) < 1970);

