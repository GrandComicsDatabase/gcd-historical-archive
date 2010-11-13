SET SESSION sql_mode='STRICT_ALL_TABLES';

-- Allow for secret ballots (NULL voters, tracked through receipts instead).
ALTER TABLE voting_vote MODIFY COLUMN voter_id integer default NULL;

-- There should always be a quorum of at least one- no votes, no results.
UPDATE voting_agenda SET quorum=1 WHERE quorum IS NULL;
ALTER TABLE voting_agenda MODIFY COLUMN quorum integer NOT NULL default 1;

ALTER TABLE voting_agenda_mailing_list
    ADD COLUMN is_primary tinyint(1) NOT NULL default 0;

SET @policy_list=(SELECT id FROM voting_mailing_list
    WHERE address LIKE 'gcd-policy%');
SET @board_list=(SELECT id FROM voting_mailing_list
    WHERE address LIKE 'gcd-board%');

SET @rules_agenda=(SELECT id FROM voting_agenda WHERE name LIKE '%Rules');
SET @board_agenda=(SELECT id FROM voting_agenda WHERE name LIKE 'Board%');

UPDATE voting_agenda_mailing_list SET is_primary=1
    WHERE (mailing_list_id=@policy_list AND agenda_id=@rules_agenda) OR
          (mailing_list_id=@board_list AND agenda_id=@board_agenda);

ALTER TABLE voting_agenda_item CHANGE COLUMN open state tinyint(1) default NULL;

-- Add the open flag, then set to one as all current topics are open.
ALTER TABLE voting_topic ADD COLUMN open tinyint(1) NOT NULL default 0;
UPDATE voting_topic SET open=1;

