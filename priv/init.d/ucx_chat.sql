-- MySQL dump 10.13  Distrib 5.1.73, for redhat-linux-gnu (x86_64)
--
-- Host: localhost    Database: ucx_chat_prod
-- ------------------------------------------------------
-- Server version	5.1.73

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
-- Current Database: `ucx_chat_prod`
--

/*!40000 DROP DATABASE IF EXISTS `ucx_chat_prod`*/;

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `ucx_chat_prod` /*!40100 DEFAULT CHARACTER SET utf8 */;

USE `ucx_chat_prod`;

--
-- Table structure for table `accounts`
--

DROP TABLE IF EXISTS `accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accounts` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `language` varchar(255) DEFAULT 'en',
  `desktop_notification_enabled` tinyint(1) NOT NULL DEFAULT '1',
  `desktop_notification_duration` int(11) DEFAULT NULL,
  `unread_alert` tinyint(1) NOT NULL DEFAULT '1',
  `use_emojis` tinyint(1) NOT NULL DEFAULT '1',
  `convert_ascii_emoji` tinyint(1) NOT NULL DEFAULT '1',
  `auto_image_load` tinyint(1) NOT NULL DEFAULT '1',
  `save_mobile_bandwidth` tinyint(1) NOT NULL DEFAULT '1',
  `collapse_media_by_default` tinyint(1) NOT NULL DEFAULT '0',
  `unread_rooms_mode` tinyint(1) NOT NULL DEFAULT '0',
  `hide_user_names` tinyint(1) NOT NULL DEFAULT '0',
  `hide_flex_tab` tinyint(1) NOT NULL DEFAULT '0',
  `hide_avatars` tinyint(1) NOT NULL DEFAULT '0',
  `merge_channels` tinyint(1) DEFAULT NULL,
  `enter_key_behaviour` varchar(255) DEFAULT 'normal',
  `view_mode` int(11) DEFAULT '1',
  `email_notification_mode` varchar(255) DEFAULT 'all',
  `highlights` text,
  `new_room_notification` varchar(255) DEFAULT 'door',
  `new_message_notification` varchar(255) DEFAULT 'chime',
  `chat_mode` tinyint(1) NOT NULL DEFAULT '0',
  `inserted_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accounts`
--

LOCK TABLES `accounts` WRITE;
/*!40000 ALTER TABLE `accounts` DISABLE KEYS */;
INSERT INTO `accounts` VALUES (1,'on',1,NULL,1,1,1,1,1,0,0,0,0,0,NULL,'normal',1,'all','','door','chime',0,'2017-02-28 15:00:24','2017-02-28 15:00:24'),(2,'on',1,NULL,1,1,1,1,1,0,0,0,0,0,NULL,'normal',1,'all','','door','chime',0,'2017-02-28 15:00:24','2017-02-28 15:00:24');
/*!40000 ALTER TABLE `accounts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `channels`
--

DROP TABLE IF EXISTS `channels`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `channels` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `topic` varchar(255) DEFAULT '',
  `type` int(11) NOT NULL DEFAULT '0',
  `read_only` tinyint(1) NOT NULL DEFAULT '0',
  `archived` tinyint(1) NOT NULL DEFAULT '0',
  `blocked` tinyint(1) NOT NULL DEFAULT '0',
  `default` tinyint(1) NOT NULL DEFAULT '0',
  `description` text,
  `user_id` bigint(20) unsigned DEFAULT NULL,
  `inserted_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`),
  KEY `channels_user_id_index` (`user_id`),
  CONSTRAINT `channels_user_id_fkey` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `channels`
--

LOCK TABLES `channels` WRITE;
/*!40000 ALTER TABLE `channels` DISABLE KEYS */;
INSERT INTO `channels` VALUES (1,'general','',0,0,0,0,1,NULL,1,'2017-02-28 15:00:25','2017-02-28 15:00:25');
/*!40000 ALTER TABLE `channels` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `config`
--

DROP TABLE IF EXISTS `config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `config` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `general` text,
  `message` text,
  `layout` text,
  `inserted_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `config`
--

LOCK TABLES `config` WRITE;
/*!40000 ALTER TABLE `config` DISABLE KEYS */;
INSERT INTO `config` VALUES (1,'{\"rooms_slash_commands\":[\"join\",\"archive\",\"kick\",\"lennyface\",\"leave\",\"gimme\",\"create\",\"invite\",\"invite-all-to\",\"invite-all-from\",\"msg\",\"part\",\"unarchive\",\"tableflip\",\"topic\",\"mute\",\"me\",\"open\",\"unflip\",\"shrug\",\"unmute\",\"unhide\"],\"id\":\"82ad8631-01c5-428c-839d-a21b0c573e98\",\"enable_favorite_rooms\":true,\"chat_slash_commands\":[\"lennyface\",\"gimme\",\"msg\",\"tableflip\",\"mute\",\"me\",\"unflip\",\"shrug\",\"unmute\"]}','{\"embed_link_previews\":true,\"hide_user_leave\":false,\"allow_message_staring\":true,\"autolinker_www_urls\":true,\"autolinker_phone\":true,\"disable_embedded_for_users\":\"\",\"embeded_ignore_hosts\":\"localhost, 127.0.0.1, 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16\",\"grouping_period_seconds\":300,\"autolinker_strip_prefix\":false,\"max_allowed_message_size\":5000,\"date_format\":\"LL\",\"allow_message_deleting\":true,\"allow_message_editing\":true,\"block_message_deleting_after\":0,\"block_message_editing_after\":0,\"add_bad_words_to_blacklist\":\"\",\"hide_user_muted\":false,\"show_edited_status\":true,\"time_format\":\"LT\",\"autolinker_email\":true,\"hide_user_removed\":false,\"show_formatting_tips\":true,\"hide_user_join\":false,\"show_deleted_status\":false,\"allow_bad_words_filtering\":false,\"autolinker_tld_urls\":true,\"hide_user_added\":false,\"autolinker_url_regexl\":\"(://|www.).+\",\"autolinker_scheme_urls\":true,\"allow_message_snippeting\":false,\"allow_message_pinning\":true,\"max_channel_size_for_all_message\":0,\"id\":\"28cd3d63-d6c9-4b86-b28d-504822a263bc\"}','{\"user_full_initials_for_avatars\":false,\"merge_private_groups\":true,\"id\":\"5cb0b3e1-a102-4e0f-94a6-93a516282a76\",\"display_roles\":true,\"content_side_nav_footer\":\"<img src=\\\"/images/logo.png\\\" />\",\"content_home_title\":\"Home\",\"content_home_body\":\"Welcome to Ucx Chat <br> Go to APP SETTINGS -> Layout to customize this intro.\",\"body_font_family\":\"-apple-system, BlinkMacSystemFont, Roboto, \'Helvetica Neue\', Arial, sans-serif, \'Apple Color Emoji\', \'Segoe UI\', \'Segoe UI Emoji\', \'Segoe UI Symbol\', \'Meiryo UI\'\"}','2017-02-28 15:00:24','2017-02-28 15:00:24');
/*!40000 ALTER TABLE `config` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `directs`
--

DROP TABLE IF EXISTS `directs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `directs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `users` varchar(255) DEFAULT NULL,
  `user_id` bigint(20) unsigned DEFAULT NULL,
  `channel_id` bigint(20) unsigned DEFAULT NULL,
  `inserted_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`),
  UNIQUE KEY `directs_user_id_users_index` (`user_id`,`users`),
  KEY `directs_channel_id_index` (`channel_id`),
  CONSTRAINT `directs_channel_id_fkey` FOREIGN KEY (`channel_id`) REFERENCES `channels` (`id`) ON DELETE CASCADE,
  CONSTRAINT `directs_user_id_fkey` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `directs`
--

LOCK TABLES `directs` WRITE;
/*!40000 ALTER TABLE `directs` DISABLE KEYS */;
/*!40000 ALTER TABLE `directs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `invitations`
--

DROP TABLE IF EXISTS `invitations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `invitations` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `token` varchar(255) DEFAULT NULL,
  `inserted_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`),
  UNIQUE KEY `invitations_email_index` (`email`),
  KEY `invitations_token_index` (`token`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `invitations`
--

LOCK TABLES `invitations` WRITE;
/*!40000 ALTER TABLE `invitations` DISABLE KEYS */;
/*!40000 ALTER TABLE `invitations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mentions`
--

DROP TABLE IF EXISTS `mentions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mentions` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `unread` tinyint(1) DEFAULT '1',
  `all` tinyint(1) DEFAULT '1',
  `name` varchar(255) DEFAULT NULL,
  `user_id` bigint(20) unsigned DEFAULT NULL,
  `message_id` bigint(20) unsigned DEFAULT NULL,
  `channel_id` bigint(20) unsigned DEFAULT NULL,
  `inserted_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`),
  KEY `mentions_user_id_index` (`user_id`),
  KEY `mentions_message_id_index` (`message_id`),
  KEY `mentions_channel_id_index` (`channel_id`),
  CONSTRAINT `mentions_channel_id_fkey` FOREIGN KEY (`channel_id`) REFERENCES `channels` (`id`) ON DELETE SET NULL,
  CONSTRAINT `mentions_message_id_fkey` FOREIGN KEY (`message_id`) REFERENCES `messages` (`id`) ON DELETE SET NULL,
  CONSTRAINT `mentions_user_id_fkey` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mentions`
--

LOCK TABLES `mentions` WRITE;
/*!40000 ALTER TABLE `mentions` DISABLE KEYS */;
/*!40000 ALTER TABLE `mentions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `messages`
--

DROP TABLE IF EXISTS `messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `messages` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `body` text,
  `type` varchar(2) DEFAULT '',
  `edited_id` bigint(20) unsigned DEFAULT NULL,
  `sequential` tinyint(1) NOT NULL DEFAULT '0',
  `system` tinyint(1) NOT NULL DEFAULT '0',
  `user_id` bigint(20) unsigned DEFAULT NULL,
  `channel_id` bigint(20) unsigned DEFAULT NULL,
  `expire_at` datetime DEFAULT NULL,
  `timestamp` varchar(255) DEFAULT NULL,
  `inserted_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`),
  KEY `messages_timestamp_index` (`timestamp`),
  KEY `messages_user_id_index` (`user_id`),
  KEY `messages_channel_id_index` (`channel_id`),
  KEY `messages_edited_id_index` (`edited_id`),
  CONSTRAINT `messages_channel_id_fkey` FOREIGN KEY (`channel_id`) REFERENCES `channels` (`id`) ON DELETE CASCADE,
  CONSTRAINT `messages_edited_id_fkey` FOREIGN KEY (`edited_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `messages_user_id_fkey` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `messages`
--

LOCK TABLES `messages` WRITE;
/*!40000 ALTER TABLE `messages` DISABLE KEYS */;
/*!40000 ALTER TABLE `messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `muted`
--

DROP TABLE IF EXISTS `muted`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `muted` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned DEFAULT NULL,
  `channel_id` bigint(20) unsigned DEFAULT NULL,
  `inserted_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`),
  UNIQUE KEY `muted_user_id_channel_id_index` (`user_id`,`channel_id`),
  KEY `muted_channel_id_fkey` (`channel_id`),
  CONSTRAINT `muted_channel_id_fkey` FOREIGN KEY (`channel_id`) REFERENCES `channels` (`id`) ON DELETE CASCADE,
  CONSTRAINT `muted_user_id_fkey` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `muted`
--

LOCK TABLES `muted` WRITE;
/*!40000 ALTER TABLE `muted` DISABLE KEYS */;
/*!40000 ALTER TABLE `muted` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pinned_messages`
--

DROP TABLE IF EXISTS `pinned_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pinned_messages` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `message_id` bigint(20) unsigned DEFAULT NULL,
  `channel_id` bigint(20) unsigned DEFAULT NULL,
  `inserted_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`),
  KEY `pinned_messages_message_id_index` (`message_id`),
  KEY `pinned_messages_channel_id_index` (`channel_id`),
  CONSTRAINT `pinned_messages_channel_id_fkey` FOREIGN KEY (`channel_id`) REFERENCES `channels` (`id`) ON DELETE CASCADE,
  CONSTRAINT `pinned_messages_message_id_fkey` FOREIGN KEY (`message_id`) REFERENCES `messages` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pinned_messages`
--

LOCK TABLES `pinned_messages` WRITE;
/*!40000 ALTER TABLE `pinned_messages` DISABLE KEYS */;
/*!40000 ALTER TABLE `pinned_messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `roles` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT '',
  `scope` varchar(255) DEFAULT 'global',
  `description` varchar(255) DEFAULT NULL,
  `inserted_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`,`name`),
  UNIQUE KEY `id` (`id`),
  UNIQUE KEY `roles_name_index` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES (1,'admin','global',NULL,'2017-02-28 15:00:24','2017-02-28 15:00:24'),(2,'moderator','rooms',NULL,'2017-02-28 15:00:24','2017-02-28 15:00:24'),(3,'owner','rooms',NULL,'2017-02-28 15:00:24','2017-02-28 15:00:24'),(4,'user','global',NULL,'2017-02-28 15:00:24','2017-02-28 15:00:24'),(5,'bot','global',NULL,'2017-02-28 15:00:24','2017-02-28 15:00:24'),(6,'guest','global',NULL,'2017-02-28 15:00:24','2017-02-28 15:00:24');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `schema_migrations`
--

DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schema_migrations` (
  `version` bigint(20) NOT NULL DEFAULT '0',
  `inserted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `schema_migrations`
--

LOCK TABLES `schema_migrations` WRITE;
/*!40000 ALTER TABLE `schema_migrations` DISABLE KEYS */;
INSERT INTO `schema_migrations` VALUES (20170209174603,'2017-02-28 15:00:23'),(20170209184604,'2017-02-28 15:00:23'),(20170209184605,'2017-02-28 15:00:23'),(20170209195951,'2017-02-28 15:00:23'),(20170209200255,'2017-02-28 15:00:23'),(20170212042803,'2017-02-28 15:00:23'),(20170213030927,'2017-02-28 15:00:23'),(20170217044247,'2017-02-28 15:00:23'),(20170217224533,'2017-02-28 15:00:23'),(20170218015658,'2017-02-28 15:00:23'),(20170219202134,'2017-02-28 15:00:23'),(20170223070609,'2017-02-28 15:00:23'),(20170226175259,'2017-02-28 15:00:23'),(20170227001745,'2017-02-28 15:00:23'),(20170227011136,'2017-02-28 15:00:23');
/*!40000 ALTER TABLE `schema_migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stared_messages`
--

DROP TABLE IF EXISTS `stared_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stared_messages` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned DEFAULT NULL,
  `message_id` bigint(20) unsigned DEFAULT NULL,
  `channel_id` bigint(20) unsigned DEFAULT NULL,
  `inserted_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`),
  KEY `stared_messages_user_id_index` (`user_id`),
  KEY `stared_messages_message_id_index` (`message_id`),
  KEY `stared_messages_channel_id_index` (`channel_id`),
  CONSTRAINT `stared_messages_channel_id_fkey` FOREIGN KEY (`channel_id`) REFERENCES `channels` (`id`) ON DELETE CASCADE,
  CONSTRAINT `stared_messages_message_id_fkey` FOREIGN KEY (`message_id`) REFERENCES `messages` (`id`) ON DELETE CASCADE,
  CONSTRAINT `stared_messages_user_id_fkey` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stared_messages`
--

LOCK TABLES `stared_messages` WRITE;
/*!40000 ALTER TABLE `stared_messages` DISABLE KEYS */;
/*!40000 ALTER TABLE `stared_messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `subscriptions`
--

DROP TABLE IF EXISTS `subscriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `subscriptions` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `last_read` varchar(255) DEFAULT '',
  `type` int(11) DEFAULT '0',
  `open` tinyint(1) DEFAULT '0',
  `alert` tinyint(1) DEFAULT '0',
  `hidden` tinyint(1) DEFAULT '0',
  `has_unread` tinyint(1) DEFAULT '0',
  `ls` datetime DEFAULT NULL,
  `f` tinyint(1) DEFAULT '0',
  `unread` int(11) DEFAULT '0',
  `current_message` varchar(255) DEFAULT '',
  `channel_id` bigint(20) unsigned DEFAULT NULL,
  `user_id` bigint(20) unsigned DEFAULT NULL,
  `inserted_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`),
  UNIQUE KEY `subscriptions_user_id_channel_id_index` (`user_id`,`channel_id`),
  KEY `subscriptions_channel_id_fkey` (`channel_id`),
  CONSTRAINT `subscriptions_channel_id_fkey` FOREIGN KEY (`channel_id`) REFERENCES `channels` (`id`) ON DELETE CASCADE,
  CONSTRAINT `subscriptions_user_id_fkey` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `subscriptions`
--

LOCK TABLES `subscriptions` WRITE;
/*!40000 ALTER TABLE `subscriptions` DISABLE KEYS */;
INSERT INTO `subscriptions` VALUES (1,'',0,0,0,0,0,NULL,0,0,'',1,2,'2017-02-28 15:00:25','2017-02-28 15:00:25');
/*!40000 ALTER TABLE `subscriptions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `username` varchar(255) DEFAULT NULL,
  `alias` varchar(255) DEFAULT NULL,
  `tz_offset` int(11) DEFAULT NULL,
  `account_id` bigint(20) unsigned DEFAULT NULL,
  `unlock_token` varchar(255) DEFAULT NULL,
  `reset_password_token` varchar(255) DEFAULT NULL,
  `reset_password_sent_at` datetime DEFAULT NULL,
  `failed_attempts` int(11) DEFAULT '0',
  `locked_at` datetime DEFAULT NULL,
  `password_hash` varchar(255) DEFAULT NULL,
  `sign_in_count` int(11) DEFAULT '0',
  `current_sign_in_at` datetime DEFAULT NULL,
  `last_sign_in_at` datetime DEFAULT NULL,
  `current_sign_in_ip` varchar(255) DEFAULT NULL,
  `last_sign_in_ip` varchar(255) DEFAULT NULL,
  `active` tinyint(1) DEFAULT '1',
  `chat_status` varchar(255) DEFAULT NULL,
  `tag_line` varchar(255) DEFAULT '',
  `uri` varchar(255) DEFAULT '',
  `inserted_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `open_id` bigint(20) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`),
  UNIQUE KEY `users_username_index` (`username`),
  UNIQUE KEY `users_alias_index` (`alias`),
  KEY `users_account_id_index` (`account_id`),
  KEY `users_open_id_index` (`open_id`),
  CONSTRAINT `users_account_id_fkey` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE,
  CONSTRAINT `users_open_id_fkey` FOREIGN KEY (`open_id`) REFERENCES `channels` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'Bot','bot@example.com','bot',NULL,NULL,1,NULL,NULL,NULL,0,NULL,'$2b$12$8kCoBSoWhucF9O9CXCXVYezVyTPq5YRHBaPYaFXROizvSihJOTHE2',0,NULL,NULL,NULL,NULL,1,NULL,'','','2017-02-28 15:00:24','2017-02-28 15:00:24',NULL),(2,'Admin','admin@spallen.com','admin',NULL,-4,2,NULL,NULL,NULL,0,NULL,'$2b$12$hkqKG3XrPxDP2XioVIFCgeqkg17u9Ddv0P68v29mLRvZ9iKGUL05e',1,'2017-02-28 15:00:37','2017-02-28 15:00:37','{10, 30, 15, 114}','{10, 30, 15, 114}',1,NULL,'','','2017-02-28 15:00:25','2017-02-28 15:00:37',NULL);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users_roles`
--

DROP TABLE IF EXISTS `users_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users_roles` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `role` varchar(255) NOT NULL,
  `scope` int(11) DEFAULT '0',
  `user_id` bigint(20) unsigned DEFAULT NULL,
  `inserted_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`),
  KEY `users_roles_user_id_index` (`user_id`),
  CONSTRAINT `users_roles_user_id_fkey` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users_roles`
--

LOCK TABLES `users_roles` WRITE;
/*!40000 ALTER TABLE `users_roles` DISABLE KEYS */;
INSERT INTO `users_roles` VALUES (1,'bot',0,1,'2017-02-28 15:00:24','2017-02-28 15:00:24'),(2,'admin',0,2,'2017-02-28 15:00:25','2017-02-28 15:00:25'),(3,'owner',1,1,'2017-02-28 15:00:25','2017-02-28 15:00:25');
/*!40000 ALTER TABLE `users_roles` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2017-02-28 10:08:34
