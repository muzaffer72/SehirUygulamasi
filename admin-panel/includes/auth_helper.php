<?php
/**
 * ŞikayetVar - Kimlik Doğrulama Yardımcı Fonksiyonları
 */

/**
 * API isteği için kullanıcı kimlik doğrulama
 * 
 * @return array|bool Kullanıcı bilgileri veya false
 */
function authenticateUser() {
    global $db;
    
    // Bearer token kontrolü
    $headers = getallheaders();
    $authHeader = isset($headers['Authorization']) ? $headers['Authorization'] : '';
    
    if (empty($authHeader) || !preg_match('/Bearer\s+(.*)$/i', $authHeader, $matches)) {
        return false;
    }
    
    $token = $matches[1];
    
    // Token geçerlilik kontrolü
    try {
        $query = "SELECT u.* FROM user_tokens t JOIN users u ON t.user_id = u.id 
                 WHERE t.token = ? AND t.expires_at > NOW()";
        
        $stmt = $db->prepare($query);
        $stmt->bind_param("s", $token);
        $stmt->execute();
        $result = $stmt->get_result();
        
        if ($result->num_rows === 0) {
            return false;
        }
        
        return $result->fetch_assoc();
        
    } catch (Exception $e) {
        error_log("Kimlik doğrulama hatası: " . $e->getMessage());
        return false;
    }
}

/**
 * Oturum kontrolü yapar (admin panel için)
 * 
 * @param bool $redirectToLogin Giriş sayfasına yönlendirilsin mi?
 * @return array|bool Kullanıcı bilgileri veya false
 */
function checkSession($redirectToLogin = true) {
    if (!isset($_SESSION['user_id'])) {
        if ($redirectToLogin) {
            header('Location: login.php');
            exit;
        }
        return false;
    }
    
    global $db;
    
    try {
        $userId = $_SESSION['user_id'];
        $query = "SELECT * FROM users WHERE id = ? AND is_admin = 1 LIMIT 1";
        $stmt = $db->prepare($query);
        $stmt->bind_param("i", $userId);
        $stmt->execute();
        $result = $stmt->get_result();
        
        if ($result->num_rows === 0) {
            if ($redirectToLogin) {
                session_destroy();
                header('Location: login.php');
                exit;
            }
            return false;
        }
        
        return $result->fetch_assoc();
        
    } catch (Exception $e) {
        error_log("Oturum kontrolü hatası: " . $e->getMessage());
        if ($redirectToLogin) {
            session_destroy();
            header('Location: login.php');
            exit;
        }
        return false;
    }
}

/**
 * Kullanıcı yetkisini kontrol eder
 * 
 * @param string $permission Kontrol edilecek yetki
 * @param array $user Kullanıcı dizisi
 * @return bool Yetkili mi?
 */
function hasPermission($permission, $user = null) {
    if (!$user) {
        if (!isset($_SESSION['user_id'])) {
            return false;
        }
        
        global $db;
        
        try {
            $userId = $_SESSION['user_id'];
            $query = "SELECT role FROM users WHERE id = ? LIMIT 1";
            $stmt = $db->prepare($query);
            $stmt->bind_param("i", $userId);
            $stmt->execute();
            $result = $stmt->get_result();
            
            if ($result->num_rows === 0) {
                return false;
            }
            
            $userRow = $result->fetch_assoc();
            $user = $userRow;
            
        } catch (Exception $e) {
            error_log("Yetki kontrolü hatası: " . $e->getMessage());
            return false;
        }
    }
    
    // Kullanıcı rolüne göre yetki kontrolü
    $role = isset($user['role']) ? $user['role'] : '';
    
    // Super admin her şeyi yapabilir
    if ($role === 'super_admin') {
        return true;
    }
    
    // Yetki haritası
    $permissionMap = [
        'admin' => [
            'view_dashboard', 'manage_posts', 'manage_surveys', 
            'manage_categories', 'manage_users', 'view_reports'
        ],
        'editor' => [
            'view_dashboard', 'manage_posts', 'manage_surveys', 
            'manage_categories', 'view_reports'
        ],
        'moderator' => [
            'view_dashboard', 'manage_posts', 'view_reports'
        ]
    ];
    
    // Rol için izinleri kontrol et
    if (isset($permissionMap[$role]) && in_array($permission, $permissionMap[$role])) {
        return true;
    }
    
    return false;
}