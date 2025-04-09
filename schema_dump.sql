-- ŞikayetVar Veritabanı Şeması - Version 1.0
-- Oluşturulma tarihi: 9 Nisan 2025

-- Veritabanı şeması tabloları ve ilişkileri

-- Aşağıdaki şema, ŞikayetVar uygulamasının veritabanı yapısını tanımlar.
-- Bu şema şunları içerir:
-- - İller ve ilçeler (Türkiye'nin tüm il ve ilçeleri)
-- - Kullanıcılar ve seviye sistemi
-- - Paylaşımlar (şikayetler, öneriler, duyurular)
-- - Yorumlar ve etkileşimler
-- - Anketler ve anket sonuçları (bölgesel)
-- - Yasaklı kelimeler listesi (içerik filtreleme için)

-- Kategoriler tablosu
CREATE TABLE IF NOT EXISTS categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE
);

-- İller tablosu
CREATE TABLE IF NOT EXISTS cities (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE
);

-- İlçeler tablosu
CREATE TABLE IF NOT EXISTS districts (
    id SERIAL PRIMARY KEY,
    city_id INTEGER NOT NULL REFERENCES cities(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE
);

-- Kullanıcılar tablosu
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    bio TEXT,
    profile_picture VARCHAR(255),
    points INTEGER DEFAULT 0,
    level VARCHAR(50) DEFAULT 'newUser',
    city_id INTEGER REFERENCES cities(id),
    district_id INTEGER REFERENCES districts(id),
    is_admin BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE
);

-- Paylaşımlar tablosu (şikayetler, öneriler, duyurular)
CREATE TABLE IF NOT EXISTS posts (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    post_type VARCHAR(50) NOT NULL,
    status VARCHAR(50) DEFAULT 'awaitingSolution',
    visibility VARCHAR(50) DEFAULT 'public',
    scope_type VARCHAR(50) DEFAULT 'general',
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    category_id INTEGER REFERENCES categories(id),
    city_id INTEGER REFERENCES cities(id),
    district_id INTEGER REFERENCES districts(id),
    votes_up INTEGER DEFAULT 0,
    votes_down INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE
);

-- Medya tablosu (görseller, videolar)
CREATE TABLE IF NOT EXISTS media (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    post_id INTEGER REFERENCES posts(id) ON DELETE CASCADE,
    comment_id INTEGER REFERENCES comments(id) ON DELETE CASCADE,
    media_type VARCHAR(50) NOT NULL,
    media_url VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Yorumlar tablosu
CREATE TABLE IF NOT EXISTS comments (
    id SERIAL PRIMARY KEY,
    content TEXT NOT NULL,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    post_id INTEGER NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    parent_id INTEGER REFERENCES comments(id) ON DELETE CASCADE,
    votes_up INTEGER DEFAULT 0,
    votes_down INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE
);

-- Anketler tablosu
CREATE TABLE IF NOT EXISTS surveys (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    scope_type VARCHAR(50) NOT NULL,
    start_date TIMESTAMP WITH TIME ZONE NOT NULL,
    end_date TIMESTAMP WITH TIME ZONE NOT NULL,
    user_id INTEGER NOT NULL REFERENCES users(id),
    city_id INTEGER REFERENCES cities(id),
    district_id INTEGER REFERENCES districts(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE
);

-- Anket seçenekleri tablosu
CREATE TABLE IF NOT EXISTS survey_options (
    id SERIAL PRIMARY KEY,
    survey_id INTEGER NOT NULL REFERENCES surveys(id) ON DELETE CASCADE,
    option_text VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Anket bölgesel sonuçları tablosu
CREATE TABLE IF NOT EXISTS survey_regional_results (
    id SERIAL PRIMARY KEY,
    survey_id INTEGER NOT NULL REFERENCES surveys(id) ON DELETE CASCADE,
    option_id INTEGER NOT NULL REFERENCES survey_options(id) ON DELETE CASCADE,
    city_id INTEGER REFERENCES cities(id),
    district_id INTEGER REFERENCES districts(id),
    vote_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE
);

-- Yasaklı kelimeler tablosu (içerik filtreleme için)
CREATE TABLE IF NOT EXISTS banned_words (
    id SERIAL PRIMARY KEY,
    word VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Örnek kategori verileri
INSERT INTO categories (name, description) VALUES
('Altyapı', 'Su, elektrik, doğalgaz, kanalizasyon gibi temel altyapı hizmetleri'),
('Ulaşım', 'Toplu taşıma, yollar, trafik düzenlemeleri'),
('Çevre', 'Parklar, yeşil alanlar, çevre temizliği'),
('Güvenlik', 'Asayiş, güvenlik önlemleri'),
('Sağlık', 'Sağlık hizmetleri ve tesisleri'),
('Eğitim', 'Okullar, kütüphaneler, eğitim faaliyetleri'),
('Kültür ve Sanat', 'Festivaller, etkinlikler, kültürel tesisler'),
('Spor', 'Spor tesisleri, aktiviteler'),
('Belediye Hizmetleri', 'Çöp toplama, temizlik, zabıta');

-- Örnek admin kullanıcısı
INSERT INTO users (username, email, password, first_name, last_name, is_admin, level) 
VALUES ('admin', 'admin@sikayetvar.com', '$2y$10$8KOI.iXxmZOA2sdlvxuBXuLQUvKLvJiYVmH.pVuYr1qRIKO4hXUIm', 'Admin', 'User', TRUE, 'master');
-- Not: Şifre admin123 (bcrypt ile hashlendi)

-- Yasaklı kelimeler için örnek veriler
INSERT INTO banned_words (word) VALUES
('küfür'),
('hakaret'),
('sövmek'),
('ahmak'),
('aptal'),
('gerizekalı'),
('salak'),
('dümbük');