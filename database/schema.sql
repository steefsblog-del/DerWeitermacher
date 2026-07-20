-- RSA 21 Baustellenmanagement - Datenbankschema
-- MariaDB 10.3+ / MySQL 8.0+

CREATE TABLE IF NOT EXISTS `users` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `username` VARCHAR(255) UNIQUE NOT NULL,
  `email` VARCHAR(255) UNIQUE NOT NULL,
  `firstname` VARCHAR(100),
  `lastname` VARCHAR(100),
  `company` VARCHAR(255),
  `password_hash` VARCHAR(255) NOT NULL,
  `role` ENUM('admin', 'user') DEFAULT 'user',
  `status` ENUM('active', 'inactive', 'suspended') DEFAULT 'active',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_email` (`email`),
  INDEX `idx_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `projects` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL,
  `project_name` VARCHAR(255) NOT NULL,
  `description` TEXT,
  `location` VARCHAR(255),
  `street` VARCHAR(255),
  `zip_code` VARCHAR(10),
  `city` VARCHAR(100),
  `start_date` DATE,
  `end_date` DATE,
  `status` ENUM('draft', 'active', 'completed', 'archived') DEFAULT 'draft',
  `template_used` VARCHAR(100),
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `traffic_signs` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `sign_code` VARCHAR(50) UNIQUE NOT NULL,
  `category` VARCHAR(100),
  `name` VARCHAR(255) NOT NULL,
  `description` TEXT,
  `width` INT DEFAULT 600,
  `height` INT DEFAULT 600,
  `color` VARCHAR(50),
  `svg_path` LONGTEXT,
  `active` BOOLEAN DEFAULT TRUE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX `idx_category` (`category`),
  INDEX `idx_active` (`active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `placed_signs` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `project_id` INT NOT NULL,
  `sign_id` INT NOT NULL,
  `x_position` DECIMAL(10, 2),
  `y_position` DECIMAL(10, 2),
  `width` INT DEFAULT 600,
  `height` INT DEFAULT 600,
  `rotation` INT DEFAULT 0,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`project_id`) REFERENCES `projects`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`sign_id`) REFERENCES `traffic_signs`(`id`),
  INDEX `idx_project_id` (`project_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `validation_rules` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `rule_code` VARCHAR(100) UNIQUE NOT NULL,
  `rule_name` VARCHAR(255),
  `description` TEXT,
  `severity` ENUM('error', 'warning', 'info') DEFAULT 'warning',
  `rule_json` JSON,
  `active` BOOLEAN DEFAULT TRUE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX `idx_active` (`active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `project_versions` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `project_id` INT NOT NULL,
  `version_number` INT,
  `data_snapshot` LONGTEXT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`project_id`) REFERENCES `projects`(`id`) ON DELETE CASCADE,
  INDEX `idx_project_id` (`project_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `audit_logs` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT,
  `action` VARCHAR(100),
  `entity_type` VARCHAR(50),
  `entity_id` INT,
  `old_values` JSON,
  `new_values` JSON,
  `ip_address` VARCHAR(45),
  `user_agent` TEXT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Standard Validierungsregeln einfügen
INSERT IGNORE INTO `validation_rules` (`rule_code`, `rule_name`, `description`, `severity`, `active`) VALUES
('minimum_distance', 'Mindestabstand zur Gefahrenstelle', 'Prüft ob der Mindestabstand von 150m eingehalten wird', 'error', TRUE),
('mandatory_signs', 'Pflichtzeichen vorhanden', 'Prüft ob alle erforderlichen Verkehrszeichen vorhanden sind', 'error', TRUE),
('sign_size', 'Zeichengröße korrekt', 'Prüft ob die Zeichen die richtige Größe haben', 'warning', TRUE),
('no_overlap', 'Keine Überlagerung', 'Prüft ob Zeichen sich überschneiden', 'warning', TRUE);

-- Standard Verkehrszeichen einfügen
INSERT IGNORE INTO `traffic_signs` (`sign_code`, `category`, `name`, `description`, `width`, `height`, `active`) VALUES
('D1', 'warning', 'Umleitungsschild', 'Allgemeines Umleitungsschild', 600, 600, TRUE),
('D2', 'warning', 'Baustelle', 'Baustellen-Warnschild', 600, 600, TRUE),
('D3', 'warning', 'Behinderung', 'Verkehrsbehinderungswarnschild', 600, 600, TRUE),
('Z1', 'mandatory', 'Gebot Vorsicht', 'Gebotstafel Vorsicht', 420, 420, TRUE),
('Z2', 'mandatory', 'Gebot Richtung', 'Gebotstafel Richtung', 420, 420, TRUE),
('Z3', 'mandatory', 'Gebot Geschwindigkeit', 'Gebotstafel Geschwindigkeit', 420, 420, TRUE),
('Z4', 'mandatory', 'Gebot Sicherheit', 'Gebotstafel Sicherheit', 420, 420, TRUE),
('R1', 'diversion', 'Umleitungsweg rechts', 'Weist Umleitung nach rechts', 600, 600, TRUE),
('R2', 'diversion', 'Umleitungsweg links', 'Weist Umleitung nach links', 600, 600, TRUE),
('R3', 'diversion', 'Umleitungsweg geradeaus', 'Weist Umleitung geradeaus', 600, 600, TRUE);
