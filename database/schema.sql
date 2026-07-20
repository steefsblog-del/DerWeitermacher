-- RSA 21 Baustellenmanagement - Komplettes Datenbankschema
CREATE DATABASE IF NOT EXISTS rsa21_baustellenmanagement CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE rsa21_baustellenmanagement;

-- ============================================================
-- BENUTZER UND AUTHENTIFIZIERUNG
-- ============================================================
CREATE TABLE IF NOT EXISTS users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(255) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    firstname VARCHAR(100),
    lastname VARCHAR(100),
    company VARCHAR(255),
    phone VARCHAR(20),
    role ENUM('admin', 'user', 'viewer') DEFAULT 'user',
    status ENUM('active', 'inactive', 'suspended') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login DATETIME,
    INDEX idx_email (email),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- PROJEKTE
-- ============================================================
CREATE TABLE IF NOT EXISTS projects (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    project_name VARCHAR(255) NOT NULL,
    description TEXT,
    location VARCHAR(255),
    lat DECIMAL(10, 8),
    lng DECIMAL(11, 8),
    street VARCHAR(255),
    zip_code VARCHAR(10),
    city VARCHAR(100),
    start_date DATE,
    end_date DATE,
    status ENUM('draft', 'active', 'completed', 'archived') DEFAULT 'draft',
    template_used VARCHAR(100),
    canvas_data LONGTEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- VERKEHRSZEICHEN KATALOG (RSA 21)
-- ============================================================
CREATE TABLE IF NOT EXISTS traffic_signs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    sign_code VARCHAR(50) UNIQUE NOT NULL,
    sign_name VARCHAR(255) NOT NULL,
    description TEXT,
    category ENUM('warning', 'mandatory', 'prohibition', 'information', 'direction') DEFAULT 'information',
    svg_content TEXT,
    width INT DEFAULT 1050,
    height INT DEFAULT 1050,
    rsa21_compliant BOOLEAN DEFAULT TRUE,
    is_mandatory BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_sign_code (sign_code),
    INDEX idx_category (category),
    INDEX idx_mandatory (is_mandatory)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- PLATZIERTE ZEICHEN IM PROJEKT
-- ============================================================
CREATE TABLE IF NOT EXISTS placed_signs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    project_id INT NOT NULL,
    sign_id INT NOT NULL,
    x_position INT,
    y_position INT,
    rotation INT DEFAULT 0,
    scale FLOAT DEFAULT 1.0,
    custom_text VARCHAR(255),
    is_mandatory BOOLEAN DEFAULT FALSE,
    validation_status ENUM('valid', 'warning', 'error') DEFAULT 'valid',
    validation_message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
    FOREIGN KEY (sign_id) REFERENCES traffic_signs(id) ON DELETE RESTRICT,
    INDEX idx_project_id (project_id),
    INDEX idx_sign_id (sign_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- VORLAGEN
-- ============================================================
CREATE TABLE IF NOT EXISTS templates (
    id INT PRIMARY KEY AUTO_INCREMENT,
    template_name VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100),
    configuration JSON,
    preview_image LONGBLOB,
    is_system_template BOOLEAN DEFAULT TRUE,
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usage_count INT DEFAULT 0,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_category (category),
    INDEX idx_system_template (is_system_template)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- BAUSTELLENDOKUMENTATION
-- ============================================================
CREATE TABLE IF NOT EXISTS site_documentation (
    id INT PRIMARY KEY AUTO_INCREMENT,
    project_id INT NOT NULL,
    doc_type ENUM('traffic_plan', 'diversion_plan', 'signage_plan', 'control_protocol', 'inspection_protocol', 'traffic_order_request') NOT NULL,
    content LONGTEXT,
    generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    file_path VARCHAR(500),
    file_size INT,
    approved_by INT,
    approved_at DATETIME,
    revision_number INT DEFAULT 1,
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
    FOREIGN KEY (approved_by) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_project_id (project_id),
    INDEX idx_doc_type (doc_type),
    INDEX idx_revision (revision_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- VALIDIERUNGSREGELN
-- ============================================================
CREATE TABLE IF NOT EXISTS validation_rules (
    id INT PRIMARY KEY AUTO_INCREMENT,
    rule_name VARCHAR(255) NOT NULL,
    description TEXT,
    rule_code VARCHAR(100) UNIQUE NOT NULL,
    severity ENUM('error', 'warning', 'info') DEFAULT 'warning',
    rule_json JSON,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_rule_code (rule_code),
    INDEX idx_active (active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- VALIDIERUNGSPROTOKOLLE
-- ============================================================
CREATE TABLE IF NOT EXISTS validation_protocols (
    id INT PRIMARY KEY AUTO_INCREMENT,
    project_id INT NOT NULL,
    validation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_checks INT,
    passed_checks INT,
    failed_checks INT,
    warnings_count INT,
    validation_result ENUM('passed', 'warnings', 'failed') DEFAULT 'passed',
    protocol_details JSON,
    validated_by INT,
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
    FOREIGN KEY (validated_by) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_project_id (project_id),
    INDEX idx_validation_date (validation_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- PROJEKTVERSIONEN (VERSIONSKONTROLLE)
-- ============================================================
CREATE TABLE IF NOT EXISTS project_versions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    project_id INT NOT NULL,
    version_number INT,
    snapshot_data JSON,
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    change_description VARCHAR(500),
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_project_id (project_id),
    UNIQUE KEY unique_version (project_id, version_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- AUDIT LOG
-- ============================================================
CREATE TABLE IF NOT EXISTS audit_log (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    action VARCHAR(255),
    table_name VARCHAR(100),
    record_id INT,
    old_values JSON,
    new_values JSON,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_user_id (user_id),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- STANDARD VERKEHRSZEICHEN EINFÜGEN (RSA 21)
-- ============================================================

-- WARNZEICHEN
INSERT IGNORE INTO traffic_signs (sign_code, sign_name, description, category, width, height, rsa21_compliant, is_mandatory) VALUES
('W1', 'Baustelle', 'Warnung vor Baustelle', 'warning', 1050, 1050, TRUE, TRUE),
('W2', 'Fahrbahnerneuerung', 'Warnung vor Fahrbahnerneuerung', 'warning', 1050, 1050, TRUE, FALSE),
('W3', 'Straßenarbeiten', 'Warnung vor Straßenarbeiten', 'warning', 1050, 1050, TRUE, FALSE),
('W4', 'Fahrzeuge räumen die Fahrbahn', 'Fahrzeuge räumen Fahrbahn', 'warning', 1050, 1050, TRUE, FALSE);

-- GEBOTZEICHEN
INSERT IGNORE INTO traffic_signs (sign_code, sign_name, description, category, width, height, rsa21_compliant, is_mandatory) VALUES
('D1', 'Gebot: Rechts vorbei', 'Gebot rechts vorbeizufahren', 'mandatory', 900, 900, TRUE, TRUE),
('D2', 'Gebot: Links vorbei', 'Gebot links vorbeizufahren', 'mandatory', 900, 900, TRUE, TRUE),
('D3', 'Gebot: Rechts oder Links vorbei', 'Gebot rechts oder links vorbei', 'mandatory', 900, 900, TRUE, FALSE);

-- UMLEITUNGSZEICHEN
INSERT IGNORE INTO traffic_signs (sign_code, sign_name, description, category, width, height, rsa21_compliant, is_mandatory) VALUES
('U1', 'Umleitung nach rechts', 'Umleitung nach rechts', 'direction', 1050, 1050, TRUE, FALSE),
('U2', 'Umleitung nach links', 'Umleitung nach links', 'direction', 1050, 1050, TRUE, FALSE),
('U3', 'Umleitung geradeaus', 'Umleitung geradeaus', 'direction', 1050, 1050, TRUE, FALSE);

-- INFORMATIONSZEICHEN
INSERT IGNORE INTO traffic_signs (sign_code, sign_name, description, category, width, height, rsa21_compliant, is_mandatory) VALUES
('I1', 'Umleitungsstrecke', 'Kennzeichnung Umleitungsstrecke', 'information', 900, 900, TRUE, FALSE),
('I2', 'Fußgänger', 'Warnung vor Fußgängern', 'information', 1050, 1050, TRUE, FALSE),
('I3', 'Fahrzeuge', 'Hinweis auf Fahrzeugverkehr', 'information', 1050, 1050, TRUE, FALSE);

-- ============================================================
-- STANDARD VALIDIERUNGSREGELN EINFÜGEN
-- ============================================================
INSERT IGNORE INTO validation_rules (rule_name, rule_code, description, severity, rule_json, active) VALUES
('Mindestabstand zur Baustelle', 'min_distance', 'Verkehrszeichen müssen mindestens 150m vor der Baustelle angebracht sein', 'error', '{"min_distance_m": 150}', TRUE),
('Pflichtzeichen vorhanden', 'mandatory_signs', 'Alle erforderlichen Pflichtzeichen nach RSA 21 müssen vorhanden sein', 'error', '{"required_signs": ["W1", "D1", "D2"]}', TRUE),
('Zeichengröße korrekt', 'sign_size', 'Warnzeichen müssen mind. 1050mm x 1050mm groß sein', 'warning', '{"min_width_mm": 1050, "min_height_mm": 1050}', TRUE),
('Keine Überlagerung', 'no_overlap', 'Verkehrszeichen dürfen sich nicht überschneiden', 'warning', '{"min_spacing_px": 50}', TRUE),
('Sichtbarkeit gewährleistet', 'visibility', 'Ausreichende Sichtbarkeit muss gewährleistet sein', 'warning', '{"min_viewing_distance_m": 300}', TRUE);

-- ============================================================
-- STANDARD VORLAGEN EINFÜGEN
-- ============================================================
INSERT IGNORE INTO templates (template_name, category, description, is_system_template, configuration) VALUES
('Standardbaustelle klein', 'small_construction', 'Vorlage für kleine Baustellen (< 50m)', TRUE, '{"canvas_width": 1024, "canvas_height": 768, "signs": ["W1", "D1", "D2"], "difficulty": "easy"}'),
('Standardbaustelle groß', 'large_construction', 'Vorlage für große Baustellen (> 50m)', TRUE, '{"canvas_width": 1280, "canvas_height": 1024, "signs": ["W1", "W2", "D1", "D2", "D3"], "difficulty": "medium"}'),
('Fahrbahnerneuerung', 'road_renewal', 'Vorlage für Fahrbahnerneuerung', TRUE, '{"canvas_width": 1024, "canvas_height": 768, "signs": ["W1", "W2", "D1", "D2"], "difficulty": "medium"}'),
('Nachtbaustelle', 'night_construction', 'Vorlage für Nachtbaustellen mit Beleuchtung', TRUE, '{"canvas_width": 1024, "canvas_height": 768, "signs": ["W1", "D1", "D2", "I2"], "lighting_required": true, "difficulty": "hard"}'),
('Umleitungsstrecke', 'diversion_route', 'Vorlage für Umleitungsstrecken', TRUE, '{"canvas_width": 1280, "canvas_height": 1024, "signs": ["U1", "U2", "U3", "I1"], "difficulty": "hard"}');
