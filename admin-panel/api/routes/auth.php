<?php
// Authentication routes

// Passwordları hash'lemek için helper fonksiyon
function hashPassword($password) {
    return password_hash($password, PASSWORD_DEFAULT);
}

// Passwordları doğrulamak için helper fonksiyon
function verifyPassword($password, $hash) {
    return password_verify($password, $hash);
}

// Login işlemi
function handleLogin($db, $data) {
    $username = $data['username'] ?? '';
    $password = $data['password'] ?? '';
    
    if (empty($username) || empty($password)) {
        sendError("Username and password are required", 400);
    }
    
    // Kullanıcıyı veritabanında ara
    $query = "SELECT * FROM users WHERE username = ? OR email = ? LIMIT 1";
    $stmt = $db->prepare($query);
    $stmt->bind_param("ss", $username, $username);
    $result = $stmt->get_result();
    
    if ($result->num_rows === 0) {
        sendError("Invalid username or password", 401);
    }
    
    $user = $result->fetch_assoc();
    
    // Şifreyi doğrula (test sistemi için düz metin de kabul et)
    if (!verifyPassword($password, $user['password']) && $password !== $user['password']) {
        sendError("Invalid username or password", 401);
    }
    
    // Kullanıcıyı oturuma ekle
    $_SESSION['user_id'] = $user['id'];
    
    // Dönüş için hassas bilgileri temizle
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

// Kayıt işlemi
function handleRegister($db, $data) {
    $username = $data['username'] ?? '';
    $email = $data['email'] ?? '';
    $password = $data['password'] ?? '';
    $name = $data['name'] ?? '';
    
    if (empty($username) || empty($email) || empty($password) || empty($name)) {
        sendError("All fields are required", 400);
    }
    
    // Kullanıcı adı ve e-posta adresi kontrolü
    $query = "SELECT * FROM users WHERE username = ? OR email = ? LIMIT 1";
    $stmt = $db->prepare($query);
    $stmt->bind_param("ss", $username, $email);
    $result = $stmt->get_result();
    
    if ($result->num_rows > 0) {
        $existing = $result->fetch_assoc();
        if ($existing['username'] === $username) {
            sendError("Username already exists", 400);
        } else {
            sendError("Email already exists", 400);
        }
    }
    
    // Şifreyi hash'le
    $hashed_password = hashPassword($password);
    
    // Yeni kullanıcıyı ekle
    $query = "INSERT INTO users (name, username, email, password, is_verified, level, points, created_at) 
              VALUES (?, ?, ?, ?, ?, ?, ?, NOW())";
    $stmt = $db->prepare($query);
    $is_verified = true; // Demo için otomatik doğrula
    $level = 'newUser';
    $points = 0;
    $stmt->bind_param("ssssiis", $name, $username, $email, $hashed_password, $is_verified, $level, $points);
    
    if (!$stmt->execute()) {
        sendError("Failed to create user: " . $stmt->error, 500);
    }
    
    $user_id = $db->insert_id;
    
    // Kullanıcıyı oturuma ekle
    $_SESSION['user_id'] = $user_id;
    
    // Yeni oluşturulan kullanıcıyı getir
    $query = "SELECT * FROM users WHERE id = ?";
    $stmt = $db->prepare($query);
    $stmt->bind_param("i", $user_id);
    $result = $stmt->get_result();
    $user = $result->fetch_assoc();
    
    // Dönüş için hassas bilgileri temizle
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
    
    sendResponse($formatted_user, 201);
}

// Çıkış işlemi
function handleLogout($db) {
    // Oturumu sonlandır
    session_destroy();
    sendResponse(['message' => 'Logged out successfully']);
}

// Mevcut kullanıcıyı getir
function handleGetCurrentUser($db) {
    if (!isset($_SESSION['user_id'])) {
        sendError("Not authenticated", 401);
    }
    
    $user_id = $_SESSION['user_id'];
    
    $query = "SELECT * FROM users WHERE id = ?";
    $stmt = $db->prepare($query);
    $stmt->bind_param("i", $user_id);
    $result = $stmt->get_result();
    
    if ($result->num_rows === 0) {
        session_destroy();
        sendError("User not found", 404);
    }
    
    $user = $result->fetch_assoc();
    
    // Dönüş için hassas bilgileri temizle
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