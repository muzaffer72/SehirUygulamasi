<?php
require_once '../db_connection.php';

header('Content-Type: application/json');

// API güvenliği - sadece POST isteklerini kabul et
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode([
        'success' => false, 
        'error' => 'Sadece POST istekleri kabul edilir.'
    ]);
    exit;
}

// POST verilerini al
$post_data = json_decode(file_get_contents('php://input'), true);

// Yorum ID kontrolü
$comment_id = isset($post_data['comment_id']) ? (int)$post_data['comment_id'] : null;

if (!$comment_id) {
    echo json_encode([
        'success' => false, 
        'error' => 'Geçersiz yorum ID.'
    ]);
    exit;
}

try {
    // Yorum silme işlemi
    $delete_comment = "DELETE FROM comments WHERE id = ?";
    $stmt = $db->prepare($delete_comment);
    $stmt->bind_param("i", $comment_id);
    $stmt->execute();
    
    // Etkilenen satır sayısını kontrol et
    if ($db->affected_rows > 0) {
        echo json_encode([
            'success' => true,
            'message' => 'Yorum başarıyla silindi.',
            'deleted_comment_id' => $comment_id
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'error' => 'Yorum bulunamadı veya silinirken bir hata oluştu.'
        ]);
    }
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'error' => 'Yorum silinirken bir hata oluştu: ' . $e->getMessage()
    ]);
}
?>