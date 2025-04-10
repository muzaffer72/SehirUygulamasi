<?php
// PostgreSQL veritabanı bağlantı dosyası
// PDO bağlantısını ve mysqli benzeri bir wrapper sağlar

require_once 'db_config.php';

// PDO bağlantısını mysqli benzeri bir wrapper'a dönüştür
class MySQLiCompatWrapper {
    private $pdo;
    public $error;

    public function __construct($pdo) {
        $this->pdo = $pdo;
    }

    public function prepare($query) {
        $stmt = $this->pdo->prepare($query);
        return new MySQLiStmtCompatWrapper($stmt);
    }

    public function query($query) {
        $stmt = $this->pdo->query($query);
        return new MySQLiResultCompatWrapper($stmt);
    }
}

class MySQLiStmtCompatWrapper {
    private $stmt;

    public function __construct($stmt) {
        $this->stmt = $stmt;
    }

    public function bind_param($types, ...$args) {
        $paramTypes = str_split($types);
        foreach($args as $key => $value) {
            $param = $key + 1; // PDO parametre indeksleri 1'den başlar
            $this->stmt->bindValue($param, $value, $this->getPDOParamType($paramTypes[$key]));
        }
        return true;
    }

    private function getPDOParamType($type) {
        switch($type) {
            case 'i': return PDO::PARAM_INT;
            case 'd': return PDO::PARAM_STR;
            case 'b': return PDO::PARAM_LOB;
            default: return PDO::PARAM_STR;
        }
    }

    public function execute() {
        return $this->stmt->execute();
    }

    public function get_result() {
        $this->stmt->execute();
        return new MySQLiResultCompatWrapper($this->stmt);
    }
}

class MySQLiResultCompatWrapper {
    private $stmt;
    public $num_rows;

    public function __construct($stmt) {
        $this->stmt = $stmt;
        // num_rows için rowCount() kullanılabilir, fakat tam eşdeğer değil
        $this->num_rows = $stmt->rowCount();
    }

    public function fetch_assoc() {
        return $this->stmt->fetch(PDO::FETCH_ASSOC);
    }

    public function fetch_all(int $resultType = PDO::FETCH_ASSOC) {
        return $this->stmt->fetchAll($resultType);
    }
}

// Bağlantıyı oluştur
$conn = new MySQLiCompatWrapper($pdo);
?>