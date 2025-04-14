<?php
// Search Suggestions API
header('Content-Type: application/json');

require_once '../db_connection.php';

// CORS için gerekli headerlar
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// OPTIONS isteği kontrolü (CORS preflight)
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Sadece GET isteklerine izin ver
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405); // Method Not Allowed
    echo json_encode(['error' => 'Only GET method is allowed']);
    exit;
}

// Veritabanı bağlantısını al
$conn = pg_connect("host={$db_host} port={$db_port} dbname={$db_name} user={$db_user} password={$db_password}");
if (!$conn) {
    http_response_code(500);
    echo json_encode(['error' => 'Database connection error']);
    exit;
}

try {
    // Tablo varsa devam et, yoksa hata döndür
    $check_table = pg_query($conn, "SELECT to_regclass('public.search_suggestions')");
    $table_exists = pg_fetch_result($check_table, 0, 0);
    
    if (!$table_exists) {
        // Tablo yoksa boş dizi döndür
        echo json_encode(['suggestions' => []]);
        exit;
    }

    // Aktif arama önerilerini getir
    $query = "SELECT id, text FROM search_suggestions WHERE is_active = true ORDER BY display_order ASC, text ASC";
    $result = pg_query($conn, $query);
    
    if (!$result) {
        throw new Exception(pg_last_error($conn));
    }
    
    $suggestions = [];
    while ($row = pg_fetch_assoc($result)) {
        $suggestions[] = [
            'id' => (int)$row['id'],
            'text' => $row['text']
        ];
    }
    
    // Sonuçları döndür
    echo json_encode(['suggestions' => $suggestions]);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Server error: ' . $e->getMessage()]);
}
?>