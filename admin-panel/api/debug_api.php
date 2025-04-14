<?php
// Hata raporlama ayarlarını aç (tanılama için)
error_reporting(E_ALL);
ini_set('display_errors', 1);

// CORS başlıkları (güvenlik için üretim ortamında daha kısıtlayıcı ayarlanmalıdır)
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json");

// Veritabanı bağlantısı
require_once '../db_connection.php';
$db = $conn;

// API hata ayıklama için fonksiyonlar
function debugQuery($query, $params = []) {
    global $db;
    
    try {
        $stmt = $db->prepare($query);
        
        if (!empty($params)) {
            // Parametrelerin bağlanması
            $types = '';
            foreach ($params as $param) {
                if (is_int($param)) {
                    $types .= 'i';
                } elseif (is_float($param)) {
                    $types .= 'd';
                } else {
                    $types .= 's';
                }
            }
            
            $stmt->bind_param($types, ...$params);
        }
        
        $stmt->execute();
        $result = $stmt->get_result();
        
        $data = [];
        while ($row = $result->fetch_assoc()) {
            $data[] = $row;
        }
        
        return [
            'success' => true,
            'query' => $query,
            'params' => $params,
            'result_count' => count($data),
            'data' => $data
        ];
        
    } catch (Exception $e) {
        return [
            'success' => false,
            'query' => $query,
            'params' => $params,
            'error' => $e->getMessage()
        ];
    }
}

// Yorumlar için test sorgusu
function testCommentsQuery($post_id = 1) {
    $query = "SELECT c.*, 
               u.username as user_username, 
               u.name as user_name, 
               u.avatar as user_avatar 
              FROM comments c
              LEFT JOIN users u ON c.user_id = u.id
              WHERE c.post_id = ?
              ORDER BY c.created_at DESC";
              
    return debugQuery($query, [$post_id]);
}

// Beğeniler için test sorgusu
function testLikesQuery($post_id = 1) {
    $query = "SELECT l.*, u.username as user_username
              FROM likes l
              LEFT JOIN users u ON l.user_id = u.id
              WHERE l.post_id = ?";
              
    return debugQuery($query, [$post_id]);
}

// Tablo şeması kontrolü
function checkTableSchema($table_name) {
    global $db;
    
    try {
        // PostgreSQL'de tablo şemasını kontrol et
        $query = "SELECT column_name, data_type 
                  FROM information_schema.columns 
                  WHERE table_name = ?";
                  
        $result = debugQuery($query, [$table_name]);
        
        // Tablo varlığını kontrol et
        $checkExistsQuery = "SELECT EXISTS (
            SELECT FROM information_schema.tables 
            WHERE table_name = ?
        )";
        
        $existsResult = debugQuery($checkExistsQuery, [$table_name]);
        
        return [
            'table_name' => $table_name,
            'exists' => $existsResult['data'][0]['exists'] ?? false,
            'schema' => $result
        ];
        
    } catch (Exception $e) {
        return [
            'table_name' => $table_name,
            'error' => $e->getMessage()
        ];
    }
}

// Hangi test yapılacak?
$action = $_GET['action'] ?? 'all';
$post_id = intval($_GET['post_id'] ?? 1);

$response = [];

switch ($action) {
    case 'comments':
        $response = testCommentsQuery($post_id);
        break;
        
    case 'likes':
        $response = testLikesQuery($post_id);
        break;
        
    case 'schema':
        $table = $_GET['table'] ?? 'comments';
        $response = checkTableSchema($table);
        break;
        
    case 'all':
    default:
        $response = [
            'comments' => testCommentsQuery($post_id),
            'likes' => testLikesQuery($post_id),
            'schemas' => [
                'comments' => checkTableSchema('comments'),
                'likes' => checkTableSchema('likes'),
                'posts' => checkTableSchema('posts'),
                'users' => checkTableSchema('users')
            ]
        ];
        break;
}

// JSON yanıtını gönder
echo json_encode($response, JSON_PRETTY_PRINT);
?>