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
    
    $query = "UPDATE districts SET name = ?, city_id = ? WHERE id = ?";
    $stmt = $conn->prepare($query);
    $stmt->bind_param('sii', $name, $districtCityId, $districtId);
    
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
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="addDistrictModalLabel">Yeni İlçe Ekle</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form method="POST">
                <div class="modal-body">
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
            
            <div class="mt-4">
                <a href="?page=districts<?php echo $cityId > 0 ? '&city_id=' . $cityId : ''; ?>" class="btn btn-secondary">İptal</a>
                <button type="submit" name="update_district" class="btn btn-primary">Güncelle</button>
            </div>
        </form>
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