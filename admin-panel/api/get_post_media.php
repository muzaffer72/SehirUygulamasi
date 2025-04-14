<?php
// Veritabanı bağlantısı
require_once '../db_connection.php';
// $db değişkeni db_connection.php içinde oluşturuldu

// CORS başlıkları
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET');
header('Access-Control-Allow-Headers: Content-Type');

// Post ID parametresini kontrol et
if (!isset($_GET['post_id']) || empty($_GET['post_id'])) {
    echo json_encode(['error' => 'Post ID gereklidir']);
    exit;
}

$post_id = intval($_GET['post_id']);

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
    
    // Post medyalarını getir
    $media_query = "SELECT * FROM media WHERE post_id = ? ORDER BY id ASC";
    $media_stmt = $db->prepare($media_query);
    $media_stmt->bind_param("i", $post_id);
    $media_stmt->execute();
    $media_result = $media_stmt->get_result();
    $media_items = [];
    
    // fetch_all yerine fetch_assoc kullanarak düzgün bir dizi oluştur
    while ($row = $media_result->fetch_assoc()) {
        $media_items[] = $row;
    }
    
    // Varsayılan resim ve video özellikleri (eğer URL yoksa)
    foreach ($media_items as &$media) {
        if ($media['type'] === 'image' && empty($media['url'])) {
            $media['url'] = 'https://via.placeholder.com/640x360?text=Resim+Bulunamadi';
        } else if ($media['type'] === 'video' && empty($media['url'])) {
            $media['url'] = 'https://www.youtube.com/embed/dQw4w9WgXcQ'; // Varsayılan video
        }
    }
    
    // Yanıt olarak post ve medya bilgilerini döndür
    echo json_encode([
        'success' => true,
        'post' => $post,
        'media' => $media_items
    ]);
    
} catch (Exception $e) {
    echo json_encode([
        'error' => 'Veritabanı hatası: ' . $e->getMessage()
    ]);
}
?>