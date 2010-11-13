SET SESSION sql_mode='STRICT_ALL_TABLES';

-- Make everything fit in the auth_users table.  Most of these names were
-- in the last_name field making this the only account that did not fit.
UPDATE auth_user SET first_name='Chris Brown; M Vassallo;',
                      last_name='F Motler; J Selegue'
    WHERE username = 'Cbrown';

UPDATE auth_user u INNER JOIN Indexers i ON u.id = i.user_id
    SET u.date_joined=i.DateCreated;

UPDATE Indexers SET Country='de' WHERE Country = 'GERMANY';
UPDATE Indexers SET Country='fi' WHERE Country = 'FINLAND';
UPDATE Indexers SET Country='ie' WHERE Country = 'IRL';
UPDATE Indexers SET Country='il' WHERE Country = 'ISRAEL';
UPDATE Indexers SET Country='pt' WHERE Country = 'Portugal';
UPDATE Indexers SET Country='es' WHERE Country IN ('SPAIN', 'E');
UPDATE Indexers SET Country=NULL WHERE Country IN ('None', '');

ALTER TABLE Indexers
    DROP COLUMN FirstName,
    DROP COLUMN LastName,
    DROP COLUMN Name,
    DROP COLUMN username,
    DROP COLUMN `password`,
    DROP COLUMN eMail,
    DROP COLUMN loginkey,
    DROP COLUMN loginlock,
    DROP COLUMN session,
    DROP COLUMN userlevel,
    DROP COLUMN expert,
    DROP COLUMN Message,
    DROP COLUMN Active,
    DROP COLUMN DateCreated,
    DROP COLUMN DateMod,
    ADD COLUMN country_id int(11) default NULL,
    ADD COLUMN deceased tinyint(1) NOT NULL default 0,
    ADD COLUMN max_reservations int(11) NOT NULL default 10,
    ADD COLUMN max_ongoing int(11) NOT NULL default 4,
    ADD COLUMN is_new int(11) NOT NULL default 0,
    ADD COLUMN is_banned int(11) NOT NULL default 0,
    ADD COLUMN mentor_id int(11) default NULL,
    ADD COLUMN interests longtext default NULL,
    ADD COLUMN registration_key varchar(40),
    ADD COLUMN registration_expires date,
    ADD INDEX (country_id),
    ADD INDEX (mentor_id),
    ADD INDEX (is_new),
    ADD INDEX (is_banned),
    ADD INDEX (deceased),
    ADD INDEX (registration_key),
    ADD INDEX (registration_expires);

UPDATE Indexers i INNER JOIN auth_user u ON i.user_id = u.id
    SET i.deceased=1, u.is_active=0 WHERE u.last_name LIKE '%R.I.P.%';
UPDATE auth_user SET last_name=REPLACE(last_name, ' (R.I.P.)', '')
    WHERE last_name LIKE '%(R.I.P.)';
UPDATE auth_user SET last_name=REPLACE(last_name, ' R.I.P.', '')
    WHERE last_name LIKE '%R.I.P.';

UPDATE Indexers i INNER JOIN auth_user u ON i.user_id = u.id
    SET i.is_banned=1 WHERE email LIKE '%do not reactivate%';

UPDATE auth_user SET email='' WHERE email='need!';

UPDATE Indexers i
    SET i.country_id=(SELECT c.id FROM Countries c WHERE i.Country = c.code)
    WHERE i.Country IS NOT NULL;
ALTER TABLE Indexers DROP Country;

CREATE TABLE Indexers_Languages (
    id int(11) NOT NULL auto_increment,
    indexer_id int(11) NOT NULL,
    language_id int(11) NOT NULL,
    PRIMARY KEY (id),
    INDEX (indexer_id),
    INDEX (language_id)
);

-- Make this alphabatize on the main name, not the parenthetical name
UPDATE Languages SET language='Oromo (Afan)' WHERE code='om';

INSERT INTO auth_group (name) VALUES ('member'), ('board');

SET @board=(SELECT id FROM auth_group WHERE name = 'board');
INSERT INTO auth_user_groups (user_id, group_id)
    SELECT id, @board FROM auth_user WHERE username IN (
        'handrews', -- Henry
        'lionele', -- Lionel
        'loum*azze', -- Lou
        'leylander', -- Matt
        'rastas3204', -- Mike
        'ralfh', -- Ralf
        'rayb', -- Ray
        'tonyr', -- Tony
        'wallred' -- Will
    );

INSERT INTO auth_permission (name, content_type_id, codename)
    VALUES ('can upload cover',
            (SELECT id FROM django_content_type WHERE model = 'cover'),
            'can_upload_cover');

INSERT INTO auth_group_permissions (group_id, permission_id)
    VALUES ((SELECT id FROM auth_group WHERE name = 'indexer'),
            (SELECT id from auth_permission WHERE codename='can_upload_cover'));

-- Fix various extra account problems by consolidating to the primary account
-- for each user if necessary.  Delete the extras.
UPDATE IndexCredit SET IndexerID=369 WHERE IndexerID = 190;
UPDATE auth_user SET last_name='Løvstad'WHERE username = 'jonal';

DELETE Indexers, auth_user
    FROM Indexers INNER JOIN auth_user ON Indexers.user_id = auth_user.id
    WHERE Indexers.ID IN (190, 299, 332);

