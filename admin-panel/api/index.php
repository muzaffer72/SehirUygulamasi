<?php
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
$db = $conn;

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

// API endpoint'lerini işle
$request_uri = $_SERVER['REQUEST_URI'];
$path = parse_url($request_uri, PHP_URL_PATH);
$segments = explode('/', trim($path, '/'));

// API alt dizinini bul (admin-panel/api sonrası kısmı)
$api_index = array_search('api', $segments);
if ($api_index !== false) {
    $segments = array_slice($segments, $api_index + 1);
} else {
    sendError("Invalid API path", 404);
}

// Endpoint'i belirle
$endpoint = $segments[0] ?? '';
$id = $segments[1] ?? null;
$action = $segments[2] ?? null;

// HTTP metodu al
$method = $_SERVER['REQUEST_METHOD'];

// İstek gövdesini al (JSON)
$json_data = file_get_contents('php://input');
$request_data = json_decode($json_data, true) ?? [];

// Rotaları işle
switch ($endpoint) {
    case 'login':
        require_once 'routes/auth.php';
        handleLogin($db, $request_data);
        break;
        
    case 'register':
        require_once 'routes/auth.php';
        handleRegister($db, $request_data);
        break;
        
    case 'logout':
        require_once 'routes/auth.php';
        handleLogout($db);
        break;
        
    case 'user':
        require_once 'routes/auth.php';
        handleGetCurrentUser($db);
        break;
        
    case 'users':
        require_once 'routes/users.php';
        
        if ($method === 'GET') {
            if ($id) {
                getUserById($db, $id);
            } else {
                getUsers($db);
            }
        } elseif ($method === 'PUT' && $id) {
            if ($action === 'location') {
                updateUserLocation($db, $id, $request_data);
            } else {
                updateUser($db, $id, $request_data);
            }
        } else {
            sendError("Invalid method for users endpoint", 405);
        }
        break;
        
    case 'cities':
        require_once 'routes/cities.php';
        
        if ($method === 'GET') {
            if ($id) {
                if ($action === 'profile') {
                    getCityProfile($db, $id);
                } else {
                    getCityById($db, $id);
                }
            } else {
                getCities($db);
            }
        } else {
            sendError("Invalid method for cities endpoint", 405);
        }
        break;
        
    case 'districts':
        require_once 'routes/districts.php';
        
        if ($method === 'GET') {
            if ($id) {
                getDistrictById($db, $id);
            } else {
                // Query parametresi olarak şehir ID kontrolü
                $city_id = $_GET['city_id'] ?? null;
                if ($city_id) {
                    getDistrictsByCityId($db, $city_id);
                } else {
                    getDistricts($db);
                }
            }
        } else {
            sendError("Invalid method for districts endpoint", 405);
        }
        break;
        
    case 'categories':
        require_once 'routes/categories.php';
        
        if ($method === 'GET') {
            if ($id) {
                getCategoryById($db, $id);
            } else {
                getCategories($db);
            }
        } else {
            sendError("Invalid method for categories endpoint", 405);
        }
        break;
        
    case 'posts':
        require_once 'routes/posts.php';
        
        if ($method === 'GET') {
            if ($id) {
                getPostById($db, $id);
            } else {
                getPosts($db);
            }
        } elseif ($method === 'POST') {
            createPost($db, $request_data);
        } elseif ($method === 'PUT' && $id) {
            updatePost($db, $id, $request_data);
        } elseif ($method === 'DELETE' && $id) {
            deletePost($db, $id);
        } else {
            sendError("Invalid method for posts endpoint", 405);
        }
        break;
        
    case 'comments':
        require_once 'routes/comments.php';
        
        if ($method === 'GET') {
            // Query parametresi olarak post ID kontrolü
            $post_id = $_GET['post_id'] ?? null;
            if ($post_id) {
                getCommentsByPostId($db, $post_id);
            } else {
                sendError("Post ID required for comments", 400);
            }
        } elseif ($method === 'POST') {
            addComment($db, $request_data);
        } else {
            sendError("Invalid method for comments endpoint", 405);
        }
        break;
        
    case 'surveys':
        require_once 'routes/surveys.php';
        
        if ($method === 'GET') {
            if ($id) {
                getSurveyById($db, $id);
            } else {
                // Filtre parametreleri kontrolü
                $city_id = $_GET['city_id'] ?? null;
                $district_id = $_GET['district_id'] ?? null;
                $scope_type = $_GET['scope_type'] ?? null;
                
                getSurveys($db, $city_id, $district_id, $scope_type);
            }
        } else {
            sendError("Invalid method for surveys endpoint", 405);
        }
        break;
        
    case 'banned-words':
        require_once 'routes/banned_words.php';
        
        if ($method === 'GET') {
            getBannedWords($db);
        } elseif ($method === 'POST') {
            addBannedWord($db, $request_data);
        } elseif ($method === 'DELETE') {
            removeBannedWord($db, $request_data);
        } else {
            sendError("Invalid method for banned-words endpoint", 405);
        }
        break;
        
    case 'parties':
        // Parti verilerini yönet
        require_once 'routes/parties.php';
        break;
        
    case 'search':
        // Doğrudan search.php dosyasını çağır
        include 'search.php';
        exit();
        break;
        
    case 'search_suggestions':
        // Doğrudan search_suggestions.php dosyasını çağır
        include 'search_suggestions.php';
        exit();
        break;
        
    default:
        sendError("Endpoint not found: $endpoint", 404);
}