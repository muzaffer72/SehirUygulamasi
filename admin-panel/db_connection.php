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
    
    // Transaction metotları
    public function begin_transaction() {
        return pg_query($this->conn, "BEGIN");
    }
    
    public function commit() {
        return pg_query($this->conn, "COMMIT");
    }
    
    public function rollback() {
        return pg_query($this->conn, "ROLLBACK");
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

// Uygulama başlatıldığında önemli tabloların durumunu otomatik kontrol edelim
// Sadece API isteklerinde ve ajax çağrılarında tablo kontrolü pas geçelim
$isApiRequest = strpos($_SERVER['REQUEST_URI'] ?? '', '/api.php') !== false;
$isAjaxRequest = !empty($_SERVER['HTTP_X_REQUESTED_WITH']) && strtolower($_SERVER['HTTP_X_REQUESTED_WITH']) == 'xmlhttprequest';
$isCommandLine = php_sapi_name() === 'cli';

// Aşağıdaki durumlarda tablo kontrolü yapma:
// 1. API çağrısı ise
// 2. AJAX isteği ise
// 3. Komut satırından çalıştırılıyorsa
// 4. Test modu aktifse (SKIP_TABLE_CHECK sabit değişkeni tanımlanmışsa)
// 5. $_GET['quick_api'] parametresi gönderilmişse (hızlı API çağrıları için)
if (!$isApiRequest && !$isAjaxRequest && !$isCommandLine && !defined('SKIP_TABLE_CHECK') && empty($_GET['quick_api'])) {
    // İlk kez çağrılıyorsa zaten dahil edilmiş olacak
    if (!function_exists('ensureCoreTables')) {
        $dbUtilsPath = __DIR__ . '/db_utils.php';
        if (file_exists($dbUtilsPath)) {
            try {
                require_once($dbUtilsPath);
                
                // Temel tabloları kontrol et
                if (function_exists('ensureCoreTables')) {
                    // Potansiyel uzun sürebilecek işlemler için, isteği sonlandırma süresini arttır
                    set_time_limit(120); // 2 dakika
                    
                    // Güvenlik için, DROP, DELETE gibi yıkıcı SQL komutları engelle
                    if (defined('DB_SAFE_MODE') && constant('DB_SAFE_MODE') === true) {
                        error_log("Veritabanı Güvenlik Modu: AÇIK - Tablo kontrolü yapılıyor (sadece ekleme)");
                    }
                    
                    // Temel tabloları kontrol et
                    $results = ensureCoreTables($db);
                    
                    // Başarılı sonuç loglaması - debug
                    $createdTables = array_keys(array_filter($results));
                    if (count($createdTables) > 0) {
                        error_log("Veritabanı tabloları otomatik olarak oluşturuldu: " . implode(', ', $createdTables));
                    } else {
                        error_log("Veritabanı tabloları kontrol edildi, tüm tablolar mevcut.");
                    }
                }
            } catch (Exception $e) {
                error_log("VERİTABANI HATA: Tablo kontrolünde ciddi bir hata: " . $e->getMessage());
                // Kritik hatayı bildirmek için log dosyasına detaylı bilgi yaz
                error_log("Hata Yığını: " . $e->getTraceAsString());
            }
        } else {
            error_log("UYARI: db_utils.php dosyası bulunamadı, tablo kontrolleri yapılamadı.");
        }
    }
}

// PostgreSQL ping ile bağlantıyı kontrol et
function pg_connection_is_alive($conn) {
    if (!$conn) return false;
    
    try {
        $result = pg_query($conn, "SELECT 1");
        return $result !== false;
    } catch (Exception $e) {
        error_log("Bağlantı kontrolünde hata: " . $e->getMessage());
        return false;
    }
}
?>