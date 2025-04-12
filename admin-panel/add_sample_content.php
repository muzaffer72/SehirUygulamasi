<?php
// Bu script, veritabanına örnek içerikler ekler

// Database bağlantısı
require_once 'db_config.php';
require_once 'db_connection.php';
$db = $conn;

echo "<h2>Örnek İçerik Ekleme Aracı</h2>";

// Veritabanı tablolarını kontrol et
try {
    // Şehirler tablosunu kontrol et
    $query = "SELECT COUNT(*) as count FROM cities";
    $result = $db->query($query);
    $city_count = $result->fetch_assoc()['count'];
    
    // İlçeler tablosunu kontrol et
    $query = "SELECT COUNT(*) as count FROM districts";
    $result = $db->query($query);
    $district_count = $result->fetch_assoc()['count'];
    
    // Kategoriler tablosunu kontrol et
    $query = "SELECT COUNT(*) as count FROM categories";
    $result = $db->query($query);
    $category_count = $result->fetch_assoc()['count'];
    
    // Kullanıcılar tablosunu kontrol et
    $query = "SELECT COUNT(*) as count FROM users";
    $result = $db->query($query);
    $user_count = $result->fetch_assoc()['count'];
    
    echo "<p>Tablolarda kayıt durumu:</p>";
    echo "<ul>";
    echo "<li>Şehirler: $city_count kayıt</li>";
    echo "<li>İlçeler: $district_count kayıt</li>";
    echo "<li>Kategoriler: $category_count kayıt</li>";
    echo "<li>Kullanıcılar: $user_count kayıt</li>";
    echo "</ul>";
    
    if ($city_count == 0 || $district_count == 0 || $category_count == 0 || $user_count == 0) {
        echo "<div style='color: red; font-weight: bold;'>UYARI: Bazı tablolarda kayıt bulunmuyor. Önce temel verileri yüklemeniz gerekiyor.</div>";
        exit;
    }
} catch (Exception $e) {
    echo "<div style='color: red;'>Hata: " . $e->getMessage() . "</div>";
    exit;
}

// Şu anki içerik sayısını kontrol et
try {
    $query = "SELECT COUNT(*) as count FROM posts";
    $result = $db->query($query);
    $post_count = $result->fetch_assoc()['count'];
    
    echo "<p>Mevcut içerik sayısı: $post_count</p>";
} catch (Exception $e) {
    echo "<div style='color: red;'>Posts tablosu kontrolünde hata: " . $e->getMessage() . "</div>";
    exit;
}

// Medya tablosunda kayıt olup olmadığını kontrol et
try {
    $query = "SELECT to_regclass('public.media') IS NOT NULL AS table_exists";
    $result = $db->query($query);
    $media_table_exists = $result->fetch_assoc()['table_exists'] ?? false;
    
    if (!$media_table_exists) {
        echo "<div style='color: orange;'>Medya tablosu bulunamadı. Media tablosunu oluşturuyorum...</div>";
        
        // Medya tablosunu oluştur
        $createTable = "CREATE TABLE IF NOT EXISTS media (
            id SERIAL PRIMARY KEY,
            post_id INTEGER NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
            media_type VARCHAR(20) NOT NULL,
            media_url VARCHAR(255) NOT NULL,
            thumbnail_url VARCHAR(255),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )";
        
        if ($db->query($createTable)) {
            echo "<div style='color: green;'>Media tablosu başarıyla oluşturuldu.</div>";
        } else {
            echo "<div style='color: red;'>Media tablosu oluşturulamadı</div>";
            exit;
        }
    } else {
        // Medya tablosundaki kayıt sayısını kontrol et
        $query = "SELECT COUNT(*) as count FROM media";
        $result = $db->query($query);
        $media_count = $result->fetch_assoc()['count'];
        
        echo "<p>Medya tablosunda $media_count kayıt var.</p>";
    }
} catch (Exception $e) {
    echo "<div style='color: red;'>Medya tablosu kontrolünde hata: " . $e->getMessage() . "</div>";
    exit;
}

// Rastgele ID'ler almak için yardımcı fonksiyonlar
function getRandomCity($db) {
    $query = "SELECT id FROM cities ORDER BY RANDOM() LIMIT 1";
    $result = $db->query($query);
    return $result->fetch_assoc()['id'];
}

function getRandomDistrict($db, $city_id) {
    $query = "SELECT id FROM districts WHERE city_id = ? ORDER BY RANDOM() LIMIT 1";
    $stmt = $db->prepare($query);
    $stmt->bind_param("i", $city_id);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows > 0) {
        return $result->fetch_assoc()['id'];
    } else {
        // Eğer o şehirde ilçe bulunamazsa, herhangi bir ilçe döndür
        $query = "SELECT id FROM districts ORDER BY RANDOM() LIMIT 1";
        $result = $db->query($query);
        return $result->fetch_assoc()['id'];
    }
}

function getRandomCategory($db) {
    $query = "SELECT id FROM categories ORDER BY RANDOM() LIMIT 1";
    $result = $db->query($query);
    return $result->fetch_assoc()['id'];
}

function getRandomUser($db) {
    $query = "SELECT id FROM users ORDER BY RANDOM() LIMIT 1";
    $result = $db->query($query);
    return $result->fetch_assoc()['id'];
}

// Rastgele durum, içerik tipi seçimi
function getRandomStatus() {
    $statuses = ['awaitingSolution', 'inProgress', 'solved', 'rejected'];
    return $statuses[array_rand($statuses)];
}

function getRandomPostType() {
    $types = ['problem', 'suggestion', 'announcement', 'general'];
    return $types[array_rand($types)];
}

// Örnek içerikler
$sample_posts = [
    [
        'title' => 'Park alanında çöp sorunu',
        'content' => 'Atatürk Parkı\'nda son zamanlarda çöp kutuları düzenli olarak boşaltılmıyor. Özellikle hafta sonları park çöplerle doluyor ve kötü koku oluşuyor. Bu sorunun en kısa zamanda çözülmesi gerekiyor. Çocukların oyun alanları da temiz değil.',
        'post_type' => 'problem',
        'has_media' => true,
        'media_type' => 'image',
        'media_url' => 'https://images.unsplash.com/photo-1605600659873-d808a13e4d2f?q=80&w=1000',
        'likes' => rand(5, 100),
        'highlights' => rand(0, 30)
    ],
    [
        'title' => 'İlçemizde yeni bisiklet yolları yapılsın',
        'content' => 'Bisiklet kullanımını teşvik etmek ve daha sağlıklı bir toplum oluşturmak için ilçemize güvenli bisiklet yolları yapılmasını öneriyorum. Özellikle ana caddelerde ve sahil şeridinde bisiklet yolları yapılırsa hem trafik rahatlar hem de insanlar daha fazla spor yapar.',
        'post_type' => 'suggestion',
        'has_media' => true,
        'media_type' => 'image',
        'media_url' => 'https://images.unsplash.com/photo-1528262502195-26dfb3c29f8f?q=80&w=1000',
        'likes' => rand(10, 200),
        'highlights' => rand(5, 50)
    ],
    [
        'title' => 'Kaldırımlarda engelli erişimi sorunu',
        'content' => 'Merkez mahallede kaldırımların birçoğunda engelli rampaları ya yok ya da standartlara uygun değil. Tekerlekli sandalye kullananlar ve görme engelliler için bu durum büyük sorun yaratıyor. Ayrıca bazı kaldırımlarda ağaç kökleri kaldırımları kaldırmış durumda.',
        'post_type' => 'problem',
        'has_media' => true,
        'media_type' => 'image',
        'media_url' => 'https://images.unsplash.com/photo-1628515334134-870832b6e76a?q=80&w=1000',
        'likes' => rand(20, 150),
        'highlights' => rand(10, 40)
    ],
    [
        'title' => 'Mahalle sakinlerine ücretsiz sağlık taraması',
        'content' => 'Bu hafta sonu, 09:00-17:00 saatleri arasında Kültür Merkezi\'nde ücretsiz sağlık taraması yapılacaktır. Tansiyon, şeker, kolesterol ölçümleri ve genel sağlık kontrolü için tüm mahalle sakinlerimiz davetlidir. Lütfen kimlik kartınızı getirmeyi unutmayın.',
        'post_type' => 'announcement',
        'has_media' => false,
        'media_type' => null,
        'media_url' => null,
        'likes' => rand(30, 120),
        'highlights' => rand(15, 60)
    ],
    [
        'title' => 'Sokak hayvanları için mama ve su kapları',
        'content' => 'İlçemizin çeşitli noktalarına sokak hayvanları için mama ve su kapları yerleştirilmesini öneriyorum. Özellikle yaz aylarında su bulma konusunda zorluk yaşayan sokak hayvanları için bu önemli bir ihtiyaç. Belediyenin bu konuya duyarlı davranacağını umuyorum.',
        'post_type' => 'suggestion',
        'has_media' => true,
        'media_type' => 'image',
        'media_url' => 'https://images.unsplash.com/photo-1549042261-24c2ddb5df68?q=80&w=1000',
        'likes' => rand(50, 300),
        'highlights' => rand(20, 100)
    ],
    [
        'title' => 'Trafik ışıklarının çalışmaması',
        'content' => 'Ana bulvardaki trafik ışıkları üç gündür çalışmıyor. Bu durum özellikle sabah ve akşam saatlerinde trafik karmaşasına yol açıyor. Kaza riski yüksek, acilen tamir edilmesi gerekiyor.',
        'post_type' => 'problem',
        'has_media' => true,
        'media_type' => 'video',
        'media_url' => 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        'likes' => rand(15, 180),
        'highlights' => rand(5, 50)
    ],
    [
        'title' => 'Spor salonu ücretlerindeki artış',
        'content' => 'Belediyeye ait spor salonunda ücretlere yapılan son zamlar çok yüksek. Özellikle öğrenciler ve emekliler bu zamlardan sonra spor salonunu kullanamaz hale geldi. Belediyenin bu konuyu tekrar değerlendirmesini ve özellikle öğrenci ve emekliler için indirimli tarifeler uygulamasını rica ediyorum.',
        'post_type' => 'general',
        'has_media' => false,
        'media_type' => null,
        'media_url' => null,
        'likes' => rand(25, 150),
        'highlights' => rand(10, 45)
    ],
    [
        'title' => 'Yeni açılan kültür merkezi',
        'content' => 'Geçen hafta açılan kültür merkezi gerçekten çok güzel olmuş. Özellikle kütüphane bölümü çok ferah ve kullanışlı. Belediyemizi bu güzel hizmet için tebrik ediyorum. Umarım benzer projelere devam edilir ve kültürel etkinlikler artırılır.',
        'post_type' => 'general',
        'has_media' => true,
        'media_type' => 'image',
        'media_url' => 'https://images.unsplash.com/photo-1526714719019-b3032b5b5aac?q=80&w=1000',
        'likes' => rand(40, 250),
        'highlights' => rand(20, 80)
    ],
    [
        'title' => 'Sel baskını sonrası altyapı sorunu',
        'content' => 'Geçen haftaki yağışlar sonrası Yeni Mahalle\'de ciddi sel baskınları yaşandı. Birçok ev ve iş yerinin alt katları su altında kaldı. Bu durum altyapının yetersiz olduğunu gösteriyor. Belediyenin özellikle yağmur suyu kanallarını temizlemesi ve genişletmesi gerekiyor.',
        'post_type' => 'problem',
        'has_media' => true,
        'media_type' => 'video',
        'media_url' => 'https://www.youtube.com/watch?v=a3ICNMQW7Ok',
        'likes' => rand(60, 350),
        'highlights' => rand(30, 120)
    ],
    [
        'title' => 'Sokak aydınlatmalarının yetersizliği',
        'content' => 'Bahçelievler bölgesindeki sokak lambaları çok seyrek ve ışıkları yetersiz. Bu durum özellikle kış aylarında akşam saatlerinde güvenlik sorunu yaratıyor. Aydınlatmaların artırılması ve mevcut lambaların daha güçlü LED lambalarla değiştirilmesi faydalı olacaktır.',
        'post_type' => 'suggestion',
        'has_media' => false,
        'media_type' => null,
        'media_url' => null,
        'likes' => rand(35, 200),
        'highlights' => rand(15, 70)
    ],
];

// İçerikleri eklemeye başla
echo "<h3>İçerik ekleme işlemi başlıyor...</h3>";

$added_posts = 0;
$added_media = 0;

foreach ($sample_posts as $post) {
    // Rastgele veriler
    $city_id = getRandomCity($db);
    $district_id = getRandomDistrict($db, $city_id);
    $category_id = getRandomCategory($db);
    $user_id = getRandomUser($db);
    $status = getRandomStatus();
    $post_type = $post['post_type'];
    $likes = $post['likes'];
    $highlights = $post['highlights'];
    
    try {
        // Post ekle - PostgreSQL için INTERVAL sözdizimini düzelt ve RETURNING kullan
        // Ayrıca post_type yerine type sütununu kullan
        $random_days = rand(1, 30); // Rastgele bir tarih
        $query = "INSERT INTO posts (title, content, user_id, city_id, district_id, category_id, status, type, likes, highlights, created_at, is_anonymous, comment_count) 
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW() - INTERVAL '$random_days DAYS', false, 0) RETURNING id";
        $stmt = $db->prepare($query);
        $stmt->bind_param("ssiiiiissi", $post['title'], $post['content'], $user_id, $city_id, $district_id, 
                         $category_id, $status, $post_type, $likes, $highlights);
        
        if ($stmt->execute()) {
            $result = $stmt->get_result();
            $post_id = $result->fetch_assoc()['id'];
            $added_posts++;
            
            echo "<div style='padding: 5px; margin-bottom: 10px; border-bottom: 1px solid #ccc;'>";
            echo "<strong>Post eklendi:</strong> {$post['title']} (ID: $post_id)";
            echo "<br>Şehir: $city_id, İlçe: $district_id, Kategori: $category_id, Kullanıcı: $user_id";
            echo "<br>Durum: $status, Tip: $post_type";
            
            // Medya ekle (eğer varsa)
            if ($post['has_media']) {
                $media_type = $post['media_type'];
                $media_url = $post['media_url'];
                
                // Tabloya uygun sütun isimlerini kullan (media_type -> type, media_url -> url, thumbnail_url yok)
                $query = "INSERT INTO media (post_id, type, url, created_at) 
                         VALUES (?, ?, ?, NOW()) RETURNING id";
                $stmt2 = $db->prepare($query);
                $stmt2->bind_param("iss", $post_id, $media_type, $media_url);
                
                if ($stmt2->execute()) {
                    $result = $stmt2->get_result();
                    $media_id = $result->fetch_assoc()['id'];
                    $added_media++;
                    echo "<br><span style='color: green;'>Medya eklendi: $media_type (ID: $media_id)</span>";
                } else {
                    echo "<br><span style='color: red;'>Medya eklenemedi</span>";
                }
            }
            
            echo "</div>";
        } else {
            echo "<div style='color: red;'>Post eklenemedi</div>";
        }
    } catch (Exception $e) {
        echo "<div style='color: red;'>Hata: " . $e->getMessage() . "</div>";
    }
}

echo "<h3>İşlem tamamlandı</h3>";
echo "<p>Eklenen içerik sayısı: $added_posts</p>";
echo "<p>Eklenen medya sayısı: $added_media</p>";

echo "<p><a href='index.php?page=posts' class='btn btn-primary'>Şikayetler Sayfasına Git</a></p>";
?>