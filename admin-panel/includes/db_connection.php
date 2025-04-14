<?php
/**
 * Veritabanı bağlantısı
 * 
 * Bu dosya, PostgreSQL veritabanı bağlantısını sağlar.
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
$db_connection = pg_connect($connection_string);

// Bağlantı kontrolü
if (!$db_connection) {
    // Hata durumunda log kaydı oluştur ve kullanıcıya genel bir hata göster
    error_log("PostgreSQL bağlantı hatası: " . pg_last_error());
    die("Veritabanına bağlanırken bir hata oluştu. Lütfen daha sonra tekrar deneyin.");
}

// Bağlantı bilgilerini logla (sadece geliştirme ortamında)
if (getenv('APP_ENV') !== 'production') {
    error_log("PostgreSQL bağlantısı: Host={$db_host} DB={$db_name} User={$db_user} Port={$db_port}");
}

// UTF-8 karakter seti kullanımı için
pg_query($db_connection, "SET NAMES 'UTF8'");
?>