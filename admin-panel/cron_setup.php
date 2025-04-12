<?php
// Bu dosya, otomatik ödül kontrolü için günlük cron job ayarlar

// Günlük çalışacak cron job komutu
$scriptPath = __DIR__ . '/auto_award_checker.php';
$logPath = __DIR__ . '/cron_logs/award_checker_log_' . date('Ymd') . '.log';

// Cron logs dizinini oluştur
if (!file_exists(__DIR__ . '/cron_logs')) {
    mkdir(__DIR__ . '/cron_logs', 0755, true);
}

// Cron job komutu
$cronCommand = "0 0 * * * php $scriptPath > $logPath 2>&1";

// Mevcut cron işlerini al
exec('crontab -l', $currentCronJobs, $returnCode);

// Hata kontrolü
if ($returnCode !== 0) {
    // Muhtemelen crontab boş, yeni bir liste oluştur
    $currentCronJobs = [];
}

// Ödül kontrolü için cron kaydı var mı kontrol et
$awardCheckerExists = false;
foreach ($currentCronJobs as $job) {
    if (strpos($job, 'auto_award_checker.php') !== false) {
        $awardCheckerExists = true;
        break;
    }
}

// Eğer mevcut değilse ekle
if (!$awardCheckerExists) {
    $currentCronJobs[] = $cronCommand;
    $newCronJobs = implode("\n", $currentCronJobs);
    
    // Geçici bir dosyaya yaz
    $tempFile = tempnam(sys_get_temp_dir(), 'cron');
    file_put_contents($tempFile, $newCronJobs . "\n");
    
    // Crontab'a yükle
    exec('crontab ' . $tempFile, $output, $returnCode);
    unlink($tempFile);
    
    if ($returnCode === 0) {
        echo "Otomatik ödül kontrolü için cron job başarıyla eklendi.<br>";
        echo "Komut: " . $cronCommand . "<br>";
    } else {
        echo "Cron job eklenirken hata oluştu. Kod: " . $returnCode . "<br>";
        echo "Çıktı: " . implode("<br>", $output) . "<br>";
    }
} else {
    echo "Otomatik ödül kontrolü için cron job zaten eklenmiş.<br>";
}

echo "<p>Günlük otomatik ödül kontrolü cron job kurulumu tamamlandı.</p>";
echo "<p><a href='index.php?page=award_system'>Ödül Sistemi Sayfasına Dön</a></p>";
?>