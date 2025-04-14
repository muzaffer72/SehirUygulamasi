<?php
// Hata raporlama ayarlarını devre dışı bırak
require_once '../php_error_config.php';

// Bu dosya sunucu bilgilerini görüntülemek için kullanılır
// SADECE hata ayıklama amaçlıdır, production'da KALDIRILMALIDIR

echo "<h1>PHP ve Sunucu Bilgileri</h1>";
echo "<p>PHP Sürümü: " . phpversion() . "</p>";

echo "<h2>Yüklü PHP Uzantıları</h2>";
echo "<pre>";
print_r(get_loaded_extensions());
echo "</pre>";

echo "<h2>PDO Sürücüleri</h2>";
echo "<pre>";
print_r(PDO::getAvailableDrivers());
echo "</pre>";

echo "<h2>PHP Bilgileri</h2>";
phpinfo();
?>