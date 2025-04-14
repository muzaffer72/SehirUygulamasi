<?php
/**
 * ŞikayetVar Admin Panel - Kategori Tablosu Güncelleme
 * 
 * Bu script categories tablosuna eksik olan yeni alanları ekler:
 * - icon: Kategori ikonu (Bootstrap Icons kodu)
 * - color: Kategori rengi (HEX kodu)
 * - is_active: Kategori aktif mi?
 * - display_order: Görüntüleme sırası
 */

// Veritabanı bağlantısı
require_once 'includes/db_config.php';

try {
    // PostgreSQL bağlantısını kontrol et
    if ($db instanceof mysqli) {
        
        // Sütunların var olup olmadığını kontrol et ve ekle
        $columns_to_add = [
            "icon" => "ALTER TABLE categories ADD COLUMN IF NOT EXISTS icon VARCHAR(100);",
            "color" => "ALTER TABLE categories ADD COLUMN IF NOT EXISTS color VARCHAR(50) DEFAULT '#1976d2';",
            "is_active" => "ALTER TABLE categories ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE;",
            "display_order" => "ALTER TABLE categories ADD COLUMN IF NOT EXISTS display_order INTEGER DEFAULT 0;"
        ];
        
        foreach ($columns_to_add as $column => $sql) {
            // Sütun var mı kontrol et
            $result = $db->query("SELECT column_name FROM information_schema.columns WHERE table_name='categories' AND column_name='$column'");
            
            if (!$result || $result->num_rows === 0) {
                // Sütun yoksa ekle
                $db->query($sql);
                echo "$column sütunu eklendi.<br>";
            } else {
                echo "$column sütunu zaten var.<br>";
            }
        }
        
        echo "<p>Kategori tablosu başarıyla güncellendi.</p>";
        echo "<a href='index.php?page=categories' class='btn btn-primary'>Kategoriler Sayfasına Dön</a>";
    } else {
        echo "Hata: Desteklenmeyen veritabanı bağlantısı. Bu script MySQL/PostgreSQL veritabanları için tasarlanmıştır.";
    }
} catch (Exception $e) {
    echo "Güncelleme hatası: " . $e->getMessage();
}