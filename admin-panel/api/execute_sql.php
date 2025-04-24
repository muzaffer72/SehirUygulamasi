<?php
/**
 * ŞikayetVar Admin Panel - SQL Sorgusu Çalıştır API
 * Bu API, SQL sorgularını çalıştırmak için kullanılır (sadece geliştirme için)
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

// JSON verisini al
$input = json_decode(file_get_contents('php://input'), true);

// Sorgu ve parametreleri kontrol et
if (empty($input['query'])) {
    echo json_encode([
        'success' => false,
        'error' => 'Sorgu belirtilmedi'
    ]);
    exit;
}

$query = $input['query'];
$params = $input['params'] ?? [];

try {
    // Sorguyu çalıştır
    $stmt = $db->prepare($query);
    $stmt->execute($params);
    
    // Sorgu bilgisini logla
    error_log("SQL query executed: $query");
    
    // Sorgu sonucunu al
    $result = [];
    if (stripos($query, 'SELECT') === 0 || 
        stripos($query, 'SHOW') === 0 || 
        stripos($query, 'DESCRIBE') === 0 || 
        stripos($query, 'EXPLAIN') === 0 ||
        strpos($query, 'RETURNING') !== false) {
        $pgres = $stmt->get_result();
        if ($pgres) {
            while ($row = $pgres->fetch_assoc()) {
                $result[] = $row;
            }
        }
    }
    
    // Yanıt hazırla
    $response = [
        'success' => true,
        'rows' => $result,
        'rowCount' => count($result)
    ];
    
    echo json_encode($response);
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}