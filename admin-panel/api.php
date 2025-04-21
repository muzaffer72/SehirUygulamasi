<?php
// API for mobile app

header('Content-Type: application/json; charset=utf-8');
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
    
    // PostgreSQL veya MySQL uyumlu num_rows kontrolü
    $rowCount = 0;
    if (method_exists($result, 'num_rows')) {
        $rowCount = $result->num_rows; // MySQL yöntemi
    } else if (function_exists('pg_num_rows') && get_class($result) === 'PgSql\Result') {
        $rowCount = pg_num_rows($result); // PostgreSQL yöntemi
    } else {
        // Manuel sayım yöntemi
        $temp = [];
        while ($row = $result->fetch_assoc()) {
            $temp[] = $row;
        }
        $rowCount = count($temp);
        // İmleci başa sar (eğer destekleniyorsa)
        if (method_exists($result, 'data_seek')) {
            $result->data_seek(0);
        }
    }
    
    if ($rowCount === 0) {
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
    
    // Çıktı arabelleğini temizle - önceki hata mesajları varsa kaldır
    if (ob_get_length()) ob_clean();
    
    // JSON_UNESCAPED_UNICODE ile karakterler korunur, JSON_THROW_ON_ERROR hata kontrolü sağlar
    try {
        $json = json_encode($data, JSON_UNESCAPED_UNICODE | JSON_THROW_ON_ERROR);
        echo $json;
    } catch (Exception $e) {
        // JSON kodlama hatası durumunda
        error_log('JSON kodlama hatası: ' . $e->getMessage());
        http_response_code(500);
        echo json_encode(['error' => 'Sunucu yanıtı işlenemedi'], JSON_UNESCAPED_UNICODE);
    }
    
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
    
    // Ham sorgu ve parametreleri logla
    error_log("getDistricts fonksiyonu çağrıldı, city_id parametresi: " . ($cityId === null ? 'NULL' : $cityId));
    
    // Sorgu öncesi veritabanı bağlantısını kontrol et
    if (!$db) {
        error_log("Veritabanı bağlantısı yok veya geçersiz!");
        return [];
    }
    
    // İlk olarak manuel olarak direkt SQL sorgusu logla
    $testSql = "SELECT COUNT(*) as count FROM districts WHERE 1=1" . ($cityId ? " AND city_id = '$cityId'" : "");
    $testResult = $db->query($testSql);
    if ($testResult) {
        $countRow = $testResult->fetch_assoc();
        error_log("İlçe toplam sayısı: " . $countRow['count'] . ($cityId ? " (Şehir ID: $cityId için)" : " (tüm ilçeler)"));
    } else {
        error_log("Test sorgusu hata verdi: " . $db->error);
    }
    
    // Şehir ID'si varsa, sorguyu hazırla (yedek sorgu dahil)
    try {
        if ($cityId) {
            // İlk yöntem: Prepared Statement
            error_log("Prepared statement kullanılıyor...");
            $stmt = $db->prepare("SELECT * FROM districts WHERE city_id = ? ORDER BY name");
            if (!$stmt) {
                error_log("Prepared statement oluşturulamadı: " . $db->error);
                // Alternatif yöntemi dene
                $sql = "SELECT * FROM districts WHERE city_id = '" . $db->real_escape_string($cityId) . "' ORDER BY name";
                error_log("Alternatif sorgu: $sql");
                $result = $db->query($sql);
            } else {
                // cityId'yi string veya int olarak kabul et
                $cityIdParam = is_numeric($cityId) ? $cityId : $cityId;
                error_log("Parametre hazırlandı: $cityIdParam (tip: " . gettype($cityIdParam) . ")");
                
                // Parametre tipini belirle
                $paramType = is_numeric($cityIdParam) ? 'i' : 's';
                error_log("Parametre tipi: $paramType");
                
                $stmt->bind_param($paramType, $cityIdParam);
                $success = $stmt->execute();
                
                if (!$success) {
                    error_log("Sorgu çalıştırma hatası: " . $stmt->error);
                    // Alternatif sorguyu dene
                    $sql = "SELECT * FROM districts WHERE city_id = '" . $db->real_escape_string($cityId) . "' ORDER BY name";
                    error_log("Alternatif sorgu çalıştırılıyor: $sql");
                    $result = $db->query($sql);
                } else {
                    $result = $stmt->get_result();
                }
            }
            
            // Eğer hiçbir ilçe bulunamazsa, alternatif sorgular dene
            if ($result && (is_object($result) && method_exists($result, 'num_rows') && $result->num_rows == 0) || 
                (is_object($result) && !method_exists($result, 'num_rows')) || !$result) {
                
                error_log("Tam eşleşmede ilçe bulunamadı, PostgreSQL için alternatif sorgu deneniyor...");
                
                // PostgreSQL için int ve string tip dönüşümüne dikkat ederek sorgu yap
                $alternativeSql = "SELECT * FROM districts WHERE city_id = " . intval($cityId) . " ORDER BY name";
                error_log("Alternatif sorgu: $alternativeSql");
                try {
                    $result = $db->query($alternativeSql);
                    if (!$result) {
                        error_log("SQL Hatası: " . ($db->error ?? 'Bilinmeyen hata') . " - Sorgu: $alternativeSql");
                    }
                } catch (Exception $e) {
                    error_log("Sorgu hatası: " . $e->getMessage());
                }
            }
            
            // Yine de bulunamazsa, tüm ilçeleri getir
            if ($result && (
                (is_object($result) && method_exists($result, 'num_rows') && $result->num_rows == 0) || 
                (is_object($result) && !method_exists($result, 'num_rows'))
               )) {
                error_log("Alternatif sorgu ile de ilçe bulunamadı. Veritabanındaki tüm ilçeleri kontrol etme...");
                $allDistrictsSQL = "SELECT id, name, city_id FROM districts WHERE city_id = " . intval($cityId) . " ORDER BY id LIMIT 30";
                $allResult = $db->query($allDistrictsSQL);
                if ($allResult) {
                    $tempRows = [];
                    while ($row = $allResult->fetch_assoc()) {
                        $tempRows[] = $row;
                        error_log("ID: {$row['id']}, Name: {$row['name']}, City ID: {$row['city_id']}");
                    }
                    error_log("Şehir ID: $cityId için ilçe sayısı: " . count($tempRows));
                    
                    // Eğer bu sorguda veriler bulunursa, bunları kullan
                    if (count($tempRows) > 0) {
                        $result = $allResult;
                        // Sonucu başa sarmak için yeniden sorgu yapmak gerekebilir
                        $allResult = $db->query($allDistrictsSQL);
                        $result = $allResult;
                    }
                }
            }
            
        } else {
            // Tüm ilçeleri getir
            error_log("Tüm ilçeler getiriliyor");
            $result = $db->query("SELECT * FROM districts ORDER BY name");
        }
    } catch (Exception $e) {
        error_log("İlçe sorgusunda istisna: " . $e->getMessage());
        $result = null;
    }
    
    // Sonuçları işle
    $districts = array();
    if ($result) {
        // Sonuçları güvenli şekilde işle
        while ($row = $result->fetch_assoc()) {
            $districts[] = $row;
        }
        
        // İlçelerin sayısını debug için logla
        error_log("Toplam " . count($districts) . " ilçe bulundu" . ($cityId ? " (Şehir ID: $cityId için)" : ""));
    } else {
        // Hata durumunu logla
        error_log("İlçe sorgusunda hata: " . $db->error);
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
    // Burada parametre önceliklerini endpoint'e göre ayarla
    if ($endpoint == 'districts' && isset($_GET['city_id'])) {
        // districts endpoint'i için city_id parametresi varsa, id parametresini yoksay
        $id = isset($_GET['id']) ? $_GET['id'] : null;
        // city_id parametresi için özel mantık, bu durumda hata ayıkla ve id'yi NULL yap
        error_log("districts için city_id={$_GET['city_id']} parametresi kullanılıyor, id parametresi: " . ($id ? $id : "NULL"));
        
        // Eğer hem id hem city_id varsa, id'yi özel olarak saklarız ve id'yi null yaparız
        if ($id) {
            $original_id = $id;
            $id = null;
            error_log("Hem id hem city_id var, öncelik city_id'ye verildi. Orijinal id: $original_id");
        }
    } else {
        // Diğer endpoint'ler için normal parametre öncelikleri
        $id = $_GET['id'] ?? ($_GET['post_id'] ?? ($_GET['user_id'] ?? ($_GET['city_id'] ?? ($_GET['survey_id'] ?? null))));
    }
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
            // POST listesini veritabanından getir
            if ($id) {
                // Tek bir gönderiyi ID ile getir
                $stmt = $db->prepare("SELECT * FROM posts WHERE id = ?");
                $stmt->bind_param('i', $id);
                $stmt->execute();
                $result = $stmt->get_result();
                $post = $result->fetch_assoc();
                
                if ($post) {
                    // Gönderi sahibi bilgilerini getir
                    $userStmt = $db->prepare("SELECT id, name, username, profile_image_url FROM users WHERE id = ?");
                    $userStmt->bind_param('i', $post['user_id']);
                    $userStmt->execute();
                    $userResult = $userStmt->get_result();
                    $user = $userResult->fetch_assoc();
                    
                    // Şehir bilgilerini getir
                    $cityStmt = $db->prepare("SELECT name FROM cities WHERE id = ?");
                    $cityStmt->bind_param('i', $post['city_id']);
                    $cityStmt->execute();
                    $cityResult = $cityStmt->get_result();
                    $city = $cityResult->fetch_assoc();
                    
                    // Kategori bilgilerini getir
                    if ($post['category_id']) {
                        $catStmt = $db->prepare("SELECT name, icon_name FROM categories WHERE id = ?");
                        $catStmt->bind_param('i', $post['category_id']);
                        $catStmt->execute();
                        $catResult = $catStmt->get_result();
                        $category = $catResult->fetch_assoc();
                    } else {
                        $category = null;
                    }
                    
                    // İlçe bilgilerini getir
                    if ($post['district_id']) {
                        $districtStmt = $db->prepare("SELECT name FROM districts WHERE id = ?");
                        $districtStmt->bind_param('i', $post['district_id']);
                        $districtStmt->execute();
                        $districtResult = $districtStmt->get_result();
                        $district = $districtResult->fetch_assoc();
                    } else {
                        $district = null;
                    }
                    
                    // Sonuçları birleştir
                    $post['user'] = $user;
                    $post['city_name'] = $city ? $city['name'] : null;
                    $post['district_name'] = $district ? $district['name'] : null;
                    $post['category_name'] = $category ? $category['name'] : null;
                    $post['category_icon'] = $category ? $category['icon_name'] : null;
                    
                    sendResponse($post);
                } else {
                    sendResponse(['error' => 'Post not found'], 404);
                }
            } else {
                // Tüm gönderileri getir
                $sql = "SELECT p.*, 
                           u.name as user_name, u.username, u.profile_image_url,
                           c.name as city_name, 
                           d.name as district_name,
                           cat.name as category_name, cat.icon_name as category_icon
                        FROM posts p
                        LEFT JOIN users u ON p.user_id = u.id
                        LEFT JOIN cities c ON p.city_id = c.id
                        LEFT JOIN districts d ON p.district_id = d.id
                        LEFT JOIN categories cat ON p.category_id = cat.id
                        WHERE 1=1";
                
                // Filtreler
                $params = [];
                $types = '';
                
                $categoryId = $_GET['category_id'] ?? null;
                if ($categoryId) {
                    $sql .= " AND p.category_id = ?";
                    $params[] = $categoryId;
                    $types .= 'i';
                }
                
                $cityId = $_GET['city_id'] ?? null;
                if ($cityId) {
                    $sql .= " AND p.city_id = ?";
                    $params[] = $cityId;
                    $types .= 'i';
                }
                
                $districtId = $_GET['district_id'] ?? null;
                if ($districtId) {
                    $sql .= " AND p.district_id = ?";
                    $params[] = $districtId;
                    $types .= 'i';
                }
                
                $status = $_GET['status'] ?? null;
                if ($status) {
                    $sql .= " AND p.status = ?";
                    $params[] = $status;
                    $types .= 's';
                }
                
                $userId = $_GET['user_id'] ?? null;
                if ($userId) {
                    $sql .= " AND p.user_id = ?";
                    $params[] = $userId;
                    $types .= 'i';
                }
                
                // Sıralama
                $sql .= " ORDER BY p.created_at DESC";
                
                // Sayfalama
                $page = isset($_GET['page']) ? intval($_GET['page']) : 1;
                $perPage = isset($_GET['per_page']) ? intval($_GET['per_page']) : 10;
                $offset = ($page - 1) * $perPage;
                
                $sql .= " LIMIT ? OFFSET ?";
                $params[] = $perPage;
                $types .= 'i';
                $params[] = $offset;
                $types .= 'i';
                
                // Sorguyu çalıştır
                $stmt = $db->prepare($sql);
                if (!empty($params)) {
                    $stmt->bind_param($types, ...$params);
                }
                $stmt->execute();
                $result = $stmt->get_result();
                
                $posts = [];
                while ($row = $result->fetch_assoc()) {
                    // Kullanıcı bilgilerini yapılandır
                    $row['user'] = [
                        'id' => $row['user_id'],
                        'name' => $row['user_name'],
                        'username' => $row['username'],
                        'profile_image_url' => $row['profile_image_url']
                    ];
                    
                    // Gereksiz alanları kaldır
                    unset($row['user_name']);
                    
                    $posts[] = $row;
                }
                
                sendResponse($posts);
            }
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
            // Gelen tüm parametreleri logla
            error_log("Districts endpoint'ine istek: " . json_encode($_GET));
            
            if ($id) {
                // Tek ilçeyi getir
                error_log("Tek ilçe getiriliyor, ID: $id");
                $district = getDistrictById($id);
                if ($district) {
                    error_log("İlçe bulundu: " . json_encode($district));
                    sendResponse($district);
                } else {
                    error_log("İlçe bulunamadı: $id");
                    sendResponse(['error' => 'İlçe bulunamadı'], 404);
                }
            } else {
                // Tüm ilçeleri getir veya şehir filtresine göre getir
                $cityId = $_GET['city_id'] ?? null;
                
                // API'nin farklı parametre formatlarını kontrol et
                if (!$cityId) {
                    // Diğer olası parametre isimlerini kontrol et
                    foreach (['city', 'city-id', 'cityId', 'cityid', 'city_id'] as $possibleParam) {
                        if (isset($_GET[$possibleParam])) {
                            $cityId = $_GET[$possibleParam];
                            error_log("Alternatif parametre ile şehir ID'si bulundu: $possibleParam = $cityId");
                            break;
                        }
                    }
                }
                
                // Veritabanından ilçeleri getir
                error_log("İlçeler getiriliyor, şehir ID: " . ($cityId ? $cityId : "tümü"));
                $districts = getDistricts($cityId);
                
                // Sonuçları logla ve döndür
                error_log("Sonuç ilçe sayısı: " . count($districts));
                if (count($districts) == 0) {
                    error_log("UYARI: Hiç ilçe bulunamadı. Bu bir veri problemi olabilir!");
                    
                    // Bazı test verilerini loglayalım
                    $testQuery = "SELECT city_id, COUNT(*) as count FROM districts GROUP BY city_id ORDER BY count DESC LIMIT 10";
                    $testResult = $db->query($testQuery);
                    if ($testResult) {
                        error_log("En çok ilçesi olan 10 şehir:");
                        while ($row = $testResult->fetch_assoc()) {
                            error_log("Şehir ID: {$row['city_id']} - İlçe sayısı: {$row['count']}");
                        }
                    }
                }
                
                // Sonuçları döndür
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

// Not: sendResponse fonksiyonu dosyanın başında tanımlandığı için burada tekrar tanımlamaya gerek yok.