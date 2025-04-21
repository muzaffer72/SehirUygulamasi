<?php
// Bu dosya, comments.php içindeki MySQL/PostgreSQL uyumsuzluklarını düzeltmek için alternatif bir yorum API'si sağlar
// Sorunu olan dış sunucuda kullanmak için, bu dosyayı çağırarak yorum işlevlerini deneyebilirsiniz

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
 * Belirli bir gönderi için yorumları al (PDO ile doğrudan PostgreSQL sorgusu)
 */
function getCommentsByPostId($post_id) {
    global $pdo;
    
    // Hata günlüğü
    error_log("Yorumlar getiriliyor, post_id: $post_id");
    
    try {
        $query = "SELECT c.*, 
                   u.username as user_username, 
                   u.name as user_name, 
                   u.avatar as user_avatar 
                  FROM comments c
                  LEFT JOIN users u ON c.user_id = u.id
                  WHERE c.post_id = :post_id
                  ORDER BY c.created_at DESC";
                  
        $stmt = $pdo->prepare($query);
        $stmt->bindValue(':post_id', $post_id, PDO::PARAM_INT);
        $stmt->execute();
        
        $comments = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        sendResponse(['comments' => $comments]);
    } catch (PDOException $e) {
        error_log("Yorum getirme hatası: " . $e->getMessage());
        sendError('Error fetching comments: ' . $e->getMessage(), 500);
    }
}

/**
 * Yeni bir yorum ekle (PDO ile doğrudan PostgreSQL sorgusu)
 */
function addComment($data) {
    global $pdo;
    
    if (!isset($data['post_id']) || !isset($data['user_id']) || !isset($data['text'])) {
        sendError('Missing required fields', 400);
    }
    
    try {
        // Profanity filter uygula
        $text = filterProfanity($data['text']);
        
        $query = "INSERT INTO comments (post_id, user_id, text, created_at, updated_at)
                  VALUES (:post_id, :user_id, :text, NOW(), NOW())
                  RETURNING id";
                  
        $stmt = $pdo->prepare($query);
        $stmt->bindValue(':post_id', $data['post_id'], PDO::PARAM_INT);
        $stmt->bindValue(':user_id', $data['user_id'], PDO::PARAM_INT);
        $stmt->bindValue(':text', $text, PDO::PARAM_STR);
        $stmt->execute();
        
        $comment_id = $stmt->fetchColumn();
        
        // Yeni eklenen yorumu getir
        $query = "SELECT c.*, 
                 u.username as user_username, 
                 u.name as user_name, 
                 u.avatar as user_avatar 
                FROM comments c
                LEFT JOIN users u ON c.user_id = u.id
                WHERE c.id = :id";
                
        $stmt = $pdo->prepare($query);
        $stmt->bindValue(':id', $comment_id, PDO::PARAM_INT);
        $stmt->execute();
        $comment = $stmt->fetch(PDO::FETCH_ASSOC);
        
        sendResponse(['comment' => $comment, 'message' => 'Comment added successfully'], 201);
    } catch (PDOException $e) {
        error_log("Yorum ekleme hatası: " . $e->getMessage());
        sendError('Error adding comment: ' . $e->getMessage(), 500);
    }
}

/**
 * Yasaklı kelime filtrelemesi (PDO ile doğrudan PostgreSQL sorgusu)
 */
function filterProfanity($text) {
    global $pdo;
    
    try {
        // Yasaklı kelimeleri veritabanından al
        $query = "SELECT word FROM banned_words";
        $stmt = $pdo->query($query);
        $banned_words = $stmt->fetchAll(PDO::FETCH_COLUMN);
        
        // Yasaklı kelimeleri "*" ile değiştir
        foreach ($banned_words as $word) {
            $replacement = str_repeat('*', mb_strlen($word));
            $text = str_ireplace($word, $replacement, $text);
        }
        
        return $text;
    } catch (PDOException $e) {
        error_log("Yasaklı kelime filtreleme hatası: " . $e->getMessage());
        return $text; // Hata durumunda orijinal metni döndür
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
        getCommentsByPostId($post_id);
    } else {
        sendError("Post ID required for comments", 400);
    }
} elseif ($method === 'POST') {
    addComment($request_data);
} else {
    sendError("Invalid method for comments endpoint", 405);
}
?>