<?php
/**
 * Nöbetçi Eczaneler Eklentisi - Ana Dosya
 * 
 * Bu eklenti, il ve ilçe bazlı nöbetçi eczane bilgilerini görüntüler.
 * Harita entegrasyonu ve mesafeye göre sıralama özellikleri sunar.
 */

// Eklenti aktif edildiğinde çalışacak işlevler
function pharmacy_plugin_init() {
    // Eklenti kurulumu tamamlandı, gerekli sayfaları oluştur
    error_log("Nöbetçi Eczaneler eklentisi başlatıldı");
    
    // Admin panel için eczane sayfasını kopyala (varsa)
    if (!file_exists(__DIR__ . '/../../pages/duty_pharmacies.php')) {
        if (file_exists(__DIR__ . '/templates/admin_page.php')) {
            copy(__DIR__ . '/templates/admin_page.php', __DIR__ . '/../../pages/duty_pharmacies.php');
            error_log("Nöbetçi Eczaneler admin sayfası oluşturuldu");
        }
    }
}

// Eklenti devre dışı bırakıldığında çalışacak temizleme işlevi
function pharmacy_plugin_cleanup() {
    error_log("Nöbetçi Eczaneler eklentisi devre dışı bırakıldı");
}

// Eklenti ayarlarını alma fonksiyonu
function get_pharmacy_settings($db) {
    global $plugin_config;
    
    // Veritabanında kayıtlı ayarları al veya varsayılanları kullan
    if (!isset($plugin_config) || empty($plugin_config)) {
        // Ayarlar dosyasını dahil et
        require_once __DIR__ . '/settings.php';
        
        // Veritabanından eklenti yapılandırmasını al
        $plugin_config = getPluginConfig($db, 'duty_pharmacies');
        
        // Varsayılan değerleri ayarlanmayan alanlar için kullan
        foreach ($plugin_settings as $key => $setting) {
            if (!isset($plugin_config[$key])) {
                $plugin_config[$key] = $setting['default'] ?? '';
            }
        }
    }
    
    return $plugin_config;
}

// API'den eczane verilerini getirme işlevi
function fetch_duty_pharmacies($city, $district = null, $lat = null, $lng = null) {
    global $db;
    
    // Eklenti ayarlarını al
    $settings = get_pharmacy_settings($db);
    
    // API endpoint'ini ayarlardan al
    $api_endpoint = $settings['api_endpoint'] ?? 'http://0.0.0.0:5001/pharmacies';
    
    // API parametrelerini oluştur
    $params = ['city' => $city];
    
    if ($district) {
        $params['district'] = $district;
    }
    
    if ($lat && $lng && ($settings['show_distance'] ?? false)) {
        $params['lat'] = $lat;
        $params['lng'] = $lng;
    }
    
    // Maksimum gösterilecek eczane sayısı
    $limit = intval($settings['display_count'] ?? 10);
    if ($limit > 0) {
        $params['limit'] = $limit;
    }
    
    // URL oluştur
    $url = $api_endpoint . '?' . http_build_query($params);
    
    // API'ye istek yap
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_TIMEOUT, 10);
    
    $response = curl_exec($ch);
    $error = curl_error($ch);
    $status_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    
    curl_close($ch);
    
    // Hata kontrolü
    if ($error) {
        error_log("Nöbetçi eczane API hatası: $error");
        return ['error' => 'API bağlantı hatası: ' . $error];
    }
    
    if ($status_code != 200) {
        error_log("Nöbetçi eczane API durum kodu hatası: $status_code");
        return ['error' => 'API durum kodu hatası: ' . $status_code];
    }
    
    // JSON yanıtını çözümle
    $data = json_decode($response, true);
    
    if (json_last_error() !== JSON_ERROR_NONE) {
        error_log("Nöbetçi eczane API JSON çözümleme hatası: " . json_last_error_msg());
        return ['error' => 'JSON çözümleme hatası: ' . json_last_error_msg()];
    }
    
    return $data;
}

// Eczane verilerini önbellekten alma veya API'den çekme
function get_cached_pharmacies($city, $district = null, $lat = null, $lng = null) {
    global $db;
    
    // Eklenti ayarlarını al
    $settings = get_pharmacy_settings($db);
    
    // Önbellek süresini ayarlardan al
    $cache_time = intval($settings['cache_time'] ?? 60); // Varsayılan: 60 dakika
    $cache_key = "pharmacy_" . md5($city . '_' . $district . '_' . $lat . '_' . $lng);
    
    // Önbellekten verileri al
    $cache_data = get_cache_data($cache_key);
    
    if ($cache_data && isset($cache_data['timestamp'])) {
        $cache_age = time() - $cache_data['timestamp'];
        
        // Önbellek süresi dolmadıysa önbellekten al
        if ($cache_age < ($cache_time * 60)) {
            return $cache_data['data'];
        }
    }
    
    // Önbellekte yok veya süresi dolmuş, API'den al
    $pharmacy_data = fetch_duty_pharmacies($city, $district, $lat, $lng);
    
    // Başarılıysa önbelleğe kaydet
    if (!isset($pharmacy_data['error'])) {
        set_cache_data($cache_key, $pharmacy_data);
    }
    
    return $pharmacy_data;
}

// Önbellekten veri alma
function get_cache_data($key) {
    global $db;
    
    $query = "SELECT data, created_at FROM cache WHERE cache_key = ?";
    
    try {
        $stmt = $db->prepare($query);
        $stmt->bind_param('s', $key);
        $stmt->execute();
        $result = $stmt->get_result();
        
        if ($row = $result->fetch_assoc()) {
            return [
                'data' => json_decode($row['data'], true),
                'timestamp' => strtotime($row['created_at'])
            ];
        }
    } catch (Exception $e) {
        error_log("Önbellek okuma hatası: " . $e->getMessage());
    }
    
    return null;
}

// Önbelleğe veri kaydetme
function set_cache_data($key, $data) {
    global $db;
    
    // Önbellek tablosunu kontrol et
    ensure_cache_table($db);
    
    // Verileri JSON olarak serialize et
    $json_data = json_encode($data);
    
    // Veriyi kaydet veya güncelle
    $query = "INSERT INTO cache (cache_key, data, created_at) 
              VALUES (?, ?, NOW()) 
              ON CONFLICT (cache_key) 
              DO UPDATE SET data = EXCLUDED.data, created_at = NOW()";
    
    try {
        $stmt = $db->prepare($query);
        $stmt->bind_param('ss', $key, $json_data);
        $stmt->execute();
    } catch (Exception $e) {
        error_log("Önbelleğe yazma hatası: " . $e->getMessage());
        
        // PostgreSQL dışındaki veritabanları için alternatif kod
        try {
            // Önce kayıt var mı kontrol et
            $check_query = "SELECT 1 FROM cache WHERE cache_key = ?";
            $check_stmt = $db->prepare($check_query);
            $check_stmt->bind_param('s', $key);
            $check_stmt->execute();
            $check_result = $check_stmt->get_result();
            
            if ($check_result->num_rows > 0) {
                // Güncelle
                $update_query = "UPDATE cache SET data = ?, created_at = NOW() WHERE cache_key = ?";
                $update_stmt = $db->prepare($update_query);
                $update_stmt->bind_param('ss', $json_data, $key);
                $update_stmt->execute();
            } else {
                // Ekle
                $insert_query = "INSERT INTO cache (cache_key, data, created_at) VALUES (?, ?, NOW())";
                $insert_stmt = $db->prepare($insert_query);
                $insert_stmt->bind_param('ss', $key, $json_data);
                $insert_stmt->execute();
            }
        } catch (Exception $e2) {
            error_log("Alternatif önbelleğe yazma hatası: " . $e2->getMessage());
        }
    }
}

// Önbellek tablosunu oluştur
function ensure_cache_table($db) {
    // Tablo var mı kontrol et
    $check_query = "SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'cache'
    )";
    
    try {
        $stmt = $db->prepare($check_query);
        $stmt->execute();
        $result = $stmt->get_result();
        $exists = $result->fetch_assoc()['exists'] ?? false;
        
        if (!$exists) {
            // Tablo yok, oluştur
            $create_query = "CREATE TABLE cache (
                cache_key VARCHAR(255) PRIMARY KEY,
                data TEXT NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )";
            
            $db->query($create_query);
            error_log("Önbellek tablosu oluşturuldu");
        }
    } catch (Exception $e) {
        error_log("Önbellek tablosu kontrolünde hata: " . $e->getMessage());
        
        // Alternatif yöntem ile tablo var mı kontrol et
        try {
            $alt_check = $db->query("SHOW TABLES LIKE 'cache'");
            
            if ($alt_check && $alt_check->num_rows == 0) {
                // Tablo yok, oluştur
                $create_query = "CREATE TABLE cache (
                    cache_key VARCHAR(255) PRIMARY KEY,
                    data TEXT NOT NULL,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )";
                
                $db->query($create_query);
                error_log("Önbellek tablosu alternatif yöntemle oluşturuldu");
            }
        } catch (Exception $e2) {
            error_log("Alternatif önbellek tablosu kontrolünde hata: " . $e2->getMessage());
        }
    }
}

// Eklenti başlama ve sonlanma fonksiyonlarını ayarla
register_plugin_hooks();

function register_plugin_hooks() {
    // Eklenti kancaları tanımla (plugin_manager.php'de kullanılacak)
    if (!function_exists('register_activation_hook')) {
        function register_activation_hook($plugin_slug, $callback) {
            // Bu sadece bir yer tutucu - gerçek uygulama plugin_manager.php'de yapılır
        }
    }
    
    if (!function_exists('register_deactivation_hook')) {
        function register_deactivation_hook($plugin_slug, $callback) {
            // Bu sadece bir yer tutucu - gerçek uygulama plugin_manager.php'de yapılır
        }
    }
    
    // Aktivasyon ve deaktivasyon kancalarını kaydet
    register_activation_hook('duty_pharmacies', 'pharmacy_plugin_init');
    register_deactivation_hook('duty_pharmacies', 'pharmacy_plugin_cleanup');
}

// Eklenti başlatıldı
pharmacy_plugin_init();
?>