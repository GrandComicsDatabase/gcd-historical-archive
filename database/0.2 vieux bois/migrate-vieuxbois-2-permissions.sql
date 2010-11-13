SET SESSION sql_mode='STRICT_ALL_TABLES';

SET @editor=(SELECT id FROM auth_group WHERE name = 'editor');
SET @indexer=(SELECT id FROM auth_group WHERE name = 'indexer');

INSERT INTO auth_group_permissions (group_id, permission_id)
    SELECT @indexer, id FROM auth_permission
        WHERE codename IN ('can_reserve', 'can_upload_cover');

-- Note that can_mentor is already set.
INSERT INTO auth_group_permissions (group_id, permission_id)
    SELECT @editor, id FROM auth_permission
        WHERE codename IN ('can_approve', 'can_cancel');

