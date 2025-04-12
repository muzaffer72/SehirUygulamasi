<?php
/**
 * Bu script, award_types tablosuna eksik sütunları ekler.
 */

// Veritabanı bağlantısı
require __DIR__ . '/admin-panel/db_connection.php';

try {
    // İşlemlere başla
    $pdo->beginTransaction();
    
    // min_rate ve max_rate sütunlarını ekle
    echo "award_types tablosuna min_rate ve max_rate sütunları ekleniyor...\n";
    $sql = "DO $$
    BEGIN
        BEGIN
            ALTER TABLE award_types ADD COLUMN min_rate DECIMAL(5,2) DEFAULT 0;
        EXCEPTION
            WHEN duplicate_column THEN
                RAISE NOTICE 'min_rate sütunu zaten var.';
        END;
        
        BEGIN
            ALTER TABLE award_types ADD COLUMN max_rate DECIMAL(5,2) DEFAULT 100;
        EXCEPTION
            WHEN duplicate_column THEN
                RAISE NOTICE 'max_rate sütunu zaten var.';
        END;
        
        BEGIN
            ALTER TABLE award_types ADD COLUMN badge_color VARCHAR(20);
        EXCEPTION
            WHEN duplicate_column THEN
                RAISE NOTICE 'badge_color sütunu zaten var.';
        END;
    END $$;";
    
    $pdo->exec($sql);
    echo "Sütunlar eklendi.\n";
    
    // Ödül türlerini ekle (varsa silip yeniden ekle)
    echo "Ödül türleri tanımlanıyor...\n";
    $pdo->exec("TRUNCATE TABLE award_types CASCADE");
    
    $awardTypes = [
        [
            'name' => 'Bronz Belediye Ödülü',
            'description' => 'Şikayet çözüm oranı %25 ile %50 arasında olan belediyeler',
            'icon' => 'bronze_medal.png',
            'min_rate' => 25,
            'max_rate' => 49.99,
            'badge_color' => '#CD7F32',
            'color' => '#CD7F32',
            'points' => 100
        ],
        [
            'name' => 'Gümüş Belediye Ödülü',
            'description' => 'Şikayet çözüm oranı %50 ile %75 arasında olan belediyeler',
            'icon' => 'silver_medal.png',
            'min_rate' => 50,
            'max_rate' => 74.99,
            'badge_color' => '#C0C0C0',
            'color' => '#C0C0C0',
            'points' => 200
        ],
        [
            'name' => 'Altın Belediye Ödülü',
            'description' => 'Şikayet çözüm oranı %75 ve üzerinde olan belediyeler',
            'icon' => 'gold_medal.png',
            'min_rate' => 75,
            'max_rate' => 100,
            'badge_color' => '#FFD700',
            'color' => '#FFD700',
            'points' => 300
        ]
    ];
    
    $insertSql = "INSERT INTO award_types (name, description, icon, min_rate, max_rate, badge_color, color, points) 
                  VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
    $stmt = $pdo->prepare($insertSql);
    
    foreach ($awardTypes as $award) {
        $stmt->execute([
            $award['name'],
            $award['description'],
            $award['icon'],
            $award['min_rate'],
            $award['max_rate'],
            $award['badge_color'],
            $award['color'],
            $award['points']
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