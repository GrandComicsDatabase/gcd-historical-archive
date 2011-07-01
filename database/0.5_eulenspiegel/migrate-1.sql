-- Add issue title field.
ALTER TABLE gcd_issue
    ADD COLUMN `variant_of_id` int(11) DEFAULT NULL,
    ADD COLUMN variant_name VARCHAR(255) NOT NULL DEFAULT '',
    ADD COLUMN barcode VARCHAR(38) NOT NULL DEFAULT '',
    ADD COLUMN no_barcode tinyint(1) NOT NULL DEFAULT '0',
    ADD COLUMN title varchar(255) NOT NULL default '',
    ADD COLUMN no_title tinyint(1) NOT NULL default 0,
    ADD KEY (title),
    ADD KEY `variant_of_id` (`variant_of_id`),
    ADD KEY barcode (barcode),
    ADD CONSTRAINT `gcd_issue_ibfk_4` FOREIGN KEY (`variant_of_id`) REFERENCES `gcd_issue` (`id`);
ALTER TABLE oi_issue_revision 
    ADD COLUMN `variant_of_id` int(11) DEFAULT NULL, 
    ADD COLUMN variant_name VARCHAR(255) NOT NULL DEFAULT '',
    ADD COLUMN barcode VARCHAR(38) NOT NULL DEFAULT '',
    ADD COLUMN no_barcode tinyint(1) NOT NULL DEFAULT '0',
    ADD COLUMN title varchar(255) NOT NULL default '',
    ADD COLUMN no_title tinyint(1) NOT NULL default 0,
    ADD KEY `variant_of_id` (`variant_of_id`), 
    ADD CONSTRAINT `oi_issue_revision_ibfk_4` FOREIGN KEY (`variant_of_id`) REFERENCES `gcd_issue` (`id`);

ALTER TABLE oi_story_revision MODIFY COLUMN `issue_id` int(11) DEFAULT NULL;

UPDATE gcd_series JOIN gcd_issue ON gcd_series.id = gcd_issue.series_id
       SET no_barcode = 1
       WHERE year_ended < 1974 OR
             (key_date <> '' AND SUBSTR(key_date, 1, 4) < 1974);
	
UPDATE oi_issue_revision i INNER JOIN gcd_series s ON i.series_id=s.id
    SET i.no_barcode=1 WHERE s.year_ended < 1974 OR
        (i.key_date != '' AND SUBSTR(i.key_date, 1, 4) < 1974);
