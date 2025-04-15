<?php

// Veritabanı bağlantısını al
require_once 'admin-panel/db_connection.php';

try {
    // `satisfaction_rating` sütununu ekle
    $query = "ALTER TABLE posts ADD COLUMN IF NOT EXISTS satisfaction_rating INTEGER;";
    $result = pg_query($conn, $query);
    
    if (!$result) {
        throw new Exception("Sütun eklenirken hata: " . pg_last_error($conn));
    }
    
    echo "satisfaction_rating sütunu başarıyla eklendi veya zaten vardı.\n";
    
    // before_after_records tablosunu oluştur
    $create_table_query = "
    CREATE TABLE IF NOT EXISTS before_after_records (
        id SERIAL PRIMARY KEY,
        post_id INTEGER NOT NULL,
        before_image_url TEXT NOT NULL,
        after_image_url TEXT NOT NULL,
        description TEXT,
        recorded_by INTEGER,
        record_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
        FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
        FOREIGN KEY (recorded_by) REFERENCES users(id)
    );";
    
    $create_result = pg_query($conn, $create_table_query);
    
    if (!$create_result) {
        throw new Exception("Tablo oluşturulurken hata: " . pg_last_error($conn));
    }
    
    echo "before_after_records tablosu başarıyla oluşturuldu veya zaten vardı.\n";
    
    echo "İşlem başarıyla tamamlandı!\n";
} catch (Exception $e) {
    echo "Hata: " . $e->getMessage() . "\n";
}
?>