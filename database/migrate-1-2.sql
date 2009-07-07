SET SESSION sql_mode='STRICT_ALL_TABLES';

-- Fix absurd parent and imprint IDs.
UPDATE core_publisher SET parent_id=NULL WHERE parent_id = 0;
UPDATE core_series SET imprint_id=NULL WHERE imprint_id = 0;

-- Mark missing country IDs.
INSERT INTO core_country (code, name) VALUES ('XX', '-- FIX ME --');
UPDATE core_publisher SET country_id=(
    SELECT id FROM core_country WHERE code = 'XX')
    WHERE country_id = 0 OR country_id IS NULL;

-- Fix wacky double cover entry- delete the one that has no image with it.
DELETE FROM core_cover WHERE id=232797;

-- Deal with missing cover entries.
INSERT INTO core_cover (issue_id, issue_number, series_id, sort_code, has_image,
                        publisher_name, series_name, year_began,
                        created, creation_time, modified, modification_time)
    SELECT i.id, i.`number`, i.series_id, '000', 0, i.publisher_name,
           i.series_name, i.year_began, CURRENT_DATE(), CURRENT_TIME(),
           CURRENT_DATE(), CURRENT_TIME()
        FROM core_issue i LEFT OUTER JOIN core_cover c ON i.id=c.issue_id
        WHERE c.id IS NULL;

-- Fix missing default setting of sequence_number from previous script.
-- Only do this for covers matching issues that have a sequence 0 already.
UPDATE core_cover c INNER JOIN core_issue i ON c.issue_id=i.id
                    INNER JOIN core_sequence q ON i.id=q.issue_id AND q.number=0
    SET c.sequence_number=0, c.sequence_id=q.id;

-- Make the sort code an attribute of the issue table, but leave it on
-- the cover table as denormalization for now, adjusting the name to reflect
-- that.  Index it on the issue table, and index the issue number while
-- we're at it.  Then update all but the "orphan cover" issues, which
-- have multiple covers attached to them.
ALTER TABLE core_cover
    MODIFY COLUMN sequence_number int(11) default NULL
        COMMENT 'Will be NULL for issues with no sequences indexed.',
    MODIFY COLUMN has_image tinyint(1) NOT NULL default 0
        COMMENT 'May be dropped if has_* fields are sufficient.',
    CHANGE COLUMN sort_code location_code varchar(50) NOT NULL,
    ADD COLUMN issue_sort_code int(11) NOT NULL default 0 AFTER location_code;

ALTER TABLE core_issue
    ADD COLUMN sort_code int(11) NOT NULL default 0 AFTER key_date,
    ADD INDEX issue_sort (sort_code),
    ADD INDEX issue_number (`number`);

SET @doubled_covers_issue=
    (SELECT id FROM core_issue WHERE number='*GCD DOUBLED COVERS ISSUE');
SET @null_issue=
    (SELECT id FROM core_issue WHERE number='*GCD NULL ISSUE');
SET @orphan_covers_issue=
    (SELECT id FROM core_issue WHERE number='*GCD ORPHAN COVERS ISSUE');
SET @vanished_issue_covers_issue=
    (SELECT id FROM core_issue WHERE number='*GCD VANISHED ISS. COVERS');
SET @vanished_issues_issue=
    (SELECT id FROM core_issue WHERE number='*GCD VANISHED ISSUES');

CREATE TEMPORARY TABLE sort_helper (
    id int(11) NOT NULL auto_increment,
    cover_id int(11),
    issue_id int(11),
    PRIMARY KEY (id) 
);

INSERT INTO sort_helper (cover_id, issue_id)
    SELECT c.id, i.id FROM core_cover c LEFT OUTER JOIN core_issue i
                                  ON c.issue_id = i.id
                ORDER BY c.series_id, c.location_code, i.key_date;

UPDATE core_issue i INNER JOIN sort_helper h ON i.id = h.issue_id
    SET i.sort_code=h.id
        WHERE i.id NOT IN (@doubled_covers_issue);

UPDATE core_cover c INNER JOIN core_issue i ON i.id = c.issue_id
    SET c.issue_sort_code=i.sort_code,
        c.issue_number=i.number;

ALTER TABLE core_sequence
    ADD INDEX sequence_type (`type`),
    ADD INDEX sequence_genre (genre);

UPDATE core_sequence SET `type`='Insert' WHERE `type` ='inserto';
UPDATE core_sequence SET `type`='Letters' WHERE `type` ='lettere';
UPDATE core_sequence SET `type`='Text Story' WHERE `type` ='Storia testuale';
UPDATE core_sequence SET `type`='Story' WHERE `type` ='Storia';
UPDATE core_sequence SET `type`='Cover' WHERE `type` ='Copertina';
UPDATE core_sequence SET `type`='Backcovers' WHERE `type` =
    'Copertina Posteriore';
UPDATE core_sequence SET `type`='Pinup' WHERE `type` = 'Illustrazione';
UPDATE core_sequence SET `type`='Text Article' WHERE `type` = 'Articolo';
UPDATE core_sequence SET `type`='Cover Reprint'
    WHERE `type` = 'Copertina Interna';
UPDATE core_sequence SET `type`='Activity' WHERE `type` = 'Giochi';
UPDATE core_sequence SET `type`='Text Story' WHERE `type` = 'Racconto';

-- Our collation may not be case sensitive, but Python is.
UPDATE core_sequence SET `type`=LOWER(`type`) WHERE `type` IS NOT NULL;

