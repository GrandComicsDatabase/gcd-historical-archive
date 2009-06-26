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
    confirmed tinyint(1) default 0,
    notes mediumtext,
    PRIMARY KEY (id),
    KEY reprint_from (`source_id`),
    KEY reprint_to (`target_id`)
);

CREATE TABLE core_reprint_to_issue (
    id int(11) NOT NULL auto_increment,
    source_id int(11) NOT NULL,
    target_id int(11) NOT NULL,
    confirmed tinyint(1) default 0,
    notes mediumtext,
    PRIMARY KEY (id),
    KEY reprint_to_issue_from (`source_id`),
    KEY reprint_to_issue_to (`target_id`)
);

CREATE TABLE core_reprint_from_issue (
    id int(11) NOT NULL auto_increment,
    source_id int(11) NOT NULL,
    target_id int(11) NOT NULL,
    confirmed tinyint(1) default 0,
    notes mediumtext,
    PRIMARY KEY (id),
    KEY reprint_to_issue_from (`source_id`),
    KEY reprint_to_issue_to (`target_id`)
);

ALTER TABLE core_sequence CHANGE COLUMN reprints reprint_notes mediumtext
    ADD INDEX reprint_notes (reprint_notes);

