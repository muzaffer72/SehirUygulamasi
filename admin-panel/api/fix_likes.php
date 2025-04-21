<?php
// Bu dosya, like/beğeni işlemlerini doğrudan PostgreSQL üzerinden gerçekleştirir
// Dış sunucudaki sorunlu uygulamalar için alternatif hizmet sağlar

// Hata raporlama ayarlarını yükle - bu API yanıtlarında hata mesajlarının görünmesini engeller
require_once '../php_error_config.php';

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json");

// Preflight OPTIONS istekleri için hemen yanıt
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Veritabanı bağlantısı
require_once '../db_connection.php';
// $db değişkeni db_connection.php dosyasında tanımlanmış durumda
// PDO bağlantısı için pg_pdo.php içeren adapteri kullanalım
require_once '../includes/pg_pdo.php';
$pdo = get_pdo_connection(); // PostgreSQL PDO bağlantısını al

// Yardımcı fonksiyonlar
function sendResponse($data, $statusCode = 200) {
    http_response_code($statusCode);
    echo json_encode($data);
    exit();
}

function sendError($message, $statusCode = 400) {
    http_response_code($statusCode);
    echo json_encode(['error' => $message]);
    exit();
}

/**
 * Belirli bir gönderi için beğenileri al (PDO ile doğrudan PostgreSQL sorgusu)
 */
function getLikesByPostId($post_id) {
    global $pdo;
    
    // Hata günlüğü
    error_log("Beğeniler getiriliyor, post_id: $post_id");
    
    try {
        $query = "SELECT ul.*, u.username as user_username, u.name as user_name
                  FROM user_likes ul
                  LEFT JOIN users u ON ul.user_id = u.id
                  WHERE ul.post_id = :post_id";
                  
        $stmt = $pdo->prepare($query);
        $stmt->bindValue(':post_id', $post_id, PDO::PARAM_INT);
        $stmt->execute();
        
        $likes = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        // Toplam beğeni sayısını sorgula
        $countQuery = "SELECT COUNT(*) FROM user_likes WHERE post_id = :post_id";
        $countStmt = $pdo->prepare($countQuery);
        $countStmt->bindValue(':post_id', $post_id, PDO::PARAM_INT);
        $countStmt->execute();
        $count = $countStmt->fetchColumn();
        
        sendResponse([
            'likes' => $likes, 
            'total' => (int)$count,
            'post_id' => (int)$post_id
        ]);
    } catch (PDOException $e) {
        error_log("Beğeni getirme hatası: " . $e->getMessage());
        sendError('Error fetching likes: ' . $e->getMessage(), 500);
    }
}

/**
 * Yeni bir beğeni ekle (PDO ile doğrudan PostgreSQL sorgusu)
 */
function addLike($data) {
    global $pdo;
    
    if (!isset($data['post_id']) || !isset($data['user_id'])) {
        sendError('Missing required fields: post_id and user_id', 400);
    }
    
    try {
        // Mevcut beğeni kontrolü yap
        $checkQuery = "SELECT COUNT(*) FROM user_likes 
                       WHERE post_id = :post_id AND user_id = :user_id";
        $checkStmt = $pdo->prepare($checkQuery);
        $checkStmt->bindValue(':post_id', $data['post_id'], PDO::PARAM_INT);
        $checkStmt->bindValue(':user_id', $data['user_id'], PDO::PARAM_INT);
        $checkStmt->execute();
        
        if ($checkStmt->fetchColumn() > 0) {
            sendError("User already liked this post", 400);
        }
        
        // Yeni beğeni ekle
        $query = "INSERT INTO user_likes (post_id, user_id, created_at)
                  VALUES (:post_id, :user_id, NOW())
                  RETURNING id";
                  
        $stmt = $pdo->prepare($query);
        $stmt->bindValue(':post_id', $data['post_id'], PDO::PARAM_INT);
        $stmt->bindValue(':user_id', $data['user_id'], PDO::PARAM_INT);
        $stmt->execute();
        
        $like_id = $stmt->fetchColumn();
        
        // Post'un beğeni sayısını güncelle
        $updateQuery = "UPDATE posts SET likes = likes + 1 
                        WHERE id = :post_id";
        $updateStmt = $pdo->prepare($updateQuery);
        $updateStmt->bindValue(':post_id', $data['post_id'], PDO::PARAM_INT);
        $updateStmt->execute();
        
        // Toplam beğeni sayısını getir
        $countQuery = "SELECT COUNT(*) FROM user_likes WHERE post_id = :post_id";
        $countStmt = $pdo->prepare($countQuery);
        $countStmt->bindValue(':post_id', $data['post_id'], PDO::PARAM_INT);
        $countStmt->execute();
        $count = $countStmt->fetchColumn();
        
        sendResponse([
            'like_id' => $like_id,
            'total_likes' => (int)$count,
            'message' => 'Like added successfully'
        ], 201);
    } catch (PDOException $e) {
        error_log("Beğeni ekleme hatası: " . $e->getMessage());
        sendError('Error adding like: ' . $e->getMessage(), 500);
    }
}

/**
 * Beğeni sil (PDO ile doğrudan PostgreSQL sorgusu)
 */
function removeLike($data) {
    global $pdo;
    
    if (!isset($data['post_id']) || !isset($data['user_id'])) {
        sendError('Missing required fields: post_id and user_id', 400);
    }
    
    try {
        // Beğeniyi sil
        $query = "DELETE FROM user_likes 
                  WHERE post_id = :post_id AND user_id = :user_id
                  RETURNING id";
                  
        $stmt = $pdo->prepare($query);
        $stmt->bindValue(':post_id', $data['post_id'], PDO::PARAM_INT);
        $stmt->bindValue(':user_id', $data['user_id'], PDO::PARAM_INT);
        $stmt->execute();
        
        $deletedId = $stmt->fetchColumn();
        
        if (!$deletedId) {
            sendError("Like not found", 404);
        }
        
        // Post'un beğeni sayısını güncelle
        $updateQuery = "UPDATE posts SET likes = GREATEST(likes - 1, 0) 
                        WHERE id = :post_id";
        $updateStmt = $pdo->prepare($updateQuery);
        $updateStmt->bindValue(':post_id', $data['post_id'], PDO::PARAM_INT);
        $updateStmt->execute();
        
        // Toplam beğeni sayısını getir
        $countQuery = "SELECT COUNT(*) FROM user_likes WHERE post_id = :post_id";
        $countStmt = $pdo->prepare($countQuery);
        $countStmt->bindValue(':post_id', $data['post_id'], PDO::PARAM_INT);
        $countStmt->execute();
        $count = $countStmt->fetchColumn();
        
        sendResponse([
            'deleted_id' => $deletedId,
            'total_likes' => (int)$count,
            'message' => 'Like removed successfully'
        ]);
    } catch (PDOException $e) {
        error_log("Beğeni silme hatası: " . $e->getMessage());
        sendError('Error removing like: ' . $e->getMessage(), 500);
    }
}

// İstek tipini belirle
$method = $_SERVER['REQUEST_METHOD'];
$request_uri = $_SERVER['REQUEST_URI'];
$path = parse_url($request_uri, PHP_URL_PATH);
$segments = explode('/', trim($path, '/'));

// JSON request data
$json_data = file_get_contents('php://input');
$request_data = json_decode($json_data, true) ?? [];

// İşlemi gerçekleştir
if ($method === 'GET') {
    // Query parametresi olarak post ID kontrolü
    $post_id = $_GET['post_id'] ?? null;
    if ($post_id) {
        getLikesByPostId($post_id);
    } else {
        sendError("Post ID required for likes", 400);
    }
} elseif ($method === 'POST') {
    addLike($request_data);
} elseif ($method === 'DELETE') {
    removeLike($request_data);
} else {
    sendError("Invalid method for likes endpoint", 405);
}
?>