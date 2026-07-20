// Zusätzliche Editor-Funktionalität

let canvasZoom = 1;
const ZOOM_STEP = 0.1;
const MIN_ZOOM = 0.5;
const MAX_ZOOM = 3;

// Zoom-Funktionen
function zoomIn() {
    if (canvasZoom < MAX_ZOOM) {
        canvasZoom += ZOOM_STEP;
        updateCanvasSize();
    }
}

function zoomOut() {
    if (canvasZoom > MIN_ZOOM) {
        canvasZoom -= ZOOM_STEP;
        updateCanvasSize();
    }
}

function zoomReset() {
    canvasZoom = 1;
    updateCanvasSize();
}

function updateCanvasSize() {
    const newWidth = canvas.width * canvasZoom;
    const newHeight = canvas.height * canvasZoom;
    canvas.style.width = newWidth + 'px';
    canvas.style.height = newHeight + 'px';
}

// Undo/Redo Stack
class CommandHistory {
    constructor() {
        this.history = [];
        this.currentIndex = -1;
    }

    execute(command) {
        command.execute();
        this.history = this.history.slice(0, this.currentIndex + 1);
        this.history.push(command);
        this.currentIndex++;
    }

    undo() {
        if (this.currentIndex > 0) {
            this.currentIndex--;
            this.history[this.currentIndex].undo();
            drawCanvas();
        }
    }

    redo() {
        if (this.currentIndex < this.history.length - 1) {
            this.currentIndex++;
            this.history[this.currentIndex].execute();
            drawCanvas();
        }
    }
}

let commandHistory = new CommandHistory();

// Keyboard Shortcuts
document.addEventListener('keydown', (e) => {
    // Ctrl+Z - Undo
    if ((e.ctrlKey || e.metaKey) && e.key === 'z' && !e.shiftKey) {
        e.preventDefault();
        commandHistory.undo();
    }
    // Ctrl+Shift+Z - Redo
    if ((e.ctrlKey || e.metaKey) && (e.key === 'z' || e.key === 'y') && e.shiftKey) {
        e.preventDefault();
        commandHistory.redo();
    }
    // Delete - Löschen
    if (e.key === 'Delete' && selectedSign) {
        e.preventDefault();
        deleteSelectedSign();
    }
});

// Zeichen löschen
function deleteSelectedSign() {
    if (selectedSign) {
        const index = placedSigns.findIndex(s => s === selectedSign);
        if (index > -1) {
            placedSigns.splice(index, 1);
            selectedSign = null;
            drawCanvas();
            showNotification('Zeichen gelöscht', 'success');
        }
    }
}

// Mehrfachauswahl
let selectedSigns = [];
let selectionBox = null;

canvas.addEventListener('mousedown', (e) => {
    if (e.shiftKey) {
        selectionBox = {
            startX: e.offsetX,
            startY: e.offsetY
        };
    }
});

canvas.addEventListener('mousemove', (e) => {
    if (selectionBox) {
        selectionBox.endX = e.offsetX;
        selectionBox.endY = e.offsetY;
        drawCanvas();
        // Draw selection box
        ctx.strokeStyle = 'rgba(102, 126, 234, 0.5)';
        ctx.lineWidth = 2;
        ctx.strokeRect(
            selectionBox.startX,
            selectionBox.startY,
            selectionBox.endX - selectionBox.startX,
            selectionBox.endY - selectionBox.startY
        );
    }
});

canvas.addEventListener('mouseup', () => {
    if (selectionBox) {
        // Find signs in selection
        const minX = Math.min(selectionBox.startX, selectionBox.endX);
        const maxX = Math.max(selectionBox.startX, selectionBox.endX);
        const minY = Math.min(selectionBox.startY, selectionBox.endY);
        const maxY = Math.max(selectionBox.startY, selectionBox.endY);

        selectedSigns = placedSigns.filter(sign => 
            sign.x >= minX && sign.x + sign.width <= maxX &&
            sign.y >= minY && sign.y + sign.height <= maxY
        );
        
        selectionBox = null;
        drawCanvas();
    }
});

// Gruppieren
function groupSigns() {
    if (selectedSigns.length > 1) {
        const group = {
            type: 'group',
            signs: [...selectedSigns],
            x: Math.min(...selectedSigns.map(s => s.x)),
            y: Math.min(...selectedSigns.map(s => s.y))
        };
        
        // Remove individual signs and add group
        placedSigns = placedSigns.filter(s => !selectedSigns.includes(s));
        placedSigns.push(group);
        selectedSigns = [];
        drawCanvas();
        showNotification('Zeichen gruppiert', 'success');
    }
}

// Ausrichten
function alignSigns(direction) {
    if (selectedSigns.length < 2) return;

    const positions = selectedSigns.map(s => ({
        sign: s,
        x: s.x,
        y: s.y
    }));

    switch(direction) {
        case 'left':
            const minLeft = Math.min(...positions.map(p => p.x));
            selectedSigns.forEach(s => s.x = minLeft);
            break;
        case 'right':
            const maxRight = Math.max(...positions.map(p => p.x + p.sign.width));
            selectedSigns.forEach(s => s.x = maxRight - s.width);
            break;
        case 'top':
            const minTop = Math.min(...positions.map(p => p.y));
            selectedSigns.forEach(s => s.y = minTop);
            break;
        case 'bottom':
            const maxBottom = Math.max(...positions.map(p => p.y + p.sign.height));
            selectedSigns.forEach(s => s.y = maxBottom - s.height);
            break;
    }

    drawCanvas();
    showNotification(`Zeichen ausgerichtet: ${direction}`, 'success');
}

// Verteilung
function distributeSignsEvenly(direction) {
    if (selectedSigns.length < 3) return;

    const sorted = direction === 'horizontal' 
        ? selectedSigns.sort((a, b) => a.x - b.x)
        : selectedSigns.sort((a, b) => a.y - b.y);

    const first = sorted[0];
    const last = sorted[sorted.length - 1];
    const spacing = direction === 'horizontal'
        ? (last.x - first.x) / (sorted.length - 1)
        : (last.y - first.y) / (sorted.length - 1);

    sorted.forEach((sign, index) => {
        if (direction === 'horizontal') {
            sign.x = first.x + (spacing * index);
        } else {
            sign.y = first.y + (spacing * index);
        }
    });

    drawCanvas();
    showNotification(`Zeichen verteilt: ${direction}`, 'success');
}

// Template-System
const Templates = {
    saveTemplate: (name) => {
        const template = {
            name: name,
            signs: JSON.parse(JSON.stringify(placedSigns)),
            timestamp: new Date().toISOString()
        };
        const templates = Storage.get('templates') || [];
        templates.push(template);
        Storage.set('templates', templates);
        showNotification('Template gespeichert', 'success');
    },

    loadTemplate: (name) => {
        const templates = Storage.get('templates') || [];
        const template = templates.find(t => t.name === name);
        if (template) {
            placedSigns = JSON.parse(JSON.stringify(template.signs));
            drawCanvas();
            showNotification('Template geladen', 'success');
        }
    },

    deleteTemplate: (name) => {
        let templates = Storage.get('templates') || [];
        templates = templates.filter(t => t.name !== name);
        Storage.set('templates', templates);
        showNotification('Template gelöscht', 'success');
    },

    listTemplates: () => {
        return Storage.get('templates') || [];
    }
};

// Auto-Save
let autoSaveTimer = null;

function enableAutoSave(intervalSeconds = 30) {
    autoSaveTimer = setInterval(() => {
        if (projectId) {
            saveProject();
            Logger.log('Auto-Save durchgeführt');
        }
    }, intervalSeconds * 1000);
}

function disableAutoSave() {
    if (autoSaveTimer) {
        clearInterval(autoSaveTimer);
        autoSaveTimer = null;
    }
}

// Zeichen-Snapshots
function createSnapshot() {
    return JSON.stringify(placedSigns);
}

function restoreSnapshot(snapshot) {
    placedSigns = JSON.parse(snapshot);
    drawCanvas();
}

// Enable Auto-Save on startup
enableAutoSave(30);
