CREATE TEMPORARY TABLE series_min_max_sort AS
        SELECT series_id, MIN(sort_code) AS min_sort_code, MAX(sort_code) AS max_sort_code
               FROM gcd_issue GROUP BY series_id;

CREATE TEMPORARY TABLE series_min_issue AS
        SELECT gcd_issue.series_id, gcd_issue.id FROM gcd_issue, series_min_max_sort
               WHERE series_min_max_sort.series_id = gcd_issue.series_id AND 
                     gcd_issue.sort_code = series_min_max_sort.min_sort_code;

CREATE TEMPORARY TABLE series_max_issue AS
        SELECT gcd_issue.series_id, gcd_issue.id FROM gcd_issue, series_min_max_sort
               WHERE series_min_max_sort.series_id = gcd_issue.series_id AND
                     gcd_issue.sort_code = series_min_max_sort.max_sort_code;

UPDATE gcd_series, series_min_issue
        SET gcd_series.first_issue_id = series_min_issue.id
        WHERE gcd_series.id = series_min_issue.series_id;

UPDATE gcd_series, series_max_issue
        SET gcd_series.last_issue_id = series_max_issue.id
        WHERE gcd_series.id = series_max_issue.series_id;

DROP TEMPORARY TABLE series_min_max_sort;
DROP TEMPORARY TABLE series_min_issue;
DROP TEMPORARY TABLE series_max_issue;
