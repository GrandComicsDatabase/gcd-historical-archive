-- Fix inexplicable disappearance of auth and admin foreign keys.
ALTER TABLE auth_group_permissions
    ADD KEY (`group_id`),
    ADD FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`),
    ADD FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`);

ALTER TABLE auth_message
    ADD FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`);

ALTER TABLE auth_permission
    ADD FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`);

ALTER TABLE auth_user_groups
    ADD KEY (`user_id`),
    ADD FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`),
    ADD FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`);

ALTER TABLE auth_user_user_permissions
    ADD KEY (`user_id`),
    ADD FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`),
    ADD FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`);

ALTER TABLE django_admin_log
    ADD FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`),
    ADD FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`);

-- Key added in a more recent version of Django.
ALTER TABLE django_session
    ADD KEY (`expire_date`);

-- Make is_new and is_banned match their boolean type, not be int(11).
ALTER TABLE gcd_indexer
    MODIFY is_new tinyint(1) NOT NULL,
    MODIFY is_banned tinyint(1) NOT NULL;

-- Remove the Classification table and all references.
ALTER TABLE oi_series_revision
    DROP FOREIGN KEY `oi_series_revision_ibfk_1`,
    DROP COLUMN classification_id;
ALTER TABLE gcd_series
    DROP FOREIGN KEY `gcd_series_ibfk_7`,
    DROP COLUMN classification_id;
DROP TABLE gcd_classification;

-- Do all of the engine conversions so the restored foreign keys work on both ends.
ALTER TABLE gcd_error ENGINE=InnoDB,
    CONVERT TO CHARACTER SET utf8;
ALTER TABLE gcd_image ENGINE=InnoDB,
    CONVERT TO CHARACTER SET utf8;
ALTER TABLE gcd_image_type ENGINE=InnoDB,
    CONVERT TO CHARACTER SET utf8;

-- Restore foreign keys dropped by MyISAM.
ALTER TABLE gcd_image
    ADD FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`),
    ADD FOREIGN KEY (`type_id`) REFERENCES `gcd_image_type` (`id`);

-- Fix various key and DEFAULT NULL vs NOT NULL issues.
-- Dropping a key is always beacuse it appears as both a key on the column
-- and a unique key on that same single column.
-- The three publisher tables are generated from the same code and
-- therefore have the same fix, so are grouped out of alphabetical order.
ALTER TABLE gcd_brand
    MODIFY notes longtext NOT NULL,
    MODIFY url varchar(255) NOT NULL;
ALTER TABLE gcd_indicia_publisher
    MODIFY notes longtext NOT NULL,
    MODIFY url varchar(255) NOT NULL;
ALTER TABLE gcd_publisher
    MODIFY notes longtext NOT NULL,
    MODIFY url varchar(255) NOT NULL;

ALTER TABLE gcd_count_stats
    MODIFY count int(11) NOT NULL;

ALTER TABLE gcd_country
    DROP KEY code;

ALTER TABLE gcd_cover
    MODIFY created datetime NOT NULL,
    MODIFY modified datetime NOT NULL,
    CONVERT TO CHARACTER SET utf8;

ALTER TABLE gcd_indexer
    ADD KEY (`notify_on_approve`),
    ADD KEY (`collapse_compare_view`),
    ADD KEY (`show_wiki_links`),
    DROP KEY user_id,
    ADD UNIQUE KEY (`user_id`);

ALTER TABLE gcd_indexer_languages
    ADD UNIQUE KEY (`indexer_id`, `language_id`);

-- Fix some nulls, make sort_code unsigned for consistency.
ALTER TABLE gcd_issue
    MODIFY publication_date varchar(255) NOT NULL,
    MODIFY key_date varchar(10) NOT NULL,
    MODIFY on_sale_date varchar(10) NOT NULL,
    MODIFY price varchar(255) NOT NULL,
    MODIFY indicia_pub_not_printed tinyint(1) NOT NULL,
    MODIFY no_brand tinyint(1) NOT NULL,
    MODIFY sort_code int(11) NOT NULL,
    ADD KEY (`no_title`);

ALTER TABLE gcd_issue_reprint
    MODIFY notes longtext NOT NULL;

ALTER TABLE gcd_language
    DROP KEY code;

ALTER TABLE gcd_reprint
    MODIFY notes longtext NOT NULL,
    MODIFY origin_id int(11) NOT NULL;
ALTER TABLE gcd_reprint_to_issue
    MODIFY notes longtext NOT NULL,
    MODIFY origin_id int(11) NOT NULL;
ALTER TABLE gcd_reprint_from_issue
    MODIFY notes longtext NOT NULL,
    MODIFY origin_issue_id int(11) NOT NULL;

ALTER TABLE gcd_story
    ADD KEY (title_inferred);

ALTER TABLE gcd_story_type
    DROP KEY type_name;

-- This table is part of the gcd app.
-- I think once upon a time there was going to be a migration app.
ALTER TABLE migration_story_status
    RENAME gcd_migration_story_status,
    DROP KEY key_story_id,
    ADD UNIQUE KEY (story_id),
    ADD FOREIGN KEY (story_id) REFERENCES gcd_story (id);

-- Drop some tables that I apparently put in at some point without
-- matching code.  Would love to see this stuff done, but not this way.
-- I think this was from one of the original prototype migration scripts.
DROP TABLE gcd_series_relationship_type;
DROP TABLE gcd_series_relationship;

-- Do we still need these tables in production?  Or are they archived somewhere?
-- I think they were there for history migration, but have already been migrated.
-- DROP TABLE log_publisher;
-- DROP TABLE log_series;


-- oi_changeset: tinyint(2) is an optimization Django doesn't get.
