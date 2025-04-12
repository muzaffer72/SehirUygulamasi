<?php
// Veritabanı bağlantısı
require_once 'admin-panel/db_connection.php';
global $pdo;

// Türkçe isim ve soyisimleri için veri setleri
$firstNames = [
    'Ahmet', 'Mehmet', 'Ali', 'Ayşe', 'Fatma', 'Zeynep', 'Mustafa', 'Emine', 
    'Hüseyin', 'İbrahim', 'Hatice', 'Hasan', 'Merve', 'Hülya', 'Ömer', 'Elif',
    'Emre', 'Selin', 'Buse', 'Yusuf', 'Burak', 'Esra', 'Ceren', 'Deniz', 
    'Onur', 'Gizem', 'Tuğçe', 'Serkan', 'Özge', 'Murat', 'Gamze', 'Kemal',
    'Ece', 'Canan', 'Serdar', 'Sevgi', 'Erkan', 'Zehra', 'Ümit', 'Melek'
];

$lastNames = [
    'Yılmaz', 'Kaya', 'Demir', 'Çelik', 'Şahin', 'Yıldız', 'Yıldırım', 'Öztürk',
    'Aydın', 'Özdemir', 'Arslan', 'Doğan', 'Kılıç', 'Aslan', 'Çetin', 'Koç',
    'Kurt', 'Özkan', 'Şimşek', 'Polat', 'Korkmaz', 'Karataş', 'Bulut', 'Erdoğan',
    'Yalçın', 'Kaplan', 'Avcı', 'Tekin', 'Ünal', 'Gül', 'Aktaş', 'Güneş',
    'Türk', 'Alp', 'Keskin', 'Tunç', 'Duran', 'Güven', 'Sönmez', 'Acar'
];

// Şehirleri veritabanından al
$citiesQuery = "SELECT id FROM cities ORDER BY id ASC";
$stmt = $pdo->query($citiesQuery);
$cityIds = [];
while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
    $cityIds[] = $row['id'];
}

// Yerleşim yerlerine göre kullanıcılar için şehir dağılımı
$randomCities = array_merge(
    array_fill(0, 35, 34), // İstanbul (35 kullanıcı)
    array_fill(0, 20, 6),  // Ankara (20 kullanıcı)
    array_fill(0, 15, 35), // İzmir (15 kullanıcı)
    array_fill(0, 30, array_rand(array_flip($cityIds))) // Diğer şehirler (30 kullanıcı)
);
shuffle($randomCities);

// Kategorileri veritabanından al
$categoriesQuery = "SELECT id FROM categories ORDER BY id ASC";
$stmt = $pdo->query($categoriesQuery);
$categoryIds = [];
while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
    $categoryIds[] = $row['id'];
}

// Örnek yorum ve içerikler
$postTitles = [
    'Sokağımızdaki çöpler toplanmıyor',
    'Park ve bahçelerin durumu kötü',
    'Yol çalışmaları ne zaman bitecek?',
    'Toplu taşıma seferleri yetersiz',
    'Su kesintileri hakkında bilgilendirme',
    'Sokak hayvanları için barınak önerisi',
    'Mahallemizdeki trafik sorunu',
    'Çevre düzenlemesi yapılması gereken bölgeler',
    'Parkların temizliği ve güvenliği',
    'Otobüs hatlarının yetersizliği',
    'Şehir aydınlatması sorunu',
    'Çöp konteynerlerinin yetersizliği',
    'Altyapı çalışmaları ne zaman tamamlanacak?',
    'Engelli erişimi olmayan kaldırımlar',
    'Trafik ışıklarının süreleri düzenlenmeli'
];

$postContents = [
    'Sokağımızda günlerdir çöpler toplanmıyor ve kötü koku oluşmaya başladı. Belediyenin bu sorunu acilen çözmesini talep ediyoruz.',
    'Mahallemizdeki parklar bakımsız durumda. Çocuk oyun alanları tehlikeli ve yeşil alanlar yeterince sulanmıyor.',
    'Caddemizde aylardır süren yol çalışmaları trafik sorununa neden oluyor. Ne zaman bitecek bilgi verilmesini istiyoruz.',
    'Sabah ve akşam saatlerinde toplu taşıma yetersiz kalıyor. Daha sık sefer konulmasını talep ediyoruz.',
    'Sürekli yaşanan su kesintileri günlük hayatımızı olumsuz etkiliyor. Önceden bilgilendirme yapılmasını istiyoruz.',
    'Mahallemizde sokak hayvanları için bir barınak kurulmasını öneriyoruz. Bu sayede hem hayvanlar korunur hem de sokaklar daha güvenli olur.',
    'Okul çıkış saatlerinde trafik çok yoğun oluyor ve bu durum tehlikeli durumlar yaratıyor. Trafik düzenlemesi yapılması gerekiyor.',
    'Semtimizde bulunan boş arazilerin park veya yeşil alan olarak düzenlenmesini talep ediyoruz.',
    'Parklarımızda güvenlik kameraları ve daha fazla aydınlatma olması gerekiyor. Özellikle akşam saatlerinde parklar güvensiz hale geliyor.',
    'Merkeze giden otobüs hatları çok az ve seyrek. Yeni güzergahlar eklenmesini talep ediyoruz.',
    'Bazı sokaklar yeterince aydınlatılmıyor ve bu güvenlik sorunları yaratıyor. Aydınlatma sisteminin güçlendirilmesini istiyoruz.',
    'Çöp konteynerleri yeterli değil ve sık sık taşıyor. Daha fazla konteyner yerleştirilmesi lazım.',
    'Altyapı çalışmaları çok uzun süredir devam ediyor ve günlük hayatımızı olumsuz etkiliyor. Ne zaman biteceği hakkında bilgi verilmesini istiyoruz.',
    'Kaldırımlarda engelli rampası yok ve tekerlekli sandalye kullananlar için ulaşım çok zor. Bu sorunun çözülmesini talep ediyoruz.',
    'Trafik ışıklarının süreleri çok kısa ve karşıdan karşıya geçmek için yeterli olmuyor. Özellikle yaşlılar zorlanıyor.'
];

$commentTexts = [
    'Bu sorunu ben de yaşıyorum. Belediye bu konuyla ilgilenmeli.',
    'Tam olarak katılıyorum, bu durum gerçekten rahatsız edici.',
    'Bence bu sorun bir an önce çözülmeli. Çok uzun süredir devam ediyor.',
    'Bu konuda bir gelişme oldu mu? Bizim bölgede de benzer sıkıntılar var.',
    'Belediyeye bir dilekçe yazalım, toplu şikayet daha etkili olabilir.',
    'Bu sorunu ben defalarca bildirdim ama bir gelişme olmadı.',
    'Geçen ay da aynı sorun yaşanmıştı, kısa sürede düzeltilmişti. Umarım yine çözülür.',
    'Bu şikayeti destekliyorum, aynı sorundan biz de muzdaripiz.',
    'Sorununuzu anlıyorum, bence bir imza kampanyası başlatalım.',
    'Belediyenin çağrı merkezini denediniz mi? Bazen hızlı yanıt veriyorlar.',
    'Bu sorun gerçekten can sıkıcı, yetkililerin dikkate almasını umuyorum.',
    'Farklı kanallardan da şikayet edelim, sosyal medyadan da duyuralım.',
    'Mahalle muhtarına da bildirdiniz mi? Bazen araya girerek yardımcı olabiliyorlar.',
    'Bu konuda yapılan bir çalışma var mı? Bilgi sahibi olan var mı?',
    'Benzer bir sorunu geçen yıl çözdürmüştük, size nasıl yardımcı olabileceğimi yazarsanız destek olurum.'
];

// Kullanıcı oluşturma fonksiyonu
function hashPassword($password) {
    $salt = bin2hex(random_bytes(16));
    $hash = hash('sha256', $password . $salt);
    return $hash . '.' . $salt;
}

function generateUsername($firstName, $lastName) {
    $username = strtolower(transliterateTurkishChars($firstName)) . '.' . strtolower(transliterateTurkishChars($lastName));
    return $username . rand(10, 999);
}

function transliterateTurkishChars($text) {
    $search = ['ç', 'Ç', 'ğ', 'Ğ', 'ı', 'İ', 'ö', 'Ö', 'ş', 'Ş', 'ü', 'Ü'];
    $replace = ['c', 'C', 'g', 'G', 'i', 'I', 'o', 'O', 's', 'S', 'u', 'U'];
    return str_replace($search, $replace, $text);
}

// Rastgele avatar URL'leri
$avatarUrls = [
    'https://randomuser.me/api/portraits/men/1.jpg',
    'https://randomuser.me/api/portraits/women/1.jpg',
    'https://randomuser.me/api/portraits/men/2.jpg',
    'https://randomuser.me/api/portraits/women/2.jpg',
    'https://randomuser.me/api/portraits/men/3.jpg',
    'https://randomuser.me/api/portraits/women/3.jpg',
    'https://randomuser.me/api/portraits/men/4.jpg',
    'https://randomuser.me/api/portraits/women/4.jpg',
    'https://randomuser.me/api/portraits/men/5.jpg',
    'https://randomuser.me/api/portraits/women/5.jpg'
];

// İlerleme göstergesi için fonksiyon
function showProgress($current, $total, $message) {
    $percent = round(($current / $total) * 100);
    echo "\r[$percent%] $message $current/$total";
    flush();
}

// Veritabanı işlemleri başlatılıyor
$pdo->beginTransaction();

try {
    // 1. Kullanıcıları oluştur
    echo "Kullanıcılar oluşturuluyor...\n";
    $userIds = [];
    $userCount = 10;
    
    for ($i = 0; $i < $userCount; $i++) {
        $firstName = $firstNames[array_rand($firstNames)];
        $lastName = $lastNames[array_rand($lastNames)];
        $fullName = "$firstName $lastName";
        $username = generateUsername($firstName, $lastName);
        $email = $username . '@example.com';
        $password = hashPassword('test1234');
        $city_id = $randomCities[$i] ?? 34; // Varsayılan olarak İstanbul
        $profileImage = $avatarUrls[array_rand($avatarUrls)];
        
        $query = "INSERT INTO users (name, username, email, password, city_id, profile_image_url, level) 
                  VALUES (?, ?, ?, ?, ?, ?, ?)";
        $stmt = $pdo->prepare($query);
        
        // Kullanıcı seviyelerini dağıt (çoğunluk newUser, bazıları daha yüksek seviyeler)
        $levelDistribution = ['newUser', 'newUser', 'newUser', 'newUser', 'contributor', 'contributor', 'active', 'expert', 'master'];
        $level = $levelDistribution[array_rand($levelDistribution)];
        
        $stmt->execute([$fullName, $username, $email, $password, $city_id, $profileImage, $level]);
        
        $userIds[] = $pdo->lastInsertId();
        showProgress($i + 1, $userCount, "Kullanıcı oluşturuldu");
    }
    echo "\nKullanıcılar başarıyla oluşturuldu.\n";
    
    // 2. Post oluştur
    echo "Paylaşımlar oluşturuluyor...\n";
    $postIds = [];
    $postCount = 10;
    
    $postStatuses = ['awaitingSolution', 'inProgress', 'solved', 'rejected'];
    $postTypes = ['problem', 'problem', 'problem', 'suggestion', 'suggestion', 'announcement', 'general'];
    
    for ($i = 0; $i < $postCount; $i++) {
        $userId = $userIds[array_rand($userIds)];
        $title = $postTitles[array_rand($postTitles)];
        $content = $postContents[array_rand($postContents)];
        $status = $postStatuses[array_rand($postStatuses)];
        $type = $postTypes[array_rand($postTypes)];
        $city_id = $randomCities[array_rand($randomCities)];
        
        // İlçe ID'si almak için
        $districtQuery = "SELECT id FROM districts WHERE city_id = ? ORDER BY RANDOM() LIMIT 1";
        $districtStmt = $pdo->prepare($districtQuery);
        $districtStmt->execute([$city_id]);
        $district = $districtStmt->fetch(PDO::FETCH_ASSOC);
        $district_id = $district['id'] ?? null;
        
        $category_id = $categoryIds[array_rand($categoryIds)];
        
        $query = "INSERT INTO posts (user_id, title, content, status, type, city_id, district_id, category_id) 
                  VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        $stmt = $pdo->prepare($query);
        $stmt->execute([$userId, $title, $content, $status, $type, $city_id, $district_id, $category_id]);
        
        $postIds[] = $pdo->lastInsertId();
        showProgress($i + 1, $postCount, "Paylaşım oluşturuldu");
    }
    echo "\nPaylaşımlar başarıyla oluşturuldu.\n";
    
    // 3. Yorumlar oluştur
    echo "Yorumlar oluşturuluyor...\n";
    $commentCount = 20; // Toplam yorum sayısı
    $commentIds = [];
    
    for ($i = 0; $i < $commentCount; $i++) {
        $postId = $postIds[array_rand($postIds)];
        $userId = $userIds[array_rand($userIds)];
        $content = $commentTexts[array_rand($commentTexts)];
        // İleri özellikleri sonradan ekleyeceğiz
        
        $query = "INSERT INTO comments (post_id, user_id, content)
                  VALUES (?, ?, ?)";
        $stmt = $pdo->prepare($query);
        $stmt->execute([$postId, $userId, $content]);
        
        $commentIds[] = $pdo->lastInsertId();
        
        // Post'un yorum sayacını güncelle
        $updatePostQuery = "UPDATE posts SET comment_count = comment_count + 1 WHERE id = ?";
        $updateStmt = $pdo->prepare($updatePostQuery);
        $updateStmt->execute([$postId]);
        
        showProgress($i + 1, $commentCount, "Yorum oluşturuldu");
    }
    echo "\nYorumlar başarıyla oluşturuldu.\n";
    
    // 4. Beğeniler oluştur
    echo "Beğeniler oluşturuluyor...\n";
    $likeCount = 30; // Toplam beğeni sayısı
    $likeTracker = []; // Aynı kullanıcının aynı içeriği tekrar beğenmesini önlemek için
    
    for ($i = 0; $i < $likeCount; $i++) {
        $tries = 0;
        $unique = false;
        
        // Benzersiz kullanıcı-post kombinasyonu bul
        while (!$unique && $tries < 10) {
            $postId = $postIds[array_rand($postIds)];
            $userId = $userIds[array_rand($userIds)];
            $key = $userId . '-' . $postId;
            
            if (!isset($likeTracker[$key])) {
                $unique = true;
                $likeTracker[$key] = true;
            }
            $tries++;
        }
        
        if ($unique) {
            $query = "INSERT INTO user_likes (user_id, post_id) VALUES (?, ?)";
            $stmt = $pdo->prepare($query);
            $stmt->execute([$userId, $postId]);
            
            // Post'un beğeni sayacını güncelle
            $updatePostQuery = "UPDATE posts SET likes = likes + 1 WHERE id = ?";
            $updateStmt = $pdo->prepare($updatePostQuery);
            $updateStmt->execute([$postId]);
            
            showProgress($i + 1, $likeCount, "Beğeni oluşturuldu");
        }
    }
    echo "\nBeğeniler başarıyla oluşturuldu.\n";
    
    // 5. Yorum beğenileri oluştur
    echo "Yorum beğenileri oluşturuluyor...\n";
    $commentLikeCount = 20;
    $commentLikeTracker = [];
    
    for ($i = 0; $i < $commentLikeCount; $i++) {
        $tries = 0;
        $unique = false;
        
        while (!$unique && $tries < 10) {
            $commentId = $commentIds[array_rand($commentIds)];
            $userId = $userIds[array_rand($userIds)];
            $key = $userId . '-' . $commentId;
            
            if (!isset($commentLikeTracker[$key])) {
                $unique = true;
                $commentLikeTracker[$key] = true;
            }
            $tries++;
        }
        
        if ($unique) {
            $query = "INSERT INTO user_likes (user_id, comment_id) VALUES (?, ?)";
            $stmt = $pdo->prepare($query);
            $stmt->execute([$userId, $commentId]);
            
            showProgress($i + 1, $commentLikeCount, "Yorum beğenisi oluşturuldu");
        }
    }
    echo "\nYorum beğenileri başarıyla oluşturuldu.\n";
    
    // Öne çıkarma özelliği veritabanında hazır değil, şimdilik atlıyoruz
    $highlightCount = 0;
    
    // İşlemleri onayla
    $pdo->commit();
    echo "\n\nTüm işlemler başarıyla tamamlandı! Toplam oluşturulan veriler:\n";
    echo "- $userCount kullanıcı\n";
    echo "- $postCount paylaşım\n";
    echo "- $commentCount yorum\n";
    echo "- $likeCount beğeni\n";
    echo "- $commentLikeCount yorum beğenisi\n";
    echo "- $highlightCount öne çıkarma\n";
    
} catch (Exception $e) {
    // Hata durumunda geri alma
    $pdo->rollBack();
    echo "Hata oluştu: " . $e->getMessage() . "\n";
    echo "İşlemler geri alındı.\n";
}
?>