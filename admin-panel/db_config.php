<?php
// Veritabanı bağlantı ayarları
// PostgreSQL Replit veritabanı bilgileri
$db_host = 'ep-cold-voice-a42vfzgh.us-east-1.aws.neon.tech';
$db_name = 'neondb';
$db_user = 'neondb_owner';
$db_pass = 'npg_CMhXWqZR69Pb';
$db_port = 5432;
$sslmode = 'require';

// PDO veritabanı bağlantısı oluştur
try {
    $pdo = new PDO(
        "pgsql:host=$db_host;dbname=$db_name;port=$db_port;sslmode=$sslmode", 
        $db_user, 
        $db_pass, 
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false
        ]
    );
} catch (PDOException $e) {
    die("Veritabanı bağlantı hatası: " . $e->getMessage());
}

// Uyarı mesajlarını gösterme fonksiyonu
function showAlert($message, $type = 'success') {
    return "<div class='alert alert-$type alert-dismissible fade show' role='alert'>
                $message
                <button type='button' class='btn-close' data-bs-dismiss='alert' aria-label='Close'></button>
            </div>";
}
?>