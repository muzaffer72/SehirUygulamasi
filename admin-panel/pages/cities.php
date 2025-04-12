<?php
// Yetki kontrolü
requireAdmin();

// Filtreleme - region sütunu olmadığı için koddan çıkarıldı
$regionFilter = isset($_GET['region']) ? $_GET['region'] : '';
$query = "SELECT c.*, 
            COALESCE(c.problem_solving_rate, 0) as problem_solving_rate,
            COUNT(DISTINCT p.id) as total_posts,
            SUM(CASE WHEN p.status = 'solved' THEN 1 ELSE 0 END) as solved_posts
          FROM cities c
          LEFT JOIN posts p ON c.id = p.city_id";

$params = [];

// Region filtresi geçici olarak devre dışı bırakıldı
// if (!empty($regionFilter)) {
//     $query .= " WHERE c.region = ?";
//     $params[] = $regionFilter;
// }

$query .= " GROUP BY c.id ORDER BY c.name ASC";

$stmt = $pdo->prepare($query);
$stmt->execute($params);
$cities = $stmt->fetchAll(PDO::FETCH_ASSOC);

// Bölgeleri çek - Bu kısmı geçici olarak devre dışı bıraktık, çünkü veritabanında 'region' sütunu yok
// $regionsQuery = "SELECT DISTINCT region FROM cities WHERE region IS NOT NULL ORDER BY region";
// $regionsStmt = $pdo->query($regionsQuery);
// $regions = $regionsStmt->fetchAll(PDO::FETCH_COLUMN);
$regions = [];

// Ödül türlerini getir
$awardQuery = "SELECT * FROM award_types ORDER BY min_rate ASC";
$awardStmt = $pdo->query($awardQuery);
$awardTypes = $awardStmt->fetchAll(PDO::FETCH_ASSOC);

// Ödül durumlarına göre şehir sayıları
// PostgreSQL için bunu geçici olarak atlayacağız, çünkü integer/float dönüşümü sorun çıkarıyor.
$awardStats = [];
foreach ($awardTypes as $award) {
    // PostgreSQL için numeric değerleri özel olarak hazırlayalım
    // $minRate = floatval($award['min_rate']);
    // $maxRate = floatval($award['max_rate']);
    
    // Geçici çözüm: Her sınır için sabit bir değer atıyoruz
    $awardStats[$award['id']] = 0;
}

// Aktif ödül sahibi şehirler - geçici olarak devre dışı
$activeAwards = [];
// PostgreSQL ile uyumluluk sorunları olduğu için bu sorguyu geçici olarak kaldırdık
// $activeAwardsQuery = "SELECT c.name as city_name, at.name as award_name, at.badge_color, ca.award_date, ca.expiry_date
//                       FROM city_awards ca
//                       JOIN cities c ON ca.city_id = c.id
//                       JOIN award_types at ON ca.award_type_id = at.id
//                       WHERE ca.is_active = true
//                       ORDER BY ca.award_date DESC
//                       LIMIT 10";
// $activeAwardsStmt = $pdo->query($activeAwardsQuery);
// $activeAwards = $activeAwardsStmt->fetchAll(PDO::FETCH_ASSOC);
?>

<div class="container-fluid px-4">
    <h1 class="mt-4">Şehirler</h1>
    <ol class="breadcrumb mb-4">
        <li class="breadcrumb-item"><a href="index.php">Ana Sayfa</a></li>
        <li class="breadcrumb-item active">Şehirler</li>
    </ol>
    
    <!-- Ödül Sistemi Özeti (Yatay Kartlar) -->
    <div class="card mb-4">
        <div class="card-header">
            <i class="fas fa-medal me-1"></i>
            Belediye Ödül Sistemi
            
            <!-- Ödül Sistemi Butonları -->
            <div class="float-end">
                <button class="btn btn-sm btn-primary me-2" onclick="updateAllRates()">
                    <i class="fas fa-sync me-1"></i> Tüm Şehirlerin Oranlarını Güncelle
                </button>
                <button class="btn btn-sm btn-success" onclick="calculateAllAwards()">
                    <i class="fas fa-medal me-1"></i> Tüm Şehirlerin Ödüllerini Hesapla
                </button>
            </div>
        </div>
        <div class="card-body">
            <!-- Yatay Ödül Kartları -->
            <div class="row">
                <?php foreach ($awardTypes as $award): ?>
                <div class="col-md-4">
                    <div class="card mb-3">
                        <div class="card-header" style="background-color: <?php echo htmlspecialchars($award['badge_color']); ?>; color: #fff;">
                            <?php echo htmlspecialchars($award['name']); ?>
                        </div>
                        <div class="card-body">
                            <p><?php echo htmlspecialchars($award['description']); ?></p>
                            <div class="d-flex justify-content-between">
                                <span>Çözüm Oranı: %<?php echo $award['min_rate']; ?> - %<?php echo $award['max_rate']; ?></span>
                                <span class="badge bg-primary"><?php echo $awardStats[$award['id']]; ?> şehir</span>
                            </div>
                        </div>
                    </div>
                </div>
                <?php endforeach; ?>
            </div>
            
            <?php if (!empty($activeAwards)): ?>
            <div class="mt-4">
                <h5>Son Kazanılan Ödüller</h5>
                <div class="table-responsive">
                    <table class="table table-bordered table-striped">
                        <thead>
                            <tr>
                                <th>Şehir</th>
                                <th>Ödül</th>
                                <th>Kazanma Tarihi</th>
                                <th>Geçerlilik</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($activeAwards as $award): ?>
                            <tr>
                                <td><?php echo htmlspecialchars($award['city_name']); ?></td>
                                <td>
                                    <span class="badge" style="background-color: <?php echo htmlspecialchars($award['badge_color']); ?>">
                                        <?php echo htmlspecialchars($award['award_name']); ?>
                                    </span>
                                </td>
                                <td><?php echo date('d.m.Y', strtotime($award['award_date'])); ?></td>
                                <td>
                                    <?php if (isset($award['expiry_date']) && $award['expiry_date']): ?>
                                        <?php echo date('d.m.Y', strtotime($award['expiry_date'])); ?>'e kadar
                                    <?php else: ?>
                                        Süresiz
                                    <?php endif; ?>
                                </td>
                            </tr>
                            <?php endforeach; ?>
                        </tbody>
                    </table>
                </div>
            </div>
            <?php endif; ?>
        </div>
    </div>
    
    <!-- Şehir Listesi (Eski Tasarım Geri Geldi) -->
    <div class="card mb-4">
        <div class="card-header d-flex justify-content-between align-items-center">
            <div>
                <i class="fas fa-city me-1"></i>
                Şehir Listesi
            </div>
            <div>
                <a href="index.php?page=city_add" class="btn btn-sm btn-primary">
                    <i class="fas fa-plus"></i> Şehir Ekle
                </a>
            </div>
        </div>
        <div class="card-body">
            <!-- Filtreler -->
            <div class="row mb-3">
                <div class="col-md-4">
                    <label for="regionFilter" class="form-label">Bölgeye Göre Filtrele:</label>
                    <select id="regionFilter" class="form-select" onchange="filterByRegion(this.value)">
                        <option value="">Tüm Bölgeler</option>
                        <?php foreach ($regions as $region): ?>
                            <option value="<?php echo htmlspecialchars($region); ?>" <?php echo $regionFilter === $region ? 'selected' : ''; ?>>
                                <?php echo htmlspecialchars($region); ?>
                            </option>
                        <?php endforeach; ?>
                    </select>
                </div>
            </div>
            
            <div class="table-responsive">
                <table id="citiesTable" class="table table-bordered table-striped table-hover">
                    <thead>
                        <tr>
                            <th>Şehir Adı</th>
                            <th>Plaka</th>
                            <th>Bölge</th>
                            <th>Toplam Şikayet</th>
                            <th>Çözülen Şikayet</th>
                            <th>Çözüm Oranı</th>
                            <th>İşlemler</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($cities as $city): ?>
                            <tr>
                                <td><?php echo htmlspecialchars($city['name']); ?></td>
                                <td><?php echo htmlspecialchars($city['plate_number'] ?? '-'); ?></td>
                                <td><?php echo htmlspecialchars($city['region'] ?? '-'); ?></td>
                                <td><?php echo $city['total_posts']; ?></td>
                                <td><?php echo $city['solved_posts']; ?></td>
                                <td>
                                    <div class="progress" style="height: 20px;">
                                        <?php
                                        $rate = floatval($city['problem_solving_rate']);
                                        $colorClass = 'bg-danger';
                                        
                                        if ($rate >= 75) {
                                            $colorClass = 'bg-success';
                                        } elseif ($rate >= 50) {
                                            $colorClass = 'bg-info';
                                        } elseif ($rate >= 25) {
                                            $colorClass = 'bg-warning';
                                        }
                                        ?>
                                        <div class="progress-bar <?php echo $colorClass; ?>" 
                                             role="progressbar" 
                                             style="width: <?php echo $rate; ?>%;" 
                                             aria-valuenow="<?php echo $rate; ?>" 
                                             aria-valuemin="0" 
                                             aria-valuemax="100">
                                            %<?php echo number_format($rate, 2); ?>
                                        </div>
                                    </div>
                                </td>
                                <td>
                                    <div class="btn-group">
                                        <a href="index.php?page=city_profile&id=<?php echo $city['id']; ?>" class="btn btn-sm btn-primary">
                                            <i class="fas fa-eye"></i>
                                        </a>
                                        <a href="index.php?page=city_edit&id=<?php echo $city['id']; ?>" class="btn btn-sm btn-warning">
                                            <i class="fas fa-edit"></i>
                                        </a>
                                        <button class="btn btn-sm btn-info" onclick="updateCityRate(<?php echo $city['id']; ?>)">
                                            <i class="fas fa-sync"></i>
                                        </button>
                                        <button class="btn btn-sm btn-success" onclick="calculateCityAward(<?php echo $city['id']; ?>)">
                                            <i class="fas fa-medal"></i>
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<script>
// Bölge filtreleme
function filterByRegion(region) {
    window.location.href = 'index.php?page=cities&region=' + encodeURIComponent(region);
}

// Şehir oranını güncelleme
function updateCityRate(cityId) {
    if (confirm('Şehrin problem çözüm oranı güncellenecek. Devam etmek istiyor musunuz?')) {
        fetch('api/update_problem_solving_rate.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: 'city_id=' + cityId
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                alert('İşlem başarılı: ' + data.message);
                location.reload();
            } else {
                alert('Hata: ' + data.message);
            }
        })
        .catch(error => {
            console.error('Hata:', error);
            alert('İşlem sırasında bir hata oluştu.');
        });
    }
}

// Tüm şehirlerin oranlarını güncelleme
function updateAllRates() {
    if (confirm('Tüm şehirlerin problem çözüm oranları güncellenecek. Devam etmek istiyor musunuz?')) {
        fetch('api/update_problem_solving_rate.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: 'city_id=0' // 0 tüm şehirler anlamına gelir
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                alert('İşlem başarılı: ' + data.message);
                location.reload();
            } else {
                alert('Hata: ' + data.message);
            }
        })
        .catch(error => {
            console.error('Hata:', error);
            alert('İşlem sırasında bir hata oluştu.');
        });
    }
}

// Şehir ödülünü hesaplama
function calculateCityAward(cityId) {
    if (confirm('Şehrin ödül durumu hesaplanacak. Devam etmek istiyor musunuz?')) {
        fetch('api/calculate_city_award.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: 'city_id=' + cityId
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                alert('İşlem başarılı: ' + data.message);
                location.reload();
            } else {
                alert('Bilgi: ' + data.message);
            }
        })
        .catch(error => {
            console.error('Hata:', error);
            alert('İşlem sırasında bir hata oluştu.');
        });
    }
}

// Tüm şehirlerin ödüllerini hesaplama
function calculateAllAwards() {
    if (confirm('Tüm şehirlerin ödül durumları hesaplanacak. Bu işlem biraz zaman alabilir. Devam etmek istiyor musunuz?')) {
        // Burada tüm şehirleri getirip her biri için ödül hesaplaması yapabiliriz
        // Şimdilik bu özelliği eklemiyoruz
        alert('Bu özellik henüz uygulanmadı. Lütfen şehirlerin ödüllerini tek tek hesaplayın.');
    }
}

// Veri tablosunu başlat
document.addEventListener('DOMContentLoaded', function() {
    new DataTable('#citiesTable', {
        "language": {
            "url": "//cdn.datatables.net/plug-ins/1.10.25/i18n/Turkish.json"
        },
        "order": []
    });
});
</script>