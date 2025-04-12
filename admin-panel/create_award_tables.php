<?php
require_once 'db_connection.php';

// Ödül türleri tablosu
$sql = "CREATE TABLE IF NOT EXISTS award_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    icon VARCHAR(100),
    icon_url TEXT,
    badge_url TEXT,
    color VARCHAR(20),
    points INTEGER NOT NULL DEFAULT 0,
    is_system BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)";

$stmt = $conn->prepare($sql);
if ($stmt->execute()) {
    echo "Ödül türleri tablosu başarıyla oluşturuldu.<br>";
} else {
    echo "Hata: Ödül türleri tablosu oluşturulamadı.<br>";
}

// Belediye ödülleri tablosu
$sql = "CREATE TABLE IF NOT EXISTS city_awards (
    id SERIAL PRIMARY KEY,
    city_id INTEGER NOT NULL,
    award_type_id INTEGER NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    award_date DATE NOT NULL,
    issuer VARCHAR(100),
    certificate_url TEXT,
    featured BOOLEAN NOT NULL DEFAULT FALSE,
    project_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (city_id) REFERENCES cities(id) ON DELETE CASCADE,
    FOREIGN KEY (award_type_id) REFERENCES award_types(id) ON DELETE CASCADE,
    FOREIGN KEY (project_id) REFERENCES city_projects(id) ON DELETE SET NULL
)";

$stmt = $conn->prepare($sql);
if ($stmt->execute()) {
    echo "Belediye ödülleri tablosu başarıyla oluşturuldu.<br>";
} else {
    echo "Hata: Belediye ödülleri tablosu oluşturulamadı.<br>";
}

// Temel ödül türlerini ekle
$defaultAwardTypes = [
    [
        'name' => 'Çevre Dostu Belediye',
        'description' => 'Çevre koruma ve sürdürülebilirlik alanlarında üstün başarı gösteren belediyeler için verilen ödül.',
        'color' => '#4CAF50',
        'points' => 100
    ],
    [
        'name' => 'Dijital Dönüşüm',
        'description' => 'Dijital hizmetler ve teknolojik yenilikler konusunda öncü belediyeler için verilen ödül.',
        'color' => '#2196F3',
        'points' => 100
    ],
    [
        'name' => 'Sosyal Belediyecilik',
        'description' => 'Sosyal hizmetler ve toplumsal dayanışma projelerinde üstün başarı gösteren belediyeler için verilen ödül.',
        'color' => '#9C27B0',
        'points' => 100
    ],
    [
        'name' => 'Kültür-Sanat Ödülü',
        'description' => 'Kültür ve sanat alanlarında yaptığı çalışmalarla öne çıkan belediyeler için verilen ödül.',
        'color' => '#FF9800',
        'points' => 100
    ],
    [
        'name' => 'Ulaşım ve Altyapı',
        'description' => 'Ulaşım ve altyapı projelerinde başarılı çalışmalar yapan belediyeler için verilen ödül.',
        'color' => '#795548',
        'points' => 100
    ],
    [
        'name' => 'Ayın Belediyesi',
        'description' => 'Genel performans ve vatandaş memnuniyeti açısından ayın en başarılı belediyesi.',
        'color' => '#FFC107',
        'points' => 150
    ],
    [
        'name' => 'Yılın Belediyesi',
        'description' => 'Yıl boyunca gösterdiği performans ve başarılı projelerle öne çıkan belediye.',
        'color' => '#F44336',
        'points' => 200
    ]
];

// Önce mevcut ödül tiplerini kontrol et
$checkSql = "SELECT COUNT(*) as count FROM award_types";
$checkStmt = $conn->prepare($checkSql);
$checkStmt->execute();
$result = $checkStmt->get_result();
$row = $result->fetch_assoc();

// Eğer hiç ödül tipi yoksa ekle
if ($row['count'] == 0) {
    $insertSql = "INSERT INTO award_types (name, description, color, points) VALUES (?, ?, ?, ?)";
    $insertStmt = $conn->prepare($insertSql);
    
    foreach ($defaultAwardTypes as $type) {
        $insertStmt->bind_param('sssi', $type['name'], $type['description'], $type['color'], $type['points']);
        $insertStmt->execute();
    }
    
    echo "Varsayılan ödül türleri başarıyla eklendi.<br>";
} else {
    echo "Ödül türleri zaten mevcut, ekleme yapılmadı.<br>";
}

echo "<p>Kurulum tamamlandı. <a href='index.php'>Ana sayfaya dön</a></p>";
?>