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

// DATABASE_URL değerini alıp kullan (daha güvenilir yöntem)
if (isset($_ENV['DATABASE_URL']) && !empty($_ENV['DATABASE_URL'])) {
    $database_url = $_ENV['DATABASE_URL'];
} else {
    $database_url = getenv('DATABASE_URL');
}

if (empty($database_url)) {
    die("DATABASE_URL çevre değişkeni bulunamadı!");
}

// PostgreSQL sürücüsünün yüklenip yüklenmediğini kontrol et
if (!extension_loaded('pdo_pgsql')) {
    die("PostgreSQL PDO sürücüsü yüklü değil. PHP yapılandırmanızı kontrol edin.");
}

// URL'i parçalara ayır
$dbparts = parse_url($database_url);
$hostname = $dbparts['host'];
$dbname = ltrim($dbparts['path'], '/');
$username = $dbparts['user'];
$password = $dbparts['pass'];
$port = $dbparts['port'] ?? 5432;

// Manuel bağlantı oluştur
try {
    $pdo = new PDO(
        "pgsql:host=$hostname;port=$port;dbname=$dbname;sslmode=require", 
        $username, 
        $password, 
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