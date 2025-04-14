<?php
/**
 * ŞikayetVar - Bildirim API
 * 
 * Bu API, mobil uygulama için bildirim sistemine erişim sağlar:
 * - Bildirim listeleme
 * - Bildirim oluşturma
 * - Bildirimleri okundu işaretleme
 * - Okunmamış bildirim sayısını alma
 */

// Gerekli dosyaları dahil et
require_once '../includes/db_config.php';
require_once '../includes/auth_helper.php';
require_once '../includes/api_helper.php';

// CORS için izinler
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Content-Type: application/json; charset=UTF-8');

// OPTIONS pre-flight isteklerini yakala
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit;
}

// API endpoint'leri
$endpoint = isset($_GET['endpoint']) ? $_GET['endpoint'] : 'list';

// Kullanıcı kimlik doğrulama
$user = authenticateUser();

if (!$user) {
    sendApiResponse(401, false, 'Yetkisiz erişim', null);
    exit;
}

switch ($endpoint) {
    
    // Bildirim listeleme
    case 'list':
        $page = isset($_GET['page']) ? (int)$_GET['page'] : 1;
        $limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 20;
        $offset = ($page - 1) * $limit;
        
        try {
            // Kullanıcının bildirimlerini getir
            $query = "
                SELECT n.*, 
                       u.username as sender_username, 
                       u.name as sender_name, 
                       u.avatar_url as sender_avatar
                FROM notifications n
                LEFT JOIN users u ON n.created_by = u.id
                WHERE n.user_id = ?
                ORDER BY n.created_at DESC
                LIMIT ? OFFSET ?
            ";
            
            $stmt = $db->prepare($query);
            $stmt->bind_param("iii", $user['id'], $limit, $offset);
            $stmt->execute();
            $result = $stmt->get_result();
            $notifications = $result->fetch_all(MYSQLI_ASSOC);
            
            // Toplam sayıyı getir
            $countQuery = "SELECT COUNT(*) as total FROM notifications WHERE user_id = ?";
            $countStmt = $db->prepare($countQuery);
            $countStmt->bind_param("i", $user['id']);
            $countStmt->execute();
            $countResult = $countStmt->get_result();
            $totalCount = $countResult->fetch_assoc()['total'];
            
            // Sonuçları formatla
            $result = [
                'notifications' => $notifications,
                'pagination' => [
                    'total' => (int)$totalCount,
                    'page' => $page,
                    'limit' => $limit,
                    'pages' => ceil($totalCount / $limit)
                ]
            ];
            
            sendApiResponse(200, true, 'Bildirimler başarıyla alındı', $result);
            
        } catch (Exception $e) {
            sendApiResponse(500, false, 'Bildirimler alınırken bir hata oluştu: ' . $e->getMessage(), null);
        }
        break;
        
    // Okunmamış bildirim sayısı
    case 'unread_count':
        try {
            $query = "SELECT COUNT(*) as count FROM notifications WHERE user_id = ? AND is_read = FALSE";
            $stmt = $db->prepare($query);
            $stmt->bind_param("i", $user['id']);
            $stmt->execute();
            $result = $stmt->get_result();
            $count = $result->fetch_assoc()['count'];
            
            sendApiResponse(200, true, 'Okunmamış bildirim sayısı alındı', ['count' => (int)$count]);
            
        } catch (Exception $e) {
            sendApiResponse(500, false, 'Bildirim sayısı alınırken bir hata oluştu: ' . $e->getMessage(), null);
        }
        break;
        
    // Bildirim oluşturma (kullanıcı etkileşimleri için)
    case 'create':
        // POST verisini al
        $data = json_decode(file_get_contents('php://input'), true);
        
        if (!$data) {
            sendApiResponse(400, false, 'Geçersiz istek verisi', null);
            exit;
        }
        
        // Gerekli alanları kontrol et
        $requiredFields = ['user_id', 'title', 'content', 'type'];
        foreach ($requiredFields as $field) {
            if (!isset($data[$field]) || empty($data[$field])) {
                sendApiResponse(400, false, "Eksik alan: $field", null);
                exit;
            }
        }
        
        // Bildirim verileri
        $userId = (int)$data['user_id'];
        $title = $data['title'];
        $content = $data['content'];
        $type = $data['type'];
        $notificationType = isset($data['notification_type']) ? $data['notification_type'] : 'interaction';
        $scopeType = isset($data['scope_type']) ? $data['scope_type'] : 'user';
        $scopeId = isset($data['scope_id']) ? (int)$data['scope_id'] : null;
        $relatedId = isset($data['related_id']) ? (int)$data['related_id'] : null;
        $imageUrl = isset($data['image_url']) ? $data['image_url'] : null;
        $actionUrl = isset($data['action_url']) ? $data['action_url'] : null;
        $isSent = isset($data['is_sent']) ? (bool)$data['is_sent'] : true;
        
        try {
            $query = "
                INSERT INTO notifications (
                    user_id, created_by, title, content, type, 
                    notification_type, scope_type, scope_id, 
                    related_id, image_url, action_url, is_sent
                ) VALUES (
                    ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
                )
            ";
            
            $stmt = $db->prepare($query);
            $stmt->bind_param(
                "iisssssiiissi",
                $userId,
                $user['id'],  // Gönderen kullanıcı
                $title,
                $content,
                $type,
                $notificationType,
                $scopeType,
                $scopeId,
                $relatedId,
                $imageUrl,
                $actionUrl,
                $isSent
            );
            
            $result = $stmt->execute();
            
            if ($result) {
                $notificationId = $stmt->insert_id;
                sendApiResponse(201, true, 'Bildirim başarıyla oluşturuldu', ['id' => $notificationId]);
            } else {
                sendApiResponse(500, false, 'Bildirim oluşturulurken bir hata oluştu', null);
            }
            
        } catch (Exception $e) {
            sendApiResponse(500, false, 'Bildirim oluşturulurken bir hata oluştu: ' . $e->getMessage(), null);
        }
        break;
        
    // Bildirimi okundu olarak işaretle
    case 'mark_read':
        $notificationId = isset($_GET['id']) ? (int)$_GET['id'] : 0;
        
        if ($notificationId <= 0) {
            sendApiResponse(400, false, 'Geçersiz bildirim ID', null);
            exit;
        }
        
        try {
            // Bildirimin kullanıcıya ait olduğunu kontrol et
            $checkQuery = "SELECT id FROM notifications WHERE id = ? AND user_id = ?";
            $checkStmt = $db->prepare($checkQuery);
            $checkStmt->bind_param("ii", $notificationId, $user['id']);
            $checkStmt->execute();
            $checkResult = $checkStmt->get_result();
            
            if ($checkResult->num_rows === 0) {
                sendApiResponse(404, false, 'Bildirim bulunamadı', null);
                exit;
            }
            
            // Bildirimi okundu olarak işaretle
            $updateQuery = "UPDATE notifications SET is_read = TRUE WHERE id = ?";
            $updateStmt = $db->prepare($updateQuery);
            $updateStmt->bind_param("i", $notificationId);
            $result = $updateStmt->execute();
            
            if ($result) {
                sendApiResponse(200, true, 'Bildirim okundu olarak işaretlendi', null);
            } else {
                sendApiResponse(500, false, 'Bildirim işaretlenirken bir hata oluştu', null);
            }
            
        } catch (Exception $e) {
            sendApiResponse(500, false, 'Bildirim işaretlenirken bir hata oluştu: ' . $e->getMessage(), null);
        }
        break;
        
    // Tüm bildirimleri okundu olarak işaretle
    case 'mark_all_read':
        try {
            $query = "UPDATE notifications SET is_read = TRUE WHERE user_id = ? AND is_read = FALSE";
            $stmt = $db->prepare($query);
            $stmt->bind_param("i", $user['id']);
            $result = $stmt->execute();
            
            $affectedRows = $stmt->affected_rows;
            
            if ($result) {
                sendApiResponse(200, true, "$affectedRows bildirim okundu olarak işaretlendi", null);
            } else {
                sendApiResponse(500, false, 'Bildirimler işaretlenirken bir hata oluştu', null);
            }
            
        } catch (Exception $e) {
            sendApiResponse(500, false, 'Bildirimler işaretlenirken bir hata oluştu: ' . $e->getMessage(), null);
        }
        break;
        
    // Geçersiz endpoint
    default:
        sendApiResponse(404, false, 'Geçersiz API endpoint', null);
        break;
}