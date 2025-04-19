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

// Mock data (would come from database in a real application)
$posts = [
    [
        'id' => 1,
        'title' => 'Sokak lambası çalışmıyor',
        'content' => 'Evimin önündeki sokak lambası 3 gündür çalışmıyor. Akşamları dışarı çıkmak tehlikeli oluyor.',
        'user_id' => 2,
        'city_id' => 34, // İstanbul
        'district_id' => 4, // Beşiktaş
        'category_id' => 1, // Altyapı
        'status' => 'inProgress',
        'likes' => 25,
        'highlights' => 5,
        'created_at' => '2024-01-15 14:30:00'
    ],
    [
        'id' => 2,
        'title' => 'Çöpler toplanmıyor',
        'content' => 'Mahallemizde çöpler düzenli toplanmıyor. Kötü koku ve sağlık sorunlarına yol açıyor.',
        'user_id' => 3,
        'city_id' => 6, // Ankara
        'district_id' => 12, // Çankaya
        'category_id' => 2, // Temizlik
        'status' => 'awaitingSolution',
        'likes' => 42,
        'highlights' => 12,
        'created_at' => '2024-01-20 09:15:00'
    ],
    [
        'id' => 3,
        'title' => 'Otobüs durağı hasarlı',
        'content' => 'Ana caddedeki otobüs durağının camları kırık ve oturacak yerler hasarlı. Yağmurlu havalarda beklemek imkansız oluyor.',
        'user_id' => 1,
        'city_id' => 35, // İzmir
        'district_id' => 18, // Konak
        'category_id' => 3, // Ulaşım
        'status' => 'solved',
        'likes' => 18,
        'highlights' => 3,
        'created_at' => '2024-01-25 16:45:00'
    ],
];

$users = [
    [
        'id' => 1,
        'name' => 'Ahmet Yılmaz',
        'email' => 'ahmet@example.com',
        'password' => password_hash('password', PASSWORD_DEFAULT),
        'is_verified' => true,
        'city_id' => 35,
        'district_id' => 18,
        'created_at' => '2023-12-01 10:00:00'
    ],
    [
        'id' => 2,
        'name' => 'Ayşe Kaya',
        'email' => 'ayse@example.com',
        'password' => password_hash('password', PASSWORD_DEFAULT),
        'is_verified' => true,
        'city_id' => 34,
        'district_id' => 4,
        'created_at' => '2023-12-05 14:30:00'
    ],
    [
        'id' => 3,
        'name' => 'Mehmet Demir',
        'email' => 'mehmet@example.com',
        'password' => password_hash('password', PASSWORD_DEFAULT),
        'is_verified' => false,
        'city_id' => 6,
        'district_id' => 12,
        'created_at' => '2023-12-10 09:15:00'
    ],
];

$surveys = [
    [
        'id' => 1,
        'title' => 'Yeni park projesi',
        'description' => 'Mahallemize yapılacak yeni park için hangisi daha uygun olur?',
        'city_id' => 34,
        'category_id' => 4,
        'is_active' => true,
        'start_date' => '2024-02-01',
        'end_date' => '2024-03-01',
        'total_votes' => 125,
        'options' => [
            ['id' => 1, 'text' => 'Çocuk oyun alanları ağırlıklı park', 'vote_count' => 75],
            ['id' => 2, 'text' => 'Spor alanları ağırlıklı park', 'vote_count' => 35],
            ['id' => 3, 'text' => 'Piknik alanları ağırlıklı park', 'vote_count' => 15]
        ]
    ],
    [
        'id' => 2,
        'title' => 'Toplu taşıma saatleri',
        'description' => 'Otobüs seferlerinin hangi saatlerde artırılmasını istersiniz?',
        'city_id' => 6,
        'category_id' => 3,
        'is_active' => true,
        'start_date' => '2024-02-15',
        'end_date' => '2024-03-15',
        'total_votes' => 210,
        'options' => [
            ['id' => 1, 'text' => 'Sabah (07:00-09:00)', 'vote_count' => 95],
            ['id' => 2, 'text' => 'Öğle (12:00-14:00)', 'vote_count' => 25],
            ['id' => 3, 'text' => 'Akşam (17:00-19:00)', 'vote_count' => 90]
        ]
    ]
];

$cities = [
    ['id' => 6, 'name' => 'Ankara'],
    ['id' => 34, 'name' => 'İstanbul'],
    ['id' => 35, 'name' => 'İzmir']
];

$districts = [
    ['id' => 4, 'name' => 'Beşiktaş', 'city_id' => 34],
    ['id' => 12, 'name' => 'Çankaya', 'city_id' => 6],
    ['id' => 18, 'name' => 'Konak', 'city_id' => 35]
];

$categories = [
    ['id' => 1, 'name' => 'Altyapı', 'icon_name' => 'build'],
    ['id' => 2, 'name' => 'Temizlik', 'icon_name' => 'cleaning_services'],
    ['id' => 3, 'name' => 'Ulaşım', 'icon_name' => 'directions_bus'],
    ['id' => 4, 'name' => 'Park ve Bahçeler', 'icon_name' => 'nature']
];

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
    global $posts, $users, $surveys, $cities, $districts, $categories;
    
    switch ($endpoint) {
        case 'posts':
            if ($id) {
                // Get single post
                $post = findById($posts, $id);
                if ($post) {
                    sendResponse($post);
                } else {
                    sendResponse(['error' => 'Post not found'], 404);
                }
            } else {
                // Get all posts
                // Check for filters
                $categoryId = $_GET['category_id'] ?? null;
                $cityId = $_GET['city_id'] ?? null;
                $districtId = $_GET['district_id'] ?? null;
                $status = $_GET['status'] ?? null;
                
                $filteredPosts = $posts;
                
                if ($categoryId) {
                    $filteredPosts = array_filter($filteredPosts, function($post) use ($categoryId) {
                        return $post['category_id'] == $categoryId;
                    });
                }
                
                if ($cityId) {
                    $filteredPosts = array_filter($filteredPosts, function($post) use ($cityId) {
                        return $post['city_id'] == $cityId;
                    });
                }
                
                if ($districtId) {
                    $filteredPosts = array_filter($filteredPosts, function($post) use ($districtId) {
                        return $post['district_id'] == $districtId;
                    });
                }
                
                if ($status) {
                    $filteredPosts = array_filter($filteredPosts, function($post) use ($status) {
                        return $post['status'] == $status;
                    });
                }
                
                sendResponse(array_values($filteredPosts));
            }
            break;
            
        case 'users':
            if ($id) {
                // Get single user
                $user = findById($users, $id);
                if ($user) {
                    // Remove password before sending
                    unset($user['password']);
                    sendResponse($user);
                } else {
                    sendResponse(['error' => 'User not found'], 404);
                }
            } else {
                // Get all users (without passwords)
                $safeUsers = array_map(function($user) {
                    unset($user['password']);
                    return $user;
                }, $users);
                sendResponse($safeUsers);
            }
            break;
            
        case 'surveys':
            if ($id) {
                // Get single survey
                $survey = findById($surveys, $id);
                if ($survey) {
                    sendResponse($survey);
                } else {
                    sendResponse(['error' => 'Survey not found'], 404);
                }
            } else {
                // Get all surveys
                // Filter active surveys if requested
                $active = isset($_GET['active']) ? filter_var($_GET['active'], FILTER_VALIDATE_BOOLEAN) : null;
                
                if ($active !== null) {
                    $filteredSurveys = array_filter($surveys, function($survey) use ($active) {
                        return $survey['is_active'] === $active;
                    });
                    sendResponse(array_values($filteredSurveys));
                } else {
                    sendResponse($surveys);
                }
            }
            break;
            
        case 'cities':
            if ($id) {
                // Get single city
                $city = findById($cities, $id);
                if ($city) {
                    sendResponse($city);
                } else {
                    sendResponse(['error' => 'City not found'], 404);
                }
            } else {
                // Get all cities
                sendResponse($cities);
            }
            break;
            
        case 'districts':
            if ($id) {
                // Get single district
                $district = findById($districts, $id);
                if ($district) {
                    sendResponse($district);
                } else {
                    sendResponse(['error' => 'District not found'], 404);
                }
            } else {
                // Get all districts or filter by city
                $cityId = $_GET['city_id'] ?? null;
                
                if ($cityId) {
                    $filteredDistricts = array_filter($districts, function($district) use ($cityId) {
                        return $district['city_id'] == $cityId;
                    });
                    sendResponse(array_values($filteredDistricts));
                } else {
                    sendResponse($districts);
                }
            }
            break;
            
        case 'categories':
            if ($id) {
                // Get single category
                $category = findById($categories, $id);
                if ($category) {
                    sendResponse($category);
                } else {
                    sendResponse(['error' => 'Category not found'], 404);
                }
            } else {
                // Get all categories
                sendResponse($categories);
            }
            break;
            
        default:
            sendResponse(['error' => 'Invalid endpoint'], 404);
    }
}

// POST request handler
function handlePost($endpoint) {
    global $posts, $users, $surveys;
    
    // Get request body
    $data = json_decode(file_get_contents('php://input'), true);
    
    if (!$data && $endpoint !== 'login') {
        sendResponse(['error' => 'Invalid request data'], 400);
        return;
    }
    
    switch ($endpoint) {
        case 'login':
            // Handle login
            $email = $_POST['email'] ?? ($data['email'] ?? null);
            $password = $_POST['password'] ?? ($data['password'] ?? null);
            
            if (!$email || !$password) {
                sendResponse(['error' => 'Email and password are required'], 400);
                return;
            }
            
            $user = null;
            foreach ($users as $u) {
                if ($u['email'] === $email) {
                    $user = $u;
                    break;
                }
            }
            
            if (!$user || !password_verify($password, $user['password'])) {
                sendResponse(['error' => 'Invalid credentials'], 401);
                return;
            }
            
            // Create a token (this would be more secure in a real app)
            $token = bin2hex(random_bytes(32));
            
            // Remove password before sending
            unset($user['password']);
            
            sendResponse([
                'user' => $user,
                'token' => $token
            ]);
            break;
            
        case 'register':
            // Handle registration
            $name = $data['name'] ?? null;
            $email = $data['email'] ?? null;
            $password = $data['password'] ?? null;
            $cityId = $data['city_id'] ?? null;
            $districtId = $data['district_id'] ?? null;
            
            if (!$name || !$email || !$password) {
                sendResponse(['error' => 'Name, email and password are required'], 400);
                return;
            }
            
            // Check if email already exists
            foreach ($users as $user) {
                if ($user['email'] === $email) {
                    sendResponse(['error' => 'Email already exists'], 409);
                    return;
                }
            }
            
            // Create new user
            $newUser = [
                'id' => count($users) + 1,
                'name' => $name,
                'email' => $email,
                'password' => password_hash($password, PASSWORD_DEFAULT),
                'is_verified' => false,
                'city_id' => $cityId,
                'district_id' => $districtId,
                'created_at' => date('Y-m-d H:i:s')
            ];
            
            $users[] = $newUser;
            
            // Remove password before sending
            unset($newUser['password']);
            
            sendResponse($newUser, 201);
            break;
            
        case 'posts':
            // Handle post creation
            $title = $data['title'] ?? null;
            $content = $data['content'] ?? null;
            $userId = $data['user_id'] ?? null;
            $cityId = $data['city_id'] ?? null;
            $districtId = $data['district_id'] ?? null;
            $categoryId = $data['category_id'] ?? null;
            
            if (!$title || !$content || !$userId || !$categoryId) {
                sendResponse(['error' => 'Title, content, user_id and category_id are required'], 400);
                return;
            }
            
            // Create new post
            $newPost = [
                'id' => count($posts) + 1,
                'title' => $title,
                'content' => $content,
                'user_id' => $userId,
                'city_id' => $cityId,
                'district_id' => $districtId,
                'category_id' => $categoryId,
                'status' => 'awaitingSolution',
                'likes' => 0,
                'highlights' => 0,
                'created_at' => date('Y-m-d H:i:s')
            ];
            
            $posts[] = $newPost;
            
            sendResponse($newPost, 201);
            break;
            
        case 'surveys':
            // Handle survey creation
            $title = $data['title'] ?? null;
            $description = $data['description'] ?? null;
            $cityId = $data['city_id'] ?? null;
            $categoryId = $data['category_id'] ?? null;
            $startDate = $data['start_date'] ?? date('Y-m-d');
            $endDate = $data['end_date'] ?? null;
            $options = $data['options'] ?? null;
            
            if (!$title || !$description || !$categoryId || !$endDate || !$options || !is_array($options)) {
                sendResponse(['error' => 'Title, description, category_id, end_date and options are required'], 400);
                return;
            }
            
            // Create option objects
            $surveyOptions = [];
            foreach ($options as $index => $option) {
                $surveyOptions[] = [
                    'id' => $index + 1,
                    'text' => $option,
                    'vote_count' => 0
                ];
            }
            
            // Create new survey
            $newSurvey = [
                'id' => count($surveys) + 1,
                'title' => $title,
                'description' => $description,
                'city_id' => $cityId,
                'category_id' => $categoryId,
                'is_active' => true,
                'start_date' => $startDate,
                'end_date' => $endDate,
                'total_votes' => 0,
                'options' => $surveyOptions
            ];
            
            $surveys[] = $newSurvey;
            
            sendResponse($newSurvey, 201);
            break;
            
        default:
            sendResponse(['error' => 'Invalid endpoint'], 404);
    }
}

// PUT request handler
function handlePut($endpoint, $id) {
    global $posts, $users, $surveys;
    
    if (!$id) {
        sendResponse(['error' => 'ID is required'], 400);
        return;
    }
    
    // Get request body
    $data = json_decode(file_get_contents('php://input'), true);
    
    if (!$data) {
        sendResponse(['error' => 'Invalid request data'], 400);
        return;
    }
    
    switch ($endpoint) {
        case 'posts':
            // Update post
            $postIndex = findIndexById($posts, $id);
            
            if ($postIndex === false) {
                sendResponse(['error' => 'Post not found'], 404);
                return;
            }
            
            // Update only provided fields
            foreach ($data as $key => $value) {
                if (array_key_exists($key, $posts[$postIndex])) {
                    $posts[$postIndex][$key] = $value;
                }
            }
            
            sendResponse($posts[$postIndex]);
            break;
            
        case 'users':
            // Update user
            $userIndex = findIndexById($users, $id);
            
            if ($userIndex === false) {
                sendResponse(['error' => 'User not found'], 404);
                return;
            }
            
            // Update only provided fields
            foreach ($data as $key => $value) {
                if ($key === 'password') {
                    // Hash password
                    $users[$userIndex][$key] = password_hash($value, PASSWORD_DEFAULT);
                } else if (array_key_exists($key, $users[$userIndex])) {
                    $users[$userIndex][$key] = $value;
                }
            }
            
            // Remove password before sending
            $response = $users[$userIndex];
            unset($response['password']);
            
            sendResponse($response);
            break;
            
        case 'surveys':
            // Update survey
            $surveyIndex = findIndexById($surveys, $id);
            
            if ($surveyIndex === false) {
                sendResponse(['error' => 'Survey not found'], 404);
                return;
            }
            
            // Update only provided fields
            foreach ($data as $key => $value) {
                if (array_key_exists($key, $surveys[$surveyIndex])) {
                    $surveys[$surveyIndex][$key] = $value;
                }
            }
            
            sendResponse($surveys[$surveyIndex]);
            break;
            
        default:
            sendResponse(['error' => 'Invalid endpoint'], 404);
    }
}

// DELETE request handler
function handleDelete($endpoint, $id) {
    global $posts, $users, $surveys;
    
    if (!$id) {
        sendResponse(['error' => 'ID is required'], 400);
        return;
    }
    
    switch ($endpoint) {
        case 'posts':
            // Delete post
            $postIndex = findIndexById($posts, $id);
            
            if ($postIndex === false) {
                sendResponse(['error' => 'Post not found'], 404);
                return;
            }
            
            array_splice($posts, $postIndex, 1);
            
            sendResponse(['success' => true]);
            break;
            
        case 'users':
            // Delete user
            $userIndex = findIndexById($users, $id);
            
            if ($userIndex === false) {
                sendResponse(['error' => 'User not found'], 404);
                return;
            }
            
            array_splice($users, $userIndex, 1);
            
            sendResponse(['success' => true]);
            break;
            
        case 'surveys':
            // Delete survey
            $surveyIndex = findIndexById($surveys, $id);
            
            if ($surveyIndex === false) {
                sendResponse(['error' => 'Survey not found'], 404);
                return;
            }
            
            array_splice($surveys, $surveyIndex, 1);
            
            sendResponse(['success' => true]);
            break;
            
        default:
            sendResponse(['error' => 'Invalid endpoint'], 404);
    }
}

// Helper functions
function findById($array, $id) {
    foreach ($array as $item) {
        if ($item['id'] == $id) {
            return $item;
        }
    }
    return null;
}

function findIndexById($array, $id) {
    foreach ($array as $index => $item) {
        if ($item['id'] == $id) {
            return $index;
        }
    }
    return false;
}

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