<?php
/**
 * ŞikayetVar Admin Panel - İlçeleri Getir API
 * Bu API, belirli bir şehre ait ilçeleri getirmek için kullanılır
 */

// CORS ve JSON başlıkları
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json; charset=UTF-8');

// Veritabanı bağlantısı
require_once '../db_connection.php';
// $db değişkeni db_connection.php dosyasında tanımlanmış durumda

// Şehir ID'sini kontrol et
if (!isset($_GET['city_id']) || empty($_GET['city_id'])) {
    echo json_encode([
        'success' => false,
        'error' => 'Şehir ID\'si gereklidir'
    ]);
    exit;
}

$city_id = intval($_GET['city_id']);

try {
    // İlçeleri getir
    $query = "
        SELECT id, name
        FROM districts
        WHERE city_id = ?
        ORDER BY name ASC
    ";
    
    $stmt = $db->prepare($query);
    $stmt->execute([$city_id]);
    $result = $stmt->get_result();
    
    $districts = [];
    while ($row = $result->fetch_assoc()) {
        $districts[] = $row;
    }
    
    echo json_encode([
        'success' => true,
        'districts' => $districts
    ]);
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}