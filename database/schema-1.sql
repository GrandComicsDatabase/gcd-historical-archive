-- MySQL dump 10.11
--
-- Host: localhost    Database: gcd_third
-- ------------------------------------------------------
-- Server version	5.0.45-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `core_country`
--

DROP TABLE IF EXISTS `core_country`;
CREATE TABLE `core_country` (
  `id` int(11) NOT NULL auto_increment,
  `code` varchar(10) NOT NULL,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `code` (`code`),
  KEY `country` (`name`(50))
) ENGINE=MyISAM AUTO_INCREMENT=248 DEFAULT CHARSET=utf8;

--
-- Table structure for table `core_cover`
--

DROP TABLE IF EXISTS `core_cover`;
CREATE TABLE `core_cover` (
  `id` int(11) NOT NULL auto_increment,
  `issue_id` int(11) NOT NULL,
  `issue_number` varchar(50) NOT NULL COMMENT 'From the issue table.',
  `series_id` int(11) NOT NULL,
  `sequence_id` int(11) default NULL COMMENT 'Will be NULL for issues with no sequences indexed.',
  `sequence_number` int(11) default NULL COMMENT 'Zero until we have a way to add images to other sequences.',
  `sort_code` varchar(50) NOT NULL,
  `has_image` tinyint(1) NOT NULL COMMENT 'May be dropped if has_* fields are sufficient.',
  `marked` tinyint(1) NOT NULL default '0' COMMENT 'If 1, cover has been marked for replacement',
  `has_small` tinyint(1) NOT NULL default '0',
  `has_medium` tinyint(1) NOT NULL default '0',
  `has_large` tinyint(1) NOT NULL default '0',
  `server_version` int(11) NOT NULL default '1',
  `contributor` varchar(255) default NULL,
  `publisher_name` varchar(255) NOT NULL COMMENT 'publisher table denormalization',
  `series_name` varchar(255) NOT NULL COMMENT 'series table denormalization',
  `year_began` int(11) NOT NULL COMMENT 'series table denormalization',
  `created` date NOT NULL default '0001-01-01',
  `creation_time` time NOT NULL default '00:00:00',
  `modified` date NOT NULL default '0001-01-01',
  `modification_time` time NOT NULL default '00:00:00',
  PRIMARY KEY  (`id`),
  KEY `IssueID` (`issue_id`),
  KEY `SeriesID` (`series_id`),
  KEY `c1` (`has_small`),
  KEY `Modified` (`modified`),
  KEY `covercode` (`sort_code`),
  KEY `HasImage` (`has_image`),
  KEY `c2` (`has_medium`),
  KEY `c4` (`has_large`),
  KEY `Yr_Began` (`year_began`)
) ENGINE=MyISAM AUTO_INCREMENT=609127 DEFAULT CHARSET=utf8;

--
-- Table structure for table `core_indexer`
--

DROP TABLE IF EXISTS `core_indexer`;
CREATE TABLE `core_indexer` (
  `id` int(11) NOT NULL auto_increment,
  `username` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `country_code` varchar(255) default NULL,
  `email` varchar(255) default NULL,
  `given_name` varchar(255) default NULL,
  `family_name` varchar(255) default NULL,
  `name_order` tinyint(1) default '0' COMMENT 'Controls name display.  For future language/culture expansion.',
  `user_level` int(11) NOT NULL default '0',
  `active` tinyint(1) NOT NULL default '1',
  `message` mediumtext,
  `created` date NOT NULL default '0001-01-01',
  `modified` date NOT NULL default '0001-01-01',
  PRIMARY KEY  (`id`),
  KEY `LastName` (`family_name`),
  KEY `FirstName` (`given_name`),
  KEY `eMail` (`email`),
  KEY `username` (`username`),
  KEY `password` (`password`)
) ENGINE=MyISAM AUTO_INCREMENT=530 DEFAULT CHARSET=utf8;

--
-- Table structure for table `core_issue`
--

DROP TABLE IF EXISTS `core_issue`;
CREATE TABLE `core_issue` (
  `id` int(11) NOT NULL auto_increment,
  `number` varchar(50) NOT NULL COMMENT 'Varchar to support "numbers" like "5a", "Winter Special".',
  `volume` int(11) default NULL COMMENT 'Rarely correct, often also in issue i.e. as "v1#1".',
  `series_id` int(11) NOT NULL,
  `key_date` varchar(10) default NULL COMMENT 'Format YYYY.MM.DD',
  `publication_date` varchar(255) default NULL COMMENT 'As in comic, but no abbreviations.  Not always proper date.',
  `price` varchar(255) default NULL COMMENT 'Format: decimal followed by ISO code, but often is not.',
  `page_count` varchar(10) default NULL,
  `editing` mediumtext,
  `index_status` int(11) NOT NULL default '0' COMMENT 'Ignore unless you are implementing the indexing system.',
  `reserve_status` int(11) NOT NULL default '0' COMMENT 'Ignore unless you are implementing the indexing system.',
  `notes` mediumtext COMMENT 'May also have notes for sequence 0.',
  `sequence_count` int(11) NOT NULL default '0',
  `series_name` varchar(255) NOT NULL COMMENT 'series table denormalization',
  `year_began` int(11) NOT NULL COMMENT 'series table denormalization',
  `publisher_name` varchar(255) NOT NULL COMMENT 'publisher table denormalization',
  `created` date NOT NULL,
  `modified` date NOT NULL,
  `modification_time` time NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `SeriesID` (`series_id`),
  KEY `Key_Date` (`key_date`),
  KEY `IndexStatus` (`index_status`),
  KEY `ReserveStatus` (`reserve_status`),
  KEY `Bk_Name` (`series_name`)
) ENGINE=MyISAM AUTO_INCREMENT=625182 DEFAULT CHARSET=utf8;

--
-- Table structure for table `core_language`
--

DROP TABLE IF EXISTS `core_language`;
CREATE TABLE `core_language` (
  `id` int(11) NOT NULL auto_increment,
  `code` varchar(10) NOT NULL,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `code` (`code`),
  KEY `language` (`name`(10))
) ENGINE=MyISAM AUTO_INCREMENT=137 DEFAULT CHARSET=utf8;

--
-- Table structure for table `core_publisher`
--

DROP TABLE IF EXISTS `core_publisher`;
CREATE TABLE `core_publisher` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  `country_id` int(11) default NULL,
  `year_began` int(11) default NULL,
  `year_ended` int(11) default NULL COMMENT 'Frequently 9999 as the UI wont allow NULL for current pubs.',
  `notes` longtext,
  `url` varchar(255) default NULL,
  `master` tinyint(1) NOT NULL COMMENT 'Only Master publishers may have "imprints"',
  `parent_id` int(11) default NULL COMMENT 'All imprints, indicia publishers, etc. have a parent id.',
  `alpha_sort_code` varchar(1) default NULL COMMENT 'Used to group related publishers in a sort, may go away.',
  `imprint_count` int(11) NOT NULL default '0',
  `series_count` int(11) NOT NULL default '0',
  `issue_count` int(11) NOT NULL default '0',
  `created` date NOT NULL,
  `modified` date NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `PubName` (`name`),
  KEY `ParentID` (`parent_id`),
  KEY `Master` (`master`),
  KEY `YearBegan` (`year_began`)
) ENGINE=MyISAM AUTO_INCREMENT=5048 DEFAULT CHARSET=utf8;

--
-- Table structure for table `core_reservation`
--

DROP TABLE IF EXISTS `core_reservation`;
CREATE TABLE `core_reservation` (
  `id` int(11) NOT NULL auto_increment,
  `indexer_id` int(11) NOT NULL,
  `issue_id` int(11) NOT NULL,
  `status` int(11) NOT NULL,
  `index_type` int(11) NOT NULL,
  `expires` date default NULL,
  `created` date default NULL,
  PRIMARY KEY  (`id`),
  KEY `IndexerID` (`indexer_id`),
  KEY `IssueID` (`issue_id`),
  KEY `Status` (`status`)
) ENGINE=MyISAM AUTO_INCREMENT=86350 DEFAULT CHARSET=utf8;

--
-- Table structure for table `core_sequence`
--

DROP TABLE IF EXISTS `core_sequence`;
CREATE TABLE `core_sequence` (
  `id` int(11) NOT NULL auto_increment,
  `title` varchar(255) default NULL,
  `feature` varchar(255) default NULL COMMENT 'Feature name, not featured character.',
  `number` int(11) NOT NULL COMMENT 'Sequence zero is always the (first) cover.',
  `page_count` varchar(10) default NULL,
  `type` varchar(50) default NULL,
  `job_number` varchar(25) default NULL COMMENT 'Strictly speaking, not always a number.',
  `script` mediumtext,
  `pencils` mediumtext,
  `inks` mediumtext,
  `colors` mediumtext,
  `letters` mediumtext,
  `editing` mediumtext,
  `genre` varchar(255) default NULL,
  `characters` mediumtext,
  `synopsis` mediumtext,
  `reprints` mediumtext,
  `notes` mediumtext,
  `issue_id` int(11) NOT NULL,
  `series_id` int(11) NOT NULL COMMENT 'issue table denormalization.',
  `issue_number` varchar(50) NOT NULL COMMENT 'issue table denormalization.',
  `series_name` varchar(255) NOT NULL COMMENT 'series table denormalization',
  `year_began` int(11) NOT NULL COMMENT 'series table denormalization',
  `publisher_name` varchar(255) NOT NULL COMMENT 'publisher table denormalization',
  `created` date NOT NULL,
  `modified` date NOT NULL,
  `modification_time` time NOT NULL,
  `Key_Date` varchar(30) default NULL,
  `Pub_Date` varchar(255) default NULL,
  `Price` double default NULL,
  PRIMARY KEY  (`id`),
  KEY `IssueID` (`issue_id`),
  KEY `Title` (`title`),
  KEY `Script` (`script`(255)),
  KEY `Pencils` (`pencils`(255)),
  KEY `Inks` (`inks`(255)),
  KEY `Colors` (`colors`(255)),
  KEY `Letters` (`letters`(255)),
  KEY `Editing` (`editing`(255)),
  KEY `Char_App` (`characters`(255)),
  KEY `JobNo` (`job_number`(15)),
  KEY `SeriesID` (`series_id`),
  KEY `Seq_No` (`number`),
  KEY `Feature` (`feature`),
  KEY `Modified` (`modified`),
  KEY `Key_Date` (`Key_Date`)
) ENGINE=MyISAM AUTO_INCREMENT=763317 DEFAULT CHARSET=utf8;

--
-- Table structure for table `core_series`
--

DROP TABLE IF EXISTS `core_series`;
CREATE TABLE `core_series` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  `format` varchar(255) default NULL,
  `year_began` int(11) NOT NULL,
  `year_ended` int(11) default NULL,
  `publication_dates` varchar(255) default NULL,
  `country_code` varchar(4) default NULL COMMENT 'Should be replaced with country_id to core_country table.',
  `language_code` varchar(3) default NULL COMMENT 'Should be replaced with language_id to core_language table.',
  `publisher_id` int(11) NOT NULL COMMENT 'Should only link to Master publishers.',
  `imprint_id` int(11) default NULL COMMENT 'Should only link to non-Master publishers.',
  `first_issue` varchar(25) default NULL,
  `last_issue` varchar(25) default NULL,
  `publication_notes` mediumtext COMMENT 'Another attempt to capture imprint and other publisher data',
  `tracking_notes` mediumtext COMMENT 'For tracking numbering across series re-names.',
  `notes` mediumtext,
  `has_gallery` tinyint(1) NOT NULL default '0' COMMENT 'Not entirely sure if this field is accurate or useful.',
  `open_reserve` int(11) default NULL COMMENT 'Ignore unless you are implementing the indexing system.',
  `issue_count` int(11) NOT NULL default '0',
  `publisher_name` varchar(255) NOT NULL COMMENT 'publisher table denormalization',
  `created` date NOT NULL,
  `modified` date NOT NULL,
  `modification_time` time NOT NULL,
  `InitDist` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `imprint_id` (`imprint_id`),
  KEY `PubID` (`publisher_id`),
  KEY `Bk_Name` (`name`(150)),
  KEY `Yr_Began` (`year_began`),
  KEY `HasGallery` (`has_gallery`),
  KEY `LangCode` (`language_code`)
) ENGINE=MyISAM AUTO_INCREMENT=36188 DEFAULT CHARSET=utf8;

--
-- Table structure for table `core_seriescredit`
--

DROP TABLE IF EXISTS `core_seriescredit`;
CREATE TABLE `core_seriescredit` (
  `id` int(11) NOT NULL auto_increment,
  `indexer_id` int(11) NOT NULL,
  `series_id` int(11) NOT NULL,
  `run` varchar(255) default NULL,
  `notes` mediumtext,
  `created` date NOT NULL default '0001-01-01',
  `modified` date NOT NULL default '0001-01-01',
  PRIMARY KEY  (`id`),
  KEY `IndexerID` (`indexer_id`),
  KEY `SeriesID` (`series_id`)
) ENGINE=MyISAM AUTO_INCREMENT=24953 DEFAULT CHARSET=utf8;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2009-05-04  6:25:22
