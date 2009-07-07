-- MySQL dump 10.11
--
-- Host: localhost    Database: gcd_scratch4
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
  UNIQUE KEY `code_2` (`code`),
  KEY `code` (`code`),
  KEY `country` (`name`(50))
) ENGINE=MyISAM AUTO_INCREMENT=249 DEFAULT CHARSET=utf8;

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
  `sequence_number` int(11) default NULL COMMENT 'Will be NULL for issues with no sequences indexed.',
  `location_code` varchar(50) NOT NULL,
  `issue_sort_code` int(11) NOT NULL default '0',
  `has_image` tinyint(1) NOT NULL default '0' COMMENT 'May be dropped if has_* fields are sufficient.',
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
  KEY `covercode` (`location_code`),
  KEY `HasImage` (`has_image`),
  KEY `c2` (`has_medium`),
  KEY `c4` (`has_large`),
  KEY `Yr_Began` (`year_began`)
) ENGINE=MyISAM AUTO_INCREMENT=627117 DEFAULT CHARSET=utf8;

DELIMITER ;;
/*!50003 SET SESSION SQL_MODE="" */;;
/*!50003 CREATE */ /*!50017 DEFINER=`root`@`localhost` */ /*!50003 TRIGGER `pre_insert_cover` BEFORE INSERT ON `core_cover` FOR EACH ROW BEGIN
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
    END */;;

/*!50003 SET SESSION SQL_MODE="" */;;
/*!50003 CREATE */ /*!50017 DEFINER=`root`@`localhost` */ /*!50003 TRIGGER `pre_update_cover` BEFORE UPDATE ON `core_cover` FOR EACH ROW IF new.sequence_number != old.sequence_number OR
           (old.sequence_number IS NULL AND new.sequence_number IS NOT NULL)
        THEN
            SET new.sequence_id=
                (SELECT id FROM core_sequence q
                    WHERE q.issue_id = new.issue_id AND
                          q.`number` = new.sequence_number);
        ELSEIF old.sequence_number IS NOT NULL AND new.sequence_number IS NULL
        THEN
            SET new.sequence_id=NULL;
        END IF */;;

DELIMITER ;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE */;

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
) ENGINE=MyISAM AUTO_INCREMENT=536 DEFAULT CHARSET=utf8;

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
  `sort_code` int(11) NOT NULL default '0',
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
  KEY `Bk_Name` (`series_name`),
  KEY `issue_sort` (`sort_code`),
  KEY `issue_number` (`number`)
) ENGINE=MyISAM AUTO_INCREMENT=643126 DEFAULT CHARSET=utf8;

DELIMITER ;;
/*!50003 SET SESSION SQL_MODE="" */;;
/*!50003 CREATE */ /*!50017 DEFINER=`root`@`localhost` */ /*!50003 TRIGGER `pre_insert_issue` BEFORE INSERT ON `core_issue` FOR EACH ROW BEGIN
        SET new.publisher_name=
            (SELECT s.publisher_name FROM core_series s
                WHERE s.id = new.series_id);
        SET new.series_name=
            (SELECT s.name FROM core_series s WHERE s.id = new.series_id);
        SET new.year_began=
            (SELECT s.year_began FROM core_series s WHERE s.id = new.series_id);
    END */;;

/*!50003 SET SESSION SQL_MODE="" */;;
/*!50003 CREATE */ /*!50017 DEFINER=`root`@`localhost` */ /*!50003 TRIGGER `post_insert_issue` AFTER INSERT ON `core_issue` FOR EACH ROW UPDATE core_series s SET s.issue_count=s.issue_count + 1
        WHERE s.id = new.series_id */;;

/*!50003 SET SESSION SQL_MODE="" */;;
/*!50003 CREATE */ /*!50017 DEFINER=`root`@`localhost` */ /*!50003 TRIGGER `pre_update_issue` BEFORE UPDATE ON `core_issue` FOR EACH ROW IF new.series_id != old.series_id THEN
        SET new.series_name=
            (SELECT s.name FROM core_series s WHERE s.id = new.series_id);
        SET new.year_began=
            (SELECT s.year_began FROM core_series s WHERE s.id = new.series_id);
        SET new.publisher_name=
            (SELECT s.publisher_name FROM core_series s where s.id = new.series_id);
    END IF */;;

/*!50003 SET SESSION SQL_MODE="" */;;
/*!50003 CREATE */ /*!50017 DEFINER=`root`@`localhost` */ /*!50003 TRIGGER `post_update_issue` AFTER UPDATE ON `core_issue` FOR EACH ROW BEGIN
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
    END */;;

/*!50003 SET SESSION SQL_MODE="" */;;
/*!50003 CREATE */ /*!50017 DEFINER=`root`@`localhost` */ /*!50003 TRIGGER `post_delete_issue` AFTER DELETE ON `core_issue` FOR EACH ROW UPDATE core_series s SET s.issue_count=s.issue_count - 1
        WHERE s.id = old.series_id */;;

DELIMITER ;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE */;

--
-- Table structure for table `core_issue_reprint`
--

DROP TABLE IF EXISTS `core_issue_reprint`;
CREATE TABLE `core_issue_reprint` (
  `id` int(11) NOT NULL auto_increment,
  `source_issue_id` int(11) NOT NULL,
  `target_issue_id` int(11) NOT NULL,
  `notes` mediumtext,
  PRIMARY KEY  (`id`),
  KEY `issue_from` (`source_issue_id`),
  KEY `issue_to` (`target_issue_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Table structure for table `core_language`
--

DROP TABLE IF EXISTS `core_language`;
CREATE TABLE `core_language` (
  `id` int(11) NOT NULL auto_increment,
  `code` varchar(10) NOT NULL,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `code_2` (`code`),
  KEY `code` (`code`),
  KEY `language` (`name`(10))
) ENGINE=MyISAM AUTO_INCREMENT=138 DEFAULT CHARSET=utf8;

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
  `series_count` int(11) NOT NULL default '0',
  `issue_count` int(11) NOT NULL default '0',
  `created` date NOT NULL,
  `modified` date NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `PubName` (`name`),
  KEY `ParentID` (`parent_id`),
  KEY `Master` (`master`),
  KEY `YearBegan` (`year_began`)
) ENGINE=MyISAM AUTO_INCREMENT=5155 DEFAULT CHARSET=utf8;

DELIMITER ;;
/*!50003 SET SESSION SQL_MODE="" */;;
/*!50003 CREATE */ /*!50017 DEFINER=`root`@`localhost` */ /*!50003 TRIGGER `post_update_publisher` AFTER UPDATE ON `core_publisher` FOR EACH ROW BEGIN
        IF old.name != new.name THEN
            UPDATE core_series SET core_series.publisher_name=new.name
                WHERE core_series.publisher_id = new.id;
        END IF;
    END */;;

DELIMITER ;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE */;

--
-- Table structure for table `core_reprint`
--

DROP TABLE IF EXISTS `core_reprint`;
CREATE TABLE `core_reprint` (
  `id` int(11) NOT NULL auto_increment,
  `source_id` int(11) NOT NULL,
  `target_id` int(11) NOT NULL,
  `notes` mediumtext,
  PRIMARY KEY  (`id`),
  KEY `reprint_from` (`source_id`),
  KEY `reprint_to` (`target_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Table structure for table `core_reprint_from_issue`
--

DROP TABLE IF EXISTS `core_reprint_from_issue`;
CREATE TABLE `core_reprint_from_issue` (
  `id` int(11) NOT NULL auto_increment,
  `source_issue_id` int(11) NOT NULL,
  `target_id` int(11) NOT NULL,
  `notes` mediumtext,
  PRIMARY KEY  (`id`),
  KEY `reprint_to_issue_from` (`source_issue_id`),
  KEY `reprint_to_issue_to` (`target_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Table structure for table `core_reprint_to_issue`
--

DROP TABLE IF EXISTS `core_reprint_to_issue`;
CREATE TABLE `core_reprint_to_issue` (
  `id` int(11) NOT NULL auto_increment,
  `source_id` int(11) NOT NULL,
  `target_issue_id` int(11) NOT NULL,
  `notes` mediumtext,
  PRIMARY KEY  (`id`),
  KEY `reprint_to_issue_from` (`source_id`),
  KEY `reprint_to_issue_to` (`target_issue_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

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
) ENGINE=MyISAM AUTO_INCREMENT=87573 DEFAULT CHARSET=utf8;

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
  `reprint_notes` mediumtext,
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
  KEY `Key_Date` (`Key_Date`),
  KEY `sequence_type` (`type`),
  KEY `sequence_genre` (`genre`),
  KEY `reprint_notes` (`reprint_notes`(255))
) ENGINE=MyISAM AUTO_INCREMENT=771688 DEFAULT CHARSET=utf8;

DELIMITER ;;
/*!50003 SET SESSION SQL_MODE="" */;;
/*!50003 CREATE */ /*!50017 DEFINER=`root`@`localhost` */ /*!50003 TRIGGER `pre_insert_sequence` BEFORE INSERT ON `core_sequence` FOR EACH ROW BEGIN
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
    END */;;

/*!50003 SET SESSION SQL_MODE="" */;;
/*!50003 CREATE */ /*!50017 DEFINER=`root`@`localhost` */ /*!50003 TRIGGER `post_insert_sequence` AFTER INSERT ON `core_sequence` FOR EACH ROW UPDATE core_issue i SET i.sequence_count=i.sequence_count + 1
        WHERE i.id = new.issue_id */;;

/*!50003 SET SESSION SQL_MODE="" */;;
/*!50003 CREATE */ /*!50017 DEFINER=`root`@`localhost` */ /*!50003 TRIGGER `post_update_sequence` AFTER UPDATE ON `core_sequence` FOR EACH ROW IF new.`number` != old.`number` THEN
        UPDATE core_cover c SET c.sequence_number=new.`number`
            WHERE c.sequence_id = new.id;
    END IF */;;

/*!50003 SET SESSION SQL_MODE="" */;;
/*!50003 CREATE */ /*!50017 DEFINER=`root`@`localhost` */ /*!50003 TRIGGER `post_delete_sequence` AFTER DELETE ON `core_sequence` FOR EACH ROW UPDATE core_issue i SET i.sequence_count=i.sequence_count - 1
        WHERE i.id = old.issue_id */;;

DELIMITER ;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE */;

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
) ENGINE=MyISAM AUTO_INCREMENT=37394 DEFAULT CHARSET=utf8;

DELIMITER ;;
/*!50003 SET SESSION SQL_MODE="" */;;
/*!50003 CREATE */ /*!50017 DEFINER=`root`@`localhost` */ /*!50003 TRIGGER `pre_insert_series` BEFORE INSERT ON `core_series` FOR EACH ROW SET new.publisher_name=(
        SELECT name FROM core_publisher p WHERE p.id = new.publisher_id) */;;

/*!50003 SET SESSION SQL_MODE="" */;;
/*!50003 CREATE */ /*!50017 DEFINER=`root`@`localhost` */ /*!50003 TRIGGER `post_insert_series` AFTER INSERT ON `core_series` FOR EACH ROW UPDATE core_publisher p SET p.series_count = p.series_count + 1,
                                p.issue_count = p.issue_count + new.issue_count
        WHERE p.id = series.publisher_id */;;

/*!50003 SET SESSION SQL_MODE="" */;;
/*!50003 CREATE */ /*!50017 DEFINER=`root`@`localhost` */ /*!50003 TRIGGER `pre_update_series` BEFORE UPDATE ON `core_series` FOR EACH ROW IF new.publisher_id != old.publisher_id THEN
        SET new.publisher_name=
            (SELECT p.name FROM core_publisher p
                WHERE p.id = new.publisher_id);
    END IF */;;

/*!50003 SET SESSION SQL_MODE="" */;;
/*!50003 CREATE */ /*!50017 DEFINER=`root`@`localhost` */ /*!50003 TRIGGER `post_update_series` AFTER UPDATE ON `core_series` FOR EACH ROW BEGIN
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
    END */;;

/*!50003 SET SESSION SQL_MODE="" */;;
/*!50003 CREATE */ /*!50017 DEFINER=`root`@`localhost` */ /*!50003 TRIGGER `post_delete_series` AFTER DELETE ON `core_series` FOR EACH ROW UPDATE core_publisher p SET p.series_count=p.series_count - 1,
                                p.issue_count=p.issue_count - old.issue_count
        WHERE p.id = old.publisher_id */;;

DELIMITER ;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE */;

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
) ENGINE=MyISAM AUTO_INCREMENT=25330 DEFAULT CHARSET=utf8;

--
-- Table structure for table `migration_sequence_status`
--

DROP TABLE IF EXISTS `migration_sequence_status`;
CREATE TABLE `migration_sequence_status` (
  `id` int(11) NOT NULL auto_increment,
  `sequence_id` int(11) NOT NULL,
  `reprint_needs_inspection` tinyint(1) default NULL,
  `reprint_confirmed` tinyint(1) default NULL,
  `reprint_original_notes` mediumtext,
  PRIMARY KEY  (`id`),
  KEY `key_reprint_needs_inspection` (`reprint_needs_inspection`),
  KEY `key_reprint_confirmed` (`reprint_confirmed`),
  KEY `key_reprint_notes` (`reprint_original_notes`(255))
) ENGINE=MyISAM AUTO_INCREMENT=722388 DEFAULT CHARSET=utf8;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2009-07-05 22:56:34
