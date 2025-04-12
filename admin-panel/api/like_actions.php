<?php
require_once '../db_connection.php';

header('Content-Type: application/json');

// İşlem türünü kontrol et
$action = isset($_POST['action']) ? $_POST['action'] : '';
$post_id = isset($_POST['post_id']) ? (int)$_POST['post_id'] : 0;

if (empty($action) || $post_id <= 0) {
    echo json_encode(['error' => 'Geçersiz işlem veya paylaşım ID']);
    exit;
}

try {
    global $pdo;
    $response = ['success' => false];
    
    switch ($action) {
        case 'clear_likes':
            // Paylaşıma ait tüm beğenileri sil
            $query = "DELETE FROM user_likes WHERE post_id = ?";
            $stmt = $pdo->prepare($query);
            $stmt->execute([$post_id]);
            $rowCount = $stmt->rowCount();
            
            if ($rowCount > 0) {
                // Paylaşımın beğeni sayacını sıfırla
                $update_post = "UPDATE posts SET likes = 0 WHERE id = ?";
                $update_stmt = $pdo->prepare($update_post);
                $update_stmt->execute([$post_id]);
                
                $response = [
                    'success' => true,
                    'message' => 'Tüm beğeniler başarıyla temizlendi.'
                ];
            } else {
                $response = [
                    'success' => false,
                    'error' => 'Beğeniler temizlenirken bir hata oluştu veya beğeni bulunamadı.'
                ];
            }
            break;
            
        case 'remove_like':
            // Belirli bir beğeniyi sil
            $like_id = isset($_POST['like_id']) ? (int)$_POST['like_id'] : 0;
            
            if ($like_id <= 0) {
                $response = [
                    'success' => false,
                    'error' => 'Geçersiz beğeni ID'
                ];
                break;
            }
            
            $query = "DELETE FROM user_likes WHERE id = ?";
            $stmt = $pdo->prepare($query);
            $stmt->execute([$like_id]);
            $rowCount = $stmt->rowCount();
            
            if ($rowCount > 0) {
                // Paylaşımın beğeni sayacını güncelle
                $update_post = "
                    UPDATE posts p
                    SET likes = (
                        SELECT COUNT(*) FROM user_likes WHERE post_id = p.id
                    )
                    WHERE id = ?
                ";
                $update_stmt = $pdo->prepare($update_post);
                $update_stmt->execute([$post_id]);
                
                $response = [
                    'success' => true,
                    'message' => 'Beğeni başarıyla silindi.'
                ];
            } else {
                $response = [
                    'success' => false,
                    'error' => 'Beğeni silinirken bir hata oluştu veya beğeni bulunamadı.'
                ];
            }
            break;
            
        case 'add_like':
            // Yeni beğeni ekle
            $user_id = isset($_POST['user_id']) ? (int)$_POST['user_id'] : 0;
            
            if ($user_id <= 0) {
                $response = [
                    'success' => false,
                    'error' => 'Geçersiz kullanıcı ID'
                ];
                break;
            }
            
            // Daha önce beğeni var mı kontrol et
            $check_query = "SELECT id FROM user_likes WHERE user_id = ? AND post_id = ?";
            $check_stmt = $pdo->prepare($check_query);
            $check_stmt->execute([$user_id, $post_id]);
            $exists = $check_stmt->fetch(PDO::FETCH_ASSOC);
            
            if ($exists) {
                $response = [
                    'success' => false,
                    'error' => 'Bu kullanıcı zaten bu paylaşımı beğenmiş.'
                ];
                break;
            }
            
            // Yeni beğeni ekle
            $query = "INSERT INTO user_likes (user_id, post_id) VALUES (?, ?)";
            $stmt = $pdo->prepare($query);
            $stmt->execute([$user_id, $post_id]);
            $rowCount = $stmt->rowCount();
            
            if ($rowCount > 0) {
                // Paylaşımın beğeni sayacını güncelle
                $update_post = "UPDATE posts SET likes = likes + 1 WHERE id = ?";
                $update_stmt = $pdo->prepare($update_post);
                $update_stmt->execute([$post_id]);
                
                // Yeni eklenen beğeninin ID'sini al
                $new_id = $pdo->lastInsertId();
                
                // Eklenen beğeninin verilerini getir
                $get_like = "
                    SELECT l.*, 
                           u.username as user_username, 
                           u.name as user_name,
                           u.profile_image_url as user_image
                    FROM user_likes l
                    JOIN users u ON l.user_id = u.id
                    WHERE l.id = ?
                ";
                $get_stmt = $pdo->prepare($get_like);
                $get_stmt->execute([$new_id]);
                $like = $get_stmt->fetch(PDO::FETCH_ASSOC);
                
                $response = [
                    'success' => true,
                    'message' => 'Beğeni başarıyla eklendi.',
                    'like' => $like
                ];
            } else {
                $response = [
                    'success' => false,
                    'error' => 'Beğeni eklenirken bir hata oluştu.'
                ];
            }
            break;
            
        default:
            $response = [
                'success' => false,
                'error' => 'Geçersiz işlem.'
            ];
            break;
    }
    
    echo json_encode($response);
    
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'error' => 'İşlem sırasında bir hata oluştu: ' . $e->getMessage()
    ]);
}
?>