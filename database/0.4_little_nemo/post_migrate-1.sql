ALTER TABLE gcd_issue
  ADD COLUMN valid_isbn VARCHAR(13) NOT NULL DEFAULT '', 
  ADD INDEX (isbn),
  ADD INDEX (valid_isbn);

