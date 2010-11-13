SET SESSION sql_mode='STRICT_ALL_TABLES';

ALTER TABLE gcd_count_stats 
    ADD COLUMN language_id int(11) default NULL, 
    ADD FOREIGN KEY (language_id) REFERENCES gcd_language (id),
    DROP INDEX name;

