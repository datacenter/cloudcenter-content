-- MySQL dump 10.16  Distrib 10.1.24-MariaDB, for Linux (x86_64)
--
-- Host: localhost    Database: siwapp
-- ------------------------------------------------------
-- Server version	10.1.24-MariaDB

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
-- Table structure for table `common`
--
CREATE DATABASE IF NOT EXISTS siwapp;

USE siwapp;

DROP TABLE IF EXISTS `common`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `common` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `series_id` bigint(20) DEFAULT NULL,
  `customer_id` bigint(20) DEFAULT NULL,
  `customer_name` varchar(100) DEFAULT NULL,
  `customer_identification` varchar(50) DEFAULT NULL,
  `customer_email` varchar(100) DEFAULT NULL,
  `invoicing_address` longtext,
  `shipping_address` longtext,
  `contact_person` varchar(100) DEFAULT NULL,
  `terms` longtext,
  `notes` longtext,
  `base_amount` decimal(53,15) DEFAULT NULL,
  `discount_amount` decimal(53,15) DEFAULT NULL,
  `net_amount` decimal(53,15) DEFAULT NULL,
  `gross_amount` decimal(53,15) DEFAULT NULL,
  `paid_amount` decimal(53,15) DEFAULT NULL,
  `tax_amount` decimal(53,15) DEFAULT NULL,
  `status` tinyint(4) DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `draft` tinyint(1) DEFAULT '1',
  `closed` tinyint(1) DEFAULT '0',
  `sent_by_email` tinyint(1) DEFAULT '0',
  `number` int(11) DEFAULT NULL,
  `recurring_invoice_id` bigint(20) DEFAULT NULL,
  `issue_date` date DEFAULT NULL,
  `due_date` date DEFAULT NULL,
  `days_to_due` mediumint(9) DEFAULT NULL,
  `enabled` tinyint(1) DEFAULT '0',
  `max_occurrences` int(11) DEFAULT NULL,
  `must_occurrences` int(11) DEFAULT NULL,
  `period` int(11) DEFAULT NULL,
  `period_type` varchar(8) DEFAULT NULL,
  `starting_date` date DEFAULT NULL,
  `finishing_date` date DEFAULT NULL,
  `last_execution_date` date DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `cstnm_idx` (`customer_name`),
  KEY `cstid_idx` (`customer_identification`),
  KEY `cstml_idx` (`customer_email`),
  KEY `cntct_idx` (`contact_person`),
  KEY `common_type_idx` (`type`),
  KEY `customer_id_idx` (`customer_id`),
  KEY `series_id_idx` (`series_id`),
  KEY `recurring_invoice_id_idx` (`recurring_invoice_id`),
  CONSTRAINT `common_customer_id_customer_id` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`id`) ON DELETE SET NULL,
  CONSTRAINT `common_recurring_invoice_id_common_id` FOREIGN KEY (`recurring_invoice_id`) REFERENCES `common` (`id`) ON DELETE SET NULL,
  CONSTRAINT `common_series_id_series_id` FOREIGN KEY (`series_id`) REFERENCES `series` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=88 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `common`
--

LOCK TABLES `common` WRITE;
/*!40000 ALTER TABLE `common` DISABLE KEYS */;
INSERT INTO `common` VALUES (6,12,6,'Krustyco','7141253916O','deborah_hudson@example.com','Fake Dir n 244\nMadrid\nSpain','Fake Dir n 244\nMadrid\nSpain','Deborah Hudson','Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.','Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',586.170000000000000,0.000000000000000,586.170000000000000,586.170000000000000,NULL,0.000000000000000,3,'RecurringInvoice',1,0,0,NULL,NULL,NULL,NULL,553,1,NULL,1,50,'year','2006-06-30',NULL,NULL,'2017-06-22 20:55:29','2017-06-22 20:55:31'),(9,9,6,'Krustyco','6852996407X','valeria_starling@example.com','Fake Dir n 899\nMadrid\nSpain','Fake Dir n 899\nMadrid\nSpain','Valeria Starling','Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.','Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',1699.680000000000000,0.000000000000000,1699.680000000000000,1699.680000000000000,NULL,0.000000000000000,3,'RecurringInvoice',1,0,0,NULL,NULL,NULL,NULL,347,1,14,14,8,'week','2004-12-02','2037-06-04',NULL,'2017-06-22 20:55:29','2017-06-22 20:55:31'),(12,9,9,'Plow King','7885556345D','jennifer_karidian@example.com','Fake Dir n 812\nMadrid\nSpain','Fake Dir n 812\nMadrid\nSpain','Jennifer Karidian','Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.','Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',5976.950000000000000,0.000000000000000,5976.950000000000000,5976.950000000000000,NULL,0.000000000000000,3,'RecurringInvoice',1,0,0,NULL,NULL,NULL,NULL,219,1,15,15,1,'month','2005-03-10','2037-10-31',NULL,'2017-06-22 20:55:29','2017-06-22 20:55:31'),(15,9,12,'Smith and Co.','2450626775P','jody_nichols@example.com','Fake Dir n 262\nMadrid\nSpain','Fake Dir n 262\nMadrid\nSpain','Jody Nichols','Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.','Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',7198.850000000000000,0.000000000000000,7198.850000000000000,8233.650000000000000,8610.680000000000000,1034.799500000000000,3,'Invoice',0,0,0,1,NULL,'2007-08-11','2015-03-22',NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2009-04-17 09:45:36','2017-06-22 20:55:31'),(18,6,15,'Rouster and Sideways','1889335077','varria_leijten@example.com','Fake Dir n 871\nMadrid\nSpain','Fake Dir n 871\nMadrid\nSpain','Varria Leijten','Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.','Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',11571.890000000000000,0.000000000000000,11571.890000000000000,13407.920000000000000,13317.870000000000000,1836.026000000000000,3,'Invoice',0,0,0,1,NULL,'2008-11-09','2015-04-04',NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2009-04-17 09:45:36','2017-06-22 20:55:31'),(21,9,18,'Western Gas & Electric','3924395949G','marissa_peers@example.com','Fake Dir n 88\nMadrid\nSpain','Fake Dir n 88\nMadrid\nSpain','Marissa Peers','Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.','Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',11521.020000000000000,0.000000000000000,11521.020000000000000,12714.940000000000000,11780.260000000000000,1193.923200000000000,0,'Invoice',1,0,0,NULL,NULL,'2008-02-07','2015-10-28',NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2009-04-17 09:45:36','2017-06-22 20:55:31'),(24,12,21,'Osato Chemicals','4499553670X','julie_radue@example.com','Fake Dir n 969\nMadrid\nSpain','Fake Dir n 969\nMadrid\nSpain','Julie Radue','Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.','Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',17254.860000000000000,0.000000000000000,17254.860000000000000,16985.470000000000000,14512.700000000000000,-269.387200000000000,3,'Invoice',0,0,0,1,NULL,'2005-05-08','2006-09-02',NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2009-04-17 09:45:36','2017-07-19 00:00:01'),(27,12,24,'123 Warehousing','77426541881','cyrus_decker@example.com','Fake Dir n 39\nMadrid\nSpain','Fake Dir n 39\nMadrid\nSpain','Cyrus Decker','Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.','Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.',4802.700000000000000,1077.245400000000000,3725.454600000000000,3986.240000000000000,3986.230000000000000,260.781822000000000,0,'Invoice',1,0,0,NULL,NULL,'2008-08-06','2015-12-01',NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2009-04-17 09:45:36','2017-06-22 20:55:31'),(30,6,27,'Allied Biscuit','6787068643G','willard_starling@example.com','Fake Dir n 617\nMadrid\nSpain','Fake Dir n 617\nMadrid\nSpain','Willard Starling','Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.','Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',19659.410000000000000,0.000000000000000,19659.410000000000000,22370.790000000000000,20804.790000000000000,2711.380400000000000,3,'Invoice',0,0,0,2,NULL,'2008-11-04','2009-09-23',NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2009-04-17 09:45:36','2017-06-22 20:55:31'),(33,6,30,'St. Anky Beer','9295043937','sharon_ward@example.com','Fake Dir n 424\nMadrid\nSpain','Fake Dir n 424\nMadrid\nSpain','Sharon Ward','Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.','Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.',21236.910000000000000,0.000000000000000,21236.910000000000000,23077.790000000000000,23510.310000000000000,1840.880200000000000,3,'Invoice',0,0,0,3,NULL,'2008-02-02','2015-09-27',NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2009-04-17 09:45:36','2017-07-19 00:00:01'),(36,6,30,'St. Anky Beer','9295043937','sharon_ward@example.com','Fake Dir n 155\nMadrid\nSpain','Fake Dir n 155\nMadrid\nSpain','Sharon Ward','Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.','Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.',6469.090000000000000,796.018000000000000,5673.072000000000000,6580.760000000000000,6367.850000000000000,907.691520000000000,3,'Invoice',0,0,0,4,NULL,'2006-05-03','2006-06-06',NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2009-04-17 09:45:37','2017-07-19 00:00:01'),(39,9,33,'The Krusty Krab','8248936709','kusatsu_douglas@example.com','Fake Dir n 390\nMadrid\nSpain','Fake Dir n 390\nMadrid\nSpain','Kusatsu Douglas','Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.','Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',30063.500000000000000,0.000000000000000,30063.500000000000000,33058.160000000000000,25028.620000000000000,2994.655200000000000,3,'Invoice',0,0,0,2,NULL,'2006-08-01','2015-09-16',NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2009-04-17 09:45:37','2017-07-19 00:00:01'),(42,12,36,'Big Kahuna Burger','5714673104J','natima_seyetik@example.com','Fake Dir n 734\nMadrid\nSpain','Fake Dir n 734\nMadrid\nSpain','Natima Seyetik','Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.','Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.',18963.520000000000000,0.000000000000000,18963.520000000000000,18820.620000000000000,22191.670000000000000,-142.903100000000000,3,'Invoice',0,0,0,2,NULL,'2006-10-30','2007-03-01',NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2009-04-17 09:45:37','2017-07-19 00:00:01'),(45,12,39,'SpringShield','4716162264W','dmitri_campio@example.com','Fake Dir n 824\nMadrid\nSpain','Fake Dir n 824\nMadrid\nSpain','Dmitri Campio','Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.','Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.',25132.030000000000000,0.000000000000000,25132.030000000000000,26169.270000000000000,27224.250000000000000,1037.244200000000000,3,'Invoice',0,0,0,3,NULL,'2007-01-28','2015-11-30',NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2009-04-17 09:45:37','2017-07-19 00:00:01'),(48,12,42,'Sample, inc','7863841633Q','gerard_bennett@example.com','Fake Dir n 681\nMadrid\nSpain','Fake Dir n 681\nMadrid\nSpain','Gerard Bennett','Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.','Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',1580.400000000000000,0.000000000000000,1580.400000000000000,1633.610000000000000,1876.770000000000000,53.211600000000000,3,'Invoice',0,0,0,4,NULL,'2007-04-28','2008-08-26',NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2009-04-17 09:45:37','2017-07-19 00:00:01'),(51,9,45,'Tessier-Ashpool','3378474903M','ronald_mccullen@example.com','Fake Dir n 802\nMadrid\nSpain','Fake Dir n 802\nMadrid\nSpain','Ronald McCullen','Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.','Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.',26374.370000000000000,1508.840100000000000,24865.529900000000000,24878.590000000000000,29146.360000000000000,13.055492000000000,3,'Invoice',0,0,0,3,NULL,'2007-07-27','2015-08-09',NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2009-04-17 09:45:37','2017-07-19 00:00:01'),(54,6,48,'Fake Brothers','6009961348U','tristan_stone@example.com','Fake Dir n 839\nMadrid\nSpain','Fake Dir n 839\nMadrid\nSpain','Tristan Stone','Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.','Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',3481.950000000000000,0.000000000000000,3481.950000000000000,3199.270000000000000,3823.910000000000000,-282.678000000000000,0,'Invoice',1,0,0,NULL,NULL,'2007-10-25','2008-05-06',NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2009-04-17 09:45:37','2017-06-22 20:55:31'),(57,6,27,'Allied Biscuit','6787068643G','willard_starling@example.com','Fake Dir n 538\nMadrid\nSpain','Fake Dir n 538\nMadrid\nSpain','Willard Starling','Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.','Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.',9561.690000000000000,0.000000000000000,9561.690000000000000,9268.470000000000000,10498.080000000000000,-293.219600000000000,3,'Invoice',0,0,0,5,NULL,'2008-01-23','2015-09-02',NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2009-04-17 09:45:37','2017-06-22 20:55:31'),(60,6,51,'Sonky Rubber Goods','40487600161','olivia_mirren@example.com','Fake Dir n 47\nMadrid\nSpain','Fake Dir n 47\nMadrid\nSpain','Olivia Mirren','Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.','Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',15940.250000000000000,49.489200000000000,15890.760800000000000,17452.830000000000000,15163.290000000000000,1562.067128000000000,3,'Invoice',0,0,0,6,NULL,'2008-04-22','2015-09-18',NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2009-04-17 09:45:37','2017-07-19 00:00:01'),(63,12,54,'BLAND Corporation','6812087434H','kestra_o\'malley@example.com','Fake Dir n 983\nMadrid\nSpain','Fake Dir n 983\nMadrid\nSpain','Kestra O\'Malley','Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.','Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.',16827.550000000000000,1596.674000000000000,15230.876000000000000,14818.540000000000000,16936.690000000000000,-412.337960000000000,3,'Invoice',0,0,0,5,NULL,'2008-07-21','2015-09-15',NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2009-04-17 09:45:37','2017-07-19 00:00:01'),(66,6,57,'Initech','1674636932B','orfil_johnson@example.com','Fake Dir n 700\nMadrid\nSpain','Fake Dir n 700\nMadrid\nSpain','Orfil Johnson','Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.','Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.',9014.490000000000000,1351.060200000000000,7663.429800000000000,8110.140000000000000,8110.140000000000000,446.708934000000000,1,'Invoice',0,1,0,7,NULL,'2008-10-19','2015-06-28',NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2009-04-17 09:45:37','2017-06-22 20:55:31'),(69,9,36,'Big Kahuna Burger','3641026692R','mary_ellen_ingram@example.com','Fake Dir n 763\nMadrid\nSpain','Fake Dir n 763\nMadrid\nSpain','Mary Ellen Ingram','Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.','Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',4800.480000000000000,1356.348000000000000,3444.132000000000000,3995.190000000000000,3468.240000000000000,551.061120000000000,3,'Invoice',0,0,0,4,NULL,'2009-01-17','2015-08-10',NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2009-04-17 09:45:38','2017-07-19 00:00:00'),(72,6,42,'Sample, inc','7863841633Q','gerard_bennett@example.com','Fake Dir n 687\nMadrid\nSpain','Fake Dir n 687\nMadrid\nSpain','Gerard Bennett','Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.','Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.',12233.020000000000000,0.000000000000000,12233.020000000000000,13287.420000000000000,12566.940000000000000,1054.398400000000000,3,'Invoice',0,0,0,8,NULL,'2009-04-17','2015-02-06',NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2009-04-17 09:45:38','2017-06-22 20:55:31'),(75,6,12,'Smith and Co.','2450626775P','jody_nichols@example.com','Fake Dir n 262\nMadrid\nSpain','Fake Dir n 262\nMadrid\nSpain','Jody Nichols','Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.','Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',7198.850000000000000,0.000000000000000,7198.850000000000000,8233.650000000000000,NULL,1034.799500000000000,1,'Estimate',0,0,0,1,NULL,'2007-08-11',NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2009-04-17 09:45:36','2017-06-22 20:55:31'),(78,6,15,'Rouster and Sideways','1889335077','varria_leijten@example.com','Fake Dir n 871\nMadrid\nSpain','Fake Dir n 871\nMadrid\nSpain','Varria Leijten','Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.','Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',11571.890000000000000,0.000000000000000,11571.890000000000000,13407.920000000000000,NULL,1836.026000000000000,1,'Estimate',0,0,0,2,NULL,'2008-11-09',NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2009-04-17 09:45:36','2017-06-22 20:55:31'),(81,6,18,'Western Gas & Electric','3924395949G','marissa_peers@example.com','Fake Dir n 88\nMadrid\nSpain','Fake Dir n 88\nMadrid\nSpain','Marissa Peers','Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.','Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',11521.020000000000000,0.000000000000000,11521.020000000000000,11737.500000000000000,NULL,216.480000000000000,2,'Estimate',0,0,0,3,NULL,'2008-02-07',NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2009-04-17 09:45:36','2017-06-22 20:55:31'),(84,6,21,'Osato Chemicals','4499553670X','julie_radue@example.com','Fake Dir n 969\nMadrid\nSpain','Fake Dir n 969\nMadrid\nSpain','Julie Radue','Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.','Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',15419.960000000000000,0.000000000000000,15419.960000000000000,14291.560000000000000,NULL,-1128.403200000000000,3,'Estimate',0,0,0,4,NULL,'2005-05-08',NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2009-04-17 09:45:36','2017-06-22 20:55:31'),(87,6,24,'123 Warehousing','77426541881','cyrus_decker@example.com','Fake Dir n 39\nMadrid\nSpain','Fake Dir n 39\nMadrid\nSpain','Cyrus Decker','Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.','Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.',4802.700000000000000,1077.245400000000000,3725.454600000000000,3986.240000000000000,NULL,260.781822000000000,0,'Estimate',1,0,0,NULL,NULL,'2008-08-06',NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2009-04-17 09:45:36','2017-06-22 20:55:31');
/*!40000 ALTER TABLE `common` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customer`
--

DROP TABLE IF EXISTS `customer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `customer` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT NULL,
  `name_slug` varchar(100) DEFAULT NULL,
  `identification` varchar(50) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `contact_person` varchar(100) DEFAULT NULL,
  `invoicing_address` longtext,
  `shipping_address` longtext,
  PRIMARY KEY (`id`),
  UNIQUE KEY `cstm_idx` (`name`),
  UNIQUE KEY `cstm_slug_idx` (`name_slug`)
) ENGINE=InnoDB AUTO_INCREMENT=58 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customer`
--

LOCK TABLES `customer` WRITE;
/*!40000 ALTER TABLE `customer` DISABLE KEYS */;
INSERT INTO `customer` VALUES (6,'Krustyco','krustyco','6852996407X','valeria_starling@example.com','Valeria Starling','Fake Dir n 899\nMadrid\nSpain','Fake Dir n 899\nMadrid\nSpain'),(9,'Plow King','plowking','7885556345D','jennifer_karidian@example.com','Jennifer Karidian','Fake Dir n 812\nMadrid\nSpain','Fake Dir n 812\nMadrid\nSpain'),(12,'Smith and Co.','smithandco','2450626775P','jody_nichols@example.com','Jody Nichols','Fake Dir n 262\nMadrid\nSpain','Fake Dir n 262\nMadrid\nSpain'),(15,'Rouster and Sideways','rousterandsideways','1889335077','varria_leijten@example.com','Varria Leijten','Fake Dir n 871\nMadrid\nSpain','Fake Dir n 871\nMadrid\nSpain'),(18,'Western Gas & Electric','westerngaselectric','3924395949G','marissa_peers@example.com','Marissa Peers','Fake Dir n 88\nMadrid\nSpain','Fake Dir n 88\nMadrid\nSpain'),(21,'Osato Chemicals','osatochemicals','4499553670X','julie_radue@example.com','Julie Radue','Fake Dir n 969\nMadrid\nSpain','Fake Dir n 969\nMadrid\nSpain'),(24,'123 Warehousing','123warehousing','77426541881','cyrus_decker@example.com','Cyrus Decker','Fake Dir n 39\nMadrid\nSpain','Fake Dir n 39\nMadrid\nSpain'),(27,'Allied Biscuit','alliedbiscuit','6787068643G','willard_starling@example.com','Willard Starling','Fake Dir n 617\nMadrid\nSpain','Fake Dir n 617\nMadrid\nSpain'),(30,'St. Anky Beer','stankybeer','9295043937','sharon_ward@example.com','Sharon Ward','Fake Dir n 424\nMadrid\nSpain','Fake Dir n 424\nMadrid\nSpain'),(33,'The Krusty Krab','thekrustykrab','8248936709','kusatsu_douglas@example.com','Kusatsu Douglas','Fake Dir n 390\nMadrid\nSpain','Fake Dir n 390\nMadrid\nSpain'),(36,'Big Kahuna Burger','bigkahunaburger','5714673104J','natima_seyetik@example.com','Natima Seyetik','Fake Dir n 734\nMadrid\nSpain','Fake Dir n 734\nMadrid\nSpain'),(39,'SpringShield','springshield','4716162264W','dmitri_campio@example.com','Dmitri Campio','Fake Dir n 824\nMadrid\nSpain','Fake Dir n 824\nMadrid\nSpain'),(42,'Sample, inc','sampleinc','7863841633Q','gerard_bennett@example.com','Gerard Bennett','Fake Dir n 681\nMadrid\nSpain','Fake Dir n 681\nMadrid\nSpain'),(45,'Tessier-Ashpool','tessierashpool','3378474903M','ronald_mccullen@example.com','Ronald McCullen','Fake Dir n 802\nMadrid\nSpain','Fake Dir n 802\nMadrid\nSpain'),(48,'Fake Brothers','fakebrothers','6009961348U','tristan_stone@example.com','Tristan Stone','Fake Dir n 839\nMadrid\nSpain','Fake Dir n 839\nMadrid\nSpain'),(51,'Sonky Rubber Goods','sonkyrubbergoods','40487600161','olivia_mirren@example.com','Olivia Mirren','Fake Dir n 47\nMadrid\nSpain','Fake Dir n 47\nMadrid\nSpain'),(54,'BLAND Corporation','blandcorporation','6812087434H','kestra_o\'malley@example.com','Kestra O\'Malley','Fake Dir n 983\nMadrid\nSpain','Fake Dir n 983\nMadrid\nSpain'),(57,'Initech','initech','1674636932B','orfil_johnson@example.com','Orfil Johnson','Fake Dir n 700\nMadrid\nSpain','Fake Dir n 700\nMadrid\nSpain');
/*!40000 ALTER TABLE `customer` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `item`
--

DROP TABLE IF EXISTS `item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `item` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `quantity` decimal(53,15) NOT NULL DEFAULT '1.000000000000000',
  `discount` decimal(53,2) NOT NULL DEFAULT '0.00',
  `common_id` bigint(20) DEFAULT NULL,
  `product_id` bigint(20) DEFAULT NULL,
  `description` varchar(20000) DEFAULT NULL,
  `unitary_cost` decimal(53,15) NOT NULL DEFAULT '0.000000000000000',
  PRIMARY KEY (`id`),
  KEY `desc_idx` (`description`(255)),
  KEY `common_id_idx` (`common_id`),
  KEY `product_id_idx` (`product_id`),
  CONSTRAINT `item_common_id_common_id` FOREIGN KEY (`common_id`) REFERENCES `common` (`id`) ON DELETE CASCADE,
  CONSTRAINT `item_product_id_product_id` FOREIGN KEY (`product_id`) REFERENCES `product` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=361 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `item`
--

LOCK TABLES `item` WRITE;
/*!40000 ALTER TABLE `item` DISABLE KEYS */;
INSERT INTO `item` VALUES (6,7.000000000000000,0.00,15,6,'Excepteur sint occaecat',179.540000000000000),(9,8.000000000000000,0.00,15,9,'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.',207.080000000000000),(12,2.000000000000000,0.00,15,NULL,'Ab illo inventore veritatis.',75.370000000000000),(15,7.000000000000000,0.00,15,NULL,'Ab illo inventore veritatis.',304.110000000000000),(18,4.000000000000000,0.00,15,NULL,'Lorem ipsum dolor sit amet, consectetur adipisicing elit.',501.480000000000000),(21,2.000000000000000,0.00,18,12,'Ullamco laboris nisi',99.150000000000000),(24,4.000000000000000,0.00,18,NULL,'Lorem ipsum dolor sit amet, consectetur adipisicing elit.',762.330000000000000),(27,2.000000000000000,0.00,18,NULL,'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.',195.130000000000000),(30,1.000000000000000,0.00,18,NULL,'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',171.960000000000000),(33,9.000000000000000,0.00,18,NULL,'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',862.450000000000000),(36,9.000000000000000,0.00,21,NULL,'Ut enim ad minim',678.780000000000000),(39,10.000000000000000,0.00,21,NULL,'Lorem ipsum dolor sit amet, consectetur adipisicing elit.',541.200000000000000),(42,7.000000000000000,0.00,24,NULL,'Lorem ipsum dolor sit amet, consectetur adipisicing elit.',504.850000000000000),(45,10.000000000000000,0.00,24,NULL,'Ullamco laboris nisi',183.490000000000000),(48,1.000000000000000,0.00,24,NULL,'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.',343.290000000000000),(51,7.000000000000000,0.00,24,NULL,'Ab illo inventore veritatis.',303.460000000000000),(54,5.000000000000000,0.00,24,NULL,'Ab illo inventore veritatis.',85.000000000000000),(57,10.000000000000000,0.00,24,NULL,'Lorem ipsum dolor sit amet, consectetur adipisicing elit.',899.350000000000000),(60,3.000000000000000,49.00,27,15,'Lorem ipsum dolor sit amet, consectetur adipisicing elit.',732.820000000000000),(63,9.000000000000000,0.00,27,NULL,'Lorem ipsum dolor sit amet, consectetur adipisicing elit.',289.360000000000000),(66,9.000000000000000,0.00,30,NULL,'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.',374.440000000000000),(69,10.000000000000000,0.00,30,NULL,'Ab illo inventore veritatis.',235.260000000000000),(72,5.000000000000000,0.00,30,NULL,'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.',564.020000000000000),(75,7.000000000000000,0.00,30,NULL,'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.',778.330000000000000),(78,6.000000000000000,0.00,30,NULL,'Ut enim ad minim',405.720000000000000),(81,3.000000000000000,0.00,30,NULL,'Ullamco laboris nisi',265.870000000000000),(84,3.000000000000000,0.00,30,NULL,'Ab illo inventore veritatis.',812.170000000000000),(87,10.000000000000000,0.00,33,NULL,'Excepteur sint occaecat',363.890000000000000),(90,10.000000000000000,0.00,33,NULL,'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',611.030000000000000),(93,2.000000000000000,0.00,33,NULL,'Lorem ipsum dolor sit amet, consectetur adipisicing elit.',520.550000000000000),(96,4.000000000000000,0.00,33,NULL,'Excepteur sint occaecat',893.680000000000000),(99,9.000000000000000,0.00,33,NULL,'Ab illo inventore veritatis.',284.850000000000000),(102,6.000000000000000,0.00,33,NULL,'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',718.040000000000000),(105,10.000000000000000,62.00,36,NULL,'Lorem ipsum dolor sit amet, consectetur adipisicing elit.',128.390000000000000),(108,1.000000000000000,0.00,36,NULL,'Ut enim ad minim',903.770000000000000),(111,6.000000000000000,0.00,36,NULL,'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',713.570000000000000),(114,5.000000000000000,0.00,39,NULL,'Ut enim ad minim',980.990000000000000),(117,9.000000000000000,0.00,39,NULL,'Excepteur sint occaecat',971.700000000000000),(120,8.000000000000000,0.00,39,NULL,'Ullamco laboris nisi',486.850000000000000),(123,7.000000000000000,0.00,39,NULL,'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',665.750000000000000),(126,1.000000000000000,0.00,39,NULL,'Ab illo inventore veritatis.',216.920000000000000),(129,8.000000000000000,0.00,39,NULL,'Lorem ipsum dolor sit amet, consectetur adipisicing elit.',955.160000000000000),(132,10.000000000000000,0.00,42,NULL,'Lorem ipsum dolor sit amet, consectetur adipisicing elit.',674.590000000000000),(135,3.000000000000000,0.00,42,NULL,'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',477.660000000000000),(138,3.000000000000000,0.00,42,NULL,'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',875.630000000000000),(141,8.000000000000000,0.00,42,NULL,'Excepteur sint occaecat',215.920000000000000),(144,9.000000000000000,0.00,42,NULL,'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.',498.990000000000000),(147,4.000000000000000,0.00,42,NULL,'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.',484.870000000000000),(150,7.000000000000000,0.00,45,NULL,'Excepteur sint occaecat',498.500000000000000),(153,8.000000000000000,0.00,45,NULL,'Ullamco laboris nisi',433.020000000000000),(156,5.000000000000000,0.00,45,NULL,'Ab illo inventore veritatis.',907.400000000000000),(159,7.000000000000000,0.00,45,NULL,'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',962.760000000000000),(162,1.000000000000000,0.00,45,NULL,'Ab illo inventore veritatis.',809.860000000000000),(165,9.000000000000000,0.00,45,NULL,'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',676.910000000000000),(168,3.000000000000000,0.00,48,NULL,'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',312.120000000000000),(171,3.000000000000000,0.00,48,NULL,'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.',214.680000000000000),(174,1.000000000000000,0.00,51,NULL,'Lorem ipsum dolor sit amet, consectetur adipisicing elit.',751.670000000000000),(177,7.000000000000000,0.00,51,NULL,'Excepteur sint occaecat',875.850000000000000),(180,9.000000000000000,0.00,51,NULL,'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',792.830000000000000),(183,9.000000000000000,17.00,51,NULL,'Lorem ipsum dolor sit amet, consectetur adipisicing elit.',986.170000000000000),(186,9.000000000000000,0.00,51,NULL,'Ut enim ad minim',386.750000000000000),(189,3.000000000000000,0.00,54,NULL,'Ut enim ad minim',903.000000000000000),(192,5.000000000000000,0.00,54,NULL,'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',154.590000000000000),(195,3.000000000000000,0.00,57,NULL,'Lorem ipsum dolor sit amet, consectetur adipisicing elit.',274.550000000000000),(198,4.000000000000000,0.00,57,NULL,'Excepteur sint occaecat',427.860000000000000),(201,5.000000000000000,0.00,57,NULL,'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',737.140000000000000),(204,1.000000000000000,0.00,57,NULL,'Ab illo inventore veritatis.',412.980000000000000),(207,4.000000000000000,0.00,57,NULL,'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.',723.180000000000000),(210,5.000000000000000,0.00,57,NULL,'Ullamco laboris nisi',7.040000000000000),(213,6.000000000000000,6.00,60,NULL,'Excepteur sint occaecat',137.470000000000000),(216,7.000000000000000,0.00,60,NULL,'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',623.900000000000000),(219,1.000000000000000,0.00,60,NULL,'Ab illo inventore veritatis.',67.070000000000000),(222,1.000000000000000,0.00,60,NULL,'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',30.980000000000000),(225,10.000000000000000,0.00,60,NULL,'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',222.390000000000000),(228,6.000000000000000,0.00,60,NULL,'Ab illo inventore veritatis.',84.640000000000000),(231,8.000000000000000,0.00,60,NULL,'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.',62.180000000000000),(234,10.000000000000000,0.00,60,NULL,'Lorem ipsum dolor sit amet, consectetur adipisicing elit.',742.090000000000000),(237,4.000000000000000,0.00,63,NULL,'Ullamco laboris nisi',780.380000000000000),(240,10.000000000000000,0.00,63,NULL,'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.',99.680000000000000),(243,6.000000000000000,0.00,63,NULL,'Lorem ipsum dolor sit amet, consectetur adipisicing elit.',490.360000000000000),(246,7.000000000000000,0.00,63,NULL,'Ut enim ad minim',905.340000000000000),(249,5.000000000000000,68.00,63,NULL,'Lorem ipsum dolor sit amet, consectetur adipisicing elit.',469.610000000000000),(252,2.000000000000000,0.00,63,NULL,'Ut enim ad minim',540.820000000000000),(255,9.000000000000000,42.00,66,NULL,'Ut enim ad minim',247.370000000000000),(258,3.000000000000000,0.00,66,NULL,'Ullamco laboris nisi',281.760000000000000),(261,9.000000000000000,7.00,66,NULL,'Ut enim ad minim',660.320000000000000),(264,2.000000000000000,70.00,69,NULL,'Ab illo inventore veritatis.',968.820000000000000),(267,3.000000000000000,0.00,69,NULL,'Ab illo inventore veritatis.',892.640000000000000),(270,6.000000000000000,0.00,69,NULL,'Ab illo inventore veritatis.',30.820000000000000),(273,9.000000000000000,0.00,72,NULL,'Excepteur sint occaecat',737.970000000000000),(276,10.000000000000000,0.00,72,NULL,'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',462.890000000000000),(279,7.000000000000000,0.00,72,NULL,'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.',11.440000000000000),(282,1.000000000000000,0.00,72,NULL,'Ab illo inventore veritatis.',882.310000000000000),(285,1.000000000000000,0.00,6,NULL,'Iure reprehenderit qui in ea voluptate',586.170000000000000),(288,1.000000000000000,0.00,9,NULL,'Nemo enim ipsam voluptatem quia voluptas',881.860000000000000),(291,7.000000000000000,0.00,9,NULL,'Iure reprehenderit qui in ea voluptate',64.370000000000000),(294,3.000000000000000,0.00,9,NULL,'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.',122.410000000000000),(297,3.000000000000000,0.00,12,NULL,'Adipisci velit, sed quia non numquam',936.650000000000000),(300,3.000000000000000,0.00,12,NULL,'Ut enim ad minima',80.520000000000000),(303,4.000000000000000,0.00,12,NULL,'Ullamco laboris nisi',731.360000000000000),(306,7.000000000000000,0.00,75,NULL,'Excepteur sint occaecat',179.540000000000000),(309,8.000000000000000,0.00,75,NULL,'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.',207.080000000000000),(312,2.000000000000000,0.00,75,NULL,'Ab illo inventore veritatis.',75.370000000000000),(315,7.000000000000000,0.00,75,NULL,'Ab illo inventore veritatis.',304.110000000000000),(318,4.000000000000000,0.00,75,NULL,'Lorem ipsum dolor sit amet, consectetur adipisicing elit.',501.480000000000000),(321,2.000000000000000,0.00,78,NULL,'Ullamco laboris nisi',99.150000000000000),(324,4.000000000000000,0.00,78,NULL,'Lorem ipsum dolor sit amet, consectetur adipisicing elit.',762.330000000000000),(327,2.000000000000000,0.00,78,NULL,'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.',195.130000000000000),(330,1.000000000000000,0.00,78,NULL,'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',171.960000000000000),(333,9.000000000000000,0.00,78,NULL,'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',862.450000000000000),(336,9.000000000000000,0.00,81,NULL,'Ut enim ad minim',678.780000000000000),(339,10.000000000000000,0.00,81,NULL,'Lorem ipsum dolor sit amet, consectetur adipisicing elit.',541.200000000000000),(342,7.000000000000000,0.00,84,NULL,'Lorem ipsum dolor sit amet, consectetur adipisicing elit.',504.850000000000000),(345,1.000000000000000,0.00,84,NULL,'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.',343.290000000000000),(348,7.000000000000000,0.00,84,NULL,'Ab illo inventore veritatis.',303.460000000000000),(351,5.000000000000000,0.00,84,NULL,'Ab illo inventore veritatis.',85.000000000000000),(354,10.000000000000000,0.00,84,NULL,'Lorem ipsum dolor sit amet, consectetur adipisicing elit.',899.350000000000000),(357,3.000000000000000,49.00,87,NULL,'Lorem ipsum dolor sit amet, consectetur adipisicing elit.',732.820000000000000),(360,9.000000000000000,0.00,87,NULL,'Lorem ipsum dolor sit amet, consectetur adipisicing elit.',289.360000000000000);
/*!40000 ALTER TABLE `item` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `item_tax`
--

DROP TABLE IF EXISTS `item_tax`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `item_tax` (
  `item_id` bigint(20) NOT NULL,
  `tax_id` bigint(20) NOT NULL,
  PRIMARY KEY (`item_id`,`tax_id`),
  CONSTRAINT `item_tax_item_id_item_id` FOREIGN KEY (`item_id`) REFERENCES `item` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `item_tax`
--

LOCK TABLES `item_tax` WRITE;
/*!40000 ALTER TABLE `item_tax` DISABLE KEYS */;
INSERT INTO `item_tax` VALUES (6,6),(6,15),(9,12),(12,12),(15,6),(15,9),(15,12),(18,6),(21,6),(24,6),(27,6),(30,12),(33,6),(36,6),(39,9),(42,6),(45,6),(48,6),(51,12),(54,9),(57,15),(60,12),(63,12),(66,6),(69,6),(72,9),(75,6),(78,6),(81,9),(84,6),(87,15),(90,6),(93,6),(96,9),(99,6),(102,6),(105,6),(108,6),(111,6),(114,9),(117,6),(120,15),(123,6),(126,12),(129,6),(132,15),(135,6),(138,9),(141,6),(144,6),(144,15),(147,9),(147,12),(150,15),(153,15),(156,6),(159,6),(162,9),(165,9),(168,6),(171,15),(174,9),(177,12),(180,15),(183,6),(183,12),(183,15),(186,6),(186,15),(189,15),(192,6),(195,6),(198,9),(201,15),(204,15),(207,9),(210,6),(213,6),(216,6),(219,6),(222,6),(225,9),(228,12),(231,6),(234,12),(237,15),(240,15),(243,15),(246,12),(249,9),(252,6),(255,12),(258,6),(261,9),(264,6),(267,6),(270,6),(273,9),(276,6),(279,6),(282,9),(285,3),(288,1),(291,1),(294,1),(297,2),(300,2),(303,2),(306,6),(306,15),(309,12),(312,12),(315,6),(315,9),(315,12),(318,6),(321,6),(324,6),(327,6),(330,12),(333,6),(339,9),(345,6),(348,12),(351,9),(354,15),(357,12),(360,12);
/*!40000 ALTER TABLE `item_tax` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `migration_version`
--

DROP TABLE IF EXISTS `migration_version`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `migration_version` (
  `version` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `migration_version`
--

LOCK TABLES `migration_version` WRITE;
/*!40000 ALTER TABLE `migration_version` DISABLE KEYS */;
INSERT INTO `migration_version` VALUES (4);
/*!40000 ALTER TABLE `migration_version` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payment`
--

DROP TABLE IF EXISTS `payment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `payment` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `invoice_id` bigint(20) DEFAULT NULL,
  `date` date DEFAULT NULL,
  `amount` decimal(53,15) DEFAULT NULL,
  `notes` longtext,
  PRIMARY KEY (`id`),
  KEY `invoice_id_idx` (`invoice_id`),
  CONSTRAINT `payment_invoice_id_common_id` FOREIGN KEY (`invoice_id`) REFERENCES `common` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=85 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payment`
--

LOCK TABLES `payment` WRITE;
/*!40000 ALTER TABLE `payment` DISABLE KEYS */;
INSERT INTO `payment` VALUES (6,15,'2004-10-21',8610.680000000000000,'Ullamco laboris nisi'),(9,18,'2005-01-18',13317.870000000000000,'Ullamco laboris nisi'),(12,21,'2005-04-03',11780.260000000000000,'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.'),(15,24,'2005-10-17',9675.130000000000000,'Excepteur sint occaecat'),(18,24,'2006-03-25',4837.570000000000000,'Ut enim ad minim'),(21,27,'2005-09-21',3986.230000000000000,'Ut enim ad minim'),(24,30,'2005-12-17',20804.790000000000000,'Ab illo inventore veritatis.'),(27,33,'2006-08-10',23510.310000000000000,'Ullamco laboris nisi'),(30,36,'2006-05-13',6367.850000000000000,'Ab illo inventore veritatis.'),(33,39,'2006-09-14',7929.860000000000000,'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.'),(36,39,'2006-08-30',5947.400000000000000,'Ab illo inventore veritatis.'),(39,39,'2006-09-04',8921.090000000000000,'Lorem ipsum dolor sit amet, consectetur adipisicing elit.'),(42,39,'2006-09-08',2230.270000000000000,'Ut enim ad minim'),(45,42,'2006-12-07',22191.670000000000000,'Excepteur sint occaecat'),(48,45,'2008-05-26',27224.250000000000000,'Ab illo inventore veritatis.'),(51,48,'2007-11-19',1876.770000000000000,'Ab illo inventore veritatis.'),(54,51,'2007-08-04',29146.360000000000000,'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.'),(57,54,'2007-10-31',3008.980000000000000,'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.'),(60,54,'2008-04-26',752.240000000000000,'Ullamco laboris nisi'),(63,54,'2008-05-01',62.690000000000000,'Ullamco laboris nisi'),(66,57,'2008-04-11',10498.080000000000000,'Ut enim ad minim'),(69,60,'2008-06-30',8664.740000000000000,'Excepteur sint occaecat'),(72,60,'2008-06-20',6498.550000000000000,'Excepteur sint occaecat'),(75,63,'2008-11-22',16936.690000000000000,'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.'),(78,66,'2010-01-30',8110.140000000000000,'Ut enim ad minim'),(81,69,'2009-11-21',3468.240000000000000,'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.'),(84,72,'2009-09-18',12566.940000000000000,'Ullamco laboris nisi');
/*!40000 ALTER TABLE `payment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product`
--

DROP TABLE IF EXISTS `product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `reference` varchar(100) NOT NULL,
  `description` longtext,
  `price` decimal(53,15) NOT NULL DEFAULT '0.000000000000000',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product`
--

LOCK TABLES `product` WRITE;
/*!40000 ALTER TABLE `product` DISABLE KEYS */;
INSERT INTO `product` VALUES (6,'test product 1','test product 1 description',179.540000000000000,'2017-06-22 20:55:29','2017-06-22 20:55:29'),(9,'test product 2','test product 2 description',207.080000000000000,'2017-06-22 20:55:29','2017-06-22 20:55:29'),(12,'test product 3','test product 3 description',99.150000000000000,'2017-06-22 20:55:29','2017-06-22 20:55:29'),(15,'test product 4','test product 4 description',732.820000000000000,'2017-06-22 20:55:29','2017-06-22 20:55:29'),(18,'prod 5','description of prod 5',11780.260000000000000,'2017-06-22 20:55:29','2017-06-22 20:55:29'),(21,'prod 6','description of prod 6',21780.260000000000000,'2017-06-22 20:55:29','2017-06-22 20:55:29');
/*!40000 ALTER TABLE `product` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `property`
--

DROP TABLE IF EXISTS `property`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `property` (
  `keey` varchar(50) NOT NULL,
  `value` longtext,
  PRIMARY KEY (`keey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `property`
--

LOCK TABLES `property` WRITE;
/*!40000 ALTER TABLE `property` DISABLE KEYS */;
INSERT INTO `property` VALUES ('company_address','\"Some Address\"'),('company_email','\"support@invoicerltd.com\"'),('company_fax','\"01-2-3456781\"'),('company_name','\"Invoicer LTD\"'),('company_phone','\"01-2-3456789\"'),('company_url','\"http:\\/\\/www.invoicerltd.com\"'),('currency','\"USD\"'),('currency_decimals','2'),('default_template','1'),('last_calculation_date','\"2017-07-19\"'),('legal_terms','\"INVOICE TERMS: Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.\"'),('sample_data_load','0'),('siwapp_modules','[\"customers\",\"estimates\",\"products\"]');
/*!40000 ALTER TABLE `property` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `series`
--

DROP TABLE IF EXISTS `series`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `series` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `value` varchar(255) DEFAULT NULL,
  `first_number` int(11) DEFAULT '1',
  `enabled` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `series`
--

LOCK TABLES `series` WRITE;
/*!40000 ALTER TABLE `series` DISABLE KEYS */;
INSERT INTO `series` VALUES (6,'Internet','ASET-',1,1),(9,'Design','BSET-',1,1),(12,'Others','CSET-',1,1);
/*!40000 ALTER TABLE `series` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sf_guard_group`
--

DROP TABLE IF EXISTS `sf_guard_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sf_guard_group` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `description` text,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sf_guard_group`
--

LOCK TABLES `sf_guard_group` WRITE;
/*!40000 ALTER TABLE `sf_guard_group` DISABLE KEYS */;
/*!40000 ALTER TABLE `sf_guard_group` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sf_guard_group_permission`
--

DROP TABLE IF EXISTS `sf_guard_group_permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sf_guard_group_permission` (
  `group_id` int(11) NOT NULL,
  `permission_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`group_id`,`permission_id`),
  KEY `sf_guard_group_permission_permission_id_sf_guard_permission_id` (`permission_id`),
  CONSTRAINT `sf_guard_group_permission_group_id_sf_guard_group_id` FOREIGN KEY (`group_id`) REFERENCES `sf_guard_group` (`id`) ON DELETE CASCADE,
  CONSTRAINT `sf_guard_group_permission_permission_id_sf_guard_permission_id` FOREIGN KEY (`permission_id`) REFERENCES `sf_guard_permission` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sf_guard_group_permission`
--

LOCK TABLES `sf_guard_group_permission` WRITE;
/*!40000 ALTER TABLE `sf_guard_group_permission` DISABLE KEYS */;
/*!40000 ALTER TABLE `sf_guard_group_permission` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sf_guard_permission`
--

DROP TABLE IF EXISTS `sf_guard_permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sf_guard_permission` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `description` text,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sf_guard_permission`
--

LOCK TABLES `sf_guard_permission` WRITE;
/*!40000 ALTER TABLE `sf_guard_permission` DISABLE KEYS */;
/*!40000 ALTER TABLE `sf_guard_permission` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sf_guard_remember_key`
--

DROP TABLE IF EXISTS `sf_guard_remember_key`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sf_guard_remember_key` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `remember_key` varchar(32) DEFAULT NULL,
  `ip_address` varchar(50) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`,`ip_address`),
  KEY `user_id_idx` (`user_id`),
  CONSTRAINT `sf_guard_remember_key_user_id_sf_guard_user_id` FOREIGN KEY (`user_id`) REFERENCES `sf_guard_user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sf_guard_remember_key`
--

LOCK TABLES `sf_guard_remember_key` WRITE;
/*!40000 ALTER TABLE `sf_guard_remember_key` DISABLE KEYS */;
/*!40000 ALTER TABLE `sf_guard_remember_key` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sf_guard_user`
--

DROP TABLE IF EXISTS `sf_guard_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sf_guard_user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(128) NOT NULL,
  `algorithm` varchar(128) NOT NULL DEFAULT 'sha1',
  `salt` varchar(128) DEFAULT NULL,
  `password` varchar(128) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `is_super_admin` tinyint(1) DEFAULT '0',
  `last_login` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  KEY `is_active_idx_idx` (`is_active`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sf_guard_user`
--

LOCK TABLES `sf_guard_user` WRITE;
/*!40000 ALTER TABLE `sf_guard_user` DISABLE KEYS */;
INSERT INTO `sf_guard_user` VALUES (1,'siwapp','sha1','9d41e10c3f3183a92618d2bf8822e439','a82993dd0d93665f3aded5dfddd5553b76bcee2d',1,1,'2017-07-19 05:57:14','2017-06-22 15:55:28','2017-07-19 17:57:14');
/*!40000 ALTER TABLE `sf_guard_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sf_guard_user_group`
--

DROP TABLE IF EXISTS `sf_guard_user_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sf_guard_user_group` (
  `user_id` int(11) NOT NULL,
  `group_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`user_id`,`group_id`),
  KEY `sf_guard_user_group_group_id_sf_guard_group_id` (`group_id`),
  CONSTRAINT `sf_guard_user_group_group_id_sf_guard_group_id` FOREIGN KEY (`group_id`) REFERENCES `sf_guard_group` (`id`) ON DELETE CASCADE,
  CONSTRAINT `sf_guard_user_group_user_id_sf_guard_user_id` FOREIGN KEY (`user_id`) REFERENCES `sf_guard_user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sf_guard_user_group`
--

LOCK TABLES `sf_guard_user_group` WRITE;
/*!40000 ALTER TABLE `sf_guard_user_group` DISABLE KEYS */;
/*!40000 ALTER TABLE `sf_guard_user_group` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sf_guard_user_permission`
--

DROP TABLE IF EXISTS `sf_guard_user_permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sf_guard_user_permission` (
  `user_id` int(11) NOT NULL,
  `permission_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`user_id`,`permission_id`),
  KEY `sf_guard_user_permission_permission_id_sf_guard_permission_id` (`permission_id`),
  CONSTRAINT `sf_guard_user_permission_permission_id_sf_guard_permission_id` FOREIGN KEY (`permission_id`) REFERENCES `sf_guard_permission` (`id`) ON DELETE CASCADE,
  CONSTRAINT `sf_guard_user_permission_user_id_sf_guard_user_id` FOREIGN KEY (`user_id`) REFERENCES `sf_guard_user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sf_guard_user_permission`
--

LOCK TABLES `sf_guard_user_permission` WRITE;
/*!40000 ALTER TABLE `sf_guard_user_permission` DISABLE KEYS */;
/*!40000 ALTER TABLE `sf_guard_user_permission` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sf_guard_user_profile`
--

DROP TABLE IF EXISTS `sf_guard_user_profile`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sf_guard_user_profile` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `sf_guard_user_id` int(11) DEFAULT NULL,
  `first_name` varchar(50) DEFAULT NULL,
  `last_name` varchar(50) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `nb_display_results` smallint(6) DEFAULT NULL,
  `language` varchar(3) DEFAULT NULL,
  `country` varchar(2) DEFAULT NULL,
  `search_filter` varchar(30) DEFAULT NULL,
  `series` varchar(50) DEFAULT NULL,
  `hash` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  KEY `sf_guard_user_id_idx` (`sf_guard_user_id`),
  CONSTRAINT `sf_guard_user_profile_sf_guard_user_id_sf_guard_user_id` FOREIGN KEY (`sf_guard_user_id`) REFERENCES `sf_guard_user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sf_guard_user_profile`
--

LOCK TABLES `sf_guard_user_profile` WRITE;
/*!40000 ALTER TABLE `sf_guard_user_profile` DISABLE KEYS */;
INSERT INTO `sf_guard_user_profile` VALUES (1,1,NULL,NULL,'admin@siwapp.com',NULL,'en','','',NULL,NULL);
/*!40000 ALTER TABLE `sf_guard_user_profile` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tag`
--

DROP TABLE IF EXISTS `tag`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tag` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT NULL,
  `is_triple` tinyint(1) DEFAULT NULL,
  `triple_namespace` varchar(100) DEFAULT NULL,
  `triple_key` varchar(100) DEFAULT NULL,
  `triple_value` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `name_idx` (`name`),
  KEY `triple1_idx` (`triple_namespace`),
  KEY `triple2_idx` (`triple_key`),
  KEY `triple3_idx` (`triple_value`)
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tag`
--

LOCK TABLES `tag` WRITE;
/*!40000 ALTER TABLE `tag` DISABLE KEYS */;
INSERT INTO `tag` VALUES (6,'veniam',0,NULL,NULL,NULL),(9,'non',0,NULL,NULL,NULL),(12,'velit',0,NULL,NULL,NULL),(15,'commodo',0,NULL,NULL,NULL),(18,'sit',0,NULL,NULL,NULL),(21,'exercitation',0,NULL,NULL,NULL),(24,'do',0,NULL,NULL,NULL),(27,'lorem',0,NULL,NULL,NULL),(30,'laboris',0,NULL,NULL,NULL),(33,'nostrud',0,NULL,NULL,NULL);
/*!40000 ALTER TABLE `tag` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tagging`
--

DROP TABLE IF EXISTS `tagging`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tagging` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tag_id` bigint(20) NOT NULL,
  `taggable_model` varchar(30) DEFAULT NULL,
  `taggable_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `tag_idx` (`tag_id`),
  KEY `taggable_idx` (`taggable_model`,`taggable_id`)
) ENGINE=InnoDB AUTO_INCREMENT=64 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tagging`
--

LOCK TABLES `tagging` WRITE;
/*!40000 ALTER TABLE `tagging` DISABLE KEYS */;
INSERT INTO `tagging` VALUES (6,6,'Invoice',1),(9,9,'Invoice',1),(12,12,'Invoice',2),(15,12,'Invoice',3),(18,15,'Invoice',3),(21,18,'Invoice',3),(24,21,'Invoice',3),(27,24,'Invoice',3),(30,27,'Invoice',4),(33,30,'Invoice',4),(36,33,'Invoice',4),(39,15,'Invoice',7),(42,30,'Invoice',8),(45,6,'Invoice',8),(48,15,'Invoice',9),(51,30,'Invoice',14),(54,18,'Invoice',15),(57,24,'Invoice',16),(60,15,'Invoice',17),(63,30,'Invoice',18);
/*!40000 ALTER TABLE `tagging` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tax`
--

DROP TABLE IF EXISTS `tax`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tax` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  `value` decimal(53,2) DEFAULT NULL,
  `active` tinyint(1) DEFAULT '1',
  `is_default` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tax`
--

LOCK TABLES `tax` WRITE;
/*!40000 ALTER TABLE `tax` DISABLE KEYS */;
INSERT INTO `tax` VALUES (6,'IVA 16%',16.00,1,1),(9,'IVA 4%',4.00,1,0),(12,'IVA 7%',7.00,0,0),(15,'IRPF',-15.00,1,1);
/*!40000 ALTER TABLE `tax` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `template`
--

DROP TABLE IF EXISTS `template`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `template` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `template` longtext,
  `models` varchar(200) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `slug` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `template_sluggable_idx` (`slug`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `template`
--

LOCK TABLES `template` WRITE;
/*!40000 ALTER TABLE `template` DISABLE KEYS */;
INSERT INTO `template` VALUES (6,'Invoice Template','<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.1//EN\" \"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd\">\n<html lang=\"{{lang}}\" xmlns=\"http://www.w3.org/1999/xhtml\">\n<head>\n  <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n  <title>Invoice</title>\n\n  <style type=\"text/css\">\n    /* Custom CSS code */\n    table {border-spacing:0; border-collapse: collapse;}\n    ul {list-style-type: none; padding-left:0;}\n    body, input, textarea { font-family:helvetica,sans-serif; font-size:8pt; }\n    body { color:#464648; margin:2cm 1.5cm; }\n    h2   { color:#535255; font-size:16pt; font-weight:normal; line-height:1.2em; border-bottom:1px solid #DB4823; margin-right:220px }\n    h3   { color:#9A9A9A; font-size:13pt; font-weight:normal; margin-bottom: 0em}\n\n    table th.right,\n    table td.right              { text-align:right; }\n\n    .customer-data              { padding:1em 0; }\n    .customer-data table        { width:100%;       }\n    .customer-data table td     { width:50%;        }\n    .customer-data td span      { display:block; margin:0 0 5pt; padding-bottom:2pt; border-bottom:1px solid #DCDCDC; }\n    .customer-data td span.left { margin-right:1em; }\n    .customer-data label        { display:block; font-weight:bold; font-size:8pt; }\n    .payment-data               { padding:1em 0;    }\n    .payment-data table         { width:100%;       }\n    .payment-data th,\n    .payment-data td            { line-height:1em; padding:5pt 8pt 5pt; border:1px solid #DCDCDC; }\n    .payment-data thead th      { background:#FAFAFA; }\n    .payment-data th            { font-weight:bold; white-space:nowrap; }\n    .payment-data .bottomleft   { border-color:white; border-top:inherit; border-right:inherit; }\n    .payment-data span.tax      { display:block; white-space:nowrap; }\n    .terms, .notes              { padding:9pt 0 0; font-size:7pt; line-height:9pt; }\n\n    .section                    { margin-bottom: 1em; }\n    .logo                       { text-align: right; }\n  </style>\n\n  <style type=\"text/css\">\n    /* CSS code for printing */\n    @media print {\n      body           { margin:auto; }\n      .section       { page-break-inside:avoid; }\n      div#sfWebDebug { display:none; }\n    }\n  </style>\n</head>\n<body>\n\n  {% if settings.company_logo %}\n    <div class=\"logo\">\n      <img src=\"{{ settings.company_logo }}\" alt=\"{{ settings.company_name }}\" />\n    </div>\n  {% endif %}\n    \n  <div class=\"h2\">\n    <h2>Invoice #{{invoice}}</h2>\n  </div>\n\n  <div class=\"section\">\n    <div class=\"company-data\">\n      <ul>\n        <li>Company: {{settings.company_name}}</li>\n        <li>Address: {{settings.company_address|format}}</li>\n        <li>Phone: {{settings.company_phone}}</li>\n        <li>Fax: {{settings.company_fax}}</li>\n        <li>Email: {{settings.company_email}}</li>\n        <li>Web: {{settings.company_url}}</li>\n      </ul>\n    </div>\n  </div>\n\n  <div class=\"section\">\n    <h3>Client info</h3>\n\n    <div class=\"customer-data\">\n      <table cellspacing=\"0\" cellpadding=\"0\" width=\"100%\">\n        <tr>\n          <td>\n            <span class=\"left\">\n              <label>Customer:</label>\n              {{invoice.customer_name}}\n            </span>\n          </td>\n          <td>\n            <span class=\"right\">\n              <label>Customer identification:</label>\n              {{invoice.customer_identification}}\n            </span>\n          </td>\n        </tr>\n        <tr>\n          <td>\n            <span class=\"left\">\n              <label>Contact person:</label>\n              {{invoice.contact_person}}\n            </span>\n          </td>\n          <td>\n            <span class=\"right\">\n              <label>Email:</label>\n              {{invoice.customer_email}}\n            </span>\n          </td>\n        </tr>\n        <tr>\n          <td>\n            <span class=\"left\">\n              <label>Invoicing address:</label>\n              {{invoice.invoicing_address|format}}\n            </span>\n          </td>\n          <td>\n            <span class=\"right\">\n              <label>Shipping address:</label>\n              {{invoice.shipping_address|format}}\n            </span>\n          </td>\n        </tr>\n      </table>\n    </div>\n  </div>\n\n  <div class=\"section\">\n    <h3>Payment details</h3>\n\n    <div class=\"payment-data\">\n      <table>\n        <thead>\n          <tr>\n            <th>Description</th>\n            <th class=\"right\">Unit Cost</th>\n            <th class=\"right\">Qty</th>\n            <th class=\"right\">Taxes</th>\n            {# show discounts only if there is some discount #}\n            {% if invoice.discount_amount %}\n            <th class=\"right\">Discount</th>\n            {% endif %}\n            <th class=\"right\">Price</th>\n          </tr>\n        </thead>\n        <tbody>\n          {% for item in invoice.Items %}\n            <tr>\n              <td>\n                {{item.description}}\n              </td>\n              <td class=\"right\">{{item.unitary_cost|currency}}</td>\n              <td class=\"right\">{{item.quantity}}</td>\n              <td class=\"right\">\n                {% for tax in item.Taxes %}\n                  <span class=\"tax\">{{tax.name}}</span>\n                {% endfor %}\n              </td>\n              {% if invoice.discount_amount %}\n              <td class=\"right\">{{item.discount_amount|currency}}</td>\n              {% endif %}\n              <td class=\"right\">{{item.gross_amount|currency}}</td>\n            </tr>\n          {% endfor %}\n        </tbody>\n        <tfoot>\n          <tr>\n            <td class=\"bottomleft\" colspan=\"{% if invoice.discount_amount %}4{% else %}3{% endif %}\"></td>\n            <th class=\"right\">Base</th>\n            <td class=\"right\">{{invoice.base_amount|currency}}</td>\n          </tr>\n          {% if invoice.discount_amount %}\n          <tr>\n            <td class=\"bottomleft\" colspan=\"{% if invoice.discount_amount %}4{% else %}3{% endif %}\"></td>\n            <th class=\"right\">Discount</th>\n            <td class=\"td_global_discount right\">{{invoice.discount_amount|currency}}</td>\n          </tr>\n          {% endif %}\n          <tr>\n            <td class=\"bottomleft\" colspan=\"{% if invoice.discount_amount %}4{% else %}3{% endif %}\"></td>\n            <th class=\"right\">Subtotal</th>\n            <td class=\"td_subtotal right\">{{invoice.net_amount|currency}}</td>\n          </tr>\n          <tr>\n            <td class=\"bottomleft\" colspan=\"{% if invoice.discount_amount %}4{% else %}3{% endif %}\"></td>\n            <th class=\"right\">Taxes</th>\n            <td class=\"td_total_taxes right\">{{invoice.tax_amount|currency}}</td>\n          </tr>\n          <tr class=\"strong\">\n            <td class=\"bottomleft\" colspan=\"{% if invoice.discount_amount %}4{% else %}3{% endif %}\"></td>\n            <th class=\"right\">Total</th>\n            <td class=\"td_total right\">{{invoice.gross_amount|currency}}</td>\n          </tr>\n        </tfoot>\n      </table>\n    </div>\n  </div>\n  \n  <div class=\"section\">\n    <h3>Terms & conditions</h3>\n    <div class=\"terms\">\n      {{invoice.terms|format}}\n    </div>\n  </div>\n</body>\n</html>\n','Invoice','2017-06-22 15:55:28','2017-06-22 15:55:28','invoice-template'),(9,'Template with product','<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.1//EN\" \"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd\">\n<html lang=\"{{lang}}\" xmlns=\"http://www.w3.org/1999/xhtml\">\n<head>\n <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n <title>Invoice</title>\n\n <style type=\"text/css\">\n   /* Custom CSS code */\n   table {border-spacing:0; border-collapse: collapse;}\n   ul {list-style-type: none; padding-left:0;}\n   body, input, textarea { font-family:helvetica,sans-serif; font-size:8pt; }\n   body { color:#464648; margin:2cm 1.5cm; }\n   h2   { color:#535255; font-size:16pt; font-weight:normal; line-height:1.2em; border-bottom:1px solid #DB4823; margin-right:220px }\n   h3   { color:#9A9A9A; font-size:13pt; font-weight:normal; margin-bottom: 0em}\n\n   table th.right,\n   table td.right              { text-align:right; }\n\n   .customer-data              { padding:1em 0; }\n   .customer-data table        { width:100%;       }\n   .customer-data table td     { width:50%;        }\n   .customer-data td span      { display:block; margin:0 0 5pt; padding-bottom:2pt; border-bottom:1px solid #DCDCDC; }\n   .customer-data td span.left { margin-right:1em; }\n   .customer-data label        { display:block; font-weight:bold; font-size:8pt; }\n   .payment-data               { padding:1em 0;    }\n   .payment-data table         { width:100%;       }\n   .payment-data th,\n   .payment-data td            { line-height:1em; padding:5pt 8pt 5pt; border:1px solid #DCDCDC; }\n   .payment-data thead th      { background:#FAFAFA; }\n   .payment-data th            { font-weight:bold; white-space:nowrap; }\n   .payment-data .bottomleft   { border-color:white; border-top:inherit; border-right:inherit; }\n   .payment-data span.tax      { display:block; white-space:nowrap; }\n   .terms, .notes              { padding:9pt 0 0; font-size:7pt; line-height:9pt; }\n\n   .section                    { margin-bottom: 1em; }\n   .logo                       { text-align: right; }\n </style>\n\n <style type=\"text/css\">\n   /* CSS code for printing */\n   @media print {\n     body           { margin:auto; }\n     .section       { page-break-inside:avoid; }\n     div#sfWebDebug { display:none; }\n   }\n </style>\n</head>\n<body>\n\n {% if settings.company_logo %}\n   <div class=\"logo\">\n     <img src=\"{{ settings.company_logo }}\" alt=\"{{ settings.company_name }}\" />\n   </div>\n {% endif %}\n\n <div class=\"h2\">\n   <h2>Invoice #{{invoice.number}}</h2>\n </div>\n\n <div class=\"section\">\n   <div class=\"company-data\">\n     <ul>\n       <li>Company: {{settings.company_name}}</li>\n       <li>Address: {{settings.company_address|format}}</li>\n       <li>Phone: {{settings.company_phone}}</li>\n       <li>Fax: {{settings.company_fax}}</li>\n       <li>Email: {{settings.company_email}}</li>\n       <li>Web: {{settings.company_url}}</li>\n     </ul>\n   </div>\n </div>\n\n <div class=\"section\">\n   <h3>Client info</h3>\n\n   <div class=\"customer-data\">\n     <table cellspacing=\"0\" cellpadding=\"0\" width=\"100%\">\n       <tr>\n         <td>\n           <span class=\"left\">\n             <label>Customer:</label>\n             {{invoice.customer_name}}\n           </span>\n         </td>\n         <td>\n           <span class=\"right\">\n             <label>Customer identification:</label>\n             {{invoice.customer_identification}}\n           </span>\n         </td>\n       </tr>\n       <tr>\n         <td>\n           <span class=\"left\">\n             <label>Contact person:</label>\n             {{invoice.contact_person}}\n           </span>\n         </td>\n         <td>\n           <span class=\"right\">\n             <label>Email:</label>\n             {{invoice.customer_email}}\n           </span>\n         </td>\n       </tr>\n       <tr>\n         <td>\n           <span class=\"left\">\n             <label>Invoicing address:</label>\n             {{invoice.invoicing_address|format}}\n           </span>\n         </td>\n         <td>\n           <span class=\"right\">\n             <label>Shipping address:</label>\n             {{invoice.shipping_address|format}}\n           </span>\n         </td>\n       </tr>\n     </table>\n   </div>\n </div>\n\n <div class=\"section\">\n   <h3>Payment details</h3>\n\n   <div class=\"payment-data\">\n     <table>\n       <thead>\n         <tr>\n           <th>Reference</th>\n           <th>Description</th>\n           <th class=\"right\">Unit Cost</th>\n           <th class=\"right\">Qty</th>\n           <th class=\"right\">TVA</th>\n           {# show discounts only if there is some discount #}\n           {% if invoice.discount_amount %}\n           <th class=\"right\">Discount</th>\n           {% endif %}\n           <th class=\"right\">Price</th>\n         </tr>\n       </thead>\n       <tbody>\n         {% for item in invoice.Items %}\n           <tr>\n             <td>\n               {{item.product_id|product_reference}}\n             </td>\n             <td>\n               {{item.description}}\n             </td>\n             <td class=\"right\">{{item.unitary_cost|currency}}</td>\n             <td class=\"right\">{{item.quantity}}</td>\n             <td class=\"right\">\n               {% for tax in item.Taxes %}\n                 <span class=\"tax\">{{tax.name}}</span>\n               {% endfor %}\n             </td>\n             {% if invoice.discount_amount %}\n             <td class=\"right\">{{item.discount|currency}}</td>\n             {% endif %}\n             <td class=\"right\">{{item.gross|currency}}</td>\n           </tr>\n         {% endfor %}\n       </tbody>\n       <tfoot>\n         <tr>\n           <td class=\"bottomleft\" colspan=\"{% if invoice.discount_amount %}5{% else %}4{% endif %}\"></td>\n           <th class=\"right\">Base</th>\n           <td class=\"right\">{{invoice.base_amount|currency}}</td>\n         </tr>\n         {% if invoice.discount_amount %}\n         <tr>\n           <td class=\"bottomleft\" colspan=\"{% if invoice.discount_amount %}5{% else %}4{% endif %}\"></td>\n           <th class=\"right\">Discount</th>\n           <td class=\"td_global_discount right\">{{invoice.discount_amount|currency}}</td>\n         </tr>\n         {% endif %}\n         <tr>\n           <td class=\"bottomleft\" colspan=\"{% if invoice.discount_amount %}5{% else %}4{% endif %}\"></td>\n           <th class=\"right\">Subtotal</th>\n           <td class=\"td_subtotal right\">{{invoice.net_amount|currency}}</td>\n         </tr>\n         <tr>\n           <td class=\"bottomleft\" colspan=\"{% if invoice.discount_amount %}5{% else %}4{% endif %}\"></td>\n           <th class=\"right\">Taxes</th>\n           <td class=\"td_total_taxes right\">{{invoice.tax_amount|currency}}</td>\n         </tr>\n         <tr class=\"strong\">\n           <td class=\"bottomleft\" colspan=\"{% if invoice.discount_amount %}5{% else %}4{% endif %}\"></td>\n           <th class=\"right\">Total</th>\n           <td class=\"td_total right\">{{invoice.gross_amount|currency}}</td>\n         </tr>\n       </tfoot>\n     </table>\n   </div>\n </div>\n\n <div class=\"section\">\n   <h3>Terms & conditions</h3>\n   <div class=\"terms\">\n     {{invoice.terms|format}}\n   </div>\n </div>\n</body>\n</html>\n','Invoice','2017-06-22 15:55:28','2017-06-22 15:55:28','template-with-product'),(12,'Estimate Template','<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.1//EN\" \"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd\">\n<html lang=\"{{lang}}\" xmlns=\"http://www.w3.org/1999/xhtml\">\n<head>\n  <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n  <title>Estimate</title>\n\n  <style type=\"text/css\">\n    /* Custom CSS code */\n    table {border-spacing:0; border-collapse: collapse;}\n    ul {list-style-type: none; padding-left:0;}\n    body, input, textarea { font-family:helvetica,sans-serif; font-size:8pt; }\n    body { color:#464648; margin:2cm 1.5cm; }\n    h2   { color:#535255; font-size:16pt; font-weight:normal; line-height:1.2em; border-bottom:1px solid #DB4823; margin-right:220px }\n    h3   { color:#9A9A9A; font-size:13pt; font-weight:normal; margin-bottom: 0em}\n\n    table th.right,\n    table td.right              { text-align:right; }\n\n    .customer-data              { padding:1em 0; }\n    .customer-data table        { width:100%;       }\n    .customer-data table td     { width:50%;        }\n    .customer-data td span      { display:block; margin:0 0 5pt; padding-bottom:2pt; border-bottom:1px solid #DCDCDC; }\n    .customer-data td span.left { margin-right:1em; }\n    .customer-data label        { display:block; font-weight:bold; font-size:8pt; }\n    .payment-data               { padding:1em 0;    }\n    .payment-data table         { width:100%;       }\n    .payment-data th,\n    .payment-data td            { line-height:1em; padding:5pt 8pt 5pt; border:1px solid #DCDCDC; }\n    .payment-data thead th      { background:#FAFAFA; }\n    .payment-data th            { font-weight:bold; white-space:nowrap; }\n    .payment-data .bottomleft   { border-color:white; border-top:inherit; border-right:inherit; }\n    .payment-data span.tax      { display:block; white-space:nowrap; }\n    .terms, .notes              { padding:9pt 0 0; font-size:7pt; line-height:9pt; }\n\n    .section                    { margin-bottom: 1em; }\n    .logo                       { text-align: right; }\n  </style>\n\n  <style type=\"text/css\">\n    /* CSS code for printing */\n    @media print {\n      body           { margin:auto; }\n      .section       { page-break-inside:avoid; }\n      div#sfWebDebug { display:none; }\n    }\n  </style>\n</head>\n<body>\n\n  {% if settings.company_logo %}\n    <div class=\"logo\">\n      <img src=\"{{ settings.company_logo }}\" alt=\"{{ settings.company_name }}\" />\n    </div>\n  {% endif %}\n\n  <div class=\"h2\">\n    <h2>Estimate #{{estimate}}</h2>\n  </div>\n\n  <div class=\"section\">\n    <div class=\"company-data\">\n      <ul>\n        <li>Company: {{settings.company_name}}</li>\n        <li>Address: {{settings.company_address|format}}</li>\n        <li>Phone: {{settings.company_phone}}</li>\n        <li>Fax: {{settings.company_fax}}</li>\n        <li>Email: {{settings.company_email}}</li>\n        <li>Web: {{settings.company_url}}</li>\n      </ul>\n    </div>\n  </div>\n\n  <div class=\"section\">\n    <h3>Client info</h3>\n\n    <div class=\"customer-data\">\n      <table cellspacing=\"0\" cellpadding=\"0\" width=\"100%\">\n        <tr>\n          <td>\n            <span class=\"left\">\n              <label>Customer:</label>\n              {{estimate.customer_name}}\n            </span>\n          </td>\n          <td>\n            <span class=\"right\">\n              <label>Customer identification:</label>\n              {{estimate.customer_identification}}\n            </span>\n          </td>\n        </tr>\n        <tr>\n          <td>\n            <span class=\"left\">\n              <label>Contact person:</label>\n              {{estimate.contact_person}}\n            </span>\n          </td>\n          <td>\n            <span class=\"right\">\n              <label>Email:</label>\n              {{estimate.customer_email}}\n            </span>\n          </td>\n        </tr>\n        <tr>\n          <td>\n            <span class=\"left\">\n              <label>Invoicing address:</label>\n              {{estimate.invoicing_address|format}}\n            </span>\n          </td>\n          <td>\n            <span class=\"right\">\n              <label>Shipping address:</label>\n              {{estimate.shipping_address|format}}\n            </span>\n          </td>\n        </tr>\n      </table>\n    </div>\n  </div>\n\n  <div class=\"section\">\n    <h3>Payment details</h3>\n\n    <div class=\"payment-data\">\n      <table>\n        <thead>\n          <tr>\n            <th>Description</th>\n            <th class=\"right\">Unit Cost</th>\n            <th class=\"right\">Qty</th>\n            <th class=\"right\">Taxes</th>\n            {# show discounts only if there is some discount #}\n            {% if estimate.discount_amount %}\n            <th class=\"right\">Discount</th>\n            {% endif %}\n            <th class=\"right\">Price</th>\n          </tr>\n        </thead>\n        <tbody>\n          {% for item in estimate.Items %}\n            <tr>\n              <td>\n                {{item.description}}\n              </td>\n              <td class=\"right\">{{item.unitary_cost|currency}}</td>\n              <td class=\"right\">{{item.quantity}}</td>\n              <td class=\"right\">\n                {% for tax in item.Taxes %}\n                  <span class=\"tax\">{{tax.name}}</span>\n                {% endfor %}\n              </td>\n              {% if estimate.discount_amount %}\n              <td class=\"right\">{{item.discount_amount|currency}}</td>\n              {% endif %}\n              <td class=\"right\">{{item.gross_amount|currency}}</td>\n            </tr>\n          {% endfor %}\n        </tbody>\n        <tfoot>\n          <tr>\n            <td class=\"bottomleft\" colspan=\"{% if estimate.discount_amount %}4{% else %}3{% endif %}\"></td>\n            <th class=\"right\">Base</th>\n            <td class=\"right\">{{estimate.base_amount|currency}}</td>\n          </tr>\n          {% if estimate.discount_amount %}\n          <tr>\n            <td class=\"bottomleft\" colspan=\"{% if estimate.discount_amount %}4{% else %}3{% endif %}\"></td>\n            <th class=\"right\">Discount</th>\n            <td class=\"td_global_discount right\">{{estimate.discount_amount|currency}}</td>\n          </tr>\n          {% endif %}\n          <tr>\n            <td class=\"bottomleft\" colspan=\"{% if estimate.discount_amount %}4{% else %}3{% endif %}\"></td>\n            <th class=\"right\">Subtotal</th>\n            <td class=\"td_subtotal right\">{{estimate.net_amount|currency}}</td>\n          </tr>\n          <tr>\n            <td class=\"bottomleft\" colspan=\"{% if estimate.discount_amount %}4{% else %}3{% endif %}\"></td>\n            <th class=\"right\">Taxes</th>\n            <td class=\"td_total_taxes right\">{{estimate.tax_amount|currency}}</td>\n          </tr>\n          <tr class=\"strong\">\n            <td class=\"bottomleft\" colspan=\"{% if estimate.discount_amount %}4{% else %}3{% endif %}\"></td>\n            <th class=\"right\">Total</th>\n            <td class=\"td_total right\">{{estimate.gross_amount|currency}}</td>\n          </tr>\n        </tfoot>\n      </table>\n    </div>\n  </div>\n\n  <div class=\"section\">\n    <h3>Terms & conditions</h3>\n    <div class=\"terms\">\n      {{estimate.terms|format}}\n    </div>\n  </div>\n</body>\n</html>\n','Estimate','2017-06-22 15:55:28','2017-06-22 15:55:28','estimate-template');
/*!40000 ALTER TABLE `template` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2017-07-19 12:57:15
