-- migration_story_status exists, but no corresponding entries exist
-- for new stories, might as well drop the whole table and rebuilt
DROP TABLE IF EXISTS migration_story_status;

CREATE TABLE migration_story_status (
    id int(11) NOT NULL auto_increment,
    story_id int(11) NOT NULL,
    reprint_needs_inspection tinyint(1) default NULL,
    reprint_confirmed tinyint(1) default NULL,
    reprint_original_notes longtext,
    modified datetime NOT NULL default '1901-01-01 00:00:00',
    PRIMARY KEY (id),
    KEY key_story_id (`story_id`),
    KEY key_reprint_needs_inspection (`reprint_needs_inspection`),
    KEY key_reprint_confirmed (`reprint_confirmed`),
    KEY key_reprint_notes (`reprint_original_notes`(255))
) ENGINE=InnoDB DEFAULT CHARSET=utf8;;

DROP TABLE IF EXISTS `gcd_issue_reprint`;
DROP TABLE IF EXISTS `issue_reprint`;
CREATE TABLE `gcd_issue_reprint` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `origin_issue_id` int(11) NOT NULL,
  `target_issue_id` int(11) NOT NULL,
  `notes` longtext,
  `reserved` tinyint(1) NOT NULL DEFAULT '0',
  `modified` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `issue_from` (`origin_issue_id`),
  KEY `issue_to` (`target_issue_id`),
  KEY `reserved` (`reserved`),
  CONSTRAINT `gcd_issue_reprint_ibfk_1` FOREIGN KEY (`origin_issue_id`) REFERENCES `gcd_issue` (`id`),
  CONSTRAINT `gcd_issue_reprint_ibfk_2` FOREIGN KEY (`target_issue_id`) REFERENCES `gcd_issue` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


INSERT INTO migration_story_status (story_id)
    SELECT id FROM gcd_story;

UPDATE migration_story_status i INNER JOIN gcd_story h ON h.id = i.story_id
    SET i.reprint_original_notes=h.reprint_notes;
UPDATE migration_story_status set reprint_confirmed=1 where reprint_original_notes='';
UPDATE migration_story_status i INNER JOIN gcd_story h ON h.id = i.story_id
    SET i.reprint_confirmed=1 where h.reprint_notes = i.reprint_original_notes;

ALTER TABLE gcd_reprint
    DROP FOREIGN KEY gcd_reprint_ibfk_1,
    CHANGE COLUMN source_id origin_id int(11) default NULL;
ALTER TABLE gcd_reprint
    ADD CONSTRAINT `gcd_reprint_ibfk_1` FOREIGN KEY (`origin_id`) REFERENCES `gcd_story` (`id`);

ALTER TABLE gcd_reprint_from_issue
    DROP FOREIGN KEY gcd_reprint_from_issue_ibfk_1,
    CHANGE COLUMN source_issue_id origin_issue_id int(11) default NULL;
ALTER TABLE gcd_reprint_from_issue
    ADD CONSTRAINT `gcd_reprint_from_issue_ibfk_1` FOREIGN KEY (`origin_issue_id`) REFERENCES `gcd_issue` (`id`);

ALTER TABLE gcd_reprint_to_issue
    DROP FOREIGN KEY gcd_reprint_to_issue_ibfk_1,
    CHANGE COLUMN source_id origin_id int(11) default NULL;
ALTER TABLE gcd_reprint_to_issue
    ADD CONSTRAINT `gcd_reprint_to_issue_ibfk_1` FOREIGN KEY (`origin_id`) REFERENCES `gcd_story` (`id`);

CREATE TABLE `oi_reprint_revision` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `changeset_id` int(11) NOT NULL,
  `deleted` tinyint(1) NOT NULL,
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL,
  `reprint_id` int(11) DEFAULT NULL,
  `reprint_from_issue_id` int(11) DEFAULT NULL,
  `reprint_to_issue_id` int(11) DEFAULT NULL,
  `issue_reprint_id` int(11) DEFAULT NULL,
  `origin_story_id` int(11) DEFAULT NULL,
  `origin_revision_id` int(11) DEFAULT NULL,
  `origin_issue_id` int(11) DEFAULT NULL,
  `target_story_id` int(11) DEFAULT NULL,
  `target_revision_id` int(11) DEFAULT NULL,
  `target_issue_id` int(11) DEFAULT NULL,
  `notes` longtext NOT NULL,
  `in_type` int(11) DEFAULT NULL,
  `out_type` int(11) DEFAULT NULL,
  `previous_revision_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `previous_revision_id` (`previous_revision_id`),
  KEY `oi_reprint_revision_661cc59` (`changeset_id`),
  KEY `oi_reprint_revision_3216ff68` (`created`),
  KEY `oi_reprint_revision_5436e97a` (`modified`),
  KEY `oi_reprint_revision_bc873b9b` (`reprint_id`),
  KEY `oi_reprint_revision_6408518b` (`reprint_from_issue_id`),
  KEY `oi_reprint_revision_1113fb1c` (`reprint_to_issue_id`),
  KEY `oi_reprint_revision_6f02b75` (`issue_reprint_id`),
  KEY `oi_reprint_revision_8d6b44c1` (`origin_story_id`),
  KEY `oi_reprint_revision_4511cc72` (`origin_revision_id`),
  KEY `oi_reprint_revision_6ede1263` (`origin_issue_id`),
  KEY `oi_reprint_revision_75a90c0b` (`target_story_id`),
  KEY `oi_reprint_revision_37925432` (`target_revision_id`),
  KEY `oi_reprint_revision_b219039` (`target_issue_id`),
  KEY `oi_reprint_revision_7c1039b0` (`in_type`),
  KEY `oi_reprint_revision_9449d54` (`out_type`),
  CONSTRAINT `oi_reprint_revision_ibfk_1` FOREIGN KEY (`origin_story_id`) REFERENCES `gcd_story` (`id`),
  CONSTRAINT `oi_reprint_revision_ibfk_2` FOREIGN KEY (`origin_revision_id`) REFERENCES `oi_story_revision` (`id`),
  CONSTRAINT `oi_reprint_revision_ibfk_3` FOREIGN KEY (`origin_issue_id`) REFERENCES `gcd_issue` (`id`),
  CONSTRAINT `oi_reprint_revision_ibfk_4` FOREIGN KEY (`target_story_id`) REFERENCES `gcd_story` (`id`),
  CONSTRAINT `oi_reprint_revision_ibfk_5` FOREIGN KEY (`target_revision_id`) REFERENCES `oi_story_revision` (`id`),
  CONSTRAINT `oi_reprint_revision_ibfk_6` FOREIGN KEY (`target_issue_id`) REFERENCES `gcd_issue` (`id`),
  CONSTRAINT `oi_reprint_revision_ibfk_7` FOREIGN KEY (`reprint_id`) REFERENCES `gcd_reprint` (`id`),
  CONSTRAINT `oi_reprint_revision_ibfk_8` FOREIGN KEY (`reprint_from_issue_id`) REFERENCES `gcd_reprint_from_issue` (`id`),
  CONSTRAINT `oi_reprint_revision_ibfk_9` FOREIGN KEY (`reprint_to_issue_id`) REFERENCES `gcd_reprint_to_issue` (`id`),
  CONSTRAINT `oi_reprint_revision_ibfk_10` FOREIGN KEY (`issue_reprint_id`) REFERENCES `gcd_issue_reprint` (`id`),
  CONSTRAINT `oi_reprint_revision_ibfk_11` FOREIGN KEY (`previous_revision_id`) REFERENCES `oi_reprint_revision` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

