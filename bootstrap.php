<?php
/**
 * Autoloader und Bootstrap
 */

require_once __DIR__ . '/config/config.php';

spl_autoload_register(function ($class) {
    $prefix = 'RSA21\\';
    $base_dir = __DIR__ . '/src/';
    
    $len = strlen($prefix);
    if (strncmp($prefix, $class, $len) !== 0) {
        return;
    }
    
    $relative_class = substr($class, $len);
    $file = $base_dir . str_replace('\\', '/', $relative_class) . '.php';
    
    if (file_exists($file)) {
        require $file;
    }
});

// Session starten
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}
