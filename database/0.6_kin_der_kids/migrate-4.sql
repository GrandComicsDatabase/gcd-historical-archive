ALTER TABLE oi_publisher_revision
    ADD COLUMN keywords longtext NOT NULL;
ALTER TABLE oi_brand_revision
    ADD COLUMN keywords longtext NOT NULL;
ALTER TABLE oi_indicia_publisher_revision
    ADD COLUMN keywords longtext NOT NULL;
ALTER TABLE oi_series_revision
    ADD COLUMN keywords longtext NOT NULL;
ALTER TABLE oi_issue_revision
    ADD COLUMN keywords longtext NOT NULL;
ALTER TABLE oi_story_revision
    ADD COLUMN keywords longtext NOT NULL;
