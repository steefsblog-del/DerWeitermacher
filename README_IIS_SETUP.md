# IIS Setup - Schnelleinstieg

## 🚀 Schnelle Installation mit PowerShell

### 1. PowerShell Script ausführen

```powershell
# Als Administrator ausführen
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser -Force
.\INSTALLATION_WINDOWS_POWERSHELL.ps1
```

### 2. PHP & MariaDB manuell installieren

- **PHP 8.1**: https://windows.php.net/download/
- **MariaDB**: https://mariadb.org/download/

### 3. Datenbank vorbereiten

```powershell
mysql -u root -p < database\schema.sql
```

### 4. config.php bearbeiten

```powershell
Edit C:\inetpub\wwwroot\DerWeitermacher\config\config.php
```

### 5. Composer Install

```powershell
cd C:\inetpub\wwwroot\DerWeitermacher
composer install
```

### 6. Anwendung öffnen

Öffnen Sie: `http://localhost/`

---

## 📚 Vollständige Dokumentation

Siehe: **INSTALLATION_IIS.md**

---

## ⚠️ Troubleshooting

### PHP wird nicht ausgeführt?

1. Überprüfen Sie IIS Handler Mappings
2. Kontrollieren Sie php-cgi.exe Pfad in web.config
3. Starten Sie IIS neu: `iisreset`

### Fehler beim Datenbankzugriff?

1. Überprüfen Sie MariaDB läuft
2. Kontrollieren Sie Benutzer in config.php
3. Überprüfen Sie Windows Event Viewer

### Permission Denied?

```powershell
icacls C:\inetpub\wwwroot\DerWeitermacher /grant "IIS_IUSRS:M" /T
```

---

**Unterstützung:** Siehe INSTALLATION_IIS.md für detaillierte Anleitung
