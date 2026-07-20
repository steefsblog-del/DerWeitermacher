<?php
/**
 * Verkehrszeichen Klasse
 */

namespace RSA21\Classes;

use RSA21\Config\Database;
use PDO;

class TrafficSign {
    private $db;
    private $table = 'traffic_signs';

    public function __construct() {
        $this->db = Database::getInstance()->getConnection();
    }

    /**
     * Alle Zeichen abrufen
     */
    public function getAllSigns() {
        $sql = "SELECT * FROM {$this->table} WHERE active = TRUE ORDER BY category, sign_code";
        $stmt = $this->db->prepare($sql);
        $stmt->execute();
        return $stmt->fetchAll();
    }

    /**
     * Zeichen nach Kategorie filtern
     */
    public function getSignsByCategory($category) {
        $sql = "SELECT * FROM {$this->table} WHERE category = :category AND active = TRUE ORDER BY sign_code";
        $stmt = $this->db->prepare($sql);
        $stmt->execute([':category' => $category]);
        return $stmt->fetchAll();
    }

    /**
     * Zeichen nach ID abrufen
     */
    public function getSignById($signId) {
        $sql = "SELECT * FROM {$this->table} WHERE id = :id AND active = TRUE";
        $stmt = $this->db->prepare($sql);
        $stmt->execute([':id' => $signId]);
        return $stmt->fetch();
    }

    /**
     * Kategorien abrufen
     */
    public function getCategories() {
        $sql = "SELECT DISTINCT category FROM {$this->table} WHERE active = TRUE ORDER BY category";
        $stmt = $this->db->prepare($sql);
        $stmt->execute();
        return $stmt->fetchAll(PDO::FETCH_COLUMN);
    }
}
