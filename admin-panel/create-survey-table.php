<?php
/**
 * ŞikayetVar Admin Panel - Anket Tablosu Oluşturma
 */

// Veritabanı bağlantısı
require_once 'db_connection.php';

// PostgreSQL için tablo yapısı oluşturma
try {
    // Anketler tablosu
    $pdo->exec("DROP TABLE IF EXISTS surveys CASCADE");
    
    $pdo->exec("CREATE TABLE surveys (
        id SERIAL PRIMARY KEY,
        title VARCHAR(255) NOT NULL,
        short_title VARCHAR(100) NOT NULL,
        description TEXT NOT NULL,
        category_id INTEGER NOT NULL,
        scope_type VARCHAR(20) NOT NULL,
        city_id INTEGER,
        district_id INTEGER,
        start_date DATE NOT NULL,
        end_date DATE NOT NULL,
        total_users INTEGER NOT NULL DEFAULT 1000,
        is_active BOOLEAN NOT NULL DEFAULT TRUE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )");
    
    // Anket seçenekleri tablosu
    $pdo->exec("DROP TABLE IF EXISTS survey_options CASCADE");
    
    $pdo->exec("CREATE TABLE survey_options (
        id SERIAL PRIMARY KEY,
        survey_id INTEGER NOT NULL,
        text VARCHAR(255) NOT NULL,
        vote_count INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (survey_id) REFERENCES surveys(id) ON DELETE CASCADE
    )");
    
    // Bölgesel anket sonuçları tablosu
    $pdo->exec("DROP TABLE IF EXISTS survey_regional_results CASCADE");
    
    $pdo->exec("CREATE TABLE survey_regional_results (
        id SERIAL PRIMARY KEY,
        survey_id INTEGER NOT NULL,
        option_id INTEGER NOT NULL,
        region_type VARCHAR(20) NOT NULL,
        region_id INTEGER NOT NULL,
        vote_count INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (survey_id) REFERENCES surveys(id) ON DELETE CASCADE,
        FOREIGN KEY (option_id) REFERENCES survey_options(id) ON DELETE CASCADE
    )");
    
    echo "Anket tabloları başarıyla oluşturuldu.";
    
} catch (PDOException $e) {
    die("Tablo oluşturma hatası: " . $e->getMessage());
}