<?php
/**
 * ŞikayetVar Admin Panel - Veritabanı Tablo Oluşturma
 */

// Veritabanı bağlantısı
require_once 'config.php';

// PostgreSQL için tablo yapısı oluşturma
try {
    // Kategoriler tablosu
    $db->exec("CREATE TABLE IF NOT EXISTS categories (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        description TEXT
    )");
    
    // Şehirler tablosu
    $db->exec("CREATE TABLE IF NOT EXISTS cities (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        region VARCHAR(100)
    )");
    
    // İlçeler tablosu
    $db->exec("CREATE TABLE IF NOT EXISTS districts (
        id SERIAL PRIMARY KEY,
        city_id INTEGER NOT NULL,
        name VARCHAR(255) NOT NULL,
        FOREIGN KEY (city_id) REFERENCES cities(id)
    )");
    
    // Kullanıcılar tablosu
    $db->exec("CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        username VARCHAR(100) UNIQUE NOT NULL,
        email VARCHAR(255) UNIQUE NOT NULL,
        password VARCHAR(255) NOT NULL,
        name VARCHAR(255),
        profile_image VARCHAR(255),
        level VARCHAR(50) DEFAULT 'newUser',
        points INTEGER DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )");
    
    // Paylaşımlar tablosu
    $db->exec("CREATE TABLE IF NOT EXISTS posts (
        id SERIAL PRIMARY KEY,
        user_id INTEGER NOT NULL,
        title VARCHAR(255) NOT NULL,
        content TEXT NOT NULL,
        type VARCHAR(50) NOT NULL,
        status VARCHAR(50) DEFAULT 'awaitingSolution',
        category_id INTEGER,
        city_id INTEGER,
        district_id INTEGER,
        upvotes INTEGER DEFAULT 0,
        downvotes INTEGER DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id),
        FOREIGN KEY (category_id) REFERENCES categories(id),
        FOREIGN KEY (city_id) REFERENCES cities(id),
        FOREIGN KEY (district_id) REFERENCES districts(id)
    )");
    
    // Medya tablosu
    $db->exec("CREATE TABLE IF NOT EXISTS media (
        id SERIAL PRIMARY KEY,
        post_id INTEGER NOT NULL,
        file_path VARCHAR(255) NOT NULL,
        type VARCHAR(50) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE
    )");
    
    // Yorumlar tablosu
    $db->exec("CREATE TABLE IF NOT EXISTS comments (
        id SERIAL PRIMARY KEY,
        post_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        parent_id INTEGER,
        content TEXT NOT NULL,
        upvotes INTEGER DEFAULT 0,
        downvotes INTEGER DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users(id),
        FOREIGN KEY (parent_id) REFERENCES comments(id) ON DELETE CASCADE
    )");
    
    // Anketler tablosu
    $db->exec("CREATE TABLE IF NOT EXISTS surveys (
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
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (category_id) REFERENCES categories(id),
        FOREIGN KEY (city_id) REFERENCES cities(id),
        FOREIGN KEY (district_id) REFERENCES districts(id)
    )");
    
    // Anket seçenekleri tablosu
    $db->exec("CREATE TABLE IF NOT EXISTS survey_options (
        id SERIAL PRIMARY KEY,
        survey_id INTEGER NOT NULL,
        text VARCHAR(255) NOT NULL,
        vote_count INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (survey_id) REFERENCES surveys(id) ON DELETE CASCADE
    )");
    
    // Bölgesel anket sonuçları tablosu
    $db->exec("CREATE TABLE IF NOT EXISTS survey_regional_results (
        id SERIAL PRIMARY KEY,
        survey_id INTEGER NOT NULL,
        option_id INTEGER NOT NULL,
        region_type VARCHAR(20) NOT NULL,
        region_id INTEGER NOT NULL,
        vote_count INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (survey_id) REFERENCES surveys(id) ON DELETE CASCADE,
        FOREIGN KEY (option_id) REFERENCES survey_options(id) ON DELETE CASCADE
    )");
    
    // Yasaklı kelimeler tablosu
    $db->exec("CREATE TABLE IF NOT EXISTS banned_words (
        id SERIAL PRIMARY KEY,
        word VARCHAR(100) NOT NULL UNIQUE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )");
    
    echo "Tablolar başarıyla oluşturuldu.";
    
} catch (PDOException $e) {
    die("Tablo oluşturma hatası: " . $e->getMessage());
}