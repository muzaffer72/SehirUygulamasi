<?php
require_once '../db_connection.php';

header('Content-Type: application/json');

try {
    global $pdo;
    // Aktif kullanıcıları getir (yasaklanmamış)
    $query = "
        SELECT id, username, name, email, profile_image_url 
        FROM users 
        WHERE is_banned = FALSE OR is_banned IS NULL
        ORDER BY name ASC
    ";
    
    $stmt = $pdo->prepare($query);
    $stmt->execute();
    $users = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
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