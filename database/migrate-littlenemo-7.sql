-- littlenemo-6a.sql and apps/gcd/migration/history_publisher.py must be run first
-- updates all the old site cover changesets as well
update oi_changeset set modified = created where created < "2009-12-07";
-- updates all the new site cover changesets before they were added to the OI
update oi_changeset set modified = created where change_type = 7 and approver_id = 381;
update oi_publisher_revision set modified = created where created < "2009-12-07";
drop table log_publisher;


-- littlenemo-6b.sql and apps/gcd/migration/history_series.py must be run first
-- updates all the old site cover changesets as well
update oi_changeset set modified = created where created < "2009-12-07";
update oi_series_revision set modified = created where created < "2009-12-07";
drop table log_series;