<?php
require_once '../db_connection.php';

header('Content-Type: application/json');

// Post ID kontrol et
$post_id = isset($_GET['post_id']) ? (int)$_GET['post_id'] : 0;

if ($post_id <= 0) {
    echo json_encode(['error' => 'Geçersiz paylaşım ID']);
    exit;
}

try {
    // Beğenileri getir
    $query = "
        SELECT l.*, 
               u.username as user_username, 
               u.name as user_name,
               u.profile_image_url as user_image
        FROM user_likes l
        LEFT JOIN users u ON l.user_id = u.id
        WHERE l.post_id = ?
        ORDER BY l.created_at DESC
    ";
    
    $stmt = $db->prepare($query);
    $stmt->execute([$post_id]);
    $result = $stmt->get_result();
    $likes = [];
    while ($row = $result->fetch_assoc()) {
        $likes[] = $row;
    }
    
    // Beğenileri JSON olarak döndür
    echo json_encode([
        'success' => true,
        'count' => count($likes),
        'likes' => $likes
    ]);
    
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'error' => 'Beğeniler alınırken bir hata oluştu: ' . $e->getMessage()
    ]);
}
?>