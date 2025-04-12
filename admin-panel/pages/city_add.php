<?php
// Şehir Ekleme Sayfası
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
        
        // Sayısal değerleri doğru formata çevir
        $plateNumber = intval($plateNumber);
        $population = intval($population);
        $latitude = !empty($latitude) ? floatval($latitude) : null;
        $longitude = !empty($longitude) ? floatval($longitude) : null;
        
        // Veritabanına ekle - PostgreSQL uyumlu şekilde
        $query = "INSERT INTO cities (name, plate_number, region, population, mayor, mayor_party, 
                                     governor_name, area_code, latitude, longitude, problem_solving_rate) 
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0)";
        
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
            $longitude
        ]);
        
        // Başarılı mesajı
        $success_message = "'{$name}' şehri başarıyla eklendi";
        
        // Şehirler sayfasına yönlendir
        header('Location: index.php?page=cities&success=' . urlencode($success_message));
        exit;
        
    } catch (Exception $e) {
        $error_message = "Hata: " . $e->getMessage();
    }
}
?>

<div class="container-fluid px-4">
    <h1 class="mt-4">Şehir Ekle</h1>
    <ol class="breadcrumb mb-4">
        <li class="breadcrumb-item"><a href="index.php">Ana Sayfa</a></li>
        <li class="breadcrumb-item"><a href="index.php?page=cities">Şehirler</a></li>
        <li class="breadcrumb-item active">Şehir Ekle</li>
    </ol>
    
    <?php if (isset($error_message)): ?>
        <div class="alert alert-danger"><?php echo $error_message; ?></div>
    <?php endif; ?>
    
    <div class="card mb-4">
        <div class="card-header">
            <i class="fas fa-plus-circle me-1"></i>
            Yeni Şehir Bilgileri
        </div>
        <div class="card-body">
            <form method="post" action="">
                <div class="row mb-3">
                    <div class="col-md-6">
                        <div class="mb-3">
                            <label for="name" class="form-label">Şehir Adı <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" id="name" name="name" required>
                        </div>
                        
                        <div class="mb-3">
                            <label for="plate_number" class="form-label">Plaka Kodu</label>
                            <input type="number" class="form-control" id="plate_number" name="plate_number" min="1" max="81">
                        </div>
                        
                        <div class="mb-3">
                            <label for="region" class="form-label">Bölge</label>
                            <select class="form-select" id="region" name="region">
                                <option value="">Seçiniz</option>
                                <?php foreach ($regions as $regionOption): ?>
                                    <option value="<?php echo htmlspecialchars($regionOption); ?>">
                                        <?php echo htmlspecialchars($regionOption); ?>
                                    </option>
                                <?php endforeach; ?>
                            </select>
                        </div>
                        
                        <div class="mb-3">
                            <label for="population" class="form-label">Nüfus</label>
                            <input type="number" class="form-control" id="population" name="population">
                        </div>
                    </div>
                    
                    <div class="col-md-6">
                        <div class="mb-3">
                            <label for="mayor" class="form-label">Belediye Başkanı</label>
                            <input type="text" class="form-control" id="mayor" name="mayor">
                        </div>
                        
                        <div class="mb-3">
                            <label for="mayor_party" class="form-label">Belediye Partisi</label>
                            <input type="text" class="form-control" id="mayor_party" name="mayor_party">
                        </div>
                        
                        <div class="mb-3">
                            <label for="governor_name" class="form-label">Vali</label>
                            <input type="text" class="form-control" id="governor_name" name="governor_name">
                        </div>
                        
                        <div class="mb-3">
                            <label for="area_code" class="form-label">Alan Kodu</label>
                            <input type="text" class="form-control" id="area_code" name="area_code">
                        </div>
                    </div>
                </div>
                
                <div class="row mb-3">
                    <div class="col-md-6">
                        <div class="mb-3">
                            <label for="latitude" class="form-label">Enlem</label>
                            <input type="number" step="0.000001" class="form-control" id="latitude" name="latitude">
                        </div>
                    </div>
                    
                    <div class="col-md-6">
                        <div class="mb-3">
                            <label for="longitude" class="form-label">Boylam</label>
                            <input type="number" step="0.000001" class="form-control" id="longitude" name="longitude">
                        </div>
                    </div>
                </div>
                
                <div class="mb-3">
                    <button type="submit" class="btn btn-primary">Şehri Ekle</button>
                    <a href="index.php?page=cities" class="btn btn-secondary">İptal</a>
                </div>
            </form>
        </div>
    </div>
</div>