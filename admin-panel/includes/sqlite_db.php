<?php
/**
 * SQLite Veritabanı Bağlantısı - ŞikayetVar Admin Panel
 * Bu dosya, uygulamanın SQLite veritabanı bağlantısını sağlar.
 */

// Hata raporlaması etkinleştir
ini_set('display_errors', 1);
error_reporting(E_ALL);

// SQLite veritabanı dosya yolunu belirle
$db_file = __DIR__ . '/../db/sikayetvar.db';

// Veritabanı dizini yoksa oluştur
$db_dir = dirname($db_file);
if (!file_exists($db_dir)) {
    mkdir($db_dir, 0755, true);
}

try {
    // PDO bağlantısını oluştur
    $db = new PDO('sqlite:' . $db_file);
    
    // Hata modunu etkinleştir
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // SQLite özel ayarları
    $db->exec('PRAGMA foreign_keys = ON;');
    
    // Veritabanı şemasını oluştur (ilk kurulum için)
    setupDatabase($db);
    
} catch (PDOException $e) {
    // Hata durumunda, hata mesajını göster ve uygulama çalışmayı durdursun
    die('Veritabanı bağlantı hatası: ' . $e->getMessage());
}

/**
 * Veritabanı şemasını oluşturan fonksiyon
 */
function setupDatabase($db) {
    // Kategoriler tablosu
    $db->exec('CREATE TABLE IF NOT EXISTS categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT
    )');
    
    // Şehirler tablosu
    $db->exec('CREATE TABLE IF NOT EXISTS cities (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        region TEXT
    )');
    
    // İlçeler tablosu
    $db->exec('CREATE TABLE IF NOT EXISTS districts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        city_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        FOREIGN KEY (city_id) REFERENCES cities(id)
    )');
    
    // Kullanıcılar tablosu
    $db->exec('CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        name TEXT,
        profile_image TEXT,
        level TEXT DEFAULT "newUser",
        points INTEGER DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )');
    
    // Paylaşımlar tablosu
    $db->exec('CREATE TABLE IF NOT EXISTS posts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        type TEXT NOT NULL,
        status TEXT DEFAULT "awaitingSolution",
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
    )');
    
    // Medya tablosu
    $db->exec('CREATE TABLE IF NOT EXISTS media (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        post_id INTEGER NOT NULL,
        file_path TEXT NOT NULL,
        type TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE
    )');
    
    // Yorumlar tablosu
    $db->exec('CREATE TABLE IF NOT EXISTS comments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
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
    )');
    
    // Anketler tablosu
    $db->exec('CREATE TABLE IF NOT EXISTS surveys (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        short_title TEXT NOT NULL,
        description TEXT NOT NULL,
        category_id INTEGER NOT NULL,
        scope_type TEXT NOT NULL,
        city_id INTEGER,
        district_id INTEGER,
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        total_users INTEGER NOT NULL DEFAULT 1000,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (category_id) REFERENCES categories(id),
        FOREIGN KEY (city_id) REFERENCES cities(id),
        FOREIGN KEY (district_id) REFERENCES districts(id)
    )');
    
    // Anket seçenekleri tablosu
    $db->exec('CREATE TABLE IF NOT EXISTS survey_options (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        survey_id INTEGER NOT NULL,
        text TEXT NOT NULL,
        vote_count INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (survey_id) REFERENCES surveys(id) ON DELETE CASCADE
    )');
    
    // Bölgesel anket sonuçları tablosu
    $db->exec('CREATE TABLE IF NOT EXISTS survey_regional_results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        survey_id INTEGER NOT NULL,
        option_id INTEGER NOT NULL,
        region_type TEXT NOT NULL,
        region_id INTEGER NOT NULL,
        vote_count INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (survey_id) REFERENCES surveys(id) ON DELETE CASCADE,
        FOREIGN KEY (option_id) REFERENCES survey_options(id) ON DELETE CASCADE
    )');
    
    // Yasaklı kelimeler tablosu
    $db->exec('CREATE TABLE IF NOT EXISTS banned_words (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word TEXT NOT NULL UNIQUE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )');
    
    // Demo kategoriler ekle
    addDemoCategories($db);
}

/**
 * Demo kategorileri ekleyen fonksiyon
 */
function addDemoCategories($db) {
    // Kategoriler tablosunda veri yoksa, demo kategorileri ekle
    $stmt = $db->query('SELECT COUNT(*) as count FROM categories');
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($row['count'] == 0) {
        $categories = [
            ['name' => 'Altyapı', 'description' => 'Yol, su, elektrik, doğalgaz gibi altyapı sorunları'],
            ['name' => 'Çevre', 'description' => 'Çevre kirliliği, parklar, yeşil alanlar'],
            ['name' => 'Ulaşım', 'description' => 'Toplu taşıma, trafik sorunları'],
            ['name' => 'Güvenlik', 'description' => 'Asayiş, güvenlik önlemleri'],
            ['name' => 'Eğitim', 'description' => 'Okul, kurs, eğitim tesisleri'],
            ['name' => 'Sağlık', 'description' => 'Hastane, sağlık hizmetleri'],
            ['name' => 'Sosyal Hizmetler', 'description' => 'Dezavantajlı gruplara yönelik hizmetler'],
            ['name' => 'Kültür ve Sanat', 'description' => 'Kültürel etkinlikler, tesisler'],
            ['name' => 'Spor', 'description' => 'Spor tesisleri, aktiviteler'],
            ['name' => 'Diğer', 'description' => 'Diğer konular']
        ];
        
        $stmt = $db->prepare('INSERT INTO categories (name, description) VALUES (?, ?)');
        
        foreach ($categories as $category) {
            $stmt->execute([$category['name'], $category['description']]);
        }
    }
}