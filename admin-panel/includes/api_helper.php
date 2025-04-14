<?php
/**
 * ŞikayetVar - API Yardımcı Fonksiyonları
 */

/**
 * API yanıtı gönderir
 * 
 * @param int $statusCode HTTP durum kodu
 * @param bool $success İşlem başarılı mı?
 * @param string $message Mesaj
 * @param mixed $data Veriler (null olabilir)
 */
function sendApiResponse($statusCode, $success, $message, $data = null) {
    http_response_code($statusCode);
    
    $response = [
        'success' => $success,
        'message' => $message,
    ];
    
    if ($data !== null) {
        $response['data'] = $data;
    }
    
    echo json_encode($response, JSON_UNESCAPED_UNICODE);
    exit;
}

/**
 * JSON verisi doğrular
 * 
 * @param array $data Kontrol edilecek veri
 * @param array $requiredFields Gerekli alanlar
 * @return bool Tüm gerekli alanlar var mı?
 */
function validateJsonData($data, $requiredFields) {
    if (!is_array($data)) {
        return false;
    }
    
    foreach ($requiredFields as $field) {
        if (!isset($data[$field]) || empty($data[$field])) {
            return false;
        }
    }
    
    return true;
}

/**
 * POST verilerini JSON olarak alır
 * 
 * @param array $requiredFields Gerekli alanlar (opsiyonel)
 * @return array|false Veri veya hata durumunda false
 */
function getJsonPostData($requiredFields = []) {
    $data = json_decode(file_get_contents('php://input'), true);
    
    if (!$data) {
        return false;
    }
    
    if (!empty($requiredFields) && !validateJsonData($data, $requiredFields)) {
        return false;
    }
    
    return $data;
}

/**
 * Yeni bir UUID oluşturur
 * 
 * @return string UUID v4
 */
function generateUuid() {
    // UUID v4 rastgele 
    return sprintf(
        '%04x%04x-%04x-%04x-%04x-%04x%04x%04x',
        // 32 bit zaman
        mt_rand(0, 0xffff), mt_rand(0, 0xffff),
        
        // 16 bit zaman
        mt_rand(0, 0xffff),
        
        // 16 bit sürüm 4
        mt_rand(0, 0x0fff) | 0x4000,
        
        // 16 bit yüksek bit 2 varyantı
        mt_rand(0, 0x3fff) | 0x8000,
        
        // 48 bit node id
        mt_rand(0, 0xffff), mt_rand(0, 0xffff), mt_rand(0, 0xffff)
    );
}