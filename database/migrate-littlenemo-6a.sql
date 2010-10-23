-- copy table so we don't modify the final dump directly
create table log_publisher (primary key (id)) engine=MyISAM
    select * from GCDOnline.LogPublishers;

-- drop columns won't need for porting
alter table log_publisher drop column connection,
                          drop column parentid,
                          drop column master,
                          drop column actiontype,
                          add column sort_old int(11) default null,
                          add column sort_new int(11) default null,
                          add column userid_new int(11) default null,
                          add column modified_new date default null,
                          add column modifiedtime_new time default null,
                          add index (sort_old),
                          add index (sort_new),
                          modify column id bigint(11) unsigned NOT NULL
                            auto_increment;

-- set Ray's 2nd login to his first login
update log_publisher set userid = 49 where userid = 299;
-- set to Anonymous User
update log_publisher set userid = 249 where userid is null;

-- set to (unknown)
update log_publisher set countryid = 249 where countryid is null;
update log_publisher set countryid = 249 where countryid = 0;

-- clean up
update log_publisher set notes = '' where notes is null;
update log_publisher set web = '' where web is null;

-- Set up the change records representing the final pre-migration state.
SET @anon=(SELECT id FROM auth_user WHERE username='anon');
INSERT INTO log_publisher
        (PubName, Notes, YearBegan, YearEnded, CountryID, Web, UserID, PublisherID)
    SELECT 
        PubName, Notes, YearBegan, YearEnded, CountryID, Web, @anon, ID
    FROM GCDOnline.publishers;

-- don't port publishers we don't know about, and don't port imprint changes
-- Do this after adding current state to make sure we don't re-import junk
-- that was cleaned up by the data migration.
DELETE lp FROM log_publisher lp LEFT OUTER JOIN
               gcd_publisher gp ON lp.publisherid = gp.id
    WHERE gp.id IS NULL OR gp.is_master = 0;

-- Anything that's left is potentially a useful row, so now adjust the user IDs
-- and timestamps to make these new-value rows instead of old-value rows.
-- The idea here is to give each row two counters that capture the off-by-one-ness
-- of the current situation.  Currently, we have the oldest possible value
-- (version 0) of an object associated with the user and time of version 1.
-- So we set the old counter to 1 for that object and the new counter to 0.
-- Then we do a self-join setting those two counters equal to each other, and
-- assign the userid and times from the old side of the join to the new side.
-- For version 0, there is a new side (new counter 0) but no old side
-- (old counter 0) because we do not know who added the object.
-- For the last version Z, there is an old side (old counter Z+1) but no new
-- side.  This is OK because this last version was inserted directly from
-- the final state of the display tables with the anonymous user and a time
-- of the server migration.  These placeholder users and times are correctly
-- discarded.

SET @sort_old=1;
SET @sort_new=0;
UPDATE log_publisher SET sort_old=@sort_old:=@sort_old + 1,
                         sort_new=@sort_new:=@sort_new + 1
    ORDER BY publisherid, id;

-- Left join with this table order because we want the pairing where the new
-- counter is smallest to be absent, as there is nothing from which to assign
-- it a new user and times.  We will set it to anon and a suitably old placeholder
-- in a separate step later.
UPDATE log_publisher new LEFT OUTER JOIN log_publisher old
    ON old.sort_old=new.sort_new
    SET new.userid_new=old.userid,
        new.modified_new=old.modified,
        new.modifiedtime_new=old.modifiedtime
    WHERE old.publisherid=new.publisherid;

-- Now reverse the direction of the join and look for either the actual zero row,
-- for which the old side will be NULL, or mismatches in source ids, in which case
-- the old side will be the previous publisher and the new side will be the zero row
-- of the next publisher.
SET @first_day='1901-01-01';
SET @first_time='00:00:00';
UPDATE log_publisher old LEFT OUTER JOIN log_publisher new
    ON old.sort_old=new.sort_new
    SET new.userid_new=@anon,
        new.modified_new=@first_day,
        new.modifiedtime_new=@first_time
    WHERE old.publisherid != new.publisherid OR old.publisherid IS NULL;

-- delete duplicate rows where it is a dupe if the "group by" columns are the same
CREATE TABLE publisher_helper (id int(11) PRIMARY KEY)
    SELECT MIN(id) as id FROM log_publisher
    GROUP BY pubname, notes, yearbegan, yearended, countryid, publisherid, web;

DELETE lp FROM log_publisher lp LEFT OUTER JOIN publisher_helper ph ON lp.id=ph.id
    WHERE ph.id IS NULL;

-- 1865 records reduced to 823 (56% less)

-- use 2009-11-01 00:00:00 as placeholder
update log_publisher set modified = "2009-11-01" where modified is null;

-- update a few times manually where some publishers had a mix of records
-- with dates and times and some without.
-- publishers with only null dates and times will be handled in the python script
update log_publisher set modifiedtime = "00:00:00"
    where id in (1865,1870,1872,1875,1876,1877,161,1359,1590,1315);
update log_publisher set modifiedtime = "00:00:01" where id in (1360,1164);
update log_publisher set modifiedtime = "00:00:02" where id in (1361);

