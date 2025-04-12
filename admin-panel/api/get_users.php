<?php
require_once '../db_connection.php';

header('Content-Type: application/json');

try {
    global $pdo;
    // Aktif kullanıcıları getir (yasaklanmamış)
    // PostgreSQL'de boolean değerler için 'FALSE' yerine 'false' kullanılıyor
    // ve IS NULL kontrolü ekliyoruz (is_banned sütunu yoksa hata vermemesi için)
    // PostgreSQL için WHERE is_banned = FALSE koşulunu BOOLEAN olarak doğru kullanıyoruz
    // Ayrıca is_banned sütunun hiç olmaması ihtimaline karşı IS NULL kontrolü de ekliyoruz
    $query = "
        SELECT id, username, name, email, profile_image_url 
        FROM users 
        WHERE is_banned IS NULL OR is_banned = FALSE
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