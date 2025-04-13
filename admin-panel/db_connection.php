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
    
    public function begin_transaction() {
        return $this->pdo->beginTransaction();
    }
    
    public function commit() {
        return $this->pdo->commit();
    }
    
    public function rollback() {
        return $this->pdo->rollBack();
    }
}

class MySQLiStmtCompatWrapper {
    private $stmt;
    public $affected_rows;

    public function __construct($stmt) {
        $this->stmt = $stmt;
        $this->affected_rows = 0; // Varsayılan değer
    }

    public function bind_param($types, ...$args) {
        $paramTypes = str_split($types);
        foreach($args as $key => $value) {
            $param = $key + 1; // PDO parametre indeksleri 1'den başlar
            // paramTypes[$key] için güvenlik kontrolü ekle
            $paramType = isset($paramTypes[$key]) ? $paramTypes[$key] : 's'; // Varsayılan olarak string
            $this->stmt->bindValue($param, $value, $this->getPDOParamType($paramType));
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
        try {
            // PDO'nun execute() metodu başarılı olsa bile false döndürebilir
            // Bu yüzden sorgunun çalışıp çalışmadığını kontrol etmeliyiz
            $this->stmt->execute();
            
            // Etkilenen satır sayısını güncelle
            $this->affected_rows = $this->stmt->rowCount();
            
            // Hata var mı kontrol et
            $errorInfo = $this->stmt->errorInfo();
            if ($errorInfo[0] !== '00000') {
                error_log("PDO error in execute(): " . json_encode($errorInfo));
                return false;
            }
            
            // Debug için sorgu bilgilerini logla
            $query = $this->stmt->queryString;
            error_log("SQL query executed: $query");
            
            return true;
        } catch (Exception $e) {
            error_log("PDO execute exception: " . $e->getMessage());
            return false;
        }
    }
    
    public function error() {
        return $this->stmt->errorInfo();
    }

    public function get_result() {
        try {
            $this->stmt->execute();
            return new MySQLiResultCompatWrapper($this->stmt);
        } catch (PDOException $e) {
            // Hata oluştuğunda uygun şekilde ele al
            error_log("PDO execute exception: " . $e->getMessage());
            throw $e; // Hata fırlatmaya devam et, böylece çağıran kod tarafında ele alınabilir
        }
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

    public function fetch_all(int $resultType = null) {
        // MYSQLI_ASSOC = 1, PDO::FETCH_ASSOC = 2
        // MYSQLI_NUM = 2, PDO::FETCH_NUM = 3
        // MYSQLI_BOTH = 3, PDO::FETCH_BOTH = 4
        
        $pdoFetchMode = PDO::FETCH_ASSOC; // Varsayılan mode
        
        if ($resultType !== null) {
            // MYSQLI sabitlerini PDO sabitlerına dönüştür
            if ($resultType === 1) { // MYSQLI_ASSOC
                $pdoFetchMode = PDO::FETCH_ASSOC;
            } else if ($resultType === 2) { // MYSQLI_NUM
                $pdoFetchMode = PDO::FETCH_NUM;
            } else if ($resultType === 3) { // MYSQLI_BOTH
                $pdoFetchMode = PDO::FETCH_BOTH;
            } else {
                // Değer bilinmiyorsa varsayılan olarak ASSOC kullan
                $pdoFetchMode = PDO::FETCH_ASSOC;
            }
        }
        
        return $this->stmt->fetchAll($pdoFetchMode);
    }
}

// Bağlantıyı oluştur
$conn = new MySQLiCompatWrapper($pdo);
?>