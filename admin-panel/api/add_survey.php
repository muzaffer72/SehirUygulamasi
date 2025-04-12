<?php
/**
 * ŞikayetVar Admin Panel - Anket Ekle API
 * Bu API, yeni anket ekleme işlevselliği sağlar
 */

// CORS ve JSON başlıkları
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json; charset=UTF-8');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

// OPTIONS isteğini işle (preflight)
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Veritabanı bağlantısı
require_once '../db_connection.php';

try {
    // Form verilerini al
    $title = trim($_POST['title'] ?? '');
    $short_title = trim($_POST['short_title'] ?? '');
    $description = trim($_POST['description'] ?? '');
    $category_id = intval($_POST['category_id'] ?? 0);
    $scope_type = trim($_POST['scope_type'] ?? '');
    $city_id = ($_POST['city_id'] ?? '') !== '' ? intval($_POST['city_id']) : null;
    $district_id = ($_POST['district_id'] ?? '') !== '' ? intval($_POST['district_id']) : null;
    $start_date = trim($_POST['start_date'] ?? '');
    $end_date = trim($_POST['end_date'] ?? '');
    $total_users = intval($_POST['total_users'] ?? 1000);
    $is_active = isset($_POST['is_active']) ? true : false;
    $options = $_POST['options'] ?? [];
    
    // Veri doğrulama
    $errors = [];
    
    if (empty($title)) {
        $errors[] = 'Anket başlığı gereklidir';
    }
    
    if (empty($short_title)) {
        $errors[] = 'Kısa başlık gereklidir';
    }
    
    if (empty($description)) {
        $errors[] = 'Açıklama gereklidir';
    }
    
    if ($category_id <= 0) {
        $errors[] = 'Geçerli bir kategori seçmelisiniz';
    }
    
    if (!in_array($scope_type, ['general', 'city', 'district'])) {
        $errors[] = 'Geçerli bir kapsam türü seçmelisiniz';
    }
    
    if ($scope_type === 'city' && empty($city_id)) {
        $errors[] = 'İl bazlı anketler için bir il seçmelisiniz';
    }
    
    if ($scope_type === 'district' && (empty($city_id) || empty($district_id))) {
        $errors[] = 'İlçe bazlı anketler için bir il ve ilçe seçmelisiniz';
    }
    
    if (empty($start_date)) {
        $errors[] = 'Başlangıç tarihi gereklidir';
    }
    
    if (empty($end_date)) {
        $errors[] = 'Bitiş tarihi gereklidir';
    }
    
    if (strtotime($end_date) <= strtotime($start_date)) {
        $errors[] = 'Bitiş tarihi başlangıç tarihinden sonra olmalıdır';
    }
    
    if (count($options) < 2) {
        $errors[] = 'En az 2 anket seçeneği eklemelisiniz';
    }
    
    // Hata varsa yanıt dön ve sonlandır
    if (!empty($errors)) {
        echo json_encode([
            'success' => false,
            'errors' => $errors
        ]);
        exit;
    }
    
    // İlçe bazlı değilse district_id'yi null yap
    if ($scope_type !== 'district') {
        $district_id = null;
    }
    
    // İl bazlı değilse ve genel ise city_id'yi null yap
    if ($scope_type === 'general') {
        $city_id = null;
    }
    
    // Anket ekle
    $stmt = $pdo->prepare("
        INSERT INTO surveys (
            title, short_title, description, category_id, scope_type, 
            city_id, district_id, start_date, end_date, total_users, is_active, created_at
        ) VALUES (
            ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW()
        )
    ");
    
    $result = $stmt->execute([
        $title, 
        $short_title, 
        $description, 
        $category_id, 
        $scope_type, 
        $city_id, 
        $district_id,
        $start_date, 
        $end_date, 
        $total_users, 
        ($is_active ? 'true' : 'false')
    ]);
    
    if ($result) {
        $survey_id = $pdo->lastInsertId();
        
        // Seçenekleri ekle
        if (!empty($options)) {
            $option_stmt = $pdo->prepare("
                INSERT INTO survey_options (survey_id, text, vote_count)
                VALUES (?, ?, 0)
            ");
            
            foreach ($options as $option_text) {
                if (!empty(trim($option_text))) {
                    $option_stmt->execute([$survey_id, trim($option_text)]);
                }
            }
        }
        
        echo json_encode([
            'success' => true,
            'message' => 'Anket başarıyla eklendi',
            'survey_id' => $survey_id
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'error' => 'Anket eklenirken bir hata oluştu'
        ]);
    }
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}