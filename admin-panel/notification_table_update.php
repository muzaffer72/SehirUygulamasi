<?php
/**
 * ŞikayetVar Admin Panel - Bildirim Tablosu Güncelleme
 * 
 * Bu script bildirim sistemini güncellemek için notifications tablosunu yeniden yapılandırır.
 * İki tür bildirim oluşturulacak:
 * 1. Sistem/Yönetici Bildirimleri - Yönetici tarafından oluşturulan, tüm kullanıcılara veya belirli bir bölgedeki kullanıcılara gönderilebilen
 * 2. Kullanıcı Etkileşim Bildirimleri - Beğeni, yorum vb. olaylar için otomatik oluşan bildirimler
 */

// Veritabanı bağlantısı
require_once 'includes/db_config.php';

try {
    // Yeni sütunlar ekle
    $columns_to_add = [
        "notification_type" => "ALTER TABLE notifications ADD COLUMN IF NOT EXISTS notification_type VARCHAR(20) DEFAULT 'interaction' NOT NULL",
        "scope_type" => "ALTER TABLE notifications ADD COLUMN IF NOT EXISTS scope_type VARCHAR(20) DEFAULT 'user'",
        "scope_id" => "ALTER TABLE notifications ADD COLUMN IF NOT EXISTS scope_id INTEGER DEFAULT NULL",
        "related_id" => "ALTER TABLE notifications ADD COLUMN IF NOT EXISTS related_id INTEGER DEFAULT NULL",
        "image_url" => "ALTER TABLE notifications ADD COLUMN IF NOT EXISTS image_url VARCHAR(255)",
        "action_url" => "ALTER TABLE notifications ADD COLUMN IF NOT EXISTS action_url VARCHAR(255)",
        "is_sent" => "ALTER TABLE notifications ADD COLUMN IF NOT EXISTS is_sent BOOLEAN DEFAULT FALSE"
    ];
    
    foreach ($columns_to_add as $column => $sql) {
        // Sütun var mı kontrol et
        $result = $db->query("SELECT column_name FROM information_schema.columns WHERE table_name='notifications' AND column_name='$column'");
        
        if (!$result || $result->num_rows === 0) {
            // Sütun yoksa ekle
            $db->query($sql);
            echo "$column sütunu eklendi.<br>";
        } else {
            echo "$column sütunu zaten var.<br>";
        }
    }
    
    echo "<p>Bildirim tablosu başarıyla güncellendi.</p>";
    echo "<p>notification_type değerleri: 'system' (yönetici tarafından oluşturulan), 'interaction' (kullanıcı etkileşimlerinden otomatik oluşan)</p>";
    echo "<p>scope_type değerleri: 'user', 'all', 'city', 'district'</p>";
    echo "<a href='index.php?page=notifications' class='btn btn-primary'>Bildirimler Sayfasına Dön</a>";
    
} catch (Exception $e) {
    echo "Güncelleme hatası: " . $e->getMessage();
}