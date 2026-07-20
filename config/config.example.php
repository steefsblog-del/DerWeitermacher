<?php
/**
 * RSA 21 Baustellenmanagement - Konfigurationsdatei
 */

// Datenbank-Konfiguration
define('DB_HOST', 'localhost');
define('DB_USER', 'root');
define('DB_PASS', '');
define('DB_NAME', 'rsa21_baustellenmanagement');
define('DB_PORT', 3306);

// Anwendung-Einstellungen
define('APP_NAME', 'RSA 21 Baustellenmanagement');
define('APP_VERSION', '1.0.0');
define('APP_URL', 'http://localhost:8000');
define('APP_ENV', 'development'); // development, production

// Dateiupload-Einstellungen
define('UPLOAD_DIR', __DIR__ . '/../public/uploads/');
define('MAX_UPLOAD_SIZE', 50 * 1024 * 1024); // 50MB
define('ALLOWED_EXTENSIONS', ['pdf', 'jpg', 'jpeg', 'png', 'docx', 'xlsx']);

// PDF-Generierung
define('PDF_FONT_DIR', __DIR__ . '/../vendor/mpdf/mpdf/ttfonts/');
define('PDF_TEMP_DIR', __DIR__ . '/../tmp/');

// Session-Einstellungen
define('SESSION_TIMEOUT', 3600); // 1 Stunde
define('SESSION_NAME', 'RSA21_SESSION');

// RSA 21 Standards
define('RSA21_MIN_DISTANCE_TO_HAZARD', 150); // Mindestabstand in Metern
define('RSA21_WARNING_SIGN_HEIGHT', 1050); // mm
define('RSA21_MANDATORY_SIGNS', ['D1', 'D2', 'D3', 'Z1', 'Z2', 'Z3', 'Z4']);

// Error Handling
if (APP_ENV === 'production') {
    error_reporting(0);
    ini_set('display_errors', 0);
} else {
    error_reporting(E_ALL);
    ini_set('display_errors', 1);
}

// Timezone
date_default_timezone_set('Europe/Berlin');
