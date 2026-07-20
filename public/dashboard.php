<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - RSA 21 Baustellenmanagement</title>
    <link rel="stylesheet" href="/css/dashboard.css">
</head>
<body>
    <div class="dashboard">
        <!-- Sidebar -->
        <aside class="sidebar">
            <div class="logo">
                <h2>RSA 21</h2>
            </div>
            <nav class="menu">
                <a href="#" class="menu-item active" onclick="loadPage('overview')">📊 Übersicht</a>
                <a href="#" class="menu-item" onclick="loadPage('projects')">📁 Projekte</a>
                <a href="#" class="menu-item" onclick="loadPage('editor')">✏️ Editor</a>
                <a href="#" class="menu-item" onclick="loadPage('templates')">📋 Vorlagen</a>
                <a href="#" class="menu-item" onclick="loadPage('documents')">📄 Dokumente</a>
                <a href="#" class="menu-item" onclick="loadPage('settings')">⚙️ Einstellungen</a>
                <a href="/src/api/auth.php?action=logout" class="menu-item">🚪 Abmelden</a>
            </nav>
        </aside>

        <!-- Main Content -->
        <main class="main-content">
            <!-- Header -->
            <header class="header">
                <h1 id="pageTitle">Übersicht</h1>
                <div class="user-info">
                    <span id="userName">Benutzer</span>
                    <img src="https://via.placeholder.com/40" alt="Avatar" class="avatar">
                </div>
            </header>

            <!-- Content Area -->
            <div class="content-area" id="contentArea">
                <!-- Dynamisch geladen -->
            </div>
        </main>
    </div>

    <!-- Modals -->
    <div id="projectModal" class="modal">
        <div class="modal-content">
            <span class="close" onclick="closeModal('projectModal')">&times;</span>
            <h2>Neues Projekt erstellen</h2>
            <form id="projectForm">
                <div class="form-group">
                    <label for="projectName">Projektname</label>
                    <input type="text" id="projectName" required>
                </div>
                <div class="form-group">
                    <label for="projectLocation">Ort</label>
                    <input type="text" id="projectLocation" required>
                </div>
                <div class="form-group">
                    <label for="projectStreet">Straße</label>
                    <input type="text" id="projectStreet" required>
                </div>
                <div class="form-group">
                    <label for="projectZip">PLZ</label>
                    <input type="text" id="projectZip" required>
                </div>
                <div class="form-group">
                    <label for="projectCity">Stadt</label>
                    <input type="text" id="projectCity" required>
                </div>
                <div class="form-group">
                    <label for="projectStart">Startdatum</label>
                    <input type="date" id="projectStart" required>
                </div>
                <div class="form-group">
                    <label for="projectEnd">Enddatum</label>
                    <input type="date" id="projectEnd" required>
                </div>
                <div class="form-group">
                    <label for="projectTemplate">Vorlage</label>
                    <select id="projectTemplate" required>
                        <option value="">-- Vorlage wählen --</option>
                        <option value="small_construction">Kleine Baustelle</option>
                        <option value="large_construction">Große Baustelle</option>
                        <option value="road_renewal">Fahrbahnerneuerung</option>
                        <option value="night_construction">Nachtbaustelle</option>
                        <option value="diversion_route">Umleitungsstrecke</option>
                    </select>
                </div>
                <button type="submit" class="btn btn-primary">Projekt erstellen</button>
            </form>
        </div>
    </div>

    <script src="/js/dashboard.js"></script>
</body>
</html>
