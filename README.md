# RSA 21 Baustellenmanagement

Eine professionelle Web-Anwendung zur Erstellung und Verwaltung von Verkehrszeichenplänen nach den **Richtlinien für die Sicherung von Arbeitsstellen auf Straßen (RSA 21)**.

## 🎯 Funktionen

- ✅ **Intuitiver Baukasten** mit Drag-and-Drop Interface
- ✅ **Vorgefertigte Templates** für häufige Szenarien
- ✅ **Automatische Platzierung** basierend auf RSA 21 Richtlinien
- ✅ **Automatische Dokumentgenerierung** in PDF:
  - Antrag auf verkehrsrechtliche Anordnung
  - Verkehrszeichenpläne nach RSA 21
  - Umleitungspläne
  - Beschilderungspläne
  - Kontroll- und Prüfprotokolle
  - Baustellendokumentation
- ✅ **Projektverwaltung** mit Speicherung und Abruf
- ✅ **Versionskontrolle** und Revisionsverlauf
- ✅ **RSA 21 Validierung** und Compliance-Überprüfung
- ✅ **Benutzerkonten** und Zugriffskontrolle

## 🛠️ Technologie-Stack

- **Backend**: PHP 7.4+
- **Frontend**: HTML5, CSS3, JavaScript (Vanilla)
- **Datenbank**: MariaDB
- **PDF-Generierung**: mPDF
- **Kanvas-Rendering**: HTML5 Canvas + SVG

## 📦 Installation

### Voraussetzungen
- PHP 7.4 oder höher
- MariaDB 10.3+
- Composer (optional, für Dependency Management)

### Schritt-für-Schritt

```bash
# 1. Repository klonen
git clone https://github.com/SayaFly/RSA21-Baustellenmanagement.git
cd RSA21-Baustellenmanagement

# 2. Konfiguration anpassen
cp config/config.example.php config/config.php
# Bearbeiten Sie die Datenbankverbindung in config/config.php

# 3. Datenbank initialisieren
mysql -u username -p database_name < database/schema.sql

# 4. Dateiberechtigungen setzen
chmod -R 755 public/uploads
chmod 644 config/config.php

# 5. Webserver starten (PHP Built-in Server zum Testen)
php -S localhost:8000 -t public/
```

## 🎨 Verwendung

1. **Neues Projekt erstellen**: Wählen Sie einen vordefinierten Template oder starten Sie von Grund auf
2. **Zeichen platzieren**: Nutzen Sie Drag-and-Drop im Baukasten
3. **Validierung**: Das System überprüft automatisch die RSA 21 Einhaltung
4. **Dokumente generieren**: Exportieren Sie alle erforderlichen PDFs auf Knopfdruck
5. **Projekt speichern**: Speichern Sie Ihr Projekt für zukünftige Bearbeitung

## 📚 Dokumentation

- [Installation & Setup](docs/INSTALLATION.md)
- [API-Referenz](docs/API.md)
- [RSA 21 Richtlinien](docs/RSA21-GUIDELINES.md)
- [Developer Guide](docs/DEVELOPER.md)

## 📄 Lizenz

Proprietär - Alle Rechte vorbehalten

## 👤 Autor

**SayaFly**

---

**Hinweis**: Diese Anwendung wurde speziell für die professionelle Verwaltung von Baustellen-Verkehrszeichen entwickelt. Alle generierten Dokumente müssen von entsprechend qualifiziertem Fachpersonal überprüft werden.
