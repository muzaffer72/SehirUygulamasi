<?php
/**
 * Firebase Cloud Messaging (FCM) API entegrasyonu
 * Bu dosya, ŞikayetVar uygulamasının bildirim sistemini yönetir.
 * 
 * İşlevleri:
 * 1. Kullanıcılara bildirim gönderme
 * 2. Bildirim durumunu kontrol etme
 * 3. Toplu bildirim gönderme
 */

// Gerekli dosyaları dahil et
require_once __DIR__ . '/../includes/config.php';
require_once __DIR__ . '/../includes/db_connection.php';
require_once __DIR__ . '/../includes/api_auth.php';

// API isteklerini sadece yetkili kullanıcılar için kontrol et
// checkApiAuth();

// HTTP isteklerini işle
header('Content-Type: application/json');

// HTTP metodu kontrolü
$method = $_SERVER['REQUEST_METHOD'];

// POST metodu ile gönderilen JSON verisini al
$json_str = file_get_contents('php://input');
$data = json_decode($json_str, true);

// GET ile alınan parametreleri al
if ($method === 'GET') {
    // Bildirim ID'si verilmişse, durumunu döndür
    if (isset($_GET['id'])) {
        $notification_id = intval($_GET['id']);
        
        $query = "SELECT * FROM notifications WHERE id = $1";
        $result = pg_query_params($db_connection, $query, [$notification_id]);
        
        if ($result && pg_num_rows($result) > 0) {
            $notification = pg_fetch_assoc($result);
            
            http_response_code(200);
            echo json_encode([
                'success' => true,
                'notification' => $notification
            ]);
            exit;
        } else {
            http_response_code(404);
            echo json_encode([
                'success' => false,
                'message' => 'Bildirim bulunamadı'
            ]);
            exit;
        }
    }
    
    // Tüm bildirimleri listele
    $query = "SELECT * FROM notifications ORDER BY created_at DESC";
    $result = pg_query($db_connection, $query);
    
    $notifications = [];
    while ($row = pg_fetch_assoc($result)) {
        $notifications[] = $row;
    }
    
    http_response_code(200);
    echo json_encode([
        'success' => true,
        'notifications' => $notifications
    ]);
    exit;
}

// POST metodu ile yeni bildirim oluştur
if ($method === 'POST') {
    // Gerekli alanları kontrol et
    if (!isset($data['title']) || !isset($data['message'])) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Başlık ve mesaj alanları zorunludur'
        ]);
        exit;
    }
    
    $title = $data['title'];
    $message = $data['message'];
    $target_type = isset($data['target_type']) ? $data['target_type'] : 'all';
    $target_id = isset($data['target_id']) ? $data['target_id'] : null;
    
    // Firebase'e bildirim gönder
    $fcm_result = sendFirebaseNotification($title, $message, $target_type, $target_id);
    
    // Bildirimi veritabanına kaydet
    $created_at = date('Y-m-d H:i:s');
    $status = $fcm_result ? 'sent' : 'error';
    
    $query = "INSERT INTO notifications (title, message, target_type, target_id, created_at, status) 
              VALUES ($1, $2, $3, $4, $5, $6) RETURNING id";
    $result = pg_query_params($db_connection, $query, [
        $title, $message, $target_type, $target_id, $created_at, $status
    ]);
    
    if ($result) {
        $row = pg_fetch_assoc($result);
        $notification_id = $row['id'];
        
        http_response_code(201);
        echo json_encode([
            'success' => true,
            'message' => 'Bildirim başarıyla gönderildi',
            'notification_id' => $notification_id,
            'status' => $status
        ]);
        exit;
    } else {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Bildirim kaydedilirken bir hata oluştu',
            'error' => pg_last_error($db_connection)
        ]);
        exit;
    }
}

// DELETE metodu ile bildirim sil
if ($method === 'DELETE') {
    if (!isset($_GET['id'])) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Bildirim ID\'si gereklidir'
        ]);
        exit;
    }
    
    $notification_id = intval($_GET['id']);
    
    $query = "DELETE FROM notifications WHERE id = $1";
    $result = pg_query_params($db_connection, $query, [$notification_id]);
    
    if ($result) {
        http_response_code(200);
        echo json_encode([
            'success' => true,
            'message' => 'Bildirim başarıyla silindi'
        ]);
        exit;
    } else {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Bildirim silinirken bir hata oluştu',
            'error' => pg_last_error($db_connection)
        ]);
        exit;
    }
}

/**
 * Firebase Cloud Messaging ile bildirim gönderir
 * 
 * @param string $title Bildirim başlığı
 * @param string $message Bildirim içeriği
 * @param string $target_type Hedef tipi ('all', 'user', 'city')
 * @param int|null $target_id Hedef ID (kullanıcı veya şehir ID'si)
 * @return bool Gönderim başarılı mı?
 */
function sendFirebaseNotification($title, $message, $target_type = 'all', $target_id = null) {
    global $db_connection;
    
    // FCM API anahtarı
    $fcm_server_key = getenv('FIREBASE_SERVER_KEY');
    
    // Firebase API anahtarı yoksa, hata döndür
    if (empty($fcm_server_key)) {
        error_log("Firebase Server Key bulunamadı!");
        return false;
    }
    
    // FCM mesaj içeriği
    $notification = [
        'title' => $title,
        'body' => $message,
        'sound' => 'default',
        'badge' => '1',
        'icon' => 'ic_notification'
    ];
    
    // Ek veri alanları
    $data = [
        'title' => $title,
        'message' => $message,
        'type' => 'notification',
        'notification_id' => uniqid(),
        'timestamp' => time() * 1000,
    ];
    
    // Hedef türüne göre alıcıları belirle
    $to = null;
    $registration_ids = [];
    
    if ($target_type === 'all') {
        // Tüm kullanıcılara gönder (topic)
        $to = '/topics/all_users';
    } else if ($target_type === 'user' && !empty($target_id)) {
        // Belirli bir kullanıcıya gönder
        $query = "SELECT fcm_token FROM users WHERE id = $1 AND fcm_token IS NOT NULL";
        $result = pg_query_params($db_connection, $query, [$target_id]);
        
        if ($row = pg_fetch_assoc($result)) {
            $registration_ids[] = $row['fcm_token'];
        }
    } else if ($target_type === 'city' && !empty($target_id)) {
        // Belirli bir şehirdeki kullanıcılara gönder
        $data['city_id'] = $target_id;
        $to = '/topics/city_' . $target_id;
    }
    
    // FCM isteği için veri formatını oluştur
    $fields = [
        'notification' => $notification,
        'data' => $data,
        'android' => [
            'notification' => [
                'sound' => 'default',
                'icon' => 'ic_notification',
                'color' => '#1976D2'
            ]
        ],
        'apns' => [
            'payload' => [
                'aps' => [
                    'sound' => 'default'
                ]
            ]
        ]
    ];
    
    // Hedef belirleme
    if (!empty($to)) {
        $fields['to'] = $to;
    } else if (!empty($registration_ids)) {
        $fields['registration_ids'] = $registration_ids;
    } else {
        // Hedef yoksa başarısız olarak işaretle
        return false;
    }
    
    // cURL isteği ile Firebase'e bildirim gönder
    $ch = curl_init();
    
    curl_setopt($ch, CURLOPT_URL, 'https://fcm.googleapis.com/fcm/send');
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Authorization: key=' . $fcm_server_key,
        'Content-Type: application/json'
    ]);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($fields));
    
    $result = curl_exec($ch);
    $http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    
    curl_close($ch);
    
    // Sonuçları logla
    error_log("Firebase bildirim gönderme sonucu: " . $result);
    
    // 200 OK yanıtı alındıysa başarılı kabul et
    return $http_code == 200;
}

// Varsayılan yanıt - 405 Method Not Allowed
http_response_code(405);
echo json_encode([
    'success' => false,
    'message' => 'Desteklenmeyen HTTP metodu'
]);
exit;
?>