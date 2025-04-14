<?php
// Bu betik surveys tablosuna is_pinned sütununu ekler

// Veritabanı bağlantısını al
require_once 'db_config.php';

try {
    // Sütun var mı kontrol et
    $checkColumnQuery = "SELECT column_name 
                         FROM information_schema.columns 
                         WHERE table_name='surveys' AND column_name='is_pinned'";
    $stmt = $pdo->query($checkColumnQuery);
    $columnExists = $stmt->fetchColumn();
    
    if (!$columnExists) {
        // Sütunu ekle
        $alterQuery = "ALTER TABLE surveys ADD COLUMN is_pinned BOOLEAN DEFAULT FALSE";
        $pdo->exec($alterQuery);
        echo "is_pinned sütunu surveys tablosuna başarıyla eklendi.<br>";
    } else {
        echo "is_pinned sütunu zaten surveys tablosunda mevcut.<br>";
    }
    
    echo "İşlem tamamlandı.";
    
} catch (PDOException $e) {
    echo "Hata oluştu: " . $e->getMessage();
}
?>