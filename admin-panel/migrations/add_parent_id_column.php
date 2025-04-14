<?php
// Veritabanı bağlantısı ve konfigürasyon
require_once __DIR__ . '/../config/config.php';
require_once __DIR__ . '/../includes/db.php';

try {
    // PostgreSQL için parent_id sütununu ekle (eğer yoksa)
    $addColumnQuery = "
        DO $$
        BEGIN
            BEGIN
                ALTER TABLE comments ADD COLUMN parent_id INTEGER DEFAULT NULL;
            EXCEPTION
                WHEN duplicate_column THEN
                    -- sütun zaten var, herhangi bir şey yapma
            END;
            
            BEGIN
                ALTER TABLE comments ADD COLUMN is_anonymous BOOLEAN DEFAULT FALSE;
            EXCEPTION
                WHEN duplicate_column THEN
                    -- sütun zaten var, herhangi bir şey yapma
            END;
        END
        $$;
    ";
    
    $result = $pdo->exec($addColumnQuery);
    echo "Sütunlar başarıyla eklendi veya zaten mevcutlar.";
} catch (PDOException $e) {
    echo "Hata: " . $e->getMessage();
}
?>