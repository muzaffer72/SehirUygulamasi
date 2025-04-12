<?php
/**
 * ŞikayetVar Admin Panel - Anketleri Getir API
 * Bu API, anketleri filtreleme ve listeleme işlevselliği sağlar
 */

// CORS ve JSON başlıkları
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json; charset=UTF-8');
header('Access-Control-Allow-Methods: GET, POST');
header('Access-Control-Allow-Headers: Content-Type');

// Veritabanı bağlantısı
require_once '../db_connection.php';

try {
    // Filtreleme parametrelerini al
    $category_id = isset($_GET['category_id']) ? intval($_GET['category_id']) : 0;
    $scope_type = isset($_GET['scope_type']) ? $_GET['scope_type'] : '';
    $city_id = isset($_GET['city_id']) ? intval($_GET['city_id']) : 0;
    $status = isset($_GET['status']) ? $_GET['status'] : '';
    $search = isset($_GET['search']) ? $_GET['search'] : '';
    
    // Sayfalama için parametreleri al
    $page = isset($_GET['page']) ? intval($_GET['page']) : 1;
    $per_page = isset($_GET['per_page']) ? intval($_GET['per_page']) : 10;
    $offset = ($page - 1) * $per_page;
    
    // SQL sorgusunu oluştur
    $where_clauses = [];
    $params = [];
    
    if ($category_id > 0) {
        $where_clauses[] = "s.category_id = ?";
        $params[] = $category_id;
    }
    
    if (!empty($scope_type) && in_array($scope_type, ['general', 'city', 'district'])) {
        $where_clauses[] = "s.scope_type = ?";
        $params[] = $scope_type;
    }
    
    if ($city_id > 0) {
        $where_clauses[] = "s.city_id = ?";
        $params[] = $city_id;
    }
    
    if ($status === 'active') {
        $where_clauses[] = "s.is_active = true";
    } elseif ($status === 'inactive') {
        $where_clauses[] = "s.is_active = false";
    }
    
    if (!empty($search)) {
        $where_clauses[] = "(s.title LIKE ? OR s.description LIKE ?)";
        $params[] = "%{$search}%";
        $params[] = "%{$search}%";
    }
    
    $where_sql = empty($where_clauses) ? "" : "WHERE " . implode(" AND ", $where_clauses);
    
    // Anket verilerini getir
    $query = "
        SELECT s.*, c.name as category_name, 
               city.name as city_name, d.name as district_name
        FROM surveys s
        LEFT JOIN categories c ON s.category_id = c.id
        LEFT JOIN cities city ON s.city_id = city.id
        LEFT JOIN districts d ON s.district_id = d.id
        $where_sql
        ORDER BY s.created_at DESC
        LIMIT ? OFFSET ?
    ";
    
    // Limit ve offset parametrelerini ekle
    $params[] = $per_page;
    $params[] = $offset;
    
    $stmt = $pdo->prepare($query);
    $stmt->execute($params);
    $surveys = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Toplam anket sayısını getir
    $count_query = "
        SELECT COUNT(*) as total
        FROM surveys s
        $where_sql
    ";
    
    // Limit ve offset hariç diğer parametreleri ekle
    $count_params = array_slice($params, 0, -2);
    
    $count_stmt = $pdo->prepare($count_query);
    $count_stmt->execute($count_params);
    $total = $count_stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // Her anket için oy seçeneklerini ve toplam oyları getir
    foreach ($surveys as &$survey) {
        $options_query = "
            SELECT id, text, vote_count
            FROM survey_options
            WHERE survey_id = ?
            ORDER BY id ASC
        ";
        
        $options_stmt = $pdo->prepare($options_query);
        $options_stmt->execute([$survey['id']]);
        $options = $options_stmt->fetchAll(PDO::FETCH_ASSOC);
        
        // Toplam oy sayısını hesapla
        $total_votes = 0;
        foreach ($options as $option) {
            $total_votes += intval($option['vote_count']);
        }
        
        $survey['options'] = $options;
        $survey['total_votes'] = $total_votes;
    }
    
    // Sonuçları JSON formatında döndür
    echo json_encode([
        'success' => true,
        'data' => $surveys,
        'total' => $total,
        'page' => $page,
        'per_page' => $per_page,
        'total_pages' => ceil($total / $per_page)
    ]);
    
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}