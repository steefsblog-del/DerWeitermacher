<?php
/**
 * API - Verkehrszeichen
 */

header('Content-Type: application/json; charset=utf-8');
require_once __DIR__ . '/../config/config.php';
require_once __DIR__ . '/../config/Database.php';
require_once __DIR__ . '/../classes/TrafficSign.php';

use RSA21\Classes\TrafficSign;

$signClass = new TrafficSign();
method = $_SERVER['REQUEST_METHOD'];

switch ($method) {
    case 'GET':
        if (isset($_GET['category'])) {
            $signs = $signClass->getSignsByCategory($_GET['category']);
        } else {
            $signs = $signClass->getAllSigns();
        }
        echo json_encode(['success' => true, 'data' => $signs]);
        break;

    default:
        http_response_code(405);
        echo json_encode(['error' => 'Methode nicht erlaubt']);
}
