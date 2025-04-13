<?php
// Anket API endpoint'leri

/**
 * Tüm anketleri getir (filtreleme parametreleriyle)
 */
function getSurveys($db, $city_id = null, $district_id = null, $scope_type = null) {
    $query = "
        SELECT s.*, c.name as category_name, 
               city.name as city_name, d.name as district_name
        FROM surveys s
        LEFT JOIN categories c ON s.category_id = c.id
        LEFT JOIN cities city ON s.city_id = CAST(city.id AS INTEGER)
        LEFT JOIN districts d ON s.district_id = d.id
        WHERE 1=1";
    
    $params = [];
    $types = "";
    
    // Filtreleme koşullarını ekle
    if ($city_id) {
        $query .= " AND (s.city_id = ? OR s.scope = 'nationwide')";
        $params[] = $city_id;
        $types .= "i";
    }
    
    if ($district_id) {
        $query .= " AND (s.district_id = ? OR s.scope = 'nationwide' OR s.scope = 'citywide')";
        $params[] = $district_id;
        $types .= "i";
    }
    
    if ($scope_type) {
        $query .= " AND s.scope = ?";
        $params[] = $scope_type;
        $types .= "s";
    }
    
    // Aktif anketleri filtrele
    if (isset($_GET['active']) && $_GET['active'] == 'true') {
        $query .= " AND s.is_active = 1";
    }
    
    // Kategori filtre
    if (isset($_GET['category_id'])) {
        $query .= " AND s.category_id = ?";
        $params[] = (int)$_GET['category_id'];
        $types .= "i";
    }
    
    // Anket tipi filtre
    if (isset($_GET['type'])) {
        $query .= " AND s.type = ?";
        $params[] = $_GET['type'];
        $types .= "s";
    }
    
    // Sıralama ve limit
    $query .= " ORDER BY s.created_at DESC";
    
    if (isset($_GET['limit'])) {
        $limit = (int)$_GET['limit'];
        $query .= " LIMIT ?";
        $params[] = $limit;
        $types .= "i";
    } else {
        $query .= " LIMIT 10"; // Varsayılan limit
    }
    
    $stmt = $db->prepare($query);
    
    if (!empty($params)) {
        $stmt->bind_param($types, ...$params);
    }
    
    $stmt->execute();
    $result = $stmt->get_result();
    
    $surveys = [];
    while ($row = $result->fetch_assoc()) {
        // Her anket için seçenekleri yükle
        $options_query = "
            SELECT id, text, vote_count
            FROM survey_options
            WHERE survey_id = ?
            ORDER BY id ASC";
            
        $options_stmt = $db->prepare($options_query);
        $options_stmt->bind_param("i", $row['id']);
        $options_stmt->execute();
        $options_result = $options_stmt->get_result();
        
        $options = [];
        $total_votes = 0;
        
        while ($option = $options_result->fetch_assoc()) {
            $total_votes += $option['vote_count'];
            $options[] = $option;
        }
        
        // Her seçenek için oy yüzdesini hesapla
        if ($total_votes > 0) {
            foreach ($options as &$option) {
                $option['percentage'] = round(($option['vote_count'] / $total_votes) * 100, 1);
            }
        } else {
            foreach ($options as &$option) {
                $option['percentage'] = 0;
            }
        }
        
        $row['options'] = $options;
        $row['total_votes'] = $total_votes;
        
        // Anket bölgesel sonuçlarını yükle (varsa)
        if ($row['has_regional_results']) {
            $regions_query = "
                SELECT region_id, region_name, region_type, option_id, vote_count
                FROM survey_regional_results
                WHERE survey_id = ?
                ORDER BY region_type, region_name";
                
            $regions_stmt = $db->prepare($regions_query);
            $regions_stmt->bind_param("i", $row['id']);
            $regions_stmt->execute();
            $regions_result = $regions_stmt->get_result();
            
            $regional_results = [];
            while ($region = $regions_result->fetch_assoc()) {
                $regional_results[] = $region;
            }
            
            $row['regional_results'] = $regional_results;
        }
        
        $surveys[] = $row;
    }
    
    sendResponse(['surveys' => $surveys]);
}

/**
 * Belirli bir anketi ID'ye göre getir
 */
function getSurveyById($db, $id) {
    $query = "
        SELECT s.*, c.name as category_name, 
               city.name as city_name, d.name as district_name
        FROM surveys s
        LEFT JOIN categories c ON s.category_id = c.id
        LEFT JOIN cities city ON s.city_id = CAST(city.id AS INTEGER)
        LEFT JOIN districts d ON s.district_id = d.id
        WHERE s.id = ?";
        
    $stmt = $db->prepare($query);
    $stmt->bind_param("i", $id);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows === 0) {
        sendError("Survey not found", 404);
    }
    
    $survey = $result->fetch_assoc();
    
    // Anket seçeneklerini yükle
    $options_query = "
        SELECT id, text, vote_count
        FROM survey_options
        WHERE survey_id = ?
        ORDER BY id ASC";
        
    $options_stmt = $db->prepare($options_query);
    $options_stmt->bind_param("i", $id);
    $options_stmt->execute();
    $options_result = $options_stmt->get_result();
    
    $options = [];
    $total_votes = 0;
    
    while ($option = $options_result->fetch_assoc()) {
        $total_votes += $option['vote_count'];
        $options[] = $option;
    }
    
    // Her seçenek için oy yüzdesini hesapla
    if ($total_votes > 0) {
        foreach ($options as &$option) {
            $option['percentage'] = round(($option['vote_count'] / $total_votes) * 100, 1);
        }
    } else {
        foreach ($options as &$option) {
            $option['percentage'] = 0;
        }
    }
    
    $survey['options'] = $options;
    $survey['total_votes'] = $total_votes;
    
    // Anket bölgesel sonuçlarını yükle (varsa)
    if ($survey['has_regional_results']) {
        $regions_query = "
            SELECT region_id, region_name, region_type, option_id, vote_count
            FROM survey_regional_results
            WHERE survey_id = ?
            ORDER BY region_type, region_name";
            
        $regions_stmt = $db->prepare($regions_query);
        $regions_stmt->bind_param("i", $id);
        $regions_stmt->execute();
        $regions_result = $regions_stmt->get_result();
        
        $regional_results = [];
        while ($region = $regions_result->fetch_assoc()) {
            $regional_results[] = $region;
        }
        
        $survey['regional_results'] = $regional_results;
    }
    
    sendResponse(['survey' => $survey]);
}