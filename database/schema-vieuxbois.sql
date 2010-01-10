-- MySQL dump 10.13  Distrib 5.1.40, for apple-darwin9.5.0 (i386)
--
-- Host: localhost    Database: gcd_innodb7
-- ------------------------------------------------------
-- Server version	5.1.40-log

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
-- Table structure for table `auth_group`
--

DROP TABLE IF EXISTS `auth_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auth_group` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(80) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `auth_group_permissions`
--

DROP TABLE IF EXISTS `auth_group_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auth_group_permissions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `group_id` int(11) NOT NULL,
  `permission_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `group_id` (`group_id`,`permission_id`),
  KEY `permission_id_refs_id_a7792de1` (`permission_id`)
) ENGINE=InnoDB AUTO_INCREMENT=60 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `auth_message`
--

DROP TABLE IF EXISTS `auth_message`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auth_message` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `message` longtext NOT NULL,
  PRIMARY KEY (`id`),
  KEY `auth_message_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `auth_permission`
--

DROP TABLE IF EXISTS `auth_permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auth_permission` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `content_type_id` int(11) NOT NULL,
  `codename` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `content_type_id` (`content_type_id`,`codename`),
  KEY `auth_permission_content_type_id` (`content_type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=105 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `auth_user`
--

DROP TABLE IF EXISTS `auth_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auth_user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(30) NOT NULL,
  `first_name` varchar(30) NOT NULL,
  `last_name` varchar(30) NOT NULL,
  `email` varchar(75) NOT NULL,
  `password` varchar(128) NOT NULL,
  `is_staff` tinyint(1) NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `is_superuser` tinyint(1) NOT NULL,
  `last_login` datetime NOT NULL,
  `date_joined` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=848 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `auth_user_groups`
--

DROP TABLE IF EXISTS `auth_user_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auth_user_groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `group_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`,`group_id`),
  KEY `group_id_refs_id_f0ee9890` (`group_id`)
) ENGINE=InnoDB AUTO_INCREMENT=924 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `auth_user_user_permissions`
--

DROP TABLE IF EXISTS `auth_user_user_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auth_user_user_permissions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `permission_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`,`permission_id`),
  KEY `permission_id_refs_id_67e79cb` (`permission_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `django_admin_log`
--

DROP TABLE IF EXISTS `django_admin_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `django_admin_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `action_time` datetime NOT NULL,
  `user_id` int(11) NOT NULL,
  `content_type_id` int(11) DEFAULT NULL,
  `object_id` longtext,
  `object_repr` varchar(200) NOT NULL,
  `action_flag` smallint(5) unsigned NOT NULL,
  `change_message` longtext NOT NULL,
  PRIMARY KEY (`id`),
  KEY `django_admin_log_user_id` (`user_id`),
  KEY `django_admin_log_content_type_id` (`content_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `django_content_type`
--

DROP TABLE IF EXISTS `django_content_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `django_content_type` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `app_label` varchar(100) NOT NULL,
  `model` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `app_label` (`app_label`,`model`)
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `django_session`
--

DROP TABLE IF EXISTS `django_session`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `django_session` (
  `session_key` varchar(40) NOT NULL,
  `session_data` longtext NOT NULL,
  `expire_date` datetime NOT NULL,
  PRIMARY KEY (`session_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gcd_brand`
--

DROP TABLE IF EXISTS `gcd_brand`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gcd_brand` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `parent_id` int(11) NOT NULL,
  `year_began` int(11) DEFAULT NULL,
  `year_ended` int(11) DEFAULT NULL,
  `notes` longtext,
  `url` varchar(255) DEFAULT NULL,
  `issue_count` int(11) NOT NULL DEFAULT '0',
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL,
  `reserved` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `name` (`name`),
  KEY `parent_id` (`parent_id`),
  KEY `year_began` (`year_began`),
  KEY `reserved` (`reserved`),
  CONSTRAINT `gcd_brand_ibfk_1` FOREIGN KEY (`parent_id`) REFERENCES `gcd_publisher` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=249 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gcd_count_stats`
--

DROP TABLE IF EXISTS `gcd_count_stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gcd_count_stats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(40) NOT NULL,
  `count` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  KEY `name_index` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gcd_country`
--

DROP TABLE IF EXISTS `gcd_country`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gcd_country` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(10) NOT NULL,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code_2` (`code`),
  KEY `code` (`code`),
  KEY `country` (`name`(50))
) ENGINE=InnoDB AUTO_INCREMENT=249 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gcd_cover`
--

DROP TABLE IF EXISTS `gcd_cover`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gcd_cover` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `issue_id` int(11) NOT NULL,
  `code` varchar(50) NOT NULL,
  `has_image` tinyint(1) NOT NULL DEFAULT '0',
  `marked` tinyint(1) NOT NULL DEFAULT '0',
  `contributor` varchar(255) DEFAULT NULL,
  `server_version` int(11) NOT NULL DEFAULT '1',
  `series_id` int(11) NOT NULL,
  `created` datetime NOT NULL DEFAULT '1901-01-01 00:00:00',
  `modified` datetime NOT NULL DEFAULT '1901-01-01 00:00:00',
  `variant_text` varchar(255) DEFAULT NULL,
  `variant_code` char(2) DEFAULT NULL,
  `file_extension` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `IssueID` (`issue_id`),
  KEY `SeriesID` (`series_id`),
  KEY `Modified` (`modified`),
  KEY `covercode` (`code`),
  KEY `HasImage` (`has_image`),
  CONSTRAINT `gcd_cover_ibfk_1` FOREIGN KEY (`issue_id`) REFERENCES `gcd_issue` (`id`),
  CONSTRAINT `gcd_cover_ibfk_2` FOREIGN KEY (`series_id`) REFERENCES `gcd_series` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=682194 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gcd_error`
--

DROP TABLE IF EXISTS `gcd_error`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gcd_error` (
  `error_key` varchar(40) NOT NULL,
  `error_text` longtext,
  `is_safe` tinyint(1) NOT NULL,
  PRIMARY KEY (`error_key`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gcd_indexer`
--

DROP TABLE IF EXISTS `gcd_indexer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gcd_indexer` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `country_id` int(11) NOT NULL,
  `deceased` tinyint(1) NOT NULL DEFAULT '0',
  `max_reservations` int(11) NOT NULL DEFAULT '10',
  `max_ongoing` int(11) NOT NULL DEFAULT '4',
  `is_new` int(11) NOT NULL DEFAULT '0',
  `is_banned` int(11) NOT NULL DEFAULT '0',
  `mentor_id` int(11) DEFAULT NULL,
  `interests` longtext,
  `registration_key` varchar(40) DEFAULT NULL,
  `registration_expires` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `country_id` (`country_id`),
  KEY `mentor_id` (`mentor_id`),
  KEY `is_new` (`is_new`),
  KEY `is_banned` (`is_banned`),
  KEY `deceased` (`deceased`),
  KEY `registration_key` (`registration_key`),
  KEY `registration_expires` (`registration_expires`),
  CONSTRAINT `gcd_indexer_ibfk_1` FOREIGN KEY (`country_id`) REFERENCES `gcd_country` (`id`),
  CONSTRAINT `gcd_indexer_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`),
  CONSTRAINT `gcd_indexer_ibfk_3` FOREIGN KEY (`mentor_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=868 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gcd_indexer_languages`
--

DROP TABLE IF EXISTS `gcd_indexer_languages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gcd_indexer_languages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `indexer_id` int(11) NOT NULL,
  `language_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `indexer_id` (`indexer_id`),
  KEY `language_id` (`language_id`),
  CONSTRAINT `gcd_indexer_languages_ibfk_1` FOREIGN KEY (`indexer_id`) REFERENCES `gcd_indexer` (`id`),
  CONSTRAINT `gcd_indexer_languages_ibfk_2` FOREIGN KEY (`language_id`) REFERENCES `gcd_language` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=391 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gcd_indicia_publisher`
--

DROP TABLE IF EXISTS `gcd_indicia_publisher`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gcd_indicia_publisher` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `parent_id` int(11) NOT NULL,
  `country_id` int(11) NOT NULL,
  `year_began` int(11) DEFAULT NULL,
  `year_ended` int(11) DEFAULT NULL,
  `is_surrogate` tinyint(1) NOT NULL DEFAULT '0',
  `notes` longtext,
  `url` varchar(255) NOT NULL DEFAULT '',
  `issue_count` int(11) NOT NULL DEFAULT '0',
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL,
  `reserved` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `name` (`name`),
  KEY `parent_id` (`parent_id`),
  KEY `country_id` (`country_id`),
  KEY `year_began` (`year_began`),
  KEY `is_surrogate` (`is_surrogate`),
  KEY `reserved` (`reserved`),
  CONSTRAINT `gcd_indicia_publisher_ibfk_1` FOREIGN KEY (`parent_id`) REFERENCES `gcd_publisher` (`id`),
  CONSTRAINT `gcd_indicia_publisher_ibfk_2` FOREIGN KEY (`country_id`) REFERENCES `gcd_country` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=285 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gcd_issue`
--

DROP TABLE IF EXISTS `gcd_issue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gcd_issue` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `number` varchar(50) NOT NULL,
  `volume` int(11) DEFAULT NULL,
  `no_volume` tinyint(1) NOT NULL DEFAULT '0',
  `display_volume_with_number` tinyint(1) NOT NULL DEFAULT '0',
  `series_id` int(11) NOT NULL,
  `indicia_publisher_id` int(11) DEFAULT NULL,
  `brand_id` int(11) DEFAULT NULL,
  `publication_date` varchar(255) DEFAULT NULL,
  `key_date` varchar(10) DEFAULT NULL,
  `sort_code` int(11) unsigned NOT NULL DEFAULT '0',
  `price` varchar(255) DEFAULT NULL,
  `page_count` decimal(10,3) DEFAULT NULL,
  `page_count_uncertain` tinyint(1) NOT NULL DEFAULT '0',
  `indicia_frequency` varchar(255) NOT NULL DEFAULT '',
  `editing` longtext NOT NULL,
  `no_editing` tinyint(1) NOT NULL DEFAULT '0',
  `notes` longtext NOT NULL,
  `story_type_count` int(11) NOT NULL DEFAULT '0',
  `index_status` int(11) NOT NULL DEFAULT '0',
  `reserve_status` int(11) NOT NULL DEFAULT '0',
  `reserve_check` int(11) DEFAULT NULL,
  `created` datetime NOT NULL DEFAULT '1901-01-01 00:00:00',
  `modified` datetime NOT NULL DEFAULT '1901-01-01 00:00:00',
  `reserved` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `series_id_sort_code` (`series_id`,`sort_code`),
  KEY `SeriesID` (`series_id`),
  KEY `Key_Date` (`key_date`),
  KEY `IndexStatus` (`index_status`),
  KEY `ReserveStatus` (`reserve_status`),
  KEY `Issue` (`number`),
  KEY `VolumeNum` (`volume`),
  KEY `Modified` (`modified`),
  KEY `reserved` (`reserved`),
  KEY `no_volume` (`no_volume`),
  KEY `display_volume_with_number` (`display_volume_with_number`),
  KEY `indicia_publisher_id` (`indicia_publisher_id`),
  KEY `brand_id` (`brand_id`),
  KEY `no_editing` (`no_editing`),
  KEY `story_type_count` (`story_type_count`),
  KEY `reserve_check` (`reserve_check`),
  KEY `sort_code` (`sort_code`),
  CONSTRAINT `gcd_issue_ibfk_1` FOREIGN KEY (`series_id`) REFERENCES `gcd_series` (`id`),
  CONSTRAINT `gcd_issue_ibfk_2` FOREIGN KEY (`indicia_publisher_id`) REFERENCES `gcd_indicia_publisher` (`id`),
  CONSTRAINT `gcd_issue_ibfk_3` FOREIGN KEY (`brand_id`) REFERENCES `gcd_brand` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=697805 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gcd_issue_reprint`
--

DROP TABLE IF EXISTS `gcd_issue_reprint`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gcd_issue_reprint` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `source_issue_id` int(11) NOT NULL,
  `target_issue_id` int(11) NOT NULL,
  `notes` longtext,
  `reserved` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `issue_from` (`source_issue_id`),
  KEY `issue_to` (`target_issue_id`),
  KEY `reserved` (`reserved`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gcd_language`
--

DROP TABLE IF EXISTS `gcd_language`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gcd_language` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(10) NOT NULL,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code_2` (`code`),
  KEY `code` (`code`),
  KEY `language` (`name`(10))
) ENGINE=InnoDB AUTO_INCREMENT=146 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gcd_publisher`
--

DROP TABLE IF EXISTS `gcd_publisher`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gcd_publisher` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `country_id` int(11) NOT NULL,
  `year_began` int(11) DEFAULT NULL,
  `year_ended` int(11) DEFAULT NULL,
  `notes` longtext NOT NULL,
  `url` varchar(255) NOT NULL DEFAULT '',
  `is_master` tinyint(1) NOT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `imprint_count` int(11) NOT NULL DEFAULT '0',
  `brand_count` int(11) NOT NULL DEFAULT '0',
  `indicia_publisher_count` int(11) NOT NULL DEFAULT '0',
  `series_count` int(11) NOT NULL DEFAULT '0',
  `created` datetime NOT NULL DEFAULT '1901-01-01 00:00:00',
  `modified` datetime NOT NULL DEFAULT '1901-01-01 00:00:00',
  `issue_count` int(11) NOT NULL DEFAULT '0',
  `reserved` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `PubName` (`name`),
  KEY `ParentID` (`parent_id`),
  KEY `Master` (`is_master`),
  KEY `YearBegan` (`year_began`),
  KEY `reserved` (`reserved`),
  KEY `country_id` (`country_id`),
  KEY `brand_count` (`brand_count`),
  KEY `indicia_publisher_count` (`indicia_publisher_count`),
  CONSTRAINT `gcd_publisher_ibfk_1` FOREIGN KEY (`country_id`) REFERENCES `gcd_country` (`id`),
  CONSTRAINT `gcd_publisher_ibfk_2` FOREIGN KEY (`parent_id`) REFERENCES `gcd_publisher` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5707 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gcd_reprint`
--

DROP TABLE IF EXISTS `gcd_reprint`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gcd_reprint` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `source_id` int(11) NOT NULL,
  `target_id` int(11) NOT NULL,
  `notes` longtext,
  `reserved` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `reprint_from` (`source_id`),
  KEY `reprint_to` (`target_id`),
  KEY `reserved` (`reserved`),
  CONSTRAINT `gcd_reprint_ibfk_1` FOREIGN KEY (`source_id`) REFERENCES `gcd_story` (`id`),
  CONSTRAINT `gcd_reprint_ibfk_2` FOREIGN KEY (`target_id`) REFERENCES `gcd_story` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gcd_reprint_from_issue`
--

DROP TABLE IF EXISTS `gcd_reprint_from_issue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gcd_reprint_from_issue` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `source_issue_id` int(11) NOT NULL,
  `target_id` int(11) NOT NULL,
  `notes` longtext,
  `reserved` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `reprint_to_issue_from` (`source_issue_id`),
  KEY `reprint_to_issue_to` (`target_id`),
  KEY `reserved` (`reserved`),
  CONSTRAINT `gcd_reprint_from_issue_ibfk_1` FOREIGN KEY (`source_issue_id`) REFERENCES `gcd_issue` (`id`),
  CONSTRAINT `gcd_reprint_from_issue_ibfk_2` FOREIGN KEY (`target_id`) REFERENCES `gcd_story` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gcd_reprint_to_issue`
--

DROP TABLE IF EXISTS `gcd_reprint_to_issue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gcd_reprint_to_issue` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `source_id` int(11) NOT NULL,
  `target_issue_id` int(11) NOT NULL,
  `notes` longtext,
  `reserved` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `reprint_to_issue_from` (`source_id`),
  KEY `reprint_to_issue_to` (`target_issue_id`),
  KEY `reserved` (`reserved`),
  CONSTRAINT `gcd_reprint_to_issue_ibfk_1` FOREIGN KEY (`source_id`) REFERENCES `gcd_story` (`id`),
  CONSTRAINT `gcd_reprint_to_issue_ibfk_2` FOREIGN KEY (`target_issue_id`) REFERENCES `gcd_issue` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gcd_reservation`
--

DROP TABLE IF EXISTS `gcd_reservation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gcd_reservation` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `indexer_id` int(11) NOT NULL,
  `issue_id` int(11) NOT NULL,
  `status` int(11) NOT NULL,
  `expires` date DEFAULT NULL,
  `created` datetime DEFAULT '1901-01-01 00:00:00',
  PRIMARY KEY (`id`),
  KEY `IndexerID` (`indexer_id`),
  KEY `IssueID` (`issue_id`),
  KEY `Status` (`status`),
  CONSTRAINT `gcd_reservation_ibfk_1` FOREIGN KEY (`issue_id`) REFERENCES `gcd_issue` (`id`),
  CONSTRAINT `gcd_reservation_ibfk_2` FOREIGN KEY (`indexer_id`) REFERENCES `gcd_indexer` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=91466 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gcd_series`
--

DROP TABLE IF EXISTS `gcd_series`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gcd_series` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `format` varchar(255) NOT NULL DEFAULT '',
  `year_began` int(11) NOT NULL,
  `year_ended` int(11) DEFAULT NULL,
  `publication_dates` varchar(255) NOT NULL DEFAULT '',
  `first_issue_id` int(11) DEFAULT NULL,
  `last_issue_id` int(11) DEFAULT NULL,
  `is_current` tinyint(1) NOT NULL DEFAULT '0',
  `publisher_id` int(11) NOT NULL,
  `imprint_id` int(11) DEFAULT NULL,
  `country_id` int(11) NOT NULL,
  `language_id` int(11) NOT NULL,
  `tracking_notes` longtext NOT NULL,
  `notes` longtext NOT NULL,
  `publication_notes` longtext NOT NULL,
  `has_gallery` tinyint(1) NOT NULL DEFAULT '0',
  `open_reserve` int(11) DEFAULT NULL,
  `issue_count` int(11) NOT NULL DEFAULT '0',
  `created` datetime NOT NULL DEFAULT '1901-01-01 00:00:00',
  `modified` datetime NOT NULL DEFAULT '1901-01-01 00:00:00',
  `reserved` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `imprint_id` (`imprint_id`),
  KEY `PubID` (`publisher_id`),
  KEY `Bk_Name` (`name`(150)),
  KEY `Yr_Began` (`year_began`),
  KEY `HasGallery` (`has_gallery`),
  KEY `reserved` (`reserved`),
  KEY `country_id` (`country_id`),
  KEY `language_id` (`language_id`),
  KEY `first_issue_id` (`first_issue_id`),
  KEY `last_issue_id` (`last_issue_id`),
  CONSTRAINT `gcd_series_ibfk_3` FOREIGN KEY (`country_id`) REFERENCES `gcd_country` (`id`),
  CONSTRAINT `gcd_series_ibfk_4` FOREIGN KEY (`language_id`) REFERENCES `gcd_language` (`id`),
  CONSTRAINT `gcd_series_ibfk_5` FOREIGN KEY (`first_issue_id`) REFERENCES `gcd_issue` (`id`),
  CONSTRAINT `gcd_series_ibfk_6` FOREIGN KEY (`last_issue_id`) REFERENCES `gcd_issue` (`id`),
  CONSTRAINT `gcd_series_ibfk_1` FOREIGN KEY (`imprint_id`) REFERENCES `gcd_publisher` (`id`),
  CONSTRAINT `gcd_series_ibfk_2` FOREIGN KEY (`publisher_id`) REFERENCES `gcd_publisher` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=41177 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gcd_series_indexers`
--

DROP TABLE IF EXISTS `gcd_series_indexers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gcd_series_indexers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `indexer_id` int(11) NOT NULL,
  `series_id` int(11) NOT NULL,
  `run` varchar(255) DEFAULT NULL,
  `notes` longtext,
  `modified` datetime NOT NULL DEFAULT '1901-01-01 00:00:00',
  PRIMARY KEY (`id`),
  KEY `IndexerID` (`indexer_id`),
  KEY `SeriesID` (`series_id`),
  CONSTRAINT `gcd_series_indexers_ibfk_1` FOREIGN KEY (`series_id`) REFERENCES `gcd_series` (`id`),
  CONSTRAINT `gcd_series_indexers_ibfk_2` FOREIGN KEY (`indexer_id`) REFERENCES `gcd_indexer` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=26238 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gcd_series_relationship`
--

DROP TABLE IF EXISTS `gcd_series_relationship`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gcd_series_relationship` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `source_id` int(11) NOT NULL,
  `target_id` int(11) NOT NULL,
  `source_issue_id` int(11) DEFAULT NULL,
  `target_issue_id` int(11) DEFAULT NULL,
  `link_type_id` int(11) NOT NULL,
  `notes` longtext,
  PRIMARY KEY (`id`),
  KEY `key_source` (`source_id`),
  KEY `key_target` (`target_id`),
  KEY `key_issue_source` (`source_issue_id`),
  KEY `key_issue_target` (`target_issue_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gcd_series_relationship_type`
--

DROP TABLE IF EXISTS `gcd_series_relationship_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gcd_series_relationship_type` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `description` longtext,
  `reserved` tinyint(1) NOT NULL DEFAULT '0',
  `notes` longtext,
  PRIMARY KEY (`id`),
  KEY `key_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gcd_story`
--

DROP TABLE IF EXISTS `gcd_story`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gcd_story` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL DEFAULT '',
  `title_inferred` tinyint(1) NOT NULL DEFAULT '0',
  `feature` varchar(255) NOT NULL,
  `sequence_number` int(11) NOT NULL,
  `page_count` decimal(10,3) DEFAULT NULL,
  `issue_id` int(11) NOT NULL,
  `script` longtext NOT NULL,
  `pencils` longtext NOT NULL,
  `inks` longtext NOT NULL,
  `colors` longtext NOT NULL,
  `letters` longtext NOT NULL,
  `editing` longtext NOT NULL,
  `genre` varchar(255) NOT NULL DEFAULT '',
  `characters` longtext NOT NULL,
  `synopsis` longtext NOT NULL,
  `reprint_notes` longtext NOT NULL,
  `created` datetime NOT NULL DEFAULT '1901-01-01 00:00:00',
  `modified` datetime NOT NULL DEFAULT '1901-01-01 00:00:00',
  `notes` longtext NOT NULL,
  `no_script` tinyint(1) NOT NULL DEFAULT '0',
  `no_pencils` tinyint(1) NOT NULL DEFAULT '0',
  `no_inks` tinyint(1) NOT NULL DEFAULT '0',
  `no_colors` tinyint(1) NOT NULL DEFAULT '0',
  `no_letters` tinyint(1) NOT NULL DEFAULT '0',
  `no_editing` tinyint(1) NOT NULL DEFAULT '0',
  `page_count_uncertain` tinyint(1) NOT NULL DEFAULT '0',
  `type_id` int(11) NOT NULL,
  `job_number` varchar(25) NOT NULL DEFAULT '',
  `reserved` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `IssueID` (`issue_id`),
  KEY `Modified` (`modified`),
  KEY `no_script` (`no_script`),
  KEY `no_pencils` (`no_pencils`),
  KEY `no_inks` (`no_inks`),
  KEY `no_colors` (`no_colors`),
  KEY `no_letters` (`no_letters`),
  KEY `page_count_uncertain` (`page_count_uncertain`),
  KEY `reserved` (`reserved`),
  KEY `Pg_Cnt` (`page_count`),
  KEY `no_editing` (`no_editing`),
  KEY `type_id` (`type_id`),
  CONSTRAINT `gcd_story_ibfk_2` FOREIGN KEY (`type_id`) REFERENCES `gcd_story_type` (`id`),
  CONSTRAINT `gcd_story_ibfk_1` FOREIGN KEY (`issue_id`) REFERENCES `gcd_issue` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=807255 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gcd_story_type`
--

DROP TABLE IF EXISTS `gcd_story_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gcd_story_type` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `sort_code` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  UNIQUE KEY `sort_code` (`sort_code`),
  KEY `type_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `migration_story_status`
--

DROP TABLE IF EXISTS `migration_story_status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `migration_story_status` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `story_id` int(11) NOT NULL,
  `reprint_needs_inspection` tinyint(1) DEFAULT NULL,
  `reprint_confirmed` tinyint(1) DEFAULT NULL,
  `reprint_original_notes` longtext,
  PRIMARY KEY (`id`),
  KEY `key_reprint_needs_inspection` (`reprint_needs_inspection`),
  KEY `key_reprint_confirmed` (`reprint_confirmed`),
  KEY `key_reprint_notes` (`reprint_original_notes`(255))
) ENGINE=InnoDB AUTO_INCREMENT=746995 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `oi_brand_revision`
--

DROP TABLE IF EXISTS `oi_brand_revision`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oi_brand_revision` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `changeset_id` int(11) NOT NULL,
  `deleted` tinyint(1) NOT NULL,
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL,
  `name` varchar(255) NOT NULL,
  `year_began` int(11) DEFAULT NULL,
  `year_ended` int(11) DEFAULT NULL,
  `notes` longtext NOT NULL,
  `url` varchar(200) NOT NULL,
  `brand_id` int(11) DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `oi_brand_revision_changeset_id` (`changeset_id`),
  KEY `oi_brand_revision_created` (`created`),
  KEY `oi_brand_revision_modified` (`modified`),
  KEY `oi_brand_revision_name` (`name`),
  KEY `oi_brand_revision_year_began` (`year_began`),
  KEY `oi_brand_revision_brand_id` (`brand_id`),
  KEY `oi_brand_revision_parent_id` (`parent_id`),
  CONSTRAINT `brand_id_refs_id_c8ffcf5d` FOREIGN KEY (`brand_id`) REFERENCES `gcd_brand` (`id`),
  CONSTRAINT `changeset_id_refs_id_2d345f53` FOREIGN KEY (`changeset_id`) REFERENCES `oi_changeset` (`id`),
  CONSTRAINT `parent_id_refs_id_98d9d082` FOREIGN KEY (`parent_id`) REFERENCES `gcd_publisher` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=263 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `oi_changeset`
--

DROP TABLE IF EXISTS `oi_changeset`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oi_changeset` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `state` int(11) NOT NULL,
  `indexer_id` int(11) NOT NULL,
  `approver_id` int(11) DEFAULT NULL,
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `oi_changeset_state` (`state`),
  KEY `oi_changeset_indexer_id` (`indexer_id`),
  KEY `oi_changeset_approver_id` (`approver_id`),
  KEY `oi_changeset_created` (`created`),
  KEY `oi_changeset_modified` (`modified`),
  CONSTRAINT `approver_id_refs_id_a70e5f0d` FOREIGN KEY (`approver_id`) REFERENCES `auth_user` (`id`),
  CONSTRAINT `indexer_id_refs_id_a70e5f0d` FOREIGN KEY (`indexer_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15046 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `oi_changeset_along_with`
--

DROP TABLE IF EXISTS `oi_changeset_along_with`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oi_changeset_along_with` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `changeset_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `changeset_id` (`changeset_id`,`user_id`),
  KEY `user_id_refs_id_3eb9b55` (`user_id`),
  CONSTRAINT `user_id_refs_id_3eb9b55` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`),
  CONSTRAINT `changeset_id_refs_id_c3156f2b` FOREIGN KEY (`changeset_id`) REFERENCES `oi_changeset` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `oi_changeset_comment`
--

DROP TABLE IF EXISTS `oi_changeset_comment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oi_changeset_comment` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `commenter_id` int(11) NOT NULL,
  `text` longtext NOT NULL,
  `changeset_id` int(11) NOT NULL,
  `old_state` int(11) NOT NULL,
  `new_state` int(11) NOT NULL,
  `created` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `oi_changeset_comment_commenter_id` (`commenter_id`),
  KEY `oi_changeset_comment_changeset_id` (`changeset_id`),
  CONSTRAINT `changeset_id_refs_id_4813e053` FOREIGN KEY (`changeset_id`) REFERENCES `oi_changeset` (`id`),
  CONSTRAINT `commenter_id_refs_id_b0d742d3` FOREIGN KEY (`commenter_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=47235 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `oi_changeset_on_behalf_of`
--

DROP TABLE IF EXISTS `oi_changeset_on_behalf_of`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oi_changeset_on_behalf_of` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `changeset_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `changeset_id` (`changeset_id`,`user_id`),
  KEY `user_id_refs_id_57abaec1` (`user_id`),
  CONSTRAINT `user_id_refs_id_57abaec1` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`),
  CONSTRAINT `changeset_id_refs_id_d2c93441` FOREIGN KEY (`changeset_id`) REFERENCES `oi_changeset` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `oi_indicia_publisher_revision`
--

DROP TABLE IF EXISTS `oi_indicia_publisher_revision`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oi_indicia_publisher_revision` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `changeset_id` int(11) NOT NULL,
  `deleted` tinyint(1) NOT NULL,
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL,
  `name` varchar(255) NOT NULL,
  `year_began` int(11) DEFAULT NULL,
  `year_ended` int(11) DEFAULT NULL,
  `notes` longtext NOT NULL,
  `url` varchar(200) NOT NULL,
  `indicia_publisher_id` int(11) DEFAULT NULL,
  `is_surrogate` tinyint(1) NOT NULL,
  `country_id` int(11) NOT NULL,
  `parent_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `oi_indicia_publisher_revision_changeset_id` (`changeset_id`),
  KEY `oi_indicia_publisher_revision_created` (`created`),
  KEY `oi_indicia_publisher_revision_modified` (`modified`),
  KEY `oi_indicia_publisher_revision_name` (`name`),
  KEY `oi_indicia_publisher_revision_year_began` (`year_began`),
  KEY `oi_indicia_publisher_revision_indicia_publisher_id` (`indicia_publisher_id`),
  KEY `oi_indicia_publisher_revision_is_surrogate` (`is_surrogate`),
  KEY `oi_indicia_publisher_revision_country_id` (`country_id`),
  KEY `oi_indicia_publisher_revision_parent_id` (`parent_id`),
  CONSTRAINT `changeset_id_refs_id_f792c29a` FOREIGN KEY (`changeset_id`) REFERENCES `oi_changeset` (`id`),
  CONSTRAINT `country_id_refs_id_751b8f5f` FOREIGN KEY (`country_id`) REFERENCES `gcd_country` (`id`),
  CONSTRAINT `indicia_publisher_id_refs_id_52542785` FOREIGN KEY (`indicia_publisher_id`) REFERENCES `gcd_indicia_publisher` (`id`),
  CONSTRAINT `parent_id_refs_id_967d78e9` FOREIGN KEY (`parent_id`) REFERENCES `gcd_publisher` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=299 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `oi_issue_revision`
--

DROP TABLE IF EXISTS `oi_issue_revision`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oi_issue_revision` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `changeset_id` int(11) NOT NULL,
  `deleted` tinyint(1) NOT NULL,
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL,
  `issue_id` int(11) DEFAULT NULL,
  `after_id` int(11) DEFAULT NULL,
  `revision_sort_code` int(11) DEFAULT NULL,
  `reservation_requested` tinyint(1) NOT NULL,
  `number` varchar(50) NOT NULL,
  `volume` int(11) DEFAULT NULL,
  `no_volume` tinyint(1) NOT NULL,
  `display_volume_with_number` tinyint(1) NOT NULL,
  `publication_date` varchar(255) NOT NULL,
  `indicia_frequency` varchar(255) NOT NULL,
  `key_date` varchar(10) NOT NULL,
  `price` varchar(255) NOT NULL,
  `page_count` decimal(10,3) DEFAULT NULL,
  `page_count_uncertain` tinyint(1) NOT NULL,
  `editing` longtext NOT NULL,
  `no_editing` tinyint(1) NOT NULL,
  `notes` longtext NOT NULL,
  `series_id` int(11) NOT NULL,
  `indicia_publisher_id` int(11) DEFAULT NULL,
  `brand_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `oi_issue_revision_changeset_id` (`changeset_id`),
  KEY `oi_issue_revision_created` (`created`),
  KEY `oi_issue_revision_modified` (`modified`),
  KEY `oi_issue_revision_issue_id` (`issue_id`),
  KEY `oi_issue_revision_after_id` (`after_id`),
  KEY `oi_issue_revision_series_id` (`series_id`),
  KEY `oi_issue_revision_indicia_publisher_id` (`indicia_publisher_id`),
  KEY `oi_issue_revision_brand_id` (`brand_id`),
  CONSTRAINT `after_id_refs_id_8ccb9867` FOREIGN KEY (`after_id`) REFERENCES `gcd_issue` (`id`),
  CONSTRAINT `brand_id_refs_id_3a28006f` FOREIGN KEY (`brand_id`) REFERENCES `gcd_brand` (`id`),
  CONSTRAINT `changeset_id_refs_id_238d3bc1` FOREIGN KEY (`changeset_id`) REFERENCES `oi_changeset` (`id`),
  CONSTRAINT `indicia_publisher_id_refs_id_2d8053dc` FOREIGN KEY (`indicia_publisher_id`) REFERENCES `gcd_indicia_publisher` (`id`),
  CONSTRAINT `issue_id_refs_id_8ccb9867` FOREIGN KEY (`issue_id`) REFERENCES `gcd_issue` (`id`),
  CONSTRAINT `series_id_refs_id_543abcb6` FOREIGN KEY (`series_id`) REFERENCES `gcd_series` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=26241 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `oi_ongoing_reservation`
--

DROP TABLE IF EXISTS `oi_ongoing_reservation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oi_ongoing_reservation` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `indexer_id` int(11) NOT NULL,
  `series_id` int(11) NOT NULL,
  `created` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `series_id` (`series_id`),
  KEY `oi_ongoing_reservation_indexer_id` (`indexer_id`),
  KEY `oi_ongoing_reservation_created` (`created`),
  CONSTRAINT `indexer_id_refs_id_7cb1471` FOREIGN KEY (`indexer_id`) REFERENCES `auth_user` (`id`),
  CONSTRAINT `series_id_refs_id_8a6346ac` FOREIGN KEY (`series_id`) REFERENCES `gcd_series` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=121 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `oi_ongoing_reservation_along_with`
--

DROP TABLE IF EXISTS `oi_ongoing_reservation_along_with`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oi_ongoing_reservation_along_with` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ongoingreservation_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ongoingreservation_id` (`ongoingreservation_id`,`user_id`),
  KEY `user_id_refs_id_24a08f75` (`user_id`),
  CONSTRAINT `user_id_refs_id_24a08f75` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`),
  CONSTRAINT `ongoingreservation_id_refs_id_6dd0811` FOREIGN KEY (`ongoingreservation_id`) REFERENCES `oi_ongoing_reservation` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `oi_ongoing_reservation_on_behalf_of`
--

DROP TABLE IF EXISTS `oi_ongoing_reservation_on_behalf_of`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oi_ongoing_reservation_on_behalf_of` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ongoingreservation_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ongoingreservation_id` (`ongoingreservation_id`,`user_id`),
  KEY `user_id_refs_id_dda58cb5` (`user_id`),
  CONSTRAINT `user_id_refs_id_dda58cb5` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`),
  CONSTRAINT `ongoingreservation_id_refs_id_4ed5a3e7` FOREIGN KEY (`ongoingreservation_id`) REFERENCES `oi_ongoing_reservation` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `oi_publisher_revision`
--

DROP TABLE IF EXISTS `oi_publisher_revision`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oi_publisher_revision` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `changeset_id` int(11) NOT NULL,
  `deleted` tinyint(1) NOT NULL,
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL,
  `name` varchar(255) NOT NULL,
  `year_began` int(11) DEFAULT NULL,
  `year_ended` int(11) DEFAULT NULL,
  `notes` longtext NOT NULL,
  `url` varchar(200) NOT NULL,
  `publisher_id` int(11) DEFAULT NULL,
  `country_id` int(11) NOT NULL,
  `is_master` tinyint(1) NOT NULL,
  `parent_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `oi_publisher_revision_changeset_id` (`changeset_id`),
  KEY `oi_publisher_revision_created` (`created`),
  KEY `oi_publisher_revision_modified` (`modified`),
  KEY `oi_publisher_revision_name` (`name`),
  KEY `oi_publisher_revision_year_began` (`year_began`),
  KEY `oi_publisher_revision_publisher_id` (`publisher_id`),
  KEY `oi_publisher_revision_country_id` (`country_id`),
  KEY `oi_publisher_revision_is_master` (`is_master`),
  KEY `oi_publisher_revision_parent_id` (`parent_id`),
  CONSTRAINT `changeset_id_refs_id_7bde1992` FOREIGN KEY (`changeset_id`) REFERENCES `oi_changeset` (`id`),
  CONSTRAINT `country_id_refs_id_b606b4d9` FOREIGN KEY (`country_id`) REFERENCES `gcd_country` (`id`),
  CONSTRAINT `parent_id_refs_id_e91cce4f` FOREIGN KEY (`parent_id`) REFERENCES `gcd_publisher` (`id`),
  CONSTRAINT `publisher_id_refs_id_e91cce4f` FOREIGN KEY (`publisher_id`) REFERENCES `gcd_publisher` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=603 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `oi_series_revision`
--

DROP TABLE IF EXISTS `oi_series_revision`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oi_series_revision` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `changeset_id` int(11) NOT NULL,
  `deleted` tinyint(1) NOT NULL,
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL,
  `series_id` int(11) DEFAULT NULL,
  `reservation_requested` tinyint(1) NOT NULL,
  `name` varchar(255) NOT NULL,
  `format` varchar(255) NOT NULL,
  `year_began` int(11) NOT NULL,
  `year_ended` int(11) DEFAULT NULL,
  `is_current` tinyint(1) NOT NULL,
  `publication_notes` longtext NOT NULL,
  `tracking_notes` longtext NOT NULL,
  `notes` longtext NOT NULL,
  `country_id` int(11) NOT NULL,
  `language_id` int(11) NOT NULL,
  `publisher_id` int(11) NOT NULL,
  `imprint_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `oi_series_revision_changeset_id` (`changeset_id`),
  KEY `oi_series_revision_created` (`created`),
  KEY `oi_series_revision_modified` (`modified`),
  KEY `oi_series_revision_series_id` (`series_id`),
  KEY `oi_series_revision_country_id` (`country_id`),
  KEY `oi_series_revision_language_id` (`language_id`),
  KEY `oi_series_revision_publisher_id` (`publisher_id`),
  KEY `oi_series_revision_imprint_id` (`imprint_id`),
  CONSTRAINT `changeset_id_refs_id_9def20fa` FOREIGN KEY (`changeset_id`) REFERENCES `oi_changeset` (`id`),
  CONSTRAINT `country_id_refs_id_f63cc241` FOREIGN KEY (`country_id`) REFERENCES `gcd_country` (`id`),
  CONSTRAINT `imprint_id_refs_id_74f29cb7` FOREIGN KEY (`imprint_id`) REFERENCES `gcd_publisher` (`id`),
  CONSTRAINT `language_id_refs_id_57d8edc` FOREIGN KEY (`language_id`) REFERENCES `gcd_language` (`id`),
  CONSTRAINT `publisher_id_refs_id_74f29cb7` FOREIGN KEY (`publisher_id`) REFERENCES `gcd_publisher` (`id`),
  CONSTRAINT `series_id_refs_id_360da84b` FOREIGN KEY (`series_id`) REFERENCES `gcd_series` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1653 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `oi_story_revision`
--

DROP TABLE IF EXISTS `oi_story_revision`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oi_story_revision` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `changeset_id` int(11) NOT NULL,
  `deleted` tinyint(1) NOT NULL,
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL,
  `story_id` int(11) DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  `title_inferred` tinyint(1) NOT NULL,
  `feature` varchar(255) NOT NULL,
  `type_id` int(11) NOT NULL,
  `sequence_number` int(11) NOT NULL,
  `page_count` decimal(10,3) DEFAULT NULL,
  `page_count_uncertain` tinyint(1) NOT NULL,
  `script` longtext NOT NULL,
  `pencils` longtext NOT NULL,
  `inks` longtext NOT NULL,
  `colors` longtext NOT NULL,
  `letters` longtext NOT NULL,
  `editing` longtext NOT NULL,
  `no_script` tinyint(1) NOT NULL,
  `no_pencils` tinyint(1) NOT NULL,
  `no_inks` tinyint(1) NOT NULL,
  `no_colors` tinyint(1) NOT NULL,
  `no_letters` tinyint(1) NOT NULL,
  `no_editing` tinyint(1) NOT NULL,
  `job_number` varchar(25) NOT NULL,
  `genre` varchar(255) NOT NULL,
  `characters` longtext NOT NULL,
  `synopsis` longtext NOT NULL,
  `reprint_notes` longtext NOT NULL,
  `notes` longtext NOT NULL,
  `issue_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `oi_story_revision_changeset_id` (`changeset_id`),
  KEY `oi_story_revision_created` (`created`),
  KEY `oi_story_revision_modified` (`modified`),
  KEY `oi_story_revision_story_id` (`story_id`),
  KEY `oi_story_revision_title_inferred` (`title_inferred`),
  KEY `oi_story_revision_type_id` (`type_id`),
  KEY `oi_story_revision_issue_id` (`issue_id`),
  CONSTRAINT `changeset_id_refs_id_e56586c1` FOREIGN KEY (`changeset_id`) REFERENCES `oi_changeset` (`id`),
  CONSTRAINT `issue_id_refs_id_eb9b5367` FOREIGN KEY (`issue_id`) REFERENCES `gcd_issue` (`id`),
  CONSTRAINT `story_id_refs_id_e9dc26ed` FOREIGN KEY (`story_id`) REFERENCES `gcd_story` (`id`),
  CONSTRAINT `type_id_refs_id_b33b3b9b` FOREIGN KEY (`type_id`) REFERENCES `gcd_story_type` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=42390 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2010-01-10 15:14:19
