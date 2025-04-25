<?php
/**
 * Veritabanı tablo yönetimi için yardımcı fonksiyonlar
 * PostgreSQL ve MySQL uyumluluğu için özel destek ve tablo yönetimi
 */

/**
 * Bir tablonun var olup olmadığını kontrol eder ve yoksa oluşturur
 * 
 * @param mysqli $db Veritabanı bağlantısı
 * @param string $tableName Kontrol edilecek tablo adı
 * @param string $createSQL Tablo yoksa çalıştırılacak oluşturma sorgusu
 * @param string $initSQL [opsiyonel] Tablo oluşturulduktan sonra çalıştırılacak başlangıç sorgusu (örn. varsayılan veriler)
 * @return bool Tablo zaten vardı mı yoksa yeni mi oluşturuldu
 */
function ensureTableExists($db, $tableName, $createSQL, $initSQL = null) {
    // Tablo var mı diye kontrol et (PostgreSQL uyumlu)
    $checkTableSQL = "SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = ?
    )";
    
    $stmt = $db->prepare($checkTableSQL);
    $stmt->bind_param('s', $tableName);
    $stmt->execute();
    $result = $stmt->get_result();
    $tableExists = $result->fetch_assoc()['exists'] ?? false;
    
    // Tablo yoksa oluştur
    if (!$tableExists) {
        error_log("Tablo kontrol: '$tableName' tablosu bulunamadı, oluşturuluyor...");
        
        try {
            // Tabloyu oluştur
            $success = $db->query($createSQL);
            
            if (!$success) {
                error_log("HATA: '$tableName' tablosu oluşturulamadı: " . $db->error);
                return false;
            }
            
            // Başlangıç verilerini ekle (varsa)
            if ($initSQL && $success) {
                $success = $db->query($initSQL);
                if (!$success) {
                    error_log("UYARI: '$tableName' için başlangıç verileri eklenemedi: " . $db->error);
                }
            }
            
            error_log("BAŞARILI: '$tableName' tablosu oluşturuldu");
            return true;
        } catch (Exception $e) {
            error_log("HATA: Tablo oluşturma hatası: " . $e->getMessage());
            return false;
        }
    }
    
    // Tablo zaten var
    return false;
}

/**
 * Veritabanında bir sütunun var olup olmadığını kontrol eder
 * 
 * @param mysqli $db Veritabanı bağlantısı
 * @param string $tableName Tablo adı
 * @param string $columnName Sütun adı
 * @return bool Sütun var mı yok mu
 */
function columnExists($db, $tableName, $columnName) {
    // PostgreSQL uyumlu sütun kontrolü
    $checkSQL = "SELECT EXISTS (
        SELECT FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = ?
        AND column_name = ?
    )";
    
    $stmt = $db->prepare($checkSQL);
    $stmt->bind_param('ss', $tableName, $columnName);
    $stmt->execute();
    $result = $stmt->get_result();
    return $result->fetch_assoc()['exists'] ?? false;
}

/**
 * Bir tabloya yeni bir sütun ekler (yoksa)
 * 
 * @param mysqli $db Veritabanı bağlantısı
 * @param string $tableName Tablo adı
 * @param string $columnName Sütun adı
 * @param string $columnDef Sütun tanımı (örn. "VARCHAR(100) DEFAULT NULL")
 * @return bool İşlem başarılı mı
 */
function addColumnIfNotExists($db, $tableName, $columnName, $columnDef) {
    if (!columnExists($db, $tableName, $columnName)) {
        error_log("Sütun kontrol: '$tableName.$columnName' bulunamadı, ekleniyor...");
        
        $addSQL = "ALTER TABLE $tableName ADD COLUMN $columnName $columnDef";
        
        try {
            $success = $db->query($addSQL);
            
            if ($success) {
                error_log("BAŞARILI: '$tableName.$columnName' sütunu eklendi");
                return true;
            } else {
                error_log("HATA: '$tableName.$columnName' sütunu eklenemedi: " . $db->error);
                return false;
            }
        } catch (Exception $e) {
            error_log("HATA: Sütun ekleme hatası: " . $e->getMessage());
            return false;
        }
    }
    
    return false;
}

/**
 * Veritabanı için gerekli olan temel tabloların tümünü kontrol eder ve gerekirse oluşturur
 * 
 * @param mysqli $db Veritabanı bağlantısı
 * @return array İşlem sonuçları
 */
function ensureCoreTables($db) {
    $results = [];
    
    // 1. Settings tablosu kontrol/oluşturma
    $settingsSQL = "CREATE TABLE settings (
        id INT PRIMARY KEY,
        site_name VARCHAR(100) NOT NULL DEFAULT 'ŞikayetVar',
        site_description TEXT,
        admin_email VARCHAR(255),
        maintenance_mode BOOLEAN DEFAULT FALSE,
        email_notifications BOOLEAN DEFAULT TRUE,
        push_notifications BOOLEAN DEFAULT TRUE,
        new_post_notifications BOOLEAN DEFAULT TRUE,
        new_user_notifications BOOLEAN DEFAULT TRUE,
        api_key VARCHAR(100),
        webhook_url VARCHAR(255),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )";
    
    $settingsInitSQL = "INSERT INTO settings (
        id, site_name, site_description, admin_email, 
        maintenance_mode, email_notifications, push_notifications, 
        new_post_notifications, new_user_notifications, 
        api_key, webhook_url
    ) VALUES (
        1, 'ŞikayetVar', 'Belediye ve Valilik''e yönelik şikayet ve öneri paylaşım platformu', 
        'admin@sikayetvar.com', FALSE, TRUE, TRUE, TRUE, TRUE, 
        'henüz oluşturulmadı', 'https://sikayetvar.com/api/webhook'
    )";
    
    $results['settings'] = ensureTableExists($db, 'settings', $settingsSQL, $settingsInitSQL);
    
    // 2. Kategoriler tablosu kontrol/oluşturma
    $categoriesSQL = "CREATE TABLE categories (
        id SERIAL PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        description TEXT,
        icon_name VARCHAR(50),
        parent_id INTEGER DEFAULT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )";
    
    $categoriesInitSQL = "INSERT INTO categories (name, description, icon_name) VALUES 
        ('Altyapı', 'Su, elektrik, doğalgaz, kanalizasyon gibi altyapı sorunları', 'construction'),
        ('Ulaşım', 'Toplu taşıma, yollar, trafik ve ulaşım sorunları', 'directions_bus'),
        ('Çevre', 'Çevre düzeni, park, bahçe ve peyzaj sorunları', 'nature'),
        ('Temizlik', 'Çöp toplama ve genel temizlik hizmetleri sorunları', 'cleaning_services'),
        ('Güvenlik', 'Asayiş ve güvenlikle ilgili sorunlar', 'security'),
        ('Eğitim', 'Okul, eğitim ve kütüphane hizmetleri sorunları', 'school'),
        ('Sağlık', 'Sağlık hizmetleri ile ilgili sorunlar', 'local_hospital'),
        ('Kültür & Sanat', 'Kültürel etkinlikler ve sanatsal faaliyetler', 'theaters'),
        ('Diğer', 'Diğer sorun ve öneriler', 'help')
    ";
    
    $results['categories'] = ensureTableExists($db, 'categories', $categoriesSQL, $categoriesInitSQL);
    
    // 3. Users tablosu kontrol/oluşturma
    $usersSQL = "CREATE TABLE users (
        id SERIAL PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        email VARCHAR(255) NOT NULL UNIQUE,
        username VARCHAR(50) UNIQUE,
        password VARCHAR(255) NOT NULL,
        profile_image_url TEXT,
        bio TEXT,
        level VARCHAR(50) DEFAULT 'newUser',
        points INTEGER DEFAULT 0,
        post_count INTEGER DEFAULT 0,
        comment_count INTEGER DEFAULT 0,
        city_id INTEGER,
        district_id INTEGER,
        is_verified BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )";
    
    $results['users'] = ensureTableExists($db, 'users', $usersSQL);
    
    // 4. Şehirler tablosu kontrol/oluşturma
    $citiesSQL = "CREATE TABLE cities (
        id SERIAL PRIMARY KEY,
        name VARCHAR(50) NOT NULL,
        description TEXT,
        population INTEGER DEFAULT 0,
        area INTEGER DEFAULT 0,
        mayor_name VARCHAR(100),
        mayor_party VARCHAR(100),
        website VARCHAR(255),
        phone VARCHAR(20),
        email VARCHAR(255),
        social_media TEXT,
        problem_solving_rate DECIMAL(5,2) DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )";
    
    $results['cities'] = ensureTableExists($db, 'cities', $citiesSQL);
    
    // 5. İlçeler tablosu kontrol/oluşturma
    $districtsSQL = "CREATE TABLE districts (
        id SERIAL PRIMARY KEY,
        city_id INTEGER NOT NULL,
        name VARCHAR(50) NOT NULL,
        description TEXT,
        population INTEGER DEFAULT 0,
        area INTEGER DEFAULT 0,
        mayor_name VARCHAR(100),
        mayor_party VARCHAR(100),
        website VARCHAR(255),
        phone VARCHAR(20),
        email VARCHAR(255),
        social_media TEXT,
        problem_solving_rate DECIMAL(5,2) DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )";
    
    $results['districts'] = ensureTableExists($db, 'districts', $districtsSQL);
    
    // 6. Posts (Şikayetler) tablosu kontrol/oluşturma
    $postsSQL = "CREATE TABLE posts (
        id SERIAL PRIMARY KEY,
        user_id INTEGER NOT NULL,
        title VARCHAR(255) NOT NULL,
        content TEXT NOT NULL,
        post_type VARCHAR(50) DEFAULT 'problem',
        status VARCHAR(50) DEFAULT 'awaitingSolution',
        category_id INTEGER,
        city_id INTEGER,
        district_id INTEGER,
        image_url TEXT,
        location_latitude DECIMAL(10,8),
        location_longitude DECIMAL(11,8),
        view_count INTEGER DEFAULT 0,
        solution_text TEXT,
        response_time_hours INTEGER,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )";
    
    $results['posts'] = ensureTableExists($db, 'posts', $postsSQL);
    
    // 7. Comments (Yorumlar) tablosu kontrol/oluşturma
    $commentsSQL = "CREATE TABLE comments (
        id SERIAL PRIMARY KEY,
        post_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        content TEXT NOT NULL,
        is_official BOOLEAN DEFAULT FALSE,
        is_solution BOOLEAN DEFAULT FALSE,
        parent_id INTEGER DEFAULT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )";
    
    $results['comments'] = ensureTableExists($db, 'comments', $commentsSQL);
    
    // 8. Media (Dosyalar) tablosu kontrol/oluşturma
    $mediaSQL = "CREATE TABLE media (
        id SERIAL PRIMARY KEY,
        post_id INTEGER,
        comment_id INTEGER,
        user_id INTEGER,
        file_type VARCHAR(50) NOT NULL,
        file_url TEXT NOT NULL,
        file_name VARCHAR(255),
        file_size INTEGER,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )";
    
    $results['media'] = ensureTableExists($db, 'media', $mediaSQL);
    
    // 9. User Likes (Beğeniler) tablosu kontrol/oluşturma
    $userLikesSQL = "CREATE TABLE user_likes (
        id SERIAL PRIMARY KEY,
        user_id INTEGER NOT NULL,
        post_id INTEGER,
        comment_id INTEGER,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        CONSTRAINT unique_post_like UNIQUE (user_id, post_id),
        CONSTRAINT unique_comment_like UNIQUE (user_id, comment_id)
    )";
    
    $results['user_likes'] = ensureTableExists($db, 'user_likes', $userLikesSQL);
    
    // 10. Banned Words (Yasaklı Kelimeler) tablosu kontrol/oluşturma
    $bannedWordsSQL = "CREATE TABLE banned_words (
        id SERIAL PRIMARY KEY,
        word VARCHAR(100) NOT NULL UNIQUE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )";
    
    $results['banned_words'] = ensureTableExists($db, 'banned_words', $bannedWordsSQL);
    
    // 11. Notifications (Bildirimler) tablosu kontrol/oluşturma
    $notificationsSQL = "CREATE TABLE notifications (
        id SERIAL PRIMARY KEY,
        user_id INTEGER NOT NULL,
        content TEXT NOT NULL,
        notification_type VARCHAR(50) NOT NULL,
        related_id INTEGER,
        is_read BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )";
    
    $results['notifications'] = ensureTableExists($db, 'notifications', $notificationsSQL);
    
    // 12. Surveys (Anketler) tablosu kontrol/oluşturma
    $surveysSQL = "CREATE TABLE surveys (
        id SERIAL PRIMARY KEY,
        title VARCHAR(255) NOT NULL,
        description TEXT,
        scope_type VARCHAR(50) DEFAULT 'general',
        city_id INTEGER,
        district_id INTEGER,
        start_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        end_date TIMESTAMP,
        created_by INTEGER,
        is_active BOOLEAN DEFAULT TRUE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )";
    
    $results['surveys'] = ensureTableExists($db, 'surveys', $surveysSQL);
    
    // 13. Survey Options (Anket Seçenekleri) tablosu kontrol/oluşturma
    $surveyOptionsSQL = "CREATE TABLE survey_options (
        id SERIAL PRIMARY KEY,
        survey_id INTEGER NOT NULL,
        option_text TEXT NOT NULL,
        option_order INTEGER DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )";
    
    $results['survey_options'] = ensureTableExists($db, 'survey_options', $surveyOptionsSQL);
    
    // 14. Survey Regional Results (Anket Bölgesel Sonuçları) tablosu kontrol/oluşturma
    $surveyRegionalResultsSQL = "CREATE TABLE survey_regional_results (
        id SERIAL PRIMARY KEY,
        survey_id INTEGER NOT NULL,
        option_id INTEGER NOT NULL,
        city_id INTEGER,
        district_id INTEGER,
        vote_count INTEGER DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )";
    
    $results['survey_regional_results'] = ensureTableExists($db, 'survey_regional_results', $surveyRegionalResultsSQL);
    
    // Anket örnek verilerini ekleyelim (eğer hiç anket yoksa)
    $checkSurveysSQL = "SELECT COUNT(*) as count FROM surveys";
    $checkResult = $db->query($checkSurveysSQL);
    if ($checkResult && $checkResult->fetch_assoc()['count'] == 0) {
        try {
            // Örnek anket
            $demoSurveySQL = "INSERT INTO surveys (title, description, scope_type) 
                             VALUES ('Belediye Hizmetleri Memnuniyet Anketi', 
                                    'Yaşadığınız şehirdeki belediye hizmetlerinden memnuniyetinizi değerlendirin.', 
                                    'city')";
            $db->query($demoSurveySQL);
            
            // Anket ID'sini al
            $surveyId = $db->insert_id();
            
            if ($surveyId > 0) {
                // Anket seçeneklerini ekle
                $optionsSQL = "INSERT INTO survey_options (survey_id, option_text, option_order) VALUES 
                    ($surveyId, 'Çok memnunum', 1),
                    ($surveyId, 'Memnunum', 2),
                    ($surveyId, 'Kararsızım', 3),
                    ($surveyId, 'Memnun değilim', 4),
                    ($surveyId, 'Hiç memnun değilim', 5)";
                $db->query($optionsSQL);
                
                // İkinci örnek anket
                $demoSurvey2SQL = "INSERT INTO surveys (title, description, scope_type) 
                                 VALUES ('Şehir içi Ulaşım Anketi', 
                                        'Şehir içi ulaşım hizmetleri hakkında görüşlerinizi belirtin.', 
                                        'general')";
                $db->query($demoSurvey2SQL);
                
                $surveyId2 = $db->insert_id();
                
                if ($surveyId2 > 0) {
                    // Anket seçeneklerini ekle
                    $options2SQL = "INSERT INTO survey_options (survey_id, option_text, option_order) VALUES 
                        ($surveyId2, 'Toplu taşıma', 1),
                        ($surveyId2, 'Özel araç', 2),
                        ($surveyId2, 'Taksi', 3),
                        ($surveyId2, 'Bisiklet', 4),
                        ($surveyId2, 'Yürüyüş', 5)";
                    $db->query($options2SQL);
                }
            }
        } catch (Exception $e) {
            error_log("Örnek anket verileri eklenirken hata: " . $e->getMessage());
        }
    }
    
    return $results;
}