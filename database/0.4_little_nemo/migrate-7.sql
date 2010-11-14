-- updates all the new site cover changesets before they were added to the OI
update oi_changeset set modified = created where change_type = 7 and approver_id = 381;
