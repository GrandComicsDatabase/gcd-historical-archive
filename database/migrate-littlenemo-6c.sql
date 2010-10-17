-- copy table so we don't modify the final dump directly
create table log_issues select * from GCDOnline.LogIssues;
-- drop columns won't need for porting
alter table log_issues drop column ip, drop column actiontype;

-- set Ray's 2nd login to his first login
update log_issues set userid = 49 where userid = 299;
-- set to Anonymous User
update log_issues set userid = 249 where userid is null;
-- don't port issues we don't know about
delete from log_issues where issueid is null;
delete from log_issues where issueid not in (select id from gcd_issue);
-- i don't even want to know what these are
delete from log_issues where seriesid not in (select id from gcd_series);
-- misc clean up
update log_issues set pub_date = "" where pub_date is null;
update log_issues set key_date = "" where key_date is null;
update log_issues set price = "" where price is null;

-- create second table with duplicates removed
create table log_issues2 ( `id` bigint(11) unsigned NOT NULL DEFAULT '0',
  `volumenum` int(11) DEFAULT NULL, `seriesid` int(11) DEFAULT NULL,
  `pub_date` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `price` varchar(25) CHARACTER SET latin1 DEFAULT NULL,
  `modified` date DEFAULT NULL, `modtime` time DEFAULT NULL,
  `key_date` varchar(10) CHARACTER SET latin1 DEFAULT NULL,
  `issue` varchar(25) CHARACTER SET latin1 DEFAULT NULL,
  `issueid` bigint(20) DEFAULT NULL, `userid` int(11) DEFAULT NULL );

insert into log_issues2 select min(id) as id, volumenum, seriesid, pub_date, price, modified, modtime, key_date, issue, issueid, userid
 from log_issues group by volumenum, seriesid, pub_date, price, key_date, issue, issueid;

-- 193953 records reduced to 155241 (20% less)

-- use 2009-11-01 00:00:00 as placeholder (max date in table is 2009-10-01, first new site date is 2009-12-07)
update log_issues2 set modified = "2009-11-01" where modified is null;

-- now run apps/gcd/migration/history_issues and then littlenemo-7.sql