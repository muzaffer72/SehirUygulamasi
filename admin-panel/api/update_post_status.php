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

// Post ID ve durum parametrelerini kontrol et
if (!isset($post_data['post_id']) || empty($post_data['post_id']) || !isset($post_data['status']) || empty($post_data['status'])) {
    echo json_encode(['error' => 'Post ID ve durum gereklidir']);
    exit;
}

$post_id = intval($post_data['post_id']);
$status = $post_data['status'];

// Durum değerinin geçerli olduğunu kontrol et
$valid_statuses = ['awaitingSolution', 'inProgress', 'solved', 'rejected'];
if (!in_array($status, $valid_statuses)) {
    echo json_encode(['error' => 'Geçersiz durum değeri. Geçerli değerler: ' . implode(', ', $valid_statuses)]);
    exit;
}

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
    
    // Post durumunu güncelle
    $update_query = "UPDATE posts SET status = ? WHERE id = ?";
    $update_stmt = $db->prepare($update_query);
    $update_stmt->bind_param("si", $status, $post_id);
    $update_result = $update_stmt->execute();
    
    if ($update_result) {
        echo json_encode([
            'success' => true,
            'message' => 'Post durumu başarıyla güncellendi',
            'post_id' => $post_id,
            'new_status' => $status
        ]);
    } else {
        echo json_encode([
            'error' => 'Post durumu güncellenirken bir hata oluştu'
        ]);
    }
    
} catch (Exception $e) {
    echo json_encode([
        'error' => 'Veritabanı hatası: ' . $e->getMessage()
    ]);
}
?>