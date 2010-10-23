-- copy table so we don't modify the final dump directly
CREATE TABLE log_series (
    PRIMARY KEY (id)
) SELECT * FROM GCDOnline.LogSeries;

-- drop columns won't need for porting, add columns for shifting.
ALTER TABLE log_series
    DROP COLUMN frst_iss,
    DROP COLUMN included,
    DROP COLUMN last_iss,
    DROP COLUMN pubdates,
    DROP COLUMN actiontype,
    ADD COLUMN indexer_id int(11) default NULL,
    ADD COLUMN modified_new datetime default NULL,
    ADD COLUMN sort_old int(11) default NULL,
    ADD COLUMN sort_new int(11) default NULL,
    ADD INDEX (sort_old),
    ADD INDEX (sort_new),
    MODIFY COLUMN id bigint(11) unsigned NOT NULL auto_increment;

SET @anon=(SELECT id FROM auth_users WHERE username='auto');
SET @unknown_pub=(SELECT id FROM gcd_publisher WHERE name='(unknown)');
SET @unknown_country=(SELECT code FROM gcd_country WHERE name = '(unknown)');

-- ISO 639-2 defines a code for "undetermined" language.
INSERT INTO gcd_language (code, name) VALUES ('und', '(undetermined)');
SET @undetermined_language='und';

-- Set up the change records representing the final pre-migration state.
INSERT INTO log_series
        (Bk_Name, PubID, CounCode, LangCode, Format, Tracking, Pub_Note, Notes,
         Yr_Began, Yr_Ended, ImprintID, UserID)
    SELECT
        Bk_Name, PubID, CounCode, LangCode, Format, Tracking, Pub_Note, Notes,
        Yr_Began, Yr_Ended, imprint_id, @anon
    FROM GCDOnline.series;

-- set Ray's 2nd login to his first login
UPDATE log_series SET userid=49 WHERE userid = 299;
-- set to Anonymous User
UPDATE log_series SET userid=@anon WHERE userid IS NULL;

-- don't port series we don't know about
DELETE ls FROM log_series ls LEFT OUTER JOIN gcd_series gs ON ls.seriesid=gs.id
    WHERE ls.seriesid IS NULL;

-- set country codes to country id if known or to unknown otherwise
UPDATE log_series ls LEFT OUTER JOIN gcd_country gc ON ls.councode = gc.code
    SET councode=@unknown_country WHERE gc.code IS NULL;
    WHERE councode NOT IN (SELECT code FROM gcd_country) OR councode IS NULL;

UPDATE log_series ls INNER JOIN gcd_country gc ON ls.councode=gc.code
    SET ls.councode = gc.id;

-- set language codes to language id if known or to unknown otherwise
UPDATE log_series ls LEFT OUTER JOIN gcd_language gl ON ls.langcode = gl.code
    SET ls.langcode=@undetermined_language WHERE gl.code IS NULL;

update log_series set langcode = 146
    where langcode not in (select code from gcd_language);
update log_series set langcode = (
        select id from gcd_language where code = log_series.langcode
    ) where langcode != 146;

-- set publisher to "unknown" and imprint to null when unknown
update log_series set pubid = 6691
    where pubid not in (select id from gcd_publisher where is_master = 1);
update log_series set imprintid = null
    where imprintid not in (select id from gcd_publisher where is_master = 0);

-- misc clean up
update log_series set bk_name = "" where bk_name is null;
update log_series set format = "" where format is null;
update log_series set notes = "" where notes is null;
update log_series set pub_note = "" where pub_note is null;
update log_series set tracking = "" where tracking is null;
update log_series set yr_began = 0 where yr_began is null;

-- delete duplicate rows where it is a dupe if the "group by" columns are the same
delete log_series from log_series left outer join (
    select min(id) as id, bk_name, councode, format, langcode,
           modified, modtime, notes, pubid, pub_note, seriesid,
           tracking, yr_began, yr_ended, userid, imprintid
    from log_series
    group by bk_name, councode, format, langcode,
             notes, pubid, pub_note, seriesid,
             tracking, yr_began, yr_ended, imprintid
) as keeprows on log_series.id = keeprows.id where keeprows.id is NULL;

-- 18884 records reduced to 16481 (13% less)

-- use 2009-11-01 00:00:00 as placeholder
-- (max date in table is 2009-10-01, first new site date is 2009-12-07)
update log_series set modified = "2009-11-01" where modified is null;

