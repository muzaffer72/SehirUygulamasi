<?php
// Database bağlantısını içe aktar
require_once '../includes/db.php';
require_once '../includes/functions.php';

// CORS ayarları ve API başlıkları
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE');
header('Access-Control-Allow-Headers: Access-Control-Allow-Headers, Content-Type, Access-Control-Allow-Methods, Authorization, X-Requested-With');

// API Request yöntemini belirle
$method = $_SERVER['REQUEST_METHOD'];

// Post ID'sini al
$post_id = isset($_GET['post_id']) ? intval($_GET['post_id']) : null;

// API yanıtı için temel yapı
$response = [
    'success' => false,
    'message' => '',
    'data' => null
];

// GET Methodu: Belirli bir şikayetin memnuniyet puanını veya tüm puanları getir
if ($method === 'GET') {
    try {
        if ($post_id) {
            // Belirli bir şikayetin memnuniyet puanını getir
            $query = "
                SELECT p.id, p.title, p.status, p.satisfaction_rating, 
                       c.name as city_name, d.name as district_name
                FROM posts p
                LEFT JOIN cities c ON p.city_id = c.id
                LEFT JOIN districts d ON p.district_id = d.id
                WHERE p.id = ? AND p.status = 'resolved'
            ";
            
            $stmt = $db->prepare($query);
            $stmt->bind_param('i', $post_id);
            $stmt->execute();
            $result = $stmt->get_result();
            
            if ($result->num_rows > 0) {
                $data = $result->fetch_assoc();
                $response['success'] = true;
                $response['message'] = 'Memnuniyet puanı başarıyla alındı';
                $response['data'] = $data;
            } else {
                $response['message'] = 'Belirtilen şikayet bulunamadı veya çözülmemiş durumda';
            }
        } else {
            // Tüm çözülen şikayetlerin memnuniyet puanlarını getir
            $query = "
                SELECT p.id, p.title, p.status, p.satisfaction_rating, 
                       c.name as city_name, d.name as district_name, 
                       DATE_FORMAT(p.updated_at, '%d.%m.%Y') as resolved_date
                FROM posts p
                LEFT JOIN cities c ON p.city_id = c.id
                LEFT JOIN districts d ON p.district_id = d.id
                WHERE p.status = 'resolved'
                ORDER BY p.updated_at DESC
                LIMIT 100
            ";
            
            $result = $db->query($query);
            
            if ($result->num_rows > 0) {
                $data = [];
                while ($row = $result->fetch_assoc()) {
                    $data[] = $row;
                }
                $response['success'] = true;
                $response['message'] = 'Memnuniyet puanları başarıyla alındı';
                $response['data'] = $data;
            } else {
                $response['message'] = 'Çözülmüş şikayet bulunamadı';
            }
        }
    } catch (Exception $e) {
        $response['message'] = 'Bir hata oluştu: ' . $e->getMessage();
    }
}

// POST Methodu: Yeni memnuniyet puanı ekle veya mevcut puanı güncelle
else if ($method === 'POST') {
    // JSON verisini al
    $data = json_decode(file_get_contents('php://input'));
    
    // Gerekli alanları kontrol et
    if ($data && isset($data->post_id) && isset($data->rating)) {
        $post_id = intval($data->post_id);
        $rating = intval($data->rating);
        $user_id = isset($data->user_id) ? intval($data->user_id) : 0;
        
        // Rating değerini doğrula (1-5 arası)
        if ($rating < 1 || $rating > 5) {
            $response['message'] = 'Memnuniyet puanı 1 ile 5 arasında olmalıdır';
            echo json_encode($response);
            exit;
        }
        
        try {
            // Önce şikayetin var olduğunu ve çözülmüş durumda olduğunu kontrol et
            $check_query = "
                SELECT id, status FROM posts 
                WHERE id = ? AND status = 'resolved'
            ";
            
            $check_stmt = $db->prepare($check_query);
            $check_stmt->bind_param('i', $post_id);
            $check_stmt->execute();
            $check_result = $check_stmt->get_result();
            
            if ($check_result->num_rows === 0) {
                $response['message'] = 'Şikayet bulunamadı veya çözülmemiş durumda';
                echo json_encode($response);
                exit;
            }
            
            // Şikayet memnuniyet puanını güncelle
            $update_query = "
                UPDATE posts SET 
                satisfaction_rating = ?,
                updated_at = NOW()
                WHERE id = ?
            ";
            
            $update_stmt = $db->prepare($update_query);
            $update_stmt->bind_param('ii', $rating, $post_id);
            
            if ($update_stmt->execute()) {
                $response['success'] = true;
                $response['message'] = 'Memnuniyet puanı başarıyla kaydedildi';
                
                // İşlem başarılı olduysa veritabanından güncel kaydı al
                $get_query = "
                    SELECT p.id, p.title, p.status, p.satisfaction_rating,
                           c.name as city_name, d.name as district_name
                    FROM posts p
                    LEFT JOIN cities c ON p.city_id = c.id
                    LEFT JOIN districts d ON p.district_id = d.id
                    WHERE p.id = ?
                ";
                
                $get_stmt = $db->prepare($get_query);
                $get_stmt->bind_param('i', $post_id);
                $get_stmt->execute();
                $get_result = $get_stmt->get_result();
                
                if ($get_result->num_rows > 0) {
                    $response['data'] = $get_result->fetch_assoc();
                }
            } else {
                $response['message'] = 'Memnuniyet puanı güncellenirken bir hata oluştu';
            }
        } catch (Exception $e) {
            $response['message'] = 'Bir hata oluştu: ' . $e->getMessage();
        }
    } else {
        $response['message'] = 'Eksik veya hatalı veri gönderildi';
    }
}

// Yanıtı JSON olarak döndür
echo json_encode($response);
?>