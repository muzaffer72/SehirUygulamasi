<?php
// Search API
header('Content-Type: application/json');

require_once '../db_connection.php';

// CORS için gerekli headerlar
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// OPTIONS isteği kontrolü (CORS preflight)
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Sadece GET isteklerine izin ver
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405); // Method Not Allowed
    echo json_encode(['error' => 'Only GET method is allowed']);
    exit;
}

// Arama sorgusu kontrolü
$query = isset($_GET['q']) ? trim($_GET['q']) : '';
if (empty($query)) {
    http_response_code(400);
    echo json_encode(['error' => 'Search query is required']);
    exit;
}

// Veritabanı bağlantısını al
$conn = pg_connect("host={$db_host} port={$db_port} dbname={$db_name} user={$db_user} password={$db_password}");
if (!$conn) {
    http_response_code(500);
    echo json_encode(['error' => 'Database connection error']);
    exit;
}

try {
    // Arama sonuçları
    $results = [
        'posts' => [],
        'surveys' => [],
        'cities' => [],
        'users' => []
    ];
    
    // 1. Gönderi arama
    try {
        $check_posts = pg_query($conn, "SELECT to_regclass('public.posts')");
        $posts_exists = pg_fetch_result($check_posts, 0, 0);
        
        if ($posts_exists) {
            $post_query = "
                SELECT p.id, p.title, p.content, p.created_at, p.type, 
                       u.username as user_name, c.name as category_name, 
                       city.name as city_name, d.name as district_name
                FROM posts p
                LEFT JOIN users u ON p.user_id = u.id
                LEFT JOIN categories c ON p.category_id = c.id
                LEFT JOIN cities city ON p.city_id = city.id
                LEFT JOIN districts d ON p.district_id = d.id
                WHERE (p.title ILIKE $1 OR p.content ILIKE $1)
                AND p.is_active = true
                ORDER BY p.created_at DESC
                LIMIT 10";
                
            $post_result = pg_query_params($conn, $post_query, ["%$query%"]);
            
            if ($post_result !== false) {
                while ($row = pg_fetch_assoc($post_result)) {
                    $results['posts'][] = [
                        'id' => $row['id'],
                        'title' => $row['title'],
                        'content' => substr($row['content'], 0, 100) . (strlen($row['content']) > 100 ? '...' : ''),
                        'type' => $row['type'],
                        'user_name' => $row['user_name'],
                        'category_name' => $row['category_name'],
                        'city_name' => $row['city_name'],
                        'district_name' => $row['district_name'],
                        'created_at' => $row['created_at']
                    ];
                }
            }
        }
    } catch (Exception $e) {
        // Hata oluşursa gönderi aramasını atla
        error_log("Gönderi arama hatası: " . $e->getMessage());
    }
    
    // 2. Anket arama
    try {
        $check_surveys = pg_query($conn, "SELECT to_regclass('public.surveys')");
        $surveys_exists = pg_fetch_result($check_surveys, 0, 0);
        
        if ($surveys_exists) {
            $survey_query = "
                SELECT id, title, description, created_at
                FROM surveys
                WHERE (title ILIKE $1 OR description ILIKE $1)
                AND is_active = true
                ORDER BY created_at DESC
                LIMIT 5";
                
            $survey_result = pg_query_params($conn, $survey_query, ["%$query%"]);
            
            if ($survey_result !== false) {
                while ($row = pg_fetch_assoc($survey_result)) {
                    $results['surveys'][] = [
                        'id' => $row['id'],
                        'title' => $row['title'],
                        'description' => substr($row['description'], 0, 100) . (strlen($row['description']) > 100 ? '...' : ''),
                        'created_at' => $row['created_at']
                    ];
                }
            }
        }
    } catch (Exception $e) {
        // Hata oluşursa anket aramasını atla
        error_log("Anket arama hatası: " . $e->getMessage());
    }
    
    // 3. Şehir arama
    try {
        $check_cities = pg_query($conn, "SELECT to_regclass('public.cities')");
        $cities_exists = pg_fetch_result($check_cities, 0, 0);
        
        if ($cities_exists) {
            $city_query = "
                SELECT id, name, region, population, mayor_name
                FROM cities
                WHERE name ILIKE $1 OR region ILIKE $1 OR mayor_name ILIKE $1
                ORDER BY name ASC
                LIMIT 5";
                
            $city_result = pg_query_params($conn, $city_query, ["%$query%"]);
            
            if ($city_result !== false) {
                while ($row = pg_fetch_assoc($city_result)) {
                    $results['cities'][] = [
                        'id' => $row['id'],
                        'name' => $row['name'],
                        'region' => $row['region'],
                        'population' => $row['population'],
                        'mayor_name' => $row['mayor_name']
                    ];
                }
            }
        }
    } catch (Exception $e) {
        // Hata oluşursa şehir aramasını atla
        error_log("Şehir arama hatası: " . $e->getMessage());
    }
    
    // 4. Kullanıcı arama
    try {
        $check_users = pg_query($conn, "SELECT to_regclass('public.users')");
        $users_exists = pg_fetch_result($check_users, 0, 0);
        
        if ($users_exists) {
            $user_query = "
                SELECT id, username, display_name, city_id, district_id, profile_image_url
                FROM users
                WHERE username ILIKE $1 OR display_name ILIKE $1 
                ORDER BY username ASC
                LIMIT 5";
                
            $user_result = pg_query_params($conn, $user_query, ["%$query%"]);
            
            if ($user_result !== false) {
                while ($row = pg_fetch_assoc($user_result)) {
                    $results['users'][] = [
                        'id' => $row['id'],
                        'username' => $row['username'],
                        'display_name' => $row['display_name'],
                        'city_id' => $row['city_id'],
                        'district_id' => $row['district_id'],
                        'profile_image_url' => $row['profile_image_url']
                    ];
                }
            }
        }
    } catch (Exception $e) {
        // Hata oluşursa kullanıcı aramasını atla
        error_log("Kullanıcı arama hatası: " . $e->getMessage());
    }
    
    // 5. İlçe adlarında da arama yapabilir (şehirlerin altında göstermek için)
    try {
        $check_districts = pg_query($conn, "SELECT to_regclass('public.districts')");
        $districts_exists = pg_fetch_result($check_districts, 0, 0);
        
        if ($districts_exists) {
            $district_query = "
                SELECT d.id, d.name, d.city_id, c.name as city_name
                FROM districts d
                JOIN cities c ON d.city_id = c.id
                WHERE d.name ILIKE $1
                ORDER BY c.name ASC, d.name ASC
                LIMIT 5";
                
            $district_result = pg_query_params($conn, $district_query, ["%$query%"]);
            
            if ($district_result !== false) {
                $districts = [];
                while ($row = pg_fetch_assoc($district_result)) {
                    $districts[] = [
                        'id' => $row['id'],
                        'name' => $row['name'],
                        'city_id' => $row['city_id'],
                        'city_name' => $row['city_name']
                    ];
                }
                
                // İlçeleri şehirlere ekle
                if (!empty($districts)) {
                    $results['districts'] = $districts;
                }
            }
        }
    } catch (Exception $e) {
        // Hata oluşursa ilçe aramasını atla
        error_log("İlçe arama hatası: " . $e->getMessage());
    }
    
    // Arama sorgusunu kaydet
    try {
        $check_logs = pg_query($conn, "SELECT to_regclass('public.search_logs')");
        $logs_exists = pg_fetch_result($check_logs, 0, 0);
        
        if ($logs_exists) {
            $log_query = "
                INSERT INTO search_logs (query, result_count) 
                VALUES ($1, $2)";
            
            $total_results = count($results['posts']) + count($results['surveys']) + 
                             count($results['cities']) + count($results['users']);
                              
            pg_query_params($conn, $log_query, [$query, $total_results]);
        }
    } catch (Exception $e) {
        // Hata oluşursa loglama işlemini atla
        error_log("Arama logu kaydetme hatası: " . $e->getMessage());
    }
    
    // Sonuçları döndür
    echo json_encode($results);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Server error: ' . $e->getMessage()]);
}
?>