<?php
require_once '../db_connection.php';
// $conn değişkenini doğrudan db_connection.php'den alıyoruz (global değişken)

header('Content-Type: application/json');

// Post ID kontrol et
$post_id = isset($_GET['post_id']) ? (int)$_GET['post_id'] : 0;

if ($post_id <= 0) {
    echo json_encode(['error' => 'Geçersiz paylaşım ID']);
    exit;
}

try {
    // Yorumları getir
    $query = "
        SELECT c.*, 
               u.username as user_username, 
               u.name as user_name,
               u.profile_image_url as user_image
        FROM comments c
        LEFT JOIN users u ON c.user_id = u.id
        WHERE c.post_id = ?
        ORDER BY c.created_at DESC
    ";
    
    $stmt = $db->prepare($query);
    $stmt->execute([$post_id]);
    $comments = [];
    
    $result = $stmt->get_result();
    if ($result) {
        while ($row = $result->fetch_assoc()) {
            $comments[] = $row;
        }
    } else {
        // Alternatif yöntem - manuel veri çekme
        $pgQuery = str_replace('?', '$1', $query);
        $pgResult = pg_query_params($conn, $pgQuery, [$post_id]);
        if ($pgResult) {
            while ($row = pg_fetch_assoc($pgResult)) {
                $comments[] = $row;
            }
        }
    }
    
    // Yorumları JSON olarak döndür
    echo json_encode([
        'success' => true,
        'count' => count($comments),
        'comments' => $comments
    ]);
    
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'error' => 'Yorumlar alınırken bir hata oluştu: ' . $e->getMessage()
    ]);
}
?>