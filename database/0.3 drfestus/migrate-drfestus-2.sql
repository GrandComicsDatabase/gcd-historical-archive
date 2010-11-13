DROP TABLE IF EXISTS `oi_cover_revision`;
CREATE TABLE `oi_cover_revision` (
  `id` int(11) NOT NULL auto_increment,
  `changeset_id` int(11) NOT NULL,
  `deleted` tinyint(1) NOT NULL,
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL,
  `cover_id` int(11) default NULL,
  `issue_id` int(11) NOT NULL,
  `marked` tinyint(1) NOT NULL default '0',
  `file_source` varchar(255) default NULL,
  `is_replacement` tinyint(1) NOT NULL default '0',
  PRIMARY KEY  (`id`),
  KEY `oi_cover_revision_changeset_id` (`changeset_id`),
  KEY `oi_cover_revision_created` (`created`),
  KEY `oi_cover_revision_modified` (`modified`),
  KEY `oi_cover_revision_cover_id` (`cover_id`),
  KEY `oi_cover_revision_issue_id` (`issue_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

