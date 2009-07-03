SET SESSION sql_mode='STRICT_ALL_TABLES';

ALTER TABLE core_country MODIFY COLUMN code varchar(10) NOT NULL UNIQUE;
ALTER TABLE core_language MODIFY COLUMN code varchar(10) NOT NULL UNIQUE;
UPDATE core_country SET code=UPPER(code);
UPDATE core_language SET code=UPPER(code);

ALTER TABLE core_cover
    ALTER COLUMN issue_sort_code location_code varchar(50) NOT NULL,
    ADD COLUMN issue_sort_code int(11) NOT NULL default 0;

CREATE TABLE core_reprint (
    id int(11) NOT NULL auto_increment,
    source_id int(11) NOT NULL,
    target_id int(11) NOT NULL,
    notes mediumtext,
    PRIMARY KEY (id),
    KEY reprint_from (`source_id`),
    KEY reprint_to (`target_id`)
);

CREATE TABLE core_reprint_to_issue (
    id int(11) NOT NULL auto_increment,
    source_id int(11) NOT NULL,
    target_issue_id int(11) NOT NULL,
    notes mediumtext,
    PRIMARY KEY (id),
    KEY reprint_to_issue_from (`source_id`),
    KEY reprint_to_issue_to (`target_issue_id`)
);

CREATE TABLE core_reprint_from_issue (
    id int(11) NOT NULL auto_increment,
    source_issue_id int(11) NOT NULL,
    target_id int(11) NOT NULL,
    notes mediumtext,
    PRIMARY KEY (id),
    KEY reprint_to_issue_from (`source_issue_id`),
    KEY reprint_to_issue_to (`target_id`)
);

CREATE TABLE core_issue_reprint (
    id int(11) NOT NULL auto_increment,
    source_issue_id int(11) NOT NULL,
    target_issue_id int(11) NOT NULL,
    notes mediumtext,
    PRIMARY KEY (id),
    KEY issue_from (`source_issue_id`),
    KEY issue_to (`target_issue_id`)
);

ALTER TABLE core_sequence CHANGE COLUMN reprints reprint_notes mediumtext
    ADD INDEX reprint_notes (reprint_notes);

-- Add the first Migration data table, and populate it so we can use
-- a proper OneToOne field in Django.

CREATE TABLE migration_sequence_status (
    id int(11) NOT NULL auto_increment,
    sequence_id int(11) NOT NULL,
    reprint_needs_inspection tinyint(1) default NULL,
    reprint_confirmed tinyint(1) default NULL,
    reprint_original_notes mediumtext,
    PRIMARY KEY (id),
    KEY key_reprint_needs_inspection (`reprint_needs_inspection`),
    KEY key_reprint_confirmed (`reprint_confirmed`),
    KEY key_reprint_notes (`reprint_original_notes`(255))
);

INSERT INTO migration_sequence_status (sequence_id)
    SELECT id FROM core_sequence;

-- imprint_count can't be maintained by a trigger, and is relatively
-- inexpensive to calculate given the size of the publisher table,
-- so drop it rather than try to maintain it in code.

ALTER TABLE core_publisher DROP COLUMN imprint_count;

