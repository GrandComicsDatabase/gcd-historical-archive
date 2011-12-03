--- migration_story_status exists, but no corresponding entries exist
--- for new stories, might as well drop the whole table and rebuilt
DROP TABLE migration_story_status;

CREATE TABLE migration_story_status (
    id int(11) NOT NULL auto_increment,
    story_id int(11) NOT NULL,
    reprint_needs_inspection tinyint(1) default NULL,
    reprint_confirmed tinyint(1) default NULL,
    reprint_original_notes longtext,
    PRIMARY KEY (id),
    KEY key_reprint_needs_inspection (`reprint_needs_inspection`),
    KEY key_reprint_confirmed (`reprint_confirmed`),
    KEY key_reprint_notes (`reprint_original_notes`(255))
) ENGINE=InnoDB;

INSERT INTO migration_story_status (story_id)
    SELECT id FROM gcd_story;

UPDATE migration_story_status i INNER JOIN gcd_story h ON h.id = i.story_id
    SET i.reprint_original_notes=h.reprint_notes;
UPDATE migration_story_status set reprint_confirmed=1 where reprint_original_notes='';
