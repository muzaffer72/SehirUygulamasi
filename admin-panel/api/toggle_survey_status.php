<?php
/**
 * ŞikayetVar Admin Panel - Anket Durumu Değiştir API
 * Bu API, anketlerin aktif/pasif durumunu değiştirir
 */

// CORS ve JSON başlıkları
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json; charset=UTF-8');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// OPTIONS isteğini işle (preflight)
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Veritabanı bağlantısı
require_once '../db_connection.php';

// JSON olarak gelen veriyi al
$input_data = json_decode(file_get_contents('php://input'), true);

// POST verileri yoksa girişi JSON'dan al
if (empty($_POST)) {
    $_POST = $input_data;
}

try {
    // İstek parametrelerini kontrol et
    if (!isset($_POST['survey_id']) || !isset($_POST['is_active'])) {
        throw new Exception('Geçersiz istek parametreleri');
    }
    
    $survey_id = intval($_POST['survey_id']);
    $is_active = $_POST['is_active'] ? 'true' : 'false';
    
    // Durumu güncelle
    $query = "UPDATE surveys SET is_active = ? WHERE id = ?";
    $stmt = $pdo->prepare($query);
    $result = $stmt->execute([$is_active, $survey_id]);
    
    if ($result) {
        echo json_encode([
            'success' => true,
            'is_active' => $is_active === 'true',
            'message' => 'Anket durumu başarıyla güncellendi'
        ]);
    } else {
        throw new Exception('Anket durumu güncellenirken bir hata oluştu');
    }
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}