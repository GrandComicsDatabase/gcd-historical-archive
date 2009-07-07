SET SESSION sql_mode='STRICT_ALL_TABLES';

ALTER TABLE core_country MODIFY COLUMN code varchar(10) NOT NULL UNIQUE;
ALTER TABLE core_language MODIFY COLUMN code varchar(10) NOT NULL UNIQUE;
UPDATE core_country SET code=LOWER(code);
UPDATE core_language SET code=LOWER(code);

-- The "Superman: Deadly Legacy" series is indeed in Bosnian, which is
-- not in our language table.  The series' language code is correct, though.
INSERT INTO core_language (code, name) VALUES ('bs', 'Bosnian');

-- Fix language code for Dutch.
UPDATE core_series SET language_code='nl'
    WHERE country_code = 'nl' AND language_code IN ('du', 'dy');

-- Fix language code for Danish.
UPDATE core_series SET language_code='da'
    WHERE country_code = 'dk' AND language_code = 'dk';

-- Fix language code for Swedish.
UPDATE core_series SET language_code='sv'
    WHERE country_code = 'se' AND language_code IN ('se', 'ev');

-- Fix language code for English.
UPDATE core_series SET language_code='en'
    WHERE country_code IN ('us', 'uk', 'jp')
         AND language_code IN ('us', 'en,', 'en;', 'ed');

-- Fix language code for Spanish.
UPDATE core_series SET language_code='es'
    WHERE country_code IN ('us', 'mx') AND language_code IN ('sp', 'mx');

-- FIX language code for Portuguese.
UPDATE core_series SET language_code='pt'
    WHERE country_code = 'us' AND language_code = 'po';

-- Fix language code for Greek.
UPDATE core_series SET language_code='el'
    WHERE country_code = 'gr' AND language_code IN ('gr', 'gk');

-- Fix language code for Italian.
UPDATE core_series SET language_code='it'
    WHERE country_code = 'it' AND language_code = 'ir';

UPDATE core_issue SET `number`='[nn]' WHERE `number` = 'nn';

--
-- Proper reprint tables!
--

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

ALTER TABLE core_sequence
    CHANGE COLUMN reprints reprint_notes mediumtext,
    ADD INDEX reprint_notes (reprint_notes(255));

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

