-- Add a migrated flag to find automatically migrated changes in case we
-- discover errors and have to re-migrate or adjust these changes in the future.
-- Also remove unused indexes on revision tables.

ALTER TABLE oi_changeset
    ADD COLUMN migrated tinyint(1) NOT NULL default 0,
    ADD INDEX (migrated);

ALTER TABLE oi_story_revision
    DROP INDEX oi_story_revision_title_inferred;

ALTER TABLE oi_issue_revision
    DROP INDEX no_brand;

ALTER TABLE oi_publisher_revision
    DROP INDEX oi_publisher_revision_name,
    DROP INDEX oi_publisher_revision_year_began;

ALTER TABLE oi_indicia_publisher_revision
    DROP INDEX oi_indicia_publisher_revision_name,
    DROP INDEX oi_indicia_publisher_revision_year_began,
    DROP INDEX oi_indicia_publisher_revision_is_surrogate;

ALTER TABLE oi_brand_revision
    DROP INDEX oi_brand_revision_name,
    DROP INDEX oi_brand_revision_year_began;

