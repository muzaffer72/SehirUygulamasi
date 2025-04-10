<?php
// Veritabanı bağlantı ayarları
// PostgreSQL Replit veritabanı bilgileri - .env dosyasından alınıyor
// Çalışmazsa manuel olarak bilgilerinizi girin
$env_file = dirname(__DIR__) . '/.env';
if (file_exists($env_file)) {
    $env_lines = file($env_file, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach($env_lines as $line) {
        if (strpos($line, '=') !== false) {
            list($key, $value) = explode('=', $line, 2);
            $key = trim($key);
            $value = trim($value);
            $_ENV[$key] = $value;
        }
    }
}

// Eğer PGHOST değişkeni tanımlıysa bunları kullan
if (isset($_ENV['PGHOST'])) {
    $db_host = $_ENV['PGHOST'];
    $db_name = $_ENV['PGDATABASE'];
    $db_user = $_ENV['PGUSER'];
    $db_pass = $_ENV['PGPASSWORD'];
    $db_port = $_ENV['PGPORT'];
    $sslmode = 'prefer';
} else {
    // Varsayılan bağlantı bilgileri
    $db_host = getenv('PGHOST');
    $db_name = getenv('PGDATABASE');
    $db_user = getenv('PGUSER');
    $db_pass = getenv('PGPASSWORD');
    $db_port = getenv('PGPORT') ?: 5432;
    $sslmode = 'prefer';
}

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