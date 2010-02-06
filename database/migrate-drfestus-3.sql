--- apps/gcd/migration/covers *has* to run before this change

ALTER TABLE gcd_cover
     DROP FOREIGN KEY gcd_cover_ibfk_2, 
     DROP COLUMN series_id,
     DROP COLUMN code,
     DROP COLUMN server_version,
     DROP COLUMN file_extension,
     DROP COLUMN contributor,
     ADD COLUMN last_upload datetime default NULL,
     ADD COLUMN limit_display tinyint(1) NOT NULL default '0',
     ADD INDEX (last_upload);

UPDATE gcd_cover SET last_upload=modified WHERE has_image=1;


