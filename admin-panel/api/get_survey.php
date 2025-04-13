<?php
/**
 * ŞikayetVar Admin Panel - Anket Detayı Getir API
 * Bu API, belirli bir anketin detay bilgilerini getirir
 */

// CORS ve JSON başlıkları
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json; charset=UTF-8');

// Veritabanı bağlantısı
require_once '../db_connection.php';

// Anket ID'sini kontrol et
if (!isset($_GET['id']) || empty($_GET['id'])) {
    echo json_encode([
        'success' => false,
        'error' => 'Anket ID\'si gereklidir'
    ]);
    exit;
}

$surveyId = intval($_GET['id']);

try {
    // Anket bilgilerini getir
    $stmt = $pdo->prepare("
        SELECT s.*, c.name as category_name, 
               city.name as city_name, d.name as district_name
        FROM surveys s
        LEFT JOIN categories c ON s.category_id = c.id
        LEFT JOIN cities city ON s.city_id = CAST(city.id AS INTEGER)
        LEFT JOIN districts d ON s.district_id = d.id
        WHERE s.id = ?
    ");
    
    $stmt->execute([$surveyId]);
    $survey = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$survey) {
        echo json_encode([
            'success' => false,
            'error' => 'Anket bulunamadı'
        ]);
        exit;
    }
    
    // Anket seçeneklerini getir
    $optionsStmt = $pdo->prepare("
        SELECT id, text, vote_count
        FROM survey_options
        WHERE survey_id = ?
        ORDER BY id ASC
    ");
    
    $optionsStmt->execute([$surveyId]);
    $options = $optionsStmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Toplam oy sayısını hesapla
    $totalVotes = 0;
    foreach ($options as $option) {
        $totalVotes += $option['vote_count'];
    }
    
    // Anket ve seçenekleri birleştir
    $survey['options'] = $options;
    $survey['total_votes'] = $totalVotes;
    
    echo json_encode([
        'success' => true,
        'survey' => $survey
    ]);
    
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}