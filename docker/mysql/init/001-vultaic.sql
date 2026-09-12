CREATE DATABASE IF NOT EXISTS `v_accounts`
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS `mta_toptimes`
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

GRANT ALL PRIVILEGES ON `v_accounts`.* TO 'vultaic'@'%';
GRANT ALL PRIVILEGES ON `mta_toptimes`.* TO 'vultaic'@'%';

USE `v_accounts`;

CREATE TABLE IF NOT EXISTS `vmtasa_accounts` (
  `account_id` INT UNSIGNED NOT NULL,
  `money` BIGINT NOT NULL DEFAULT 0,
  `dm_points` BIGINT NOT NULL DEFAULT 0,
  `os_points` BIGINT NOT NULL DEFAULT 0,
  `dd_points` BIGINT NOT NULL DEFAULT 0,
  `race_points` BIGINT NOT NULL DEFAULT 0,
  `shooter_points` BIGINT NOT NULL DEFAULT 0,
  `hunter_points` BIGINT NOT NULL DEFAULT 0,
  `tdm_points` BIGINT NOT NULL DEFAULT 0,
  `Clan` INT NOT NULL DEFAULT 0,
  `data` LONGTEXT NOT NULL DEFAULT '{}',
  `tuning` LONGTEXT NOT NULL DEFAULT '{}',
  PRIMARY KEY (`account_id`),
  KEY `idx_accounts_clan` (`Clan`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `v_achievements` (
  `account_id` INT UNSIGNED NOT NULL,
  `achievement_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`account_id`, `achievement_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `v_clans` (
  `ClanID` INT UNSIGNED NOT NULL,
  `ClanName` VARCHAR(64) NOT NULL,
  `ClanColor` VARCHAR(16) NOT NULL DEFAULT '#FFFFFF',
  `ClanMembers` LONGTEXT NOT NULL,
  `ClanLeaders` LONGTEXT NOT NULL,
  `data` LONGTEXT NOT NULL,
  PRIMARY KEY (`ClanID`),
  UNIQUE KEY `uq_clan_name` (`ClanName`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `v_clanwars` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `requester_clanid` INT UNSIGNED NOT NULL,
  `challenged_clanid` INT UNSIGNED NOT NULL,
  `settings` LONGTEXT NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
