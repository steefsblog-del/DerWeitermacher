<?php
/**
 * API - PDF Generierung
 */

header('Content-Type: application/json; charset=utf-8');
require_once __DIR__ . '/../config/config.php';
require_once __DIR__ . '/../config/Database.php';
require_once __DIR__ . '/../classes/PDFGenerator.php';

use RSA21\Classes\PDFGenerator;
use RSA21\Config\Database;

session_start();

if (!isset($_SESSION['user_id'])) {
    http_response_code(401);
    echo json_encode(['error' => 'Nicht authentifiziert']);
    exit;
}

$data = json_decode(file_get_contents('php://input'), true);
$db = Database::getInstance()->getConnection();
$pdfGenerator = new PDFGenerator();

if (!isset($data['project_id']) || !isset($data['document_type'])) {
    http_response_code(400);
    echo json_encode(['error' => 'Erforderliche Parameter fehlen']);
    exit;
}

// Projekt abrufen
$sql = "SELECT * FROM projects WHERE id = :id AND user_id = :user_id";
$stmt = $db->prepare($sql);
$stmt->execute([':id' => $data['project_id'], ':user_id' => $_SESSION['user_id']]);
$project = $stmt->fetch();

if (!$project) {
    http_response_code(404);
    echo json_encode(['error' => 'Projekt nicht gefunden']);
    exit;
}

// PDF basierend auf Dokumenttyp generieren
try {
    switch ($data['document_type']) {
        case 'traffic_plan':
            $pdfGenerator->generateTrafficPlan($project, $data['signs']);
            break;
        case 'diversion_plan':
            $pdfGenerator->generateDiversionPlan($project, $data['signs']);
            break;
        case 'signage_plan':
            $pdfGenerator->generateSignagePlan($project, $data['signs']);
            break;
        case 'traffic_order':
            $pdfGenerator->generateTrafficOrder($project);
            break;
        case 'control_protocol':
            $pdfGenerator->generateControlProtocol($project, $data['signs']);
            break;
        case 'site_documentation':
            $pdfGenerator->generateSiteDocumentation($project);
            break;
        default:
            http_response_code(400);
            echo json_encode(['error' => 'Unbekannter Dokumenttyp']);
    }
    echo json_encode(['success' => true]);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => $e->getMessage()]);
}
