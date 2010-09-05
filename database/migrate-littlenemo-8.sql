ALTER TABLE gcd_issue ADD is_indexed BOOL NOT NULL DEFAULT 0;
CREATE TEMPORARY TABLE indexed_issues AS
       SELECT issue_id, SUM(page_count) AS indexed_page_count
              FROM gcd_story GROUP BY issue_id;
UPDATE gcd_issue SET is_indexed = 1 WHERE story_type_count > 0;
UPDATE gcd_issue, indexed_issues
       SET is_indexed = 1
       WHERE gcd_issue.id = indexed_issues.issue_id AND
             is_indexed = 0 AND
             indexed_page_count * 2 > page_count;
DROP TEMPORARY TABLE indexed_issues;
ALTER TABLE gcd_issue DROP COLUMN story_type_count;
