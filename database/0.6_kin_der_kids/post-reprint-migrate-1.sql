-- if reprint notes stay the same during migration confirm their status
UPDATE migration_story_status i INNER JOIN gcd_story h ON h.id = i.story_id
    SET i.reprint_confirmed=1 where h.reprint_notes = i.reprint_original_notes;

