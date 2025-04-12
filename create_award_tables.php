<?php
/**
 * Bu script, belediye ödül sistemi için gereken tabloları oluşturur.
 */

// Veritabanı bağlantısı
require __DIR__ . '/admin-panel/db_connection.php';

try {
    // İşlemlere başla
    $pdo->beginTransaction();
    
    // 1. Ödül türleri tablosunu oluştur
    echo "Ödül türleri tablosu oluşturuluyor...\n";
    $sql = "CREATE TABLE IF NOT EXISTS award_types (
        id SERIAL PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        description TEXT,
        icon VARCHAR(100),
        min_rate DECIMAL(5,2) NOT NULL,
        max_rate DECIMAL(5,2) NOT NULL,
        badge_color VARCHAR(20),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )";
    
    $pdo->exec($sql);
    echo "Ödül türleri tablosu oluşturuldu.\n";
    
    // 2. Şehir ödülleri tablosunu oluştur
    echo "Şehir ödülleri tablosu oluşturuluyor...\n";
    $sql = "CREATE TABLE IF NOT EXISTS city_awards (
        id SERIAL PRIMARY KEY,
        city_id INTEGER NOT NULL REFERENCES cities(id),
        award_type_id INTEGER NOT NULL REFERENCES award_types(id),
        award_date DATE NOT NULL DEFAULT CURRENT_DATE,
        expiry_date DATE,
        is_active BOOLEAN DEFAULT TRUE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )";
    
    $pdo->exec($sql);
    echo "Şehir ödülleri tablosu oluşturuldu.\n";
    
    // Ödül türlerini ekle (varsa silip yeniden ekle)
    echo "Ödül türleri tanımlanıyor...\n";
    $pdo->exec("DELETE FROM award_types");
    
    $awardTypes = [
        [
            'name' => 'Bronz Belediye Ödülü',
            'description' => 'Şikayet çözüm oranı %25 ile %50 arasında olan belediyeler',
            'icon' => 'bronze_medal.png',
            'min_rate' => 25,
            'max_rate' => 49.99,
            'badge_color' => '#CD7F32'
        ],
        [
            'name' => 'Gümüş Belediye Ödülü',
            'description' => 'Şikayet çözüm oranı %50 ile %75 arasında olan belediyeler',
            'icon' => 'silver_medal.png',
            'min_rate' => 50,
            'max_rate' => 74.99,
            'badge_color' => '#C0C0C0'
        ],
        [
            'name' => 'Altın Belediye Ödülü',
            'description' => 'Şikayet çözüm oranı %75 ve üzerinde olan belediyeler',
            'icon' => 'gold_medal.png',
            'min_rate' => 75,
            'max_rate' => 100,
            'badge_color' => '#FFD700'
        ]
    ];
    
    $insertSql = "INSERT INTO award_types (name, description, icon, min_rate, max_rate, badge_color) 
                  VALUES (?, ?, ?, ?, ?, ?)";
    $stmt = $pdo->prepare($insertSql);
    
    foreach ($awardTypes as $award) {
        $stmt->execute([
            $award['name'],
            $award['description'],
            $award['icon'],
            $award['min_rate'],
            $award['max_rate'],
            $award['badge_color']
        ]);
    }
    
    echo "Ödül türleri tanımlandı.\n";
    
    // İşlemleri onayla
    $pdo->commit();
    echo "İşlemler başarıyla tamamlandı.\n";
    
} catch (Exception $e) {
    // Hata durumunda geri alma
    $pdo->rollBack();
    echo "Hata oluştu: " . $e->getMessage() . "\n";
    echo "İşlemler geri alındı.\n";
}
?>