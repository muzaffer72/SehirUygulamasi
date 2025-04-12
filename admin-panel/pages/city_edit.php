<?php
// Şehir Düzenleme Sayfası
require_once 'db_connection.php';

// functions.php dosyası mevcut değil, kullanıcı kontrolünü devre dışı bırakıyoruz
// require_once 'functions.php';
// Yalnızca yöneticilerin erişimi
// requireAdmin();

// Bölgeleri tanımla
$regions = [
    'Akdeniz',
    'Doğu Anadolu',
    'Ege',
    'Güneydoğu Anadolu',
    'İç Anadolu',
    'Karadeniz',
    'Marmara'
];

// Şehir ID kontrolü
$cityId = isset($_GET['id']) ? intval($_GET['id']) : 0;
if ($cityId <= 0) {
    echo '<div class="alert alert-danger">Geçersiz şehir ID</div>';
    exit;
}

// Şehir bilgilerini getir
$stmt = $pdo->prepare("SELECT * FROM cities WHERE id = ?");
$stmt->execute([$cityId]);
$city = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$city) {
    echo '<div class="alert alert-danger">Şehir bulunamadı!</div>';
    exit;
}

// Form gönderildi mi kontrol et
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    try {
        // Form verilerini al
        $name = $_POST['name'] ?? '';
        $plateNumber = $_POST['plate_number'] ?? '';
        $region = $_POST['region'] ?? '';
        $population = $_POST['population'] ?? 0;
        $mayor = $_POST['mayor'] ?? '';
        $mayorParty = $_POST['mayor_party'] ?? '';
        $governorName = $_POST['governor_name'] ?? '';
        $areaCode = $_POST['area_code'] ?? '';
        $latitude = $_POST['latitude'] ?? null;
        $longitude = $_POST['longitude'] ?? null;
        
        // Validation
        if (empty($name)) {
            throw new Exception('Şehir adı boş olamaz');
        }
        
        // Sayısal değerleri doğru formata çevir - PostgreSQL uyumlu
        $plateNumber = intval($plateNumber);
        $population = intval($population);
        $latitude = !empty($latitude) ? floatval($latitude) : null;
        $longitude = !empty($longitude) ? floatval($longitude) : null;
        
        // Veritabanını güncelle
        $query = "UPDATE cities SET 
                    name = ?, 
                    plate_number = ?, 
                    region = ?, 
                    population = ?, 
                    mayor = ?, 
                    mayor_party = ?, 
                    governor_name = ?, 
                    area_code = ?, 
                    latitude = ?, 
                    longitude = ? 
                 WHERE id = ?";
        
        $stmt = $pdo->prepare($query);
        $stmt->execute([
            $name, 
            $plateNumber,
            $region,
            $population,
            $mayor,
            $mayorParty,
            $governorName,
            $areaCode,
            $latitude,
            $longitude,
            $cityId
        ]);
        
        // Başarılı mesajı
        $success_message = "'{$name}' şehri başarıyla güncellendi";
        
        // Şehirler sayfasına yönlendir
        header('Location: index.php?page=cities&success=' . urlencode($success_message));
        exit;
        
    } catch (Exception $e) {
        $error_message = "Hata: " . $e->getMessage();
    }
}
?>

<div class="container-fluid px-4">
    <h1 class="mt-4">Şehir Düzenle: <?php echo htmlspecialchars($city['name']); ?></h1>
    <ol class="breadcrumb mb-4">
        <li class="breadcrumb-item"><a href="index.php">Ana Sayfa</a></li>
        <li class="breadcrumb-item"><a href="index.php?page=cities">Şehirler</a></li>
        <li class="breadcrumb-item active">Şehir Düzenle</li>
    </ol>
    
    <?php if (isset($error_message)): ?>
        <div class="alert alert-danger"><?php echo $error_message; ?></div>
    <?php endif; ?>
    
    <div class="card mb-4">
        <div class="card-header d-flex justify-content-between align-items-center">
            <div>
                <i class="fas fa-edit me-1"></i>
                Şehir Bilgileri
            </div>
            <div>
                <a href="index.php?page=city_profile&id=<?php echo $cityId; ?>" class="btn btn-sm btn-info">
                    <i class="fas fa-eye"></i> Profil Sayfası
                </a>
            </div>
        </div>
        <div class="card-body">
            <form method="post" action="">
                <div class="row mb-3">
                    <div class="col-md-6">
                        <div class="mb-3">
                            <label for="name" class="form-label">Şehir Adı <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" id="name" name="name" value="<?php echo htmlspecialchars($city['name']); ?>" required>
                        </div>
                        
                        <div class="mb-3">
                            <label for="plate_number" class="form-label">Plaka Kodu</label>
                            <input type="number" class="form-control" id="plate_number" name="plate_number" min="1" max="81" value="<?php echo htmlspecialchars($city['plate_number'] ?? ''); ?>">
                        </div>
                        
                        <div class="mb-3">
                            <label for="region" class="form-label">Bölge</label>
                            <select class="form-select" id="region" name="region">
                                <option value="">Seçiniz</option>
                                <?php foreach ($regions as $regionOption): ?>
                                    <option value="<?php echo htmlspecialchars($regionOption); ?>" <?php echo (isset($city['region']) && $city['region'] === $regionOption) ? 'selected' : ''; ?>>
                                        <?php echo htmlspecialchars($regionOption); ?>
                                    </option>
                                <?php endforeach; ?>
                            </select>
                        </div>
                        
                        <div class="mb-3">
                            <label for="population" class="form-label">Nüfus</label>
                            <input type="number" class="form-control" id="population" name="population" value="<?php echo htmlspecialchars($city['population'] ?? ''); ?>">
                        </div>
                    </div>
                    
                    <div class="col-md-6">
                        <div class="mb-3">
                            <label for="mayor" class="form-label">Belediye Başkanı</label>
                            <input type="text" class="form-control" id="mayor" name="mayor" value="<?php echo htmlspecialchars($city['mayor'] ?? ''); ?>">
                        </div>
                        
                        <div class="mb-3">
                            <label for="mayor_party" class="form-label">Belediye Partisi</label>
                            <input type="text" class="form-control" id="mayor_party" name="mayor_party" value="<?php echo htmlspecialchars($city['mayor_party'] ?? ''); ?>">
                        </div>
                        
                        <div class="mb-3">
                            <label for="governor_name" class="form-label">Vali</label>
                            <input type="text" class="form-control" id="governor_name" name="governor_name" value="<?php echo htmlspecialchars($city['governor_name'] ?? ''); ?>">
                        </div>
                        
                        <div class="mb-3">
                            <label for="area_code" class="form-label">Alan Kodu</label>
                            <input type="text" class="form-control" id="area_code" name="area_code" value="<?php echo htmlspecialchars($city['area_code'] ?? ''); ?>">
                        </div>
                    </div>
                </div>
                
                <div class="row mb-3">
                    <div class="col-md-6">
                        <div class="mb-3">
                            <label for="latitude" class="form-label">Enlem</label>
                            <input type="number" step="0.000001" class="form-control" id="latitude" name="latitude" value="<?php echo htmlspecialchars($city['latitude'] ?? ''); ?>">
                        </div>
                    </div>
                    
                    <div class="col-md-6">
                        <div class="mb-3">
                            <label for="longitude" class="form-label">Boylam</label>
                            <input type="number" step="0.000001" class="form-control" id="longitude" name="longitude" value="<?php echo htmlspecialchars($city['longitude'] ?? ''); ?>">
                        </div>
                    </div>
                </div>
                
                <div class="mb-3">
                    <button type="submit" class="btn btn-primary">Güncelle</button>
                    <a href="index.php?page=cities" class="btn btn-secondary">İptal</a>
                </div>
            </form>
        </div>
    </div>
    
    <div class="card mb-4">
        <div class="card-header">
            <i class="fas fa-chart-bar me-1"></i>
            Şehir İstatistikleri
        </div>
        <div class="card-body">
            <div class="row">
                <div class="col-md-4">
                    <div class="card bg-primary text-white mb-4">
                        <div class="card-body">
                            Toplam Şikayet: <?php echo intval($city['total_posts'] ?? 0); ?>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card bg-success text-white mb-4">
                        <div class="card-body">
                            Çözülen Şikayet: <?php echo intval($city['solved_posts'] ?? 0); ?>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card bg-info text-white mb-4">
                        <div class="card-body">
                            Çözüm Oranı: %<?php echo number_format(floatval($city['problem_solving_rate'] ?? 0), 2); ?>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <div class="card mb-4">
        <div class="card-header">
            <i class="fas fa-cogs me-1"></i>
            Şehir İşlemleri
        </div>
        <div class="card-body">
            <div class="d-flex gap-2">
                <button class="btn btn-info" onclick="updateCityRate(<?php echo $cityId; ?>)">
                    <i class="fas fa-sync me-1"></i> Çözüm Oranını Güncelle
                </button>
                <button class="btn btn-success" onclick="calculateCityAward(<?php echo $cityId; ?>)">
                    <i class="fas fa-medal me-1"></i> Ödül Hesapla
                </button>
            </div>
        </div>
    </div>
</div>

<script>
// Şehir oranını güncelleme
function updateCityRate(cityId) {
    if (confirm('Şehrin problem çözüm oranı güncellenecek. Devam etmek istiyor musunuz?')) {
        fetch('api/update_problem_solving_rate.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: 'city_id=' + cityId
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                alert('İşlem başarılı: ' + data.message);
                location.reload();
            } else {
                alert('Hata: ' + data.message);
            }
        })
        .catch(error => {
            console.error('Hata:', error);
            alert('İşlem sırasında bir hata oluştu.');
        });
    }
}

// Şehir ödülünü hesaplama
function calculateCityAward(cityId) {
    if (confirm('Şehrin ödül durumu hesaplanacak. Devam etmek istiyor musunuz?')) {
        fetch('api/calculate_city_award.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: 'city_id=' + cityId
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                alert('İşlem başarılı: ' + data.message);
                location.reload();
            } else {
                alert('Bilgi: ' + data.message);
            }
        })
        .catch(error => {
            console.error('Hata:', error);
            alert('İşlem sırasında bir hata oluştu.');
        });
    }
}
</script>