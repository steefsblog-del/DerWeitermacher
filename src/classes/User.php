<?php
/**
 * Benutzer Klasse
 */

namespace RSA21\Classes;

use RSA21\Config\Database;
use PDO;

class User {
    private $db;
    private $table = 'users';

    public function __construct() {
        $this->db = Database::getInstance()->getConnection();
    }

    /**
     * Benutzer authentifizieren
     */
    public function authenticate($email, $password) {
        $sql = "SELECT * FROM {$this->table} WHERE email = :email AND status = 'active'";
        $stmt = $this->db->prepare($sql);
        $stmt->execute([':email' => $email]);
        $user = $stmt->fetch();

        if ($user && password_verify($password, $user['password_hash'])) {
            return $user;
        }
        return false;
    }

    /**
     * Benutzer registrieren
     */
    public function register($data) {
        if (empty($data['email']) || empty($data['password']) || empty($data['username'])) {
            return false;
        }

        $sql = "INSERT INTO {$this->table} 
                (username, email, firstname, lastname, company, password_hash, role, status, created_at)
                VALUES 
                (:username, :email, :firstname, :lastname, :company, :password_hash, :role, :status, NOW())";

        $stmt = $this->db->prepare($sql);
        
        return $stmt->execute([
            ':username' => $data['username'],
            ':email' => $data['email'],
            ':firstname' => $data['firstname'] ?? '',
            ':lastname' => $data['lastname'] ?? '',
            ':company' => $data['company'] ?? '',
            ':password_hash' => password_hash($data['password'], PASSWORD_BCRYPT),
            ':role' => 'user',
            ':status' => 'active'
        ]);
    }

    /**
     * Prüfe ob E-Mail bereits existiert
     */
    public function emailExists($email) {
        $sql = "SELECT id FROM {$this->table} WHERE email = :email";
        $stmt = $this->db->prepare($sql);
        $stmt->execute([':email' => $email]);
        return $stmt->fetch() !== false;
    }

    /**
     * Benutzer abrufen nach ID
     */
    public function getUserById($userId) {
        $sql = "SELECT id, username, email, firstname, lastname, company, role, created_at FROM {$this->table} WHERE id = :id";
        $stmt = $this->db->prepare($sql);
        $stmt->execute([':id' => $userId]);
        return $stmt->fetch();
    }

    /**
     * Benutzer aktualisieren
     */
    public function updateUser($userId, $data) {
        $fields = [];
        $params = [':id' => $userId];

        $allowedFields = ['username', 'firstname', 'lastname', 'company'];

        foreach ($data as $key => $value) {
            if (in_array($key, $allowedFields)) {
                $fields[] = "$key = :$key";
                $params[":$key"] = $value;
            }
        }

        if (empty($fields)) return false;

        $sql = "UPDATE {$this->table} SET " . implode(', ', $fields) . " WHERE id = :id";
        $stmt = $this->db->prepare($sql);
        return $stmt->execute($params);
    }
}
