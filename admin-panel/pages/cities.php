<?php
require_once 'db_connection.php';

// İşlem yönetimi
$operation = isset($_GET['op']) ? $_GET['op'] : '';
$message = '';
$error = '';

// Şehir silme işlemi
if ($operation === 'delete' && isset($_GET['id'])) {
    $cityId = $_GET['id'];
    
    // İlçeleri kontrol et
    $checkDistrictsQuery = "SELECT COUNT(*) as count FROM districts WHERE city_id = ?";
    $stmt = $conn->prepare($checkDistrictsQuery);
    $stmt->bind_param("i", $cityId);
    $stmt->execute();
    $result = $stmt->get_result();
    $districtCount = $result->fetch_assoc()['count'];
    
    if ($districtCount > 0) {
        $error = "Bu şehre ait $districtCount ilçe bulunmaktadır. Önce ilçeleri silmelisiniz.";
    } else {
        // Şehre ait anketleri kontrol et
        $checkSurveysQuery = "SELECT COUNT(*) as count FROM surveys WHERE scope_type = 'city' AND scope_id = ?";
        $stmt = $conn->prepare($checkSurveysQuery);
        $stmt->bind_param("i", $cityId);
        $stmt->execute();
        $result = $stmt->get_result();
        $surveyCount = $result->fetch_assoc()['count'];
        
        // Şehre ait gönderileri kontrol et
        $checkPostsQuery = "SELECT COUNT(*) as count FROM posts WHERE city_id = ?";
        $stmt = $conn->prepare($checkPostsQuery);
        $stmt->bind_param("i", $cityId);
        $stmt->execute();
        $result = $stmt->get_result();
        $postCount = $result->fetch_assoc()['count'];
        
        if ($surveyCount > 0 || $postCount > 0) {
            $error = "Bu şehre ait $surveyCount anket ve $postCount gönderi bulunmaktadır. Silme işlemi yapılamaz.";
        } else {
            // Şehri sil
            $deleteQuery = "DELETE FROM cities WHERE id = ?";
            $stmt = $conn->prepare($deleteQuery);
            $stmt->bind_param("i", $cityId);
            
            if ($stmt->execute()) {
                $message = "Şehir başarıyla silindi.";
            } else {
                $error = "Şehir silinirken bir hata oluştu: " . $conn->error;
            }
        }
    }
}

// Yeni şehir ekleme
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['add_city'])) {
    $name = $_POST['name'];
    $description = $_POST['description'];
    $population = $_POST['population'];
    $latitude = $_POST['latitude'];
    $longitude = $_POST['longitude'];
    $mayorName = $_POST['mayor_name'];
    $mayorParty = $_POST['mayor_party'];
    $mayorSatisfactionRate = $_POST['mayor_satisfaction_rate'];
    
    // Headerımage ve image dosyaları kontrol ediliyor
    $headerImageUrl = null;
    $imageUrl = null;
    $mayorImageUrl = null;
    $mayorPartyLogoUrl = null;
    
    if (!empty($_FILES['header_image']['name'])) {
        $target_dir = "../uploads/cities/";
        
        // Klasör yoksa oluştur
        if (!file_exists($target_dir)) {
            mkdir($target_dir, 0777, true);
        }
        
        $headerImageFileName = time() . '_' . basename($_FILES['header_image']['name']);
        $target_file = $target_dir . $headerImageFileName;
        
        // Dosya yükleme işlemi
        if (move_uploaded_file($_FILES['header_image']['tmp_name'], $target_file)) {
            $headerImageUrl = 'uploads/cities/' . $headerImageFileName;
        } else {
            $error = "Banner resmi yüklenirken bir hata oluştu.";
        }
    }
    
    // Belediye başkanı fotoğrafı
    if (!empty($_FILES['mayor_image']['name'])) {
        $target_dir = "../uploads/mayors/";
        
        // Klasör yoksa oluştur
        if (!file_exists($target_dir)) {
            mkdir($target_dir, 0777, true);
        }
        
        $mayorImageFileName = time() . '_' . basename($_FILES['mayor_image']['name']);
        $target_file = $target_dir . $mayorImageFileName;
        
        // Dosya yükleme işlemi
        if (move_uploaded_file($_FILES['mayor_image']['tmp_name'], $target_file)) {
            $mayorImageUrl = 'uploads/mayors/' . $mayorImageFileName;
        } else {
            $error = "Belediye başkanı fotoğrafı yüklenirken bir hata oluştu.";
        }
    }
    
    // Parti logosu
    if (!empty($_FILES['mayor_party_logo']['name'])) {
        $target_dir = "../uploads/parties/";
        
        // Klasör yoksa oluştur
        if (!file_exists($target_dir)) {
            mkdir($target_dir, 0777, true);
        }
        
        $partyLogoFileName = time() . '_' . basename($_FILES['mayor_party_logo']['name']);
        $target_file = $target_dir . $partyLogoFileName;
        
        // Dosya yükleme işlemi
        if (move_uploaded_file($_FILES['mayor_party_logo']['tmp_name'], $target_file)) {
            $mayorPartyLogoUrl = 'uploads/parties/' . $partyLogoFileName;
        } else {
            $error = "Parti logosu yüklenirken bir hata oluştu.";
        }
    }
    
    if (!empty($_FILES['image']['name'])) {
        $target_dir = "../uploads/cities/";
        
        // Klasör yoksa oluştur
        if (!file_exists($target_dir)) {
            mkdir($target_dir, 0777, true);
        }
        
        $imageFileName = time() . '_' . basename($_FILES['image']['name']);
        $target_file = $target_dir . $imageFileName;
        
        // Dosya yükleme işlemi
        if (move_uploaded_file($_FILES['image']['tmp_name'], $target_file)) {
            $imageUrl = 'uploads/cities/' . $imageFileName;
        } else {
            $error = "Profil resmi yüklenirken bir hata oluştu.";
        }
    }
    
    if (empty($error)) {
        // Şehir ekle
        $insertQuery = "INSERT INTO cities (name, description, population, latitude, longitude, image_url, header_image_url, 
                        mayor_name, mayor_party, mayor_satisfaction_rate, mayor_image_url, mayor_party_logo, created_at) 
                        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())";
        $stmt = $conn->prepare($insertQuery);
        $stmt->bind_param("ssdddssssisss", $name, $description, $population, $latitude, $longitude, 
                           $imageUrl, $headerImageUrl, $mayorName, $mayorParty, $mayorSatisfactionRate, 
                           $mayorImageUrl, $mayorPartyLogoUrl);
        
        if ($stmt->execute()) {
            $message = "Şehir başarıyla eklendi.";
        } else {
            $error = "Şehir eklenirken bir hata oluştu: " . $conn->error;
        }
    }
}

// Şehir güncelleme
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['update_city'])) {
    $cityId = $_POST['city_id'];
    $name = $_POST['name'];
    $description = $_POST['description'];
    $population = $_POST['population'];
    $latitude = $_POST['latitude'];
    $longitude = $_POST['longitude'];
    $mayorName = $_POST['mayor_name'] ?? null;
    $mayorParty = $_POST['mayor_party'] ?? null;
    $mayorSatisfactionRate = isset($_POST['mayor_satisfaction_rate']) ? $_POST['mayor_satisfaction_rate'] : null;
    
    // Mevcut resim URL'lerini al
    $getImagesQuery = "SELECT image_url, header_image_url, mayor_image_url, mayor_party_logo FROM cities WHERE id = ?";
    $stmt = $conn->prepare($getImagesQuery);
    $stmt->bind_param("i", $cityId);
    $stmt->execute();
    $result = $stmt->get_result();
    $city = $result->fetch_assoc();
    
    $headerImageUrl = $city['header_image_url'];
    $imageUrl = $city['image_url'];
    $mayorImageUrl = $city['mayor_image_url'];
    $mayorPartyLogoUrl = $city['mayor_party_logo'];
    
    // Header Image işlemi
    if (!empty($_FILES['header_image']['name'])) {
        $target_dir = "../uploads/cities/";
        
        // Klasör yoksa oluştur
        if (!file_exists($target_dir)) {
            mkdir($target_dir, 0777, true);
        }
        
        $headerImageFileName = time() . '_' . basename($_FILES['header_image']['name']);
        $target_file = $target_dir . $headerImageFileName;
        
        // Dosya yükleme işlemi
        if (move_uploaded_file($_FILES['header_image']['tmp_name'], $target_file)) {
            // Eski dosyayı sil
            if (!empty($headerImageUrl) && file_exists("../" . $headerImageUrl)) {
                unlink("../" . $headerImageUrl);
            }
            $headerImageUrl = 'uploads/cities/' . $headerImageFileName;
        } else {
            $error = "Banner resmi yüklenirken bir hata oluştu.";
        }
    }
    
    // İmage işlemi
    if (!empty($_FILES['image']['name'])) {
        $target_dir = "../uploads/cities/";
        
        // Klasör yoksa oluştur
        if (!file_exists($target_dir)) {
            mkdir($target_dir, 0777, true);
        }
        
        $imageFileName = time() . '_' . basename($_FILES['image']['name']);
        $target_file = $target_dir . $imageFileName;
        
        // Dosya yükleme işlemi
        if (move_uploaded_file($_FILES['image']['tmp_name'], $target_file)) {
            // Eski dosyayı sil
            if (!empty($imageUrl) && file_exists("../" . $imageUrl)) {
                unlink("../" . $imageUrl);
            }
            $imageUrl = 'uploads/cities/' . $imageFileName;
        } else {
            $error = "Profil resmi yüklenirken bir hata oluştu.";
        }
    }
    
    if (empty($error)) {
        // Şehir güncelleme
        $updateQuery = "UPDATE cities SET name = ?, description = ?, population = ?, latitude = ?, longitude = ?, image_url = ?, header_image_url = ? WHERE id = ?";
        $stmt = $conn->prepare($updateQuery);
        $stmt->bind_param("ssdddssi", $name, $description, $population, $latitude, $longitude, $imageUrl, $headerImageUrl, $cityId);
        
        if ($stmt->execute()) {
            $message = "Şehir başarıyla güncellendi.";
        } else {
            $error = "Şehir güncellenirken bir hata oluştu: " . $conn->error;
        }
    }
}

// Şehirleri listele
$query = "SELECT c.*, (SELECT COUNT(*) FROM districts WHERE city_id = c.id) as district_count FROM cities c ORDER BY c.name";
$result = $conn->query($query);
$cities = [];

if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $cities[] = $row;
    }
}

// Düzenleme için şehir detayını getir
$editCity = null;
if (isset($_GET['op']) && $_GET['op'] === 'edit' && isset($_GET['id'])) {
    $cityId = $_GET['id'];
    $query = "SELECT * FROM cities WHERE id = ?";
    $stmt = $conn->prepare($query);
    $stmt->bind_param("i", $cityId);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows > 0) {
        $editCity = $result->fetch_assoc();
    }
}
?>

<div class="container-fluid">
    <!-- Mesaj ve hata gösterimi -->
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

    <!-- Şehir Yönetimi Başlığı -->
    <div class="d-sm-flex align-items-center justify-content-between mb-4">
        <h1 class="h3 mb-0 text-gray-800">Şehir Yönetimi</h1>
        <button class="d-none d-sm-inline-block btn btn-sm btn-primary shadow-sm" 
                data-bs-toggle="modal" data-bs-target="#addCityModal">
            <i class="fas fa-plus fa-sm text-white-50"></i> Yeni Şehir Ekle
        </button>
    </div>

    <!-- Şehirler Listesi -->
    <div class="card shadow mb-4">
        <div class="card-header py-3">
            <h6 class="m-0 font-weight-bold text-primary">Şehirler</h6>
        </div>
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-bordered" id="dataTable" width="100%" cellspacing="0">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Resim</th>
                            <th>İsim</th>
                            <th>Nüfus</th>
                            <th>İlçe Sayısı</th>
                            <th>Oluşturulma Tarihi</th>
                            <th>İşlemler</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($cities as $city): ?>
                            <tr>
                                <td><?php echo $city['id']; ?></td>
                                <td class="text-center">
                                    <?php if (!empty($city['image_url'])): ?>
                                        <img src="<?php echo $city['image_url']; ?>" alt="<?php echo $city['name']; ?>" 
                                            class="img-thumbnail" style="width: 50px; height: 50px; object-fit: cover;">
                                    <?php else: ?>
                                        <i class="fas fa-city fa-2x text-gray-300"></i>
                                    <?php endif; ?>
                                </td>
                                <td><?php echo $city['name']; ?></td>
                                <td><?php echo isset($city['population']) && $city['population'] !== null ? number_format($city['population'], 0, ',', '.') : '0'; ?></td>
                                <td><?php echo $city['district_count']; ?></td>
                                <td><?php echo date('d.m.Y H:i', strtotime($city['created_at'])); ?></td>
                                <td>
                                    <a href="?page=cities&op=edit&id=<?php echo $city['id']; ?>" class="btn btn-primary btn-sm">
                                        <i class="fas fa-edit"></i> Düzenle
                                    </a>
                                    <?php if ($city['district_count'] == 0): ?>
                                        <a href="?page=cities&op=delete&id=<?php echo $city['id']; ?>" 
                                           class="btn btn-danger btn-sm"
                                           onclick="return confirm('Bu şehri silmek istediğinize emin misiniz?');">
                                            <i class="fas fa-trash"></i> Sil
                                        </a>
                                    <?php endif; ?>
                                    <a href="?page=districts&city_id=<?php echo $city['id']; ?>" class="btn btn-info btn-sm">
                                        <i class="fas fa-list"></i> İlçeler
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

<!-- Yeni Şehir Ekleme Modal -->
<div class="modal fade" id="addCityModal" tabindex="-1" aria-labelledby="addCityModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="addCityModalLabel">Yeni Şehir Ekle</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form method="POST" enctype="multipart/form-data">
                <div class="modal-body">
                    <div class="mb-3">
                        <label for="name" class="form-label">Şehir Adı</label>
                        <input type="text" class="form-control" id="name" name="name" required>
                    </div>
                    <div class="mb-3">
                        <label for="description" class="form-label">Açıklama</label>
                        <textarea class="form-control" id="description" name="description" rows="3"></textarea>
                    </div>
                    <div class="row">
                        <div class="col-md-4">
                            <div class="mb-3">
                                <label for="population" class="form-label">Nüfus</label>
                                <input type="number" class="form-control" id="population" name="population" required>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="mb-3">
                                <label for="latitude" class="form-label">Enlem</label>
                                <input type="text" class="form-control" id="latitude" name="latitude" required>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="mb-3">
                                <label for="longitude" class="form-label">Boylam</label>
                                <input type="text" class="form-control" id="longitude" name="longitude" required>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="image" class="form-label">Profil Resmi</label>
                                <input type="file" class="form-control" id="image" name="image">
                                <small class="form-text text-muted">Şehrin profil resmi (isteğe bağlı)</small>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="header_image" class="form-label">Banner Resmi</label>
                                <input type="file" class="form-control" id="header_image" name="header_image">
                                <small class="form-text text-muted">Şehrin banner resmi (isteğe bağlı)</small>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Belediye Başkanı Bilgileri -->
                    <div class="card mb-3">
                        <div class="card-header">
                            <h6 class="m-0 font-weight-bold text-primary">Belediye Başkanı Bilgileri</h6>
                        </div>
                        <div class="card-body">
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label for="mayor_name" class="form-label">Belediye Başkanı Adı</label>
                                        <input type="text" class="form-control" id="mayor_name" name="mayor_name">
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label for="mayor_party" class="form-label">Parti</label>
                                        <input type="text" class="form-control" id="mayor_party" name="mayor_party">
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label for="mayor_satisfaction_rate" class="form-label">Memnuniyet Oranı (%)</label>
                                        <input type="number" min="0" max="100" class="form-control" id="mayor_satisfaction_rate" name="mayor_satisfaction_rate" value="70">
                                        <small class="form-text text-muted">0-100 arası bir değer girin (Örneğin: 75)</small>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label for="mayor_image" class="form-label">Belediye Başkanı Fotoğrafı</label>
                                        <input type="file" class="form-control" id="mayor_image" name="mayor_image">
                                    </div>
                                </div>
                            </div>
                            <div class="mb-3">
                                <label for="mayor_party_logo" class="form-label">Parti Logosu</label>
                                <input type="file" class="form-control" id="mayor_party_logo" name="mayor_party_logo">
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">İptal</button>
                    <button type="submit" name="add_city" class="btn btn-primary">Kaydet</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Şehir Düzenleme Formu -->
<?php if ($editCity): ?>
<div class="card shadow mb-4">
    <div class="card-header py-3">
        <h6 class="m-0 font-weight-bold text-primary"><?php echo $editCity['name']; ?> Şehrini Düzenle</h6>
    </div>
    <div class="card-body">
        <form method="POST" enctype="multipart/form-data">
            <input type="hidden" name="city_id" value="<?php echo $editCity['id']; ?>">
            
            <div class="mb-3">
                <label for="edit_name" class="form-label">Şehir Adı</label>
                <input type="text" class="form-control" id="edit_name" name="name" value="<?php echo $editCity['name']; ?>" required>
            </div>
            <div class="mb-3">
                <label for="edit_description" class="form-label">Açıklama</label>
                <textarea class="form-control" id="edit_description" name="description" rows="3"><?php echo $editCity['description']; ?></textarea>
            </div>
            <div class="row">
                <div class="col-md-4">
                    <div class="mb-3">
                        <label for="edit_population" class="form-label">Nüfus</label>
                        <input type="number" class="form-control" id="edit_population" name="population" value="<?php echo isset($editCity['population']) && $editCity['population'] !== null ? $editCity['population'] : 0; ?>" required>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="mb-3">
                        <label for="edit_latitude" class="form-label">Enlem</label>
                        <input type="text" class="form-control" id="edit_latitude" name="latitude" value="<?php echo $editCity['latitude']; ?>" required>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="mb-3">
                        <label for="edit_longitude" class="form-label">Boylam</label>
                        <input type="text" class="form-control" id="edit_longitude" name="longitude" value="<?php echo $editCity['longitude']; ?>" required>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-6">
                    <div class="mb-3">
                        <label for="edit_image" class="form-label">Profil Resmi</label>
                        <?php if (!empty($editCity['image_url'])): ?>
                            <div class="mb-2">
                                <img src="<?php echo $editCity['image_url']; ?>" alt="Mevcut Profil Resmi" class="img-thumbnail" style="max-width: 150px;">
                            </div>
                        <?php endif; ?>
                        <input type="file" class="form-control" id="edit_image" name="image">
                        <small class="form-text text-muted">Yeni bir resim yüklerseniz, eski resim değiştirilecektir.</small>
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="mb-3">
                        <label for="edit_header_image" class="form-label">Banner Resmi</label>
                        <?php if (!empty($editCity['header_image_url'])): ?>
                            <div class="mb-2">
                                <img src="<?php echo $editCity['header_image_url']; ?>" alt="Mevcut Banner Resmi" class="img-thumbnail" style="max-width: 150px;">
                            </div>
                        <?php endif; ?>
                        <input type="file" class="form-control" id="edit_header_image" name="header_image">
                        <small class="form-text text-muted">Yeni bir resim yüklerseniz, eski resim değiştirilecektir.</small>
                    </div>
                </div>
            </div>
            
            <!-- Belediye Başkanı Bilgileri -->
            <div class="card mb-4">
                <div class="card-header">
                    <h6 class="m-0 font-weight-bold text-primary">Belediye Başkanı Bilgileri</h6>
                </div>
                <div class="card-body">
                    <div class="row">
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="edit_mayor_name" class="form-label">Belediye Başkanı Adı</label>
                                <input type="text" class="form-control" id="edit_mayor_name" name="mayor_name" value="<?php echo isset($editCity['mayor_name']) ? $editCity['mayor_name'] : ''; ?>">
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="edit_mayor_party" class="form-label">Parti</label>
                                <input type="text" class="form-control" id="edit_mayor_party" name="mayor_party" value="<?php echo isset($editCity['mayor_party']) ? $editCity['mayor_party'] : ''; ?>">
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="edit_mayor_satisfaction_rate" class="form-label">Memnuniyet Oranı (%)</label>
                                <input type="number" min="0" max="100" class="form-control" id="edit_mayor_satisfaction_rate" name="mayor_satisfaction_rate" value="<?php echo isset($editCity['mayor_satisfaction_rate']) ? $editCity['mayor_satisfaction_rate'] : 70; ?>">
                                <small class="form-text text-muted">0-100 arası bir değer girin (Örneğin: 75)</small>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="edit_mayor_image" class="form-label">Belediye Başkanı Fotoğrafı</label>
                                <?php if (!empty($editCity['mayor_image_url'])): ?>
                                    <div class="mb-2">
                                        <img src="<?php echo $editCity['mayor_image_url']; ?>" alt="Mevcut Başkan Fotoğrafı" class="img-thumbnail" style="max-width: 100px; max-height: 100px;">
                                    </div>
                                <?php endif; ?>
                                <input type="file" class="form-control" id="edit_mayor_image" name="mayor_image">
                            </div>
                        </div>
                    </div>
                    <div class="mb-3">
                        <label for="edit_mayor_party_logo" class="form-label">Parti Logosu</label>
                        <?php if (!empty($editCity['mayor_party_logo'])): ?>
                            <div class="mb-2">
                                <img src="<?php echo $editCity['mayor_party_logo']; ?>" alt="Mevcut Parti Logosu" class="img-thumbnail" style="max-width: 100px; max-height: 100px;">
                            </div>
                        <?php endif; ?>
                        <input type="file" class="form-control" id="edit_mayor_party_logo" name="mayor_party_logo">
                    </div>
                </div>
            </div>
            
            <div class="mt-4">
                <a href="?page=cities" class="btn btn-secondary">İptal</a>
                <button type="submit" name="update_city" class="btn btn-primary">Güncelle</button>
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
        "order": [[2, "asc"]] // İsme göre sırala
    });
});
</script>