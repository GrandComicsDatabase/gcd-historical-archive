DROP TABLE IF EXISTS voting_expected_voter;

CREATE TABLE voting_expected_voter (
    id int(11) NOT NULL auto_increment,
    voter_id int(11) NOT NULL,
    agenda_id int(11) NOT NULL,
    tenure_began datetime NOT NULL,
    tenure_ended datetime default NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (voter_id) REFERENCES auth_user (id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (agenda_id) REFERENCES voting_agenda (id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

SET @board=(SELECT id FROM voting_agenda WHERE name = 'Board of Directors');

INSERT INTO voting_expected_voter (voter_id, agenda_id, tenure_began, tenure_ended)
  VALUES
    (528, @board, '2000-12-01 00:00:00', '2011-11-30 23:59:59'), -- Will Allred
    (429, @board, '2000-12-01 00:00:00', NULL), -- Ray Bottorff, Jr.
    (356, @board, '2000-12-01 00:00:00', '2008-11-30 23:59:59'), -- Mike Catron
    (318, @board, '2000-12-01 00:00:00', '2003-11-30 23:59:59'), -- Lionel English 1
    (318, @board, '2008-12-01 00:00:00', NULL), -- Lionel English 2
    (320, @board, '2000-12-01 00:00:00', '2001-11-30 23:59:59'), -- Lou Mazzella 1
    (320, @board, '2002-12-01 00:00:00', NULL), -- Lou Mazzella 2
    (368, @board, '2000-12-01 00:00:00', '2001-11-30 23:59:59'), -- Mike Rhode
    (513, @board, '2000-12-01 00:00:00', NULL), -- Tony Rose
    (501, @board, '2000-12-01 00:00:00', '2002-11-30 23:59:59'), -- Tim Stroup
    (353, @board, '2000-12-01 00:00:00', '2002-11-30 23:59:59'), -- Maurizio Villotta
    (302, @board, '2001-12-01 00:00:00', '2003-11-30 23:59:59'), -- Ken Lemons
    (346, @board, '2002-12-01 00:00:00', '2006-11-30 23:59:59'), -- Matt Gore 1
    (346, @board, '2007-02-15 00:00:00', '2011-11-21 23:59:59'), -- Matt Gore 2
    (351, @board, '2002-12-01 00:00:00', '2008-11-22 23:59:59'), -- Matthias Hofmann
    (347, @board, '2003-12-01 00:00:00', '2005-11-30 23:59:59'), -- Matt Head
    (413, @board, '2003-12-01 00:00:00', '2007-02-14 23:59:59'), -- Per Sandell
    (374, @board, '2005-12-01 00:00:00', '2009-11-21 23:59:59'), -- Mike Nielsen
    (222, @board, '2006-12-01 00:00:00', '2008-11-22 23:59:59'), -- Jim Ludwig
    (205, @board, '2008-11-23 00:00:00', '2011-05-12 23:59:59'), -- Henry Andrews
    (425, @board, '2008-11-23 00:00:00', '2010-11-21 23:59:59'), -- Ralf Haring
    (415, @board, '2009-11-22 00:00:00', '2011-11-21 23:59:59'), -- Peter Croome
    (132, @board, '2010-11-22 00:00:00', NULL), -- Donald Dale Milne
    (355, @board, '2011-06-21 00:00:00', NULL), -- Merlin Haas
    (15, @board, '2011-11-22 00:00:00', NULL), -- Alexandros Diamantidis
    (21, @board, '2011-11-22 00:00:00', NULL), -- Andrés Jiménez Gomez
    (92, @board, '2011-11-22 00:00:00', NULL); -- Daniel Nauschuetz

