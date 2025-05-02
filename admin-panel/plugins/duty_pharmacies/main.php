<?php
/**
 * Nöbetçi Eczaneler Eklentisi
 * 
 * Bu eklenti, belediye sayfaları için nöbetçi eczane özelliği ekler.
 * Kullanıcılar şehir/ilçe bazında nöbetçi eczaneleri görüntüleyebilir ve yol tarifi alabilir.
 * 
 * @version 1.0.0
 * @author ŞikayetVar Ekibi
 */

// Eklenti fonksiyonlarını tanımla
if (!function_exists('get_duty_pharmacies')) {
    /**
     * Belirli bir şehir ve ilçeye göre nöbetçi eczaneleri getirir
     *
     * @param string $city Şehir adı
     * @param string|null $district İlçe adı (opsiyonel)
     * @return array Eczane listesi
     */
    function get_duty_pharmacies($city, $district = null) {
        $api_url = "http://0.0.0.0:5001/pharmacies?city=" . urlencode($city);
        
        if ($district) {
            $api_url .= "&district=" . urlencode($district);
        }
        
        $response = file_get_contents($api_url);
        if ($response === false) {
            return [
                'error' => 'API ile bağlantı kurulamadı',
                'pharmacies' => []
            ];
        }
        
        $data = json_decode($response, true);
        return $data;
    }
}

if (!function_exists('get_pharmacies_by_location')) {
    /**
     * Konum bilgisine göre en yakın nöbetçi eczaneleri getirir
     *
     * @param string $city Şehir adı
     * @param float $lat Enlem
     * @param float $lng Boylam
     * @param string|null $district İlçe adı (opsiyonel)
     * @param int $limit Maksimum eczane sayısı
     * @return array Eczane listesi
     */
    function get_pharmacies_by_location($city, $lat, $lng, $district = null, $limit = 10) {
        $api_url = "http://0.0.0.0:5001/pharmacies/by_distance?city=" . urlencode($city) . "&lat={$lat}&lng={$lng}&limit={$limit}";
        
        if ($district) {
            $api_url .= "&district=" . urlencode($district);
        }
        
        $response = file_get_contents($api_url);
        if ($response === false) {
            return [
                'error' => 'API ile bağlantı kurulamadı',
                'pharmacies' => []
            ];
        }
        
        $data = json_decode($response, true);
        return $data;
    }
}

if (!function_exists('get_all_cities')) {
    /**
     * Veritabanından tüm şehirleri getirir
     *
     * @param object $db Veritabanı bağlantısı
     * @return array Şehir listesi
     */
    function get_all_cities($db) {
        $result = $db->query("SELECT id, name FROM cities ORDER BY name");
        $cities = [];
        
        while ($row = $result->fetch_assoc()) {
            $cities[] = $row;
        }
        
        return $cities;
    }
}

if (!function_exists('get_districts_by_city')) {
    /**
     * Belirli bir şehre ait ilçeleri getirir
     *
     * @param object $db Veritabanı bağlantısı
     * @param int $city_id Şehir ID
     * @return array İlçe listesi
     */
    function get_districts_by_city($db, $city_id) {
        $result = $db->query("SELECT id, name FROM districts WHERE city_id = " . intval($city_id) . " ORDER BY name");
        $districts = [];
        
        while ($row = $result->fetch_assoc()) {
            $districts[] = $row;
        }
        
        return $districts;
    }
}

if (!function_exists('save_pharmacy_settings')) {
    /**
     * Eczane eklentisi ayarlarını kaydeder
     *
     * @param object $db Veritabanı bağlantısı
     * @param array $settings Ayarlar
     * @return bool Başarılı mı?
     */
    function save_pharmacy_settings($db, $settings) {
        // Mevcut ayarları kontrol et
        $result = $db->query("SELECT * FROM settings WHERE name='pharmacy_settings'");
        
        if ($result->num_rows > 0) {
            // Güncelle
            $json_settings = json_encode($settings);
            $stmt = $db->prepare("UPDATE settings SET value = ? WHERE name = 'pharmacy_settings'");
            $stmt->bind_param('s', $json_settings);
            return $stmt->execute();
        } else {
            // Yeni ekle
            $json_settings = json_encode($settings);
            $stmt = $db->prepare("INSERT INTO settings (name, value) VALUES ('pharmacy_settings', ?)");
            $stmt->bind_param('s', $json_settings);
            return $stmt->execute();
        }
    }
}

if (!function_exists('get_pharmacy_settings')) {
    /**
     * Eczane eklentisi ayarlarını getirir
     *
     * @param object $db Veritabanı bağlantısı
     * @return array Ayarlar
     */
    function get_pharmacy_settings($db) {
        $result = $db->query("SELECT value FROM settings WHERE name='pharmacy_settings'");
        
        if ($result->num_rows > 0) {
            $row = $result->fetch_assoc();
            return json_decode($row['value'], true);
        } else {
            // Varsayılan ayarlar
            return [
                'google_maps_api_key' => '',
                'enable_directions' => true,
                'enable_proximity_search' => true,
                'max_results' => 20,
                'cache_time' => 3600,
                'display_phone' => true,
                'display_address' => true
            ];
        }
    }
}

// Eklenti menülerini kaydeder
function register_pharmacy_menus() {
    $main_menu = [
        'page' => 'duty_pharmacies',
        'title' => 'Nöbetçi Eczaneler',
        'icon' => 'fa-solid fa-prescription-bottle-medical',
        'order' => 50
    ];
    
    add_menu_item($main_menu);
}

// Admin paneli için sayfayı yükle
function load_pharmacy_admin_page() {
    include __DIR__ . '/templates/admin_page.php';
}

// Sayfa yönlendirmelerini kaydet
add_page_route('duty_pharmacies', 'load_pharmacy_admin_page');

// Menüleri kaydet
register_pharmacy_menus();

// Şehirler ve ilçeler için API rotaları
function pharmacy_api_routes() {
    global $db;
    
    if ($_SERVER['REQUEST_URI'] === '/api/cities') {
        header('Content-Type: application/json');
        echo json_encode(get_all_cities($db));
        exit;
    }
    
    if (strpos($_SERVER['REQUEST_URI'], '/api/districts') === 0) {
        $city_id = isset($_GET['city_id']) ? $_GET['city_id'] : 0;
        header('Content-Type: application/json');
        echo json_encode(get_districts_by_city($db, $city_id));
        exit;
    }
}

// API rotalarını ekle
add_action('api_routes', 'pharmacy_api_routes');