<?php
// Güvenlik kontrolü
if (!isset($_SESSION['user'])) {
    header('Location: index.php');
    exit;
}

// Veritabanı bağlantısı kontrolü
if (!isset($db)) {
    die("Database connection error");
}

// Sayfalama parametreleri
$limit = 10;
$page_num = isset($_GET['page_num']) ? (int)$_GET['page_num'] : 1;
$start = ($page_num - 1) * $limit;

// Filtreleme değişkenleri
$filter_city = isset($_GET['city_id']) ? (int)$_GET['city_id'] : 0;
$filter_district = isset($_GET['district_id']) ? (int)$_GET['district_id'] : 0;
$filter_rating = isset($_GET['rating']) ? (int)$_GET['rating'] : 0;
$filter_status = isset($_GET['status']) ? $_GET['status'] : '';

// WHERE koşulları oluşturma
$where_conditions = [];
$params = [];
$param_types = '';

$where_conditions[] = "p.status = 'resolved'";

if ($filter_city > 0) {
    $where_conditions[] = "p.city_id = ?";
    $params[] = $filter_city;
    $param_types .= 'i';
}

if ($filter_district > 0) {
    $where_conditions[] = "p.district_id = ?";
    $params[] = $filter_district;
    $param_types .= 'i';
}

if ($filter_rating > 0) {
    $where_conditions[] = "p.satisfaction_rating = ?";
    $params[] = $filter_rating;
    $param_types .= 'i';
}

// WHERE koşulunu birleştirme
$where_clause = '';
if (!empty($where_conditions)) {
    $where_clause = "WHERE " . implode(' AND ', $where_conditions);
}

// Toplam kayıt sayısını al
$count_query = "SELECT COUNT(*) as total FROM posts p $where_clause";
$count_stmt = $db->prepare($count_query);

if (!empty($params)) {
    $count_stmt->bind_param($param_types, ...$params);
}

$count_stmt->execute();
$count_result = $count_stmt->get_result();
$total_records = $count_result->fetch_assoc()['total'];
$total_pages = ceil($total_records / $limit);

// Şikayet verilerini al
$query = "
    SELECT p.*, c.name as city_name, d.name as district_name, 
           u.name as user_name, u.username as user_username,
           p.satisfaction_rating
    FROM posts p
    LEFT JOIN cities c ON p.city_id = c.id
    LEFT JOIN districts d ON p.district_id = d.id 
    LEFT JOIN users u ON p.user_id = u.id
    $where_clause
    ORDER BY p.updated_at DESC
    LIMIT ?, ?
";

$stmt = $db->prepare($query);

// Parametre tiplerini oluştur
$param_types .= 'ii';
$params[] = $start;
$params[] = $limit;

// Parametreleri bind etmek için spread operatör kullanımı
$stmt->bind_param($param_types, ...$params);

$stmt->execute();
$result = $stmt->get_result();

// Şehir ve ilçe verilerini al (filtreleme için)
$cities_query = "SELECT * FROM cities ORDER BY name";
$cities_result = $db->query($cities_query);
$cities = [];
while ($city = $cities_result->fetch_assoc()) {
    $cities[] = $city;
}

$districts_query = "SELECT * FROM districts ORDER BY name";
$districts_result = $db->query($districts_query);
$districts = [];
while ($district = $districts_result->fetch_assoc()) {
    $districts[] = $district;
}
?>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2>Memnuniyet Puanlamaları</h2>
</div>

<!-- Filtreleme -->
<div class="card mb-4">
    <div class="card-header">
        <h5 class="mb-0">Filtrele</h5>
    </div>
    <div class="card-body">
        <form method="get" action="">
            <input type="hidden" name="page" value="satisfaction_rating">
            <div class="row g-3">
                <div class="col-md-3">
                    <label for="city_id" class="form-label">Şehir</label>
                    <select class="form-select" id="city_id" name="city_id">
                        <option value="">Tümü</option>
                        <?php foreach ($cities as $city): ?>
                        <option value="<?= $city['id'] ?>" <?= $filter_city == $city['id'] ? 'selected' : '' ?>>
                            <?= $city['name'] ?>
                        </option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="col-md-3">
                    <label for="district_id" class="form-label">İlçe</label>
                    <select class="form-select" id="district_id" name="district_id">
                        <option value="">Tümü</option>
                        <?php foreach ($districts as $district): ?>
                        <option value="<?= $district['id'] ?>" data-city="<?= $district['city_id'] ?>" <?= $filter_district == $district['id'] ? 'selected' : '' ?>>
                            <?= $district['name'] ?>
                        </option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="col-md-3">
                    <label for="rating" class="form-label">Puan</label>
                    <select class="form-select" id="rating" name="rating">
                        <option value="">Tümü</option>
                        <option value="1" <?= $filter_rating == 1 ? 'selected' : '' ?>>1 - Hiç Memnun Değilim</option>
                        <option value="2" <?= $filter_rating == 2 ? 'selected' : '' ?>>2 - Memnun Değilim</option>
                        <option value="3" <?= $filter_rating == 3 ? 'selected' : '' ?>>3 - Kararsızım</option>
                        <option value="4" <?= $filter_rating == 4 ? 'selected' : '' ?>>4 - Memnunum</option>
                        <option value="5" <?= $filter_rating == 5 ? 'selected' : '' ?>>5 - Çok Memnunum</option>
                    </select>
                </div>
                <div class="col-md-3 d-flex align-items-end">
                    <button type="submit" class="btn btn-primary w-100">Filtrele</button>
                </div>
            </div>
        </form>
    </div>
</div>

<!-- Memnuniyet İstatistikleri -->
<div class="row mb-4">
    <div class="col-md-4">
        <div class="card">
            <div class="card-body">
                <h5 class="card-title">Genel Memnuniyet Oranı</h5>
                <?php
                $avg_query = "SELECT AVG(satisfaction_rating) as avg_rating FROM posts WHERE status = 'resolved' AND satisfaction_rating > 0";
                $avg_result = $db->query($avg_query);
                $avg_rating = $avg_result->fetch_assoc()['avg_rating'] ?? 0;
                $avg_rating = number_format($avg_rating, 1);
                
                $rating_percent = ($avg_rating / 5) * 100;
                ?>
                
                <div class="d-flex align-items-center">
                    <div class="display-4 fw-bold me-3"><?= $avg_rating ?>/5</div>
                    <div class="progress flex-grow-1" style="height: 20px;">
                        <div class="progress-bar bg-success" role="progressbar" style="width: <?= $rating_percent ?>%" 
                             aria-valuenow="<?= $rating_percent ?>" aria-valuemin="0" aria-valuemax="100"></div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="col-md-8">
        <div class="card">
            <div class="card-body">
                <h5 class="card-title">Puan Dağılımı</h5>
                <div class="row">
                    <?php
                    for ($i = 5; $i >= 1; $i--) {
                        $rating_count_query = "SELECT COUNT(*) as count FROM posts WHERE status = 'resolved' AND satisfaction_rating = $i";
                        $rating_count_result = $db->query($rating_count_query);
                        $rating_count = $rating_count_result->fetch_assoc()['count'] ?? 0;
                        
                        $bar_class = "bg-danger";
                        if ($i >= 4) $bar_class = "bg-success";
                        else if ($i == 3) $bar_class = "bg-warning";
                        
                        $percent = 0;
                        if ($total_records > 0) {
                            $percent = ($rating_count / $total_records) * 100;
                        }
                    ?>
                    <div class="col-12 mb-1">
                        <div class="d-flex align-items-center">
                            <span class="me-2"><?= $i ?> <i class="bi bi-star-fill text-warning"></i></span>
                            <div class="progress flex-grow-1" style="height: 18px;">
                                <div class="progress-bar <?= $bar_class ?>" role="progressbar" 
                                     style="width: <?= $percent ?>%" aria-valuenow="<?= $percent ?>" 
                                     aria-valuemin="0" aria-valuemax="100">
                                    <?= $rating_count ?> kişi
                                </div>
                            </div>
                        </div>
                    </div>
                    <?php } ?>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Memnuniyet Listesi -->
<div class="card mb-4">
    <div class="card-header">
        <h5 class="mb-0">Memnuniyet Puanlaması Yapılan Şikayetler</h5>
    </div>
    <div class="card-body">
        <div class="table-responsive">
            <table class="table table-hover">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Başlık</th>
                        <th>Konum</th>
                        <th>Kullanıcı</th>
                        <th>Çözüm Tarihi</th>
                        <th>Memnuniyet</th>
                        <th>İşlemler</th>
                    </tr>
                </thead>
                <tbody>
                    <?php
                    if ($result->num_rows > 0):
                        while ($row = $result->fetch_assoc()):
                            // Yıldızları göster
                            $stars = '';
                            $rating = (int)$row['satisfaction_rating'];
                            for ($i = 1; $i <= 5; $i++) {
                                if ($i <= $rating) {
                                    $stars .= '<i class="bi bi-star-fill text-warning"></i>';
                                } else {
                                    $stars .= '<i class="bi bi-star text-muted"></i>';
                                }
                            }
                    ?>
                    <tr>
                        <td><?= $row['id'] ?></td>
                        <td><?= $row['title'] ?></td>
                        <td><?= $row['city_name'] ?>, <?= $row['district_name'] ?></td>
                        <td><?= $row['user_name'] ?? $row['user_username'] ?></td>
                        <td><?= date('d.m.Y H:i', strtotime($row['updated_at'])) ?></td>
                        <td><?= $stars ?> (<?= $rating ?>)</td>
                        <td>
                            <a href="?page=posts&action=view&id=<?= $row['id'] ?>" class="btn btn-sm btn-primary">
                                <i class="bi bi-eye"></i>
                            </a>
                        </td>
                    </tr>
                    <?php 
                        endwhile;
                    else:
                    ?>
                    <tr>
                        <td colspan="7" class="text-center">Memnuniyet puanlaması yapılan şikayet bulunamadı.</td>
                    </tr>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
        
        <!-- Pagination -->
        <?php if ($total_pages > 1): ?>
        <nav aria-label="Page navigation">
            <ul class="pagination justify-content-center mt-4">
                <li class="page-item <?= ($page_num <= 1) ? 'disabled' : '' ?>">
                    <a class="page-link" href="?page=satisfaction_rating&page_num=<?= $page_num - 1 ?>&city_id=<?= $filter_city ?>&district_id=<?= $filter_district ?>&rating=<?= $filter_rating ?>">Önceki</a>
                </li>
                
                <?php for ($i = 1; $i <= $total_pages; $i++): ?>
                <li class="page-item <?= ($page_num == $i) ? 'active' : '' ?>">
                    <a class="page-link" href="?page=satisfaction_rating&page_num=<?= $i ?>&city_id=<?= $filter_city ?>&district_id=<?= $filter_district ?>&rating=<?= $filter_rating ?>"><?= $i ?></a>
                </li>
                <?php endfor; ?>
                
                <li class="page-item <?= ($page_num >= $total_pages) ? 'disabled' : '' ?>">
                    <a class="page-link" href="?page=satisfaction_rating&page_num=<?= $page_num + 1 ?>&city_id=<?= $filter_city ?>&district_id=<?= $filter_district ?>&rating=<?= $filter_rating ?>">Sonraki</a>
                </li>
            </ul>
        </nav>
        <?php endif; ?>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    // İlçeleri şehirlere göre filtreleme
    const citySelect = document.getElementById('city_id');
    const districtSelect = document.getElementById('district_id');
    
    function filterDistricts() {
        const selectedCityId = citySelect.value;
        
        Array.from(districtSelect.options).forEach(option => {
            const cityId = option.getAttribute('data-city');
            if (selectedCityId === '' || cityId === selectedCityId) {
                option.style.display = '';
            } else {
                option.style.display = 'none';
            }
        });
    }
    
    citySelect.addEventListener('change', function() {
        filterDistricts();
        districtSelect.value = ''; // Şehir değiştiğinde ilçe seçimini sıfırla
    });
    
    // Sayfa yüklendiğinde ilçeleri filtrele
    filterDistricts();
});
</script>