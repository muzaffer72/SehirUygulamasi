<?php
// İlçe Yönetimi Sayfası
// Şehirler gibi ilçeler de tüm detaylarla gösterilecektir

// Veritabanı bağlantısını al
$conn = pg_connect("host={$db_host} port={$db_port} dbname={$db_name} user={$db_user} password={$db_password}");
if (!$conn) {
    echo '<div class="alert alert-danger">Veritabanı bağlantı hatası: ' . pg_last_error() . '</div>';
    exit;
}

// İşlem mesajları
$message = isset($_GET['message']) ? urldecode($_GET['message']) : '';
$error = isset($_GET['error']) ? urldecode($_GET['error']) : '';
$deleted_id = isset($_GET['deleted_id']) ? intval($_GET['deleted_id']) : 0;

// İlçe silme işlemi
if (isset($_GET['op']) && $_GET['op'] === 'delete' && isset($_GET['id'])) {
    $district_id = intval($_GET['id']);
    
    try {
        // Silme işlemi öncesi ilçe adını al
        $name_query = "SELECT name FROM districts WHERE id = $1";
        $name_result = pg_query_params($conn, $name_query, array($district_id));
        
        if (pg_num_rows($name_result) > 0) {
            $district_row = pg_fetch_assoc($name_result);
            $district_name = $district_row['name'];
            
            // İlçeyi sil
            $delete_query = "DELETE FROM districts WHERE id = $1";
            $delete_result = pg_query_params($conn, $delete_query, array($district_id));
            
            if ($delete_stmt->affected_rows > 0) {
                $message = "'$district_name' ilçesi başarıyla silindi.";
                header("Location: ?page=districts&message=" . urlencode($message) . "&deleted_id=" . $district_id);
                exit;
            } else {
                $error = "İlçe silinirken bir hata oluştu.";
            }
        } else {
            $error = "Silinecek ilçe bulunamadı.";
        }
    } catch (Exception $e) {
        $error = "İlçe silme hatası: " . $e->getMessage();
    }
    
    if (!empty($error)) {
        header("Location: ?page=districts&error=" . urlencode($error));
        exit;
    }
}

// İlçe ekleme işlemi
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['add_district'])) {
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
    
    if (!empty($name) && $city_id > 0) {
        try {
            $query = "INSERT INTO districts (name, city_id, population, mayor_name, mayor_party, 
                     mayor_satisfaction_rate, problem_solving_rate, contact_email, contact_phone, 
                     website, description, created_at, updated_at) 
                     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())";
                     
            $stmt = $db->prepare($query);
            $stmt->bind_param("siissiissss", 
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
                $description
            );
            $stmt->execute();
            
            if ($stmt->affected_rows > 0) {
                $message = "'$name' ilçesi başarıyla eklendi.";
                header("Location: ?page=districts&message=" . urlencode($message));
                exit;
            } else {
                $error = "İlçe eklenirken bir hata oluştu.";
            }
        } catch (Exception $e) {
            $error = "İlçe ekleme hatası: " . $e->getMessage();
        }
    } else {
        $error = "İlçe adı ve şehir seçimi zorunludur!";
    }
}

// Şehirleri getir
try {
    $cities_query = "SELECT id, name FROM cities ORDER BY name ASC";
    $cities_result = pg_query($conn, $cities_query);
    $cities = [];
    
    if ($cities_result) {
        while ($row = pg_fetch_assoc($cities_result)) {
            $cities[] = $row;
        }
    }
} catch (Exception $e) {
    echo '<div class="alert alert-danger">Şehir listesi alınamadı: ' . $e->getMessage() . '</div>';
    $cities = [];
}

// Siyasi partileri getir
try {
    $parties_query = "SELECT name FROM political_parties ORDER BY name ASC";
    $parties_result = pg_query($conn, $parties_query);
    $political_parties = [];
    
    if ($parties_result) {
        while ($row = pg_fetch_assoc($parties_result)) {
            $political_parties[] = $row['name'];
        }
    }
} catch (Exception $e) {
    $political_parties = ["AK Parti", "CHP", "MHP", "İYİ Parti", "DEM Parti", "Saadet Partisi", "Gelecek Partisi", "DEVA Partisi", "Diğer"];
}

// İlçeleri getir - Sayfalama için
try {
    // Toplam ilçe sayısı
    $count_query = "SELECT COUNT(*) as total FROM districts";
    $count_stmt = $db->prepare($count_query);
    $count_stmt->execute();
    $count_result = $count_stmt->get_result();
    $total_districts = $count_result->fetch_assoc()['total'];
    
    // Sayfalama
    $districts_per_page = 20;
    $total_pages = ceil($total_districts / $districts_per_page);
    $current_page = isset($_GET['page_no']) ? intval($_GET['page_no']) : 1;
    $current_page = max(1, min($current_page, $total_pages));
    $offset = ($current_page - 1) * $districts_per_page;
    
    // Filtreleme
    $where_clause = " WHERE 1=1";
    $city_filter = isset($_GET['city_filter']) ? intval($_GET['city_filter']) : 0;
    if ($city_filter > 0) {
        $where_clause .= " AND d.city_id = $city_filter";
    }
    
    $search_term = isset($_GET['search']) ? $_GET['search'] : '';
    if (!empty($search_term)) {
        $search_term = '%' . $search_term . '%';
        $where_clause .= " AND (d.name LIKE '$search_term' OR c.name LIKE '$search_term')";
    }
    
    $query = "SELECT d.*, c.name as city_name
              FROM districts d
              LEFT JOIN cities c ON d.city_id = c.id
              $where_clause
              ORDER BY d.name ASC
              LIMIT $districts_per_page OFFSET $offset";
              
    $stmt = $db->prepare($query);
    $stmt->execute();
    $result = $stmt->get_result();
    $districts = [];
    while ($row = $result->fetch_assoc()) {
        $districts[] = $row;
    }
} catch (Exception $e) {
    echo '<div class="alert alert-danger">İlçe verilerini alma hatası: ' . $e->getMessage() . '</div>';
    $districts = [];
    $total_districts = 0;
    $total_pages = 1;
    $current_page = 1;
}

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
            <h6 class="m-0 font-weight-bold text-primary">İlçeler (Toplam: <?php echo number_format($total_districts, 0, ',', '.'); ?>)</h6>
            <button type="button" class="btn btn-primary btn-sm" data-bs-toggle="modal" data-bs-target="#addDistrictModal">
                <i class="bi bi-plus-circle"></i> Yeni İlçe Ekle
            </button>
        </div>
        
        <div class="card-body">
            <!-- Filtreleme -->
            <div class="row mb-3">
                <div class="col-md-12">
                    <form method="get" action="" class="row g-3">
                        <input type="hidden" name="page" value="districts">
                        
                        <div class="col-md-4">
                            <div class="input-group">
                                <input type="text" class="form-control" placeholder="İlçe adı ara..." name="search" value="<?php echo htmlspecialchars($search_term ?? ''); ?>">
                                <button class="btn btn-outline-secondary" type="submit">Ara</button>
                            </div>
                        </div>
                        
                        <div class="col-md-4">
                            <select class="form-select" name="city_filter" onchange="this.form.submit()">
                                <option value="0">Tüm Şehirler</option>
                                <?php foreach ($cities as $city): ?>
                                    <option value="<?php echo $city['id']; ?>" <?php echo ($city_filter == $city['id']) ? 'selected' : ''; ?>>
                                        <?php echo htmlspecialchars($city['name']); ?>
                                    </option>
                                <?php endforeach; ?>
                            </select>
                        </div>
                        
                        <div class="col-md-4 text-end">
                            <?php if (!empty($search_term) || $city_filter > 0): ?>
                                <a href="?page=districts" class="btn btn-outline-secondary">Filtreleri Temizle</a>
                            <?php endif; ?>
                        </div>
                    </form>
                </div>
            </div>
            
            <div class="table-responsive">
                <table class="table table-bordered table-hover" id="districtsTable" width="100%" cellspacing="0">
                    <thead class="table-light">
                        <tr>
                            <th>ID</th>
                            <th>İlçe Adı</th>
                            <th>Şehir</th>
                            <th>Bölge</th>
                            <th>Belediye Başkanı</th>
                            <th>Parti</th>
                            <th>Nüfus</th>
                            <th>Sorun Çözme Oranı</th>
                            <th>İşlemler</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php if (empty($districts)): ?>
                            <tr>
                                <td colspan="9" class="text-center">Kayıt bulunamadı.</td>
                            </tr>
                        <?php else: ?>
                            <?php foreach ($districts as $district): ?>
                                <tr <?php echo ($deleted_id > 0 && $district['id'] == $deleted_id) ? 'class="table-danger"' : ''; ?>>
                                    <td><?php echo $district['id']; ?></td>
                                    <td><?php echo htmlspecialchars($district['name']); ?></td>
                                    <td><?php echo htmlspecialchars($district['city_name'] ?? 'Bilinmiyor'); ?></td>
                                    <td>-</td>
                                    <td><?php echo htmlspecialchars($district['mayor_name'] ?? '-'); ?></td>
                                    <td><?php echo htmlspecialchars($district['mayor_party'] ?? '-'); ?></td>
                                    <td><?php echo !empty($district['population']) ? number_format($district['population'], 0, ',', '.') : '-'; ?></td>
                                    <td>
                                        <?php if (isset($district['problem_solving_rate'])): ?>
                                            <div class="progress" style="height: 20px;" title="<?php echo $district['problem_solving_rate']; ?>%">
                                                <div class="progress-bar 
                                                <?php
                                                    if ($district['problem_solving_rate'] < 30) echo 'bg-danger';
                                                    elseif ($district['problem_solving_rate'] < 60) echo 'bg-warning';
                                                    elseif ($district['problem_solving_rate'] < 85) echo 'bg-info';
                                                    else echo 'bg-success';
                                                ?>" 
                                                    role="progressbar" 
                                                    style="width: <?php echo $district['problem_solving_rate']; ?>%;" 
                                                    aria-valuenow="<?php echo $district['problem_solving_rate']; ?>" 
                                                    aria-valuemin="0" 
                                                    aria-valuemax="100">
                                                    <?php echo $district['problem_solving_rate']; ?>%
                                                </div>
                                            </div>
                                        <?php else: ?>
                                            -
                                        <?php endif; ?>
                                    </td>
                                    <td class="text-center">
                                        <a href="?page=district_edit&id=<?php echo $district['id']; ?>" class="btn btn-sm btn-primary me-1" title="Düzenle">
                                            <i class="bi bi-pencil"></i>
                                        </a>
                                        <a href="?page=districts&op=delete&id=<?php echo $district['id']; ?>" class="btn btn-sm btn-danger" 
                                           onclick="return confirm('<?php echo htmlspecialchars($district['name']); ?> ilçesini silmek istediğinizden emin misiniz?');" title="Sil">
                                            <i class="bi bi-trash"></i>
                                        </a>
                                    </td>
                                </tr>
                            <?php endforeach; ?>
                        <?php endif; ?>
                    </tbody>
                </table>
            </div>
            
            <?php if ($total_pages > 1): ?>
                <div class="d-flex justify-content-center mt-4">
                    <nav aria-label="İlçe Sayfaları">
                        <ul class="pagination">
                            <li class="page-item <?php echo ($current_page <= 1) ? 'disabled' : ''; ?>">
                                <a class="page-link" href="?page=districts&page_no=1<?php echo !empty($search_term) ? '&search='.urlencode($search_term) : ''; ?><?php echo ($city_filter > 0) ? '&city_filter='.$city_filter : ''; ?>" aria-label="İlk">
                                    <span aria-hidden="true">&laquo;&laquo;</span>
                                </a>
                            </li>
                            <li class="page-item <?php echo ($current_page <= 1) ? 'disabled' : ''; ?>">
                                <a class="page-link" href="?page=districts&page_no=<?php echo $current_page - 1; ?><?php echo !empty($search_term) ? '&search='.urlencode($search_term) : ''; ?><?php echo ($city_filter > 0) ? '&city_filter='.$city_filter : ''; ?>" aria-label="Önceki">
                                    <span aria-hidden="true">&laquo;</span>
                                </a>
                            </li>
                            
                            <?php
                            $start_page = max(1, $current_page - 2);
                            $end_page = min($total_pages, $current_page + 2);
                            
                            for ($i = $start_page; $i <= $end_page; $i++):
                            ?>
                                <li class="page-item <?php echo ($i == $current_page) ? 'active' : ''; ?>">
                                    <a class="page-link" href="?page=districts&page_no=<?php echo $i; ?><?php echo !empty($search_term) ? '&search='.urlencode($search_term) : ''; ?><?php echo ($city_filter > 0) ? '&city_filter='.$city_filter : ''; ?>">
                                        <?php echo $i; ?>
                                    </a>
                                </li>
                            <?php endfor; ?>
                            
                            <li class="page-item <?php echo ($current_page >= $total_pages) ? 'disabled' : ''; ?>">
                                <a class="page-link" href="?page=districts&page_no=<?php echo $current_page + 1; ?><?php echo !empty($search_term) ? '&search='.urlencode($search_term) : ''; ?><?php echo ($city_filter > 0) ? '&city_filter='.$city_filter : ''; ?>" aria-label="Sonraki">
                                    <span aria-hidden="true">&raquo;</span>
                                </a>
                            </li>
                            <li class="page-item <?php echo ($current_page >= $total_pages) ? 'disabled' : ''; ?>">
                                <a class="page-link" href="?page=districts&page_no=<?php echo $total_pages; ?><?php echo !empty($search_term) ? '&search='.urlencode($search_term) : ''; ?><?php echo ($city_filter > 0) ? '&city_filter='.$city_filter : ''; ?>" aria-label="Son">
                                    <span aria-hidden="true">&raquo;&raquo;</span>
                                </a>
                            </li>
                        </ul>
                    </nav>
                </div>
            <?php endif; ?>
        </div>
    </div>
</div>

<!-- İlçe Ekleme Modal -->
<div class="modal fade" id="addDistrictModal" tabindex="-1" aria-labelledby="addDistrictModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="addDistrictModalLabel">Yeni İlçe Ekle</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form method="post" action="?page=districts">
                <div class="modal-body">
                    <div class="row">
                        <!-- Temel Bilgiler -->
                        <div class="col-md-12">
                            <h6>Temel Bilgiler</h6>
                            <hr>
                        </div>
                        
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="name" class="form-label">İlçe Adı <span class="text-danger">*</span></label>
                                <input type="text" class="form-control" id="name" name="name" required>
                            </div>
                        </div>
                        
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="city_id" class="form-label">Bağlı Olduğu Şehir <span class="text-danger">*</span></label>
                                <select class="form-select" id="city_id" name="city_id" required>
                                    <option value="">Şehir Seçin</option>
                                    <?php foreach ($cities as $city): ?>
                                        <option value="<?php echo $city['id']; ?>">
                                            <?php echo htmlspecialchars($city['name']); ?> 

                                        </option>
                                    <?php endforeach; ?>
                                </select>
                            </div>
                        </div>
                        
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="population" class="form-label">Nüfus</label>
                                <input type="number" class="form-control" id="population" name="population" value="0">
                            </div>
                        </div>
                        
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="description" class="form-label">Açıklama</label>
                                <textarea class="form-control" id="description" name="description" rows="1"></textarea>
                            </div>
                        </div>
                        
                        <!-- Belediye Bilgileri -->
                        <div class="col-md-12 mt-3">
                            <h6>Belediye Bilgileri</h6>
                            <hr>
                        </div>
                        
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="mayor_name" class="form-label">Belediye Başkanı</label>
                                <input type="text" class="form-control" id="mayor_name" name="mayor_name">
                            </div>
                        </div>
                        
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="mayor_party" class="form-label">Bağlı Olduğu Parti</label>
                                <select class="form-select" id="mayor_party" name="mayor_party">
                                    <option value="">Parti Seçin</option>
                                    <?php foreach ($political_parties as $party): ?>
                                        <option value="<?php echo htmlspecialchars($party); ?>">
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
                                       min="0" max="100" value="0">
                            </div>
                        </div>
                        
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="problem_solving_rate" class="form-label">Sorun Çözme Oranı (%)</label>
                                <input type="number" class="form-control" id="problem_solving_rate" name="problem_solving_rate" 
                                       min="0" max="100" value="0">
                            </div>
                        </div>
                        
                        <!-- İletişim Bilgileri -->
                        <div class="col-md-12 mt-3">
                            <h6>İletişim Bilgileri</h6>
                            <hr>
                        </div>
                        
                        <div class="col-md-4">
                            <div class="mb-3">
                                <label for="contact_email" class="form-label">E-posta Adresi</label>
                                <input type="email" class="form-control" id="contact_email" name="contact_email">
                            </div>
                        </div>
                        
                        <div class="col-md-4">
                            <div class="mb-3">
                                <label for="contact_phone" class="form-label">Telefon Numarası</label>
                                <input type="text" class="form-control" id="contact_phone" name="contact_phone">
                            </div>
                        </div>
                        
                        <div class="col-md-4">
                            <div class="mb-3">
                                <label for="website" class="form-label">Web Sitesi</label>
                                <input type="url" class="form-control" id="website" name="website">
                            </div>
                        </div>
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

<script>
    document.addEventListener('DOMContentLoaded', function() {
        // Form doğrulama
        const addForm = document.getElementById('addDistrictModal').querySelector('form');
        addForm.addEventListener('submit', function(event) {
            const name = document.getElementById('name').value.trim();
            const cityId = document.getElementById('city_id').value;
            
            if (!name || !cityId) {
                event.preventDefault();
                alert('Lütfen ilçe adı ve şehir bilgisini girin!');
            }
        });
    });
</script>