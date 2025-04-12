<?php
require_once 'db_connection.php';

// Ödül türleri tablosuna is_system sütununu ekle
$sql = "
    DO $$
    BEGIN
        IF NOT EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name='award_types' AND column_name='is_system'
        ) THEN
            ALTER TABLE award_types ADD COLUMN is_system BOOLEAN NOT NULL DEFAULT FALSE;
        END IF;
    END
    $$;
";

$stmt = $conn->prepare($sql);
if ($stmt->execute()) {
    echo "Ödül türleri tablosuna is_system sütunu başarıyla eklendi.<br>";
} else {
    echo "Hata: is_system sütunu eklenemedi.<br>";
}

// Ödül türleri tablosuna icon sütununu ekle
$sql = "
    DO $$
    BEGIN
        IF NOT EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name='award_types' AND column_name='icon'
        ) THEN
            ALTER TABLE award_types ADD COLUMN icon VARCHAR(100);
        END IF;
    END
    $$;
";

$stmt = $conn->prepare($sql);
if ($stmt->execute()) {
    echo "Ödül türleri tablosuna icon sütunu başarıyla eklendi.<br>";
} else {
    echo "Hata: icon sütunu eklenemedi.<br>";
}

// city_awards tablosuna expiry_date (son geçerlilik tarihi) ekle
$sql = "
    DO $$
    BEGIN
        IF NOT EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name='city_awards' AND column_name='expiry_date'
        ) THEN
            ALTER TABLE city_awards ADD COLUMN expiry_date DATE;
            -- Mevcut ödüllerin son geçerlilik tarihini award_date + 1 ay olarak ayarla
            UPDATE city_awards SET expiry_date = award_date + INTERVAL '1 month';
        END IF;
    END
    $$;
";

$stmt = $conn->prepare($sql);
if ($stmt->execute()) {
    echo "Ödül tablosuna son geçerlilik tarihi (expiry_date) başarıyla eklendi.<br>";
} else {
    echo "Hata: expiry_date sütunu eklenemedi.<br>";
}

echo "<p>Tablo güncellemeleri tamamlandı. <a href='index.php?page=award_system'>Ödül Sistemi Sayfasına Dön</a></p>";
?>