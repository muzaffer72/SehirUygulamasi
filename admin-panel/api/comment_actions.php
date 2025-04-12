<?php
require_once '../db_connection.php';

header('Content-Type: application/json');

// İşlem türünü kontrol et
$action = isset($_POST['action']) ? $_POST['action'] : '';
$comment_id = isset($_POST['comment_id']) ? (int)$_POST['comment_id'] : 0;

if (empty($action) || $comment_id <= 0) {
    echo json_encode(['error' => 'Geçersiz işlem veya yorum ID']);
    exit;
}

try {
    global $pdo;
    $response = ['success' => false];
    
    switch ($action) {
        case 'delete_comment':
            // Yorum silmeden önce post_id'yi al
            $query = "SELECT post_id FROM comments WHERE id = ?";
            $stmt = $pdo->prepare($query);
            $stmt->execute([$comment_id]);
            $comment = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if (!$comment) {
                $response = [
                    'success' => false,
                    'error' => 'Yorum bulunamadı.'
                ];
                break;
            }
            
            $post_id = $comment['post_id'];
            
            // Yorumu sil
            $query = "DELETE FROM comments WHERE id = ?";
            $stmt = $pdo->prepare($query);
            $stmt->execute([$comment_id]);
            $rowCount = $stmt->rowCount();
            
            if ($rowCount > 0) {
                // İlgili paylaşımın yorum sayacını güncelle
                $updateQuery = "UPDATE posts SET comment_count = comment_count - 1 WHERE id = ? AND comment_count > 0";
                $updateStmt = $pdo->prepare($updateQuery);
                $updateStmt->execute([$post_id]);
                
                $response = [
                    'success' => true,
                    'message' => 'Yorum başarıyla silindi.',
                    'post_id' => $post_id
                ];
            } else {
                $response = [
                    'success' => false,
                    'error' => 'Yorum silinirken bir hata oluştu.'
                ];
            }
            break;
            
        case 'ban_user':
            // Kullanıcı ID'sini al
            $query = "SELECT user_id FROM comments WHERE id = ?";
            $stmt = $pdo->prepare($query);
            $stmt->execute([$comment_id]);
            $comment = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if (!$comment || !$comment['user_id']) {
                $response = [
                    'success' => false,
                    'error' => 'Yorum veya kullanıcı bulunamadı.'
                ];
                break;
            }
            
            $user_id = $comment['user_id'];
            
            // Kullanıcıyı banla
            $banQuery = "UPDATE users SET is_banned = TRUE, banned_reason = ? WHERE id = ?";
            $banReason = isset($_POST['ban_reason']) ? $_POST['ban_reason'] : 'Topluluk kurallarını ihlal etme';
            $banStmt = $pdo->prepare($banQuery);
            $banStmt->execute([$banReason, $user_id]);
            $rowCount = $banStmt->rowCount();
            
            if ($rowCount > 0) {
                $response = [
                    'success' => true,
                    'message' => 'Kullanıcı başarıyla yasaklandı.',
                    'user_id' => $user_id
                ];
            } else {
                $response = [
                    'success' => false,
                    'error' => 'Kullanıcı yasaklanırken bir hata oluştu.'
                ];
            }
            break;
            
        case 'report_comment':
            // Yorumu raporla / işaretle
            $query = "UPDATE comments SET is_reported = TRUE, report_reason = ? WHERE id = ?";
            $reportReason = isset($_POST['report_reason']) ? $_POST['report_reason'] : 'Uygunsuz içerik';
            $stmt = $pdo->prepare($query);
            $stmt->execute([$reportReason, $comment_id]);
            $rowCount = $stmt->rowCount();
            
            if ($rowCount > 0) {
                $response = [
                    'success' => true,
                    'message' => 'Yorum başarıyla raporlandı.'
                ];
            } else {
                $response = [
                    'success' => false,
                    'error' => 'Yorum raporlanırken bir hata oluştu.'
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