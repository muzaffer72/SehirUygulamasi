<?php
/**
 * ŞikayetVar Admin Panel - Anket Güncelle API
 * Bu API, anket güncelleme işlemleri için kullanılır
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
    $survey_id = intval($_POST['survey_id'] ?? 0);
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
    $option_ids = $_POST['option_ids'] ?? [];
    
    // Veri doğrulama
    $errors = [];
    
    if (empty($survey_id)) {
        $errors[] = 'Anket ID\'si gereklidir';
    }
    
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
    
    // Anketi güncelle
    $stmt = $pdo->prepare("
        UPDATE surveys 
        SET title = ?, 
            short_title = ?,
            description = ?,
            category_id = ?,
            scope_type = ?,
            city_id = ?,
            district_id = ?,
            start_date = ?,
            end_date = ?,
            total_users = ?,
            is_active = ?
        WHERE id = ?
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
        ($is_active ? 'true' : 'false'),
        $survey_id
    ]);
    
    if ($result) {
        // Mevcut seçenekleri güncelle
        if (!empty($option_ids) && !empty($options)) {
            $updateOptionStmt = $pdo->prepare("
                UPDATE survey_options
                SET text = ?
                WHERE id = ? AND survey_id = ?
            ");
            
            foreach ($options as $index => $option_text) {
                if (isset($option_ids[$index]) && !empty($option_ids[$index])) {
                    $option_id = intval($option_ids[$index]);
                    if (!empty(trim($option_text))) {
                        $updateOptionStmt->execute([trim($option_text), $option_id, $survey_id]);
                    }
                }
            }
        }
        
        // Yeni seçenekleri ekle (option_id olmayan)
        $newOptions = array_filter($options, function($value, $index) use ($option_ids) {
            return empty($option_ids[$index]);
        }, ARRAY_FILTER_USE_BOTH);
        
        if (!empty($newOptions)) {
            $addOptionStmt = $pdo->prepare("
                INSERT INTO survey_options (survey_id, text, vote_count)
                VALUES (?, ?, 0)
            ");
            
            foreach ($newOptions as $option_text) {
                if (!empty(trim($option_text))) {
                    $addOptionStmt->execute([$survey_id, trim($option_text)]);
                }
            }
        }
        
        echo json_encode([
            'success' => true,
            'message' => 'Anket başarıyla güncellendi'
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'error' => 'Anket güncellenirken bir hata oluştu'
        ]);
    }
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}