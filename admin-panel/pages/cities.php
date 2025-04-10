<?php
// Şehir Yönetimi Sayfası

// İşlem yönetimi
$operation = isset($_GET['op']) ? $_GET['op'] : '';
$message = '';
$error = '';

// Mock şehir verileri (gerçek sistemde veritabanından gelir)
$mockCities = [
    ['id' => 1, 'name' => 'İstanbul', 'region' => 'Marmara', 'population' => 15462452, 'mayor_name' => 'Ekrem İmamoğlu'],
    ['id' => 6, 'name' => 'Ankara', 'region' => 'İç Anadolu', 'population' => 5663322, 'mayor_name' => 'Mansur Yavaş'],
    ['id' => 35, 'name' => 'İzmir', 'region' => 'Ege', 'population' => 4393050, 'mayor_name' => 'Tunç Soyer'],
    ['id' => 16, 'name' => 'Bursa', 'region' => 'Marmara', 'population' => 3101833, 'mayor_name' => 'Alinur Aktaş'],
    ['id' => 7, 'name' => 'Antalya', 'region' => 'Akdeniz', 'population' => 2548308, 'mayor_name' => 'Muhittin Böcek'],
    ['id' => 20, 'name' => 'Denizli', 'region' => 'Ege', 'population' => 1040915, 'mayor_name' => 'Osman Zolan'],
    ['id' => 42, 'name' => 'Konya', 'region' => 'İç Anadolu', 'population' => 2277017, 'mayor_name' => 'Uğur İbrahim Altay'],
    ['id' => 27, 'name' => 'Gaziantep', 'region' => 'Güneydoğu Anadolu', 'population' => 2130432, 'mayor_name' => 'Fatma Şahin'],
    ['id' => 25, 'name' => 'Erzurum', 'region' => 'Doğu Anadolu', 'population' => 756893, 'mayor_name' => 'Mehmet Sekmen'],
    ['id' => 55, 'name' => 'Samsun', 'region' => 'Karadeniz', 'population' => 1368489, 'mayor_name' => 'Mustafa Demir'],
    ['id' => 34, 'name' => 'Adana', 'region' => 'Akdeniz', 'population' => 2258718, 'mayor_name' => 'Zeydan Karalar'],
    ['id' => 44, 'name' => 'Malatya', 'region' => 'Doğu Anadolu', 'population' => 806156, 'mayor_name' => 'Selahattin Gürkan'],
    ['id' => 52, 'name' => 'Ordu', 'region' => 'Karadeniz', 'population' => 771932, 'mayor_name' => 'Mehmet Hilmi Güler'],
    ['id' => 33, 'name' => 'Mersin', 'region' => 'Akdeniz', 'population' => 1868757, 'mayor_name' => 'Vahap Seçer'],
    ['id' => 65, 'name' => 'Van', 'region' => 'Doğu Anadolu', 'population' => 1136757, 'mayor_name' => 'Mehmet Emin Bilmez'],
    ['id' => 38, 'name' => 'Kayseri', 'region' => 'İç Anadolu', 'population' => 1421455, 'mayor_name' => 'Memduh Büyükkılıç'],
    ['id' => 26, 'name' => 'Eskişehir', 'region' => 'İç Anadolu', 'population' => 887475, 'mayor_name' => 'Yılmaz Büyükerşen'],
    ['id' => 10, 'name' => 'Balıkesir', 'region' => 'Marmara', 'population' => 1250610, 'mayor_name' => 'Yücel Yılmaz'],
    ['id' => 23, 'name' => 'Elazığ', 'region' => 'Doğu Anadolu', 'population' => 591098, 'mayor_name' => 'Şahin Şerifoğulları'],
    ['id' => 45, 'name' => 'Manisa', 'region' => 'Ege', 'population' => 1450616, 'mayor_name' => 'Cengiz Ergün']
];

// Şehirlerin ay ödülü bilgileri
$cityAwards = [
    ['city_id' => 35, 'month' => 'Nisan 2024', 'score' => 88.7, 'text' => 'Çevre projeleri ve şeffaf yönetimde gösterdiği başarılardan dolayı'],
    ['city_id' => 6, 'month' => 'Mart 2024', 'score' => 92.3, 'text' => 'Ulaşım hizmetleri ve sokak hayvanları projelerindeki başarısından dolayı'],
    ['city_id' => 1, 'month' => 'Şubat 2024', 'score' => 85.1, 'text' => 'Kültür sanat etkinlikleri ve dijital belediyecilik uygulamalarındaki başarısından dolayı'],
    ['city_id' => 16, 'month' => 'Ocak 2024', 'score' => 83.4, 'text' => 'Yeşil alan projeleri ve katılımcı belediyecilik uygulamalarındaki başarısından dolayı'],
    ['city_id' => 34, 'month' => 'Aralık 2023', 'score' => 80.9, 'text' => 'Sosyal belediyecilik ve altyapı iyileştirme projelerindeki başarısından dolayı']
];

// Şehir ekleme işlemi
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['add_city'])) {
    $name = $_POST['name'];
    $region = $_POST['region'];
    $population = $_POST['population'];
    $mayor_name = $_POST['mayor_name'];
    
    if (!empty($name) && !empty($region) && !empty($population)) {
        $message = "'$name' şehri başarıyla eklendi.";
    } else {
        $error = "Şehir eklenirken bir hata oluştu. Lütfen tüm alanları doldurun.";
    }
}

// Şehir düzenleme işlemi
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['update_city'])) {
    $id = $_POST['city_id'];
    $name = $_POST['name'];
    $region = $_POST['region'];
    $population = $_POST['population'];
    $mayor_name = $_POST['mayor_name'];
    
    if (!empty($name) && !empty($region) && !empty($population)) {
        $message = "'$name' şehri başarıyla güncellendi.";
    } else {
        $error = "Şehir güncellenirken bir hata oluştu. Lütfen tüm alanları doldurun.";
    }
}

// Şehir silme işlemi
if ($operation === 'delete' && isset($_GET['id'])) {
    $cityId = $_GET['id'];
    
    // Mock işlem - gerçek sistemde veritabanı işlemi yapılır
    $message = "Şehir başarıyla silindi.";
}

// Ödül atama işlemi
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['award_city'])) {
    $cityId = $_POST['city_id'];
    $awardText = $_POST['award_text'];
    $awardMonth = $_POST['award_month'];
    $awardScore = $_POST['award_score'];
    
    if (!empty($awardText) && !empty($awardMonth) && !empty($awardScore)) {
        $message = "Ödül başarıyla atandı.";
    } else {
        $error = "Ödül atanırken bir hata oluştu. Lütfen tüm alanları doldurun.";
    }
}

// Şehir düzenleme formu
if ($operation === 'edit' && isset($_GET['id'])) {
    $cityId = $_GET['id'];
    $city = null;
    
    // Şehri bul
    foreach ($mockCities as $mockCity) {
        if ($mockCity['id'] == $cityId) {
            $city = $mockCity;
            break;
        }
    }
    
    if ($city) {
        ?>
        <div class="container mt-4">
            <div class="row">
                <div class="col-md-8 offset-md-2">
                    <div class="card">
                        <div class="card-header bg-primary text-white">
                            <h5 class="mb-0">Şehir Düzenle</h5>
                        </div>
                        <div class="card-body">
                            <form method="post" action="?page=cities">
                                <input type="hidden" name="city_id" value="<?php echo $city['id']; ?>">
                                
                                <div class="mb-3">
                                    <label for="name" class="form-label">Şehir Adı</label>
                                    <input type="text" class="form-control" id="name" name="name" value="<?php echo $city['name']; ?>" required>
                                </div>
                                
                                <div class="mb-3">
                                    <label for="region" class="form-label">Bölge</label>
                                    <select class="form-select" id="region" name="region" required>
                                        <option value="">Bölge Seçin</option>
                                        <option value="Marmara" <?php echo ($city['region'] == 'Marmara') ? 'selected' : ''; ?>>Marmara</option>
                                        <option value="Ege" <?php echo ($city['region'] == 'Ege') ? 'selected' : ''; ?>>Ege</option>
                                        <option value="Akdeniz" <?php echo ($city['region'] == 'Akdeniz') ? 'selected' : ''; ?>>Akdeniz</option>
                                        <option value="İç Anadolu" <?php echo ($city['region'] == 'İç Anadolu') ? 'selected' : ''; ?>>İç Anadolu</option>
                                        <option value="Karadeniz" <?php echo ($city['region'] == 'Karadeniz') ? 'selected' : ''; ?>>Karadeniz</option>
                                        <option value="Doğu Anadolu" <?php echo ($city['region'] == 'Doğu Anadolu') ? 'selected' : ''; ?>>Doğu Anadolu</option>
                                        <option value="Güneydoğu Anadolu" <?php echo ($city['region'] == 'Güneydoğu Anadolu') ? 'selected' : ''; ?>>Güneydoğu Anadolu</option>
                                    </select>
                                </div>
                                
                                <div class="mb-3">
                                    <label for="population" class="form-label">Nüfus</label>
                                    <input type="number" class="form-control" id="population" name="population" value="<?php echo $city['population']; ?>" required>
                                </div>
                                
                                <div class="mb-3">
                                    <label for="mayor_name" class="form-label">Belediye Başkanı</label>
                                    <input type="text" class="form-control" id="mayor_name" name="mayor_name" value="<?php echo $city['mayor_name']; ?>">
                                </div>
                                
                                <div class="d-grid gap-2 d-md-flex justify-content-md-end">
                                    <a href="?page=cities" class="btn btn-secondary me-md-2">İptal</a>
                                    <button type="submit" name="update_city" class="btn btn-primary">Güncelle</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <?php
    } else {
        echo '<div class="alert alert-danger">Şehir bulunamadı.</div>';
    }
} 
// Ödül atama formu
else if ($operation === 'award' && isset($_GET['id'])) {
    $cityId = $_GET['id'];
    $city = null;
    
    // Şehri bul
    foreach ($mockCities as $mockCity) {
        if ($mockCity['id'] == $cityId) {
            $city = $mockCity;
            break;
        }
    }
    
    // Şehre ait mevcut ödül varsa bul
    $existingAward = null;
    foreach ($cityAwards as $award) {
        if ($award['city_id'] == $cityId) {
            $existingAward = $award;
            break;
        }
    }
    
    if ($city) {
        ?>
        <div class="container mt-4">
            <div class="row">
                <div class="col-md-8 offset-md-2">
                    <div class="card">
                        <div class="card-header bg-warning text-dark">
                            <h5 class="mb-0">"Ayın Belediyesi" Ödülü Ata: <?php echo $city['name']; ?></h5>
                        </div>
                        <div class="card-body">
                            <form method="post" action="?page=cities">
                                <input type="hidden" name="city_id" value="<?php echo $city['id']; ?>">
                                
                                <div class="mb-3">
                                    <label for="award_month" class="form-label">Ödül Ayı</label>
                                    <select class="form-select" id="award_month" name="award_month" required>
                                        <option value="">Ay Seçin</option>
                                        <?php
                                        $currentYear = date('Y');
                                        $currentMonth = date('n');
                                        for ($m = 1; $m <= 12; $m++) {
                                            $monthName = date('F', mktime(0, 0, 0, $m, 1, $currentYear));
                                            $value = $monthName . ' ' . $currentYear;
                                            $selected = ($existingAward && $existingAward['month'] == $value) ? 'selected' : '';
                                            echo "<option value=\"$value\" $selected>$monthName $currentYear</option>";
                                        }
                                        ?>
                                    </select>
                                </div>
                                
                                <div class="mb-3">
                                    <label for="award_score" class="form-label">Puan (0-100)</label>
                                    <input type="number" class="form-control" id="award_score" name="award_score" min="0" max="100" step="0.1" 
                                           value="<?php echo $existingAward ? $existingAward['score'] : ''; ?>" required>
                                </div>
                                
                                <div class="mb-3">
                                    <label for="award_text" class="form-label">Ödül Açıklaması</label>
                                    <textarea class="form-control" id="award_text" name="award_text" rows="3" required><?php echo $existingAward ? $existingAward['text'] : ''; ?></textarea>
                                    <div class="form-text">Örnek: "Çevre projeleri ve şeffaf yönetimde gösterdiği başarılardan dolayı"</div>
                                </div>
                                
                                <div class="d-grid gap-2 d-md-flex justify-content-md-end">
                                    <a href="?page=cities" class="btn btn-secondary me-md-2">İptal</a>
                                    <button type="submit" name="award_city" class="btn btn-warning">Ödül Ata</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <?php
    } else {
        echo '<div class="alert alert-danger">Şehir bulunamadı.</div>';
    }
} 
else {
    // Şehirler listesi
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
                <h6 class="m-0 font-weight-bold text-primary">Şehirler</h6>
                <button type="button" class="btn btn-primary btn-sm" data-bs-toggle="modal" data-bs-target="#addCityModal">
                    <i class="bi bi-plus-circle"></i> Yeni Şehir Ekle
                </button>
            </div>
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-bordered" id="dataTable" width="100%" cellspacing="0">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Şehir Adı</th>
                                <th>Bölge</th>
                                <th>Nüfus</th>
                                <th>Belediye Başkanı</th>
                                <th>Ödül Durumu</th>
                                <th>İşlemler</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($mockCities as $city): ?>
                                <?php
                                // Şehre ait ödül var mı kontrol et
                                $hasAward = false;
                                $award = null;
                                foreach ($cityAwards as $cityAward) {
                                    if ($cityAward['city_id'] == $city['id']) {
                                        $hasAward = true;
                                        $award = $cityAward;
                                        break;
                                    }
                                }
                                ?>
                                <tr>
                                    <td><?php echo $city['id']; ?></td>
                                    <td><?php echo $city['name']; ?></td>
                                    <td><?php echo $city['region']; ?></td>
                                    <td><?php echo number_format($city['population'], 0, ',', '.'); ?></td>
                                    <td><?php echo $city['mayor_name']; ?></td>
                                    <td>
                                        <?php if ($hasAward): ?>
                                            <span class="badge bg-warning text-dark" data-bs-toggle="tooltip" data-bs-placement="top" 
                                                  title="<?php echo $award['text']; ?>">
                                                Ayın Belediyesi (<?php echo $award['month']; ?>)
                                            </span>
                                        <?php else: ?>
                                            <span class="badge bg-secondary">Ödül Yok</span>
                                        <?php endif; ?>
                                    </td>
                                    <td>
                                        <a href="?page=cities&op=edit&id=<?php echo $city['id']; ?>" class="btn btn-sm btn-primary me-1">
                                            <i class="bi bi-pencil"></i>
                                        </a>
                                        <a href="?page=cities&op=award&id=<?php echo $city['id']; ?>" class="btn btn-sm btn-warning me-1" 
                                           data-bs-toggle="tooltip" data-bs-placement="top" title="Ayın Belediyesi Ödülü At">
                                            <i class="bi bi-trophy"></i>
                                        </a>
                                        <a href="?page=cities&op=delete&id=<?php echo $city['id']; ?>" class="btn btn-sm btn-danger" 
                                           onclick="return confirm('Bu şehri silmek istediğinizden emin misiniz?');">
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
    
    <!-- Şehir Ekleme Modal -->
    <div class="modal fade" id="addCityModal" tabindex="-1" aria-labelledby="addCityModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="addCityModalLabel">Yeni Şehir Ekle</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <form method="post" action="?page=cities">
                    <div class="modal-body">
                        <div class="mb-3">
                            <label for="name" class="form-label">Şehir Adı</label>
                            <input type="text" class="form-control" id="name" name="name" required>
                        </div>
                        
                        <div class="mb-3">
                            <label for="region" class="form-label">Bölge</label>
                            <select class="form-select" id="region" name="region" required>
                                <option value="">Bölge Seçin</option>
                                <option value="Marmara">Marmara</option>
                                <option value="Ege">Ege</option>
                                <option value="Akdeniz">Akdeniz</option>
                                <option value="İç Anadolu">İç Anadolu</option>
                                <option value="Karadeniz">Karadeniz</option>
                                <option value="Doğu Anadolu">Doğu Anadolu</option>
                                <option value="Güneydoğu Anadolu">Güneydoğu Anadolu</option>
                            </select>
                        </div>
                        
                        <div class="mb-3">
                            <label for="population" class="form-label">Nüfus</label>
                            <input type="number" class="form-control" id="population" name="population" required>
                        </div>
                        
                        <div class="mb-3">
                            <label for="mayor_name" class="form-label">Belediye Başkanı</label>
                            <input type="text" class="form-control" id="mayor_name" name="mayor_name">
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">İptal</button>
                        <button type="submit" name="add_city" class="btn btn-primary">Ekle</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    <?php
}
?>