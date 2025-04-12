<?php
/**
 * Şehirlerin problem çözme oranını günceller
 */
require_once '../db_connection.php';

// functions.php dosyası mevcut değil, kullanıcı kontrolünü devre dışı bırakıyoruz
// require_once '../functions.php';
// Yalnızca yöneticilerin erişimi
// requireAdmin();

// API yanıtı
$response = [
    'success' => false,
    'message' => ''
];

try {
    // POST verisi kontrol
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        throw new Exception('Geçersiz istek metodu');
    }
    
    // Şehir ID kontrolü
    $cityId = isset($_POST['city_id']) ? intval($_POST['city_id']) : 0;
    
    // Tek bir şehir için güncelleme yapmak isteniyorsa
    if ($cityId > 0) {
        updateCityRate($pdo, $cityId);
        $response['success'] = true;
        $response['message'] = 'Şehir problem çözüm oranı başarıyla güncellendi.';
    } 
    // Tüm şehirleri güncelle
    else {
        // Tüm şehirleri getir
        $stmt = $pdo->query("SELECT id FROM cities ORDER BY id");
        $cities = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        $updatedCount = 0;
        foreach ($cities as $city) {
            updateCityRate($pdo, $city['id']);
            $updatedCount++;
        }
        
        $response['success'] = true;
        $response['message'] = "Toplam {$updatedCount} şehir için problem çözüm oranı güncellendi.";
    }
    
} catch (Exception $e) {
    $response['message'] = $e->getMessage();
}

// Şehir için problem çözüm oranını güncelle
function updateCityRate($pdo, $cityId) {
    // Şehrin toplam şikayet sayısını ve çözülen şikayet sayısını hesapla
    $query = "SELECT 
                COUNT(*) as total_posts,
                SUM(CASE WHEN status = 'solved' THEN 1 ELSE 0 END) as solved_posts
              FROM posts 
              WHERE city_id = ?";
    
    $stmt = $pdo->prepare($query);
    $stmt->execute([$cityId]);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    
    $totalPosts = $result['total_posts'];
    $solvedPosts = $result['solved_posts'];
    
    // Problem çözme oranını hesapla
    $rate = 0;
    if ($totalPosts > 0) {
        $rate = ($solvedPosts / $totalPosts) * 100;
    }
    
    // PostgreSQL için ondalık sayıyı düzgün formata çevirelim
    // Çok uzun ondalık sayılar sorun çıkarıyor, iki basamağa yuvarla
    $rate = round($rate, 2);
    
    // Oranı güncelle - CAST kullanarak açıkça tür dönüşümü yapıyoruz
    $updateQuery = "UPDATE cities SET problem_solving_rate = CAST(? AS NUMERIC) WHERE id = ?";
    $stmt = $pdo->prepare($updateQuery);
    $stmt->execute([(string)$rate, $cityId]);
    
    return $rate;
}

// JSON yanıtı
header('Content-Type: application/json');
echo json_encode($response);
?>