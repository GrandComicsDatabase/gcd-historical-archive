SET SESSION sql_mode='STRICT_ALL_TABLES';

ALTER TABLE oi_changeset_comment
    ADD COLUMN content_type_id integer default NULL AFTER changeset_id,
    ADD COLUMN revision_id integer default NULL AFTER content_type_id,
    ADD INDEX (content_type_id),
    ADD FOREIGN KEY (content_type_id) REFERENCES django_content_type (id);

