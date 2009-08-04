-- MySQL dump 10.11
--
-- Host: localhost    Database: gcd_scratch_25
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
-- Table structure for table `accounts_indexer`
--

DROP TABLE IF EXISTS `accounts_indexer`;
CREATE TABLE `accounts_indexer` (
  `id` int(11) NOT NULL auto_increment,
  `username` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `country_code` varchar(255) default NULL,
  `email` varchar(255) default NULL,
  `given_name` varchar(255) default NULL,
  `family_name` varchar(255) default NULL,
  `name_order` tinyint(1) default '0',
  `user_level` int(11) NOT NULL default '0',
  `active` tinyint(1) NOT NULL default '1',
  `message` mediumtext,
  `created` datetime NOT NULL default '1901-01-01 00:00:00',
  `modified` datetime NOT NULL default '1901-01-01 00:00:00',
  PRIMARY KEY  (`id`),
  KEY `LastName` (`family_name`),
  KEY `FirstName` (`given_name`),
  KEY `eMail` (`email`),
  KEY `username` (`username`),
  KEY `password` (`password`)
) ENGINE=MyISAM AUTO_INCREMENT=546 DEFAULT CHARSET=utf8;

--
-- Table structure for table `data_address`
--

DROP TABLE IF EXISTS `data_address`;
CREATE TABLE `data_address` (
  `id` int(11) NOT NULL auto_increment,
  `address` mediumtext,
  `country_id` int(11) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `key_address` (`address`(255)),
  KEY `key_country` (`country_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Table structure for table `data_address_purpose`
--

DROP TABLE IF EXISTS `data_address_purpose`;
CREATE TABLE `data_address_purpose` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(100) NOT NULL,
  `description` mediumtext,
  PRIMARY KEY  (`id`),
  KEY `key_name` (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Table structure for table `data_classification`
--

DROP TABLE IF EXISTS `data_classification`;
CREATE TABLE `data_classification` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  `description` mediumtext,
  PRIMARY KEY  (`id`),
  KEY `key_name` (`name`)
) ENGINE=MyISAM AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;

--
-- Table structure for table `data_country`
--

DROP TABLE IF EXISTS `data_country`;
CREATE TABLE `data_country` (
  `id` int(11) NOT NULL auto_increment,
  `code` varchar(10) NOT NULL,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `code_2` (`code`),
  KEY `code` (`code`),
  KEY `country` (`name`(50))
) ENGINE=MyISAM AUTO_INCREMENT=249 DEFAULT CHARSET=utf8;

--
-- Table structure for table `data_currency`
--

DROP TABLE IF EXISTS `data_currency`;
CREATE TABLE `data_currency` (
  `id` int(11) NOT NULL auto_increment,
  `code` char(3) NOT NULL,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `key_code` (`code`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Table structure for table `data_descriptor_label`
--

DROP TABLE IF EXISTS `data_descriptor_label`;
CREATE TABLE `data_descriptor_label` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  `for_item` tinyint(1) NOT NULL default '1',
  `for_group` tinyint(1) NOT NULL default '0',
  PRIMARY KEY  (`id`),
  KEY `key_name` (`name`),
  KEY `key_item` (`for_item`),
  KEY `key_group` (`for_group`)
) ENGINE=MyISAM AUTO_INCREMENT=10 DEFAULT CHARSET=utf8;

--
-- Table structure for table `data_item`
--

DROP TABLE IF EXISTS `data_item`;
CREATE TABLE `data_item` (
  `id` int(11) NOT NULL auto_increment,
  `publication_date` varchar(255) default NULL,
  `publication_year` int(11) default NULL,
  `publication_year_inferred` tinyint(1) NOT NULL default '0',
  `publication_second_year` int(11) default NULL,
  `publication_second_year_inferred` tinyint(1) NOT NULL default '0',
  `publication_month_id` int(11) default NULL,
  `publication_month_modifier` enum('early','mid','late') default NULL,
  `publication_month_modifier_inferred` tinyint(1) NOT NULL default '0',
  `publication_month_inferred` tinyint(1) NOT NULL default '0',
  `publication_day` int(11) default NULL,
  `publication_day_inferred` tinyint(1) NOT NULL default '0',
  `indicia_frequency` varchar(255) default NULL,
  `size_id` int(11) default NULL,
  `height` decimal(10,3) default NULL,
  `width` decimal(10,3) default NULL,
  `size_in_metric` tinyint(1) default '1',
  `interior_paper_id` int(11) default NULL,
  `cover_paper_id` int(11) default NULL,
  `binding_id` int(11) default NULL,
  `price` varchar(255) default NULL,
  `page_count` varchar(10) default NULL,
  `editing` mediumtext,
  `notes` mediumtext,
  `sequence_count` int(11) NOT NULL default '0',
  `created` datetime NOT NULL default '1901-01-01 00:00:00',
  `modified` datetime NOT NULL default '1901-01-01 00:00:00',
  PRIMARY KEY  (`id`),
  KEY `item_pub_year` (`publication_year`),
  KEY `item_pub_month_id` (`publication_month_id`),
  KEY `item_pub_month_mod` (`publication_month_modifier`),
  KEY `item_pub_day` (`publication_day`),
  KEY `item_indicia_freq` (`indicia_frequency`),
  KEY `item_size` (`size_id`)
) ENGINE=MyISAM AUTO_INCREMENT=669195 DEFAULT CHARSET=utf8;

--
-- Table structure for table `data_item_brand`
--

DROP TABLE IF EXISTS `data_item_brand`;
CREATE TABLE `data_item_brand` (
  `id` int(11) NOT NULL auto_increment,
  `item_id` int(11) NOT NULL,
  `brand_id` int(11) NOT NULL,
  `emblem_id` int(11) default NULL,
  `notes` mediumtext,
  PRIMARY KEY  (`id`),
  KEY `key_item_id` (`item_id`),
  KEY `key_brand_id` (`brand_id`),
  KEY `key_emblem_id` (`emblem_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Table structure for table `data_item_descriptor`
--

DROP TABLE IF EXISTS `data_item_descriptor`;
CREATE TABLE `data_item_descriptor` (
  `id` int(11) NOT NULL auto_increment,
  `series_item_id` int(11) NOT NULL,
  `scope` enum('item','group') NOT NULL default 'item',
  `label_id` int(11) NOT NULL,
  `source_id` int(11) NOT NULL,
  `value` varchar(255) default NULL,
  PRIMARY KEY  (`id`),
  KEY `key_series_item` (`series_item_id`),
  KEY `key_scope` (`scope`),
  KEY `key_label` (`label_id`),
  KEY `key_source` (`source_id`),
  KEY `key_value` (`value`)
) ENGINE=MyISAM AUTO_INCREMENT=921099 DEFAULT CHARSET=utf8;

--
-- Table structure for table `data_item_distributor`
--

DROP TABLE IF EXISTS `data_item_distributor`;
CREATE TABLE `data_item_distributor` (
  `id` int(11) NOT NULL auto_increment,
  `item_id` int(11) NOT NULL,
  `distributor_id` int(11) NOT NULL,
  `emblem_id` int(11) default NULL,
  `code` varchar(50) default NULL,
  `source_id` int(11) NOT NULL,
  `notes` mediumtext,
  PRIMARY KEY  (`id`),
  KEY `key_item` (`item_id`),
  KEY `key_dist` (`distributor_id`),
  KEY `key_emblem` (`emblem_id`),
  KEY `key_code` (`code`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Table structure for table `data_item_price`
--

DROP TABLE IF EXISTS `data_item_price`;
CREATE TABLE `data_item_price` (
  `id` int(11) NOT NULL auto_increment,
  `value` decimal(10,3) default NULL,
  `non_decimal_value` varchar(25) default NULL,
  `currency_id` int(11) NOT NULL,
  `country_id` int(11) default NULL,
  `notes` mediumtext,
  PRIMARY KEY  (`id`),
  KEY `value` (`value`),
  KEY `non_decimal` (`non_decimal_value`),
  KEY `currency` (`currency_id`),
  KEY `country` (`country_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Table structure for table `data_item_publisher`
--

DROP TABLE IF EXISTS `data_item_publisher`;
CREATE TABLE `data_item_publisher` (
  `id` int(11) NOT NULL auto_increment,
  `item_id` int(11) NOT NULL,
  `publisher_id` int(11) NOT NULL,
  `uncertain` tinyint(1) NOT NULL default '0',
  `inferred` tinyint(1) NOT NULL default '0',
  `notes` mediumtext,
  PRIMARY KEY  (`id`),
  KEY `key_item_id` (`item_id`),
  KEY `key_publisher_id` (`publisher_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Table structure for table `data_item_publisher_address`
--

DROP TABLE IF EXISTS `data_item_publisher_address`;
CREATE TABLE `data_item_publisher_address` (
  `id` int(11) NOT NULL auto_increment,
  `item_publisher_id` int(11) NOT NULL,
  `publisher_address_id` int(11) NOT NULL,
  `purpose_id` int(11) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `key_item` (`item_publisher_id`),
  KEY `key_address` (`publisher_address_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Table structure for table `data_item_reprint`
--

DROP TABLE IF EXISTS `data_item_reprint`;
CREATE TABLE `data_item_reprint` (
  `id` int(11) NOT NULL auto_increment,
  `source_item_id` int(11) NOT NULL,
  `target_item_id` int(11) NOT NULL,
  `notes` mediumtext,
  PRIMARY KEY  (`id`),
  KEY `item_from` (`source_item_id`),
  KEY `item_to` (`target_item_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Table structure for table `data_item_sequence`
--

DROP TABLE IF EXISTS `data_item_sequence`;
CREATE TABLE `data_item_sequence` (
  `id` int(11) NOT NULL auto_increment,
  `item_id` int(11) NOT NULL,
  `sequence_id` int(11) NOT NULL,
  `sort_code` int(11) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `key_item` (`item_id`),
  KEY `key_sequence` (`sequence_id`)
) ENGINE=MyISAM AUTO_INCREMENT=714243 DEFAULT CHARSET=utf8;

--
-- Table structure for table `data_language`
--

DROP TABLE IF EXISTS `data_language`;
CREATE TABLE `data_language` (
  `id` int(11) NOT NULL auto_increment,
  `code` varchar(10) NOT NULL,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `code_2` (`code`),
  KEY `code` (`code`),
  KEY `language` (`name`(10))
) ENGINE=MyISAM AUTO_INCREMENT=145 DEFAULT CHARSET=utf8;

--
-- Table structure for table `data_price_type`
--

DROP TABLE IF EXISTS `data_price_type`;
CREATE TABLE `data_price_type` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(100) NOT NULL,
  `description` mediumtext,
  PRIMARY KEY  (`id`),
  KEY `key_name` (`name`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

--
-- Table structure for table `data_publisher`
--

DROP TABLE IF EXISTS `data_publisher`;
CREATE TABLE `data_publisher` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  `country_id` int(11) default NULL,
  `year_began` int(11) default NULL,
  `year_ended` int(11) default NULL,
  `notes` mediumtext,
  `url` varchar(255) default NULL,
  `is_master` tinyint(1) NOT NULL,
  `is_company` tinyint(1) NOT NULL,
  `is_brand` tinyint(1) NOT NULL,
  `is_distributor` tinyint(1) NOT NULL,
  `series_count` int(11) NOT NULL default '0',
  `item_count` int(11) NOT NULL default '0',
  `created` datetime NOT NULL default '1901-01-01 00:00:00',
  `modified` datetime NOT NULL default '1901-01-01 00:00:00',
  PRIMARY KEY  (`id`),
  KEY `PubName` (`name`),
  KEY `Master` (`is_master`),
  KEY `YearBegan` (`year_began`),
  KEY `country` (`country_id`),
  KEY `is_company` (`is_company`),
  KEY `is_brand` (`is_brand`)
) ENGINE=MyISAM AUTO_INCREMENT=5329 DEFAULT CHARSET=utf8;

--
-- Table structure for table `data_publisher_address`
--

DROP TABLE IF EXISTS `data_publisher_address`;
CREATE TABLE `data_publisher_address` (
  `id` int(11) NOT NULL auto_increment,
  `publisher_id` int(11) NOT NULL,
  `address_id` int(11) NOT NULL,
  `notes` mediumtext,
  PRIMARY KEY  (`id`),
  KEY `key_publisher_id` (`publisher_id`),
  KEY `key_address_id` (`address_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Table structure for table `data_publisher_emblem`
--

DROP TABLE IF EXISTS `data_publisher_emblem`;
CREATE TABLE `data_publisher_emblem` (
  `id` int(11) NOT NULL auto_increment,
  `publisher_id` int(11) NOT NULL,
  `emblem_id` int(11) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `key_publisher_id` (`publisher_id`),
  KEY `key_emblem_id` (`emblem_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Table structure for table `data_publisher_relationship`
--

DROP TABLE IF EXISTS `data_publisher_relationship`;
CREATE TABLE `data_publisher_relationship` (
  `id` int(11) NOT NULL auto_increment,
  `relating_id` int(11) NOT NULL,
  `related_id` int(11) NOT NULL,
  `link_type_id` int(11) NOT NULL,
  `notes` mediumtext,
  PRIMARY KEY  (`id`),
  KEY `key_relating` (`relating_id`),
  KEY `key_related` (`related_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1045 DEFAULT CHARSET=utf8;

--
-- Table structure for table `data_publisher_relationship_type`
--

DROP TABLE IF EXISTS `data_publisher_relationship_type`;
CREATE TABLE `data_publisher_relationship_type` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(100) NOT NULL,
  `description` mediumtext,
  PRIMARY KEY  (`id`),
  KEY `key_name` (`name`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

--
-- Table structure for table `data_reprint`
--

DROP TABLE IF EXISTS `data_reprint`;
CREATE TABLE `data_reprint` (
  `id` int(11) NOT NULL auto_increment,
  `source_id` int(11) NOT NULL,
  `target_id` int(11) NOT NULL,
  `notes` mediumtext,
  PRIMARY KEY  (`id`),
  KEY `reprint_from` (`source_id`),
  KEY `reprint_to` (`target_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Table structure for table `data_reprint_from_item`
--

DROP TABLE IF EXISTS `data_reprint_from_item`;
CREATE TABLE `data_reprint_from_item` (
  `id` int(11) NOT NULL auto_increment,
  `source_item_id` int(11) NOT NULL,
  `target_id` int(11) NOT NULL,
  `notes` mediumtext,
  PRIMARY KEY  (`id`),
  KEY `reprint_to_item_from` (`source_item_id`),
  KEY `reprint_to_item_to` (`target_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Table structure for table `data_reprint_to_item`
--

DROP TABLE IF EXISTS `data_reprint_to_item`;
CREATE TABLE `data_reprint_to_item` (
  `id` int(11) NOT NULL auto_increment,
  `source_id` int(11) NOT NULL,
  `target_item_id` int(11) NOT NULL,
  `notes` mediumtext,
  PRIMARY KEY  (`id`),
  KEY `reprint_to_item_from` (`source_id`),
  KEY `reprint_to_item_to` (`target_item_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Table structure for table `data_sequence`
--

DROP TABLE IF EXISTS `data_sequence`;
CREATE TABLE `data_sequence` (
  `id` int(11) NOT NULL auto_increment,
  `title` varchar(255) default NULL,
  `title_inferred` tinyint(1) NOT NULL default '0',
  `feature` varchar(255) default NULL,
  `page_count` varchar(10) default NULL,
  `type_id` int(11) default NULL,
  `color_type_id` int(11) default NULL,
  `job_number` varchar(25) default NULL,
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
  `created` datetime NOT NULL default '1901-01-01 00:00:00',
  `modified` datetime NOT NULL default '1901-01-01 00:00:00',
  `notes` mediumtext,
  PRIMARY KEY  (`id`),
  KEY `Title` (`title`),
  KEY `Script` (`script`(255)),
  KEY `Pencils` (`pencils`(255)),
  KEY `Inks` (`inks`(255)),
  KEY `Colors` (`colors`(255)),
  KEY `Letters` (`letters`(255)),
  KEY `Editing` (`editing`(255)),
  KEY `Char_App` (`characters`(255)),
  KEY `JobNo` (`job_number`(15)),
  KEY `Feature` (`feature`),
  KEY `Modified` (`modified`),
  KEY `sequence_type` (`type_id`),
  KEY `key_title_inferred` (`title_inferred`),
  KEY `sequence_genre` (`genre`)
) ENGINE=MyISAM AUTO_INCREMENT=786145 DEFAULT CHARSET=utf8;

--
-- Table structure for table `data_sequence_type`
--

DROP TABLE IF EXISTS `data_sequence_type`;
CREATE TABLE `data_sequence_type` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `name` (`name`),
  KEY `type_name` (`name`)
) ENGINE=MyISAM AUTO_INCREMENT=26 DEFAULT CHARSET=utf8;

--
-- Table structure for table `data_series`
--

DROP TABLE IF EXISTS `data_series`;
CREATE TABLE `data_series` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  `format` varchar(255) default NULL,
  `year_began` int(11) NOT NULL,
  `year_ended` int(11) default NULL,
  `classification_id` int(11) NOT NULL default '1',
  `language_id` int(11) default NULL,
  `tracking_notes` mediumtext,
  `notes` mediumtext,
  `has_gallery` tinyint(1) NOT NULL default '0',
  `item_count` int(11) NOT NULL default '0',
  `created` datetime NOT NULL default '1901-01-01 00:00:00',
  `modified` datetime NOT NULL default '1901-01-01 00:00:00',
  `imprint_id` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `imprint_id` (`imprint_id`),
  KEY `Bk_Name` (`name`(150)),
  KEY `Yr_Began` (`year_began`),
  KEY `HasGallery` (`has_gallery`),
  KEY `classification` (`classification_id`),
  KEY `series_language` (`language_id`)
) ENGINE=MyISAM AUTO_INCREMENT=38781 DEFAULT CHARSET=utf8;

--
-- Table structure for table `data_series_item`
--

DROP TABLE IF EXISTS `data_series_item`;
CREATE TABLE `data_series_item` (
  `id` int(11) NOT NULL auto_increment,
  `item_id` int(11) NOT NULL,
  `series_id` int(11) NOT NULL,
  `sort_code` int(11) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `key_sort_code` (`sort_code`),
  KEY `key_item_id` (`item_id`),
  KEY `key_series_id` (`series_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Table structure for table `data_series_item_name`
--

DROP TABLE IF EXISTS `data_series_item_name`;
CREATE TABLE `data_series_item_name` (
  `id` int(11) NOT NULL auto_increment,
  `series_item_id` int(11) NOT NULL,
  `series_name_id` int(11) NOT NULL,
  `source_id` int(11) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `key_item` (`series_item_id`),
  KEY `key_name` (`series_name_id`),
  KEY `key_source` (`source_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Table structure for table `data_series_name`
--

DROP TABLE IF EXISTS `data_series_name`;
CREATE TABLE `data_series_name` (
  `id` int(11) NOT NULL auto_increment,
  `series_id` int(11) NOT NULL,
  `value` varchar(255) NOT NULL,
  `source_id` int(11) NOT NULL,
  `is_primary` tinyint(1) NOT NULL default '1',
  PRIMARY KEY  (`id`),
  KEY `key_value` (`value`),
  KEY `key_source` (`source_id`),
  KEY `key_primary` (`is_primary`)
) ENGINE=MyISAM AUTO_INCREMENT=34606 DEFAULT CHARSET=utf8;

--
-- Table structure for table `data_series_publisher`
--

DROP TABLE IF EXISTS `data_series_publisher`;
CREATE TABLE `data_series_publisher` (
  `id` int(11) NOT NULL auto_increment,
  `series_id` int(11) NOT NULL,
  `publisher_id` int(11) NOT NULL,
  `uncertain` tinyint(1) NOT NULL default '0',
  `inferred` tinyint(1) NOT NULL default '0',
  `notes` mediumtext,
  PRIMARY KEY  (`id`),
  KEY `key_series_id` (`series_id`),
  KEY `key_publisher_id` (`publisher_id`)
) ENGINE=MyISAM AUTO_INCREMENT=34606 DEFAULT CHARSET=utf8;

--
-- Table structure for table `data_series_relationship`
--

DROP TABLE IF EXISTS `data_series_relationship`;
CREATE TABLE `data_series_relationship` (
  `id` int(11) NOT NULL auto_increment,
  `source_id` int(11) NOT NULL,
  `target_id` int(11) NOT NULL,
  `source_item_id` int(11) default NULL,
  `target_item_id` int(11) default NULL,
  `link_type_id` int(11) NOT NULL,
  `notes` mediumtext,
  PRIMARY KEY  (`id`),
  KEY `key_source` (`source_id`),
  KEY `key_target` (`target_id`),
  KEY `key_item_source` (`source_item_id`),
  KEY `key_item_target` (`target_item_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Table structure for table `data_series_relationship_type`
--

DROP TABLE IF EXISTS `data_series_relationship_type`;
CREATE TABLE `data_series_relationship_type` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(100) NOT NULL,
  `description` mediumtext,
  PRIMARY KEY  (`id`),
  KEY `key_name` (`name`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

--
-- Table structure for table `data_source`
--

DROP TABLE IF EXISTS `data_source`;
CREATE TABLE `data_source` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  `is_inferred` tinyint(1) NOT NULL default '0',
  PRIMARY KEY  (`id`),
  KEY `key_name` (`name`)
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

--
-- Table structure for table `migration_item_status`
--

DROP TABLE IF EXISTS `migration_item_status`;
CREATE TABLE `migration_item_status` (
  `id` int(11) NOT NULL auto_increment,
  `item_id` int(11) NOT NULL,
  `index_status` int(11) default NULL,
  `reservation_status` int(11) default NULL,
  `key_date` varchar(10) default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_status` (`index_status`),
  KEY `reservation_status` (`reservation_status`),
  KEY `key_date` (`key_date`)
) ENGINE=MyISAM AUTO_INCREMENT=460550 DEFAULT CHARSET=utf8;

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
) ENGINE=MyISAM AUTO_INCREMENT=714243 DEFAULT CHARSET=utf8;

--
-- Table structure for table `migration_series_item_status`
--

DROP TABLE IF EXISTS `migration_series_item_status`;
CREATE TABLE `migration_series_item_status` (
  `id` int(11) NOT NULL auto_increment,
  `series_item_id` int(11) NOT NULL,
  `issue_descriptor_confirmed` tinyint(1) NOT NULL,
  `volume_descriptor_confirmed` tinyint(1) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `key_series_item` (`series_item_id`),
  KEY `key_issue_descriptor` (`issue_descriptor_confirmed`),
  KEY `key_volume_descriptor` (`volume_descriptor_confirmed`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Table structure for table `migration_series_status`
--

DROP TABLE IF EXISTS `migration_series_status`;
CREATE TABLE `migration_series_status` (
  `id` int(11) NOT NULL auto_increment,
  `series_id` int(11) NOT NULL,
  `name_source_confirmed` tinyint(1) NOT NULL default '0',
  `open_reserve` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `key_series` (`series_id`),
  KEY `key_name_source` (`name_source_confirmed`)
) ENGINE=MyISAM AUTO_INCREMENT=34606 DEFAULT CHARSET=utf8;

--
-- Table structure for table `oi_reservation`
--

DROP TABLE IF EXISTS `oi_reservation`;
CREATE TABLE `oi_reservation` (
  `id` int(11) NOT NULL auto_increment,
  `indexer_id` int(11) NOT NULL,
  `item_id` int(11) NOT NULL,
  `status` int(11) NOT NULL,
  `index_type` int(11) NOT NULL,
  `expires` date default NULL,
  `created` datetime default '1901-01-01 00:00:00',
  PRIMARY KEY  (`id`),
  KEY `IndexerID` (`indexer_id`),
  KEY `IssueID` (`item_id`),
  KEY `Status` (`status`)
) ENGINE=MyISAM AUTO_INCREMENT=89638 DEFAULT CHARSET=utf8;

--
-- Table structure for table `oi_series_credit`
--

DROP TABLE IF EXISTS `oi_series_credit`;
CREATE TABLE `oi_series_credit` (
  `id` int(11) NOT NULL auto_increment,
  `indexer_id` int(11) NOT NULL,
  `series_id` int(11) NOT NULL,
  `run` varchar(255) default NULL,
  `notes` mediumtext,
  `created` datetime NOT NULL default '1901-01-01 00:00:00',
  `modified` datetime NOT NULL default '1901-01-01 00:00:00',
  PRIMARY KEY  (`id`),
  KEY `IndexerID` (`indexer_id`),
  KEY `SeriesID` (`series_id`)
) ENGINE=MyISAM AUTO_INCREMENT=25850 DEFAULT CHARSET=utf8;

--
-- Table structure for table `resource_cover`
--

DROP TABLE IF EXISTS `resource_cover`;
CREATE TABLE `resource_cover` (
  `id` int(11) NOT NULL auto_increment,
  `item_id` int(11) NOT NULL,
  `sequence_id` int(11) default NULL,
  `has_image` tinyint(1) NOT NULL default '0',
  `marked` tinyint(1) NOT NULL default '0',
  `small_image_id` int(11) default NULL,
  `medium_image_id` int(11) default NULL,
  `large_image_id` int(11) default NULL,
  `contributor` varchar(255) default NULL,
  `created` datetime NOT NULL default '1901-01-01 00:00:00',
  `modified` datetime NOT NULL default '1901-01-01 00:00:00',
  `series_id` int(11) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `IssueID` (`item_id`),
  KEY `SeriesID` (`series_id`),
  KEY `Modified` (`modified`),
  KEY `HasImage` (`has_image`)
) ENGINE=MyISAM AUTO_INCREMENT=653183 DEFAULT CHARSET=utf8;

--
-- Table structure for table `resource_file`
--

DROP TABLE IF EXISTS `resource_file`;
CREATE TABLE `resource_file` (
  `id` int(11) NOT NULL auto_increment,
  `server` varchar(100) NOT NULL,
  `path` varchar(512) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=663819 DEFAULT CHARSET=utf8;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2009-08-03  7:14:23
