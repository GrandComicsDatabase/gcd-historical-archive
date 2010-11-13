-- copy table so we don't modify the final dump directly
create table log_stories select * from GCDOnline.LogStories;
-- drop columns won't need for porting
alter table log_stories drop column actiontype;

-- set type codes to type id if known or to unknown otherwise
insert into gcd_story_type (id, name, sort_code) values (23, "(unknown)", 23);
update log_stories set type = 1 where type  = "activity";
update log_stories set type = 2 where type in ("advertisement", "ad");
update log_stories set type = 3 where type in ("backcovers", "backcover", "back cover");
update log_stories set type = 4 where type in ("biography", "bio");
update log_stories set type = 5 where type in ("cartoon", "cartoons");
update log_stories set type = 6 where type in ("cover", "front cover");
update log_stories set type = 7 where type in ("cover reprint", "cover reprints");
update log_stories set type = 8 where type = "credits";
update log_stories set type = 9 where type = "filler";
update log_stories set type = 10 where type in ("foreword", "foreward", "intro", "introduction");
update log_stories set type = 11 where type in ("insert", "dust jacket");
update log_stories set type = 12 where type in ("letter", "letter page", "letters page", "letters");
update log_stories set type = 13 where type = "photo story";
update log_stories set type = 14 where type in ("pinup", "illustration", "illustrations", "pin-up", "pin up");
update log_stories set type = 15 where type = "profile";
update log_stories set type = 16 where type in ("promo", "house ad", "house ads");
update log_stories set type = 17 where type in ("psa", "public service");
update log_stories set type = 18 where type = "recap";
update log_stories set type = 19 where type = "story";
update log_stories set type = 20 where type = "text article";
update log_stories set type = 21 where type = "text story";
update log_stories set type = 22 where type = "statement of ownership";
update log_stories set type = 23 where type not in (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22);
update log_stories set type = 23 where type is null;


-- set Ray's 2nd login to his first login
update log_stories set userid = 49 where userid = 299;
-- set to Anonymous User
update log_stories set userid = 249 where userid is null;
-- don't port stories we don't know about
delete from log_stories where storyid is null;
delete from log_stories where storyid not in (select id from gcd_story);
delete from log_stories where issueid not in (select id from gcd_issue);

-- create second table with duplicates removed
create table log_stories2 ( `id` bigint(11) unsigned NOT NULL DEFAULT '0',
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
  `type` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `userid` int(11) DEFAULT NULL,
  `jobno` varchar(25) CHARACTER SET latin1 DEFAULT NULL );

insert into log_stories2 select min(id) as id, char_app, colors, editing, feature, genre, inks, issueid, letters, modified, modtime, notes, pencils, pg_cnt, reprints, script, seq_no, storyid, synopsis, title, type, userid, jobno
 from log_stories group by char_app, colors, editing, feature, genre, inks, issueid, letters, notes, pencils, pg_cnt, reprints, script, seq_no, storyid, synopsis, title, type, jobno;

-- 768106 records reduced to 689091 (10% less)

-- use 2009-11-01 00:00:00 as placeholder (max date in table is 2009-10-01, first new site date is 2009-12-07)
update log_stories2 set modified = "2009-11-01" where modified is null;

-- now run apps/gcd/migration/history_stories and then littlenemo-7.sql