<?php
// İlçe Yönetimi Sayfası

// İşlem yönetimi
$operation = isset($_GET['op']) ? $_GET['op'] : '';
$message = '';
$error = '';

// Mock şehir verileri
$mockCities = [
    ['id' => 1, 'name' => 'İstanbul', 'region' => 'Marmara'],
    ['id' => 6, 'name' => 'Ankara', 'region' => 'İç Anadolu'],
    ['id' => 35, 'name' => 'İzmir', 'region' => 'Ege'],
    ['id' => 16, 'name' => 'Bursa', 'region' => 'Marmara'],
    ['id' => 7, 'name' => 'Antalya', 'region' => 'Akdeniz']
];

// Mock ilçe verileri (gerçek sistemde veritabanından gelir)
$mockDistricts = [
    ['id' => 1, 'name' => 'Kadıköy', 'city_id' => 1, 'population' => 458638],
    ['id' => 2, 'name' => 'Beşiktaş', 'city_id' => 1, 'population' => 182649],
    ['id' => 3, 'name' => 'Üsküdar', 'city_id' => 1, 'population' => 529550],
    ['id' => 4, 'name' => 'Çankaya', 'city_id' => 6, 'population' => 944609],
    ['id' => 5, 'name' => 'Keçiören', 'city_id' => 6, 'population' => 901067],
    ['id' => 6, 'name' => 'Konak', 'city_id' => 35, 'population' => 370360],
    ['id' => 7, 'name' => 'Karşıyaka', 'city_id' => 35, 'population' => 344140],
    ['id' => 8, 'name' => 'Nilüfer', 'city_id' => 16, 'population' => 465956],
    ['id' => 9, 'name' => 'Osmangazi', 'city_id' => 16, 'population' => 879999],
    ['id' => 10, 'name' => 'Muratpaşa', 'city_id' => 7, 'population' => 515531]
];

// İlçe ekleme işlemi
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['add_district'])) {
    $name = $_POST['name'];
    $city_id = $_POST['city_id'];
    $population = $_POST['population'];
    
    if (!empty($name) && !empty($city_id) && !empty($population)) {
        // Mock işlem - gerçek sistemde veritabanı işlemi yapılır
        $message = "'$name' ilçesi başarıyla eklendi.";
    } else {
        $error = "İlçe eklenirken bir hata oluştu. Lütfen tüm alanları doldurun.";
    }
}

// İlçe düzenleme işlemi
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['update_district'])) {
    $id = $_POST['district_id'];
    $name = $_POST['name'];
    $city_id = $_POST['city_id'];
    $population = $_POST['population'];
    
    if (!empty($name) && !empty($city_id) && !empty($population)) {
        // Mock işlem - gerçek sistemde veritabanı işlemi yapılır
        $message = "'$name' ilçesi başarıyla güncellendi.";
    } else {
        $error = "İlçe güncellenirken bir hata oluştu. Lütfen tüm alanları doldurun.";
    }
}

// İlçe silme işlemi
if ($operation === 'delete' && isset($_GET['id'])) {
    $districtId = $_GET['id'];
    
    // Mock işlem - gerçek sistemde veritabanı işlemi yapılır
    $message = "İlçe başarıyla silindi.";
}

// İlçe düzenleme formu
if ($operation === 'edit' && isset($_GET['id'])) {
    $districtId = $_GET['id'];
    $district = null;
    
    // İlçeyi bul
    foreach ($mockDistricts as $mockDistrict) {
        if ($mockDistrict['id'] == $districtId) {
            $district = $mockDistrict;
            break;
        }
    }
    
    if ($district) {
        ?>
        <div class="container mt-4">
            <div class="row">
                <div class="col-md-8 offset-md-2">
                    <div class="card">
                        <div class="card-header bg-primary text-white">
                            <h5 class="mb-0">İlçe Düzenle</h5>
                        </div>
                        <div class="card-body">
                            <form method="post" action="?page=districts">
                                <input type="hidden" name="district_id" value="<?php echo $district['id']; ?>">
                                
                                <div class="mb-3">
                                    <label for="name" class="form-label">İlçe Adı</label>
                                    <input type="text" class="form-control" id="name" name="name" value="<?php echo $district['name']; ?>" required>
                                </div>
                                
                                <div class="mb-3">
                                    <label for="city_id" class="form-label">Bağlı Olduğu Şehir</label>
                                    <select class="form-select" id="city_id" name="city_id" required>
                                        <option value="">Şehir Seçin</option>
                                        <?php foreach ($mockCities as $city): ?>
                                            <option value="<?php echo $city['id']; ?>" <?php echo ($district['city_id'] == $city['id']) ? 'selected' : ''; ?>>
                                                <?php echo $city['name']; ?> (<?php echo $city['region']; ?>)
                                            </option>
                                        <?php endforeach; ?>
                                    </select>
                                </div>
                                
                                <div class="mb-3">
                                    <label for="population" class="form-label">Nüfus</label>
                                    <input type="number" class="form-control" id="population" name="population" value="<?php echo $district['population']; ?>" required>
                                </div>
                                
                                <div class="d-grid gap-2 d-md-flex justify-content-md-end">
                                    <a href="?page=districts" class="btn btn-secondary me-md-2">İptal</a>
                                    <button type="submit" name="update_district" class="btn btn-primary">Güncelle</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <?php
    } else {
        echo '<div class="alert alert-danger">İlçe bulunamadı.</div>';
    }
} else {
    // İlçeler listesi
    ?>
    <div class="container-fluid mt-4">
        <?php if (!empty($message)): ?>
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <?php echo $message; ?>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        <?php endif; ?>
        
        <?php if (!empty($error)): ?>
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <?php echo $error; ?>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        <?php endif; ?>
        
        <div class="card shadow mb-4">
            <div class="card-header py-3 d-flex justify-content-between align-items-center">
                <h6 class="m-0 font-weight-bold text-primary">İlçeler</h6>
                <button type="button" class="btn btn-primary btn-sm" data-bs-toggle="modal" data-bs-target="#addDistrictModal">
                    <i class="bi bi-plus-circle"></i> Yeni İlçe Ekle
                </button>
            </div>
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-bordered" id="dataTable" width="100%" cellspacing="0">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>İlçe Adı</th>
                                <th>Bağlı Olduğu Şehir</th>
                                <th>Bölge</th>
                                <th>Nüfus</th>
                                <th>İşlemler</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($mockDistricts as $district): ?>
                                <?php
                                // İlçenin ait olduğu şehri bul
                                $city = null;
                                foreach ($mockCities as $c) {
                                    if ($c['id'] == $district['city_id']) {
                                        $city = $c;
                                        break;
                                    }
                                }
                                ?>
                                <tr>
                                    <td><?php echo $district['id']; ?></td>
                                    <td><?php echo $district['name']; ?></td>
                                    <td><?php echo $city ? $city['name'] : 'Bilinmiyor'; ?></td>
                                    <td><?php echo $city ? $city['region'] : 'Bilinmiyor'; ?></td>
                                    <td><?php echo number_format($district['population'], 0, ',', '.'); ?></td>
                                    <td>
                                        <a href="?page=districts&op=edit&id=<?php echo $district['id']; ?>" class="btn btn-sm btn-primary me-1">
                                            <i class="bi bi-pencil"></i>
                                        </a>
                                        <a href="?page=districts&op=delete&id=<?php echo $district['id']; ?>" class="btn btn-sm btn-danger" 
                                           onclick="return confirm('Bu ilçeyi silmek istediğinizden emin misiniz?');">
                                            <i class="bi bi-trash"></i>
                                        </a>
                                    </td>
                                </tr>
                            <?php endforeach; ?>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
    
    <!-- İlçe Ekleme Modal -->
    <div class="modal fade" id="addDistrictModal" tabindex="-1" aria-labelledby="addDistrictModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="addDistrictModalLabel">Yeni İlçe Ekle</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <form method="post" action="?page=districts">
                    <div class="modal-body">
                        <div class="mb-3">
                            <label for="name" class="form-label">İlçe Adı</label>
                            <input type="text" class="form-control" id="name" name="name" required>
                        </div>
                        
                        <div class="mb-3">
                            <label for="city_id" class="form-label">Bağlı Olduğu Şehir</label>
                            <select class="form-select" id="city_id" name="city_id" required>
                                <option value="">Şehir Seçin</option>
                                <?php foreach ($mockCities as $city): ?>
                                    <option value="<?php echo $city['id']; ?>">
                                        <?php echo $city['name']; ?> (<?php echo $city['region']; ?>)
                                    </option>
                                <?php endforeach; ?>
                            </select>
                        </div>
                        
                        <div class="mb-3">
                            <label for="population" class="form-label">Nüfus</label>
                            <input type="number" class="form-control" id="population" name="population" required>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">İptal</button>
                        <button type="submit" name="add_district" class="btn btn-primary">Ekle</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    <?php
}
?>