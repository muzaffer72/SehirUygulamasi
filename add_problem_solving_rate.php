<?php
/**
 * Bu script, cities ve districts tablolarına problem_solving_rate sütununu ekler.
 * Eğer sütun zaten varsa, işlemi atlar.
 */

// Veritabanı bağlantısı
require __DIR__ . '/admin-panel/db_connection.php';

try {
    // İşlemlere başla
    $pdo->beginTransaction();
    
    // Şehirler tablosuna problem_solving_rate sütunu ekleme
    echo "cities tablosuna problem_solving_rate sütunu ekleniyor...\n";
    $sql = "DO $$
    BEGIN
        BEGIN
            ALTER TABLE cities ADD COLUMN problem_solving_rate DECIMAL(5,2) DEFAULT 0;
        EXCEPTION
            WHEN duplicate_column THEN
                RAISE NOTICE 'problem_solving_rate sütunu zaten var.';
        END;
    END $$;";
    
    $pdo->exec($sql);
    echo "cities tablosuna problem_solving_rate sütunu eklendi.\n";
    
    // İlçeler tablosuna problem_solving_rate sütunu ekleme
    echo "districts tablosuna problem_solving_rate sütunu ekleniyor...\n";
    $sql = "DO $$
    BEGIN
        BEGIN
            ALTER TABLE districts ADD COLUMN problem_solving_rate DECIMAL(5,2) DEFAULT 0;
        EXCEPTION
            WHEN duplicate_column THEN
                RAISE NOTICE 'problem_solving_rate sütunu zaten var.';
        END;
    END $$;";
    
    $pdo->exec($sql);
    echo "districts tablosuna problem_solving_rate sütunu eklendi.\n";
    
    // Bazı rastgele değerler atama (test amaçlı)
    echo "Şehirlere rastgele problem çözüm oranları atanıyor...\n";
    $sql = "UPDATE cities SET problem_solving_rate = FLOOR(RANDOM() * 100)::decimal / 100 * 100;";
    $pdo->exec($sql);
    
    echo "İlçelere rastgele problem çözüm oranları atanıyor...\n";
    $sql = "UPDATE districts SET problem_solving_rate = FLOOR(RANDOM() * 100)::decimal / 100 * 100;";
    $pdo->exec($sql);
    
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