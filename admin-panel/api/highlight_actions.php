<?php
header('Content-Type: application/json');
require_once '../db_connection.php';
require_once '../functions.php';

// Öne çıkarma işlemleri API'si
// Kullanım:
// POST /api/highlight_actions.php
// action: "highlight" veya "unhighlight"
// post_id: Gönderi ID'si
// duration: Öne çıkarma süresi (gün cinsinden)

$action = isset($_POST['action']) ? $_POST['action'] : '';
$postId = isset($_POST['post_id']) ? intval($_POST['post_id']) : 0;
$duration = isset($_POST['duration']) ? intval($_POST['duration']) : 7; // Varsayılan 7 gün

// Sütunların var olup olmadığını kontrol edelim ve yoksa ekleyelim
try {
    // Sütunları kontrol et
    $checkColumns = $db->query("SELECT column_name FROM information_schema.columns 
                           WHERE table_name = 'posts' AND column_name = 'is_highlighted'");
    
    if ($checkColumns->rowCount() === 0) {
        // Sütunları ekle
        $db->exec("ALTER TABLE posts 
                 ADD COLUMN is_highlighted BOOLEAN DEFAULT FALSE,
                 ADD COLUMN highlighted_at TIMESTAMP,
                 ADD COLUMN highlight_expires_at TIMESTAMP");
        
        logMessage("Öne çıkarma sütunları eklendi: is_highlighted, highlighted_at, highlight_expires_at");
    }
} catch (PDOException $e) {
    logError("Sütun kontrolü sırasında hata: " . $e->getMessage());
    http_response_code(500);
    echo json_encode(['status' => 'error', 'message' => 'Veritabanı şema kontrolü sırasında hata oluştu.']);
    exit;
}

// Gönderi ID kontrolü
if (!$postId) {
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => 'Geçersiz gönderi ID\'si.']);
    exit;
}

// İşlem türüne göre işlem yap
try {
    if ($action === 'highlight') {
        // Gönderiyi öne çıkar
        $expiryDate = date('Y-m-d H:i:s', strtotime("+{$duration} days"));
        
        $stmt = $db->prepare("UPDATE posts 
                            SET is_highlighted = TRUE, 
                                highlighted_at = NOW(), 
                                highlight_expires_at = ?, 
                                highlights = highlights + 1 
                            WHERE id = ?");
        
        $stmt->execute([$expiryDate, $postId]);
        
        if ($stmt->rowCount() > 0) {
            // Başarılı
            echo json_encode([
                'status' => 'success', 
                'message' => 'Gönderi başarıyla öne çıkarıldı.',
                'post_id' => $postId,
                'expiry_date' => $expiryDate
            ]);
            
            logMessage("Gönderi öne çıkarıldı: ID=$postId, Bitiş=$expiryDate");
            
            // Kullanıcıya bildirim gönder
            try {
                // Önce gönderi bilgilerini ve kullanıcı ID'sini al
                $postQuery = $db->prepare("SELECT user_id, title FROM posts WHERE id = ?");
                $postQuery->execute([$postId]);
                $post = $postQuery->fetch(PDO::FETCH_ASSOC);
                
                if ($post) {
                    // Bildirim ekle
                    $notifStmt = $db->prepare("INSERT INTO notifications 
                                           (user_id, title, content, type, source_id, source_type) 
                                           VALUES (?, ?, ?, ?, ?, ?)");
                    
                    $notifStmt->execute([
                        $post['user_id'],
                        'Paylaşımınız Öne Çıkarıldı',
                        "\"" . htmlspecialchars($post['title']) . "\" paylaşımınız yönetici tarafından öne çıkarıldı. Bu paylaşım ana sayfada ve listelerde üst sıralarda gösterilecek.",
                        'highlight',
                        $postId,
                        'post'
                    ]);
                }
            } catch (PDOException $e) {
                // Bildirim gönderilemedi, ama öne çıkarma başarılı oldu
                logError("Bildirim gönderme hatası: " . $e->getMessage());
            }
        } else {
            echo json_encode(['status' => 'error', 'message' => 'Gönderi bulunamadı veya güncellenemedi.']);
        }
    } 
    elseif ($action === 'unhighlight') {
        // Gönderinin öne çıkarma durumunu kaldır
        $stmt = $db->prepare("UPDATE posts 
                            SET is_highlighted = FALSE, 
                                highlighted_at = NULL, 
                                highlight_expires_at = NULL 
                            WHERE id = ?");
        
        $stmt->execute([$postId]);
        
        if ($stmt->rowCount() > 0) {
            echo json_encode([
                'status' => 'success', 
                'message' => 'Gönderinin öne çıkarma durumu kaldırıldı.',
                'post_id' => $postId
            ]);
            
            logMessage("Gönderi öne çıkarma iptal edildi: ID=$postId");
        } else {
            echo json_encode(['status' => 'error', 'message' => 'Gönderi bulunamadı veya güncellenemedi.']);
        }
    }
    elseif ($action === 'list_highlighted') {
        // Öne çıkarılmış gönderileri listele
        $stmt = $db->query("SELECT p.*, 
                          c.name as city_name, 
                          d.name as district_name, 
                          cat.name as category_name,
                          u.name as user_name,
                          u.username as username 
                        FROM posts p
                        LEFT JOIN cities c ON p.city_id = c.id
                        LEFT JOIN districts d ON p.district_id = d.id
                        LEFT JOIN categories cat ON p.category_id = cat.id
                        LEFT JOIN users u ON p.user_id = u.id
                        WHERE p.is_highlighted = TRUE
                        ORDER BY p.highlighted_at DESC");
        
        $highlightedPosts = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        echo json_encode([
            'status' => 'success',
            'posts' => $highlightedPosts,
            'count' => count($highlightedPosts)
        ]);
    }
    elseif ($action === 'check_expired') {
        // Süresi dolmuş öne çıkarmaları kontrol et ve kaldır
        $stmt = $db->prepare("UPDATE posts 
                            SET is_highlighted = FALSE
                            WHERE is_highlighted = TRUE 
                            AND highlight_expires_at IS NOT NULL
                            AND highlight_expires_at < NOW()
                            RETURNING id, title");
        
        $stmt->execute();
        $expiredPosts = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        echo json_encode([
            'status' => 'success',
            'expired_count' => count($expiredPosts),
            'expired_posts' => $expiredPosts
        ]);
        
        if (count($expiredPosts) > 0) {
            logMessage("Süresi dolmuş " . count($expiredPosts) . " öne çıkarma kaldırıldı");
        }
    }
    else {
        http_response_code(400);
        echo json_encode(['status' => 'error', 'message' => 'Geçersiz işlem türü. "highlight", "unhighlight", "list_highlighted" veya "check_expired" kullanın.']);
    }
} catch (PDOException $e) {
    logError("Öne çıkarma işlemi sırasında hata: " . $e->getMessage());
    http_response_code(500);
    echo json_encode(['status' => 'error', 'message' => 'Veritabanı işlemi sırasında hata oluştu: ' . $e->getMessage()]);
}
?>