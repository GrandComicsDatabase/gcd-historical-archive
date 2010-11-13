SET SESSION sql_mode='STRICT_ALL_TABLES';

ALTER DATABASE CHARACTER SET utf8;

-- Convert tables to utf8, add flag columns, drop useles columns and indices.

ALTER TABLE Countries CONVERT TO CHARACTER SET utf8;
ALTER TABLE Languages CONVERT TO CHARACTER SET utf8;

ALTER TABLE publishers
    DROP COLUMN Connection,
    DROP COLUMN NextID,
    DROP COLUMN Updated,
    DROP COLUMN AlphaSortCode,
    CONVERT TO CHARACTER SET utf8;

ALTER TABLE series
    DROP COLUMN Crossref,
    DROP COLUMN CrossrefID,
    DROP COLUMN `File`,
    DROP COLUMN InitDist,
    DROP COLUMN Included,
    DROP COLUMN Indexers,
    DROP COLUMN LstChang,
    DROP COLUMN oldID,
    DROP COLUMN SelfCount,
    DROP COLUMN Themes,
    DROP COLUMN UpdateDist,
    ADD INDEX (LangCode),
    CONVERT TO CHARACTER SET utf8;

ALTER TABLE issues
    DROP COLUMN Char_App,
    DROP COLUMN Colors,
    DROP COLUMN CoverCheck,
    DROP COLUMN CoverCount,
    DROP COLUMN Feature,
    DROP COLUMN Editing,
    DROP COLUMN Genre,
    DROP COLUMN InitDist,
    DROP COLUMN Inks,
    DROP COLUMN isUpdated,
    DROP COLUMN Letters,
    DROP COLUMN LstChang,
    DROP COLUMN Notes,
    DROP COLUMN Pencils,
    DROP COLUMN Pg_Cnt,
    DROP COLUMN rel_year,
    DROP COLUMN Reprints,
    DROP COLUMN Seq_No,
    DROP COLUMN Script,
    DROP COLUMN SelfCount,
    DROP COLUMN Synopsis,
    DROP COLUMN SeriesLink,
    DROP COLUMN Title,
    DROP COLUMN `Type`,
    DROP COLUMN UpdateDist,
    ADD INDEX (Issue),
    ADD INDEX (VolumeNum),
    ADD INDEX (Modified),
    CONVERT TO CHARACTER SET utf8;

ALTER TABLE stories
    DROP COLUMN rel_year,
    DROP COLUMN LstChang,
    DROP COLUMN InitDist,
    DROP COLUMN IssueCount,
    DROP COLUMN Key_Date,
    DROP COLUMN Pub_Date,
    DROP COLUMN Price,
    DROP COLUMN SeriesID,
    DROP COLUMN Issue,
    DROP COLUMN Yr_Began,
    DROP COLUMN Bk_Name,
    DROP COLUMN Pub_Name,
    DROP INDEX Script,
    DROP INDEX Pencils,
    DROP INDEX Inks,
    DROP INDEX Colors,
    DROP INDEX Letters,
    DROP INDEX Editing,
    DROP INDEX Char_App,
    ADD COLUMN no_script tinyint(1) NOT NULL default 0,
    ADD COLUMN no_pencils tinyint(1) NOT NULL default 0,
    ADD COLUMN no_inks tinyint(1) NOT NULL default 0,
    ADD COLUMN no_colors tinyint(1) NOT NULL default 0,
    ADD COLUMN no_letters tinyint(1) NOT NULL default 0,
    ADD COLUMN page_count_uncertain tinyint(1) NOT NULL default 0,
    ADD INDEX (`type`),
    ADD INDEX (no_script),
    ADD INDEX (no_pencils),
    ADD INDEX (no_inks),
    ADD INDEX (no_colors),
    ADD INDEX (no_letters),
    ADD INDEX (Pg_Cnt),
    ADD INDEX (page_count_uncertain),
    CONVERT TO CHARACTER SET utf8;

ALTER TABLE covers CONVERT TO CHARACTER SET utf8;
ALTER TABLE Reservations CONVERT TO CHARACTER SET utf8;
ALTER TABLE Indexers CONVERT TO CHARACTER SET utf8;
ALTER TABLE IndexCredit CONVERT TO CHARACTER SET utf8;

UPDATE stories SET script='', no_script=1 WHERE script IN (
    'none',  -- English
    'ingen', -- Swedish
    'ninguno', -- Spanish
    'nessuno', -- Italian
    'nul', 'null', 'ne null', -- French
    'geen', -- Dutch
    'n', 'n a', 'n/a', 'na', 'no',
    '[n/a]', '[none]',
    'noen', 'non', 'nonde', 'nonen', 'nonoe',
    'nonr', 'nonw'
);
UPDATE stories SET script='', no_script=1
    WHERE type IN ('cover', 'cover reprint', 'pinup') AND
        (script IS NULL OR script = '');
UPDATE stories SET script='?'
    WHERE no_script = 0 AND script IN ('unknown', '[unknown]');
UPDATE stories SET script='?'
    WHERE no_script = 0 AND (script IS NULL OR script = '')
                        AND `type` = 'story';

UPDATE stories SET pencils='', no_pencils=1 WHERE pencils IN (
    'none',  -- English
    'ingen', -- Swedish
    'ninguno', -- Spanish
    'nessuno', -- Italian
    'nul', 'null', 'ne null', -- French
    'geen', -- Dutch
    'n', 'n a', 'n/a', 'na', 'no', 'no text',
    '[n/a]', '[none]',
    'no art',
    'noen', 'non', 'nonde', 'nonen', 'nonoe',
    'nonr', 'nonw'
);
UPDATE stories SET pencils='?'
    WHERE no_pencils = 0 AND 
        pencils IN ('[no credits]', 'unknown', '[unknown]');
UPDATE stories SET pencils='?'
    WHERE no_pencils = 0 AND (pencils IS NULL OR pencils = '') AND
        `type` IN ('cover', 'story', 'cover reprint', 'pinup');

UPDATE stories SET inks='', no_inks=1 WHERE inks IN (
    'none',  -- English
    'ingen', -- Swedish
    'ninguno', -- Spanish
    'nessuno', -- Italian
    'nul', 'null', 'ne null', -- French
    'geen', -- Dutch
    'n', 'n a', 'n/a', 'na', 'no', 'no text',
    '[n/a]', '[none]',
    '[no inker]',
    'noen', 'non', 'nonde', 'nonen', 'nonoe',
    'nonr', 'nonw'
);
UPDATE stories SET inks='?'
    WHERE no_inks = 0 AND 
        inks IN ('unknown', '[unknown]');
UPDATE stories SET inks='?'
    WHERE no_inks = 0 AND (inks IS NULL OR inks = '') AND
        `type` IN ('cover', 'story', 'cover reprint', 'pinup');

UPDATE stories SET colors='', no_colors=1 WHERE colors IN (
    'none',  -- English
    'ingen', -- Swedish
    'ninguno', -- Spanish
    'nessuno', -- Italian
    'nul', 'null', 'ne null', -- French
    'geen', -- Dutch
    'n', 'n a', 'n/a', 'na', 'no', 'no text',
    '[n/a]', '[none]',
    'noen', 'non', 'nonde', 'nonen', 'nonoe',
    'nonr', 'nonw'
);
UPDATE stories SET colors='?'
    WHERE no_colors = 0 AND 
        colors IN ('unknown', '[unknown]');
UPDATE stories SET colors='?'
    WHERE no_colors = 0 AND (colors IS NULL OR colors = '') AND
        `type` IN ('cover', 'story', 'cover reprint', 'pinup');

UPDATE stories SET letters='', no_letters=1 WHERE letters IN (
    'none',  -- English
    'ingen', -- Swedish
    'ninguno', -- Spanish
    'nessuno', -- Italian
    'nul', 'null', 'ne null', -- French
    'geen', -- Dutch
    'n', 'n a', 'n/a', 'na', 'no', 'no text',
    '[n/a]', '[none]',
    'noen', 'non', 'nonde', 'nonen', 'nonoe',
    'nonr', 'nonw'
);
UPDATE stories SET letters='', no_letters=1
    WHERE type IN ('cover', 'cover reprint', 'pinup') AND
        (letters IS NULL OR letters = '') AND no_script = 1;
UPDATE stories SET letters='?'
    WHERE no_letters = 0 AND 
        letters IN ('unknown', '[unknown]');
UPDATE stories SET letters='?'
    WHERE no_letters = 0 AND no_script = 0 AND (letters IS NULL OR letters = '') AND
        `type` IN ('cover', 'story', 'cover reprint', 'pinup');

UPDATE stories SET editing='?' WHERE editing IN ('unknown', '[unknown]');

UPDATE stories SET Pg_Cnt=NULL WHERE Pg_Cnt IN ('?', 'unknown', '');
UPDATE stories SET Pg_Cnt=0 WHERE Pg_Cnt IN ('none', 'n/a');
UPDATE stories SET Pg_Cnt=REPLACE(Pg_Cnt, ',', '.') WHERE Pg_Cnt LIKE ('%,%');
UPDATE stories SET page_count_uncertain=1,
                   Pg_Cnt=TRIM(TRAILING '?' FROM Pg_Cnt)
    WHERE Pg_Cnt LIKE '_%?';
UPDATE stories SET Pg_Cnt=TRIM(Pg_Cnt);
UPDATE stories SET Pg_Cnt='0.5' WHERE Pg_Cnt = '1/2';
UPDATE stories SET Pg_Cnt='20' WHERE Pg_Cnt = '[20]';

