ALTER TABLE gcd_issue MODIFY COLUMN volume VARCHAR(50);
UPDATE gcd_issue SET volume = '' WHERE volume IS NULL;
ALTER TABLE gcd_issue MODIFY COLUMN volume VARCHAR(50) NOT NULL DEFAULT '';

ALTER TABLE oi_issue_revision MODIFY COLUMN volume VARCHAR(50);
UPDATE oi_issue_revision SET volume = '' WHERE volume IS NULL;
ALTER TABLE oi_issue_revision MODIFY COLUMN volume VARCHAR(50) NOT NULL DEFAULT '';