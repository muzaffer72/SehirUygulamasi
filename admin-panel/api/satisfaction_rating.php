<?php
// CORS ayarları
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header('Content-Type: application/json; charset=utf-8');

// OPTIONS istekleri için hızlı yanıt (Pre-flight)
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Veritabanı bağlantısını al
require_once '../db_connection.php';

// JSON yanıtı için fonksiyon
function sendResponse($success, $message, $data = null) {
    $response = [
        'success' => $success,
        'message' => $message
    ];
    
    if ($data !== null) {
        $response['data'] = $data;
    }
    
    echo json_encode($response);
    exit;
}

// Memnuniyet derecelendirmesi ekleme
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // JSON verilerini al
    $input = json_decode(file_get_contents('php://input'), true);
    
    // Gerekli alanları kontrol et
    if (!isset($input['post_id']) || !isset($input['rating'])) {
        sendResponse(false, 'Eksik parametre: post_id ve rating gerekli');
    }
    
    $postId = (int)$input['post_id'];
    $rating = (int)$input['rating'];
    $userId = isset($input['user_id']) ? (int)$input['user_id'] : 0;
    
    // Doğrulama kontrolleri
    if ($postId <= 0) {
        sendResponse(false, 'Geçersiz post_id değeri');
    }
    
    if ($rating < 1 || $rating > 5) {
        sendResponse(false, 'Derecelendirme 1-5 arasında olmalıdır');
    }
    
    try {
        // Paylaşımın var olup olmadığını ve kullanıcının yetkisi olup olmadığını kontrol et
        $checkQuery = "SELECT id, user_id, status FROM posts WHERE id = $postId";
        $checkResult = pg_query($conn, $checkQuery);
        
        if (!$checkResult) {
            throw new Exception("Veritabanı sorgusu başarısız: " . pg_last_error($conn));
        }
        
        $post = pg_fetch_assoc($checkResult);
        
        if (!$post) {
            sendResponse(false, 'Belirtilen şikayet bulunamadı');
        }
        
        // Şikayetin durumunu kontrol et - sadece çözülmüş şikayetler derecelendirilebilir
        if ($post['status'] !== 'solved') {
            sendResponse(false, 'Sadece çözülmüş şikayetler için memnuniyet derecelendirmesi yapılabilir');
        }
        
        // Kullanıcı yetki kontrolü - sadece şikayeti oluşturan kullanıcı derecelendirebilir
        if ($userId > 0 && $post['user_id'] != $userId) {
            sendResponse(false, 'Bu şikayet için derecelendirme yapma yetkiniz yok');
        }
        
        // Memnuniyet puanını güncelle
        $updateQuery = "UPDATE posts SET satisfaction_rating = $rating WHERE id = $postId";
        $updateResult = pg_query($conn, $updateQuery);
        
        if (!$updateResult) {
            throw new Exception("Güncelleme sorgusu başarısız: " . pg_last_error($conn));
        }
        
        // Bildirim oluştur (sistem bildirimi)
        if ($rating >= 4) {
            // Yüksek puanlar için teşekkür bildirimi
            $notificationTitle = "Geri bildiriminiz için teşekkürler!";
            $notificationContent = "Şikayetinizin çözümünden memnun olduğunuzu öğrenmek bizi mutlu etti. Sizin için daha iyi hizmet sunmaya devam edeceğiz.";
        } else {
            // Düşük puanlar için geliştirme bildirimi
            $notificationTitle = "Geri bildiriminiz alındı";
            $notificationContent = "Şikayetinizin çözümüyle ilgili değerlendirmenizi aldık. Hizmet kalitemizi artırmak için çalışmaya devam ediyoruz.";
        }
        
        if ($post['user_id'] > 0) {
            $insertNotificationQuery = "
                INSERT INTO notifications 
                (user_id, title, content, type, source_id, source_type, created_at) 
                VALUES 
                ({$post['user_id']}, '$notificationTitle', '$notificationContent', 'system', $postId, 'post', NOW())
            ";
            
            pg_query($conn, $insertNotificationQuery);
        }
        
        sendResponse(true, 'Memnuniyet derecelendirmesi başarıyla kaydedildi', ['rating' => $rating]);
    } catch (Exception $e) {
        sendResponse(false, 'Bir hata oluştu: ' . $e->getMessage());
    }
}

// Memnuniyet derecelendirmesini görüntüleme
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    // Şikayet ID'sini al
    $postId = isset($_GET['post_id']) ? (int)$_GET['post_id'] : 0;
    
    if ($postId <= 0) {
        sendResponse(false, 'Geçersiz post_id değeri');
    }
    
    try {
        // Şikayetin derecelendirmesini al
        $query = "SELECT id, title, status, satisfaction_rating FROM posts WHERE id = $postId";
        $result = pg_query($conn, $query);
        
        if (!$result) {
            throw new Exception("Veritabanı sorgusu başarısız: " . pg_last_error($conn));
        }
        
        $post = pg_fetch_assoc($result);
        
        if (!$post) {
            sendResponse(false, 'Belirtilen şikayet bulunamadı');
        }
        
        sendResponse(true, 'Memnuniyet derecelendirmesi alındı', [
            'post_id' => $post['id'],
            'title' => $post['title'],
            'status' => $post['status'],
            'satisfaction_rating' => $post['satisfaction_rating']
        ]);
    } catch (Exception $e) {
        sendResponse(false, 'Bir hata oluştu: ' . $e->getMessage());
    }
}

// Desteklenmeyen HTTP metodu
sendResponse(false, 'Desteklenmeyen HTTP metodu');
?>