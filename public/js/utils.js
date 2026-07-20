// Allgemeine Hilfsfunktionen

const API_BASE_URL = '/src/api';

// Fetch mit Error Handling
async function apiCall(endpoint, options = {}) {
    const defaultOptions = {
        method: 'GET',
        headers: { 'Content-Type': 'application/json' }
    };

    const mergedOptions = { ...defaultOptions, ...options };

    try {
        const response = await fetch(`${API_BASE_URL}${endpoint}`, mergedOptions);

        if (response.status === 401) {
            // Unauthenticated
            window.location.href = '/';
            return null;
        }

        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }

        const data = await response.json();
        return data;
    } catch (error) {
        console.error('API Error:', error);
        showNotification('Fehler: ' + error.message, 'error');
        return null;
    }
}

// Benachrichtigungen
function showNotification(message, type = 'info') {
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    notification.textContent = message;
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        padding: 15px 20px;
        background: ${type === 'success' ? '#28a745' : type === 'error' ? '#dc3545' : '#17a2b8'};
        color: white;
        border-radius: 5px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        z-index: 2000;
        animation: slideIn 0.3s;
    `;

    document.body.appendChild(notification);

    setTimeout(() => {
        notification.style.animation = 'slideOut 0.3s';
        setTimeout(() => notification.remove(), 300);
    }, 3000);
}

// Datum formatieren
function formatDate(dateString) {
    const date = new Date(dateString);
    return date.toLocaleDateString('de-DE', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit'
    });
}

// Local Storage Funktionen
const Storage = {
    set: (key, value) => localStorage.setItem(key, JSON.stringify(value)),
    get: (key) => {
        const item = localStorage.getItem(key);
        return item ? JSON.parse(item) : null;
    },
    remove: (key) => localStorage.removeItem(key),
    clear: () => localStorage.clear()
};

// Debounce Funktion
function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

// Throttle Funktion
function throttle(func, limit) {
    let inThrottle;
    return function(...args) {
        if (!inThrottle) {
            func.apply(this, args);
            inThrottle = true;
            setTimeout(() => inThrottle = false, limit);
        }
    };
}

// CSV Export
function exportToCSV(data, filename) {
    const csv = [
        Object.keys(data[0]).join(','),
        ...data.map(row => Object.values(row).map(val => `"${val}"`).join(','))
    ].join('\n');

    const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    link.href = URL.createObjectURL(blob);
    link.download = filename;
    link.click();
}

// Validierung
const Validate = {
    email: (email) => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email),
    password: (password) => password.length >= 6,
    phone: (phone) => /^[\d\s\-\+\(\)]+$/.test(phone),
    url: (url) => /^https?:\/\/.+/.test(url)
};

// Logging
const Logger = {
    log: (message, data = null) => {
        console.log(`[LOG] ${message}`, data);
    },
    warn: (message, data = null) => {
        console.warn(`[WARN] ${message}`, data);
    },
    error: (message, error = null) => {
        console.error(`[ERROR] ${message}`, error);
    }
};
