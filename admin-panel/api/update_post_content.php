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

// Post ID ve içerik parametrelerini kontrol et
if (!isset($post_data['post_id']) || empty($post_data['post_id']) || !isset($post_data['content']) || empty($post_data['content']) || !isset($post_data['title']) || empty($post_data['title'])) {
    echo json_encode(['error' => 'Post ID, başlık ve içerik gereklidir']);
    exit;
}

$post_id = intval($post_data['post_id']);
$title = $post_data['title'];
$content = $post_data['content'];

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
    
    // Post içeriğini güncelle
    $update_query = "UPDATE posts SET title = ?, content = ? WHERE id = ?";
    $update_stmt = $db->prepare($update_query);
    $update_stmt->bind_param("ssi", $title, $content, $post_id);
    $update_result = $update_stmt->execute();
    
    if ($update_result) {
        echo json_encode([
            'success' => true,
            'message' => 'Post içeriği başarıyla güncellendi',
            'post_id' => $post_id,
            'title' => $title,
            'content' => $content
        ]);
    } else {
        echo json_encode([
            'error' => 'Post içeriği güncellenirken bir hata oluştu'
        ]);
    }
    
} catch (Exception $e) {
    echo json_encode([
        'error' => 'Veritabanı hatası: ' . $e->getMessage()
    ]);
}
?>