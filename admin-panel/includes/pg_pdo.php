<?php
/**
 * PostgreSQL PDO bağlantısı için yardımcı fonksiyon
 * MySQLi uyumluluk katmanını kullanmak yerine PDO kullanmak isteyen
 * API işlevleri için PDO bağlantısı sağlar
 */

function get_pdo_connection() {
    // Veritabanı ayarlarını al
    $db_host = getenv('PGHOST') ?: 'localhost';
    $db_port = getenv('PGPORT') ?: '5432';
    $db_name = getenv('PGDATABASE') ?: 'neondb';
    $db_user = getenv('PGUSER') ?: 'neondb_owner';
    $db_password = getenv('PGPASSWORD') ?: '';
    
    // Veritabanı DSN'i oluştur
    $dsn = "pgsql:host={$db_host};port={$db_port};dbname={$db_name};";
    
    // Bağlantı seçenekleri
    $options = [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false,
    ];
    
    // PDO bağlantısını oluştur ve döndür
    try {
        $pdo = new PDO($dsn, $db_user, $db_password, $options);
        $pdo->exec("SET NAMES 'UTF8'");
        return $pdo;
    } catch (PDOException $e) {
        error_log("PDO Connection Error: " . $e->getMessage());
        die("Database connection failed: " . $e->getMessage());
    }
}
?>