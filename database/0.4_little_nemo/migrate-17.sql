-- Allow us to mark migrated changesets and revisions as having inferred dates.
-- Note that brand and indicia publisher revisions are never migrated and therefore
-- do not need this column.

ALTER TABLE oi_changeset
    ADD COLUMN date_inferred tinyint(1) NOT NULL default 0;

ALTER TABLE oi_publisher_revision
    ADD COLUMN date_inferred tinyint(1) NOT NULL default 0;

ALTER TABLE oi_series_revision
    ADD COLUMN date_inferred tinyint(1) NOT NULL default 0;

ALTER TABLE oi_issue_revision
    ADD COLUMN date_inferred tinyint(1) NOT NULL default 0;

ALTER TABLE oi_story_revision
    ADD COLUMN date_inferred tinyint(1) NOT NULL default 0;

