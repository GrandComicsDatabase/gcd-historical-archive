ALTER TABLE voting_agenda_mailing_list
    MODIFY COLUMN mailing_list_id int(11) default NULL,
    ADD COLUMN group_id int(11) default NULL AFTER mailing_list_id,
    ADD FOREIGN KEY (group_id) REFERENCES auth_group (id);

