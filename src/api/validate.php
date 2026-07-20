<?php
/**
 * API - Validierung
 */

header('Content-Type: application/json; charset=utf-8');
require_once __DIR__ . '/../config/config.php';
require_once __DIR__ . '/../config/Database.php';
require_once __DIR__ . '/../classes/Validator.php';

use RSA21\Classes\Validator;

session_start();

if (!isset($_SESSION['user_id'])) {
    http_response_code(401);
    echo json_encode(['error' => 'Nicht authentifiziert']);
    exit;
}

$data = json_decode(file_get_contents('php://input'), true);
$validator = new Validator();

if (isset($data['project_id'])) {
    $result = $validator->validateProject($data['project_id']);
    echo json_encode($result);
} else {
    http_response_code(400);
    echo json_encode(['error' => 'Projekt-ID erforderlich']);
}
