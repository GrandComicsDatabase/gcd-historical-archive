SET SESSION sql_mode='STRICT_ALL_TABLES';

ALTER DATABASE CHARACTER SET utf8;

-- ----------------------------------------------------------------------------
-- NULL/delete me/message rows that need to be removed.
-- ----------------------------------------------------------------------------

-- Several tables have pathological all-NULL entries.
DELETE FROM Indexers WHERE ID=409;
DELETE FROM IndexCredit WHERE IndexerID IS NULL AND SeriesID IS NULL;
DELETE FROM publishers WHERE ID=3915;
DELETE FROM series WHERE ID=11253;
DELETE FROM issues WHERE ID=310423;

-- And "delete me's" and some "message" entries asking for indexers' emails.
DELETE FROM issues WHERE SeriesID=20759;
DELETE FROM series WHERE ID=20759;
DELETE FROM publishers WHERE ID IN (4064, 1789);

-- Former "delete me" series whose (nearly 75,000) covers were left behind.
-- The others might as well hook up to orphan/null/vanished entries instead.
DELETE FROM covers WHERE SeriesID IN (29713, 16030);

-- ----------------------------------------------------------------------------
-- Country code issues.
-- ----------------------------------------------------------------------------

-- There are several made-up countries,
-- one of which duplicates a real code (Syria vs Syrania).
DELETE FROM Countries WHERE code IN ('LW', 'XX', 'X2');
DELETE FROM Countries WHERE country = 'Syrania';

-- Fix name for better sorting- currently starts with "former"..
UPDATE Countries SET country='German Democratic Republic [former]'
    WHERE code = 'dd';

-- Mark missing country IDs.
INSERT INTO Countries (code, country) VALUES ('xx', '-- FIX ME --');
UPDATE publishers SET CountryID=(
    SELECT id FROM Countries WHERE code = 'xx') 
    WHERE CountryID = 0 OR CountryID IS NULL;

UPDATE Countries SET code=LOWER(code);

-- ----------------------------------------------------------------------------
-- There are numerous problems with language codes.
-- ----------------------------------------------------------------------------

-- The "Superman: Deadly Legacy" series is indeed in Bosnian, which is
-- not in our language table.  The series' language code is correct, though.
INSERT INTO Languages (code, language) VALUES ('bs', 'Bosnian');

-- Fix language code for Dutch.
UPDATE series SET LangCode='nl'
    WHERE CounCode = 'nl' AND LangCode IN ('du', 'dy');

-- Fix language code for Danish.
UPDATE series SET LangCode='da'
    WHERE CounCode = 'dk' AND LangCode = 'dk';

-- Fix language code for Swedish.
UPDATE series SET LangCode='sv'
    WHERE CounCode = 'se' AND LangCode = 'ev';

-- Fix language code for English.
UPDATE series SET LangCode='en'
    WHERE CounCode IN ('us', 'uk', 'jp')
         AND LangCode IN ('us', 'en,', 'en;', 'ed', 'em', 'ea');

-- Fix language code for Spanish.
UPDATE series SET LangCode='es'
    WHERE CounCode IN ('us', 'mx') AND LangCode IN ('sp', 'mx');

-- FIX language code for Portuguese.
UPDATE series SET LangCode='pt'
    WHERE CounCode = 'us' AND LangCode = 'po';

-- Fix language code for Greek.
UPDATE series SET LangCode='el'
    WHERE CounCode = 'gr' AND LangCode IN ('gr', 'gk');

-- Fix language code for Italian.
UPDATE series SET LangCode='it'
    WHERE CounCode = 'it' AND LangCode = 'ir';

-- Fix language code for Japanese.
UPDATE series SET LangCode='ja'
    WHERE CounCode = 'jp' AND LangCode = 'jp';

-- Add some languages that are in use but not in the languages table.
INSERT INTO Languages (code, language)
    VALUES ('se', 'Sami (Northern)'),
           ('sma', 'Sami (Southern)'),
           ('smj', 'Sami (Lule)'),
           ('smn', 'Sami (Inari)'),
           ('sms', 'Sami (Skolt)'),
           ('smi', 'Sami languages'),
           ('zxx', '(no linguistic content)');

UPDATE Languages SET code=LOWER(code);

-- ----------------------------------------------------------------------------
-- Publisher master/imprint stuff is messy, fix before trying to fix up
-- null foreign keys, etc.
-- ----------------------------------------------------------------------------

-- One publisher is listed as an imprint but with parentID of 0.  Make master.
-- This must be done before series table imprint/publisher fix and before the
-- vanished parent publisher fix (as 0 isn't vanished, just wrong).
UPDATE publishers SET Master=1 WHERE Master=0 AND ParentID=0;

-- Fix the one NULL Master value.  It has a parent, so it must not be Master.
-- Check that Master is really NULL in case this is fixed in a later dump.
UPDATE publishers SET Master=0 WHERE ID=3342 and Master is NULL;

-- Fix absurd parent and imprint IDs.
UPDATE publishers SET ParentID=NULL WHERE ParentID = 0;
UPDATE series SET imprint_id=NULL WHERE imprint_id = 0;

-- Some series have imprints as their master publishers.  Fix this.
-- No such series currently also have a valid imprint value.
UPDATE series INNER JOIN publishers ON series.PubID=publishers.ID
    SET series.PubID=publishers.ParentID, series.imprint_id=publishers.ID
    WHERE publishers.Master=0;

-- ----------------------------------------------------------------------------
-- Hook up orphaned or otherwise confused records with special parent records.
-- There are various NULL foreign keys that need fixing.
-- Make these easy to find since we don't know where they really go.
-- ----------------------------------------------------------------------------

INSERT INTO publishers (PubName, Notes, Master, YearBegan)
    VALUES ('*GCD NULL PUBLISHER',
            'Publisher for series with no publisher in the DB', 1, '0000');
INSERT INTO publishers (PubName, Notes, Master, YearBegan)
    VALUES ('*GCD VANISHED PUBLISHERS',
            'Publisher for series whose publisher is not in the DB', 1, '0000');
INSERT INTO publishers (PubName, Notes, Master, YearBegan)
    VALUES ('*GCD VANISHED PARENT PUBLISHERS',
            'Publisher for imprints whose publisher is not in the DB',
            1, '0000');
INSERT INTO series (Bk_Name, Yr_Began, LangCode, CounCode, Notes)
    VALUES ('*GCD NULL SERIES', '0000', 'en', 'us',
            'Series for issues with no series in the DB');
INSERT INTO series (Bk_Name, Yr_Began, LangCode, CounCode, Notes)
    VALUES ('*GCD VANISHED SERIES', '0000', 'en', 'us',
            'Series for issues whose series is not in the DB');
INSERT INTO series (Bk_Name, Yr_Began, LangCode, CounCode, Notes)
    VALUES ('*GCD VANISHED SERIES FOR COVERS', '0000', 'en', 'us',
            'Series for covers whose series is not in the DB');
INSERT INTO issues (issue, Notes) VALUES ('*GCD NULL ISSUE',
    'Issue for stories with no issue in the DB');
INSERT INTO issues (issue, Notes) VALUES ('*GCD VANISHED ISSUES',
    'Issue for stories whose issue is not in the DB');
INSERT INTO issues (issue, Notes) VALUES ('*GCD ORPHAN COVERS ISSUE',
    'Issue for covers with no issue in the DB');
INSERT INTO issues (issue, Notes) VALUES ('*GCD DOUBLED COVERS ISSUE',
    'Issue for covers with multiple issue matches by "issue" field in the DB');
INSERT INTO issues (issue, Notes) VALUES ('*GCD VANISHED ISS. COVERS',
    'Issue for covers whose issue is not in the DB');

UPDATE series SET PubID=
    (SELECT ID FROM publishers WHERE PubName='*GCD NULL PUBLISHER')
    WHERE PubID IS NULL;
UPDATE series SET PubID=
    (SELECT ID FROM publishers WHERE PubName='*GCD VANISHED PUBLISHERS')
    WHERE (SELECT ID FROM publishers WHERE publishers.ID=series.PubID) IS NULL;

UPDATE issues SET SeriesID=
    (SELECT ID FROM series WHERE Bk_Name='*GCD NULL SERIES')
    WHERE SeriesID IS NULL;
UPDATE issues SET SeriesID=
    (SELECT ID FROM series WHERE Bk_Name='*GCD VANISHED SERIES')
    WHERE (SELECT ID FROM series WHERE series.ID=issues.SeriesID) IS NULL;

UPDATE stories SET IssueID=
    (SELECT ID FROM issues WHERE Issue='*GCD NULL ISSUE')
    WHERE IssueID IS NULL;
UPDATE stories SET IssueID=
    (SELECT ID FROM issues WHERE Issue='*GCD VANISHED ISSUES')
    WHERE (SELECT ID FROM issues WHERE issues.ID=stories.IssueID) IS NULL;

-- ----------------------------------------------------------------------------
-- Do not get me started on the travesty that is the covers table.
-- The covers table is a mess.  Most of these statements must be in order.
-- Even after this, series ID, issue ID and issue are likely to disagree.
-- ----------------------------------------------------------------------------

-- First, do something about covers that can't be resolved to a single issue.
UPDATE covers SET IssueID=
    (SELECT ID FROM issues WHERE Issue='*GCD DOUBLED COVERS ISSUE')
    WHERE IssueID IS NULL AND
        (SELECT COUNT(*) FROM issues WHERE issues.SeriesID=covers.SeriesID AND
                                           issues.issue=covers.Issue) > 1;

-- Fix wacky double cover entry- delete the one that has no image with it.
DELETE FROM covers WHERE id=232797;

-- Next, do something about covers that don't match any issue.
UPDATE covers SET IssueID=
    (SELECT ID FROM issues WHERE Issue='*GCD ORPHAN COVERS ISSUE')
    WHERE IssueID IS NULL AND
        (SELECT COUNT(*) FROM issues WHERE issues.SeriesID=covers.SeriesID AND
                                           issues.issue=covers.Issue) < 1;
-- Series links that go nowhere.
UPDATE covers LEFT OUTER JOIN series ON covers.SeriesID = series.ID
    SET covers.SeriesID=
        (SELECT ID FROM series WHERE Bk_Name='*GCD VANISHED SERIES FOR COVERS')
    WHERE series.ID IS NULL;

-- Issue links that go nowhere.
-- Note that we do not later set covers.Issue so do it here.
UPDATE covers LEFT OUTER JOIN issues ON covers.IssueID = issues.ID
    SET covers.IssueID=
        (SELECT ID FROM issues WHERE issues.issue='*GCD VANISHED ISS. COVERS'),
        covers.Issue='*GCD VANISHED ISS. COVERS'
    WHERE issues.ID IS NULL;

-- Finally, fix the remaining, fixable keys.
UPDATE covers SET IssueID=
    (SELECT issues.ID from issues WHERE issues.SeriesID=covers.SeriesID AND
                                        issues.issue=covers.Issue)
    WHERE IssueID IS NULL;
    
-- ----------------------------------------------------------------------------
-- Cached counts will still be useful, except imprint count.
-- Imprint is a legacy concept and self-join counts can't be maintained
-- with triggers.  So leave that alone and we'll drop it later.
-- ----------------------------------------------------------------------------

-- Many of the cached counts and names are invalid, so fix all.
-- Counts are assembled bottom-up for counts that skip levels.
UPDATE issues SET storycount=
    (SELECT COUNT(*) FROM stories WHERE stories.IssueID = issues.ID);
UPDATE series SET series.Issuecount=
    (SELECT COUNT(*) FROM issues WHERE issues.SeriesID = series.ID);
UPDATE publishers SET BookCount=
    (SELECT COUNT(*) FROM series WHERE series.PubID = publishers.ID);
UPDATE publishers SET IssueCount=
    (SELECT SUM(series.Issuecount) FROM series
        WHERE series.PubID = publishers.ID);
-- Some publishers have no series and therefore the issue count ends up NULL
UPDATE publishers SET IssueCount=0 where BookCount=0;

-- ----------------------------------------------------------------------------
-- Clean up timestamps and a few other fields table by table.
-- Use 1901 as a default because it's old enough to be obviously wrong
-- but recent enough the mysql doesn't try to default it into
-- the current century (using year 1, in particular, causes this problem).
-- ----------------------------------------------------------------------------

UPDATE IndexCredit SET DateMod='1901-01-01'
    WHERE DateMod IS NULL OR DateMod = 0;
UPDATE Indexers SET DateCreated='1901-01-01'
    WHERE DateCreated IS NULL OR DateCreated = 0;
UPDATE Indexers SET DateMod='1901-01-01'
    WHERE DateMod IS NULL OR DateMod = 0;
UPDATE Reservations SET Created='1901-01-01'
    WHERE Created IS NULL OR Created = 0;

UPDATE publishers SET Modified=Created
    WHERE Created IS NOT NULL AND (Modified IS NULL OR Modified = 0);
UPDATE publishers SET Created='1901-01-01'
    WHERE Created IS NULL OR Created = 0;
UPDATE publishers SET Modified='1901-01-01'
    WHERE Modified IS NULL OR Modified = 0;

-- There should probably be some research here as there are most likely
-- dates like 189 that should be 1989, etc.
UPDATE publishers SET YearEnded=NULL
    WHERE YearEnded > 2010 OR YearEnded < YearBegan;
UPDATE publishers SET YearEnded=NULL
    WHERE YearEnded > 2010 OR YearEnded < YearBegan;

UPDATE series SET Yr_Ended=NULL
    WHERE Yr_Ended > 2010 OR Yr_Ended < Yr_Began;
UPDATE series SET Yr_Ended=NULL
    WHERE Yr_Ended > 2010 OR Yr_Ended < Yr_Began;

UPDATE series SET Created='1901-01-01'
    WHERE Created IS NULL OR Created = 0;
UPDATE series SET Modified=Created
    WHERE Modified IS NULL OR Modified = 0;
UPDATE series SET ModTime=0 WHERE ModTime IS NULL;
UPDATE series SET HasGallery=0 WHERE HasGallery IS NULL;

UPDATE issues SET created='1901-01-01'
    WHERE created IS NULL OR created = 0;
UPDATE issues SET Modified=Created
    WHERE Modified IS NULL OR Modified = 0;
UPDATE issues SET ModTime=0 WHERE ModTime IS NULL;
UPDATE issues SET IndexStatus=0 WHERE IndexStatus IS NULL;
UPDATE issues SET ReserveStatus=0 WHERE ReserveStatus IS NULL;
UPDATE issues SET VolumeNum=NULL WHERE VolumeNum = 0 AND
    Issue NOT IN ('0', '00', '0A', '0B', '0 Part A', '0 Part B') AND
    Issue NOT LIKE '0 [%]' AND Issue NOT LIKE '0/%';

UPDATE stories SET Created='1901-01-01'
    WHERE Created IS NULL OR Created = 0;
UPDATE stories SET Modified=Created
    WHERE Modified IS NULL OR Modified = 0;
UPDATE stories SET ModTime=0 WHERE ModTime IS NULL;

UPDATE covers SET Marked=0 WHERE Marked IS NULL;
UPDATE covers SET Created='1901-01-01'
    WHERE Created IS NULL OR Created = 0;
UPDATE covers SET Modified=Created
    WHERE Modified IS NULL OR Modified = 0;
UPDATE covers SET CreTime=0 WHERE CreTime IS NULL;
UPDATE covers SET ModTime=CreTime WHERE ModTime IS NULL;

-- ----------------------------------------------------------------------------
-- Type cleanup, tranlsating a few remaining Italian types that will be
-- handled by the localization code in the new UI.
-- ----------------------------------------------------------------------------

UPDATE stories SET `Type`='Insert' WHERE `Type` ='inserto';
UPDATE stories SET `Type`='Letters' WHERE `Type` ='lettere';
UPDATE stories SET `Type`='Text Story' WHERE `Type` ='Storia testuale';
UPDATE stories SET `Type`='Story' WHERE `Type` ='Storia';
UPDATE stories SET `Type`='Cover' WHERE `Type` ='Copertina';
UPDATE stories SET `Type`='Backcovers'
    WHERE `Type` = 'Copertina Posteriore';
UPDATE stories SET `Type`='Pinup' WHERE `Type` = 'Illustrazione';
UPDATE stories SET `Type`='Text Article' WHERE `Type` = 'Articolo';
UPDATE stories SET `Type`='Cover Reprint'
    WHERE `Type` = 'Copertina Interna';
UPDATE stories SET `Type`='Activity' WHERE `Type` = 'Giochi';
UPDATE stories SET `Type`='Text Story' WHERE `Type` = 'Racconto';

-- Our collation may not be case sensitive, but Python is.
UPDATE stories SET `Type`=LOWER(`Type`) WHERE `Type` IS NOT NULL;

