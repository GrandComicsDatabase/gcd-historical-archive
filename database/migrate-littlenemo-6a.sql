-- copy table so we don't modify the final dump directly
create table log_publisher select * from GCDOnline.LogPublishers;
-- drop columns won't need for porting
alter table log_publisher drop column connection, drop column parentid, drop column master, drop column actiontype;

-- set Ray's 2nd login to his first login
update log_publisher set userid = 49 where userid = 299;
-- set to Anonymous User
update log_publisher set userid = 249 where userid is null;
-- set to (unknown)
update log_publisher set countryid = 249 where countryid is null;
update log_publisher set countryid = 249 where countryid = 0;
-- clean up
update log_publisher set notes = "" where notes is null;
update log_publisher set web = "" where web is null;
-- don't port publishers we don't know about
delete from log_publisher where publisherid is null;
delete from log_publisher where publisherid not in (select id from gcd_publisher);
-- don't port imprint changes
delete from log_publisher where publisherid in (select id from gcd_publisher where is_master = 0);

-- delete duplicate rows where it is a dupe if the "group by" columns are the same
delete log_publisher from log_publisher left outer join (
   select min(id) as id,pubname,notes,yearbegan,yearended,countryid,modified,modifiedtime,userid,publisherid,web 
   from log_publisher group by pubname,notes,yearbegan,yearended,countryid,publisherid,web
) as keeprows on log_publisher.id = keeprows.id where keeprows.id is NULL;

-- 1865 records reduced to 823 (56% less)

-- use 2009-11-01 00:00:00 as placeholder
update log_publisher set modified = "2009-11-01" where modified is null;
-- update a few times manually where some publishers had a mix of records with dates and times and some without.
-- publishers with only null dates and times will be handled in the python script
update log_publisher set modifiedtime = "00:00:00" where id in (1865,1870,1872,1875,1876,1877,161,1359,1590,1315);
update log_publisher set modifiedtime = "00:00:01" where id in (1360,1164);
update log_publisher set modifiedtime = "00:00:02" where id in (1361);

-- now run apps/gcd/migration/history_publisher and then littlenemo-7.sql