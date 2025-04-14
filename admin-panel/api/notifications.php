<?php
/**
 * Bildirim API Endpoint
 * 
 * Bu API, ŞikayetVar mobil uygulamasından bildirimler göndermek için kullanılır.
 * Firebase Cloud Messaging kullanılarak bildirimler gönderilir.
 */

// CORS ve gerekli başlıkları ayarla
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// OPTIONS (preflight) isteği için erken yanıt
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Database connection
require_once '../db_connection.php';
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// API anahtarı kontrolü (gerçek bir uygulamada daha güvenli bir kimlik doğrulama mekanizması kullanın)
// $api_key = $_SERVER['HTTP_X_API_KEY'] ?? '';
// if (!$api_key || $api_key !== 'your_secret_api_key') {
//     http_response_code(401);
//     echo json_encode(['error' => 'Unauthorized - Invalid API Key']);
//     exit;
// }

// POST isteği için bildirim gönderme
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // İstek gövdesini JSON olarak al
    $json_data = file_get_contents('php://input');
    $data = json_decode($json_data, true);
    
    // Gerekli alanları kontrol et
    if (!isset($data['title']) || !isset($data['message'])) {
        http_response_code(400);
        echo json_encode(['error' => 'Bad Request - Missing required fields']);
        exit;
    }
    
    $title = $data['title'];
    $message = $data['message'];
    $target_type = $data['target_type'] ?? 'all';
    $target_id = $data['target_id'] ?? null;
    
    // Geçerli tarihi al
    $created_at = date('Y-m-d H:i:s');
    
    try {
        // Veritabanına bildirim ekle
        $insert_query = "
            INSERT INTO notifications (title, message, target_type, target_id, created_at, status) 
            VALUES (?, ?, ?, ?, ?, 'pending')
        ";
        $insert_stmt = $db->prepare($insert_query);
        $insert_stmt->bind_param("sssss", $title, $message, $target_type, $target_id, $created_at);
        $result = $insert_stmt->execute();
        
        if (!$result) {
            throw new Exception("Veritabanı hatası: " . $db->error());
        }
        
        // Yeni eklenen bildirim ID'sini al
        $notification_id = $db->insert_id();
        
        // Firebase ile bildirimi gönder
        $firebase_result = sendFirebaseNotification($title, $message, $target_type, $target_id);
        
        // Durumu güncelle
        $status = $firebase_result ? 'sent' : 'error';
        $update_query = "UPDATE notifications SET status = ? WHERE id = ?";
        $update_stmt = $db->prepare($update_query);
        $update_stmt->bind_param("si", $status, $notification_id);
        $update_stmt->execute();
        
        // Yanıt döndür
        http_response_code(200);
        echo json_encode([
            'success' => true,
            'message' => $firebase_result ? 'Notification sent successfully' : 'Notification saved but FCM delivery failed',
            'notification_id' => $notification_id,
            'firebase_result' => $firebase_result
        ]);
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Server Error - ' . $e->getMessage()]);
    }
}
// GET isteği için bildirim listesi
else if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $limit = isset($_GET['limit']) ? intval($_GET['limit']) : 20;
    $page = isset($_GET['page']) ? intval($_GET['page']) : 1;
    $offset = ($page - 1) * $limit;
    
    // Bildirim tipine göre filtreleme
    $target_type = isset($_GET['target_type']) ? $_GET['target_type'] : null;
    $target_id = isset($_GET['target_id']) ? intval($_GET['target_id']) : null;
    
    try {
        $query = "
            SELECT n.*, u.username as target_user_name, c.name as target_city_name
            FROM notifications n
            LEFT JOIN users u ON n.target_id = u.id AND n.target_type = 'user'
            LEFT JOIN cities c ON n.target_id = c.id AND n.target_type = 'city'
            WHERE 1=1
        ";
        
        $params = [];
        $types = "";
        
        if ($target_type) {
            $query .= " AND n.target_type = ?";
            $params[] = $target_type;
            $types .= "s";
        }
        
        if ($target_id) {
            $query .= " AND n.target_id = ?";
            $params[] = $target_id;
            $types .= "i";
        }
        
        $query .= " ORDER BY n.created_at DESC LIMIT ? OFFSET ?";
        $params[] = $limit;
        $params[] = $offset;
        $types .= "ii";
        
        $stmt = $db->prepare($query);
        
        if (!empty($params)) {
            $stmt->bind_param($types, ...$params);
        }
        
        $stmt->execute();
        $result = $stmt->get_result();
        
        $notifications = [];
        while ($row = $result->fetch_assoc()) {
            // API yanıtı için temizlenmiş bildirim verisi
            $notifications[] = [
                'id' => intval($row['id']),
                'title' => $row['title'],
                'message' => $row['message'],
                'target_type' => $row['target_type'],
                'target_id' => $row['target_id'] ? intval($row['target_id']) : null,
                'target_name' => getTargetName($row),
                'created_at' => $row['created_at'],
                'status' => $row['status'] ?? 'unknown'
            ];
        }
        
        // Toplam bildirim sayısını al
        $count_query = "
            SELECT COUNT(*) as total 
            FROM notifications
            WHERE 1=1
        ";
        
        $count_params = [];
        $count_types = "";
        
        if ($target_type) {
            $count_query .= " AND target_type = ?";
            $count_params[] = $target_type;
            $count_types .= "s";
        }
        
        if ($target_id) {
            $count_query .= " AND target_id = ?";
            $count_params[] = $target_id;
            $count_types .= "i";
        }
        
        $count_stmt = $db->prepare($count_query);
        
        if (!empty($count_params)) {
            $count_stmt->bind_param($count_types, ...$count_params);
        }
        
        $count_stmt->execute();
        $count_result = $count_stmt->get_result();
        $total = $count_result->fetch_assoc()['total'];
        
        http_response_code(200);
        echo json_encode([
            'success' => true,
            'notifications' => $notifications,
            'pagination' => [
                'total' => intval($total),
                'page' => $page,
                'limit' => $limit,
                'pages' => ceil($total / $limit)
            ]
        ]);
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Server Error - ' . $e->getMessage()]);
    }
} else {
    http_response_code(405);
    echo json_encode(['error' => 'Method Not Allowed']);
}

// Firebase bildirim gönderme fonksiyonu
function sendFirebaseNotification($title, $message, $target_type, $target_id) {
    $firebase_server_key = getenv('FIREBASE_SERVER_KEY');
    
    if (empty($firebase_server_key)) {
        error_log("Firebase Server Key bulunamadı");
        return false;
    }
    
    $url = 'https://fcm.googleapis.com/fcm/send';
    
    // Mesaj içeriğini hazırla
    $notification = [
        'title' => $title,
        'body' => $message,
        'sound' => 'default',
        'badge' => '1',
        'click_action' => 'FLUTTER_NOTIFICATION_CLICK'
    ];
    
    $data = [
        'title' => $title,
        'message' => $message,
        'type' => 'notification',
        'target_type' => $target_type,
        'target_id' => $target_id,
        'timestamp' => time()
    ];
    
    // Hedefi belirle
    $fields = [];
    if ($target_type == 'user' && $target_id) {
        // Kullanıcı token'ını al
        global $db;
        $token_query = "SELECT device_token FROM users WHERE id = ?";
        $token_stmt = $db->prepare($token_query);
        $token_stmt->bind_param("i", $target_id);
        $token_stmt->execute();
        $token_result = $token_stmt->get_result();
        $user = $token_result->fetch_assoc();
        
        if ($user && !empty($user['device_token'])) {
            $fields = [
                'to' => $user['device_token'],
                'notification' => $notification,
                'data' => $data,
                'priority' => 'high'
            ];
        } else {
            error_log("Kullanıcı token'ı bulunamadı. ID: " . $target_id);
            return false;
        }
    } else if ($target_type == 'city' && $target_id) {
        // Şehir konusu
        $topic = 'city_' . $target_id;
        $fields = [
            'to' => '/topics/' . $topic,
            'notification' => $notification,
            'data' => $data,
            'priority' => 'high'
        ];
    } else if ($target_type == 'category' && $target_id) {
        // Kategori konusu
        $topic = 'category_' . $target_id;
        $fields = [
            'to' => '/topics/' . $topic,
            'notification' => $notification,
            'data' => $data,
            'priority' => 'high'
        ];
    } else {
        // Tüm kullanıcılar
        $fields = [
            'to' => '/topics/all',
            'notification' => $notification,
            'data' => $data,
            'priority' => 'high'
        ];
    }
    
    // HTTP isteği için başlıkları hazırla
    $headers = [
        'Authorization: key=' . $firebase_server_key,
        'Content-Type: application/json'
    ];
    
    // cURL ile isteği gönder
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($fields));
    
    $result = curl_exec($ch);
    
    // Hata kontrolü
    if ($result === false) {
        error_log('Firebase Bildirim Hatası: ' . curl_error($ch));
        curl_close($ch);
        return false;
    }
    
    curl_close($ch);
    
    // Başarı kontrolü
    $result_data = json_decode($result, true);
    if (isset($result_data['success']) && $result_data['success'] == 1) {
        error_log('Firebase Bildirim Başarılı: ' . $result);
        return true;
    } else {
        error_log('Firebase Bildirim Başarısız: ' . $result);
        return false;
    }
}

// Hedef adını getirme fonksiyonu
function getTargetName($notification) {
    switch ($notification['target_type']) {
        case 'user':
            return $notification['target_user_name'] ?? 'Bilinmiyor';
        case 'city':
            return $notification['target_city_name'] ?? 'Bilinmiyor';
        case 'category':
            // Kategori adını almak için
            global $db;
            $cat_id = $notification['target_id'];
            if (!$cat_id) return 'Bilinmiyor';
            
            $query = "SELECT name FROM categories WHERE id = ?";
            $stmt = $db->prepare($query);
            $stmt->bind_param("i", $cat_id);
            $stmt->execute();
            $result = $stmt->get_result();
            $row = $result->fetch_assoc();
            
            return $row ? $row['name'] : 'Bilinmiyor';
        default:
            return 'Tümü';
    }
}
?>