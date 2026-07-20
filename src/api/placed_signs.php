<?php
/**
 * API - Platzierte Zeichen
 */

header('Content-Type: application/json; charset=utf-8');
require_once __DIR__ . '/../config/config.php';
require_once __DIR__ . '/../config/Database.php';

use RSA21\Config\Database;

session_start();

if (!isset($_SESSION['user_id'])) {
    http_response_code(401);
    echo json_encode(['error' => 'Nicht authentifiziert']);
    exit;
}

$db = Database::getInstance()->getConnection();
$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {
    case 'GET':
        if (isset($_GET['project_id'])) {
            $sql = "SELECT ps.*, ts.sign_code, ts.category FROM placed_signs ps 
                    JOIN traffic_signs ts ON ps.sign_id = ts.id 
                    WHERE ps.project_id = :project_id";
            $stmt = $db->prepare($sql);
            $stmt->execute([':project_id' => $_GET['project_id']]);
            $signs = $stmt->fetchAll();
            echo json_encode(['success' => true, 'data' => $signs]);
        }
        break;

    case 'POST':
        $data = json_decode(file_get_contents('php://input'), true);
        $sql = "INSERT INTO placed_signs (project_id, sign_id, x_position, y_position, width, height) 
                VALUES (:project_id, :sign_id, :x_position, :y_position, :width, :height)";
        $stmt = $db->prepare($sql);
        $result = $stmt->execute([
            ':project_id' => $data['project_id'],
            ':sign_id' => $data['sign_id'],
            ':x_position' => $data['x_position'],
            ':y_position' => $data['y_position'],
            ':width' => $data['width'],
            ':height' => $data['height']
        ]);
        echo json_encode(['success' => $result]);
        break;

    default:
        http_response_code(405);
        echo json_encode(['error' => 'Methode nicht erlaubt']);
}
