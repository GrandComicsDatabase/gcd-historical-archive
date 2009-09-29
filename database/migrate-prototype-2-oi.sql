SET SESSION sql_mode='STRICT_ALL_TABLES';

-- ----------------------------------------------------------------------------
-- Add consistent reservation markers (the old issue-based marker will stick
-- around for now and by migrated with a python script).
-- 
-- Make our timestamps datetime fields instead of inconsistently sometimes
-- having a separate time field and sometimes not.
-- ----------------------------------------------------------------------------

ALTER TABLE publishers
    MODIFY COLUMN Created datetime NOT NULL default '1901-01-01 00:00:00',
    MODIFY COLUMN Modified datetime NOT NULL default '1901-01-01 00:00:00',
    ADD COLUMN reserved tinyint(1) NOT NULL default 0,
    ADD INDEX (reserved);

ALTER TABLE series
    MODIFY COLUMN Created datetime NOT NULL default '1901-01-01 00:00:00',
    MODIFY COLUMN Modified datetime NOT NULL default '1901-01-01 00:00:00',
    ADD COLUMN reserved tinyint(1) NOT NULL default 0,
    ADD INDEX (reserved);

ALTER TABLE issues
    MODIFY COLUMN created datetime NOT NULL default '1901-01-01 00:00:00',
    MODIFY COLUMN Modified datetime NOT NULL default '1901-01-01 00:00:00',
    ADD COLUMN reserved tinyint(1) NOT NULL default 0,
    ADD INDEX (reserved);

ALTER TABLE stories
    MODIFY COLUMN Created datetime NOT NULL default '1901-01-01 00:00:00',
    MODIFY COLUMN Modified datetime NOT NULL default '1901-01-01 00:00:00',
    ADD COLUMN reserved tinyint(1) NOT NULL default 0,
    ADD INDEX (reserved);

ALTER TABLE covers
    MODIFY COLUMN Created datetime NOT NULL default '1901-01-01 00:00:00',
    MODIFY COLUMN Modified datetime NOT NULL default '1901-01-01 00:00:00';

-- ----------------------------------------------------------------------------
-- Fix all datetime fields.
-- ----------------------------------------------------------------------------

-- There's one series with a Modified date way in the future.
-- Add a day to NOW() because the production server is in Norway
-- and the dev server is in Arkansas.
UPDATE series SET Modified=Created
    WHERE Modified > DATE_ADD(NOW(), INTERVAL 1 DAY);
UPDATE series
    SET Modified=DATE_ADD(Modified, INTERVAL ModTime SECOND);
UPDATE issues
    SET Modified=DATE_ADD(Modified, INTERVAL ModTime SECOND);
UPDATE stories
    SET Modified=DATE_ADD(Modified, INTERVAL ModTime SECOND);

-- As always the covers table is a mess.  First fix invalid days/months.
-- There has to be a better way to do this, but I can't find it.
-- Using DATE_ADD with a zero month or day produces NULL.
UPDATE covers
    SET Modified=CONCAT(YEAR(Modified), '-01-', DAY(Modified))
    WHERE MONTH(Modified) = 0;
UPDATE covers
    SET Modified=CONCAT(YEAR(Modified), '-', MONTH(Modified), '-01')
    WHERE DAY(Modified) = 0;
UPDATE covers
    SET Created=CONCAT(YEAR(Created), '-01-', DAY(Created))
    WHERE MONTH(Created) = 0;
UPDATE covers
    SET Created=CONCAT(YEAR(Created), '-', MONTH(Created), '-01')
    WHERE DAY(Created) = 0;
-- Next fix dates in the future.
UPDATE covers SET Created = '1901-01-01 00:00:00'
    WHERE Created > DATE_ADD(NOW(), INTERVAL 1 DAY);
UPDATE covers SET Modified=Created
    WHERE Modified > DATE_ADD(NOW(), INTERVAL 1 DAY);
-- Now do the actual field migration.
UPDATE covers
    SET Modified=DATE_ADD(Modified, INTERVAL ModTime SECOND);
UPDATE covers
    SET Created=DATE_ADD(Created, INTERVAL CreTime SECOND);

-- ----------------------------------------------------------------------------
-- Drop the time fields that are now merged into datetime fields.
-- ----------------------------------------------------------------------------

ALTER TABLE series DROP COLUMN ModTime;
ALTER TABLE issues DROP COLUMN ModTime;
ALTER TABLE stories DROP COLUMN ModTime;
ALTER TABLE covers DROP COLUMN ModTime,
                   DROP COLUMN CreTime;

-- NULL out imprint parents that don't exist.
-- Should have been done before, but apparently wasn't.
UPDATE publishers i LEFT OUTER JOIN publishers p ON i.ParentID = p.ID
    SET i.ParentID = NULL WHERE p.ID IS NULL;

-- Set up permissions
SET @indexers=(SELECT id FROM auth_group WHERE name = 'indexer');
SET @editors=(SELECT id FROM auth_group WHERE name = 'editor');
SET @admins=(SELECT id FROM auth_group WHERE name = 'admin');

INSERT INTO auth_group_permissions (group_id, permission_id)
    SELECT @indexers, id FROM auth_permission WHERE codename = 'can_reserve';

INSERT INTO auth_group_permissions (group_id, permission_id)
    SELECT @editors, id FROM auth_permission
        WHERE codename IN ('can_reserve', 'can_approve', 'can_cancel',
                           'can_mark');

INSERT INTO auth_group_permissions (group_id, permission_id)
    SELECT @admins, id from auth_permission;

UPDATE issues SET Issue='[nn]' WHERE Issue = 'nn';
UPDATE stories SET feature=''
    WHERE feature in ('none', '[none]') OR feature IS NULL;

