<?php
// İlçe yönetim sayfası
// ADMIN_PANEL sabiti kontrol edilmiyor
define('ADMIN_PANEL', true);

// Veritabanı bağlantısını dahil et
require_once __DIR__ . '/../db_connection.php';

// Get city information
$cityId = isset($_GET['city_id']) ? intval($_GET['city_id']) : 0;
$cityName = '';

if ($cityId > 0) {
    $query = "SELECT name FROM cities WHERE id = ?";
    $stmt = $conn->prepare($query);
    $stmt->bind_param('i', $cityId);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($row = $result->fetch_assoc()) {
        $cityName = $row['name'];
    } else {
        // Şehir bulunamadı
        echo '<div class="alert alert-danger">Şehir bulunamadı. <a href="?page=cities">Şehirler sayfasına dön</a></div>';
        exit;
    }
}

// İlçe ekleme
if (isset($_POST['add_district'])) {
    $name = $_POST['name'];
    $districtCityId = $_POST['city_id'];
    
    $query = "INSERT INTO districts (name, city_id) VALUES (?, ?)";
    $stmt = $conn->prepare($query);
    $stmt->bind_param('si', $name, $districtCityId);
    
    if ($stmt->execute()) {
        echo '<div class="alert alert-success">İlçe başarıyla eklendi.</div>';
    } else {
        echo '<div class="alert alert-danger">İlçe eklenirken bir hata oluştu: ' . $conn->error . '</div>';
    }
}

// İlçe silme
if (isset($_GET['op']) && $_GET['op'] == 'delete' && isset($_GET['id'])) {
    $districtId = intval($_GET['id']);
    
    $query = "DELETE FROM districts WHERE id = ?";
    $stmt = $conn->prepare($query);
    $stmt->bind_param('i', $districtId);
    
    if ($stmt->execute()) {
        echo '<div class="alert alert-success">İlçe başarıyla silindi.</div>';
    } else {
        echo '<div class="alert alert-danger">İlçe silinirken bir hata oluştu: ' . $conn->error . '</div>';
    }
}

// İlçe düzenleme
$editDistrict = null;
if (isset($_GET['op']) && $_GET['op'] == 'edit' && isset($_GET['id'])) {
    $districtId = intval($_GET['id']);
    
    $query = "SELECT * FROM districts WHERE id = ?";
    $stmt = $conn->prepare($query);
    $stmt->bind_param('i', $districtId);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($row = $result->fetch_assoc()) {
        $editDistrict = $row;
    }
}

// İlçe güncelleme
if (isset($_POST['update_district'])) {
    $districtId = $_POST['district_id'];
    $name = $_POST['name'];
    $districtCityId = $_POST['city_id'];
    $population = isset($_POST['population']) && $_POST['population'] !== "" ? intval($_POST['population']) : null;
    $description = isset($_POST['description']) && $_POST['description'] !== "" ? $_POST['description'] : null;
    $mayorName = isset($_POST['mayor_name']) && $_POST['mayor_name'] !== "" ? $_POST['mayor_name'] : null;
    $postalCode = isset($_POST['postal_code']) && $_POST['postal_code'] !== "" ? $_POST['postal_code'] : null;
    $latitude = isset($_POST['latitude']) && $_POST['latitude'] !== "" ? $_POST['latitude'] : null;
    $longitude = isset($_POST['longitude']) && $_POST['longitude'] !== "" ? $_POST['longitude'] : null;
    
    // Önce tabloda gerekli alanların olup olmadığını kontrol et
    $columnsQuery = "SHOW COLUMNS FROM districts";
    $columnsResult = $conn->query($columnsQuery);
    $columns = [];
    
    while ($column = $columnsResult->fetch_assoc()) {
        $columns[] = $column['Field'];
    }
    
    // Gerekli alanlar tabloda mevcut değilse ekleyelim
    if (!in_array('population', $columns)) {
        $conn->query("ALTER TABLE districts ADD COLUMN population INT NULL");
    }
    if (!in_array('description', $columns)) {
        $conn->query("ALTER TABLE districts ADD COLUMN description TEXT NULL");
    }
    if (!in_array('mayor_name', $columns)) {
        $conn->query("ALTER TABLE districts ADD COLUMN mayor_name VARCHAR(255) NULL");
    }
    if (!in_array('postal_code', $columns)) {
        $conn->query("ALTER TABLE districts ADD COLUMN postal_code VARCHAR(50) NULL");
    }
    if (!in_array('latitude', $columns)) {
        $conn->query("ALTER TABLE districts ADD COLUMN latitude DECIMAL(10,8) NULL");
    }
    if (!in_array('longitude', $columns)) {
        $conn->query("ALTER TABLE districts ADD COLUMN longitude DECIMAL(11,8) NULL");
    }
    
    // Tüm alanlarla güncelleme yap
    $query = "UPDATE districts SET 
                name = ?, 
                city_id = ?, 
                population = ?, 
                description = ?, 
                mayor_name = ?, 
                postal_code = ?, 
                latitude = ?, 
                longitude = ? 
              WHERE id = ?";
    
    $stmt = $conn->prepare($query);
    $stmt->bind_param('siisssssdi', 
        $name, 
        $districtCityId, 
        $population, 
        $description, 
        $mayorName, 
        $postalCode,
        $latitude,
        $longitude,
        $districtId
    );
    
    if ($stmt->execute()) {
        echo '<div class="alert alert-success">İlçe başarıyla güncellendi.</div>';
        // Güncelleme sonrası mevcut şehir listesine dön
        echo '<script>window.location.href = "?page=districts&city_id=' . $districtCityId . '";</script>';
    } else {
        echo '<div class="alert alert-danger">İlçe güncellenirken bir hata oluştu: ' . $conn->error . '</div>';
    }
}

// İlçeleri getir
$districts = [];
$query = "SELECT d.*, c.name as city_name FROM districts d 
          LEFT JOIN cities c ON d.city_id = c.id";

if ($cityId > 0) {
    $query .= " WHERE d.city_id = ?";
    $stmt = $conn->prepare($query);
    $stmt->bind_param('i', $cityId);
} else {
    $stmt = $conn->prepare($query);
}

$stmt->execute();
$result = $stmt->get_result();

while ($row = $result->fetch_assoc()) {
    $districts[] = $row;
}

// Şehirleri getir (dropdown için)
$cities = [];
$query = "SELECT * FROM cities ORDER BY name";
$result = $conn->query($query);

while ($row = $result->fetch_assoc()) {
    $cities[] = $row;
}
?>

<div class="d-sm-flex align-items-center justify-content-between mb-4">
    <h1 class="h3 mb-0 text-gray-800">
        <?php if ($cityId > 0): ?>
            <?php echo $cityName; ?> İlçeleri
        <?php else: ?>
            Tüm İlçeler
        <?php endif; ?>
    </h1>
    <button class="d-none d-sm-inline-block btn btn-sm btn-primary shadow-sm" 
            data-bs-toggle="modal" data-bs-target="#addDistrictModal">
        <i class="fas fa-plus fa-sm text-white-50"></i> Yeni İlçe Ekle
    </button>
</div>

<?php if ($cityId > 0): ?>
<div class="mb-4">
    <a href="?page=cities" class="btn btn-secondary">
        <i class="fas fa-arrow-left"></i> Şehirler Listesine Dön
    </a>
</div>
<?php endif; ?>

<div class="card shadow mb-4">
    <div class="card-header py-3">
        <h6 class="m-0 font-weight-bold text-primary">İlçe Listesi</h6>
    </div>
    <div class="card-body">
        <div class="table-responsive">
            <table class="table table-bordered" id="dataTable" width="100%" cellspacing="0">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>İlçe Adı</th>
                        <?php if ($cityId == 0): ?>
                        <th>Şehir</th>
                        <?php endif; ?>
                        <th>İşlemler</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($districts as $district): ?>
                        <tr>
                            <td><?php echo $district['id']; ?></td>
                            <td><?php echo $district['name']; ?></td>
                            <?php if ($cityId == 0): ?>
                            <td><?php echo $district['city_name']; ?></td>
                            <?php endif; ?>
                            <td>
                                <a href="?page=districts&op=edit&id=<?php echo $district['id']; ?><?php echo $cityId > 0 ? '&city_id=' . $cityId : ''; ?>" class="btn btn-primary btn-sm">
                                    <i class="fas fa-edit"></i> Düzenle
                                </a>
                                <a href="?page=districts&op=delete&id=<?php echo $district['id']; ?><?php echo $cityId > 0 ? '&city_id=' . $cityId : ''; ?>" 
                                   class="btn btn-danger btn-sm"
                                   onclick="return confirm('Bu ilçeyi silmek istediğinize emin misiniz?');">
                                    <i class="fas fa-trash"></i> Sil
                                </a>
                            </td>
                        </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- Yeni İlçe Ekleme Modal -->
<div class="modal fade" id="addDistrictModal" tabindex="-1" aria-labelledby="addDistrictModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="addDistrictModalLabel">Yeni İlçe Ekle</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form method="POST">
                <div class="modal-body">
                    <div class="row">
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="name" class="form-label">İlçe Adı</label>
                                <input type="text" class="form-control" id="name" name="name" required>
                            </div>
                            <div class="mb-3">
                                <label for="city_id" class="form-label">Şehir</label>
                                <select class="form-control" id="city_id" name="city_id" required>
                                    <option value="">Şehir Seçin</option>
                                    <?php foreach ($cities as $city): ?>
                                        <option value="<?php echo $city['id']; ?>" <?php echo ($cityId == $city['id']) ? 'selected' : ''; ?>>
                                            <?php echo $city['name']; ?>
                                        </option>
                                    <?php endforeach; ?>
                                </select>
                            </div>
                            <div class="mb-3">
                                <label for="population" class="form-label">Nüfus</label>
                                <input type="number" class="form-control" id="population" name="population">
                            </div>
                            <div class="mb-3">
                                <label for="mayor_name" class="form-label">İlçe Belediye Başkanı</label>
                                <input type="text" class="form-control" id="mayor_name" name="mayor_name">
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="description" class="form-label">Açıklama</label>
                                <textarea class="form-control" id="description" name="description" rows="3"></textarea>
                            </div>
                            <div class="mb-3">
                                <label for="postal_code" class="form-label">Posta Kodu</label>
                                <input type="text" class="form-control" id="postal_code" name="postal_code">
                            </div>
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label for="latitude" class="form-label">Enlem</label>
                                        <input type="text" class="form-control" id="latitude" name="latitude">
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label for="longitude" class="form-label">Boylam</label>
                                        <input type="text" class="form-control" id="longitude" name="longitude">
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">İptal</button>
                    <button type="submit" name="add_district" class="btn btn-primary">Kaydet</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- İlçe Düzenleme Formu -->
<?php if ($editDistrict): ?>
<div class="card shadow mb-4">
    <div class="card-header py-3">
        <h6 class="m-0 font-weight-bold text-primary"><?php echo $editDistrict['name']; ?> İlçesini Düzenle</h6>
    </div>
    <div class="card-body">
        <form method="POST">
            <input type="hidden" name="district_id" value="<?php echo $editDistrict['id']; ?>">
            
            <div class="row">
                <div class="col-md-6">
                    <div class="mb-3">
                        <label for="edit_name" class="form-label">İlçe Adı</label>
                        <input type="text" class="form-control" id="edit_name" name="name" value="<?php echo $editDistrict['name']; ?>" required>
                    </div>
                    <div class="mb-3">
                        <label for="edit_city_id" class="form-label">Şehir</label>
                        <select class="form-control" id="edit_city_id" name="city_id" required>
                            <?php foreach ($cities as $city): ?>
                                <option value="<?php echo $city['id']; ?>" <?php echo ($editDistrict['city_id'] == $city['id']) ? 'selected' : ''; ?>>
                                    <?php echo $city['name']; ?>
                                </option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                    
                    <div class="mb-3">
                        <label for="edit_population" class="form-label">Nüfus</label>
                        <input type="number" class="form-control" id="edit_population" name="population" value="<?php echo isset($editDistrict['population']) ? $editDistrict['population'] : ''; ?>">
                    </div>
                </div>
                
                <div class="col-md-6">
                    <div class="mb-3">
                        <label for="edit_description" class="form-label">Açıklama</label>
                        <textarea class="form-control" id="edit_description" name="description" rows="3"><?php echo isset($editDistrict['description']) ? $editDistrict['description'] : ''; ?></textarea>
                    </div>
                    
                    <div class="mb-3">
                        <label for="edit_mayor_name" class="form-label">İlçe Belediye Başkanı</label>
                        <input type="text" class="form-control" id="edit_mayor_name" name="mayor_name" value="<?php echo isset($editDistrict['mayor_name']) ? $editDistrict['mayor_name'] : ''; ?>">
                    </div>
                    
                    <div class="mb-3">
                        <label for="edit_postal_code" class="form-label">Posta Kodu</label>
                        <input type="text" class="form-control" id="edit_postal_code" name="postal_code" value="<?php echo isset($editDistrict['postal_code']) ? $editDistrict['postal_code'] : ''; ?>">
                    </div>
                </div>
            </div>
            
            <div class="row">
                <div class="col-md-6">
                    <div class="mb-3">
                        <label for="edit_latitude" class="form-label">Enlem</label>
                        <input type="text" class="form-control" id="edit_latitude" name="latitude" value="<?php echo isset($editDistrict['latitude']) ? $editDistrict['latitude'] : ''; ?>">
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="mb-3">
                        <label for="edit_longitude" class="form-label">Boylam</label>
                        <input type="text" class="form-control" id="edit_longitude" name="longitude" value="<?php echo isset($editDistrict['longitude']) ? $editDistrict['longitude'] : ''; ?>">
                    </div>
                </div>
            </div>
            
            <div class="mt-4">
                <a href="?page=districts<?php echo $cityId > 0 ? '&city_id=' . $cityId : ''; ?>" class="btn btn-secondary">İptal</a>
                <button type="submit" name="update_district" class="btn btn-primary">Güncelle</button>
            </div>
        </form>
    </div>
</div>

<!-- İlçe İstatistikleri -->
<div class="card shadow mb-4">
    <div class="card-header py-3">
        <h6 class="m-0 font-weight-bold text-primary"><?php echo $editDistrict['name']; ?> İlçesi İstatistikleri</h6>
    </div>
    <div class="card-body">
        <div class="row">
            <div class="col-xl-3 col-md-6 mb-4">
                <div class="card border-left-primary shadow h-100 py-2">
                    <div class="card-body">
                        <div class="row no-gutters align-items-center">
                            <div class="col mr-2">
                                <div class="text-xs font-weight-bold text-primary text-uppercase mb-1">
                                    Toplam Şikayet</div>
                                <div class="h5 mb-0 font-weight-bold text-gray-800">
                                    <?php 
                                    // İlçedeki şikayet sayısını getir
                                    $queryPosts = "SELECT COUNT(*) as total FROM posts WHERE district_id = ?";
                                    $stmtPosts = $conn->prepare($queryPosts);
                                    $stmtPosts->bind_param('i', $editDistrict['id']);
                                    $stmtPosts->execute();
                                    $resultPosts = $stmtPosts->get_result();
                                    $rowPosts = $resultPosts->fetch_assoc();
                                    echo $rowPosts['total'] ?? 0;
                                    ?>
                                </div>
                            </div>
                            <div class="col-auto">
                                <i class="fas fa-comments fa-2x text-gray-300"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="col-xl-3 col-md-6 mb-4">
                <div class="card border-left-success shadow h-100 py-2">
                    <div class="card-body">
                        <div class="row no-gutters align-items-center">
                            <div class="col mr-2">
                                <div class="text-xs font-weight-bold text-success text-uppercase mb-1">
                                    Çözülen Şikayetler</div>
                                <div class="h5 mb-0 font-weight-bold text-gray-800">
                                    <?php 
                                    // İlçedeki çözülen şikayet sayısını getir
                                    $querySolved = "SELECT COUNT(*) as total FROM posts WHERE district_id = ? AND status = 'solved'";
                                    $stmtSolved = $conn->prepare($querySolved);
                                    $stmtSolved->bind_param('i', $editDistrict['id']);
                                    $stmtSolved->execute();
                                    $resultSolved = $stmtSolved->get_result();
                                    $rowSolved = $resultSolved->fetch_assoc();
                                    echo $rowSolved['total'] ?? 0;
                                    ?>
                                </div>
                            </div>
                            <div class="col-auto">
                                <i class="fas fa-check-circle fa-2x text-gray-300"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="col-xl-3 col-md-6 mb-4">
                <div class="card border-left-info shadow h-100 py-2">
                    <div class="card-body">
                        <div class="row no-gutters align-items-center">
                            <div class="col mr-2">
                                <div class="text-xs font-weight-bold text-info text-uppercase mb-1">
                                    Çözüm Oranı</div>
                                <div class="row no-gutters align-items-center">
                                    <div class="col-auto">
                                        <div class="h5 mb-0 mr-3 font-weight-bold text-gray-800">
                                            <?php 
                                            // Çözüm oranını hesapla
                                            $totalPosts = $rowPosts['total'] ?? 0;
                                            $solvedPosts = $rowSolved['total'] ?? 0;
                                            $solutionRate = $totalPosts > 0 ? round(($solvedPosts / $totalPosts) * 100) : 0;
                                            echo $solutionRate . '%';
                                            ?>
                                        </div>
                                    </div>
                                    <div class="col">
                                        <div class="progress progress-sm mr-2">
                                            <div class="progress-bar bg-info" role="progressbar" style="width: <?php echo $solutionRate; ?>%"
                                                aria-valuenow="<?php echo $solutionRate; ?>" aria-valuemin="0" aria-valuemax="100"></div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-auto">
                                <i class="fas fa-clipboard-list fa-2x text-gray-300"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="col-xl-3 col-md-6 mb-4">
                <div class="card border-left-warning shadow h-100 py-2">
                    <div class="card-body">
                        <div class="row no-gutters align-items-center">
                            <div class="col mr-2">
                                <div class="text-xs font-weight-bold text-warning text-uppercase mb-1">
                                    Aktif Kullanıcılar</div>
                                <div class="h5 mb-0 font-weight-bold text-gray-800">
                                    <?php 
                                    // İlçedeki aktif kullanıcı sayısını getir (şehire bağlı sadeleştirilmiş bir hesaplama)
                                    $queryUsers = "SELECT COUNT(DISTINCT u.id) as total FROM users u 
                                                  JOIN posts p ON u.id = p.user_id 
                                                  WHERE p.district_id = ?";
                                    $stmtUsers = $conn->prepare($queryUsers);
                                    $stmtUsers->bind_param('i', $editDistrict['id']);
                                    $stmtUsers->execute();
                                    $resultUsers = $stmtUsers->get_result();
                                    $rowUsers = $resultUsers->fetch_assoc();
                                    echo $rowUsers['total'] ?? 0;
                                    ?>
                                </div>
                            </div>
                            <div class="col-auto">
                                <i class="fas fa-users fa-2x text-gray-300"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<?php endif; ?>

<script>
$(document).ready(function() {
    $('#dataTable').DataTable({
        "language": {
            "url": "//cdn.datatables.net/plug-ins/1.10.24/i18n/Turkish.json"
        },
        "order": [[1, "asc"]] // İsme göre sırala
    });
});
</script>