<?php
require_once '../db_connection.php';

header('Content-Type: application/json');

try {
    // Aktif kullanıcıları getir (yasaklanmamış)
    $query = "
        SELECT id, username, name, email, profile_image_url 
        FROM users 
        WHERE is_banned IS NULL OR is_banned = false
        ORDER BY name ASC
    ";
    
    $pgresult = pg_query($conn, $query);
    
    if (!$pgresult) {
        throw new Exception("Veritabanı sorgu hatası: " . pg_last_error($conn));
    }
    
    $users = [];
    while ($row = pg_fetch_assoc($pgresult)) {
        $users[] = $row;
    }
    
    // Verileri JSON olarak döndür
    echo json_encode([
        'success' => true,
        'count' => count($users),
        'users' => $users
    ]);
    
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'error' => 'Kullanıcı verileri alınırken bir hata oluştu: ' . $e->getMessage()
    ]);
}
?>