ALTER TABLE gcd_issue
    ADD COLUMN `variant_of_id` int(11) DEFAULT NULL,
    ADD COLUMN variant_name VARCHAR(255) NOT NULL DEFAULT '',
    ADD KEY `variant_of_id` (`variant_of_id`),
    ADD CONSTRAINT `gcd_issue_ibfk_4` FOREIGN KEY (`variant_of_id`) REFERENCES `gcd_issue` (`id`);
ALTER TABLE oi_issue_revision 
    ADD COLUMN `variant_of_id` int(11) DEFAULT NULL, 
    ADD COLUMN variant_name VARCHAR(255) NOT NULL DEFAULT '',
    ADD KEY `variant_of_id` (`variant_of_id`), 
    ADD CONSTRAINT `oi_issue_revision_ibfk_4` FOREIGN KEY (`variant_of_id`) REFERENCES `gcd_issue` (`id`);
ALTER TABLE oi_story_revision MODIFY COLUMN `issue_id` int(11) DEFAULT NULL;

