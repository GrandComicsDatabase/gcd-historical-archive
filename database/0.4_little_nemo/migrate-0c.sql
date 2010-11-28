-- Add the Charter Amendment vote type wihch requires a two thirds majority but
-- otherwise behaves like the Pass/Vail type.

SET SESSION sql_mode='STRICT_ALL_TABLES';

INSERT INTO voting_vote_type (name, max_votes, max_winners)
    VALUES ('Charter Amendment', 1, 1);

