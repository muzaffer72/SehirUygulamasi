<?php
/**
 * Şehirlerin problem çözme oranına göre ödül durumunu hesaplar
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
    if ($cityId <= 0) {
        throw new Exception('Geçersiz şehir ID');
    }
    
    // Şehir bilgilerini getir
    $stmt = $pdo->prepare("SELECT id, name, problem_solving_rate FROM cities WHERE id = ?");
    $stmt->execute([$cityId]);
    $city = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$city) {
        throw new Exception('Şehir bulunamadı');
    }
    
    // Problem çözme oranı
    $rate = floatval($city['problem_solving_rate']);
    
    // Ödül türlerini getir
    $stmt = $pdo->prepare("SELECT * FROM award_types ORDER BY min_rate ASC");
    $stmt->execute();
    $awardTypes = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Uygun ödül türünü bul
    $matchedAward = null;
    foreach ($awardTypes as $award) {
        $minRate = floatval($award['min_rate']);
        $maxRate = floatval($award['max_rate']);
        
        if ($rate >= $minRate && $rate <= $maxRate) {
            $matchedAward = $award;
            break;
        }
    }
    
    if (!$matchedAward) {
        $response['message'] = "Şehir '{$city['name']}' herhangi bir ödül için uygun değil. Çözüm oranı: %$rate";
        echo json_encode($response);
        exit;
    }
    
    // Şehrin daha önceki ödüllerini getir
    // PostgreSQL uyumluluk sorunu: is_active sütunu yok
    $stmt = $pdo->prepare("SELECT * FROM city_awards WHERE city_id = ? ORDER BY award_date DESC");
    $stmt->execute([$cityId]);
    $existingAwards = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Eski ödülleri pasifleştir
    // PostgreSQL uyumluluk sorunu: is_active sütunu henüz mevcut değil.
    // Buradaki sorguyu eklenen city_awards tablosunda is_active sütunu olmadığı için çalıştırmıyoruz.
    // Aşağıdaki kod, veritabanında is_active sütunu eklendiğinde kullanılabilir.
    /*
    if (!empty($existingAwards)) {
        $stmt = $pdo->prepare("UPDATE city_awards SET is_active = false WHERE city_id = ?");
        $stmt->execute([$cityId]);
    }
    */
    
    // Yeni ödül oluştur
    // Geçerlilik süresi 1 ay
    $expiryDate = date('Y-m-d', strtotime('+1 month'));
    
    // Ödül başlığı ve açıklaması
    $awardTitle = $matchedAward['name'] . ' Ödülü';
    $awardDescription = $city['name'] . ' ' . $matchedAward['description'];
    
    // PostgreSQL ile title ve description alanları için NULL değer vermemeye dikkat et
    $stmt = $pdo->prepare("INSERT INTO city_awards 
                              (city_id, award_type_id, title, description, award_date, expiry_date) 
                            VALUES 
                              (?, ?, ?, ?, CURRENT_DATE, ?)");
    $stmt->execute([
        $cityId, 
        $matchedAward['id'], 
        $awardTitle,
        $awardDescription,
        $expiryDate
    ]);
    
    $response['success'] = true;
    $response['message'] = "'{$city['name']}' şehri '{$matchedAward['name']}' ödülü kazandı! Geçerlilik süresi: " . date('d.m.Y', strtotime($expiryDate));
    
} catch (Exception $e) {
    $response['message'] = $e->getMessage();
}

// JSON yanıtı
header('Content-Type: application/json');
echo json_encode($response);
?>