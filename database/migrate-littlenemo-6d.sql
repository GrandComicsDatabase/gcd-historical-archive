-- copy table so we don't modify the final dump directly
CREATE TABLE log_stories (
    PRIMARY KEY (id)
) ENGINE=MyISAM SELECT * FROM GCDOnline.LogStories;

-- drop columns won't need for porting, add type_id with correct new type.
ALTER TABLE log_stories DROP COLUMN actiontype,
                        ADD COLUMN type_id int(11) default NULL;

SET @backcovers=(SELECT id FROM gcd_story_type
    WHERE name = '(backcovers) *do not use* / *please fix*');
SET @activity=(SELECT id FROM gcd_story_type WHERE name = 'activity');
SET @advertisement=(SELECT id FROM gcd_story_type WHERE name = 'advertisement');
SET @biography=(SELECT id FROM gcd_story_type
    WHERE name = 'biography (nonfictional)');
SET @cartoon=(SELECT id FROM gcd_story_type WHERE name = 'cartoon');
SET @character=(SELECT id FROM gcd_story_type WHERE name = 'character profile');
SET @cover=(SELECT id FROM gcd_story_type WHERE name = 'cover');
SET @cover_reprint=(SELECT id FROM gcd_story_type
    WHERE name = 'cover reprint (on interior page)');
SET @credits=(SELECT id FROM gcd_story_type WHERE name = 'credits');
SET @filler=(SELECT id FROM gcd_story_type WHERE name = 'filler');
SET @foreword=(SELECT id FROM gcd_story_type
    WHERE name = 'foreword, introduction, preface, afterword');
SET @illustration=(SELECT id FROM gcd_story_type WHERE name = 'illustration');
SET @insert=(SELECT id FROM gcd_story_type WHERE name = 'insert or dust jacket');
SET @letters=(SELECT id FROM gcd_story_type WHERE name = 'letters page');
SET @photo=(SELECT id FROM gcd_story_type WHERE name = 'photo story');
SET @promo=(SELECT id FROM gcd_story_type
    WHERE name = 'promo (ad from the publisher)');
SET @public=(SELECT id FROM gcd_story_type
    WHERE name = 'public service announcement');
SET @recap=(SELECT id FROM gcd_story_type WHERE name = 'recap');
SET @statement=(SELECT id FROM gcd_story_type
    WHERE name = 'statement of ownership');
SET @story=(SELECT id FROM gcd_story_type WHERE name = 'story');
SET @text_article=(SELECT id FROM gcd_story_type WHERE name = 'text article');
SET @text_story=(SELECT id FROM gcd_story_type WHERE name = 'text story');
SET @unknown=(SELECT id FROM gcd_story_type WHERE name = '(unknown)');

-- set type codes to type id if known or to unknown otherwise
INSERT INTO gcd_story_type (id, name, sort_code) VALUES (23, "(unknown)", 23);
UPDATE log_stories SET type_id=@activity WHERE type  = "activity";
UPDATE log_stories SET type_id=@advertisement WHERE type IN ("advertisement", "ad");
UPDATE log_stories SET type_id=@backcovers
    WHERE type_id IN ("backcovers", "backcover", "back cover");
UPDATE log_stories SET type_id=@biography WHERE type IN ("biography", "bio");
UPDATE log_stories SET type_id=@cartoon WHERE type IN ("cartoon", "cartoons");
UPDATE log_stories SET type_id=@cover WHERE type IN ("cover", "front cover");
UPDATE log_stories SET type_id=@cover_reprint
    WHERE type_id IN ("cover reprint", "cover reprints");
UPDATE log_stories SET type_id=@credits WHERE type = "credits";
UPDATE log_stories SET type_id=@filler WHERE type = "filler";
UPDATE log_stories SET type_id=@foreword
    WHERE type_id IN ("foreword", "foreward", "intro", "introduction");
UPDATE log_stories SET type_id=@insert WHERE type IN ("insert", "dust jacket");
UPDATE log_stories SET type_id=@letters
    WHERE type_id IN ("letter", "letter page", "letters page", "letters");
UPDATE log_stories SET type_id=@photo WHERE type = "photo story";
UPDATE log_stories SET type_id=@illustration
    WHERE type_id IN ("pinup", "illustration", "illustrations", "pin-up", "pin up");
UPDATE log_stories SET type_id=@profile WHERE type = "profile";
UPDATE log_stories SET type_id=@promo
    WHERE type_id IN ("promo", "house ad", "house ads");
UPDATE log_stories SET type_id=@public WHERE type IN ("psa", "public service");
UPDATE log_stories SET type_id=@recap WHERE type = "recap";
UPDATE log_stories SET type_id=@story WHERE type = "story";
UPDATE log_stories SET type_id=@text_article WHERE type = "text article";
UPDATE log_stories SET type_id=@text_story WHERE type = "text story";
UPDATE log_stories SET type_id=@statement WHERE type = "statement of ownership";
UPDATE log_stories SET type_id=@unknown WHERE type_id IS NULL;

-- set Ray's 2nd login to his first login
UPDATE log_stories set userid = 49 WHERE userid = 299;
-- set to Anonymous User
UPDATE log_stories set userid = 249 WHERE userid is null;
-- don't port stories we don't know about
DELETE FROM log_stories WHERE storyid IS null;
DELETE ls FROM log_stories ls LEFT OUTER JOIN gcd_story gs ON ls.storyid=gs.id
    WHERE gs.id IS NULL;
DELETE ls FROM log_stories ls LEFT OUTER JOIN gcd_issue gi ON ls.issueid=gs.id
    WHERE gi.id IS NULL;

-- create second table with duplicates removed
CREATE TABLE log_stories2 (
  `id` bigint(11) unsigned NOT NULL DEFAULT '0',
  `char_app` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `colors` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `editing` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `feature` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `genre` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `inks` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `issueid` int(11) DEFAULT NULL,
  `letters` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `modified` date DEFAULT NULL,
  `modtime` time DEFAULT NULL,
  `notes` text CHARACTER SET latin1,
  `pencils` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `pg_cnt` int(11) DEFAULT NULL,
  `reprints` text CHARACTER SET latin1,
  `script` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `seq_no` int(11) DEFAULT NULL,
  `storyid` bigint(11) DEFAULT NULL,
  `synopsis` text CHARACTER SET latin1,
  `title` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `type_id` int(11) NOT NULL,
  `userid` int(11) DEFAULT NULL,
  `jobno` varchar(25) CHARACTER SET latin1 DEFAULT NULL
) ENGINE=MyISAM;

INSERT INTO log_stories2
    SELECT MIN(id) AS id, char_app, colors, editing, feature, genre, inks,
           issueid, letters, modified, modtime, notes, pencils, pg_cnt, reprints,
           script, seq_no, storyid, synopsis, title, type, userid, jobno
    FROM log_stories
    GROUP BY char_app, colors, editing, feature, genre, inks,
             issueid, letters, notes, pencils, pg_cnt, reprints,
             script, seq_no, storyid, synopsis, title, type, jobno;

ALTER TABLE log_stories2 CONVERT TO CHARACTER SET utf8;

-- 768106 records reduced to 689091 (10% less)

-- use 2009-11-01 00:00:00 as placeholder
-- (max date in table is 2009-10-01, first new site date is 2009-12-07)
UPDATE log_stories2 set modified = "2009-11-01" WHERE modified is null;

