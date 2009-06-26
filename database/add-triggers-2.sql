DROP TRIGGER IF EXISTS post_update_publisher;

DROP TRIGGER IF EXISTS pre_insert_series;
DROP TRIGGER IF EXISTS post_insert_series;
DROP TRIGGER IF EXISTS pre_update_series;
DROP TRIGGER IF EXISTS post_update_series;
DROP TRIGGER IF EXISTS post_delete_series;

DROP TRIGGER IF EXISTS pre_insert_issue;
DROP TRIGGER IF EXISTS post_insert_issue;
DROP TRIGGER IF EXISTS pre_update_issue;
DROP TRIGGER IF EXISTS post_update_issue;
DROP TRIGGER IF EXISTS post_delete_issue;

DROP TRIGGER IF EXISTS pre_insert_sequence;
DROP TRIGGER IF EXISTS post_insert_sequence;
DROP TRIGGER IF EXISTS post_update_sequence;
DROP TRIGGER IF EXISTS post_delete_sequence;

DROP TRIGGER IF EXISTS pre_insert_cover;
DROP TRIGGER IF EXISTS pre_update_cover;

delimiter //

-- It's not possible to manage the imprint_count with triggers due to
-- MySQL's limitations on triggers referencing other rows of the triggering
-- table.  Presumably the same mess as with updates and subqueries.
-- So no insert or delete triggers, and a shortened update trigger.

CREATE TRIGGER post_update_publisher AFTER UPDATE ON core_publisher
    FOR EACH ROW
    BEGIN
        IF old.name != new.name THEN
            UPDATE core_series SET core_series.publisher_name=new.name
                WHERE core_series.publisher_id = new.id;
        END IF;
    END;
//

CREATE TRIGGER pre_insert_series BEFORE INSERT ON core_series
    FOR EACH ROW
    SET new.publisher_name=(
        SELECT name FROM core_publisher p WHERE p.id = new.publisher_id);
//

CREATE TRIGGER post_insert_series AFTER INSERT ON core_series
    FOR EACH ROW
    UPDATE core_publisher p SET p.series_count = p.series_count + 1,
                                p.issue_count = p.issue_count + new.issue_count
        WHERE p.id = series.publisher_id;
//

CREATE TRIGGER pre_update_series BEFORE UPDATE ON core_series
    FOR EACH ROW
    IF new.publisher_id != old.publisher_id THEN
        SET new.publisher_name=
            (SELECT p.name FROM core_publisher p
                WHERE p.id = new.publisher_id);
    END IF;
//

CREATE TRIGGER post_update_series AFTER UPDATE ON core_series
    FOR EACH ROW
    BEGIN
        IF old.publisher_name != new.publisher_name OR
           old.name != new.name OR
           old.year_began != new.year_began THEN
            UPDATE core_issue i SET i.publisher_name=new.publisher_name,
                                    i.series_name=new.name,
                                    i.year_began=new.year_began
                WHERE i.series_id=new.id;
        END IF;
        IF old.publisher_id != new.publisher_id THEN
            UPDATE core_publisher p SET p.series_count = p.series_count - 1,
                p.issue_count = p.issue_count - old.issue_count
                WHERE p.id = old.publisher_id;
            UPDATE core_publisher p SET p.series_count = p.series_count + 1,
                p.issue_count = p.issue_count + new.issue_count
                WHERE p.id = new.publisher_id;
        ELSEIF old.issue_count != new.issue_count THEN
            UPDATE core_publisher p SET p.issue_count=
                p.issue_count + (new.issue_count - old.issue_count)
                WHERE p.id = new.publisher_id;
        END IF;
    END;
//

CREATE TRIGGER post_delete_series AFTER DELETE ON core_series
    FOR EACH ROW
    UPDATE core_publisher p SET p.series_count=p.series_count - 1,
                                p.issue_count=p.issue_count - old.issue_count
        WHERE p.id = old.publisher_id;
//

CREATE TRIGGER pre_insert_issue BEFORE INSERT ON core_issue
    FOR EACH ROW
    BEGIN
        SET new.publisher_name=
            (SELECT s.publisher_name FROM core_series s
                WHERE s.id = new.series_id);
        SET new.series_name=
            (SELECT s.name FROM core_series s WHERE s.id = new.series_id);
        SET new.year_began=
            (SELECT s.year_began FROM core_series s WHERE s.id = new.series_id);
    END;
//

CREATE TRIGGER post_insert_issue AFTER INSERT ON core_issue
    FOR EACH ROW
    UPDATE core_series s SET s.issue_count=s.issue_count + 1
        WHERE s.id = new.series_id;
//

CREATE TRIGGER pre_update_issue BEFORE UPDATE ON core_issue
    FOR EACH ROW
    IF new.series_id != old.series_id THEN
        SET new.series_name=
            (SELECT s.name FROM core_series s WHERE s.id = new.series_id);
        SET new.year_began=
            (SELECT s.year_began FROM core_series s WHERE s.id = new.series_id);
        SET new.publisher_name=
            (SELECT s.publisher_name FROM core_series s where s.id = new.series_id);
    END IF;
//

CREATE TRIGGER post_update_issue AFTER UPDATE ON core_issue
    FOR EACH ROW
    BEGIN
        IF old.`number` != new.`number` OR
           old.series_name != new.series_name OR
           old.year_began != new.year_began OR
           old.publisher_name != new.publisher_name THEN
            UPDATE core_sequence q SET q.issue_number=new.`number`,
                                       q.series_name=new.series_name,
                                       q.year_began=new.year_began,
                                       q.publisher_name=new.publisher_name
                WHERE q.issue_id = new.id;
            UPDATE core_cover c SET c.issue_number=new.`number`,
                                    c.series_name=new.series_name,
                                    c.year_began=new.year_began,
                                    c.publisher_name=new.publisher_name
                WHERE c.issue_id = new.id;
        END IF;
        IF old.sort_code != new.sort_code THEN
            UPDATE core_cover c SET c.issue_sort_code = new.sort_code;
        END IF;
        IF old.series_id != new.series_id THEN
            UPDATE core_sequence q SET q.series_id=new.series_id
                WHERE q.issue_id = new.id;
            UPDATE core_cover c SET c.series_id=new.series_id
                WHERE c.issue_id = new.id;

            UPDATE core_series s SET s.issue_count=s.issue_count - 1
                WHERE s.id = old.series_id;
            UPDATE core_series s SET s.issue_count=s.issue_count + 1
                WHERE s.id = new.series_id;
        END IF;
    END;
//

CREATE TRIGGER post_delete_issue AFTER DELETE ON core_issue
    FOR EACH ROW
    UPDATE core_series s SET s.issue_count=s.issue_count - 1
        WHERE s.id = old.series_id;
//

CREATE TRIGGER pre_insert_sequence BEFORE INSERT ON core_sequence
    FOR EACH ROW
    BEGIN
        SET new.issue_number=
            (SELECT `number` FROM core_issue i WHERE i.id = new.issue_id);
        SET new.series_id=
            (SELECT series_id FROM core_issue i WHERE i.id = new.issue_id);
        SET new.series_name=
            (SELECT series_name FROM core_issue i WHERE i.id = new.issue_id);
        SET new.year_began=
            (SELECT year_began FROM core_issue i WHERE i.id = new.issue_id);
        SET new.publisher_name=
            (SELECT publisher_name FROM core_issue i WHERE i.id = new.issue_id);
    END;
//

CREATE TRIGGER post_insert_sequence AFTER INSERT ON core_sequence
    FOR EACH ROW
    UPDATE core_issue i SET i.sequence_count=i.sequence_count + 1
        WHERE i.id = new.issue_id;
//

-- Moving sequences currently not allowed, so no pre_update_sequence.
-- Likewise, no check to change i.sequence_count in post_update_sequence.
-- This also removes numerous headaches tha would arise with core_cover.
CREATE TRIGGER post_update_sequence AFTER UPDATE ON core_sequence
    FOR EACH ROW
    IF new.`number` != old.`number` THEN
        UPDATE core_cover c SET c.sequence_number=new.`number`
            WHERE c.sequence_id = new.id;
    END IF;
//

CREATE TRIGGER post_delete_sequence AFTER DELETE ON core_sequence
    FOR EACH ROW
    UPDATE core_issue i SET i.sequence_count=i.sequence_count - 1
        WHERE i.id = old.issue_id;
//

-- Again because of restrictions on moving sequences *OR* moving covers,
-- there is only a simple pre_insert_cover trigger and a short pre_update.

CREATE TRIGGER pre_insert_cover BEFORE INSERT ON core_cover
    FOR EACH ROW
    BEGIN
        SET new.issue_number=
            (SELECT `number` FROM core_issue i WHERE i.id = new.issue_id);
        SET new.issue_sort_code=
            (SELECT sort_code FROM core_issue i WHERE i.id = new.issue_id);
        SET new.series_id=
            (SELECT series_id FROM core_issue i WHERE i.id = new.issue_id);
        SET new.series_name=
            (SELECT series_name FROM core_issue i WHERE i.id = new.issue_id);
        SET new.year_began=
            (SELECT year_began FROM core_issue i WHERE i.id = new.issue_id);
        SET new.publisher_name=
            (SELECT publisher_name FROM core_issue i WHERE i.id = new.issue_id);
        IF new.sequence_number IS NOT NULL THEN
            SET new.sequence_id=
                (SELECT id FROM core_sequence q
                    WHERE q.issue_id = new.issue_id AND
                          q.`number` = new.sequence_number);
        END IF;
    END;
//

CREATE TRIGGER pre_update_cover BEFORE UPDATE ON core_cover
    FOR EACH ROW
        IF new.sequence_number != old.sequence_number OR
           (old.sequence_number IS NULL AND new.sequence_number IS NOT NULL)
        THEN
            SET new.sequence_id=
                (SELECT id FROM core_sequence q
                    WHERE q.issue_id = new.issue_id AND
                          q.`number` = new.sequence_number);
        ELSEIF old.sequence_number IS NOT NULL AND new.sequence_number IS NULL
        THEN
            SET new.sequence_id=NULL;
        END IF;
//

delimiter ;

