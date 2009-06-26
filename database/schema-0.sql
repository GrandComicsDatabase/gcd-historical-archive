-- MySQL dump 10.11
--
-- Host: localhost    Database: gcd_dev
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
-- Table structure for table `countries`
--

DROP TABLE IF EXISTS `countries`;
CREATE TABLE `countries` (
  `code` varchar(10) default NULL,
  `country` varchar(255) default NULL,
  `ID` bigint(11) unsigned NOT NULL auto_increment,
  PRIMARY KEY  (`ID`),
  KEY `code` (`code`),
  KEY `country` (`country`(50))
) ENGINE=MyISAM AUTO_INCREMENT=248 DEFAULT CHARSET=utf8;

--
-- Table structure for table `languages`
--

DROP TABLE IF EXISTS `languages`;
CREATE TABLE `languages` (
  `code` varchar(10) default NULL,
  `language` varchar(255) default NULL,
  `ID` bigint(11) unsigned NOT NULL auto_increment,
  PRIMARY KEY  (`ID`),
  KEY `code` (`code`),
  KEY `language` (`language`(10))
) ENGINE=MyISAM AUTO_INCREMENT=137 DEFAULT CHARSET=utf8;

--
-- Table structure for table `indexers`
--

DROP TABLE IF EXISTS `indexers`;
CREATE TABLE `indexers` (
  `ID` bigint(11) unsigned NOT NULL auto_increment,
  `LastName` varchar(255) default NULL,
  `FirstName` varchar(255) default NULL,
  `DateCreated` date default NULL,
  `DateMod` date default NULL,
  `Name` varchar(255) default NULL,
  `eMail` varchar(255) default NULL,
  `Country` varchar(255) default NULL,
  `username` varchar(255) default NULL,
  `password` varchar(255) default NULL,
  `loginkey` varchar(50) default NULL,
  `loginlock` varchar(50) default NULL,
  `session` varchar(100) default NULL,
  `userlevel` int(11) default NULL,
  `expert` int(11) default NULL,
  `Message` mediumtext,
  `Active` int(11) default NULL,
  PRIMARY KEY  (`ID`),
  KEY `LastName` (`LastName`),
  KEY `FirstName` (`FirstName`),
  KEY `eMail` (`eMail`),
  KEY `username` (`username`),
  KEY `password` (`password`)
) ENGINE=MyISAM AUTO_INCREMENT=509 DEFAULT CHARSET=utf8;

--
-- Table structure for table `IndexCredit`
--

DROP TABLE IF EXISTS `IndexCredit`;
CREATE TABLE `IndexCredit` (
  `ID` bigint(11) unsigned NOT NULL auto_increment,
  `IndexerID` int(11) default NULL,
  `SeriesID` int(11) default NULL,
  `Run` varchar(255) default NULL,
  `DateMod` date default '0000-00-00',
  `Notes` mediumtext,
  `Comment` mediumtext,
  PRIMARY KEY  (`ID`),
  KEY `IndexerID` (`IndexerID`),
  KEY `SeriesID` (`SeriesID`)
) ENGINE=MyISAM AUTO_INCREMENT=23416 DEFAULT CHARSET=utf8;

--
-- Table structure for table `publishers`
--

DROP TABLE IF EXISTS `publishers`;
CREATE TABLE `publishers` (
  `PubName` varchar(255) default NULL,
  `BookCount` int(11) default NULL,
  `ImprintCount` int(11) default NULL,
  `IssueCount` int(11) default NULL,
  `Modified` date default NULL,
  `Connection` mediumtext,
  `ID` bigint(11) unsigned NOT NULL auto_increment,
  `ParentID` bigint(11) default NULL,
  `NextID` bigint(20) default NULL,
  `Notes` mediumtext,
  `Created` date default NULL,
  `Updated` date default NULL,
  `YearBegan` int(11) default NULL,
  `YearEnded` int(11) default NULL,
  `AlphaSortCode` char(1) default NULL,
  `CountryID` int(11) default NULL,
  `Master` tinyint(4) default NULL,
  `web` varchar(255) default NULL,
  PRIMARY KEY  (`ID`),
  KEY `PubName` (`PubName`),
  KEY `ParentID` (`ParentID`),
  KEY `Master` (`Master`),
  KEY `YearBegan` (`YearBegan`)
) ENGINE=MyISAM AUTO_INCREMENT=4746 DEFAULT CHARSET=utf8;

--
-- Table structure for table `series`
--

DROP TABLE IF EXISTS `series`;
CREATE TABLE `series` (
  `Bk_Name` varchar(255) default NULL,
  `CounCode` varchar(4) default NULL,
  `Created` date default NULL,
  `Crossref` bigint(20) default NULL,
  `CrossrefID` bigint(20) default NULL,
  `File` varchar(10) default NULL,
  `Format` varchar(255) default NULL,
  `Frst_Iss` varchar(10) default NULL,
  `HasGallery` char(3) default NULL,
  `Included` varchar(255) default NULL,
  `Indexers` mediumtext,
  `InitDist` int(11) default NULL,
  `Issuecount` int(11) default NULL,
  `LangCode` char(3) default NULL,
  `Last_Iss` varchar(25) default NULL,
  `LstChang` date default NULL,
  `Modified` date default NULL,
  `ModTime` time default NULL,
  `Notes` mediumtext,
  `oldID` int(11) default NULL,
  `PubDates` varchar(255) default NULL,
  `PubID` int(11) default NULL,
  `Pub_Name` varchar(255) default NULL,
  `Pub_Note` mediumtext,
  `SelfCount` int(11) default NULL,
  `ID` int(11) unsigned NOT NULL auto_increment,
  `Themes` mediumtext,
  `Tracking` mediumtext,
  `UpdateDist` double default NULL,
  `Yr_Began` int(11) default NULL,
  `Yr_Ended` int(11) default NULL,
  `OpenReserve` int(11) default NULL,
  `imprint_id` int(255) default '0',
  PRIMARY KEY  (`ID`),
  KEY `imprint_id` (`imprint_id`),
  KEY `PubID` (`PubID`),
  KEY `Bk_Name` (`Bk_Name`(150)),
  KEY `Yr_Began` (`Yr_Began`),
  KEY `HasGallery` (`HasGallery`),
  KEY `LangCode` (`LangCode`)
) ENGINE=MyISAM AUTO_INCREMENT=31931 DEFAULT CHARSET=utf8;

--
-- Table structure for table `issues`
--

DROP TABLE IF EXISTS `issues`;
CREATE TABLE `issues` (
  `Bk_Name` varchar(255) default NULL,
  `Char_App` mediumtext,
  `Colors` varchar(255) default NULL,
  `CoverCheck` int(11) default NULL,
  `CoverCount` int(11) default NULL,
  `Editing` varchar(255) default NULL,
  `Feature` varchar(255) default NULL,
  `Genre` varchar(255) default NULL,
  `ID` bigint(11) unsigned NOT NULL auto_increment,
  `IndexStatus` int(11) default NULL,
  `InitDist` int(11) default NULL,
  `Inks` varchar(255) default NULL,
  `Issue` varchar(25) default NULL,
  `isUpdated` int(11) default NULL,
  `Key_Date` varchar(10) default NULL,
  `Letters` varchar(255) default NULL,
  `LstChang` date default NULL,
  `Modified` date default NULL,
  `ModTime` time default NULL,
  `Notes` mediumtext,
  `Pencils` varchar(255) default NULL,
  `Pg_Cnt` int(11) default NULL,
  `Price` varchar(25) default NULL,
  `Pub_Date` varchar(255) default NULL,
  `Pub_Name` varchar(255) default NULL,
  `rel_year` int(11) default NULL,
  `Reprints` mediumtext,
  `ReserveCheck` int(11) default NULL,
  `ReserveStatus` int(11) default NULL,
  `Script` varchar(255) default NULL,
  `SelfCount` int(11) default NULL,
  `Seq_No` int(11) default NULL,
  `SeriesID` bigint(20) default NULL,
  `SeriesLink` int(11) default NULL,
  `storycount` int(11) default NULL,
  `Synopsis` mediumtext,
  `Title` varchar(255) default NULL,
  `Type` varchar(15) default NULL,
  `UpdateDist` int(11) default NULL,
  `VolumeNum` int(11) default NULL,
  `Yr_Began` int(11) default NULL,
  `created` date default NULL,
  PRIMARY KEY  (`ID`),
  KEY `SeriesID` (`SeriesID`),
  KEY `Key_Date` (`Key_Date`),
  KEY `IndexStatus` (`IndexStatus`),
  KEY `ReserveStatus` (`ReserveStatus`),
  KEY `Bk_Name` (`Bk_Name`)
) ENGINE=MyISAM AUTO_INCREMENT=542309 DEFAULT CHARSET=utf8;

--
-- Table structure for table `covers`
--

DROP TABLE IF EXISTS `covers`;
CREATE TABLE `covers` (
  `Bk_Name` mediumtext,
  `Pub_Name` mediumtext,
  `Issue` varchar(50) NOT NULL default '',
  `covercode` varchar(50) NOT NULL default '',
  `HasImage` int(11) NOT NULL default '0',
  `Marked` tinyint(2) default '0',
  `variant_text` varchar(255) default NULL,
  `Yr_Began` int(11) default NULL,
  `c1` int(11) default NULL,
  `c2` int(11) default NULL,
  `c4` int(11) default NULL,
  `SeriesID` int(11) default NULL,
  `IssueID` int(11) default NULL,
  `ID` int(11) NOT NULL auto_increment,
  `Modified` date default NULL,
  `Created` date default NULL,
  `Modtime` time default '00:00:00',
  `Cretime` time default NULL,
  `Count` int(11) default NULL,
  `CoversThisTitle` int(11) default NULL,
  `Coverage` int(11) default NULL,
  `contributor` varchar(255) default NULL,
  `is_master` tinyint(255) default NULL,
  `variant_code` char(2) default NULL,
  `gfxserver` int(11) NOT NULL default '1',
  PRIMARY KEY  (`ID`),
  KEY `IssueID` (`IssueID`),
  KEY `SeriesID` (`SeriesID`),
  KEY `c1` (`c1`),
  KEY `is_master` (`is_master`),
  KEY `Modified` (`Modified`),
  KEY `covercode` (`covercode`),
  KEY `HasImage` (`HasImage`),
  KEY `c2` (`c2`),
  KEY `c4` (`c4`),
  KEY `Yr_Began` (`Yr_Began`)
) ENGINE=MyISAM AUTO_INCREMENT=526351 DEFAULT CHARSET=utf8;

--
-- Table structure for table `stories`
--

DROP TABLE IF EXISTS `stories`;
CREATE TABLE `stories` (
  `Bk_Name` varchar(255) default NULL,
  `Pub_Name` varchar(255) default NULL,
  `Yr_Began` int(11) default NULL,
  `Key_Date` varchar(30) default NULL,
  `Issue` varchar(50) NOT NULL default '',
  `Pub_Date` varchar(50) default NULL,
  `Seq_No` int(10) unsigned default NULL,
  `Type` varchar(50) default NULL,
  `Genre` varchar(255) default NULL,
  `Feature` varchar(255) default NULL,
  `Title` varchar(255) default NULL,
  `Pencils` mediumtext,
  `Inks` mediumtext,
  `Script` mediumtext,
  `Colors` mediumtext,
  `Letters` mediumtext,
  `Editing` mediumtext,
  `Pg_Cnt` varchar(10) default NULL,
  `Price` double default NULL,
  `Char_App` mediumtext,
  `Notes` mediumtext,
  `Synopsis` mediumtext,
  `Reprints` mediumtext,
  `LstChang` date default NULL,
  `rel_year` int(11) default NULL,
  `IssueCount` int(11) default NULL,
  `ID` bigint(11) unsigned NOT NULL auto_increment,
  `IssueID` int(11) default NULL,
  `SeriesID` int(11) default NULL,
  `Modified` date default NULL,
  `ModTime` time default NULL,
  `InitDist` int(11) default NULL,
  `Created` date default NULL,
  `JobNo` varchar(25) default NULL,
  PRIMARY KEY  (`ID`),
  KEY `IssueID` (`IssueID`),
  KEY `Title` (`Title`),
  KEY `Script` (`Script`(255)),
  KEY `Pencils` (`Pencils`(255)),
  KEY `Inks` (`Inks`(255)),
  KEY `Colors` (`Colors`(255)),
  KEY `Letters` (`Letters`(255)),
  KEY `Editing` (`Editing`(255)),
  KEY `Char_App` (`Char_App`(255)),
  KEY `JobNo` (`JobNo`(15)),
  KEY `SeriesID` (`SeriesID`),
  KEY `Seq_No` (`Seq_No`),
  KEY `Feature` (`Feature`),
  KEY `Modified` (`Modified`),
  KEY `Key_Date` (`Key_Date`)
) ENGINE=MyISAM AUTO_INCREMENT=715071 DEFAULT CHARSET=utf8;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2009-04-12 21:34:25
