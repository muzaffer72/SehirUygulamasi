<?php
// Veritabanı bağlantısını içe aktar
require_once '../db_connection.php';

// CORS ayarlarını yap
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET');
header('Access-Control-Allow-Headers: Content-Type');

// ID'nin güvenli bir şekilde alınması
$award_id = isset($_GET['id']) ? (int)$_GET['id'] : 0;

if ($award_id <= 0) {
    http_response_code(400);
    echo json_encode(['error' => 'Geçersiz ödül ID\'si']);
    exit;
}

try {
    // Ödül bilgilerini sorgula
    $query = "SELECT * FROM city_awards WHERE id = ?";
    $stmt = $db->prepare($query);
    $stmt->bind_param("i", $award_id);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows === 0) {
        http_response_code(404);
        echo json_encode(['error' => 'Ödül bulunamadı']);
        exit;
    }
    
    // Ödül verilerini döndür
    $award = $result->fetch_assoc();
    
    // Tarih formatını düzelt (YYYY-MM-DD formatına çevir)
    if (isset($award['award_date'])) {
        $award['award_date'] = date('Y-m-d', strtotime($award['award_date']));
    }
    
    echo json_encode($award);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Ödül bilgileri alınırken bir hata oluştu: ' . $e->getMessage()]);
    exit;
}