<?php
// Districts routes

// İlçeleri getir
function getDistricts($db) {
    $query = "SELECT * FROM districts ORDER BY name ASC";
    $result = $db->query($query);
    
    $districts = [];
    while ($row = $result->fetch_assoc()) {
        // API yanıtı için formatı düzenle
        $districts[] = [
            'id' => (string)$row['id'],
            'name' => $row['name'],
            'city_id' => (string)$row['city_id'],
            'population' => (int)$row['population'],
            'latitude' => $row['latitude'],
            'longitude' => $row['longitude'],
            'created_at' => $row['created_at'],
            'updated_at' => $row['updated_at'],
        ];
    }
    
    sendResponse($districts);
}

// İlçeyi ID'ye göre getir
function getDistrictById($db, $id) {
    $query = "SELECT * FROM districts WHERE id = ?";
    $stmt = $db->prepare($query);
    $stmt->bind_param("i", $id);
    $result = $stmt->get_result();
    
    if ($result->num_rows === 0) {
        sendError("District not found", 404);
    }
    
    $district = $result->fetch_assoc();
    
    // API yanıtı için formatı düzenle
    $formatted_district = [
        'id' => (string)$district['id'],
        'name' => $district['name'],
        'city_id' => (string)$district['city_id'],
        'population' => (int)$district['population'],
        'latitude' => $district['latitude'],
        'longitude' => $district['longitude'],
        'created_at' => $district['created_at'],
        'updated_at' => $district['updated_at'],
    ];
    
    sendResponse($formatted_district);
}

// Şehrin ilçelerini getir
function getDistrictsByCityId($db, $cityId) {
    $query = "SELECT * FROM districts WHERE city_id = ? ORDER BY name ASC";
    $stmt = $db->prepare($query);
    $stmt->bind_param("i", $cityId);
    $result = $stmt->get_result();
    
    $districts = [];
    while ($row = $result->fetch_assoc()) {
        // API yanıtı için formatı düzenle
        $districts[] = [
            'id' => (string)$row['id'],
            'name' => $row['name'],
            'city_id' => (string)$row['city_id'],
            'population' => (int)$row['population'],
            'latitude' => $row['latitude'],
            'longitude' => $row['longitude'],
            'created_at' => $row['created_at'],
            'updated_at' => $row['updated_at'],
        ];
    }
    
    sendResponse($districts);
}