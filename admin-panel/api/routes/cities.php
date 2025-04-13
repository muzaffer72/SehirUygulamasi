<?php
// Cities routes

// Şehirleri getir
function getCities($db) {
    $query = "SELECT * FROM cities ORDER BY name ASC";
    $stmt = $db->prepare($query);
    $stmt->execute();
    $result = $stmt->get_result();
    
    $cities = [];
    while ($row = $result->fetch_assoc()) {
        // API yanıtı için formatı düzenle
        $cities[] = [
            'id' => (string)$row['id'],
            'name' => $row['name'],
            'plate_code' => $row['plate_code'],
            'region' => $row['region'],
            'population' => (int)$row['population'],
            'latitude' => $row['latitude'],
            'longitude' => $row['longitude'],
            'created_at' => $row['created_at'],
            'updated_at' => $row['updated_at'],
        ];
    }
    
    sendResponse($cities);
}

// Şehri ID'ye göre getir
function getCityById($db, $id) {
    $query = "SELECT * FROM cities WHERE id = ?";
    $stmt = $db->prepare($query);
    $stmt->bind_param("i", $id);
    $result = $stmt->get_result();
    
    if ($result->num_rows === 0) {
        sendError("City not found", 404);
    }
    
    $city = $result->fetch_assoc();
    
    // API yanıtı için formatı düzenle
    $formatted_city = [
        'id' => (string)$city['id'],
        'name' => $city['name'],
        'plate_code' => $city['plate_code'],
        'region' => $city['region'],
        'population' => (int)$city['population'],
        'latitude' => $city['latitude'],
        'longitude' => $city['longitude'],
        'created_at' => $city['created_at'],
        'updated_at' => $city['updated_at'],
    ];
    
    sendResponse($formatted_city);
}

// Şehir profil bilgilerini getir
function getCityProfile($db, $id) {
    // Temel şehir bilgilerini al
    $query = "SELECT * FROM cities WHERE id = ?";
    $stmt = $db->prepare($query);
    $stmt->bind_param("i", $id);
    $result = $stmt->get_result();
    
    if ($result->num_rows === 0) {
        sendError("City not found", 404);
    }
    
    $city = $result->fetch_assoc();
    
    // Şehir hizmetlerini al
    $query = "SELECT * FROM city_services WHERE city_id = ?";
    $stmt = $db->prepare($query);
    $stmt->bind_param("i", $id);
    $result = $stmt->get_result();
    
    $services = [];
    while ($row = $result->fetch_assoc()) {
        $services[] = [
            'id' => (string)$row['id'],
            'name' => $row['name'],
            'description' => $row['description'],
            'icon' => $row['icon'],
            'contact_info' => $row['contact_info'],
            'address' => $row['address'],
            'working_hours' => $row['working_hours'],
        ];
    }
    
    // Şehir projelerini al
    $query = "SELECT * FROM city_projects WHERE city_id = ?";
    $stmt = $db->prepare($query);
    $stmt->bind_param("i", $id);
    $result = $stmt->get_result();
    
    $projects = [];
    while ($row = $result->fetch_assoc()) {
        $projects[] = [
            'id' => (string)$row['id'],
            'title' => $row['title'],
            'description' => $row['description'],
            'status' => $row['status'],
            'start_date' => $row['start_date'],
            'end_date' => $row['end_date'],
            'budget' => $row['budget'],
            'image_url' => $row['image_url'],
        ];
    }
    
    // Şehir etkinliklerini al
    $query = "SELECT * FROM city_events WHERE city_id = ?";
    $stmt = $db->prepare($query);
    $stmt->bind_param("i", $id);
    $result = $stmt->get_result();
    
    $events = [];
    while ($row = $result->fetch_assoc()) {
        $events[] = [
            'id' => (string)$row['id'],
            'title' => $row['title'],
            'description' => $row['description'],
            'location' => $row['location'],
            'start_date' => $row['start_date'],
            'end_date' => $row['end_date'],
            'image_url' => $row['image_url'],
        ];
    }
    
    // Şehir istatistiklerini al
    $query = "SELECT * FROM city_stats WHERE city_id = ?";
    $stmt = $db->prepare($query);
    $stmt->bind_param("i", $id);
    $result = $stmt->get_result();
    
    $stats = $result->num_rows > 0 ? $result->fetch_assoc() : null;
    
    // Cevabı birleştir
    $cityProfile = [
        'id' => (string)$city['id'],
        'name' => $city['name'],
        'plate_code' => $city['plate_code'],
        'region' => $city['region'],
        'population' => (int)$city['population'],
        'latitude' => $city['latitude'],
        'longitude' => $city['longitude'],
        'services' => $services,
        'projects' => $projects,
        'events' => $events,
        'stats' => $stats ? [
            'literacy_rate' => (float)$stats['literacy_rate'],
            'unemployment_rate' => (float)$stats['unemployment_rate'],
            'green_area_per_person' => (float)$stats['green_area_per_person'],
            'hospital_count' => (int)$stats['hospital_count'],
            'school_count' => (int)$stats['school_count'],
            'university_count' => (int)$stats['university_count'],
            'annual_budget' => (float)$stats['annual_budget'],
            'average_income' => (float)$stats['average_income'],
            'tourism_income' => (float)$stats['tourism_income'],
        ] : null,
    ];
    
    sendResponse($cityProfile);
}