<?php
/**
 * Haupteinstiegspunkt
 */
require_once __DIR__ . '/bootstrap.php';

use RSA21\Config\Database;

// Database Instanz testen
try {
    $db = Database::getInstance();
    $connection = $db->getConnection();
    
    // Authentifizierung prüfen
    $isLoggedIn = isset($_SESSION['user_id']);
    
    if (!$isLoggedIn && $_SERVER['REQUEST_URI'] !== '/' && 
        strpos($_SERVER['REQUEST_URI'], '/api/') === false &&
        strpos($_SERVER['REQUEST_URI'], '/auth/') === false) {
        header('Location: /');
        exit;
    }
    
    // Home oder Dashboard laden
    if (!$isLoggedIn) {
        include __DIR__ . '/public/home.php';
    } else {
        include __DIR__ . '/public/dashboard.php';
    }
    
} catch (Exception $e) {
    die('Fehler: ' . $e->getMessage());
}
