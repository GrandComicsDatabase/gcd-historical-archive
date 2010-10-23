-- copy table so we don't modify the final dump directly
create table log_series select * from GCDOnline.LogSeries;
-- drop columns won't need for porting
alter table log_series drop column frst_iss, drop column included, drop column last_iss, drop column pubdates, drop column actiontype;

-- set Ray's 2nd login to his first login
update log_series set userid = 49 where userid = 299;
-- set to Anonymous User
update log_series set userid = 249 where userid is null;
-- don't port series we don't know about
delete from log_series where seriesid is null;
delete from log_series where seriesid not in (select id from gcd_series);
-- set country codes to country id if known or to unknown otherwise
update log_series set councode = 249 where councode is null;
update log_series set councode = 249 where councode not in (select code from gcd_country);
update log_series set councode = (select id from gcd_country where code = log_series.councode) where councode != 249;
-- set language codes to language id if known or to unknown otherwise
insert into gcd_language (id, code, name) values (146, "zzz", "(unknown)");
update log_series set langcode = 146 where langcode is null;
update log_series set langcode = 146 where langcode not in (select code from gcd_language);
update log_series set langcode = (select id from gcd_language where code = log_series.langcode) where langcode != 146;
-- set publisher to "unknown" and imprint to null when unknown
update log_series set pubid = 6691 where pubid not in (select id from gcd_publisher where is_master = 1);
update log_series set imprintid = null where imprintid not in (select id from gcd_publisher where is_master = 0);
-- misc clean up
update log_series set bk_name = "" where bk_name is null;
update log_series set format = "" where format is null;
update log_series set notes = "" where notes is null;
update log_series set pub_note = "" where pub_note is null;
update log_series set tracking = "" where tracking is null;
update log_series set yr_began = 0 where yr_began is null;

-- delete duplicate rows where it is a dupe if the "group by" columns are the same
delete log_series from log_series left outer join (
   select min(id) as id, bk_name, councode, format, langcode, modified, modtime, notes, pubid, pub_note, seriesid, tracking, yr_began, yr_ended, userid, imprintid
   from log_series group by bk_name, councode, format, langcode, notes, pubid, pub_note, seriesid, tracking, yr_began, yr_ended, imprintid
) as keeprows on log_series.id = keeprows.id where keeprows.id is NULL;

-- 18884 records reduced to 16481 (13% less)

-- use 2009-11-01 00:00:00 as placeholder (max date in table is 2009-10-01, first new site date is 2009-12-07)
update log_series set modified = "2009-11-01" where modified is null;

-- now run apps/gcd/migration/history_series and then littlenemo-7.sql