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
    $stmt = $pdo->prepare("
        SELECT id, name
        FROM districts
        WHERE city_id = ?
        ORDER BY name ASC
    ");
    
    $stmt->execute([$city_id]);
    $districts = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
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