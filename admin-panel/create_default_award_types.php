<?php
require_once 'db_connection.php';

// Önce tablo yapısını güncelle
include_once 'update_award_tables.php';

// Bronz, Gümüş ve Altın kupa ödülleri
$systemAwards = [
    [
        'name' => 'Bronz Kupa',
        'description' => 'Sorun çözme oranı %25-49 arası olan belediyeler için verilen otomatik ödül.',
        'icon' => 'bi-trophy',
        'color' => '#CD7F32', // Bronz rengi
        'points' => 50,
        'is_system' => true
    ],
    [
        'name' => 'Gümüş Kupa',
        'description' => 'Sorun çözme oranı %50-74 arası olan belediyeler için verilen otomatik ödül.',
        'icon' => 'bi-trophy-fill',
        'color' => '#C0C0C0', // Gümüş rengi
        'points' => 100,
        'is_system' => true
    ],
    [
        'name' => 'Altın Kupa',
        'description' => 'Sorun çözme oranı %75 ve üzeri olan belediyeler için verilen otomatik ödül.',
        'icon' => 'bi-trophy-fill',
        'color' => '#FFD700', // Altın rengi
        'points' => 200,
        'is_system' => true
    ]
];

// Bronz, Gümüş ve Altın kupaları ekle/güncelle
foreach ($systemAwards as $award) {
    // Önce bu isimde bir ödül var mı kontrol et
    $checkSql = "SELECT id FROM award_types WHERE name = ?";
    $checkStmt = $conn->prepare($checkSql);
    $checkStmt->bind_param('s', $award['name']);
    $checkStmt->execute();
    $result = $checkStmt->get_result();
    
    if ($result->num_rows > 0) {
        // Varsa güncelle
        $row = $result->fetch_assoc();
        $isSystem = $award['is_system'] ? 'TRUE' : 'FALSE';
        $updateSql = "UPDATE award_types SET description = ?, icon = ?, color = ?, points = ?, is_system = $isSystem WHERE id = ?";
        $updateStmt = $conn->prepare($updateSql);
        $updateStmt->bind_param('sssii', $award['description'], $award['icon'], $award['color'], $award['points'], $row['id']);
        
        if ($updateStmt->execute()) {
            echo "{$award['name']} başarıyla güncellendi.<br>";
        } else {
            echo "Hata: {$award['name']} güncellenemedi. Hata: " . $conn->error . "<br>";
        }
    } else {
        // Yoksa ekle
        $isSystem = $award['is_system'] ? 'TRUE' : 'FALSE';
        $insertSql = "INSERT INTO award_types (name, description, icon, color, points, is_system) VALUES (?, ?, ?, ?, ?, $isSystem)";
        $insertStmt = $conn->prepare($insertSql);
        $insertStmt->bind_param('ssssi', $award['name'], $award['description'], $award['icon'], $award['color'], $award['points']);
        
        if ($insertStmt->execute()) {
            echo "{$award['name']} başarıyla eklendi.<br>";
        } else {
            echo "Hata: {$award['name']} eklenemedi. Hata: " . $conn->error . "<br>";
        }
    }
}

echo "<p>Varsayılan ödüller başarıyla oluşturuldu/güncellendi.</p>";
echo "<p><a href='index.php?page=award_system'>Ödül Sistemi Sayfasına Dön</a></p>";
?>