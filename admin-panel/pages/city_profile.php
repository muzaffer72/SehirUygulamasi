<?php
// Yetki kontrolü
requireAdmin();

// Şehir ID'si
$cityId = isset($_GET['id']) ? intval($_GET['id']) : 0;

if ($cityId <= 0) {
    echo '<div class="alert alert-danger">Geçersiz şehir ID\'si!</div>';
    exit;
}

// Şehir bilgilerini getir
$query = "SELECT c.*, 
            COALESCE(c.problem_solving_rate, 0) as problem_solving_rate,
            COUNT(DISTINCT p.id) as total_posts,
            SUM(CASE WHEN p.status = 'solved' THEN 1 ELSE 0 END) as solved_posts,
            SUM(CASE WHEN p.status = 'awaitingSolution' THEN 1 ELSE 0 END) as pending_posts,
            SUM(CASE WHEN p.status = 'inProgress' THEN 1 ELSE 0 END) as in_progress_posts,
            SUM(CASE WHEN p.status = 'rejected' THEN 1 ELSE 0 END) as rejected_posts
          FROM cities c
          LEFT JOIN posts p ON c.id = p.city_id
          WHERE c.id = ?
          GROUP BY c.id";

$stmt = $pdo->prepare($query);
$stmt->execute([$cityId]);
$city = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$city) {
    echo '<div class="alert alert-danger">Şehir bulunamadı!</div>';
    exit;
}

// Şehrin aldığı ödülleri getir - PostgreSQL uyumluluk sorunu çözüldü
// is_active sütunu olmadan sorgu
$query = "SELECT ca.*, at.name as award_name, at.description as award_description, 
          at.color, at.badge_color, at.icon, at.min_rate, at.max_rate
         FROM city_awards ca
         JOIN award_types at ON ca.award_type_id = at.id
         WHERE ca.city_id = ?
         ORDER BY ca.award_date DESC";

$stmt = $pdo->prepare($query);
$stmt->execute([$cityId]);
$cityAwards = $stmt->fetchAll(PDO::FETCH_ASSOC);

// Şehrin hizmetlerini getir
$query = "SELECT cs.*
          FROM city_services cs
          WHERE cs.city_id = ?
          ORDER BY cs.name ASC";

$stmt = $pdo->prepare($query);
$stmt->execute([$cityId]);
$cityServices = $stmt->fetchAll(PDO::FETCH_ASSOC);

// Şehrin projelerini getir
$query = "SELECT cp.*
          FROM city_projects cp
          WHERE cp.city_id = ?
          ORDER BY cp.start_date DESC";

$stmt = $pdo->prepare($query);
$stmt->execute([$cityId]);
$cityProjects = $stmt->fetchAll(PDO::FETCH_ASSOC);

// Son 30 gündeki şikayetleri getir
$query = "SELECT DATE(p.created_at) as date, COUNT(*) as count, 
            SUM(CASE WHEN p.status = 'solved' THEN 1 ELSE 0 END) as solved_count
          FROM posts p
          WHERE p.city_id = ? AND p.created_at >= CURRENT_DATE - INTERVAL '30 days'
          GROUP BY DATE(p.created_at)
          ORDER BY date ASC";

$stmt = $pdo->prepare($query);
$stmt->execute([$cityId]);
$recentStats = $stmt->fetchAll(PDO::FETCH_ASSOC);

// İstatistik verilerini hazırla
$dates = [];
$complaints = [];
$solved = [];

foreach ($recentStats as $stat) {
    $dates[] = date('d M', strtotime($stat['date']));
    $complaints[] = intval($stat['count']);
    $solved[] = intval($stat['solved_count']);
}

// Grafik verileri
$statsData = [
    'labels' => $dates,
    'datasets' => [
        [
            'label' => 'Şikayet Sayısı',
            'data' => $complaints,
            'backgroundColor' => 'rgba(54, 162, 235, 0.2)',
            'borderColor' => 'rgba(54, 162, 235, 1)',
            'borderWidth' => 1
        ],
        [
            'label' => 'Çözülen Şikayet',
            'data' => $solved,
            'backgroundColor' => 'rgba(75, 192, 192, 0.2)',
            'borderColor' => 'rgba(75, 192, 192, 1)',
            'borderWidth' => 1
        ]
    ]
];
?>

<div class="container-fluid px-4">
    <h1 class="mt-4"><?php echo htmlspecialchars($city['name']); ?> Profili</h1>
    <ol class="breadcrumb mb-4">
        <li class="breadcrumb-item"><a href="index.php">Ana Sayfa</a></li>
        <li class="breadcrumb-item active"><?php echo htmlspecialchars($city['name']); ?></li>
    </ol>
    
    <div class="row">
        <div class="col-xl-8">
            <div class="card mb-4">
                <div class="card-header">
                    <i class="fas fa-city me-1"></i>
                    Şehir Bilgileri
                    <?php if (!empty($cityAwards)): ?>
                        <?php foreach ($cityAwards as $award): ?>
                            <span class="badge ms-2" style="background-color: <?php echo htmlspecialchars($award['badge_color']); ?>">
                                <?php echo htmlspecialchars($award['award_name']); ?>
                            </span>
                        <?php endforeach; ?>
                    <?php endif; ?>
                </div>
                <div class="card-body">
                    <div class="row">
                        <div class="col-md-6">
                            <h5>Genel Bilgiler</h5>
                            <p><strong>Plaka:</strong> <?php echo htmlspecialchars($city['plate_number'] ?? 'Belirtilmemiş'); ?></p>
                            <p><strong>Bölge:</strong> Belirtilmemiş</p>
                            <p><strong>Şikayet Çözüm Oranı:</strong> %<?php echo number_format($city['problem_solving_rate'], 2); ?></p>
                        </div>
                        <div class="col-md-6">
                            <h5>Şikayet İstatistikleri</h5>
                            <p><strong>Toplam Şikayet:</strong> <?php echo $city['total_posts']; ?></p>
                            <p><strong>Çözülen Şikayet:</strong> <?php echo $city['solved_posts']; ?></p>
                            <p><strong>Bekleyen Şikayet:</strong> <?php echo $city['pending_posts']; ?></p>
                            <p><strong>İşlem Görenler:</strong> <?php echo $city['in_progress_posts']; ?></p>
                            <p><strong>Reddedilenler:</strong> <?php echo $city['rejected_posts']; ?></p>
                        </div>
                    </div>
                    
                    <?php if (!empty($cityAwards)): ?>
                    <div class="row mt-4">
                        <div class="col-12">
                            <h5>Belediye Ödülleri</h5>
                            <div class="table-responsive">
                                <table class="table table-bordered">
                                    <thead>
                                        <tr>
                                            <th>Ödül</th>
                                            <th>Açıklama</th>
                                            <th>Veriliş Tarihi</th>
                                            <th>Geçerlilik</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <?php foreach ($cityAwards as $award): ?>
                                        <tr>
                                            <td>
                                                <span class="badge" style="background-color: <?php echo htmlspecialchars($award['badge_color']); ?>">
                                                    <?php echo htmlspecialchars($award['award_name']); ?>
                                                </span>
                                            </td>
                                            <td><?php echo htmlspecialchars($award['award_description']); ?></td>
                                            <td><?php echo date('d.m.Y', strtotime($award['award_date'])); ?></td>
                                            <td>
                                                <?php if ($award['expiry_date']): ?>
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
                    </div>
                    <?php endif; ?>
                </div>
            </div>
        </div>
        <div class="col-xl-4">
            <div class="card mb-4">
                <div class="card-header">
                    <i class="fas fa-chart-pie me-1"></i>
                    Şikayet Çözüm Oranı
                </div>
                <div class="card-body">
                    <div class="d-flex justify-content-center">
                        <div class="position-relative" style="height: 200px; width: 200px;">
                            <canvas id="solutionRateChart"></canvas>
                            <div class="position-absolute top-50 start-50 translate-middle text-center">
                                <h3 class="mb-0">%<?php echo number_format($city['problem_solving_rate'], 0); ?></h3>
                                <small>Çözüm Oranı</small>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="card mb-4">
                <div class="card-header">
                    <i class="fas fa-cogs me-1"></i>
                    Hızlı İşlemler
                </div>
                <div class="card-body">
                    <div class="list-group">
                        <a href="index.php?page=posts&city_id=<?php echo $cityId; ?>" class="list-group-item list-group-item-action">
                            <i class="fas fa-clipboard-list me-2"></i> Şehrin Şikayetlerini Görüntüle
                        </a>
                        <a href="#" class="list-group-item list-group-item-action" onclick="calculateAward(<?php echo $cityId; ?>)">
                            <i class="fas fa-medal me-2"></i> Ödül Durumunu Kontrol Et
                        </a>
                        <a href="#" class="list-group-item list-group-item-action" onclick="updateProblemSolvingRate(<?php echo $cityId; ?>)">
                            <i class="fas fa-sync me-2"></i> Çözüm Oranını Güncelle
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <div class="row">
        <div class="col-12">
            <div class="card mb-4">
                <div class="card-header">
                    <i class="fas fa-chart-bar me-1"></i>
                    Son 30 Gün Şikayet İstatistikleri
                </div>
                <div class="card-body">
                    <canvas id="monthlyStatsChart" height="100"></canvas>
                </div>
            </div>
        </div>
    </div>
    
    <div class="row">
        <div class="col-md-6">
            <div class="card mb-4">
                <div class="card-header">
                    <i class="fas fa-hand-holding-heart me-1"></i>
                    Belediye Hizmetleri
                </div>
                <div class="card-body">
                    <?php if (empty($cityServices)): ?>
                        <div class="alert alert-info">Henüz hizmet bilgisi girilmemiş.</div>
                    <?php else: ?>
                        <div class="list-group">
                            <?php foreach ($cityServices as $service): ?>
                                <div class="list-group-item">
                                    <h5 class="mb-1"><?php echo htmlspecialchars($service['name']); ?></h5>
                                    <p class="mb-1"><?php echo htmlspecialchars($service['description']); ?></p>
                                </div>
                            <?php endforeach; ?>
                        </div>
                    <?php endif; ?>
                </div>
            </div>
        </div>
        <div class="col-md-6">
            <div class="card mb-4">
                <div class="card-header">
                    <i class="fas fa-tasks me-1"></i>
                    Belediye Projeleri
                </div>
                <div class="card-body">
                    <?php if (empty($cityProjects)): ?>
                        <div class="alert alert-info">Henüz proje bilgisi girilmemiş.</div>
                    <?php else: ?>
                        <div class="list-group">
                            <?php foreach ($cityProjects as $project): ?>
                                <div class="list-group-item">
                                    <h5 class="mb-1"><?php echo htmlspecialchars($project['title']); ?></h5>
                                    <p class="mb-1"><?php echo htmlspecialchars($project['description']); ?></p>
                                    <?php if ($project['start_date'] && $project['end_date']): ?>
                                        <small>
                                            <?php echo date('d.m.Y', strtotime($project['start_date'])); ?> - 
                                            <?php echo date('d.m.Y', strtotime($project['end_date'])); ?>
                                        </small>
                                    <?php endif; ?>
                                </div>
                            <?php endforeach; ?>
                        </div>
                    <?php endif; ?>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
// Çözüm oranı pasta grafiği
document.addEventListener('DOMContentLoaded', function() {
    // Çözüm oranı grafiği
    var solutionCtx = document.getElementById('solutionRateChart').getContext('2d');
    var solutionRate = <?php echo $city['problem_solving_rate']; ?>;
    
    new Chart(solutionCtx, {
        type: 'doughnut',
        data: {
            datasets: [{
                data: [solutionRate, 100 - solutionRate],
                backgroundColor: [
                    'rgba(75, 192, 192, 0.8)',
                    'rgba(201, 203, 207, 0.3)'
                ],
                borderWidth: 0
            }]
        },
        options: {
            cutout: '75%',
            plugins: {
                legend: {
                    display: false
                },
                tooltip: {
                    enabled: false
                }
            },
            animation: {
                animateRotate: true
            }
        }
    });
    
    // Aylık istatistik grafiği
    var monthlyCtx = document.getElementById('monthlyStatsChart').getContext('2d');
    var statsData = <?php echo json_encode($statsData); ?>;
    
    new Chart(monthlyCtx, {
        type: 'bar',
        data: statsData,
        options: {
            scales: {
                y: {
                    beginAtZero: true
                }
            },
            responsive: true,
            maintainAspectRatio: false
        }
    });
});

// Ödül durumunu kontrol etme fonksiyonu
function calculateAward(cityId) {
    if (confirm('Şehrin ödül durumu kontrol edilecek. Devam etmek istiyor musunuz?')) {
        // AJAX isteği gönder
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
                alert('Hata: ' + data.message);
            }
        })
        .catch(error => {
            console.error('Hata:', error);
            alert('İşlem sırasında bir hata oluştu.');
        });
    }
}

// Çözüm oranını güncelleme fonksiyonu
function updateProblemSolvingRate(cityId) {
    if (confirm('Şehrin problem çözüm oranı güncellenecek. Devam etmek istiyor musunuz?')) {
        // AJAX isteği gönder
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
</script>