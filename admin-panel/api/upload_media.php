<?php
// Veritabanı bağlantısı
require_once '../db_config.php';
require_once '../db_connection.php';
$db = $conn;

// CORS başlıkları
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

// Yükleme için klasör oluştur
$uploads_dir = '../uploads';
if (!file_exists($uploads_dir)) {
    mkdir($uploads_dir, 0777, true);
}

// POST talebinde olduğunu kontrol et
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(['error' => 'Sadece POST istekleri kabul edilir']);
    exit;
}

// Dosya ve post_id kontrol et
if (!isset($_FILES['media']) || !isset($_POST['post_id'])) {
    echo json_encode(['error' => 'Dosya ve post_id gereklidir']);
    exit;
}

$post_id = intval($_POST['post_id']);
$media_type = isset($_POST['media_type']) ? $_POST['media_type'] : 'image';

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
    
    $uploaded_files = [];
    $errors = [];
    
    // Çoklu dosya yükleme için kontrol
    $files = [];
    
    if (is_array($_FILES['media']['name'])) {
        // Çoklu dosya
        $fileCount = count($_FILES['media']['name']);
        
        for ($i = 0; $i < $fileCount; $i++) {
            $files[] = [
                'name' => $_FILES['media']['name'][$i],
                'type' => $_FILES['media']['type'][$i],
                'tmp_name' => $_FILES['media']['tmp_name'][$i],
                'error' => $_FILES['media']['error'][$i],
                'size' => $_FILES['media']['size'][$i]
            ];
        }
    } else {
        // Tekli dosya
        $files[] = $_FILES['media'];
    }
    
    foreach ($files as $file) {
        // Hata kontrolü
        if ($file['error'] !== UPLOAD_ERR_OK) {
            $errors[] = 'Dosya yükleme hatası: ' . $file['error'];
            continue;
        }
        
        // Dosya boyutu kontrolü (10MB)
        if ($file['size'] > 10 * 1024 * 1024) {
            $errors[] = 'Dosya boyutu çok büyük (maksimum 10MB): ' . $file['name'];
            continue;
        }
        
        // Dosya türü kontrolü
        $allowed_image_types = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
        $allowed_video_types = ['video/mp4', 'video/webm', 'video/ogg'];
        
        if ($media_type === 'image' && !in_array($file['type'], $allowed_image_types)) {
            $errors[] = 'Geçersiz resim formatı: ' . $file['name'] . ' (' . $file['type'] . ')';
            continue;
        } elseif ($media_type === 'video' && !in_array($file['type'], $allowed_video_types)) {
            $errors[] = 'Geçersiz video formatı: ' . $file['name'] . ' (' . $file['type'] . ')';
            continue;
        }
        
        // Dosya adını güvenli hale getir
        $file_name = time() . '_' . preg_replace('/[^a-zA-Z0-9.-]/', '_', $file['name']);
        
        // Dosya yolunu oluştur
        $file_path = $uploads_dir . '/' . $file_name;
        
        // Dosyayı yükle
        if (move_uploaded_file($file['tmp_name'], $file_path)) {
            // URL'yi oluştur
            $file_url = 'uploads/' . $file_name;
            
            // Veritabanına kaydet
            $media_query = "INSERT INTO media (post_id, type, url) VALUES (?, ?, ?)";
            $media_stmt = $db->prepare($media_query);
            $media_stmt->bind_param("iss", $post_id, $media_type, $file_url);
            
            if ($media_stmt->execute()) {
                $media_id = $db->insert_id;
                $uploaded_files[] = [
                    'id' => $media_id,
                    'post_id' => $post_id,
                    'type' => $media_type,
                    'url' => $file_url,
                    'original_name' => $file['name']
                ];
            } else {
                $errors[] = 'Veritabanı kaydı sırasında hata: ' . $media_stmt->error;
            }
        } else {
            $errors[] = 'Dosya yükleme başarısız: ' . $file['name'];
        }
    }
    
    // Sonuçları döndür
    echo json_encode([
        'success' => count($uploaded_files) > 0,
        'uploaded_files' => $uploaded_files,
        'errors' => $errors,
        'post_id' => $post_id
    ]);
    
} catch (Exception $e) {
    echo json_encode([
        'error' => 'Veritabanı hatası: ' . $e->getMessage()
    ]);
}
?>