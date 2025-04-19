<?php
// API for mobile app

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-API-KEY');

// OPTIONS metodunu işle (CORS preflight istekleri için)
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Veritabanı bağlantısını dahil et
require_once('db_connection.php');

// API anahtarı kontrolü
function checkApiKey() {
    // 1. Önce URL'de API anahtarı var mı diye kontrol et
    $apiKey = $_GET['api_key'] ?? null;
    
    // 2. URL'de yoksa, header'larda kontrol et (geriye uyumluluk için)
    if (!$apiKey) {
        $headers = getallheaders();
        $apiKey = $headers['X-API-KEY'] ?? null;
    }
    
    // Her iki yöntemde de API anahtarı bulunamadıysa hata döndür
    if (!$apiKey) {
        sendResponse(['error' => 'API anahtarı gerekli. URL parametresi olarak api_key=KEY veya X-API-KEY header\'ı kullanabilirsiniz.'], 401);
        exit;
    }
    
    // Veritabanında API anahtarını kontrol et
    global $db;
    $stmt = $db->prepare("SELECT * FROM api_keys WHERE api_key = ? AND active = TRUE LIMIT 1");
    $stmt->bind_param('s', $apiKey);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows() === 0) {
        // Statik anahtar kontrolü - geçiş dönemi için
        $staticValidKeys = [
            '440bf0009c749943b440f7f5c6c2fd26' // Kullanıcının sağladığı API anahtarı
        ];
        
        // Ortam değişkeninden API anahtarı
        $envApiKey = getenv('API_KEY');
        if ($envApiKey) {
            $staticValidKeys[] = $envApiKey;
        }
        
        if (!in_array($apiKey, $staticValidKeys)) {
            sendResponse(['error' => 'Geçersiz API anahtarı'], 401);
            exit;
        }
    } else {
        // API anahtarı geçerli, kullanım sayısını artır
        $apiKeyData = $result->fetch_assoc();
        $updateStmt = $db->prepare("UPDATE api_keys SET usage_count = usage_count + 1, last_used = NOW() WHERE id = ?");
        $updateStmt->bind_param('i', $apiKeyData['id']);
        $updateStmt->execute();
    }
}

// Test modu değilse API anahtarı kontrolü yap
$testMode = isset($_GET['test_mode']) && $_GET['test_mode'] === 'true';
if (!$testMode) {
    checkApiKey();
}

// Yardımcı fonksiyonlar
function sendResponse($data, $statusCode = 200) {
    http_response_code($statusCode);
    echo json_encode($data, JSON_UNESCAPED_UNICODE);
    exit;
}

// Veritabanından şehirleri çek
function getCities() {
    global $db;
    $result = $db->query("SELECT * FROM cities ORDER BY name");
    $cities = array();
    while ($row = $result->fetch_assoc()) {
        $cities[] = $row;
    }
    return $cities;
}

// Veritabanından ilçeleri çek
function getDistricts($cityId = null) {
    global $db;
    $sql = "SELECT * FROM districts";
    if ($cityId) {
        $sql .= " WHERE city_id = " . intval($cityId);
    }
    $sql .= " ORDER BY name";
    
    $result = $db->query($sql);
    $districts = array();
    if ($result) {
        while ($row = $result->fetch_assoc()) {
            $districts[] = $row;
        }
    }
    return $districts;
}

// Veritabanından kategorileri çek
function getCategories() {
    global $db;
    $result = $db->query("SELECT * FROM categories ORDER BY name");
    $categories = array();
    while ($row = $result->fetch_assoc()) {
        $categories[] = $row;
    }
    return $categories;
}

// ID ile tek şehri getir
function getCityById($id) {
    global $db;
    $stmt = $db->prepare("SELECT * FROM cities WHERE id = ?");
    $stmt->bind_param('i', $id);
    $stmt->execute();
    $result = $stmt->get_result();
    return $result->fetch_assoc();
}

// ID ile tek ilçeyi getir
function getDistrictById($id) {
    global $db;
    $stmt = $db->prepare("SELECT * FROM districts WHERE id = ?");
    $stmt->bind_param('i', $id);
    $stmt->execute();
    $result = $stmt->get_result();
    return $result->fetch_assoc();
}

// ID ile tek kategoriyi getir
function getCategoryById($id) {
    global $db;
    $stmt = $db->prepare("SELECT * FROM categories WHERE id = ?");
    $stmt->bind_param('i', $id);
    $stmt->execute();
    $result = $stmt->get_result();
    return $result->fetch_assoc();
}

// Parse request
$method = $_SERVER['REQUEST_METHOD'];
$endpoint = $_GET['endpoint'] ?? null;

// Eski stil endpoint çözümlemesini de destekle
if (empty($endpoint) && isset($_SERVER['PATH_INFO'])) {
    $request = explode('/', trim($_SERVER['PATH_INFO'] ?? '', '/'));
    $endpoint = $request[0] ?? null;
    $id = $request[1] ?? null;
} else {
    $id = $_GET['id'] ?? ($_GET['post_id'] ?? ($_GET['user_id'] ?? ($_GET['city_id'] ?? ($_GET['survey_id'] ?? null))));
}

// Debug bilgisi ekle
error_log("API isteği: Method=$method, Endpoint=$endpoint, ID=$id, Query=" . json_encode($_GET));

// Handle requests
switch ($method) {
    case 'GET':
        handleGet($endpoint, $id);
        break;
    case 'POST':
        handlePost($endpoint);
        break;
    case 'PUT':
        handlePut($endpoint, $id);
        break;
    case 'DELETE':
        handleDelete($endpoint, $id);
        break;
    default:
        sendResponse(['error' => 'Method not allowed'], 405);
}

// GET request handler
function handleGet($endpoint, $id) {
    global $db;
    
    switch ($endpoint) {
        case 'posts':
            // TODO: Implement posts from database
            // Şimdilik boş dizi döndür
            sendResponse([]);
            break;
            
        case 'users':
            // TODO: Implement users from database
            // Şimdilik boş dizi döndür
            sendResponse([]);
            break;
            
        case 'surveys':
            // TODO: Implement surveys from database
            // Şimdilik boş dizi döndür
            sendResponse([]);
            break;
            
        case 'cities':
            if ($id) {
                // Tek şehri getir
                $city = getCityById($id);
                if ($city) {
                    sendResponse($city);
                } else {
                    sendResponse(['error' => 'Şehir bulunamadı'], 404);
                }
            } else {
                // Tüm şehirleri getir
                $cities = getCities();
                sendResponse($cities);
            }
            break;
            
        case 'districts':
            if ($id) {
                // Tek ilçeyi getir
                $district = getDistrictById($id);
                if ($district) {
                    sendResponse($district);
                } else {
                    sendResponse(['error' => 'İlçe bulunamadı'], 404);
                }
            } else {
                // Tüm ilçeleri getir veya şehir filtresine göre getir
                $cityId = $_GET['city_id'] ?? null;
                $districts = getDistricts($cityId);
                sendResponse($districts);
            }
            break;
            
        case 'categories':
            if ($id) {
                // Tek kategoriyi getir
                $category = getCategoryById($id);
                if ($category) {
                    sendResponse($category);
                } else {
                    sendResponse(['error' => 'Kategori bulunamadı'], 404);
                }
            } else {
                // Tüm kategorileri getir
                $categories = getCategories();
                sendResponse($categories);
            }
            break;
            
        default:
            sendResponse(['error' => 'Geçersiz endpoint'], 404);
    }
}

// POST request handler
function handlePost($endpoint) {
    global $db;
    
    // Get request body
    $data = json_decode(file_get_contents('php://input'), true);
    
    if (!$data && $endpoint !== 'login') {
        sendResponse(['error' => 'Geçersiz istek verisi'], 400);
        return;
    }
    
    switch ($endpoint) {
        case 'login':
            // TODO: Veritabanından kullanıcı doğrulama
            sendResponse(['error' => 'Bu özellik henüz uygulanmadı'], 501);
            break;
            
        case 'register':
            // TODO: Veritabanına kullanıcı kaydetme
            sendResponse(['error' => 'Bu özellik henüz uygulanmadı'], 501);
            break;
            
        case 'posts':
            // TODO: Veritabanına gönderi ekleme
            sendResponse(['error' => 'Bu özellik henüz uygulanmadı'], 501);
            break;
            
        case 'surveys':
            // TODO: Veritabanına anket ekleme
            sendResponse(['error' => 'Bu özellik henüz uygulanmadı'], 501);
            break;
            
        default:
            sendResponse(['error' => 'Geçersiz endpoint'], 404);
    }
}

// PUT request handler
function handlePut($endpoint, $id) {
    global $db;
    
    if (!$id) {
        sendResponse(['error' => 'ID gerekli'], 400);
        return;
    }
    
    // Get request body
    $data = json_decode(file_get_contents('php://input'), true);
    
    if (!$data) {
        sendResponse(['error' => 'Geçersiz istek verisi'], 400);
        return;
    }
    
    switch ($endpoint) {
        case 'posts':
            // TODO: Veritabanında gönderi güncelleme
            sendResponse(['error' => 'Bu özellik henüz uygulanmadı'], 501);
            break;
            
        case 'users':
            // TODO: Veritabanında kullanıcı güncelleme
            sendResponse(['error' => 'Bu özellik henüz uygulanmadı'], 501);
            break;
            
        case 'surveys':
            // TODO: Veritabanında anket güncelleme
            sendResponse(['error' => 'Bu özellik henüz uygulanmadı'], 501);
            break;
            
        default:
            sendResponse(['error' => 'Geçersiz endpoint'], 404);
    }
}

// DELETE request handler
function handleDelete($endpoint, $id) {
    global $db;
    
    if (!$id) {
        sendResponse(['error' => 'ID gerekli'], 400);
        return;
    }
    
    switch ($endpoint) {
        case 'posts':
            // TODO: Veritabanından gönderi silme
            sendResponse(['error' => 'Bu özellik henüz uygulanmadı'], 501);
            break;
            
        case 'users':
            // TODO: Veritabanından kullanıcı silme
            sendResponse(['error' => 'Bu özellik henüz uygulanmadı'], 501);
            break;
            
        case 'surveys':
            // TODO: Veritabanından anket silme
            sendResponse(['error' => 'Bu özellik henüz uygulanmadı'], 501);
            break;
            
        default:
            sendResponse(['error' => 'Geçersiz endpoint'], 404);
    }
}

// Sadece sendResponse() fonksiyonunu koru
function sendResponse($data, $statusCode = 200) {
    http_response_code($statusCode);
    
    // Eğer $data bağımsız bir dizi değilse, onu bir API yanıtı formatına çevir
    if (!isset($data['endpoint']) && !isset($data['error']) && !isset($data['status'])) {
        $data = [
            'status' => 'success',
            'data' => $data
        ];
    }
    
    echo json_encode($data, JSON_UNESCAPED_UNICODE);
    exit;
}