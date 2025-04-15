<?php
// İlçe Düzenleme Sayfası
// Bu sayfa ilçelerin düzenlenmesini sağlar

// Veritabanı bağlantısını al
$conn = pg_connect("host={$db_host} port={$db_port} dbname={$db_name} user={$db_user} password={$db_password}");
if (!$conn) {
    echo '<div class="alert alert-danger">Veritabanı bağlantı hatası: ' . pg_last_error() . '</div>';
    exit;
}

// ID'yi kontrol et
if (!isset($_GET['id']) || empty($_GET['id'])) {
    echo '<div class="alert alert-danger">İlçe ID bulunamadı.</div>';
    echo '<a href="?page=districts" class="btn btn-primary">İlçe Listesine Dön</a>';
    exit;
}

$district_id = intval($_GET['id']);
$success_message = "";
$error_message = "";

// İlçe bilgilerini getir - gelişmiş sorgu ile istatistikleri de al
try {
    $query = "SELECT d.*, 
              COALESCE(d.problem_solving_rate, 0) as problem_solving_rate,
              c.name as city_name,
              COUNT(DISTINCT p.id) as total_posts,
              SUM(CASE WHEN p.status = 'solved' THEN 1 ELSE 0 END) as solved_posts,
              SUM(CASE WHEN p.status = 'awaitingSolution' THEN 1 ELSE 0 END) as pending_posts,
              SUM(CASE WHEN p.status = 'inProgress' THEN 1 ELSE 0 END) as in_progress_posts,
              SUM(CASE WHEN p.status = 'rejected' THEN 1 ELSE 0 END) as rejected_posts
        FROM districts d
        LEFT JOIN cities c ON d.city_id = c.id
        LEFT JOIN posts p ON d.id = p.district_id
        WHERE d.id = $1
        GROUP BY d.id, c.name";
        
    $result = pg_query_params($conn, $query, array($district_id));
    
    if (pg_num_rows($result) === 0) {
        echo '<div class="alert alert-danger">İlçe bulunamadı.</div>';
        echo '<a href="?page=districts" class="btn btn-primary">İlçe Listesine Dön</a>';
        exit;
    }
    
    $district = pg_fetch_assoc($result);
    
    // city_id değerinin doğru tipte olduğundan emin olalım
    if (isset($district['city_id'])) {
        $district['city_id'] = intval($district['city_id']);
    }
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
                name = $1, 
                city_id = $2, 
                population = $3,
                mayor_name = $4,
                mayor_party = $5,
                mayor_satisfaction_rate = $6,
                problem_solving_rate = $7,
                contact_email = $8,
                contact_phone = $9,
                website = $10,
                description = $11,
                updated_at = NOW()
                WHERE id = $12";
                
            $result = pg_query_params($conn, $query, array(
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
            ));
            
            if ($result) {
                $success_message = "İlçe başarıyla güncellendi.";
                
                // Güncel ilçe bilgilerini al
                $query = "SELECT * FROM districts WHERE id = $1";
                $result = pg_query_params($conn, $query, array($district_id));
                $district = pg_fetch_assoc($result);
                
                // city_id değerinin doğru tipte olduğundan emin olalım
                if (isset($district['city_id'])) {
                    $district['city_id'] = intval($district['city_id']);
                }
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
    $result = pg_query($conn, $query);
    $cities = [];
    while ($row = pg_fetch_assoc($result)) {
        $cities[] = $row;
    }
} catch (Exception $e) {
    $error_message = "Şehir listesi alınamadı: " . $e->getMessage();
    $cities = [];
}

// Siyasi partileri getir
try {
    // Tablo var mı kontrol et
    $check_table_query = "SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'political_parties'
    )";
    $check_result = pg_query($conn, $check_table_query);
    $table_exists = pg_fetch_result($check_result, 0, 0);
    
    if ($table_exists === 't') {
        $query = "SELECT name FROM political_parties ORDER BY name ASC";
        $result = pg_query($conn, $query);
        $political_parties = [];
        while ($row = pg_fetch_assoc($result)) {
            $political_parties[] = $row['name'];
        }
    } else {
        throw new Exception("political_parties tablosu henüz oluşturulmamış");
    }
} catch (Exception $e) {
    // Hatayı gizlice işle, kullanıcıya gösterme
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
                
                <!-- Analitik ve İstatistikler Bölümü -->
                <div class="row mb-4">
                    <div class="col-md-12">
                        <h5>Analitik ve İstatistikler</h5>
                        <hr>
                    </div>
                    
                    <div class="col-md-3 mb-3">
                        <div class="card border-0 bg-light">
                            <div class="card-body text-center">
                                <h6 class="text-muted mb-1">Toplam Şikayet</h6>
                                <h3><?php echo intval($district['total_posts'] ?? 0); ?></h3>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-md-3 mb-3">
                        <div class="card border-0 bg-success bg-opacity-10">
                            <div class="card-body text-center">
                                <h6 class="text-muted mb-1">Çözülmüş</h6>
                                <h3><?php echo intval($district['solved_posts'] ?? 0); ?></h3>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-md-3 mb-3">
                        <div class="card border-0 bg-warning bg-opacity-10">
                            <div class="card-body text-center">
                                <h6 class="text-muted mb-1">İşlem Bekleyen</h6>
                                <h3><?php echo intval($district['pending_posts'] ?? 0) + intval($district['in_progress_posts'] ?? 0); ?></h3>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-md-3 mb-3">
                        <div class="card border-0 bg-danger bg-opacity-10">
                            <div class="card-body text-center">
                                <h6 class="text-muted mb-1">Reddedilmiş</h6>
                                <h3><?php echo intval($district['rejected_posts'] ?? 0); ?></h3>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Hızlı İşlemler -->
                <div class="row mb-4">
                    <div class="col-md-12">
                        <h5>Hızlı İşlemler</h5>
                        <hr>
                    </div>
                    
                    <div class="col-md-4 mb-3">
                        <a href="?page=posts&district_id=<?php echo $district_id; ?>" class="btn btn-outline-secondary w-100 py-2">
                            <i class="bi bi-file-text"></i> Bu İlçedeki Şikayetleri Görüntüle
                        </a>
                    </div>
                    
                    <div class="col-md-4 mb-3">
                        <a href="?page=surveys&district_id=<?php echo $district_id; ?>" class="btn btn-outline-secondary w-100 py-2">
                            <i class="bi bi-bar-chart-line"></i> Bu İlçedeki Anketleri Görüntüle
                        </a>
                    </div>
                    
                    <div class="col-md-4 mb-3">
                        <a href="?page=city_profile&id=<?php echo $district['city_id']; ?>" class="btn btn-outline-secondary w-100 py-2">
                            <i class="bi bi-building"></i> <?php echo htmlspecialchars($district['city_name'] ?? ''); ?> Şehir Profilini Görüntüle
                        </a>
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

<div class="row mt-4">
    <!-- İlçe Gösterge Paneli -->
    <div class="col-md-6 mb-4">
        <div class="card shadow-sm">
            <div class="card-header bg-light">
                <h5 class="mb-0">İlçe Performans Göstergesi</h5>
            </div>
            <div class="card-body">
                <div class="mb-4">
                    <h6>Sorun Çözme Oranı</h6>
                    <div class="progress" style="height: 20px;">
                        <?php 
                            $solve_rate = intval($district['problem_solving_rate'] ?? 0);
                            $class = 'bg-danger';
                            if ($solve_rate >= 75) {
                                $class = 'bg-success';
                            } elseif ($solve_rate >= 50) {
                                $class = 'bg-warning';
                            } elseif ($solve_rate >= 25) {
                                $class = 'bg-info';
                            }
                        ?>
                        <div class="progress-bar <?php echo $class; ?>" role="progressbar" 
                             style="width: <?php echo $solve_rate; ?>%;" 
                             aria-valuenow="<?php echo $solve_rate; ?>" aria-valuemin="0" aria-valuemax="100">
                            <?php echo $solve_rate; ?>%
                        </div>
                    </div>
                </div>
                
                <div class="mb-4">
                    <h6>Başkan Memnuniyet Oranı</h6>
                    <div class="progress" style="height: 20px;">
                        <?php 
                            $mayor_rate = intval($district['mayor_satisfaction_rate'] ?? 0);
                            $class = 'bg-danger';
                            if ($mayor_rate >= 75) {
                                $class = 'bg-success';
                            } elseif ($mayor_rate >= 50) {
                                $class = 'bg-warning';
                            } elseif ($mayor_rate >= 25) {
                                $class = 'bg-info';
                            }
                        ?>
                        <div class="progress-bar <?php echo $class; ?>" role="progressbar" 
                             style="width: <?php echo $mayor_rate; ?>%;" 
                             aria-valuenow="<?php echo $mayor_rate; ?>" aria-valuemin="0" aria-valuemax="100">
                            <?php echo $mayor_rate; ?>%
                        </div>
                    </div>
                </div>
                
                <div class="alert alert-info">
                    <i class="bi bi-info-circle"></i> Bu göstergeler uygulama kullanıcılarının geribildirimleri, çözülen şikayetler ve sistem analizlerine dayanmaktadır.
                </div>
            </div>
        </div>
    </div>
    
    <!-- Şikayet Dağılımı -->
    <div class="col-md-6 mb-4">
        <div class="card shadow-sm">
            <div class="card-header bg-light">
                <h5 class="mb-0">Şikayet Durumu Dağılımı</h5>
            </div>
            <div class="card-body text-center">
                <?php
                    $total = intval($district['total_posts'] ?? 0);
                    if ($total > 0) {
                        $solved_percent = round((intval($district['solved_posts'] ?? 0) / $total) * 100);
                        $pending_percent = round((intval($district['pending_posts'] ?? 0) / $total) * 100);
                        $in_progress_percent = round((intval($district['in_progress_posts'] ?? 0) / $total) * 100);
                        $rejected_percent = round((intval($district['rejected_posts'] ?? 0) / $total) * 100);
                ?>
                    <div class="row text-center mb-3">
                        <div class="col-3">
                            <div class="p-2 bg-success bg-opacity-25 rounded-3 mb-2">
                                <span><?php echo $solved_percent; ?>%</span>
                            </div>
                            <small class="text-muted">Çözüldü</small>
                        </div>
                        <div class="col-3">
                            <div class="p-2 bg-warning bg-opacity-25 rounded-3 mb-2">
                                <span><?php echo $pending_percent; ?>%</span>
                            </div>
                            <small class="text-muted">Beklemede</small>
                        </div>
                        <div class="col-3">
                            <div class="p-2 bg-info bg-opacity-25 rounded-3 mb-2">
                                <span><?php echo $in_progress_percent; ?>%</span>
                            </div>
                            <small class="text-muted">İşlemde</small>
                        </div>
                        <div class="col-3">
                            <div class="p-2 bg-danger bg-opacity-25 rounded-3 mb-2">
                                <span><?php echo $rejected_percent; ?>%</span>
                            </div>
                            <small class="text-muted">Reddedildi</small>
                        </div>
                    </div>
                <?php } else { ?>
                    <div class="alert alert-warning">
                        <i class="bi bi-exclamation-triangle"></i> Bu ilçe için henüz şikayet kaydı bulunmamaktadır.
                    </div>
                <?php } ?>
                
                <a href="?page=posts&district_id=<?php echo $district_id; ?>" class="btn btn-sm btn-outline-primary mt-3">
                    <i class="bi bi-list-ul"></i> Tüm Şikayetleri Görüntüle
                </a>
            </div>
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