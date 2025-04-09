-- ŞikayetVar Veritabanı Şeması
-- Oluşturulma Tarihi: 9 Nisan 2025

-- Kategori Tablosu
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    icon_name VARCHAR(50),
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Şehir Tablosu
CREATE TABLE cities (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- İlçe Tablosu
CREATE TABLE districts (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    city_id INTEGER NOT NULL REFERENCES cities(id) ON DELETE CASCADE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Kullanıcı Tablosu
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    profile_image_url TEXT,
    bio TEXT,
    city_id INTEGER REFERENCES cities(id),
    district_id INTEGER REFERENCES districts(id),
    is_verified BOOLEAN NOT NULL DEFAULT FALSE,
    points INTEGER NOT NULL DEFAULT 0,
    post_count INTEGER NOT NULL DEFAULT 0,
    comment_count INTEGER NOT NULL DEFAULT 0,
    level VARCHAR(20) NOT NULL DEFAULT 'newUser',
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Paylaşım (Şikayet/Öneri) Tablosu
CREATE TABLE posts (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    category_id INTEGER NOT NULL REFERENCES categories(id),
    city_id INTEGER REFERENCES cities(id),
    district_id INTEGER REFERENCES districts(id),
    status VARCHAR(20) NOT NULL DEFAULT 'awaitingSolution',
    type VARCHAR(20) NOT NULL DEFAULT 'problem',
    likes INTEGER NOT NULL DEFAULT 0,
    highlights INTEGER NOT NULL DEFAULT 0,
    comment_count INTEGER NOT NULL DEFAULT 0,
    is_anonymous BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Medya Tablosu (Paylaşımlara Eklenen Görseller)
CREATE TABLE media (
    id SERIAL PRIMARY KEY,
    post_id INTEGER NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    url TEXT NOT NULL,
    type VARCHAR(20) NOT NULL, -- image, video
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Yorum Tablosu
CREATE TABLE comments (
    id SERIAL PRIMARY KEY,
    post_id INTEGER NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    like_count INTEGER NOT NULL DEFAULT 0,
    is_hidden BOOLEAN NOT NULL DEFAULT FALSE,
    is_anonymous BOOLEAN NOT NULL DEFAULT FALSE,
    parent_id INTEGER REFERENCES comments(id),
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Anket Tablosu
CREATE TABLE surveys (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    scope_type VARCHAR(20) NOT NULL DEFAULT 'general',
    city_id INTEGER REFERENCES cities(id),
    district_id INTEGER REFERENCES districts(id),
    category_id INTEGER NOT NULL REFERENCES categories(id),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL,
    total_votes INTEGER NOT NULL DEFAULT 0,
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Anket Seçenekleri Tablosu
CREATE TABLE survey_options (
    id SERIAL PRIMARY KEY,
    survey_id INTEGER NOT NULL REFERENCES surveys(id) ON DELETE CASCADE,
    text TEXT NOT NULL,
    vote_count INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Bölgesel Anket Sonuçları Tablosu
CREATE TABLE survey_regional_results (
    id SERIAL PRIMARY KEY,
    survey_id INTEGER NOT NULL REFERENCES surveys(id) ON DELETE CASCADE,
    option_id INTEGER NOT NULL REFERENCES survey_options(id) ON DELETE CASCADE,
    city_id INTEGER REFERENCES cities(id),
    district_id INTEGER REFERENCES districts(id),
    vote_count INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Küfür Filtreleme Tablosu
CREATE TABLE banned_words (
    id SERIAL PRIMARY KEY,
    word VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Örnek Veri Ekleme İşlemleri
-- Kategoriler
INSERT INTO categories (name, icon_name) VALUES 
('Altyapı', 'construction'),
('Ulaşım', 'directions_bus'),
('Çevre', 'nature'),
('Güvenlik', 'security'),
('Sağlık', 'local_hospital'),
('Eğitim', 'school'),
('Kültür & Sanat', 'theater_comedy'),
('Sosyal Hizmetler', 'people'),
('Diğer', 'more_horiz');

-- Şehirler (Örnek olarak birkaç büyük şehir)
INSERT INTO cities (name) VALUES 
('İstanbul'),
('Ankara'),
('İzmir'),
('Bursa'),
('Antalya');

-- İlçeler (İstanbul için örnek)
INSERT INTO districts (name, city_id) VALUES 
('Kadıköy', 1),
('Beşiktaş', 1),
('Üsküdar', 1),
('Bakırköy', 1),
('Fatih', 1);

-- İlçeler (Ankara için örnek)
INSERT INTO districts (name, city_id) VALUES 
('Çankaya', 2),
('Keçiören', 2),
('Yenimahalle', 2);

-- İlçeler (İzmir için örnek)
INSERT INTO districts (name, city_id) VALUES 
('Konak', 3),
('Karşıyaka', 3),
('Bornova', 3);

-- Admin Kullanıcısı
INSERT INTO users (name, email, password, is_verified, level) VALUES 
('Admin', 'admin@example.com', '$2b$10$k55g2qPRBM6SCcW8BM3l1OkTEQoiL.Vgab21jzv8x2ZHIV5uC1Pqe', TRUE, 'master');

-- Yasaklı Kelimeler (Örnek)
INSERT INTO banned_words (word) VALUES 
('küfür'),
('hakaret'),
('argo'),
('Amcık');