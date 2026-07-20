# RSA 21 Baustellenmanagement - Automatisierte Installation für Windows Server mit IIS
# Dieses Skript muss als Administrator ausgeführt werden

# Farben für Output
$ErrorColor = 'Red'
$SuccessColor = 'Green'
$WarningColor = 'Yellow'
$InfoColor = 'Cyan'

function Write-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor $SuccessColor
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor $ErrorColor
}

function Write-Warning-Custom {
    param([string]$Message)
    Write-Host "⚠ $Message" -ForegroundColor $WarningColor
}

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ $Message" -ForegroundColor $InfoColor
}

# Admin-Rechte überprüfen
$isAdmin = [Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Error-Custom "Dieses Skript muss als Administrator ausgeführt werden!"
    exit 1
}

Write-Info "RSA 21 Baustellenmanagement - IIS Installation"
Write-Info "================================================\n"

# 1. IIS Installation
Write-Info "Schritt 1: IIS Installation\n"

$iisFeaturesNeeded = @(
    'Web-Server',
    'Web-CGI',
    'Web-Url-Rewrite',
    'Web-Mgmt-Console',
    'Web-Static-Content',
    'Web-Default-Doc',
    'Web-Dir-Browsing',
    'Web-Http-Errors',
    'Web-Http-Logging',
    'Web-Common-Http',
    'Web-Performance',
    'Web-Stat-Compression',
    'Web-Dyn-Compression',
    'Web-Security',
    'Web-Filtering'
)

foreach ($feature in $iisFeaturesNeeded) {
    $state = (Get-WindowsOptionalFeature -Online -FeatureName $feature -ErrorAction SilentlyContinue).State
    if ($state -eq 'Enabled') {
        Write-Success "$feature ist bereits aktiviert"
    } else {
        Write-Info "Aktiviere $feature..."
        Add-WindowsFeature $feature | Out-Null
        Write-Success "$feature wurde aktiviert"
    }
}

# 2. Verzeichnisstruktur erstellen
Write-Info "\nSchritt 2: Verzeichnisstruktur erstellen\n"

$basePath = "C:\inetpub\wwwroot\DerWeitermacher"
$dirsToCreate = @(
    "$basePath\public\uploads",
    "$basePath\tmp",
    "$basePath\logs",
    "C:\php\session"
)

foreach ($dir in $dirsToCreate) {
    if (Test-Path $dir) {
        Write-Success "Verzeichnis existiert: $dir"
    } else {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Success "Verzeichnis erstellt: $dir"
    }
}

# 3. Berechtigungen setzen
Write-Info "\nSchritt 3: Berechtigungen setzen\n"

$dirsToGrant = @(
    @{path="$basePath"; access="R"},
    @{path="$basePath\public\uploads"; access="M"},
    @{path="$basePath\tmp"; access="M"},
    @{path="$basePath\logs"; access="M"},
    @{path="C:\php\session"; access="M"}
)

foreach ($dir_config in $dirsToGrant) {
    $path = $dir_config.path
    $access = $dir_config.access
    
    if ($access -eq "R") {
        icacls $path /grant "IIS_IUSRS:(OI)(CI)R" /T 2>&1 | Out-Null
        Write-Success "Leseberechtigung gesetzt für: $path"
    } elseif ($access -eq "M") {
        icacls $path /grant "IIS_IUSRS:(OI)(CI)M" /T 2>&1 | Out-Null
        Write-Success "Schreibberechtigung gesetzt für: $path"
    }
}

# 4. web.config erstellen
Write-Info "\nSchritt 4: web.config erstellen\n"

$webConfigPath = "$basePath\public\web.config"

if (-not (Test-Path $webConfigPath)) {
    $webConfigContent = @'
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
                <hiddenSegments>
                    <add segment="config" />
                    <add segment="src" />
                    <add segment="vendor" />
                    <add segment="database" />
                </hiddenSegments>
                <fileExtensions>
                    <add fileExtension=".env" allowed="false" />
                    <add fileExtension=".log" allowed="false" />
                    <add fileExtension=".php" allowed="true" />
                </fileExtensions>
            </requestFiltering>
        </security>
    </system.webServer>
</configuration>
'@
    
    $webConfigContent | Out-File -FilePath $webConfigPath -Encoding UTF8 -Force
    Write-Success "web.config erstellt: $webConfigPath"
} else {
    Write-Success "web.config existiert bereits"
}

# 5. IIS Application Pool erstellen
Write-Info "\nSchritt 5: IIS Application Pool konfigurieren\n"

Import-Module WebAdministration

$poolName = "RSA21_Pool"
$siteName = "RSA21Baustellenmanagement"

# Application Pool
if (Test-Path "IIS:\AppPools\$poolName") {
    Write-Success "Application Pool existiert bereits: $poolName"
} else {
    New-WebAppPool -Name $poolName | Out-Null
    Set-ItemProperty "IIS:\AppPools\$poolName" -Name "processModel.identityType" -Value "ApplicationPoolIdentity"
    Set-ItemProperty "IIS:\AppPools\$poolName" -Name "enable32BitAppCompat" -Value $false
    Write-Success "Application Pool erstellt: $poolName"
}

# Website
if (Test-Path "IIS:\Sites\$siteName") {
    Write-Success "Website existiert bereits: $siteName"
} else {
    New-Website -Name $siteName -PhysicalPath "$basePath\public" -Port 80 -AppPool $poolName | Out-Null
    Write-Success "Website erstellt: $siteName"
}

# 6. config.php vorbereiten
Write-Info "\nSchritt 6: Konfigurationsdatei vorbereiten\n"

$configExample = "$basePath\config\config.example.php"
$configFile = "$basePath\config\config.php"

if ((Test-Path $configExample) -and (-not (Test-Path $configFile))) {
    Copy-Item -Path $configExample -Destination $configFile -Force
    Write-Success "config.php erstellt aus config.example.php"
    Write-Warning-Custom "WICHTIG: Bitte bearbeiten Sie die Datei: $configFile"
    Write-Warning-Custom "  - DB_HOST: localhost"
    Write-Warning-Custom "  - DB_USER: rsa21_user"
    Write-Warning-Custom "  - DB_PASS: [Ihr Datenbankpasswort]"
    Write-Warning-Custom "  - DB_NAME: rsa21_baustellenmanagement"
} elseif (Test-Path $configFile) {
    Write-Success "config.php existiert bereits"
} else {
    Write-Error-Custom "config.example.php nicht gefunden!"
}

# 7. Firewall-Regeln
Write-Info "\nSchritt 7: Firewall-Regeln konfigurieren\n"

# HTTP
if (Get-NetFirewallRule -DisplayName "HTTP" -ErrorAction SilentlyContinue) {
    Write-Success "HTTP Firewall-Regel existiert bereits"
} else {
    New-NetFirewallRule -DisplayName "HTTP" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 80 | Out-Null
    Write-Success "HTTP Firewall-Regel erstellt"
}

# HTTPS
if (Get-NetFirewallRule -DisplayName "HTTPS" -ErrorAction SilentlyContinue) {
    Write-Success "HTTPS Firewall-Regel existiert bereits"
} else {
    New-NetFirewallRule -DisplayName "HTTPS" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 443 | Out-Null
    Write-Success "HTTPS Firewall-Regel erstellt"
}

# 8. IIS Services starten
Write-Info "\nSchritt 8: IIS Services starten\n"

Start-Service -Name "W3SVC" -ErrorAction SilentlyContinue
Write-Success "IIS Web Service gestartet"

# 9. Zusammenfassung
Write-Info "\n================================================"
Write-Success "Installation abgeschlossen!\n"

Write-Info "Nächste Schritte:"
Write-Info "1. PHP 8.1 herunterladen und installieren (wenn nicht vorhanden)"
Write-Info "2. MariaDB/MySQL herunterladen und installieren"
Write-Info "3. Datenbank erstellen und schema.sql importieren"
Write-Info "4. config.php bearbeiten mit Ihrer Datenbankkonfiguration"
Write-Info "5. Composer install ausführen"
Write-Info "6. Anwendung öffnen: http://localhost/\n"

Write-Info "Wichtige Pfade:"
Write-Info "  Projekt: $basePath"
Write-Info "  Config: $configFile"
Write-Info "  Logs: $basePath\logs\n"

Write-Info "Weitere Informationen: INSTALLATION_IIS.md"
