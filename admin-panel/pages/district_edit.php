<?php
// İlçe Düzenleme Sayfası
// Bu sayfa ilçelerin düzenlenmesini sağlar

// ID'yi kontrol et
if (!isset($_GET['id']) || empty($_GET['id'])) {
    echo '<div class="alert alert-danger">İlçe ID bulunamadı.</div>';
    echo '<a href="?page=districts" class="btn btn-primary">İlçe Listesine Dön</a>';
    exit;
}

$district_id = intval($_GET['id']);
$success_message = "";
$error_message = "";

// İlçe bilgilerini getir
try {
    $query = "SELECT * FROM districts WHERE id = ?";
    $stmt = $db->prepare($query);
    $stmt->bind_param("i", $district_id);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows === 0) {
        echo '<div class="alert alert-danger">İlçe bulunamadı.</div>';
        echo '<a href="?page=districts" class="btn btn-primary">İlçe Listesine Dön</a>';
        exit;
    }
    
    $district = $result->fetch_assoc();
} catch (Exception $e) {
    echo '<div class="alert alert-danger">İlçe bilgisi alınamadı: ' . $e->getMessage() . '</div>';
    echo '<a href="?page=districts" class="btn btn-primary">İlçe Listesine Dön</a>';
    exit;
}

// Form gönderildiğinde
if ($_SERVER['REQUEST_METHOD'] == 'POST' && isset($_POST['update_district'])) {
    $name = $_POST['name'] ?? '';
    $city_id = isset($_POST['city_id']) ? intval($_POST['city_id']) : 0;
    $population = isset($_POST['population']) ? intval($_POST['population']) : 0;
    $mayor_name = $_POST['mayor_name'] ?? '';
    $mayor_party = $_POST['mayor_party'] ?? '';
    $mayor_satisfaction_rate = isset($_POST['mayor_satisfaction_rate']) ? intval($_POST['mayor_satisfaction_rate']) : 0;
    $problem_solving_rate = isset($_POST['problem_solving_rate']) ? intval($_POST['problem_solving_rate']) : 0;
    $contact_email = $_POST['contact_email'] ?? '';
    $contact_phone = $_POST['contact_phone'] ?? '';
    $website = $_POST['website'] ?? '';
    $description = $_POST['description'] ?? '';
    
    // Doğrulama
    if (empty($name) || $city_id <= 0) {
        $error_message = "İlçe adı ve şehir seçimi zorunludur!";
    } else {
        try {
            // Güncelleme sorgusu
            $query = "UPDATE districts SET 
                name = ?, 
                city_id = ?, 
                population = ?,
                mayor_name = ?,
                mayor_party = ?,
                mayor_satisfaction_rate = ?,
                problem_solving_rate = ?,
                contact_email = ?,
                contact_phone = ?,
                website = ?,
                description = ?,
                updated_at = NOW()
                WHERE id = ?";
                
            $stmt = $db->prepare($query);
            $stmt->bind_param("siissiiissi", 
                $name, 
                $city_id, 
                $population,
                $mayor_name,
                $mayor_party,
                $mayor_satisfaction_rate,
                $problem_solving_rate,
                $contact_email,
                $contact_phone,
                $website,
                $description,
                $district_id
            );
            $stmt->execute();
            
            if ($stmt->affected_rows > 0) {
                $success_message = "İlçe başarıyla güncellendi.";
                
                // Güncel ilçe bilgilerini al
                $query = "SELECT * FROM districts WHERE id = ?";
                $stmt = $db->prepare($query);
                $stmt->bind_param("i", $district_id);
                $stmt->execute();
                $result = $stmt->get_result();
                $district = $result->fetch_assoc();
            } else {
                $error_message = "Değişiklik yapılmadı veya bir hata oluştu.";
            }
        } catch (Exception $e) {
            $error_message = "İlçe güncellenirken hata oluştu: " . $e->getMessage();
        }
    }
}

// Şehirleri getir
try {
    $query = "SELECT id, name FROM cities ORDER BY name ASC";
    $stmt = $db->prepare($query);
    $stmt->execute();
    $result = $stmt->get_result();
    $cities = [];
    while ($row = $result->fetch_assoc()) {
        $cities[] = $row;
    }
} catch (Exception $e) {
    $error_message = "Şehir listesi alınamadı: " . $e->getMessage();
    $cities = [];
}

// Siyasi partileri getir
try {
    $query = "SELECT name FROM political_parties ORDER BY name ASC";
    $stmt = $db->prepare($query);
    $stmt->execute();
    $result = $stmt->get_result();
    $political_parties = [];
    while ($row = $result->fetch_assoc()) {
        $political_parties[] = $row['name'];
    }
} catch (Exception $e) {
    $error_message = "Siyasi parti listesi alınamadı: " . $e->getMessage();
    $political_parties = ["AK Parti", "CHP", "MHP", "İYİ Parti", "DEM Parti", "Saadet Partisi", "Gelecek Partisi", "DEVA Partisi", "Diğer"];
}

?>

<div class="container mt-4">
    <?php if (!empty($success_message)): ?>
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <?php echo $success_message; ?>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    <?php endif; ?>
    
    <?php if (!empty($error_message)): ?>
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <?php echo $error_message; ?>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    <?php endif; ?>

    <div class="card shadow-sm">
        <div class="card-header d-flex justify-content-between align-items-center">
            <h5 class="mb-0"><?php echo htmlspecialchars($district['name']); ?> İlçesi Düzenleme</h5>
            <a href="?page=districts" class="btn btn-sm btn-outline-secondary">
                <i class="bi bi-arrow-left"></i> İlçe Listesine Dön
            </a>
        </div>
        <div class="card-body">
            <form method="post" action="?page=district_edit&id=<?php echo $district_id; ?>">
                <!-- Temel Bilgiler -->
                <div class="row mb-4">
                    <div class="col-md-12">
                        <h5>Temel Bilgiler</h5>
                        <hr>
                    </div>
                    
                    <div class="col-md-6">
                        <div class="mb-3">
                            <label for="name" class="form-label">İlçe Adı</label>
                            <input type="text" class="form-control" id="name" name="name" 
                                   value="<?php echo htmlspecialchars($district['name'] ?? ''); ?>" required>
                        </div>
                    </div>
                    
                    <div class="col-md-6">
                        <div class="mb-3">
                            <label for="city_id" class="form-label">Bağlı Olduğu Şehir</label>
                            <select class="form-select" id="city_id" name="city_id" required>
                                <option value="">Şehir Seçin</option>
                                <?php foreach ($cities as $city): ?>
                                    <option value="<?php echo $city['id']; ?>" 
                                        <?php echo (isset($district['city_id']) && $district['city_id'] == $city['id']) ? 'selected' : ''; ?>>
                                        <?php echo htmlspecialchars($city['name']); ?> 
                                        <?php echo !empty($city['region']) ? '(' . htmlspecialchars($city['region']) . ')' : ''; ?>
                                    </option>
                                <?php endforeach; ?>
                            </select>
                        </div>
                    </div>
                    
                    <div class="col-md-6">
                        <div class="mb-3">
                            <label for="population" class="form-label">Nüfus</label>
                            <input type="number" class="form-control" id="population" name="population" 
                                   value="<?php echo htmlspecialchars($district['population'] ?? '0'); ?>">
                        </div>
                    </div>
                    
                    <div class="col-md-6">
                        <div class="mb-3">
                            <label for="description" class="form-label">Açıklama</label>
                            <textarea class="form-control" id="description" name="description" rows="3"><?php echo htmlspecialchars($district['description'] ?? ''); ?></textarea>
                        </div>
                    </div>
                </div>
                
                <!-- Belediye Bilgileri -->
                <div class="row mb-4">
                    <div class="col-md-12">
                        <h5>Belediye Bilgileri</h5>
                        <hr>
                    </div>
                    
                    <div class="col-md-6">
                        <div class="mb-3">
                            <label for="mayor_name" class="form-label">Belediye Başkanı</label>
                            <input type="text" class="form-control" id="mayor_name" name="mayor_name" 
                                   value="<?php echo htmlspecialchars($district['mayor_name'] ?? ''); ?>">
                        </div>
                    </div>
                    
                    <div class="col-md-6">
                        <div class="mb-3">
                            <label for="mayor_party" class="form-label">Bağlı Olduğu Parti</label>
                            <select class="form-select" id="mayor_party" name="mayor_party">
                                <option value="">Parti Seçin</option>
                                <?php foreach ($political_parties as $party): ?>
                                    <option value="<?php echo htmlspecialchars($party); ?>" 
                                        <?php echo (isset($district['mayor_party']) && $district['mayor_party'] == $party) ? 'selected' : ''; ?>>
                                        <?php echo htmlspecialchars($party); ?>
                                    </option>
                                <?php endforeach; ?>
                            </select>
                        </div>
                    </div>
                    
                    <div class="col-md-6">
                        <div class="mb-3">
                            <label for="mayor_satisfaction_rate" class="form-label">Başkan Memnuniyet Oranı (%)</label>
                            <input type="number" class="form-control" id="mayor_satisfaction_rate" name="mayor_satisfaction_rate" 
                                   min="0" max="100" value="<?php echo htmlspecialchars($district['mayor_satisfaction_rate'] ?? '0'); ?>">
                        </div>
                    </div>
                    
                    <div class="col-md-6">
                        <div class="mb-3">
                            <label for="problem_solving_rate" class="form-label">Sorun Çözme Oranı (%)</label>
                            <input type="number" class="form-control" id="problem_solving_rate" name="problem_solving_rate" 
                                   min="0" max="100" value="<?php echo htmlspecialchars($district['problem_solving_rate'] ?? '0'); ?>">
                        </div>
                    </div>
                </div>
                
                <!-- İletişim Bilgileri -->
                <div class="row mb-4">
                    <div class="col-md-12">
                        <h5>İletişim Bilgileri</h5>
                        <hr>
                    </div>
                    
                    <div class="col-md-4">
                        <div class="mb-3">
                            <label for="contact_email" class="form-label">E-posta Adresi</label>
                            <input type="email" class="form-control" id="contact_email" name="contact_email" 
                                   value="<?php echo htmlspecialchars($district['contact_email'] ?? ''); ?>">
                        </div>
                    </div>
                    
                    <div class="col-md-4">
                        <div class="mb-3">
                            <label for="contact_phone" class="form-label">Telefon Numarası</label>
                            <input type="text" class="form-control" id="contact_phone" name="contact_phone" 
                                   value="<?php echo htmlspecialchars($district['contact_phone'] ?? ''); ?>">
                        </div>
                    </div>
                    
                    <div class="col-md-4">
                        <div class="mb-3">
                            <label for="website" class="form-label">Web Sitesi</label>
                            <input type="url" class="form-control" id="website" name="website" 
                                   value="<?php echo htmlspecialchars($district['website'] ?? ''); ?>">
                        </div>
                    </div>
                </div>
                
                <!-- Kaydet ve İptal Butonları -->
                <div class="d-flex justify-content-between">
                    <a href="?page=districts" class="btn btn-outline-secondary">İptal</a>
                    <button type="submit" name="update_district" class="btn btn-primary">Güncelle</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        // Form doğrulama
        const form = document.querySelector('form');
        form.addEventListener('submit', function(event) {
            const name = document.getElementById('name').value.trim();
            const cityId = document.getElementById('city_id').value;
            
            if (!name || !cityId) {
                event.preventDefault();
                alert('Lütfen ilçe adı ve şehir bilgisini girin!');
            }
        });
    });
</script>