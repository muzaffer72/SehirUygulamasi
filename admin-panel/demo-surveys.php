<?php
/**
 * ŞikayetVar Admin Panel - Demo Anket Verilerini Ekle
 */

// Veritabanı bağlantısı
require_once 'db_connection.php';

// Bugünün ve bir ay sonrasının tarihlerini al
$today = date('Y-m-d');
$nextMonth = date('Y-m-d', strtotime('+1 month'));

try {
    // Veritabanında anket tablosu var mı kontrol et
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM surveys");
    $count = $stmt->fetch(PDO::FETCH_ASSOC)['count'];
    
    // Eğer anket yoksa, demo anketleri ekle
    if ($count == 0) {
        echo "Demo anketleri ekleniyor...<br>";
        
        // Demo anketleri tanımla
        $demoSurveys = [
            [
                'title' => 'Şehir İçi Ulaşım Memnuniyeti',
                'short_title' => 'Ulaşım Anketi',
                'description' => 'Bu anket, şehirdeki toplu taşıma ve ulaşım hizmetleri hakkında vatandaş memnuniyetini ölçmek için hazırlanmıştır.',
                'category_id' => 3, // Ulaşım
                'scope_type' => 'general',
                'city_id' => null,
                'district_id' => null,
                'start_date' => $today,
                'end_date' => $nextMonth,
                'total_users' => 5000,
                'is_active' => true,
                'options' => [
                    'Çok memnunum',
                    'Memnunum',
                    'Kararsızım',
                    'Memnun değilim',
                    'Hiç memnun değilim'
                ]
            ],
            [
                'title' => 'Belediye Hizmetleri Değerlendirme',
                'short_title' => 'Belediye Hizmetleri',
                'description' => 'Belediyenin sunduğu hizmetlerden memnuniyet düzeyinizi belirtiniz.',
                'category_id' => 10, // Diğer
                'scope_type' => 'city',
                'city_id' => 34, // İstanbul
                'district_id' => null,
                'start_date' => $today,
                'end_date' => $nextMonth,
                'total_users' => 3000,
                'is_active' => true,
                'options' => [
                    'Çok iyi',
                    'İyi',
                    'Ortalama',
                    'Kötü',
                    'Çok kötü'
                ]
            ],
            [
                'title' => 'Çevre Temizliği ve Atık Yönetimi',
                'short_title' => 'Çevre Temizliği',
                'description' => 'Yaşadığınız bölgede çevre temizliği ve atık yönetimi hakkındaki düşünceleriniz nelerdir?',
                'category_id' => 2, // Çevre
                'scope_type' => 'district',
                'city_id' => 34, // İstanbul
                'district_id' => 1, // Örnek ilçe ID'si
                'start_date' => $today,
                'end_date' => $nextMonth,
                'total_users' => 2000,
                'is_active' => true,
                'options' => [
                    'Çok temiz ve düzenli',
                    'Yeterince temiz',
                    'Bazen sorunlar yaşanıyor',
                    'Genellikle kirli',
                    'Çok kirli ve düzensiz'
                ]
            ],
            [
                'title' => 'Kültür ve Sanat Etkinlikleri',
                'short_title' => 'Kültür-Sanat',
                'description' => 'Şehrinizde düzenlenen kültür ve sanat etkinlikleri hakkında ne düşünüyorsunuz?',
                'category_id' => 8, // Kültür ve Sanat
                'scope_type' => 'city',
                'city_id' => 6, // Ankara
                'district_id' => null,
                'start_date' => $today,
                'end_date' => $nextMonth,
                'total_users' => 1500,
                'is_active' => false,
                'options' => [
                    'Çok çeşitli ve yeterli',
                    'Yeterli sayıda ama çeşitlilik az',
                    'Yetersiz ama kaliteli',
                    'Hem sayıca hem kalite açısından yetersiz'
                ]
            ],
            [
                'title' => 'Sokak Hayvanları Politikası',
                'short_title' => 'Sokak Hayvanları',
                'description' => 'Sokak hayvanlarına yönelik belediye politikalarını nasıl değerlendiriyorsunuz?',
                'category_id' => 10, // Diğer
                'scope_type' => 'general',
                'city_id' => null,
                'district_id' => null,
                'start_date' => $today,
                'end_date' => $nextMonth,
                'total_users' => 4000,
                'is_active' => true,
                'options' => [
                    'Çok başarılı buluyorum',
                    'Yeterli buluyorum',
                    'Kısmen yeterli buluyorum',
                    'Yetersiz buluyorum',
                    'Çok başarısız buluyorum'
                ]
            ]
        ];
        
        // Her anket için ekle
        foreach ($demoSurveys as $survey) {
            $stmt = $pdo->prepare("
                INSERT INTO surveys 
                    (title, short_title, description, category_id, scope_type, 
                     city_id, district_id, start_date, end_date, 
                     total_users, is_active, created_at)
                VALUES 
                    (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)
                RETURNING id
            ");
            
            $stmt->execute([
                $survey['title'],
                $survey['short_title'],
                $survey['description'],
                $survey['category_id'],
                $survey['scope_type'],
                $survey['city_id'],
                $survey['district_id'],
                $survey['start_date'],
                $survey['end_date'],
                $survey['total_users'],
                ($survey['is_active'] ? 'true' : 'false')
            ]);
            
            $result = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if ($result && isset($result['id'])) {
                $surveyId = $result['id'];
                
                // Seçenekleri ekle
                $optionStmt = $pdo->prepare("
                    INSERT INTO survey_options (survey_id, text, vote_count)
                    VALUES (?, ?, ?)
                ");
                
                foreach ($survey['options'] as $option) {
                    // Rastgele oy sayısı
                    $voteCount = rand(0, 100);
                    $optionStmt->execute([$surveyId, $option, $voteCount]);
                }
                
                echo "Anket eklendi: " . $survey['title'] . "<br>";
            }
        }
        
        echo "Demo anketler başarıyla eklendi.<br>";
    } else {
        echo "Veritabanında zaten " . $count . " adet anket var. Demo veriler eklenmedi.<br>";
    }
    
} catch (PDOException $e) {
    echo "Hata: " . $e->getMessage();
}

echo "<br><a href='index.php?page=surveys'>Anketler Sayfasına Dön</a>";