<?php
// Veritabanı bağlantısı
require_once '../db_config.php';
require_once '../db_connection.php';
$db = $conn;

// CORS başlıkları
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
header('Access-Control-Allow-Methods: DELETE, POST');
header('Access-Control-Allow-Headers: Content-Type');

// POST veya DELETE yöntemini kontrol et
if ($_SERVER['REQUEST_METHOD'] !== 'POST' && $_SERVER['REQUEST_METHOD'] !== 'DELETE') {
    echo json_encode(['error' => 'Sadece POST veya DELETE istekleri kabul edilir']);
    exit;
}

// JSON girdi verilerini al
$input = json_decode(file_get_contents('php://input'), true);

// POST ise body'den media_id'yi al, DELETE ise query string'den al
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $mediaId = isset($input['media_id']) ? intval($input['media_id']) : 0;
} else {
    $mediaId = isset($_GET['media_id']) ? intval($_GET['media_id']) : 0;
}

if (!$mediaId) {
    echo json_encode(['error' => 'Medya ID gereklidir']);
    exit;
}

try {
    // Önce medya öğesini veritabanından al (silmeden önce dosya yolunu almak için)
    $getMediaQuery = "SELECT * FROM media WHERE id = ?";
    $getMediaStmt = $db->prepare($getMediaQuery);
    $getMediaStmt->bind_param("i", $mediaId);
    $getMediaStmt->execute();
    $result = $getMediaStmt->get_result();
    $media = $result->fetch_assoc();
    
    if (!$media) {
        echo json_encode(['error' => 'Medya bulunamadı']);
        exit;
    }
    
    // Medya öğesi dosya yolu mu yoksa URL mi kontrol et
    $fileUrl = $media['url'];
    $isLocalFile = strpos($fileUrl, 'uploads/') === 0;
    $postId = $media['post_id'];
    
    // Eğer yerel dosya ise, fiziksel olarak sil
    if ($isLocalFile) {
        $filePath = '../' . $fileUrl;
        if (file_exists($filePath)) {
            unlink($filePath);
        }
    }
    
    // Veritabanından medya kaydını sil
    $deleteQuery = "DELETE FROM media WHERE id = ?";
    $deleteStmt = $db->prepare($deleteQuery);
    $deleteStmt->bind_param("i", $mediaId);
    
    if ($deleteStmt->execute()) {
        echo json_encode([
            'success' => true,
            'message' => 'Medya başarıyla silindi',
            'media_id' => $mediaId,
            'post_id' => $postId
        ]);
    } else {
        echo json_encode([
            'error' => 'Medya silinirken bir hata oluştu: ' . $deleteStmt->error
        ]);
    }
    
} catch (Exception $e) {
    echo json_encode([
        'error' => 'Veritabanı hatası: ' . $e->getMessage()
    ]);
}
?>