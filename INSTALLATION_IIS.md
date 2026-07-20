# RSA 21 Baustellenmanagement - IIS Installation Guide

## Windows Server mit IIS Kompatibilität

Diese Anleitung beschreibt die Installation und Konfiguration der RSA 21 Baustellenmanagement-Anwendung auf einem Windows Server mit Internet Information Services (IIS).

---

## 📋 Voraussetzungen

### System-Anforderungen:
- Windows Server 2016 oder höher
- Windows Server 2019 oder 2022 empfohlen
- Administrator-Zugriff
- Mindestens 2 GB RAM
- 5 GB freier Speicherplatz

### Erforderliche Komponenten:
- **IIS 10.0+** mit URL Rewrite und PHP Manager
- **PHP 7.4+** (PHP 8.1 empfohlen)
- **MariaDB 10.3+** oder **MySQL 8.0+**
- **Composer** (für Abhängigkeitsverwaltung)
- **Git** (optional, zum Klonen des Repositories)

---

## 🔧 Schritt-für-Schritt Anleitung

### 1️⃣ IIS Installation und Konfiguration

#### A) IIS installieren (Windows Server mit Desktop Experience)

```powershell
# Als Administrator ausführen
# Öffnen Sie "Server Manager" und gehen Sie zu "Add Roles and Features"

# Oder über PowerShell:
Add-WindowsFeature Web-Server
Add-WindowsFeature Web-CGI
Add-WindowsFeature Web-Url-Rewrite
Add-WindowsFeature Web-Mgmt-Console
```

#### B) Erforderliche IIS-Module aktivieren

```powershell
# PowerShell als Administrator ausführen
Add-WindowsFeature Web-Static-Content
Add-WindowsFeature Web-Default-Doc
Add-WindowsFeature Web-Dir-Browsing
Add-WindowsFeature Web-Http-Errors
Add-WindowsFeature Web-Http-Logging
Add-WindowsFeature Web-Common-Http
Add-WindowsFeature Web-Performance
Add-WindowsFeature Web-Stat-Compression
Add-WindowsFeature Web-Dyn-Compression
Add-WindowsFeature Web-Security
Add-WindowsFeature Web-Filtering
```

---

### 2️⃣ PHP Installation

#### A) PHP 8.1 (empfohlen) herunterladen

1. Laden Sie PHP Non-Thread-Safe herunter von: https://windows.php.net/download/
2. Empfohlen: **PHP 8.1 Non-Thread Safe (x64)**
3. Entpacken Sie die Datei nach: `C:\php\php-8.1`

#### B) PHP als IIS CGI konfigurieren

1. Öffnen Sie **IIS Manager** (inetmgr)
2. Gehen Sie zu **Default Web Site** → **Handler Mappings**
3. Klicken Sie auf **Add Module Mapping**:
   - **Request path**: `*.php`
   - **Module**: `FastCgiModule`
   - **Executable**: `C:\php\php-8.1\php-cgi.exe`
   - **Name**: `PHP via FastCGI`

#### C) php.ini konfigurieren

```powershell
# Kopieren Sie die Konfigurationsdatei
Copy-Item C:\php\php-8.1\php.ini-production C:\php\php-8.1\php.ini

# Öffnen Sie die Datei mit Editor und passen Sie an:
# C:\php\php-8.1\php.ini
```

**Wichtige Einstellungen in php.ini:**

```ini
; Speicherplatz und Upload
memory_limit = 256M
post_max_size = 100M
upload_max_filesize = 100M

; Zeitzonen
date.timezone = Europe/Berlin

; Session-Pfad (muss beschreibbar sein)
session.save_path = "C:\php\session"

; Erweiterungen aktivieren (für MariaDB/MySQL)
extension=pdo_mysql
extension=mysqli
extension=json
extension=mbstring
extension=curl
extension=gd

; FastCGI-Einstellungen
fastcgi.logging = 0
fastcgi.impersonate = 1
```

**Session-Verzeichnis erstellen:**

```powershell
New-Item -ItemType Directory -Path "C:\php\session" -Force
# Berechtigungen setzen (IUSR und IIS_IUSRS müssen Schreibzugriff haben)
icacls "C:\php\session" /grant "IIS_IUSRS:(OI)(CI)M" /T
```

---

### 3️⃣ MariaDB/MySQL Installation

#### A) MariaDB herunterladen und installieren

1. Laden Sie MariaDB herunter: https://mariadb.org/download/
2. Version 10.6 oder höher empfohlen
3. Installieren Sie mit:
   - **TCP Port**: 3306
   - **Zeichensatz**: utf8mb4
   - **Authentifizierung**: mysql_native_password (für PHP-Kompatibilität)

#### B) Datenbank erstellen

```bash
# Windows CMD als Administrator
cd "C:\Program Files\MariaDB 10.x\bin"
mysql -u root -p
```

```sql
CREATE DATABASE `rsa21_baustellenmanagement` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'rsa21_user'@'localhost' IDENTIFIED BY 'SecurePassword123!';
GRANT ALL PRIVILEGES ON `rsa21_baustellenmanagement`.* TO 'rsa21_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

#### C) Datenbankschema importieren

```bash
cd "C:\Program Files\MariaDB 10.x\bin"
mysql -u rsa21_user -p rsa21_baustellenmanagement < C:\wwwroot\DerWeitermacher\database\schema.sql
```

---

### 4️⃣ Projekt-Dateien bereitstellen

#### A) Repository klonen oder hochladen

```powershell
# PowerShell als Administrator
cd C:\inetpub\wwwroot
git clone https://github.com/steefsblog-del/DerWeitermacher.git
cd DerWeitermacher
```

ODER: Laden Sie die Dateien manuell in `C:\inetpub\wwwroot\DerWeitermacher` hoch

#### B) Erforderliche Verzeichnisse erstellen

```powershell
# Verzeichnisse mit Schreibberechtigung erstellen
New-Item -ItemType Directory -Path "C:\inetpub\wwwroot\DerWeitermacher\public\uploads" -Force
New-Item -ItemType Directory -Path "C:\inetpub\wwwroot\DerWeitermacher\tmp" -Force
New-Item -ItemType Directory -Path "C:\inetpub\wwwroot\DerWeitermacher\logs" -Force

# Berechtigungen setzen
icacls "C:\inetpub\wwwroot\DerWeitermacher\public\uploads" /grant "IIS_IUSRS:(OI)(CI)M" /T
icacls "C:\inetpub\wwwroot\DerWeitermacher\tmp" /grant "IIS_IUSRS:(OI)(CI)M" /T
icacls "C:\inetpub\wwwroot\DerWeitermacher\logs" /grant "IIS_IUSRS:(OI)(CI)M" /T
```

---

### 5️⃣ Composer und Abhängigkeiten

#### A) Composer installieren

1. Laden Sie Composer herunter: https://getcomposer.org/download/
2. Installieren Sie den Windows-Installer
3. Überprüfen Sie die Installation:

```powershell
composer --version
```

#### B) Abhängigkeiten installieren

```powershell
cd C:\inetpub\wwwroot\DerWeitermacher
composer install
```

---

### 6️⃣ IIS Website konfigurieren

#### A) Neue Website erstellen

1. Öffnen Sie **IIS Manager**
2. Rechtsklick auf **Sites** → **Add Website**
3. Konfigurieren Sie:
   - **Site name**: `RSA21Baustellenmanagement`
   - **Physical path**: `C:\inetpub\wwwroot\DerWeitermacher\public`
   - **Host name**: `rsa21.local` (oder Ihre Domain)
   - **IP address**: Alle nicht zugewiesen (oder spezifische IP)
   - **Port**: 80 (oder 443 für HTTPS)
   - **Binding**: `http://rsa21.local` oder `https://rsa21.local`

#### B) Application Pool konfigurieren

1. Gehen Sie zu **Application Pools**
2. Erstellen Sie neuen Pool:
   - **Name**: `RSA21_Pool`
   - **.NET CLR version**: Kein verwalteter Code
   - **Managed pipeline mode**: Integrated
   - **Identity**: ApplicationPoolIdentity

3. Bearbeiten Sie **Advanced Settings**:
   - **Enable 32-Bit Applications**: False (für x64 PHP)
   - **Maximum Worker Processes**: 1 (oder CPU-Kernen)

#### C) PHP Handler für Website konfigurieren

1. Wählen Sie die Website aus
2. Gehen Sie zu **Handler Mappings**
3. Überprüfen Sie, dass PHP-Mapping vorhanden ist
4. Falls nicht, fügen Sie hinzu (siehe Schritt 2B)

---

### 7️⃣ URL Rewriting konfigurieren

#### A) Web.config erstellen

Erstellen Sie `C:\inetpub\wwwroot\DerWeitermacher\public\web.config`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <system.webServer>
        <!-- PHP Handler -->
        <handlers>
            <add name="PHP-FastCGI" path="*.php" verb="GET,HEAD,POST,DEBUG,PUT,DELETE" modules="FastCgiModule" scriptProcessor="C:\php\php-8.1\php-cgi.exe" resourceType="File" />
        </handlers>

        <!-- Rewrite Rules -->
        <rewrite>
            <rules>
                <rule name="Imported Rule 1" stopProcessing="true">
                    <match url="^(.*)$" ignoreCase="false" />
                    <conditions logicalGrouping="MatchAll">
                        <add input="{REQUEST_FILENAME}" matchType="IsDirectory" ignoreCase="false" negate="true" />
                        <add input="{REQUEST_FILENAME}" matchType="IsFile" ignoreCase="false" negate="true" />
                        <add input="{REQUEST_FILENAME}" matchType="IsSymLink" ignoreCase="false" negate="true" />
                    </conditions>
                    <action type="Rewrite" url="/index.php" />
                </rule>
            </rules>
        </rewrite>

        <!-- Kompression -->
        <urlCompression doStaticCompression="true" doDynamicCompression="true" />

        <!-- Statische Dateien -->
        <staticContent>
            <mimeMap fileExtension=".json" mimeType="application/json" />
            <mimeMap fileExtension=".woff" mimeType="font/woff" />
            <mimeMap fileExtension=".woff2" mimeType="font/woff2" />
        </staticContent>

        <!-- Sicherheit -->
        <security>
            <requestFiltering>
                <fileExtensions>
                    <add fileExtension=".php" allowed="true" />
                </fileExtensions>
            </requestFiltering>
        </security>
    </system.webServer>
</configuration>
```

---

### 8️⃣ Konfiguration vornehmen

#### A) config.php erstellen

```bash
Copy-Item C:\inetpub\wwwroot\DerWeitermacher\config\config.example.php `
           C:\inetpub\wwwroot\DerWeitermacher\config\config.php
```

#### B) config.php bearbeiten

Öffnen Sie `C:\inetpub\wwwroot\DerWeitermacher\config\config.php`:

```php
<?php
// Datenbank-Konfiguration
define('DB_HOST', 'localhost');
define('DB_USER', 'rsa21_user');
define('DB_PASS', 'SecurePassword123!');
define('DB_NAME', 'rsa21_baustellenmanagement');
define('DB_PORT', 3306);

// Anwendung-Einstellungen
define('APP_NAME', 'RSA 21 Baustellenmanagement');
define('APP_VERSION', '1.0.0');
define('APP_URL', 'http://rsa21.local'); // Oder Ihre Domain
define('APP_ENV', 'production');

// Dateiupload-Einstellungen (Windows-Pfade)
define('UPLOAD_DIR', __DIR__ . '/../public/uploads/');
define('MAX_UPLOAD_SIZE', 50 * 1024 * 1024); // 50MB
define('ALLOWED_EXTENSIONS', ['pdf', 'jpg', 'jpeg', 'png', 'docx', 'xlsx']);

// PDF-Generierung
define('PDF_FONT_DIR', __DIR__ . '/../vendor/mpdf/mpdf/ttfonts/');
define('PDF_TEMP_DIR', __DIR__ . '/../tmp/');

// Session-Einstellungen
define('SESSION_TIMEOUT', 3600);
define('SESSION_NAME', 'RSA21_SESSION');

// RSA 21 Standards
define('RSA21_MIN_DISTANCE_TO_HAZARD', 150);
define('RSA21_WARNING_SIGN_HEIGHT', 1050);
define('RSA21_MANDATORY_SIGNS', ['D1', 'D2', 'D3', 'Z1', 'Z2', 'Z3', 'Z4']);

// Error Handling (Production)
error_reporting(0);
ini_set('display_errors', 0);
ini_set('log_errors', 1);
ini_set('error_log', __DIR__ . '/../logs/php_errors.log');

// Timezone
date_default_timezone_set('Europe/Berlin');
```

---

### 9️⃣ Berechtigungen setzen

```powershell
# Alle erforderlichen Berechtigungen
$path = "C:\inetpub\wwwroot\DerWeitermacher"

# Leseberechtigung für alle Dateien
icacls $path /grant "IIS_IUSRS:(OI)(CI)R" /T

# Schreibberechtigung für spezifische Verzeichnisse
icacls "$path\public\uploads" /grant "IIS_IUSRS:(OI)(CI)M" /T
icacls "$path\tmp" /grant "IIS_IUSRS:(OI)(CI)M" /T
icacls "$path\logs" /grant "IIS_IUSRS:(OI)(CI)M" /T

# Konfiguration schützen
icacls "$path\config" /grant "IIS_IUSRS:(OI)(CI)R" /T
```

---

### 🔟 HTTPS konfigurieren (empfohlen)

#### A) SSL-Zertifikat installieren

1. Öffnen Sie **IIS Manager**
2. Wählen Sie den Server aus
3. Gehen Sie zu **Server Certificates**
4. Erstellen oder importieren Sie ein Zertifikat

#### B) Binding für HTTPS hinzufügen

1. Wählen Sie die Website
2. Gehen Sie zu **Edit Bindings**
3. Fügen Sie Binding hinzu:
   - **Type**: https
   - **IP address**: Alle nicht zugewiesen
   - **Port**: 443
   - **SSL Certificate**: Ihr Zertifikat

---

## ✅ Überprüfung und Test

### 1. PHP-Info aufrufen

Erstellen Sie `C:\inetpub\wwwroot\DerWeitermacher\public\phpinfo.php`:

```php
<?php
phpinfo();
?>
```

Öffnen Sie `http://rsa21.local/phpinfo.php`

### 2. Datenbank-Verbindung testen

Erstellen Sie `C:\inetpub\wwwroot\DerWeitermacher\public\test-db.php`:

```php
<?php
require_once __DIR__ . '/../config/config.php';
require_once __DIR__ . '/../src/config/Database.php';

use RSA21\Config\Database;

try {
    $db = Database::getInstance();
    $connection = $db->getConnection();
    echo "✓ Datenbankverbindung erfolgreich!";
} catch (Exception $e) {
    echo "✗ Fehler: " . $e->getMessage();
}
?>
```

Öffnen Sie `http://rsa21.local/test-db.php`

### 3. Anwendung öffnen

Öffnen Sie `http://rsa21.local/` oder `https://rsa21.local/`

---

## 🛠️ Häufige Probleme und Lösungen

### Problem: "Access Denied" beim Hochladen

**Lösung:**
```powershell
icacls "C:\inetpub\wwwroot\DerWeitermacher\public\uploads" /grant "IIS_IUSRS:M" /T
```

### Problem: PHP wird nicht ausgeführt (zeigt Code statt Ausführung)

**Lösung:**
1. Überprüfen Sie Handler Mappings in IIS
2. Stellen Sie sicher, dass FastCGI Module aktiviert ist
3. Überprüfen Sie php-cgi.exe-Pfad

### Problem: "500 Internal Server Error"

**Lösung:**
1. Überprüfen Sie C:\php\php-8.1\php.ini
2. Überprüfen Sie Windows Event Viewer (Application Logs)
3. Überprüfen Sie `logs/php_errors.log`

### Problem: Session funktioniert nicht

**Lösung:**
```powershell
New-Item -ItemType Directory -Path "C:\php\session" -Force
icacls "C:\php\session" /grant "IIS_IUSRS:M" /T
```

---

## 📊 Performance-Optimierung

### IIS-Einstellungen

1. **Application Pool Recycling**
   - Gehen Sie zu **Application Pools** → `RSA21_Pool` → **Recycling**
   - Setzen Sie Recycling auf 1440 Minuten (24 Stunden)

2. **Output Caching**
   - Gehen Sie zu **Output Caching**
   - Aktivieren Sie Caching für statische Dateien

3. **Compression**
   - Gehen Sie zu **Compression**
   - Aktivieren Sie statische und dynamische Kompression

### PHP-Optimierungen

In `php.ini`:

```ini
; Opcache für bessere Performance
opcache.enable=1
opcache.enable_cli=1
opcache.memory_consumption=256
opcache.interned_strings_buffer=16
opcache.max_accelerated_files=10000
opcache.validate_timestamps=0
opcache.revalidate_freq=2
```

---

## 🔒 Sicherheit

### Firewall-Regeln

```powershell
# HTTP erlauben
New-NetFirewallRule -DisplayName "HTTP" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 80

# HTTPS erlauben
New-NetFirewallRule -DisplayName "HTTPS" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 443

# MySQL-Port (nur für lokale Verbindung)
New-NetFirewallRule -DisplayName "MySQL" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 3306 -LocalAddress 127.0.0.1
```

### web.config Sicherheit

Stellen Sie sicher, dass sensitive Dateien geschützt sind:

```xml
<system.webServer>
    <security>
        <requestFiltering>
            <hiddenSegments>
                <add segment="config" />
                <add segment="src" />
                <add segment="vendor" />
                <add segment="database" />
            </hiddenSegments>
            <fileExtensions>
                <add fileExtension=".env" allowed="false" />
                <add fileExtension=".log" allowed="false" />
            </fileExtensions>
        </requestFiltering>
    </security>
</system.webServer>
```

---

## 📝 Zusammenfassung der Befehle

```powershell
# 1. IIS installieren
Add-WindowsFeature Web-Server, Web-CGI, Web-Url-Rewrite, Web-Mgmt-Console

# 2. PHP konfigurieren
# (Manuell über IIS Manager)

# 3. Verzeichnisse erstellen
New-Item -ItemType Directory -Path "C:\inetpub\wwwroot\DerWeitermacher\public\uploads", "C:\inetpub\wwwroot\DerWeitermacher\tmp", "C:\inetpub\wwwroot\DerWeitermacher\logs" -Force

# 4. Berechtigungen setzen
$path = "C:\inetpub\wwwroot\DerWeitermacher"
icacls $path /grant "IIS_IUSRS:(OI)(CI)R" /T
icacls "$path\public\uploads" /grant "IIS_IUSRS:(OI)(CI)M" /T
icacls "$path\tmp" /grant "IIS_IUSRS:(OI)(CI)M" /T
icacls "$path\logs" /grant "IIS_IUSRS:(OI)(CI)M" /T

# 5. Composer Abhängigkeiten
cd C:\inetpub\wwwroot\DerWeitermacher
composer install

# 6. Datenbank vorbereiten
mysql -u root -p < C:\inetpub\wwwroot\DerWeitermacher\database\schema.sql
```

---

## 🎯 Support

Bei Problemen überprüfen Sie:
1. **Windows Event Viewer** - Application Logs
2. **IIS Logs** - `C:\inetpub\logs\LogFiles\`
3. **PHP Error Log** - `C:\inetpub\wwwroot\DerWeitermacher\logs\php_errors.log`
4. **MariaDB Logs** - `C:\Program Files\MariaDB 10.x\data\`

---

**Installationsdatum:** 2026-07-20
**Version:** 1.0.0
**Kompatibilität:** Windows Server 2016+, IIS 10.0+
