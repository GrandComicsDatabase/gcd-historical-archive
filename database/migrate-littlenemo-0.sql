SET SESSION sql_mode='STRICT_ALL_TABLES';

INSERT INTO voting_mailing_list (address) VALUES
    ('gcd-policy@googlegroups.com'),
    ('gcd-main@googlegroups.com'),
    ('gcd-board@googlegroups.com'),
    ('gcd-editor@googlegroups.com'),
    ('gcd-tech@googlegroups.com');

INSERT INTO voting_agenda
    (name, uses_tokens, allows_abstentions, quorum, secret_ballot, permission_id)
  VALUES
    ('Board of Directors', 0, 1, NULL, 0,
     (SELECT id FROM auth_permission WHERE codename='on_board')),
    ('Fields and Formatting Rules', 1, 0, 9, 0,
     (SELECT id FROM auth_permission WHERE codename='can_vote'));

SET @board_agenda=(SELECT id FROM voting_agenda WHERE name='Board of Directors');
SET @rules_agenda=(SELECT id FROM voting_agenda
                   WHERE name='Fields and Formatting Rules');

SET @board=(SELECT id FROM voting_mailing_list WHERE address LIKE '%board%');
SET @main=(SELECT id FROM voting_mailing_list WHERE address LIKE '%main%');
SET @policy=(SELECT id FROM voting_mailing_list WHERE address LIKE '%policy%');
SET @editor=(SELECT id FROM voting_mailing_list WHERE address LIKE '%editor%');

INSERT INTO voting_agenda_mailing_list
  (agenda_id, mailing_list_id,
   on_agenda_item_add, on_agenda_item_open, on_vote_open, on_vote_close,
   reminder, display_token)
  VALUES
    (@board_agenda, @board, 0, 0, 1, 1, 1, 0),
    (@board_agenda, @main, 0, 0, 0, 1, 0, 0),
    (@rules_agenda, @policy, 1, 1, 1, 1, 1, 1),
    (@rules_agenda, @main, 0, 1, 0, 1, 0, 0),
    (@rules_agenda, @editor, 0, 1, 0, 1, 0, 0);


INSERT INTO voting_vote_type (name, max_votes, max_winners) VALUES
    ('Pass / Fail', 1, 1),
    ('Choose One', 1, 1),
    ('Ranked Choice', NULL, 1),
    ('Board Election: Choose Four', 4, 4),
    ('Board Election: Choose Five', 5, 5);

