<?php
// Hata raporlama ayarlarını aç (tanılama için)
error_reporting(E_ALL);
ini_set('display_errors', 1);

echo "<h1>ŞikayetVar Admin Panel Tanılama Aracı</h1>";

// 1. PHP Sürümü ve Uzantıları Kontrol Et
echo "<h2>1. PHP Sürüm Kontrolü</h2>";
echo "PHP Sürümü: " . phpversion() . "<br>";
echo "Gerekli: PHP 7.4 veya üzeri<br>";
if (version_compare(phpversion(), '7.4.0', '>=')) {
    echo "<span style='color:green'>✓ PHP sürümü uyumlu</span><br>";
} else {
    echo "<span style='color:red'>✗ PHP sürümü çok düşük. PHP 7.4 veya üzeri gerekli!</span><br>";
}

// 2. Gerekli PHP Uzantıları
echo "<h2>2. PHP Uzantıları</h2>";
$required_extensions = ['pdo', 'pdo_pgsql', 'json', 'mbstring'];
$missing_extensions = [];

foreach ($required_extensions as $ext) {
    if (extension_loaded($ext)) {
        echo "<span style='color:green'>✓ $ext yüklü</span><br>";
    } else {
        echo "<span style='color:red'>✗ $ext yüklü değil</span><br>";
        $missing_extensions[] = $ext;
    }
}

if (!empty($missing_extensions)) {
    echo "<p><strong>Eksik uzantıları yüklemek için:</strong></p>";
    echo "<code>sudo apt-get install php-" . implode(" php-", $missing_extensions) . "</code><br>";
    echo "<p>Yükleme sonrası PHP'yi yeniden başlatın: <code>sudo service php8.1-fpm restart</code> (veya sunucunuzdaki PHP sürümüne göre)</p>";
}

// 3. Veritabanı Bağlantı Testi
echo "<h2>3. Veritabanı Bağlantı Testi</h2>";
require_once 'db_config.php';

try {
    // PDO Bağlantısı
    echo "Host: $hostname<br>";
    echo "Port: $port<br>";
    echo "Database: $dbname<br>";
    echo "User: $username<br>";
    
    $dsn = "pgsql:host=$hostname;port=$port;dbname=$dbname;sslmode=require";
    $testPdo = new PDO($dsn, $username, $password);
    
    echo "<span style='color:green'>✓ PDO Veritabanı bağlantısı başarılı</span><br>";
    
    // Örnek sorgu çalıştır
    echo "<h3>Örnek Sorgu Testleri:</h3>";
    
    // Tablo listesini kontrol et
    $stmt = $testPdo->query("SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'");
    $tables = $stmt->fetchAll(PDO::FETCH_COLUMN);
    
    echo "<p>Veritabanındaki tablolar:</p>";
    echo "<ul>";
    foreach ($tables as $table) {
        echo "<li>$table</li>";
    }
    echo "</ul>";
    
    // Yorumlar tablosunu kontrol et
    if (in_array('comments', $tables)) {
        echo "<span style='color:green'>✓ comments tablosu mevcut</span><br>";
        // Yorumlar tablosundaki sütunları göster
        $stmt = $testPdo->query("SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'comments'");
        $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        echo "<p>comments tablosu sütunları:</p>";
        echo "<ul>";
        foreach ($columns as $column) {
            echo "<li>{$column['column_name']} ({$column['data_type']})</li>";
        }
        echo "</ul>";
        
        // Yorum sayısını kontrol et
        $stmt = $testPdo->query("SELECT COUNT(*) FROM comments");
        $commentCount = $stmt->fetchColumn();
        echo "<p>Toplam yorum sayısı: $commentCount</p>";
    } else {
        echo "<span style='color:red'>✗ comments tablosu bulunamadı!</span><br>";
    }
    
} catch (PDOException $e) {
    echo "<span style='color:red'>✗ Veritabanı bağlantı hatası: " . $e->getMessage() . "</span><br>";
}

// 4. MySQLiCompatWrapper Test
echo "<h2>4. MySQLiCompatWrapper Test</h2>";
try {
    require_once 'db_connection.php';
    echo "<span style='color:green'>✓ MySQLiCompatWrapper başarıyla yüklendi</span><br>";
    
    // Test sorgusu çalıştır
    $test_result = $conn->query("SELECT COUNT(*) as count FROM comments");
    if ($test_result) {
        $row = $test_result->fetch_assoc();
        echo "<span style='color:green'>✓ Wrapper ile sorgu çalıştı, yorum sayısı: " . $row['count'] . "</span><br>";
    } else {
        echo "<span style='color:red'>✗ Wrapper sorgusu çalışmadı</span><br>";
    }
} catch (Exception $e) {
    echo "<span style='color:red'>✗ MySQLiCompatWrapper hatası: " . $e->getMessage() . "</span><br>";
}

// 5. API Endpoint Testi
echo "<h2>5. API Endpoint Testleri</h2>";

$endpoints = [
    ['url' => '/api/cities', 'method' => 'GET', 'description' => 'Şehirleri listele'],
    ['url' => '/api/parties', 'method' => 'GET', 'description' => 'Partileri listele'],
    ['url' => '/api/comments?post_id=1', 'method' => 'GET', 'description' => 'Yorumları getir (post_id=1)']
];

echo "<p>API endpoint'lerini test etmek için aşağıdaki bağlantıları kullanın:</p>";
echo "<ul>";
foreach ($endpoints as $endpoint) {
    $full_url = "http://" . $_SERVER['HTTP_HOST'] . $endpoint['url'];
    echo "<li><a href='$full_url' target='_blank'>{$endpoint['method']} {$endpoint['url']}</a> - {$endpoint['description']}</li>";
}
echo "</ul>";

// 6. Laravel/PHP Artisan ile ilgili notlar
echo "<h2>6. Laravel/PHP Artisan Notları</h2>";
echo "<p>Bu uygulama Laravel tabanlı değildir, bu nedenle <code>php artisan</code> komutları kullanılamaz.</p>";
echo "<p>Veritabanı işlemleri için özel PHP betikleri kullanılmaktadır.</p>";

// 7. Öneriler
echo "<h2>7. Öneriler ve Çözüm Yolları</h2>";
echo "<ol>";
echo "<li>Tüm PHP uzantılarının yüklü ve çalışır durumda olduğundan emin olun.</li>";
echo "<li>PostgreSQL veritabanı bağlantı bilgilerinin doğru olduğunu kontrol edin.</li>";
echo "<li>Sorgu hataları yaşıyorsanız, db_connection.php dosyasındaki MySQL-PostgreSQL uyumluluk katmanını kontrol edin.</li>";
echo "<li>PHP hata günlüklerini inceleyin: <code>tail -f /var/log/apache2/error.log</code> veya <code>tail -f /var/log/nginx/error.log</code></li>";
echo "<li>Tüm API endpoint'lerini tarayıcıda test edin ve yanıtları kontrol edin.</li>";
echo "</ol>";

echo "<p style='margin-top:20px;'><strong>Not:</strong> Bu tanılama sonuçlarını daha detaylı analiz için kaydedebilirsiniz.</p>";
?>