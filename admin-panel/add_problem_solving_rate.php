<?php
// cities tablosuna problem_solving_rate sütunu ekleyen script

// Veritabanı bağlantısını dahil et
require_once 'db_connection.php';

// Hata raporlamasını etkinleştir
error_reporting(E_ALL);
ini_set('display_errors', 1);

try {
    // Sütunun mevcut olup olmadığını kontrol et
    $checkQuery = $pdo->query("
        SELECT column_name 
        FROM information_schema.columns 
        WHERE table_name = 'cities' AND column_name = 'problem_solving_rate'
    ");
    
    $columnExists = $checkQuery->fetch(PDO::FETCH_ASSOC);
    
    if (!$columnExists) {
        // Sütun yoksa ekle
        $pdo->exec("
            ALTER TABLE cities 
            ADD COLUMN problem_solving_rate DECIMAL(5,2) DEFAULT 0.00
        ");
        
        echo "problem_solving_rate sütunu başarıyla eklendi.<br>";
        
        // Örnek değerleri güncelle
        $pdo->exec("
            UPDATE cities 
            SET problem_solving_rate = ROUND(RANDOM() * 100, 2)
            WHERE problem_solving_rate = 0 OR problem_solving_rate IS NULL
        ");
        
        echo "Şehirlerin çözüm oranları başarıyla güncellendi.<br>";
    } else {
        echo "problem_solving_rate sütunu zaten mevcut.<br>";
    }
    
    // İşlem başarılı
    echo "İşlem tamamlandı.";
    
} catch (PDOException $e) {
    // Hata durumunda
    echo "Hata: " . $e->getMessage();
}