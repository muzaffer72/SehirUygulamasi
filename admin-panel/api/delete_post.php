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

// Post ID kontrolü
$post_id = isset($post_data['post_id']) ? (int)$post_data['post_id'] : null;

if (!$post_id) {
    echo json_encode([
        'success' => false, 
        'error' => 'Geçersiz şikayet ID.'
    ]);
    exit;
}

try {
    // Veritabanı işlemleri için transaction başlat
    $db->begin_transaction();
    
    // 1. Önce şikayetle ilgili tüm beğenileri sil
    $delete_likes = "DELETE FROM user_likes WHERE post_id = ?";
    $stmt_likes = $db->prepare($delete_likes);
    $stmt_likes->bind_param("i", $post_id);
    $stmt_likes->execute();
    
    // 2. Şikayetle ilgili tüm yorumları sil
    $delete_comments = "DELETE FROM comments WHERE post_id = ?";
    $stmt_comments = $db->prepare($delete_comments);
    $stmt_comments->bind_param("i", $post_id);
    $stmt_comments->execute();
    
    // 3. Şikayetle ilgili medya kayıtlarını ve dosyalarını sil
    // Önce medya dosyalarının yollarını al
    $get_media = "SELECT file_path FROM post_media WHERE post_id = ?";
    $stmt_get_media = $db->prepare($get_media);
    $stmt_get_media->bind_param("i", $post_id);
    $stmt_get_media->execute();
    $result = $stmt_get_media->get_result();
    
    // Dosya sisteminden fiziksel dosyaları sil
    while ($media = $result->fetch_assoc()) {
        $file_path = '../' . $media['file_path'];
        if (file_exists($file_path)) {
            @unlink($file_path);
        }
    }
    
    // Veritabanından medya kayıtlarını sil
    $delete_media = "DELETE FROM post_media WHERE post_id = ?";
    $stmt_delete_media = $db->prepare($delete_media);
    $stmt_delete_media->bind_param("i", $post_id);
    $stmt_delete_media->execute();
    
    // 4. Son olarak şikayetin kendisini sil
    $delete_post = "DELETE FROM posts WHERE id = ?";
    $stmt_post = $db->prepare($delete_post);
    $stmt_post->bind_param("i", $post_id);
    $stmt_post->execute();
    
    // İşlemler başarılıysa değişiklikleri kaydet
    $db->commit();
    
    echo json_encode([
        'success' => true,
        'message' => 'Şikayet ve ilgili tüm veriler başarıyla silindi.',
        'deleted_post_id' => $post_id
    ]);
} catch (Exception $e) {
    // Hata oluşursa tüm değişiklikleri geri al
    $db->rollback();
    
    echo json_encode([
        'success' => false,
        'error' => 'Şikayet silinirken bir hata oluştu: ' . $e->getMessage()
    ]);
}
?>