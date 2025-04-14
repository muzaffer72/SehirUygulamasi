<?php
/**
 * Database connection wrapper
 * Uses PostgreSQL for database operations
 */

// Veritabanı yapılandırma bilgileri
$db_host = getenv('PGHOST') ?: 'localhost';
$db_port = getenv('PGPORT') ?: '5432';
$db_name = getenv('PGDATABASE') ?: 'neondb';
$db_user = getenv('PGUSER') ?: 'neondb_owner';
$db_password = getenv('PGPASSWORD') ?: '';

// Bağlantı dizesi
$connection_string = "host={$db_host} port={$db_port} dbname={$db_name} user={$db_user} password={$db_password}";

// PostgreSQL bağlantısı
$conn = pg_connect($connection_string);

// Bağlantı kontrolü
if (!$conn) {
    // Hata durumunda log kaydı oluştur ve kullanıcıya genel bir hata göster
    error_log("PostgreSQL bağlantı hatası: " . pg_last_error());
    die("Veritabanına bağlanırken bir hata oluştu. Lütfen daha sonra tekrar deneyin.");
}

// Bağlantı bilgilerini logla (sadece geliştirme ortamında)
error_log("PostgreSQL bağlantısı: Host={$db_host} DB={$db_name} User={$db_user} Port={$db_port}");

// UTF-8 karakter seti kullanımı için
pg_query($conn, "SET NAMES 'UTF8'");

/**
 * MySQLi compatibility wrapper for PostgreSQL
 * This class provides basic MySQLi-like functions for PostgreSQL
 */
class MySQLiCompatWrapper {
    private $conn;
    
    public function __construct($pgConn) {
        $this->conn = $pgConn;
    }
    
    public function query($sql) {
        // MySQL'den PostgreSQL'e SQL çevirisi
        $sql = $this->convertMySQLtoPgSQL($sql);
        
        $result = pg_query($this->conn, $sql);
        if (!$result) {
            error_log("SQL Hatası: " . pg_last_error($this->conn) . " - Sorgu: " . $sql);
            return false;
        }
        
        return new PgSQLResult($result);
    }
    
    public function prepare($sql) {
        // PostgreSQL parametre biçimine çevir (? yerine $1, $2, ...)
        $sql = preg_replace_callback('/\?/', function($matches) {
            static $count = 0;
            $count++;
            return '$' . $count;
        }, $sql);
        
        // MySQL'den PostgreSQL'e SQL çevirisi
        $sql = $this->convertMySQLtoPgSQL($sql);
        
        return new PgSQLStatement($this->conn, $sql);
    }
    
    public function real_escape_string($string) {
        return pg_escape_string($this->conn, $string);
    }
    
    public function escape_string($string) {
        return $this->real_escape_string($string);
    }
    
    public function insert_id() {
        $result = pg_query($this->conn, "SELECT lastval()");
        if (!$result) return 0;
        
        $row = pg_fetch_row($result);
        return $row[0] ?? 0;
    }
    
    public function affected_rows() {
        return pg_affected_rows($this->conn);
    }
    
    public function error() {
        return pg_last_error($this->conn);
    }
    
    public function close() {
        return pg_close($this->conn);
    }
    
    private function convertMySQLtoPgSQL($sql) {
        // MySQL özel fonksiyonları PostgreSQL'e çevir
        $replacements = [
            'IFNULL' => 'COALESCE',
            'NOW()' => 'NOW()',
            'CURDATE()' => 'CURRENT_DATE',
            'SUBSTR' => 'SUBSTRING',
            'CONCAT' => 'CONCAT',
            'LIMIT ?, ?' => 'LIMIT ? OFFSET ?'
        ];
        
        foreach ($replacements as $search => $replace) {
            $sql = str_ireplace($search, $replace, $sql);
        }
        
        return $sql;
    }
}

// Compatibility result set wrapper
class PgSQLResult {
    private $result;
    private $currentRow = 0;
    
    public function __construct($pgResult) {
        $this->result = $pgResult;
    }
    
    public function fetch_assoc() {
        return pg_fetch_assoc($this->result);
    }
    
    public function fetch_array($resultType = PGSQL_BOTH) {
        return pg_fetch_array($this->result, null, $resultType);
    }
    
    public function fetch_row() {
        return pg_fetch_row($this->result);
    }
    
    public function num_rows() {
        return pg_num_rows($this->result);
    }
    
    public function free() {
        return pg_free_result($this->result);
    }
}

// Compatibility prepared statement wrapper
class PgSQLStatement {
    private $conn;
    private $sql;
    private $params = [];
    private $result;
    private $statementName;
    
    public function __construct($pgConn, $sql) {
        $this->conn = $pgConn;
        $this->sql = $sql;
        $this->statementName = 'stmt_' . md5($sql . microtime());
    }
    
    public function bind_param($types, ...$params) {
        $this->params = $params;
        return true;
    }
    
    public function execute() {
        $this->result = pg_query_params($this->conn, $this->sql, $this->params);
        return $this->result !== false;
    }
    
    public function get_result() {
        if (!$this->result) return false;
        return new PgSQLResult($this->result);
    }
    
    public function close() {
        if ($this->result) {
            pg_free_result($this->result);
            $this->result = null;
        }
        return true;
    }
}

// MySQLi uyumlu sınıfımızı oluştur
$db = new MySQLiCompatWrapper($conn);
?>