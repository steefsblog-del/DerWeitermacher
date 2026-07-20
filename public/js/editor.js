// Editor JavaScript

let canvas;
let ctx;
let selectedSign = null;
let placedSigns = [];
let projectId = null;

window.addEventListener('DOMContentLoaded', function() {
    canvas = document.getElementById('mainCanvas');
    ctx = canvas.getContext('2d');
    
    // Canvas Größe setzen
    canvas.width = 1000;
    canvas.height = 600;
    
    // Initial zeichnen
    drawCanvas();
    
    // Zeichen laden
    loadSignsLibrary();
    
    // URL-Parameter auslesen (wenn Projekt geladen wird)
    const params = new URLSearchParams(window.location.search);
    projectId = params.get('project_id');
    
    if (projectId) {
        loadProjectData(projectId);
    }
});

// Zeichen-Bibliothek laden
function loadSignsLibrary() {
    fetch('/src/api/signs.php')
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                displaySigns(data.data);
            }
        })
        .catch(error => console.error('Fehler beim Laden der Zeichen:', error));
}

// Zeichen anzeigen
function displaySigns(signs) {
    const signsList = document.getElementById('signsList');
    signsList.innerHTML = '';
    
    signs.forEach(sign => {
        const signElement = document.createElement('div');
        signElement.className = 'sign-item';
        signElement.textContent = sign.sign_code;
        signElement.draggable = true;
        signElement.onclick = () => selectSign(sign);
        signElement.ondragstart = (e) => {
            e.dataTransfer.effectAllowed = 'copy';
            e.dataTransfer.setData('sign', JSON.stringify(sign));
        };
        signsList.appendChild(signElement);
    });
}

// Zeichen filtern
function filterSigns(category) {
    const tabs = document.querySelectorAll('.lib-tab');
    tabs.forEach(tab => tab.classList.remove('active'));
    event.target.classList.add('active');
    
    fetch(`/src/api/signs.php?category=${category}`)
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                displaySigns(data.data);
            }
        });
}

// Zeichen auswählen
function selectSign(sign) {
    selectedSign = sign;
    updatePropertiesPanel(sign);
}

// Eigenschaften-Panel aktualisieren
function updatePropertiesPanel(sign) {
    const propertiesContent = document.getElementById('propertiesContent');
    propertiesContent.innerHTML = `
        <div class="property-group">
            <label>Zeichencode:</label>
            <p>${sign.sign_code}</p>
            <label>Kategorie:</label>
            <p>${sign.category}</p>
            <label>Beschreibung:</label>
            <p>${sign.description}</p>
            <label>Höhe (mm):</label>
            <input type="number" id="signHeight" value="${sign.height || 600}">
            <label>Breite (mm):</label>
            <input type="number" id="signWidth" value="${sign.width || 600}">
            <button onclick="placeSignOnCanvas()" class="btn btn-primary">Auf Canvas platzieren</button>
        </div>
    `;
}

// Zeichen auf Canvas platzieren
function placeSignOnCanvas() {
    if (!selectedSign) return;
    
    const sign = {
        ...selectedSign,
        x: Math.random() * (canvas.width - 100),
        y: Math.random() * (canvas.height - 100),
        width: parseFloat(document.getElementById('signWidth').value),
        height: parseFloat(document.getElementById('signHeight').value)
    };
    
    placedSigns.push(sign);
    drawCanvas();
}

// Canvas zeichnen
function drawCanvas() {
    ctx.fillStyle = '#f0f0f0';
    ctx.fillRect(0, 0, canvas.width, canvas.height);
    
    // Gitter zeichnen
    ctx.strokeStyle = '#e0e0e0';
    ctx.lineWidth = 1;
    for (let i = 0; i <= canvas.width; i += 50) {
        ctx.beginPath();
        ctx.moveTo(i, 0);
        ctx.lineTo(i, canvas.height);
        ctx.stroke();
    }
    for (let i = 0; i <= canvas.height; i += 50) {
        ctx.beginPath();
        ctx.moveTo(0, i);
        ctx.lineTo(canvas.width, i);
        ctx.stroke();
    }
    
    // Zeichen zeichnen
    placedSigns.forEach(sign => {
        ctx.fillStyle = '#ff0000';
        ctx.fillRect(sign.x, sign.y, 50, 50);
        ctx.fillStyle = '#ffffff';
        ctx.font = '12px Arial';
        ctx.fillText(sign.sign_code, sign.x + 5, sign.y + 30);
    });
}

// Projekt speichern
function saveProject() {
    if (!projectId) {
        const projectName = prompt('Projektname:');
        if (!projectName) return;
    }
    
    const projectData = {
        signs: placedSigns,
        timestamp: new Date().toISOString()
    };
    
    const method = projectId ? 'PUT' : 'POST';
    const url = projectId ? `/src/api/projects.php?id=${projectId}` : '/src/api/projects.php';
    
    fetch(url, {
        method: method,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(projectData)
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            alert('Projekt gespeichert!');
            if (!projectId) {
                projectId = data.project_id;
            }
        }
    })
    .catch(error => console.error('Fehler:', error));
}

// Projekt validieren
function validateProject() {
    fetch('/src/api/validate.php', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ project_id: projectId, signs: placedSigns })
    })
    .then(response => response.json())
    .then(data => {
        displayValidationResults(data);
    })
    .catch(error => console.error('Fehler:', error));
}

// Validierungsergebnisse anzeigen
function displayValidationResults(results) {
    const validationResults = document.getElementById('validationResults');
    let html = `<p>Gesamtprüfungen: ${results.total_checks}</p>
                <p>Bestanden: ${results.passed_checks}</p>
                <p>Fehler: ${results.failed_checks}</p>
                <p>Warnungen: ${results.warnings_count}</p>`;
    
    if (results.errors.length > 0) {
        html += '<h4>Fehler:</h4><ul>';
        results.errors.forEach(error => {
            html += `<li>${error.message}</li>`;
        });
        html += '</ul>';
    }
    
    validationResults.innerHTML = html;
    document.getElementById('validationModal').style.display = 'block';
}

// Dokumente generieren Menu anzeigen
function showGenerateMenu() {
    document.getElementById('generateModal').style.display = 'block';
}

// Dokument generieren
function generateDocument(type) {
    if (!projectId) {
        alert('Bitte speichern Sie das Projekt zuerst!');
        return;
    }
    
    fetch('/src/api/generate_pdf.php', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ 
            project_id: projectId,
            document_type: type,
            signs: placedSigns
        })
    })
    .then(response => response.blob())
    .then(blob => {
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `${type}_${projectId}.pdf`;
        a.click();
    })
    .catch(error => console.error('Fehler beim Generieren:', error));
}

// Modal schließen
function closeModal(modalId) {
    document.getElementById(modalId).style.display = 'none';
}

// Projektdaten laden
function loadProjectData(id) {
    fetch(`/src/api/projects.php?id=${id}`)
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                document.getElementById('projectTitle').textContent = data.data.project_name;
                // Laden Sie auch die Zeichen
                loadPlacedSigns(id);
            }
        })
        .catch(error => console.error('Fehler:', error));
}

// Platzierte Zeichen laden
function loadPlacedSigns(projectId) {
    fetch(`/src/api/placed_signs.php?project_id=${projectId}`)
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                placedSigns = data.data;
                drawCanvas();
            }
        })
        .catch(error => console.error('Fehler:', error));
}

// Canvas Drag & Drop
canvas.addEventListener('dragover', (e) => {
    e.preventDefault();
    e.dataTransfer.dropEffect = 'copy';
});

canvas.addEventListener('drop', (e) => {
    e.preventDefault();
    const sign = JSON.parse(e.dataTransfer.getData('sign'));
    const rect = canvas.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;
    
    placedSigns.push({
        ...sign,
        x: x,
        y: y,
        width: 50,
        height: 50
    });
    
    drawCanvas();
});
