<?php
/**
 * Nöbetçi Eczane API Endpointleri
 * 
 * Bu dosya, nöbetçi eczane verilerini çeken Python API'a istek atıp
 * sonuçları JSON formatında döndüren endpointleri içerir.
 */

// Endpoint: /api/pharmacies
// HTTP Method: GET
// Parametreler: city (zorunlu), district (opsiyonel)
// Açıklama: Belirli bir şehir ve isteğe bağlı olarak ilçe için nöbetçi eczaneleri döndürür
function get_pharmacies($request) {
    // API etkin mi kontrol et
    $pharmacy_api_enabled = get_setting('pharmacy_api_enabled', '0');
    if ($pharmacy_api_enabled !== '1') {
        return [
            'status' => 'error',
            'message' => 'Nöbetçi eczane özelliği şu anda etkin değil',
            'enabled' => false
        ];
    }
    
    // Parametreleri kontrol et
    if (!isset($request['city']) || empty($request['city'])) {
        return [
            'status' => 'error',
            'message' => 'Şehir parametresi gereklidir'
        ];
    }
    
    $city = $request['city'];
    $district = isset($request['district']) && !empty($request['district']) ? $request['district'] : null;
    
    // Python API'ye istek gönder
    $url = "http://localhost:5001/api/pharmacies?city=" . urlencode($city);
    if ($district) {
        $url .= "&district=" . urlencode($district);
    }
    
    try {
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt($ch, CURLOPT_TIMEOUT, 15);
        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        
        if ($httpCode == 200) {
            $data = json_decode($response, true);
            return $data;
        } else {
            return [
                'status' => 'error',
                'message' => 'API isteği başarısız. HTTP Kodu: ' . $httpCode
            ];
        }
    } catch (Exception $e) {
        return [
            'status' => 'error',
            'message' => 'API isteği sırasında hata oluştu: ' . $e->getMessage()
        ];
    }
}

// Endpoint: /api/pharmacies/closest
// HTTP Method: GET
// Parametreler: city (zorunlu), district (opsiyonel), lat (zorunlu), lng (zorunlu), limit (opsiyonel)
// Açıklama: Belirli bir konuma en yakın nöbetçi eczaneleri döndürür
function get_closest_pharmacies($request) {
    // API etkin mi kontrol et
    $pharmacy_api_enabled = get_setting('pharmacy_api_enabled', '0');
    if ($pharmacy_api_enabled !== '1') {
        return [
            'status' => 'error',
            'message' => 'Nöbetçi eczane özelliği şu anda etkin değil',
            'enabled' => false
        ];
    }
    
    // Parametreleri kontrol et
    if (!isset($request['city']) || empty($request['city'])) {
        return [
            'status' => 'error',
            'message' => 'Şehir parametresi gereklidir'
        ];
    }
    
    if (!isset($request['lat']) || !isset($request['lng'])) {
        return [
            'status' => 'error',
            'message' => 'Konum parametreleri (lat, lng) gereklidir'
        ];
    }
    
    $city = $request['city'];
    $district = isset($request['district']) && !empty($request['district']) ? $request['district'] : null;
    $lat = $request['lat'];
    $lng = $request['lng'];
    $limit = isset($request['limit']) ? $request['limit'] : 10;
    
    // Python API'ye istek gönder
    $url = "http://localhost:5001/api/pharmacies/closest?city=" . urlencode($city) . 
           "&lat=" . urlencode($lat) . "&lng=" . urlencode($lng) . "&limit=" . urlencode($limit);
    
    if ($district) {
        $url .= "&district=" . urlencode($district);
    }
    
    try {
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt($ch, CURLOPT_TIMEOUT, 15);
        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        
        if ($httpCode == 200) {
            $data = json_decode($response, true);
            return $data;
        } else {
            return [
                'status' => 'error',
                'message' => 'API isteği başarısız. HTTP Kodu: ' . $httpCode
            ];
        }
    } catch (Exception $e) {
        return [
            'status' => 'error',
            'message' => 'API isteği sırasında hata oluştu: ' . $e->getMessage()
        ];
    }
}

// Helper: Ayarları veritabanından oku
function get_setting($key, $default = null) {
    global $pdo;
    
    try {
        $stmt = $pdo->prepare("SELECT setting_value FROM settings WHERE setting_key = ?");
        $stmt->execute([$key]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($result) {
            return $result['setting_value'];
        }
    } catch (PDOException $e) {
        error_log("Ayar okuma hatası: " . $e->getMessage());
    }
    
    return $default;
}