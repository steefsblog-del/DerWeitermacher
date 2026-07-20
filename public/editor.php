<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Editor - RSA 21 Baustellenmanagement</title>
    <link rel="stylesheet" href="/css/editor.css">
</head>
<body>
    <div class="editor-container">
        <!-- Toolbar -->
        <div class="toolbar">
            <div class="toolbar-section">
                <button id="saveBtn" class="btn btn-primary" onclick="saveProject()">💾 Speichern</button>
                <button id="validateBtn" class="btn btn-info" onclick="validateProject()">✓ Validieren</button>
                <button id="generateBtn" class="btn btn-success" onclick="showGenerateMenu()">📄 Dokumente</button>
            </div>
            <div class="toolbar-section">
                <span id="projectTitle" class="project-title"></span>
            </div>
        </div>

        <div class="editor-content">
            <!-- Sign Library -->
            <aside class="sign-library">
                <h3>Verkehrszeichen</h3>
                <div class="library-tabs">
                    <button class="lib-tab active" onclick="filterSigns('all')">Alle</button>
                    <button class="lib-tab" onclick="filterSigns('warning')">Warnzeichen</button>
                    <button class="lib-tab" onclick="filterSigns('mandatory')">Gebote</button>
                    <button class="lib-tab" onclick="filterSigns('direction')">Umleitungen</button>
                </div>
                <div id="signsList" class="signs-list">
                    <!-- Dynamisch geladen -->
                </div>
            </aside>

            <!-- Canvas Area -->
            <div class="canvas-area">
                <canvas id="mainCanvas"></canvas>
            </div>

            <!-- Properties Panel -->
            <aside class="properties-panel">
                <h3>Eigenschaften</h3>
                <div id="propertiesContent">
                    <p>Wählen Sie ein Zeichen aus um Eigenschaften zu bearbeiten</p>
                </div>
            </aside>
        </div>

        <!-- Validation Results Modal -->
        <div id="validationModal" class="modal">
            <div class="modal-content">
                <span class="close" onclick="closeModal('validationModal')">&times;</span>
                <h2>Validierungsergebnisse</h2>
                <div id="validationResults">
                    <!-- Dynamisch geladen -->
                </div>
            </div>
        </div>

        <!-- Generate Documents Modal -->
        <div id="generateModal" class="modal">
            <div class="modal-content">
                <span class="close" onclick="closeModal('generateModal')">&times;</span>
                <h2>Dokumente generieren</h2>
                <div class="doc-buttons">
                    <button onclick="generateDocument('traffic_plan')" class="btn btn-primary">Verkehrszeichenplan</button>
                    <button onclick="generateDocument('diversion_plan')" class="btn btn-primary">Umleitungsplan</button>
                    <button onclick="generateDocument('signage_plan')" class="btn btn-primary">Beschilderungsplan</button>
                    <button onclick="generateDocument('traffic_order')" class="btn btn-primary">Verkehrsrechtliche Anordnung</button>
                    <button onclick="generateDocument('control_protocol')" class="btn btn-primary">Kontrollprotokoll</button>
                    <button onclick="generateDocument('site_documentation')" class="btn btn-primary">Baustellendokumentation</button>
                </div>
            </div>
        </div>
    </div>

    <script src="/js/editor.js"></script>
</body>
</html>
