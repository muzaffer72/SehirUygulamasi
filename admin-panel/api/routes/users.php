<?php
// Users routes

// Kullanıcıları getir
function getUsers($db) {
    $query = "SELECT * FROM users ORDER BY id DESC";
    $result = $db->query($query);
    
    $users = [];
    while ($row = $result->fetch_assoc()) {
        // Hassas bilgileri temizle
        unset($row['password']);
        
        // API yanıtı için formatı düzenle
        $users[] = [
            'id' => (string)$row['id'],
            'name' => $row['name'],
            'username' => $row['username'],
            'email' => $row['email'],
            'profile_image_url' => $row['profile_image_url'],
            'is_verified' => (bool)$row['is_verified'],
            'city_id' => $row['city_id'] ? (string)$row['city_id'] : null,
            'district_id' => $row['district_id'] ? (string)$row['district_id'] : null,
            'level' => $row['level'],
            'points' => (int)$row['points'],
            'created_at' => $row['created_at']
        ];
    }
    
    sendResponse($users);
}

// Kullanıcıyı ID'ye göre getir
function getUserById($db, $id) {
    $query = "SELECT * FROM users WHERE id = ?";
    $stmt = $db->prepare($query);
    $stmt->bind_param("i", $id);
    $result = $stmt->get_result();
    
    if ($result->num_rows === 0) {
        sendError("User not found", 404);
    }
    
    $user = $result->fetch_assoc();
    
    // Hassas bilgileri temizle
    unset($user['password']);
    
    // API yanıtı için formatı düzenle
    $formatted_user = [
        'id' => (string)$user['id'],
        'name' => $user['name'],
        'username' => $user['username'],
        'email' => $user['email'],
        'profile_image_url' => $user['profile_image_url'],
        'is_verified' => (bool)$user['is_verified'],
        'city_id' => $user['city_id'] ? (string)$user['city_id'] : null,
        'district_id' => $user['district_id'] ? (string)$user['district_id'] : null,
        'level' => $user['level'],
        'points' => (int)$user['points'],
        'created_at' => $user['created_at']
    ];
    
    sendResponse($formatted_user);
}

// Kullanıcı bilgilerini güncelle
function updateUser($db, $id, $data) {
    // Güncellenebilir alanları kontrol et
    $updatable = ['name', 'email', 'profile_image_url'];
    $updates = [];
    $types = "";
    $values = [];
    
    foreach ($updatable as $field) {
        if (isset($data[$field])) {
            $updates[] = "$field = ?";
            $types .= "s";
            $values[] = $data[$field];
        }
    }
    
    if (empty($updates)) {
        sendError("No valid fields to update", 400);
    }
    
    // ID parametresini ekle
    $types .= "i";
    $values[] = $id;
    
    // Güncelleme sorgusu oluştur
    $query = "UPDATE users SET " . implode(", ", $updates) . " WHERE id = ?";
    $stmt = $db->prepare($query);
    
    // Parametreleri dinamik olarak bağla
    $stmt->bind_param($types, ...$values);
    
    if (!$stmt->execute()) {
        sendError("Failed to update user: " . $stmt->error, 500);
    }
    
    // Güncellenmiş kullanıcıyı getir
    getUserById($db, $id);
}

// Kullanıcı konumunu güncelle
function updateUserLocation($db, $id, $data) {
    $city_id = $data['city_id'] ?? null;
    $district_id = $data['district_id'] ?? null;
    
    // Şehir ID kontrolü
    if (!empty($city_id)) {
        $query = "SELECT * FROM cities WHERE id = ?";
        $stmt = $db->prepare($query);
        $stmt->bind_param("i", $city_id);
        $result = $stmt->get_result();
        
        if ($result->num_rows === 0) {
            sendError("City not found", 404);
        }
    }
    
    // İlçe ID kontrolü
    if (!empty($district_id)) {
        if (empty($city_id)) {
            sendError("City ID is required when updating district", 400);
        }
        
        $query = "SELECT * FROM districts WHERE id = ? AND city_id = ?";
        $stmt = $db->prepare($query);
        $stmt->bind_param("ii", $district_id, $city_id);
        $result = $stmt->get_result();
        
        if ($result->num_rows === 0) {
            sendError("District not found or does not belong to the specified city", 404);
        }
    }
    
    // Kullanıcı konumunu güncelle
    $query = "UPDATE users SET city_id = ?, district_id = ? WHERE id = ?";
    $stmt = $db->prepare($query);
    $stmt->bind_param("iii", $city_id, $district_id, $id);
    
    if (!$stmt->execute()) {
        sendError("Failed to update user location: " . $stmt->error, 500);
    }
    
    // Güncellenmiş kullanıcıyı getir
    getUserById($db, $id);
}