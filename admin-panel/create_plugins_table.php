<?php
/**
 * Eklenti veritabanı tablosunu oluşturma betiği
 */

// Veritabanı bağlantısını dahil et
require_once 'db_connection.php';

// Tablo SQL'i
$createPluginsTableSQL = "CREATE TABLE plugins (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    version VARCHAR(20) NOT NULL,
    author VARCHAR(100),
    is_active BOOLEAN DEFAULT FALSE,
    config TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)";

// Tablo var mı kontrol et ve yoksa oluştur
function createPluginsTable($db, $sql) {
    // Tablo var mı diye kontrol et
    $checkTableSQL = "SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'plugins'
    )";
    
    try {
        $stmt = $db->prepare($checkTableSQL);
        $stmt->execute();
        $result = $stmt->get_result();
        $tableExists = $result->fetch_assoc()['exists'] ?? false;
        
        if (!$tableExists) {
            echo "Eklenti tablosu bulunamadı, oluşturuluyor...\n";
            
            $success = $db->query($sql);
            
            if (!$success) {
                echo "HATA: Eklenti tablosu oluşturulamadı: " . $db->error . "\n";
                return false;
            }
            
            echo "BAŞARILI: Eklenti tablosu oluşturuldu.\n";
            return true;
        } else {
            echo "Eklenti tablosu zaten mevcut.\n";
            return true;
        }
    } catch (Exception $e) {
        echo "HATA: Eklenti tablosu varlık kontrolünde hata: " . $e->getMessage() . "\n";
        return false;
    }
}

// Tabloyu oluştur
$result = createPluginsTable($db, $createPluginsTableSQL);

if ($result) {
    echo "İşlem tamamlandı.\n";
} else {
    echo "İşlem sırasında hata oluştu.\n";
}
?>