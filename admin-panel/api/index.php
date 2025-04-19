<?php
// ŞikayetVar API Endpoint Yönlendirici
// Bu dosya, işe admin-panel/api/ olarak gelen istekleri doğru komut dosyalarına yönlendirir

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-API-KEY');

// İhtiyaç duyulan veri paylaşımı için oturum başlat
session_start();

// Veritabanı bağlantısını ekle
require_once '../db_connection.php';

// API anahtarını doğrulama
function verifyApiKey() {
    global $db;
    
    // API anahtarını al
    $api_key = isset($_SERVER['HTTP_X_API_KEY']) ? $_SERVER['HTTP_X_API_KEY'] : null;
    
    if (!$api_key) {
        sendError('API anahtarı gerekli', 401);
        return false;
    }
    
    // Veritabanında API anahtarını kontrol et
    $query = "SELECT api_key FROM settings WHERE api_key = ?";
    $stmt = $db->prepare($query);
    $stmt->bind_param("s", $api_key);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if (!$result || $result->num_rows() == 0) {
        sendError('Geçersiz API anahtarı', 401);
        return false;
    }
    
    return true;
}

function sendError($message, $statusCode = 400) {
    http_response_code($statusCode);
    echo json_encode(['error' => $message]);
    exit;
}

function sendResponse($data, $statusCode = 200) {
    http_response_code($statusCode);
    
    // Eğer $data bağımsız bir dizi değilse, onu bir API yanıtı formatına çevir
    if (!isset($data['endpoint']) && !isset($data['error'])) {
        $data = [
            'status' => 'success',
            'data' => $data
        ];
    }
    
    echo json_encode($data);
    exit;
}

// Gelen istek URL'ini ayrıştır
$url_parts = parse_url($_SERVER['REQUEST_URI']);
$path = $url_parts['path'];
$path_parts = explode('/', trim($path, '/'));

// İlk olarak query string endpoint parametresini kontrol et (yeni format)
if (isset($_GET['endpoint'])) {
    $endpoint = $_GET['endpoint'];
    $id = $_GET['id'] ?? null;
} else {
    // Klasik path bazlı format (eski stil)
    // URL'den gereksiz parçaları kaldır 
    foreach ($path_parts as $index => $part) {
        if ($part === 'api') {
            $endpoint = isset($path_parts[$index + 1]) ? $path_parts[$index + 1] : '';
            $id = isset($path_parts[$index + 2]) ? $path_parts[$index + 2] : null;
            break;
        }
    }
    
    if (!isset($endpoint)) {
        $endpoint = '';
    }
}

// Yetkilendirme kontrolü
if (!verifyApiKey()) {
    exit; // verifyApiKey zaten bir hata mesajı gönderdi
}

// Endpoint'e göre doğru dosyayı dahil et
switch ($endpoint) {
    case 'cities':
        require_once 'routes/cities.php';
        break;
        
    case 'districts':
        require_once 'routes/districts.php';
        break;
        
    case 'categories':
        require_once 'routes/categories.php';
        break;
        
    case 'posts':
        require_once 'routes/posts.php';
        break;
        
    case 'users':
        require_once 'routes/users.php';
        break;
        
    case 'auth':
        require_once 'routes/auth.php';
        break;
        
    case 'search_suggestions':
        require_once 'routes/search_suggestions.php';
        break;
        
    case 'banned_words':
        require_once 'routes/banned_words.php';
        break;
        
    case 'surveys':
        require_once 'routes/surveys.php';
        break;
        
    case 'satisfaction_rating':
        require_once 'routes/satisfaction_rating.php';
        break;
        
    case 'statistics':
        require_once 'routes/statistics.php';
        break;
        
    case 'parties':
        // Siyasi parti API yönlendirmesi
        require_once 'routes/parties.php';
        break;
        
    default:
        // API bilgi sayfası
        $available_endpoints = [
            'cities', 'districts', 'categories', 'posts', 'users', 'auth',
            'search_suggestions', 'banned_words', 'surveys', 'satisfaction_rating',
            'statistics', 'parties'
        ];
        
        sendResponse([
            'name' => 'ŞikayetVar API',
            'version' => '1.0',
            'description' => 'ŞikayetVar mobil uygulaması için RESTful API',
            'available_endpoints' => $available_endpoints,
            'documentation' => '/api-docs',
            'status' => 'online',
            'timestamp' => date('Y-m-d H:i:s')
        ]);
}