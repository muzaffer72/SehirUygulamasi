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

// PGHOST ve diğer Postgres değişkenlerini kullan (Replit için daha güvenilir)
$hostname = getenv('PGHOST') ?: 'ep-cold-voice-a42vfzgh.us-east-1.aws.neon.tech';
$dbname = getenv('PGDATABASE') ?: 'neondb';
$username = getenv('PGUSER') ?: 'neondb_owner';
$password = getenv('PGPASSWORD') ?: '';
$port = getenv('PGPORT') ?: 5432;

// PostgreSQL sürücüsünün yüklenip yüklenmediğini kontrol et
if (!extension_loaded('pdo_pgsql')) {
    die("PostgreSQL PDO sürücüsü yüklü değil. PHP yapılandırmanızı kontrol edin.");
}

// Bağlantı bilgilerini gösterme, API çağrılarında JSON yanıtı bozuyor
// Hata ayıklama için gerekirse error_log() kullanın
error_log("PostgreSQL bağlantısı: Host=$hostname DB=$dbname User=$username Port=$port");

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