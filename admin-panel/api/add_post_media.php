<?php
// Veritabanı bağlantısı
require_once '../db_config.php';
require_once '../db_connection.php';
$db = $conn;

// CORS başlıkları
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

// POST talebinde olduğunu kontrol et
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(['error' => 'Sadece POST istekleri kabul edilir']);
    exit;
}

// Gelen verileri al
$post_data = json_decode(file_get_contents('php://input'), true);

// Post ID ve medya parametrelerini kontrol et
if (!isset($post_data['post_id']) || empty($post_data['post_id']) || !isset($post_data['media_items']) || !is_array($post_data['media_items'])) {
    echo json_encode(['error' => 'Post ID ve medya öğeleri gereklidir']);
    exit;
}

$post_id = intval($post_data['post_id']);
$media_items = $post_data['media_items'];

try {
    // Postu getir
    $post_query = "SELECT * FROM posts WHERE id = ?";
    $post_stmt = $db->prepare($post_query);
    $post_stmt->bind_param("i", $post_id);
    $post_stmt->execute();
    $post_result = $post_stmt->get_result();
    $post = $post_result->fetch_assoc();
    
    if (!$post) {
        echo json_encode(['error' => 'Post bulunamadı']);
        exit;
    }
    
    // Medya öğelerini ekle
    $added_items = [];
    
    foreach ($media_items as $media) {
        if (!isset($media['type']) || !isset($media['url'])) {
            continue;
        }
        
        $type = $media['type']; // 'image' veya 'video'
        $url = $media['url'];
        
        // Caption alanı veritabanında bulunmadığı için kaldırılıyor
        $media_query = "INSERT INTO media (post_id, type, url) VALUES (?, ?, ?)";
        $media_stmt = $db->prepare($media_query);
        $media_stmt->bind_param("iss", $post_id, $type, $url);
        $media_result = $media_stmt->execute();
        
        if ($media_result) {
            $added_items[] = [
                'id' => $db->lastInsertId ?? $db->insert_id ?? 0,
                'post_id' => $post_id,
                'type' => $type,
                'url' => $url
            ];
        }
    }
    
    if (count($added_items) > 0) {
        echo json_encode([
            'success' => true,
            'message' => 'Medya öğeleri başarıyla eklendi',
            'post_id' => $post_id,
            'media_items' => $added_items
        ]);
    } else {
        echo json_encode([
            'error' => 'Medya öğeleri eklenirken bir hata oluştu veya geçerli öğe bulunamadı'
        ]);
    }
    
} catch (Exception $e) {
    echo json_encode([
        'error' => 'Veritabanı hatası: ' . $e->getMessage()
    ]);
}
?>