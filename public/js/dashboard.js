// Dashboard JavaScript

let currentPage = 'overview';
let projects = [];

// Seite laden
function loadPage(page) {
    currentPage = page;
    const contentArea = document.getElementById('contentArea');
    const pageTitle = document.getElementById('pageTitle');

    switch(page) {
        case 'overview':
            pageTitle.textContent = 'Übersicht';
            loadOverview();
            break;
        case 'projects':
            pageTitle.textContent = 'Projekte';
            loadProjects();
            break;
        case 'editor':
            pageTitle.textContent = 'Editor';
            loadEditor();
            break;
        case 'templates':
            pageTitle.textContent = 'Vorlagen';
            loadTemplates();
            break;
        case 'documents':
            pageTitle.textContent = 'Dokumente';
            loadDocuments();
            break;
        case 'settings':
            pageTitle.textContent = 'Einstellungen';
            loadSettings();
            break;
    }

    // Update menu items
    document.querySelectorAll('.menu-item').forEach(item => item.classList.remove('active'));
    event.target.classList.add('active');
}

// Übersicht laden
function loadOverview() {
    const contentArea = document.getElementById('contentArea');
    contentArea.innerHTML = `
        <div class="overview-container">
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-title">Gesamtprojekte</div>
                    <div class="stat-value" id="totalProjects">0</div>
                </div>
                <div class="stat-card">
                    <div class="stat-title">Aktive Projekte</div>
                    <div class="stat-value" id="activeProjects">0</div>
                </div>
                <div class="stat-card">
                    <div class="stat-title">Validierungen bestanden</div>
                    <div class="stat-value" id="passedValidations">0</div>
                </div>
            </div>
            <button class="btn btn-primary" onclick="openProjectModal()">+ Neues Projekt</button>
        </div>
    `;
    loadStatistics();
}

// Projekte laden
function loadProjects() {
    const contentArea = document.getElementById('contentArea');
    contentArea.innerHTML = '<p>Lädt Projekte...</p>';
    
    fetch('/src/api/projects.php')
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                projects = data.data;
                displayProjects();
            }
        })
        .catch(error => console.error('Fehler beim Laden der Projekte:', error));
}

function displayProjects() {
    const contentArea = document.getElementById('contentArea');
    
    if (projects.length === 0) {
        contentArea.innerHTML = '<p>Keine Projekte vorhanden. <a href="#" onclick="openProjectModal()">Neues Projekt erstellen</a></p>';
        return;
    }
    
    let html = '<table class="projects-table"><thead><tr><th>Name</th><th>Ort</th><th>Status</th><th>Aktion</th></tr></thead><tbody>';
    
    projects.forEach(project => {
        html += `
            <tr>
                <td>${project.project_name}</td>
                <td>${project.city}</td>
                <td>${project.status}</td>
                <td>
                    <button onclick="editProject(${project.id})" class="btn btn-sm">Bearbeiten</button>
                    <button onclick="deleteProject(${project.id})" class="btn btn-sm btn-danger">Löschen</button>
                </td>
            </tr>
        `;
    });
    
    html += '</tbody></table>';
    contentArea.innerHTML = html;
}

// Editor laden
function loadEditor() {
    window.location.href = '/public/editor.php';
}

// Vorlagen laden
function loadTemplates() {
    const contentArea = document.getElementById('contentArea');
    contentArea.innerHTML = `
        <div class="templates-grid">
            <div class="template-card" onclick="createFromTemplate('small_construction')">
                <h3>Kleine Baustelle</h3>
                <p>Für kleinere Baustellen mit Standard-Beschilderung</p>
            </div>
            <div class="template-card" onclick="createFromTemplate('large_construction')">
                <h3>Große Baustelle</h3>
                <p>Für umfangreiche Baustellen</p>
            </div>
            <div class="template-card" onclick="createFromTemplate('road_renewal')">
                <h3>Fahrbahnerneuerung</h3>
                <p>Spezielle Beschilderung für Straßenerneuerung</p>
            </div>
            <div class="template-card" onclick="createFromTemplate('night_construction')">
                <h3>Nachtbaustelle</h3>
                <p>Mit spezieller Beleuchtung und Beschilderung</p>
            </div>
            <div class="template-card" onclick="createFromTemplate('diversion_route')">
                <h3>Umleitungsstrecke</h3>
                <p>Mit vollständiger Umleitungsverweisung</p>
            </div>
        </div>
    `;
}

// Dokumente laden
function loadDocuments() {
    const contentArea = document.getElementById('contentArea');
    contentArea.innerHTML = '<p>Dokumentverwaltung kommt bald...</p>';
}

// Einstellungen laden
function loadSettings() {
    const contentArea = document.getElementById('contentArea');
    contentArea.innerHTML = `
        <div class="settings-form">
            <h3>Benutzereinstellungen</h3>
            <form>
                <div class="form-group">
                    <label>Sprache</label>
                    <select>
                        <option>Deutsch</option>
                        <option>English</option>
                    </select>
                </div>
                <button type="submit" class="btn btn-primary">Speichern</button>
            </form>
        </div>
    `;
}

// Modal öffnen
function openProjectModal() {
    document.getElementById('projectModal').style.display = 'block';
}

// Modal schließen
function closeModal(modalId) {
    document.getElementById(modalId).style.display = 'none';
}

// Projekt erstellen
document.addEventListener('DOMContentLoaded', function() {
    const projectForm = document.getElementById('projectForm');
    if (projectForm) {
        projectForm.addEventListener('submit', async (e) => {
            e.preventDefault();
            const formData = {
                project_name: document.getElementById('projectName').value,
                location: document.getElementById('projectLocation').value,
                street: document.getElementById('projectStreet').value,
                zip_code: document.getElementById('projectZip').value,
                city: document.getElementById('projectCity').value,
                start_date: document.getElementById('projectStart').value,
                end_date: document.getElementById('projectEnd').value,
                template_used: document.getElementById('projectTemplate').value
            };

            try {
                const response = await fetch('/src/api/projects.php', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(formData)
                });
                const data = await response.json();
                if (data.success) {
                    alert('Projekt erfolgreich erstellt!');
                    closeModal('projectModal');
                    loadProjects();
                    projectForm.reset();
                }
            } catch (error) {
                alert('Fehler: ' + error.message);
            }
        });
    }

    loadPage('overview');
});

function loadStatistics() {
    fetch('/src/api/projects.php')
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                const total = data.data.length;
                const active = data.data.filter(p => p.status === 'active').length;
                document.getElementById('totalProjects').textContent = total;
                document.getElementById('activeProjects').textContent = active;
            }
        });
}

function editProject(projectId) {
    alert('Bearbeitung kommt bald...');
}

function deleteProject(projectId) {
    if (confirm('Projekt wirklich löschen?')) {
        fetch(`/src/api/projects.php?id=${projectId}`, { method: 'DELETE' })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    alert('Projekt gelöscht');
                    loadProjects();
                }
            });
    }
}

function createFromTemplate(template) {
    alert(`Template ${template} wird geladen...`);
}
