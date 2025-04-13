-- ŞikayetVar Veritabanı Güvenli Import
-- Export Tarihi: 2025-04-13
-- Bu script, varolan tabloları kontrol eder ve gerekirse oluşturur
-- Veri importu, aynı ID'ye sahip kayıt varsa günceller, yoksa ekler
-- -------------------------------------------------------------

BEGIN;

-- Kontrol fonksiyonunu oluştur, eğer yoksa
DO $$
BEGIN
    -- Tablo var mı kontrol etmek için fonksiyon
    CREATE OR REPLACE FUNCTION table_exists(tbl text) RETURNS boolean AS $$
    DECLARE
        exists boolean;
    BEGIN
        SELECT count(*) > 0 INTO exists
        FROM information_schema.tables
        WHERE table_name = tbl;
        RETURN exists;
    END;
    $$ LANGUAGE plpgsql;

    -- Sütun var mı kontrol etmek için fonksiyon  
    CREATE OR REPLACE FUNCTION column_exists(tbl text, col text) RETURNS boolean AS $$
    DECLARE
        exists boolean;
    BEGIN
        SELECT count(*) > 0 INTO exists
        FROM information_schema.columns
        WHERE table_name = tbl AND column_name = col;
        RETURN exists;
    END;
    $$ LANGUAGE plpgsql;
END
$$;

-- Tabloları oluştur (eğer yoksa)
-- award_types tablosu
DO $$
BEGIN
    IF NOT table_exists('award_types') THEN
        CREATE TABLE award_types (
            id SERIAL PRIMARY KEY,
            name VARCHAR(100) NOT NULL,
            description TEXT,
            icon_url TEXT,
            badge_url TEXT,
            color VARCHAR(20),
            points INTEGER NOT NULL DEFAULT 0,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            is_system BOOLEAN NOT NULL DEFAULT FALSE,
            icon VARCHAR(100),
            min_rate NUMERIC DEFAULT 0,
            max_rate NUMERIC DEFAULT 100,
            badge_color VARCHAR(20)
        );
        RAISE NOTICE 'award_types tablosu oluşturuldu';
    ELSE
        -- Sütun kontrolleri ve eklemeleri
        IF NOT column_exists('award_types', 'is_system') THEN
            ALTER TABLE award_types ADD COLUMN is_system BOOLEAN NOT NULL DEFAULT FALSE;
            RAISE NOTICE 'award_types tablosuna is_system sütunu eklendi';
        END IF;
        
        IF NOT column_exists('award_types', 'icon') THEN
            ALTER TABLE award_types ADD COLUMN icon VARCHAR(100);
            RAISE NOTICE 'award_types tablosuna icon sütunu eklendi';
        END IF;
        
        IF NOT column_exists('award_types', 'min_rate') THEN
            ALTER TABLE award_types ADD COLUMN min_rate NUMERIC DEFAULT 0;
            RAISE NOTICE 'award_types tablosuna min_rate sütunu eklendi';
        END IF;
        
        IF NOT column_exists('award_types', 'max_rate') THEN
            ALTER TABLE award_types ADD COLUMN max_rate NUMERIC DEFAULT 100;
            RAISE NOTICE 'award_types tablosuna max_rate sütunu eklendi';
        END IF;
        
        IF NOT column_exists('award_types', 'badge_color') THEN
            ALTER TABLE award_types ADD COLUMN badge_color VARCHAR(20);
            RAISE NOTICE 'award_types tablosuna badge_color sütunu eklendi';
        END IF;
    END IF;
END
$$;

-- banned_words tablosu
DO $$
BEGIN
    IF NOT table_exists('banned_words') THEN
        CREATE TABLE banned_words (
            id SERIAL PRIMARY KEY,
            word VARCHAR(100) NOT NULL,
            created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        );
        RAISE NOTICE 'banned_words tablosu oluşturuldu';
    END IF;
END
$$;

-- categories tablosu
DO $$
BEGIN
    IF NOT table_exists('categories') THEN
        CREATE TABLE categories (
            id SERIAL PRIMARY KEY,
            name VARCHAR(100) NOT NULL,
            description TEXT,
            icon VARCHAR(100),
            color VARCHAR(20),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        RAISE NOTICE 'categories tablosu oluşturuldu';
    END IF;
END
$$;

-- cities tablosu
DO $$
BEGIN
    IF NOT table_exists('cities') THEN
        CREATE TABLE cities (
            id SERIAL PRIMARY KEY,
            name VARCHAR(100) NOT NULL,
            region VARCHAR(100),
            province VARCHAR(100),
            population INTEGER,
            latitude DOUBLE PRECISION,
            longitude DOUBLE PRECISION,
            about TEXT,
            logo_url TEXT,
            cover_image_url TEXT,
            mayor_name VARCHAR(100),
            mayor_party VARCHAR(100),
            mayor_photo_url TEXT,
            website_url TEXT,
            phone VARCHAR(50),
            email VARCHAR(100),
            twitter_url TEXT,
            facebook_url TEXT,
            instagram_url TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            problem_solving_rate NUMERIC DEFAULT 0
        );
        RAISE NOTICE 'cities tablosu oluşturuldu';
    ELSE
        -- problem_solving_rate sütunu kontrol et
        IF NOT column_exists('cities', 'problem_solving_rate') THEN
            ALTER TABLE cities ADD COLUMN problem_solving_rate NUMERIC DEFAULT 0;
            RAISE NOTICE 'cities tablosuna problem_solving_rate sütunu eklendi';
        END IF;
    END IF;
END
$$;

-- city_awards tablosu
DO $$
BEGIN
    IF NOT table_exists('city_awards') THEN
        CREATE TABLE city_awards (
            id SERIAL PRIMARY KEY,
            city_id INTEGER REFERENCES cities(id),
            award_id INTEGER REFERENCES award_types(id),
            start_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            expiry_date TIMESTAMP,
            is_active BOOLEAN DEFAULT TRUE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        RAISE NOTICE 'city_awards tablosu oluşturuldu';
    END IF;
END
$$;

-- city_events tablosu
DO $$
BEGIN
    IF NOT table_exists('city_events') THEN
        CREATE TABLE city_events (
            id SERIAL PRIMARY KEY,
            city_id INTEGER REFERENCES cities(id),
            name VARCHAR(200) NOT NULL,
            description TEXT,
            start_date TIMESTAMP,
            end_date TIMESTAMP,
            location TEXT,
            image_url TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        RAISE NOTICE 'city_events tablosu oluşturuldu';
    END IF;
END
$$;

-- city_projects tablosu
DO $$
BEGIN
    IF NOT table_exists('city_projects') THEN
        CREATE TABLE city_projects (
            id SERIAL PRIMARY KEY,
            city_id INTEGER REFERENCES cities(id),
            name VARCHAR(200) NOT NULL,
            description TEXT,
            start_date TIMESTAMP,
            end_date TIMESTAMP,
            status VARCHAR(50),
            budget NUMERIC,
            image_url TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        RAISE NOTICE 'city_projects tablosu oluşturuldu';
    END IF;
END
$$;

-- city_services tablosu
DO $$
BEGIN
    IF NOT table_exists('city_services') THEN
        CREATE TABLE city_services (
            id SERIAL PRIMARY KEY,
            city_id INTEGER REFERENCES cities(id),
            name VARCHAR(200) NOT NULL,
            description TEXT,
            icon VARCHAR(100),
            contact_info TEXT,
            working_hours TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        RAISE NOTICE 'city_services tablosu oluşturuldu';
    END IF;
END
$$;

-- city_stats tablosu
DO $$
BEGIN
    IF NOT table_exists('city_stats') THEN
        CREATE TABLE city_stats (
            id SERIAL PRIMARY KEY,
            city_id INTEGER REFERENCES cities(id),
            stat_name VARCHAR(100) NOT NULL,
            stat_value NUMERIC NOT NULL,
            unit VARCHAR(20),
            year INTEGER,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        RAISE NOTICE 'city_stats tablosu oluşturuldu';
    END IF;
END
$$;

-- comments tablosu
DO $$
BEGIN
    IF NOT table_exists('comments') THEN
        CREATE TABLE comments (
            id SERIAL PRIMARY KEY,
            post_id INTEGER,
            user_id INTEGER,
            content TEXT NOT NULL,
            likes_count INTEGER DEFAULT 0,
            is_approved BOOLEAN DEFAULT TRUE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            parent_id INTEGER
        );
        RAISE NOTICE 'comments tablosu oluşturuldu';
    END IF;
END
$$;

-- districts tablosu
DO $$
BEGIN
    IF NOT table_exists('districts') THEN
        CREATE TABLE districts (
            id SERIAL PRIMARY KEY,
            city_id INTEGER REFERENCES cities(id),
            name VARCHAR(100) NOT NULL,
            population INTEGER,
            latitude DOUBLE PRECISION,
            longitude DOUBLE PRECISION,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        RAISE NOTICE 'districts tablosu oluşturuldu';
    END IF;
END
$$;

-- media tablosu
DO $$
BEGIN
    IF NOT table_exists('media') THEN
        CREATE TABLE media (
            id SERIAL PRIMARY KEY,
            post_id INTEGER,
            user_id INTEGER,
            media_type VARCHAR(20) NOT NULL,
            url TEXT NOT NULL,
            thumbnail_url TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        RAISE NOTICE 'media tablosu oluşturuldu';
    END IF;
END
$$;

-- migrations tablosu
DO $$
BEGIN
    IF NOT table_exists('migrations') THEN
        CREATE TABLE migrations (
            id SERIAL PRIMARY KEY,
            migration VARCHAR(255) NOT NULL,
            batch INTEGER NOT NULL
        );
        RAISE NOTICE 'migrations tablosu oluşturuldu';
    END IF;
END
$$;

-- notifications tablosu
DO $$
BEGIN
    IF NOT table_exists('notifications') THEN
        CREATE TABLE notifications (
            id SERIAL PRIMARY KEY,
            user_id INTEGER NOT NULL,
            type VARCHAR(50) NOT NULL,
            message TEXT NOT NULL,
            is_read BOOLEAN DEFAULT FALSE,
            related_id INTEGER,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        RAISE NOTICE 'notifications tablosu oluşturuldu';
    END IF;
END
$$;

-- posts tablosu
DO $$
BEGIN
    IF NOT table_exists('posts') THEN
        CREATE TABLE posts (
            id SERIAL PRIMARY KEY,
            user_id INTEGER NOT NULL,
            title VARCHAR(255) NOT NULL,
            content TEXT NOT NULL,
            category_id INTEGER,
            city_id INTEGER,
            district_id INTEGER,
            latitude DOUBLE PRECISION,
            longitude DOUBLE PRECISION,
            status VARCHAR(50) DEFAULT 'open',
            is_resolved BOOLEAN DEFAULT FALSE,
            is_approved BOOLEAN DEFAULT TRUE,
            likes_count INTEGER DEFAULT 0,
            comments_count INTEGER DEFAULT 0,
            views_count INTEGER DEFAULT 0,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            is_anonymous BOOLEAN DEFAULT FALSE,
            is_featured BOOLEAN DEFAULT FALSE,
            address TEXT
        );
        RAISE NOTICE 'posts tablosu oluşturuldu';
    END IF;
END
$$;

-- settings tablosu
DO $$
BEGIN
    IF NOT table_exists('settings') THEN
        CREATE TABLE settings (
            id SERIAL PRIMARY KEY,
            name VARCHAR(100) NOT NULL,
            value TEXT NOT NULL,
            description TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        RAISE NOTICE 'settings tablosu oluşturuldu';
    END IF;
END
$$;

-- survey_options tablosu
DO $$
BEGIN
    IF NOT table_exists('survey_options') THEN
        CREATE TABLE survey_options (
            id SERIAL PRIMARY KEY,
            survey_id INTEGER NOT NULL,
            option_text TEXT NOT NULL,
            votes_count INTEGER DEFAULT 0,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        RAISE NOTICE 'survey_options tablosu oluşturuldu';
    END IF;
END
$$;

-- survey_regional_results tablosu
DO $$
BEGIN
    IF NOT table_exists('survey_regional_results') THEN
        CREATE TABLE survey_regional_results (
            id SERIAL PRIMARY KEY,
            survey_id INTEGER NOT NULL,
            option_id INTEGER NOT NULL,
            region_type VARCHAR(20) NOT NULL,
            region_id INTEGER NOT NULL,
            votes_count INTEGER DEFAULT 0,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        RAISE NOTICE 'survey_regional_results tablosu oluşturuldu';
    END IF;
END
$$;

-- surveys tablosu
DO $$
BEGIN
    IF NOT table_exists('surveys') THEN
        CREATE TABLE surveys (
            id SERIAL PRIMARY KEY,
            title VARCHAR(255) NOT NULL,
            description TEXT,
            start_date TIMESTAMP,
            end_date TIMESTAMP,
            is_active BOOLEAN DEFAULT TRUE,
            scope_type VARCHAR(20) DEFAULT 'national',
            scope_id INTEGER,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        RAISE NOTICE 'surveys tablosu oluşturuldu';
    END IF;
END
$$;

-- user_likes tablosu
DO $$
BEGIN
    IF NOT table_exists('user_likes') THEN
        CREATE TABLE user_likes (
            id SERIAL PRIMARY KEY,
            user_id INTEGER NOT NULL,
            post_id INTEGER,
            comment_id INTEGER,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        RAISE NOTICE 'user_likes tablosu oluşturuldu';
    END IF;
END
$$;

-- users tablosu
DO $$
BEGIN
    IF NOT table_exists('users') THEN
        CREATE TABLE users (
            id SERIAL PRIMARY KEY,
            name VARCHAR(100) NOT NULL,
            email VARCHAR(100) NOT NULL UNIQUE,
            password VARCHAR(255) NOT NULL,
            avatar_url TEXT,
            bio TEXT,
            location VARCHAR(100),
            level INTEGER DEFAULT 1,
            points INTEGER DEFAULT 0,
            role VARCHAR(20) DEFAULT 'user',
            is_verified BOOLEAN DEFAULT FALSE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            city_id INTEGER,
            district_id INTEGER,
            latitude DOUBLE PRECISION,
            longitude DOUBLE PRECISION,
            email_verified_at TIMESTAMP,
            remember_token VARCHAR(100),
            username VARCHAR(100)
        );
        RAISE NOTICE 'users tablosu oluşturuldu';
    ELSE
        -- username sütunu kontrol et
        IF NOT column_exists('users', 'username') THEN
            ALTER TABLE users ADD COLUMN username VARCHAR(100);
            RAISE NOTICE 'users tablosuna username sütunu eklendi';
        END IF;
    END IF;
END
$$;

-- Veri Importu
-- UPSERT yöntemi kullanılıyor - Aynı ID varsa güncelle, yoksa ekle

-- award_types tablosuna veri importu
INSERT INTO award_types (id, name, description, icon_url, badge_url, color, points, created_at, is_system, icon, min_rate, max_rate, badge_color)
VALUES
(11, 'Bronz Belediye Ödülü', 'Şikayet çözüm oranı %25 ile %50 arasında olan belediyeler', NULL, NULL, '#CD7F32', 100, '2025-04-11 20:30:18', FALSE, 'bronze_medal.png', 25.00, 49.99, '#CD7F32'),
(12, 'Gümüş Belediye Ödülü', 'Şikayet çözüm oranı %50 ile %75 arasında olan belediyeler', NULL, NULL, '#C0C0C0', 200, '2025-04-11 20:30:18', FALSE, 'silver_medal.png', 50.00, 74.99, '#C0C0C0'),
(13, 'Altın Belediye Ödülü', 'Şikayet çözüm oranı %75 ve üzerinde olan belediyeler', NULL, NULL, '#FFD700', 300, '2025-04-11 20:30:18', FALSE, 'gold_medal.png', 75.00, 100.00, '#FFD700'),
(14, 'Bronz Kupa', 'Sorun çözme oranı %25-49 arası olan belediyeler için verilen otomatik ödül.', NULL, NULL, '#CD7F32', 50, '2025-04-12 23:43:12', TRUE, 'bi-trophy', 0.00, 100.00, NULL),
(15, 'Gümüş Kupa', 'Sorun çözme oranı %50-74 arası olan belediyeler için verilen otomatik ödül.', NULL, NULL, '#C0C0C0', 100, '2025-04-12 23:43:12', TRUE, 'bi-trophy-fill', 0.00, 100.00, NULL),
(16, 'Altın Kupa', 'Sorun çözme oranı %75 ve üzeri olan belediyeler için verilen otomatik ödül.', NULL, NULL, '#FFD700', 200, '2025-04-12 23:43:13', TRUE, 'bi-trophy-fill', 0.00, 100.00, NULL)
ON CONFLICT (id) DO UPDATE 
SET name = EXCLUDED.name,
    description = EXCLUDED.description,
    icon_url = EXCLUDED.icon_url,
    badge_url = EXCLUDED.badge_url,
    color = EXCLUDED.color,
    points = EXCLUDED.points,
    is_system = EXCLUDED.is_system,
    icon = EXCLUDED.icon,
    min_rate = EXCLUDED.min_rate,
    max_rate = EXCLUDED.max_rate,
    badge_color = EXCLUDED.badge_color;

-- banned_words tablosuna veri importu
INSERT INTO banned_words (id, word, created_at)
VALUES
(1, 'küfür', '2025-04-10 07:33:07'),
(2, 'hakaret', '2025-04-10 07:33:07'),
(3, 'tehdit', '2025-04-10 07:33:07')
ON CONFLICT (id) DO UPDATE 
SET word = EXCLUDED.word,
    created_at = EXCLUDED.created_at;

-- categories tablosuna veri importu
INSERT INTO categories (id, name, description, icon, color, created_at)
VALUES
(1, 'Altyapı', 'Yol, su, elektrik, kanalizasyon vb. altyapı şikayetleri', 'bi-tools', '#FF5733', '2025-04-10 07:33:07'),
(2, 'Çevre', 'Çevre kirliliği, gürültü, atık yönetimi ile ilgili şikayetler', 'bi-tree', '#33FF57', '2025-04-10 07:33:07'),
(3, 'Ulaşım', 'Toplu taşıma, trafik ve ulaşım ile ilgili şikayetler', 'bi-bus-front', '#3357FF', '2025-04-10 07:33:07'),
(4, 'Güvenlik', 'Asayiş, emniyet, güvenlik ile ilgili şikayetler', 'bi-shield', '#FF33A8', '2025-04-10 07:33:07'),
(5, 'Zabıta', 'İşgaller, seyyar satıcılar, gürültü ile ilgili şikayetler', 'bi-megaphone', '#57FF33', '2025-04-10 07:33:07'),
(6, 'Sosyal Hizmetler', 'Sosyal yardım, yaşlı, engelli hizmetleri ile ilgili şikayetler', 'bi-people', '#A833FF', '2025-04-10 07:33:07'),
(7, 'İmar', 'İmar, yapı, ruhsat ile ilgili şikayetler', 'bi-building', '#FF8333', '2025-04-10 07:33:07'),
(8, 'Park & Bahçeler', 'Parklar, bahçeler, yeşil alanlar ile ilgili şikayetler', 'bi-flower1', '#33FFA8', '2025-04-10 07:33:07'),
(9, 'Diğer', 'Diğer kategorilere girmeyen şikayetler', 'bi-three-dots', '#333333', '2025-04-10 07:33:07')
ON CONFLICT (id) DO UPDATE 
SET name = EXCLUDED.name,
    description = EXCLUDED.description,
    icon = EXCLUDED.icon,
    color = EXCLUDED.color;

-- Diğer tablolar için de benzer şekilde UPSERT işlemleri uygulanmalıdır
-- Örnek olarak aşağıda sadece birkaç tablo için veri ekleme işlemleri gösterilmiştir
-- Gerçek uygulamada tüm tablolar için benzer şekilde veri ekleme işlemleri yapılmalıdır

-- city_awards tablosuna veri importu (örnek)
INSERT INTO city_awards (id, city_id, award_id, start_date, expiry_date, is_active, created_at)
VALUES
(1, 34, 14, '2025-04-13 01:37:17', '2025-05-13 01:37:17', TRUE, '2025-04-13 01:37:17'),
(2, 6, 15, '2025-04-13 01:37:17', '2025-05-13 01:37:17', TRUE, '2025-04-13 01:37:17')
ON CONFLICT (id) DO UPDATE 
SET city_id = EXCLUDED.city_id,
    award_id = EXCLUDED.award_id,
    start_date = EXCLUDED.start_date,
    expiry_date = EXCLUDED.expiry_date,
    is_active = EXCLUDED.is_active;

-- city_projects tablosuna veri importu (örnek)
INSERT INTO city_projects (id, city_id, name, description, start_date, end_date, status, budget, image_url, created_at)
VALUES
(1, 34, 'Metro Hattı Genişletme Projesi', 'İstanbul'un metro ağının genişletilmesi projesi', '2025-04-01 00:00:00', '2025-12-31 00:00:00', 'Devam Ediyor', 1500000000, 'projects/metro-extension.jpg', '2025-04-11 20:30:18')
ON CONFLICT (id) DO UPDATE 
SET city_id = EXCLUDED.city_id,
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    start_date = EXCLUDED.start_date,
    end_date = EXCLUDED.end_date,
    status = EXCLUDED.status,
    budget = EXCLUDED.budget,
    image_url = EXCLUDED.image_url;

-- Sequence değerlerini düzenle
SELECT setval('award_types_id_seq', COALESCE((SELECT MAX(id) FROM award_types), 1), true);
SELECT setval('banned_words_id_seq', COALESCE((SELECT MAX(id) FROM banned_words), 1), true);
SELECT setval('categories_id_seq', COALESCE((SELECT MAX(id) FROM categories), 1), true);
SELECT setval('cities_id_seq', COALESCE((SELECT MAX(id) FROM cities), 1), true);
SELECT setval('city_awards_id_seq', COALESCE((SELECT MAX(id) FROM city_awards), 1), true);
SELECT setval('city_events_id_seq', COALESCE((SELECT MAX(id) FROM city_events), 1), true);
SELECT setval('city_projects_id_seq', COALESCE((SELECT MAX(id) FROM city_projects), 1), true);
SELECT setval('city_services_id_seq', COALESCE((SELECT MAX(id) FROM city_services), 1), true);
SELECT setval('city_stats_id_seq', COALESCE((SELECT MAX(id) FROM city_stats), 1), true);
SELECT setval('comments_id_seq', COALESCE((SELECT MAX(id) FROM comments), 1), true);
SELECT setval('districts_id_seq', COALESCE((SELECT MAX(id) FROM districts), 1), true);
SELECT setval('media_id_seq', COALESCE((SELECT MAX(id) FROM media), 1), true);
SELECT setval('migrations_id_seq', COALESCE((SELECT MAX(id) FROM migrations), 1), true);
SELECT setval('notifications_id_seq', COALESCE((SELECT MAX(id) FROM notifications), 1), true);
SELECT setval('posts_id_seq', COALESCE((SELECT MAX(id) FROM posts), 1), true);
SELECT setval('settings_id_seq', COALESCE((SELECT MAX(id) FROM settings), 1), true);
SELECT setval('survey_options_id_seq', COALESCE((SELECT MAX(id) FROM survey_options), 1), true);
SELECT setval('survey_regional_results_id_seq', COALESCE((SELECT MAX(id) FROM survey_regional_results), 1), true);
SELECT setval('surveys_id_seq', COALESCE((SELECT MAX(id) FROM surveys), 1), true);
SELECT setval('user_likes_id_seq', COALESCE((SELECT MAX(id) FROM user_likes), 1), true);
SELECT setval('users_id_seq', COALESCE((SELECT MAX(id) FROM users), 1), true);

-- CITIES tablosunu içe aktar (örnek olarak bazı şehirleri ekliyoruz)
-- Gerçek uygulamada, tüm 81 ilin verisini ekleyin
INSERT INTO cities (id, name, region, province, population, latitude, longitude, about, logo_url, cover_image_url, mayor_name, mayor_party, mayor_photo_url, website_url, phone, email, twitter_url, facebook_url, instagram_url, created_at, problem_solving_rate)
VALUES
(1, 'Adana', 'Akdeniz', 'Adana', 2258718, 37.0000, 35.3213, 'Adana, Türkiye'nin güneyinde, Akdeniz Bölgesi'nde yer alan bir şehirdir.', 'logos/adana.png', 'covers/adana.jpg', 'Zeydan Karalar', 'CHP', 'mayors/adana.jpg', 'https://www.adana.bel.tr', '0322 999 00 00', 'info@adana.bel.tr', 'https://twitter.com/adanabld', 'https://facebook.com/adanabld', 'https://instagram.com/adanabld', '2025-04-10 07:33:07', 45.50),
(6, 'Ankara', 'İç Anadolu', 'Ankara', 5747325, 39.9208, 32.8541, 'Ankara, Türkiye'nin başkenti ve en kalabalık ikinci şehridir.', 'logos/ankara.png', 'covers/ankara.jpg', 'Mansur Yavaş', 'CHP', 'mayors/ankara.jpg', 'https://www.ankara.bel.tr', '0312 999 00 00', 'info@ankara.bel.tr', 'https://twitter.com/ankarabld', 'https://facebook.com/ankarabld', 'https://instagram.com/ankarabld', '2025-04-10 07:33:07', 65.80),
(34, 'İstanbul', 'Marmara', 'İstanbul', 16034511, 41.0082, 28.9784, 'İstanbul, Türkiye'nin en kalabalık şehri ve ekonomik, kültürel ve tarihi merkezidir.', 'logos/istanbul.png', 'covers/istanbul.jpg', 'Ekrem İmamoğlu', 'CHP', 'mayors/istanbul.jpg', 'https://www.ibb.istanbul', '0212 999 00 00', 'info@ibb.istanbul', 'https://twitter.com/ibbiletisim', 'https://facebook.com/ibbiletisim', 'https://instagram.com/ibbiletisim', '2025-04-10 07:33:07', 55.30)
ON CONFLICT (id) DO UPDATE 
SET name = EXCLUDED.name,
    region = EXCLUDED.region,
    province = EXCLUDED.province,
    population = EXCLUDED.population,
    latitude = EXCLUDED.latitude,
    longitude = EXCLUDED.longitude,
    about = EXCLUDED.about,
    logo_url = EXCLUDED.logo_url,
    cover_image_url = EXCLUDED.cover_image_url,
    mayor_name = EXCLUDED.mayor_name,
    mayor_party = EXCLUDED.mayor_party,
    mayor_photo_url = EXCLUDED.mayor_photo_url,
    website_url = EXCLUDED.website_url,
    phone = EXCLUDED.phone,
    email = EXCLUDED.email,
    twitter_url = EXCLUDED.twitter_url,
    facebook_url = EXCLUDED.facebook_url,
    instagram_url = EXCLUDED.instagram_url,
    problem_solving_rate = EXCLUDED.problem_solving_rate;

-- İşlemi tamamla
COMMIT;

-- Tamamlandı mesajı
DO $$
BEGIN
    RAISE NOTICE 'ŞikayetVar veritabanı başarıyla import edildi!';
    RAISE NOTICE 'Tablolar ve veriler kontrol edildi, gerekirse oluşturuldu veya güncellendi.';
END
$$;