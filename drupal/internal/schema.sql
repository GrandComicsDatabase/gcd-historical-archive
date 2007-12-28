/*
SQLyog Community Edition- MySQL GUI v5.22a
Host - 4.1.20-max-log : Database - ljamal_dbGCD
*********************************************************************
Server version : 4.1.20-max-log
*/

/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

/*Table structure for table `gcdCharacter` */

CREATE TABLE `gcdCharacter` (
  `CharacterID` int(11) NOT NULL auto_increment,
  `NamePrefixID` int(11) default NULL,
  `NameSuffixID` int(11) default NULL,
  `intYearCreation` int(11) default NULL,
  `strNameFamily` varchar(50) NOT NULL default '',
  `strNameGiven` varchar(50) default NULL,
  `strDisambiguation` varchar(50) default NULL,
  `txtNotes` text,
  `dteTimeStamp` datetime NOT NULL default '0000-00-00 00:00:00',
  `dteLastUpdate` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`CharacterID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Table structure for table `gcdContent` */

CREATE TABLE `gcdContent` (
  `ContentID` int(11) NOT NULL auto_increment,
  `ColorTypeID` int(11) NOT NULL default '0',
  `ContentTypeID` int(11) NOT NULL default '0',
  `IssueID` int(11) NOT NULL default '0',
  `PaperStockID` int(11) NOT NULL default '0',
  `intPageCount` int(11) NOT NULL default '0',
  `intSortOrder` int(11) NOT NULL default '0',
  `strTitle` varchar(255) NOT NULL default '',
  `txtCharacter` text,
  `txtSynopsis` text,
  `txtNotes` text NOT NULL,
  `dteTimeStamp` datetime NOT NULL default '0000-00-00 00:00:00',
  `dteLastUpdate` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`ContentID`),
  KEY `FK_gcdContent` (`ColorTypeID`),
  KEY `FK_gcdContent2` (`IssueID`),
  KEY `FK_gcdContent3` (`ContentTypeID`),
  KEY `FK_gcdContent4` (`PaperStockID`),
  CONSTRAINT `FK_gcdContent` FOREIGN KEY (`ColorTypeID`) REFERENCES `supColorType` (`ColorTypeID`),
  CONSTRAINT `FK_gcdContent2` FOREIGN KEY (`IssueID`) REFERENCES `gcdIssue` (`IssueID`),
  CONSTRAINT `FK_gcdContent3` FOREIGN KEY (`ContentTypeID`) REFERENCES `supContentType` (`ContentTypeID`),
  CONSTRAINT `FK_gcdContent4` FOREIGN KEY (`PaperStockID`) REFERENCES `supPaperStock` (`PaperStockID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Table structure for table `gcdContentCharacter` */

CREATE TABLE `gcdContentCharacter` (
  `ContentID` int(11) NOT NULL default '0',
  `CharacterID` int(11) NOT NULL default '0',
  `CharacterAliasID` int(11) default NULL,
  `CharacterAppearanceID` int(11) NOT NULL default '0',
  `CharacterGroupID` int(11) default NULL,
  PRIMARY KEY  (`ContentID`,`CharacterID`,`CharacterAppearanceID`),
  KEY `FK_gcdContentCharacter` (`CharacterID`),
  KEY `FK_gcdContentCharacter2` (`CharacterAliasID`),
  KEY `FK_gcdContentCharacter3` (`CharacterGroupID`),
  KEY `FK_gcdContentCharacter4` (`CharacterAppearanceID`),
  CONSTRAINT `FK_gcdContentCharacter` FOREIGN KEY (`CharacterID`) REFERENCES `gcdCharacter` (`CharacterID`),
  CONSTRAINT `FK_gcdContentCharacter2` FOREIGN KEY (`CharacterAliasID`) REFERENCES `gcdCharacter` (`CharacterID`),
  CONSTRAINT `FK_gcdContentCharacter3` FOREIGN KEY (`CharacterGroupID`) REFERENCES `gcdCharacter` (`CharacterID`),
  CONSTRAINT `FK_gcdContentCharacter4` FOREIGN KEY (`CharacterAppearanceID`) REFERENCES `supCharacterAppearance` (`CharacterAppearanceID`),
  CONSTRAINT `FK_gcdContentCharacter5` FOREIGN KEY (`ContentID`) REFERENCES `gcdContent` (`ContentID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Table structure for table `gcdContentCreatorRole` */

CREATE TABLE `gcdContentCreatorRole` (
  `ContentID` int(11) NOT NULL default '0',
  `CreatorID` int(11) NOT NULL default '0',
  `CreatorAliasID` int(11) default NULL,
  `CreatorGroupID` int(11) default NULL,
  `CreatorRoleID` int(11) NOT NULL default '0',
  `CreatorRoleFlagID` int(11) NOT NULL default '0',
  `txtNote` text,
  PRIMARY KEY  (`ContentID`,`CreatorID`,`CreatorRoleID`),
  KEY `FK_gcdContentCreatorRole2` (`CreatorAliasID`),
  KEY `FK_gcdContentCreatorRole3` (`CreatorGroupID`),
  KEY `FK_gcdContentCreatorRole4` (`CreatorID`),
  KEY `FK_gcdContentCreatorRole5` (`CreatorRoleID`),
  KEY `FK_gcdContentCreatorRole6` (`CreatorRoleFlagID`),
  CONSTRAINT `FK_gcdContentCreatorRole` FOREIGN KEY (`ContentID`) REFERENCES `gcdContent` (`ContentID`),
  CONSTRAINT `FK_gcdContentCreatorRole2` FOREIGN KEY (`CreatorAliasID`) REFERENCES `gcdCreator` (`CreatorID`),
  CONSTRAINT `FK_gcdContentCreatorRole3` FOREIGN KEY (`CreatorGroupID`) REFERENCES `gcdCreator` (`CreatorID`),
  CONSTRAINT `FK_gcdContentCreatorRole4` FOREIGN KEY (`CreatorID`) REFERENCES `gcdCreator` (`CreatorID`),
  CONSTRAINT `FK_gcdContentCreatorRole5` FOREIGN KEY (`CreatorRoleID`) REFERENCES `supCreatorRole` (`CreatorRoleID`),
  CONSTRAINT `FK_gcdContentCreatorRole6` FOREIGN KEY (`CreatorRoleFlagID`) REFERENCES `supCreatorRoleFlag` (`CreatorRoleFlagID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Table structure for table `gcdContentFeature` */

CREATE TABLE `gcdContentFeature` (
  `ContentID` int(11) NOT NULL default '0',
  `FeatureID` int(11) NOT NULL default '0',
  PRIMARY KEY  (`ContentID`,`FeatureID`),
  KEY `FK_gcdContentFeature` (`FeatureID`),
  CONSTRAINT `FK_gcdContentFeature` FOREIGN KEY (`FeatureID`) REFERENCES `gcdFeature` (`FeatureID`),
  CONSTRAINT `FK_gcdContentFeature2` FOREIGN KEY (`ContentID`) REFERENCES `gcdContent` (`ContentID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Table structure for table `gcdContentGenre` */

CREATE TABLE `gcdContentGenre` (
  `ContentID` int(11) NOT NULL default '0',
  `GenreID` int(11) NOT NULL default '0',
  PRIMARY KEY  (`ContentID`,`GenreID`),
  KEY `FK_gcdContentGenre2` (`GenreID`),
  CONSTRAINT `FK_gcdContentGenre` FOREIGN KEY (`ContentID`) REFERENCES `gcdContent` (`ContentID`),
  CONSTRAINT `FK_gcdContentGenre2` FOREIGN KEY (`GenreID`) REFERENCES `gcdGenre` (`GenreID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Table structure for table `gcdContentJobCode` */

CREATE TABLE `gcdContentJobCode` (
  `JobCodeID` int(11) NOT NULL default '0',
  `ContentID` int(11) NOT NULL default '0',
  `strJobCode` varchar(50) NOT NULL default '',
  PRIMARY KEY  (`JobCodeID`),
  KEY `FK_gcdContentJobCode` (`ContentID`),
  CONSTRAINT `FK_gcdContentJobCode` FOREIGN KEY (`ContentID`) REFERENCES `gcdContent` (`ContentID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Table structure for table `gcdContentReprint` */

CREATE TABLE `gcdContentReprint` (
  `ContentID` int(11) NOT NULL default '0',
  `ReprintID` int(11) NOT NULL default '0',
  `txtNotes` text,
  PRIMARY KEY  (`ContentID`,`ReprintID`),
  KEY `FK_gcdContentReprint2` (`ReprintID`),
  CONSTRAINT `FK_gcdContentReprint` FOREIGN KEY (`ContentID`) REFERENCES `gcdContent` (`ContentID`),
  CONSTRAINT `FK_gcdContentReprint2` FOREIGN KEY (`ReprintID`) REFERENCES `gcdContent` (`ContentID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Table structure for table `gcdCreator` */

CREATE TABLE `gcdCreator` (
  `CreatorID` int(11) NOT NULL auto_increment,
  `NamePrefixID` int(11) default NULL,
  `NameSuffixID` int(11) default NULL,
  `boolNameStyle` tinyint(1) NOT NULL default '0',
  `intBirthDay` int(11) default NULL,
  `intBirthMonth` int(11) default NULL,
  `intBirthYear` int(11) default NULL,
  `strNameFamily` varchar(50) NOT NULL default '',
  `strNameGiven` varchar(50) default NULL,
  `txtNotes` text,
  `dteTimeStamp` datetime NOT NULL default '0000-00-00 00:00:00',
  `dteLastUpdate` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`CreatorID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Table structure for table `gcdCreatortoCreator` */

CREATE TABLE `gcdCreatortoCreator` (
  `CreatorID` int(11) NOT NULL default '0',
  `CreatorToID` int(11) NOT NULL default '0',
  `CreatorRelationshipID` int(11) NOT NULL default '0',
  PRIMARY KEY  (`CreatorID`,`CreatorToID`,`CreatorRelationshipID`),
  KEY `FK_gcdCreatortoCreator2` (`CreatorToID`),
  KEY `FK_gcdCreatortoCreator3` (`CreatorRelationshipID`),
  CONSTRAINT `FK_gcdCreatortoCreator` FOREIGN KEY (`CreatorID`) REFERENCES `gcdCreator` (`CreatorID`),
  CONSTRAINT `FK_gcdCreatortoCreator2` FOREIGN KEY (`CreatorToID`) REFERENCES `gcdCreator` (`CreatorID`),
  CONSTRAINT `FK_gcdCreatortoCreator3` FOREIGN KEY (`CreatorRelationshipID`) REFERENCES `supCreatorRelationship` (`CreatorRelationshipID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Table structure for table `gcdFeature` */

CREATE TABLE `gcdFeature` (
  `FeatureID` int(11) NOT NULL auto_increment,
  `intYearBegin` int(11) NOT NULL default '0',
  `strFeature` varchar(50) NOT NULL default '',
  `txtDescription` text NOT NULL,
  `dteTimeStamp` datetime NOT NULL default '0000-00-00 00:00:00',
  `dteLastUpdate` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`FeatureID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Table structure for table `gcdFeatureGenre` */

CREATE TABLE `gcdFeatureGenre` (
  `FeatureID` int(11) NOT NULL default '0',
  `GenreID` int(11) NOT NULL default '0',
  PRIMARY KEY  (`FeatureID`,`GenreID`),
  KEY `FK_gcdFeatureGenre2` (`GenreID`),
  CONSTRAINT `FK_gcdFeatureGenre` FOREIGN KEY (`FeatureID`) REFERENCES `gcdFeature` (`FeatureID`),
  CONSTRAINT `FK_gcdFeatureGenre2` FOREIGN KEY (`GenreID`) REFERENCES `gcdGenre` (`GenreID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Table structure for table `gcdGenre` */

CREATE TABLE `gcdGenre` (
  `GenreID` int(11) NOT NULL auto_increment,
  `strGenre` varchar(50) NOT NULL default '',
  `txtDescription` text NOT NULL,
  PRIMARY KEY  (`GenreID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Table structure for table `gcdIssue` */

CREATE TABLE `gcdIssue` (
  `IssueID` int(11) NOT NULL auto_increment,
  `IssueReprintID` int(11) default NULL,
  `FormatTypeID` int(11) NOT NULL default '0',
  `PublicationMonthID` int(11) NOT NULL default '0',
  `intCountPage` int(11) NOT NULL default '0',
  `intPrinting` int(11) NOT NULL default '0',
  `intHeight` int(11) default NULL,
  `intWidth` int(11) default NULL,
  `intPublicationDay` int(11) default NULL,
  `intPublicationMonth` int(11) default NULL,
  `intPublicationYear` int(11) NOT NULL default '0',
  `strIndiciaTitle` varchar(255) NOT NULL default '',
  `strIndiciaVolume` varchar(50) default NULL,
  `strIndiciaNumber` varchar(50) default NULL,
  `strDisambiguation` varchar(50) default NULL,
  `txtNotes` text,
  `dteTimeStamp` datetime NOT NULL default '0000-00-00 00:00:00',
  `dteLastUpdate` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`IssueID`),
  KEY `FK_gcdIssue` (`PublicationMonthID`),
  KEY `FK_gcdIssue2` (`FormatTypeID`),
  KEY `FK_gcdIssue3` (`IssueReprintID`),
  CONSTRAINT `FK_gcdIssue3` FOREIGN KEY (`IssueReprintID`) REFERENCES `gcdIssue` (`IssueID`),
  CONSTRAINT `FK_gcdIssue` FOREIGN KEY (`PublicationMonthID`) REFERENCES `supPublicationMonth` (`PublicationMonthID`),
  CONSTRAINT `FK_gcdIssue2` FOREIGN KEY (`FormatTypeID`) REFERENCES `supFormat` (`FormatID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Table structure for table `gcdIssueCoverType` */

CREATE TABLE `gcdIssueCoverType` (
  `IssueID` int(11) NOT NULL default '0',
  `CoverTypeID` int(11) NOT NULL default '0',
  PRIMARY KEY  (`IssueID`,`CoverTypeID`),
  KEY `FK_gcdIssueCoverType2` (`CoverTypeID`),
  CONSTRAINT `FK_gcdIssueCoverType` FOREIGN KEY (`IssueID`) REFERENCES `gcdIssue` (`IssueID`),
  CONSTRAINT `FK_gcdIssueCoverType2` FOREIGN KEY (`CoverTypeID`) REFERENCES `supCoverType` (`CoverTypeID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Table structure for table `gcdIssuePrice` */

CREATE TABLE `gcdIssuePrice` (
  `IssueID` int(11) NOT NULL default '0',
  `CurrencyID` varchar(4) NOT NULL default '',
  `numPrice` float NOT NULL default '0',
  `txtNotes` text,
  PRIMARY KEY  (`IssueID`,`CurrencyID`),
  KEY `FK_gcdIssuePrice2` (`CurrencyID`),
  CONSTRAINT `FK_gcdIssuePrice` FOREIGN KEY (`IssueID`) REFERENCES `gcdIssue` (`IssueID`),
  CONSTRAINT `FK_gcdIssuePrice2` FOREIGN KEY (`CurrencyID`) REFERENCES `supCurrency` (`CurrencyID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Table structure for table `gcdIssuePublisher` */

CREATE TABLE `gcdIssuePublisher` (
  `IssueID` int(11) NOT NULL default '0',
  `PublisherID` int(11) NOT NULL default '0',
  `PublisherTypeID` int(11) NOT NULL default '0',
  PRIMARY KEY  (`IssueID`,`PublisherID`,`PublisherTypeID`),
  KEY `FK_gcdIssuePublisher2` (`PublisherID`),
  KEY `FK_gcdIssuePublisher3` (`PublisherTypeID`),
  CONSTRAINT `FK_gcdIssuePublisher3` FOREIGN KEY (`PublisherTypeID`) REFERENCES `supPublisherType` (`PublisherTypeID`),
  CONSTRAINT `FK_gcdIssuePublisher` FOREIGN KEY (`IssueID`) REFERENCES `gcdIssue` (`IssueID`),
  CONSTRAINT `FK_gcdIssuePublisher2` FOREIGN KEY (`PublisherID`) REFERENCES `gcdPublisher` (`PublisherID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC;

/*Table structure for table `gcdIssueStandardNumber` */

CREATE TABLE `gcdIssueStandardNumber` (
  `IssueStandardNumberID` int(11) NOT NULL auto_increment,
  `IssueID` int(11) NOT NULL default '0',
  `StandardNumberTypeID` int(11) NOT NULL default '0',
  `strStandardNumber` varchar(16) NOT NULL default '',
  PRIMARY KEY  (`IssueStandardNumberID`),
  KEY `FK_gcdIssueStandardNumber` (`IssueID`),
  KEY `FK_gcdIssueStandardNumber2` (`StandardNumberTypeID`),
  CONSTRAINT `FK_gcdIssueStandardNumber2` FOREIGN KEY (`StandardNumberTypeID`) REFERENCES `supStandardNumberType` (`StandardNumberTypeID`),
  CONSTRAINT `FK_gcdIssueStandardNumber` FOREIGN KEY (`IssueID`) REFERENCES `gcdIssue` (`IssueID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC;

/*Table structure for table `gcdPublisher` */

CREATE TABLE `gcdPublisher` (
  `PublisherID` int(11) NOT NULL auto_increment,
  `CountryID` varchar(6) NOT NULL default '',
  `PublisherTypeID` int(11) NOT NULL default '0',
  `intCountComics` int(11) NOT NULL default '0',
  `intCountImprint` int(11) NOT NULL default '0',
  `intCountSeries` int(11) NOT NULL default '0',
  `intYearBegin` int(11) NOT NULL default '0',
  `intYearEnd` int(11) default NULL,
  `strNamePublisher` varchar(50) NOT NULL default '',
  `strDisambiguation` varchar(50) default NULL,
  `txtNotes` text,
  `dteTimeStamp` datetime NOT NULL default '0000-00-00 00:00:00',
  `dteLastUpdate` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`PublisherID`),
  KEY `FK_gcdPublisher_PublisherType` (`PublisherTypeID`),
  KEY `FK_gcdPublisher_Country` (`CountryID`),
  CONSTRAINT `FK_gcdPublisher_Country` FOREIGN KEY (`CountryID`) REFERENCES `supCountry` (`CountryID`),
  CONSTRAINT `FK_gcdPublisher_PublisherType` FOREIGN KEY (`PublisherTypeID`) REFERENCES `supPublisherType` (`PublisherTypeID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Table structure for table `gcdPublisherRelationship` */

CREATE TABLE `gcdPublisherRelationship` (
  `PublisherID` int(11) NOT NULL default '0',
  `RelatedPublisherID` int(11) NOT NULL default '0',
  `PublisherRelationshipID` int(11) NOT NULL default '0',
  `txtNote` text,
  PRIMARY KEY  (`PublisherID`,`RelatedPublisherID`,`PublisherRelationshipID`),
  KEY `FK_gcdPublisherRelationship_RelatedPublisher` (`RelatedPublisherID`),
  KEY `FK_gcdPublisherRelationship_PublisherRelationship` (`PublisherRelationshipID`),
  CONSTRAINT `FK_gcdPublisherRelationship_Publisher` FOREIGN KEY (`PublisherID`) REFERENCES `gcdPublisher` (`PublisherID`),
  CONSTRAINT `FK_gcdPublisherRelationship_PublisherRelationship` FOREIGN KEY (`PublisherRelationshipID`) REFERENCES `supPublisherRelationship` (`PublisherRelationshipID`),
  CONSTRAINT `FK_gcdPublisherRelationship_RelatedPublisher` FOREIGN KEY (`RelatedPublisherID`) REFERENCES `gcdPublisher` (`PublisherID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Table structure for table `gcdSeries` */

CREATE TABLE `gcdSeries` (
  `SeriesID` int(11) NOT NULL auto_increment,
  `IssueBeginID` int(11) default NULL,
  `IssueEndID` int(11) default NULL,
  `LanguageID` varchar(6) default NULL,
  `intYearBegin` int(11) NOT NULL default '0',
  `intYearEnd` int(11) default NULL,
  `intCountComics` int(11) NOT NULL default '0',
  `strNameSeries` varchar(255) NOT NULL default '',
  `txtNotes` text,
  `dteTimeStamp` datetime NOT NULL default '0000-00-00 00:00:00',
  `dteLastUpdate` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`SeriesID`),
  KEY `FK_gcdSeries` (`LanguageID`),
  CONSTRAINT `FK_gcdSeries` FOREIGN KEY (`LanguageID`) REFERENCES `supLanguage` (`LanguageID`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Table structure for table `gcdSeriesIssue` */

CREATE TABLE `gcdSeriesIssue` (
  `SeriesID` int(11) NOT NULL default '0',
  `IssueID` int(11) NOT NULL default '0',
  `intSortOrder` int(11) NOT NULL default '0',
  `intVolume` int(11) default NULL,
  `strIssue` varchar(16) default NULL,
  PRIMARY KEY  (`SeriesID`,`IssueID`),
  KEY `FK_gcdSeriesIssue2` (`IssueID`),
  CONSTRAINT `FK_gcdSeriesIssue` FOREIGN KEY (`SeriesID`) REFERENCES `gcdSeries` (`SeriesID`),
  CONSTRAINT `FK_gcdSeriesIssue2` FOREIGN KEY (`IssueID`) REFERENCES `gcdIssue` (`IssueID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Table structure for table `gcdSeriesPublisher` */

CREATE TABLE `gcdSeriesPublisher` (
  `SeriesID` int(11) NOT NULL default '0',
  `PublisherID` int(11) NOT NULL default '0',
  PRIMARY KEY  (`SeriesID`,`PublisherID`),
  KEY `FK_gcdSeriesPublisher` (`PublisherID`),
  CONSTRAINT `FK_gcdSeriesPublisher` FOREIGN KEY (`PublisherID`) REFERENCES `gcdPublisher` (`PublisherID`),
  CONSTRAINT `FK_gcdSeriesPublisher2` FOREIGN KEY (`SeriesID`) REFERENCES `gcdSeries` (`SeriesID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Table structure for table `gcdSeriesStandardNumber` */

CREATE TABLE `gcdSeriesStandardNumber` (
  `SeriesStandardNumberID` int(11) NOT NULL auto_increment,
  `SeriesID` int(11) NOT NULL default '0',
  `StandardNumberTypeID` int(11) NOT NULL default '0',
  `strStandardNumber` varchar(25) NOT NULL default '',
  PRIMARY KEY  (`SeriesStandardNumberID`),
  KEY `FK_gcdSeriesStandardNumber` (`SeriesID`),
  KEY `FK_gcdSeriesStandardNumber2` (`StandardNumberTypeID`),
  CONSTRAINT `FK_gcdSeriesStandardNumber` FOREIGN KEY (`SeriesID`) REFERENCES `gcdSeries` (`SeriesID`),
  CONSTRAINT `FK_gcdSeriesStandardNumber2` FOREIGN KEY (`StandardNumberTypeID`) REFERENCES `supStandardNumberType` (`StandardNumberTypeID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Table structure for table `gcdSeriesToSeries` */

CREATE TABLE `gcdSeriesToSeries` (
  `SeriesID` int(11) NOT NULL default '0',
  `SeriesToID` int(11) NOT NULL default '0',
  `txtNotes` text,
  PRIMARY KEY  (`SeriesID`,`SeriesToID`),
  KEY `FK_gcdSeriesToSeries2` (`SeriesToID`),
  CONSTRAINT `FK_gcdSeriesToSeries` FOREIGN KEY (`SeriesID`) REFERENCES `gcdSeries` (`SeriesID`),
  CONSTRAINT `FK_gcdSeriesToSeries2` FOREIGN KEY (`SeriesToID`) REFERENCES `gcdSeries` (`SeriesID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Table structure for table `supCharacterAppearance` */

CREATE TABLE `supCharacterAppearance` (
  `CharacterAppearanceID` int(11) NOT NULL auto_increment,
  `strCharacterAppearance` varchar(50) NOT NULL default '',
  `txtDescription` text,
  PRIMARY KEY  (`CharacterAppearanceID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Table structure for table `supColorType` */

CREATE TABLE `supColorType` (
  `ColorTypeID` int(11) NOT NULL auto_increment,
  `strColorType` varchar(50) NOT NULL default '',
  `txtDescription` text,
  PRIMARY KEY  (`ColorTypeID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Table structure for table `supContentType` */

CREATE TABLE `supContentType` (
  `ContentTypeID` int(11) NOT NULL auto_increment,
  `strContentType` varchar(50) NOT NULL default '',
  `txtDescription` text,
  PRIMARY KEY  (`ContentTypeID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Table structure for table `supCountry` */

CREATE TABLE `supCountry` (
  `CountryID` varchar(6) NOT NULL default '',
  `strCountry` varchar(50) NOT NULL default '',
  PRIMARY KEY  (`CountryID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Table structure for table `supCoverType` */

CREATE TABLE `supCoverType` (
  `CoverTypeID` int(11) NOT NULL auto_increment,
  `strCoverType` varchar(50) NOT NULL default '',
  `txtDescription` text,
  PRIMARY KEY  (`CoverTypeID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Table structure for table `supCreatorRelationship` */

CREATE TABLE `supCreatorRelationship` (
  `CreatorRelationshipID` int(11) NOT NULL auto_increment,
  `strCreatorRelationship` varchar(50) NOT NULL default '',
  `txtDescription` text,
  PRIMARY KEY  (`CreatorRelationshipID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Table structure for table `supCreatorRole` */

CREATE TABLE `supCreatorRole` (
  `CreatorRoleID` int(11) NOT NULL auto_increment,
  `intSort` int(11) NOT NULL default '0',
  `strCreatorRole` varchar(50) default NULL,
  `txtDescription` text,
  PRIMARY KEY  (`CreatorRoleID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Table structure for table `supCreatorRoleFlag` */

CREATE TABLE `supCreatorRoleFlag` (
  `CreatorRoleFlagID` int(11) NOT NULL auto_increment,
  `strCreatorRoleFlag` varchar(50) NOT NULL default '',
  `txtDescription` text,
  PRIMARY KEY  (`CreatorRoleFlagID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Table structure for table `supCurrency` */

CREATE TABLE `supCurrency` (
  `CurrencyID` varchar(4) NOT NULL default '',
  `strCurrency` varchar(50) default NULL,
  PRIMARY KEY  (`CurrencyID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Table structure for table `supFormat` */

CREATE TABLE `supFormat` (
  `FormatID` int(11) NOT NULL auto_increment,
  `strFormat` varchar(50) NOT NULL default '',
  `txtDescription` text,
  PRIMARY KEY  (`FormatID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Table structure for table `supLanguage` */

CREATE TABLE `supLanguage` (
  `LanguageID` varchar(4) NOT NULL default '',
  `strLanguage` varchar(50) NOT NULL default '',
  PRIMARY KEY  (`LanguageID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Table structure for table `supNamePrefix` */

CREATE TABLE `supNamePrefix` (
  `NamePrefixID` int(11) NOT NULL auto_increment,
  `strNamePrefix` varchar(50) NOT NULL default '',
  PRIMARY KEY  (`NamePrefixID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Table structure for table `supNameSuffix` */

CREATE TABLE `supNameSuffix` (
  `NameSuffixID` int(11) NOT NULL auto_increment,
  `strNameSuffix` varchar(50) NOT NULL default '',
  PRIMARY KEY  (`NameSuffixID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Table structure for table `supPaperStock` */

CREATE TABLE `supPaperStock` (
  `PaperStockID` int(11) NOT NULL auto_increment,
  `strPaperStock` varchar(50) NOT NULL default '',
  `txtDescription` text,
  PRIMARY KEY  (`PaperStockID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Table structure for table `supPublicationMonth` */

CREATE TABLE `supPublicationMonth` (
  `PublicationMonthID` int(11) NOT NULL auto_increment,
  `strPublicationMonth` varchar(20) NOT NULL default '',
  PRIMARY KEY  (`PublicationMonthID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Table structure for table `supPublisherRelationship` */

CREATE TABLE `supPublisherRelationship` (
  `PublisherRelationshipID` int(11) NOT NULL auto_increment,
  `strPublisherRelationship` varchar(50) NOT NULL default '',
  `txtDescription` text,
  PRIMARY KEY  (`PublisherRelationshipID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Table structure for table `supPublisherType` */

CREATE TABLE `supPublisherType` (
  `PublisherTypeID` int(11) NOT NULL auto_increment,
  `strPublisherType` varchar(50) NOT NULL default '',
  `txtDescritpion` text,
  PRIMARY KEY  (`PublisherTypeID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Table structure for table `supStandardNumberType` */

CREATE TABLE `supStandardNumberType` (
  `StandardNumberTypeID` int(11) NOT NULL auto_increment,
  `strStandardNumberType` varchar(50) NOT NULL default '',
  `txtDescription` text,
  PRIMARY KEY  (`StandardNumberTypeID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
