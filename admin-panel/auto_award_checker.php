<?php
require_once 'db_connection.php';

// Günlük çalışacak ve ilçeler de dahil tüm belediyelere ödül verecek script

echo "Otomatik ödül kontrolü başlatılıyor...\n";

// Ödül türlerini getir
$awardTypesSql = "SELECT * FROM award_types WHERE is_system = TRUE";
$awardTypesResult = $conn->query($awardTypesSql);

if (!$awardTypesResult) {
    die("Ödül türleri alınamadı: " . $conn->error);
}

$awardTypes = [];
while ($row = $awardTypesResult->fetch_assoc()) {
    $awardTypes[$row['name']] = $row;
}

// Bronz, Gümüş ve Altın kupa ödüllerinin ID'lerini kontrol et
if (!isset($awardTypes['Bronz Kupa']) || !isset($awardTypes['Gümüş Kupa']) || !isset($awardTypes['Altın Kupa'])) {
    echo "Hata: Bronz, Gümüş veya Altın kupa ödül türleri bulunamadı. Lütfen varsayılan ödül türlerini oluşturun.<br>";
    die();
}

$bronzeTrophyId = $awardTypes['Bronz Kupa']['id'];
$silverTrophyId = $awardTypes['Gümüş Kupa']['id'];
$goldTrophyId = $awardTypes['Altın Kupa']['id'];

// İlçeler de dahil tüm belediyeleri getir
$citiesSql = "SELECT id, name, problem_solving_rate FROM cities ORDER BY id";
$citiesResult = $conn->query($citiesSql);

if (!$citiesResult) {
    die("Şehirler alınamadı: " . $conn->error);
}

$districtsSql = "SELECT id, name, problem_solving_rate, city_id FROM districts ORDER BY city_id, id";
$districtsResult = $conn->query($districtsSql);

if (!$districtsResult) {
    die("İlçeler alınamadı: " . $conn->error);
}

// Bugünün tarihini al
$today = date('Y-m-d');
// Bir ay sonraki tarih (ödülün geçerlilik süresi)
$expiryDate = date('Y-m-d', strtotime('+1 month'));

// Önce şehirleri kontrol et ve ödüller ver
$awardedCities = 0;
$totalCities = 0;

echo "<h3>Şehir Belediyeleri Kontrolü</h3>";

while ($city = $citiesResult->fetch_assoc()) {
    $totalCities++;
    $rate = floatval($city['problem_solving_rate']);
    $cityId = $city['id'];
    $cityName = $city['name'];
    
    // Hangi ödül verilecek
    $awardTypeId = null;
    $awardTitle = "";
    
    if ($rate >= 75) {
        $awardTypeId = $goldTrophyId;
        $awardTitle = "Altın Kupa - Yüksek Sorun Çözme Başarısı";
    } elseif ($rate >= 50) {
        $awardTypeId = $silverTrophyId;
        $awardTitle = "Gümüş Kupa - İyi Sorun Çözme Başarısı";
    } elseif ($rate >= 25) {
        $awardTypeId = $bronzeTrophyId;
        $awardTitle = "Bronz Kupa - Orta Sorun Çözme Başarısı";
    }
    
    if ($awardTypeId) {
        // Bu belediyenin mevcut sistem ödüllerini kontrol et
        $checkAwardSql = "
            SELECT ca.id, ca.award_type_id 
            FROM city_awards ca 
            JOIN award_types at ON ca.award_type_id = at.id
            WHERE ca.city_id = ? AND at.is_system = TRUE
        ";
        $checkAwardStmt = $conn->prepare($checkAwardSql);
        $checkAwardStmt->bind_param('i', $cityId);
        $checkAwardStmt->execute();
        $existingAward = $checkAwardStmt->get_result()->fetch_assoc();
        
        if ($existingAward) {
            // Mevcut ödülü güncelle
            $updateSql = "
                UPDATE city_awards 
                SET award_type_id = ?, title = ?, award_date = ?, expiry_date = ? 
                WHERE id = ?
            ";
            $updateStmt = $conn->prepare($updateSql);
            $updateStmt->bind_param('isssi', $awardTypeId, $awardTitle, $today, $expiryDate, $existingAward['id']);
            
            if ($updateStmt->execute()) {
                echo "{$cityName} belediyesinin otomatik ödülü güncellendi. (Çözüm oranı: %{$rate})<br>";
                $awardedCities++;
            } else {
                echo "Hata: {$cityName} belediyesinin ödülü güncellenemedi. Hata: " . $conn->error . "<br>";
            }
        } else {
            // Yeni ödül ekle
            $description = "Belediyenin şikayet çözüm performansı sayesinde kazandığı otomatik ödül. Çözüm oranı: %" . number_format($rate, 2);
            
            $insertSql = "
                INSERT INTO city_awards (city_id, award_type_id, title, description, award_date, expiry_date) 
                VALUES (?, ?, ?, ?, ?, ?)
            ";
            $insertStmt = $conn->prepare($insertSql);
            $insertStmt->bind_param('iissss', $cityId, $awardTypeId, $awardTitle, $description, $today, $expiryDate);
            
            if ($insertStmt->execute()) {
                echo "{$cityName} belediyesine yeni otomatik ödül verildi. (Çözüm oranı: %{$rate})<br>";
                $awardedCities++;
            } else {
                echo "Hata: {$cityName} belediyesine ödül verilemedi. Hata: " . $conn->error . "<br>";
            }
        }
    } else {
        echo "{$cityName} belediyesi ödül için yeterli çözüm oranına sahip değil. (Çözüm oranı: %{$rate})<br>";
    }
}

echo "<h3>İlçe Belediyeleri Kontrolü</h3>";

// İlçe belediyelerini kontrol et ve ödüller ver
$awardedDistricts = 0;
$totalDistricts = 0;

while ($district = $districtsResult->fetch_assoc()) {
    $totalDistricts++;
    $rate = floatval($district['problem_solving_rate']);
    $districtId = $district['id'];
    $districtName = $district['name'];
    $cityId = $district['city_id'];
    
    // İlçenin bağlı olduğu şehrin adını al
    $cityNameSql = "SELECT name FROM cities WHERE id = ?";
    $cityNameStmt = $conn->prepare($cityNameSql);
    $cityNameStmt->bind_param('i', $cityId);
    $cityNameStmt->execute();
    $cityResult = $cityNameStmt->get_result();
    $cityName = $cityResult->fetch_assoc()['name'];
    
    // Hangi ödül verilecek
    $awardTypeId = null;
    $awardTitle = "";
    
    if ($rate >= 75) {
        $awardTypeId = $goldTrophyId;
        $awardTitle = "Altın Kupa - Yüksek Sorun Çözme Başarısı";
    } elseif ($rate >= 50) {
        $awardTypeId = $silverTrophyId;
        $awardTitle = "Gümüş Kupa - İyi Sorun Çözme Başarısı";
    } elseif ($rate >= 25) {
        $awardTypeId = $bronzeTrophyId;
        $awardTitle = "Bronz Kupa - Orta Sorun Çözme Başarısı";
    }
    
    if ($awardTypeId) {
        // İlçe tablosunda bir değişiklik yapmıyoruz çünkü şu an için city_awards tablosu sadece şehir ID'lerini destekliyor
        // Gerçek bir uygulamada, ilçe ödülleri için ayrı bir district_awards tablosu oluşturabilirsiniz
        
        // İlçe adını ödül başlığına ekle
        $awardTitle = "{$districtName} İlçesi - " . $awardTitle;
        $description = "{$cityName} ili {$districtName} ilçe belediyesinin şikayet çözüm performansı sayesinde kazandığı otomatik ödül. Çözüm oranı: %" . number_format($rate, 2);
        
        // Bu ilçe belediyesinin mevcut sistem ödüllerini kontrol et (şehir tablosuna kaydediyoruz)
        $checkAwardSql = "
            SELECT ca.id 
            FROM city_awards ca 
            JOIN award_types at ON ca.award_type_id = at.id
            WHERE ca.city_id = ? AND ca.title LIKE ? AND at.is_system = TRUE
        ";
        $districtTitlePattern = "{$districtName} İlçesi - %";
        $checkAwardStmt = $conn->prepare($checkAwardSql);
        $checkAwardStmt->bind_param('is', $cityId, $districtTitlePattern);
        $checkAwardStmt->execute();
        $existingAward = $checkAwardStmt->get_result()->fetch_assoc();
        
        if ($existingAward) {
            // Mevcut ödülü güncelle
            $updateSql = "
                UPDATE city_awards 
                SET award_type_id = ?, title = ?, description = ?, award_date = ?, expiry_date = ? 
                WHERE id = ?
            ";
            $updateStmt = $conn->prepare($updateSql);
            $updateStmt->bind_param('issssi', $awardTypeId, $awardTitle, $description, $today, $expiryDate, $existingAward['id']);
            
            if ($updateStmt->execute()) {
                echo "{$cityName} / {$districtName} ilçe belediyesinin otomatik ödülü güncellendi. (Çözüm oranı: %{$rate})<br>";
                $awardedDistricts++;
            } else {
                echo "Hata: {$cityName} / {$districtName} ilçe belediyesinin ödülü güncellenemedi. Hata: " . $conn->error . "<br>";
            }
        } else {
            // Yeni ödül ekle
            $insertSql = "
                INSERT INTO city_awards (city_id, award_type_id, title, description, award_date, expiry_date) 
                VALUES (?, ?, ?, ?, ?, ?)
            ";
            $insertStmt = $conn->prepare($insertSql);
            $insertStmt->bind_param('iissss', $cityId, $awardTypeId, $awardTitle, $description, $today, $expiryDate);
            
            if ($insertStmt->execute()) {
                echo "{$cityName} / {$districtName} ilçe belediyesine yeni otomatik ödül verildi. (Çözüm oranı: %{$rate})<br>";
                $awardedDistricts++;
            } else {
                echo "Hata: {$cityName} / {$districtName} ilçe belediyesine ödül verilemedi. Hata: " . $conn->error . "<br>";
            }
        }
    } else {
        echo "{$cityName} / {$districtName} ilçe belediyesi ödül için yeterli çözüm oranına sahip değil. (Çözüm oranı: %{$rate})<br>";
    }
}

// Süresi dolan ödülleri kaldır
$expiredSql = "
    DELETE FROM city_awards 
    WHERE expiry_date < CURRENT_DATE
    AND award_type_id IN (?, ?, ?)
";

$expiredStmt = $conn->prepare($expiredSql);
$expiredStmt->bind_param('iii', $bronzeTrophyId, $silverTrophyId, $goldTrophyId);
$expiredStmt->execute();
$removedCount = $expiredStmt->affected_rows;

echo "<h3>Sonuçlar</h3>";
echo "Ödül verilen şehir sayısı: {$awardedCities} / {$totalCities}<br>";
echo "Ödül verilen ilçe sayısı: {$awardedDistricts} / {$totalDistricts}<br>";
echo "Süresi dolduğu için kaldırılan ödül sayısı: {$removedCount}<br>";
echo "Otomatik ödül kontrolü tamamlandı.<br>";
?>