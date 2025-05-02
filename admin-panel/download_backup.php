<?php
// Oturum kontrolü
session_start();
if (!isset($_SESSION['admin_logged_in']) || $_SESSION['admin_logged_in'] !== true) {
    header('Location: index.php?page=login');
    exit;
}

// Güvenlik kontrolleri
if (!isset($_GET['file']) || empty($_GET['file'])) {
    die('Dosya belirtilmedi');
}

// Dosya adını al ve güvenli hale getir
$fileName = basename($_GET['file']);

// Dosya yolu güvenliği için sadece .sql uzantılı dosyalara izin ver
if (pathinfo($fileName, PATHINFO_EXTENSION) !== 'sql') {
    die('Yalnızca SQL dosyaları indirilebilir');
}

// Yedekleme klasörünü tanımla
$backupDir = __DIR__ . '/backups';
$filePath = $backupDir . '/' . $fileName;

// Dosyanın var olup olmadığını kontrol et
if (!file_exists($filePath)) {
    die('Dosya bulunamadı');
}

// Log dosyasına kaydet
error_log("Veritabanı yedeği indirildi: $fileName, Kullanıcı: " . ($_SESSION['admin_username'] ?? 'Bilinmeyen'));

// Dosya indirme başlıklarını ayarla
header('Content-Description: File Transfer');
header('Content-Type: application/octet-stream');
header('Content-Disposition: attachment; filename="' . $fileName . '"');
header('Content-Transfer-Encoding: binary');
header('Expires: 0');
header('Cache-Control: must-revalidate, post-check=0, pre-check=0');
header('Pragma: public');
header('Content-Length: ' . filesize($filePath));

// Çıktı tamponlamasını temizle
ob_clean();
flush();

// Dosyayı oku ve çıktıya gönder
readfile($filePath);
exit;
?>