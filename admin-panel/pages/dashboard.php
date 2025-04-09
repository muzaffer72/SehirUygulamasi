<?php
// PostgreSQL veritabanından veri çekme
require_once __DIR__ . '/../db_config.php';

// İstatistik verilerini hesapla
// Bugünün tarihi
$today = new DateTime();
$todayDate = $today->format('Y-m-d');
$thirtyDaysAgo = (clone $today)->modify('-30 days')->format('Y-m-d');

// Günlük istatistikler - gerçek veri yoksa varsayılan değerleri kullan
try {
    // Günlük yeni paylaşımlar
    $stmt = $pdo->prepare("SELECT COUNT(*) FROM posts WHERE DATE(created_at) = CURRENT_DATE");
    $stmt->execute();
    $dailyNewPosts = $stmt->fetchColumn() ?: 0;
    
    // Günlük yeni yorumlar
    $stmt = $pdo->prepare("SELECT COUNT(*) FROM comments WHERE DATE(created_at) = CURRENT_DATE");
    $stmt->execute();
    $dailyNewComments = $stmt->fetchColumn() ?: 0;
    
    // Günlük yeni kullanıcılar
    $stmt = $pdo->prepare("SELECT COUNT(*) FROM users WHERE DATE(created_at) = CURRENT_DATE");
    $stmt->execute();
    $dailyNewUsers = $stmt->fetchColumn() ?: 0;
    
    // Günlük çözülen sorunlar
    $stmt = $pdo->prepare("SELECT COUNT(*) FROM posts WHERE DATE(created_at) = CURRENT_DATE AND status = 'solved'");
    $stmt->execute();
    $dailyResolvedIssues = $stmt->fetchColumn() ?: 0;
    
    // Aylık istatistikler
    // Aylık yeni paylaşımlar
    $stmt = $pdo->prepare("SELECT COUNT(*) FROM posts WHERE created_at >= :thirtyDaysAgo");
    $stmt->bindParam(':thirtyDaysAgo', $thirtyDaysAgo);
    $stmt->execute();
    $monthlyNewPosts = $stmt->fetchColumn() ?: 0;
    
    // Aylık yeni yorumlar
    $stmt = $pdo->prepare("SELECT COUNT(*) FROM comments WHERE created_at >= :thirtyDaysAgo");
    $stmt->bindParam(':thirtyDaysAgo', $thirtyDaysAgo);
    $stmt->execute();
    $monthlyNewComments = $stmt->fetchColumn() ?: 0;
    
    // Aylık yeni kullanıcılar
    $stmt = $pdo->prepare("SELECT COUNT(*) FROM users WHERE created_at >= :thirtyDaysAgo");
    $stmt->bindParam(':thirtyDaysAgo', $thirtyDaysAgo);
    $stmt->execute();
    $monthlyNewUsers = $stmt->fetchColumn() ?: 0;
    
    // Aylık çözülen sorunlar
    $stmt = $pdo->prepare("SELECT COUNT(*) FROM posts WHERE created_at >= :thirtyDaysAgo AND status = 'solved'");
    $stmt->bindParam(':thirtyDaysAgo', $thirtyDaysAgo);
    $stmt->execute();
    $monthlyResolvedIssues = $stmt->fetchColumn() ?: 0;
} catch (PDOException $e) {
    // Hata durumunda varsayılan değerler
    $dailyNewPosts = 0;
    $dailyNewComments = 0;
    $dailyNewUsers = 0;
    $dailyResolvedIssues = 0;
    $monthlyNewPosts = 0;
    $monthlyNewComments = 0;
    $monthlyNewUsers = 0;
    $monthlyResolvedIssues = 0;
}

$dailyStats = [
    'new_posts' => $dailyNewPosts,
    'new_comments' => $dailyNewComments,
    'new_users' => $dailyNewUsers,
    'resolved_issues' => $dailyResolvedIssues
];

$monthlyStats = [
    'new_posts' => $monthlyNewPosts,
    'new_comments' => $monthlyNewComments,
    'new_users' => $monthlyNewUsers,
    'resolved_issues' => $monthlyResolvedIssues
];

// Son 7 günlük veriler
$lastWeekPostData = [];
$lastWeekCommentData = [];
$lastWeekUserData = [];
$lastWeekDates = [];

try {
    // Son 7 günün tarihlerini oluştur
    for ($i = 6; $i >= 0; $i--) {
        $date = clone $today;
        $date->modify("-$i day");
        $lastWeekDates[] = $date->format('d.m');
        
        $dayDate = $date->format('Y-m-d');
        
        // Günlük paylaşımlar
        $stmt = $pdo->prepare("SELECT COUNT(*) FROM posts WHERE DATE(created_at) = :dayDate");
        $stmt->bindParam(':dayDate', $dayDate);
        $stmt->execute();
        $lastWeekPostData[] = $stmt->fetchColumn() ?: 0;
        
        // Günlük yorumlar
        $stmt = $pdo->prepare("SELECT COUNT(*) FROM comments WHERE DATE(created_at) = :dayDate");
        $stmt->bindParam(':dayDate', $dayDate);
        $stmt->execute();
        $lastWeekCommentData[] = $stmt->fetchColumn() ?: 0;
        
        // Günlük kullanıcılar
        $stmt = $pdo->prepare("SELECT COUNT(*) FROM users WHERE DATE(created_at) = :dayDate");
        $stmt->bindParam(':dayDate', $dayDate);
        $stmt->execute();
        $lastWeekUserData[] = $stmt->fetchColumn() ?: 0;
    }
} catch (PDOException $e) {
    // Hata durumunda varsayılan 7 günlük veriler
    $lastWeekPostData = [0, 0, 0, 0, 0, 0, 0];
    $lastWeekCommentData = [0, 0, 0, 0, 0, 0, 0];
    $lastWeekUserData = [0, 0, 0, 0, 0, 0, 0];
}

// Şehirlere göre aktif şikayet dağılımı
try {
    $stmt = $pdo->query("SELECT c.name, COUNT(p.id) as count 
                         FROM posts p 
                         JOIN cities c ON p.city_id = c.id 
                         WHERE p.status = 'awaitingSolution' OR p.status = 'inProgress'
                         GROUP BY c.name 
                         ORDER BY count DESC 
                         LIMIT 6");
    $cityData = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    if (empty($cityData)) {
        // Eğer veri yoksa default veriler
        $cityData = [
            ['name' => 'İstanbul', 'count' => 0],
            ['name' => 'Ankara', 'count' => 0],
            ['name' => 'İzmir', 'count' => 0],
            ['name' => 'Bursa', 'count' => 0],
            ['name' => 'Antalya', 'count' => 0]
        ];
    }
} catch (PDOException $e) {
    // Hata durumunda varsayılan şehir verileri
    $cityData = [
        ['name' => 'İstanbul', 'count' => 0],
        ['name' => 'Ankara', 'count' => 0],
        ['name' => 'İzmir', 'count' => 0],
        ['name' => 'Bursa', 'count' => 0],
        ['name' => 'Antalya', 'count' => 0]
    ];
}

// En aktif kullanıcılar
try {
    $stmt = $pdo->query("SELECT id, name, points, level FROM users ORDER BY points DESC LIMIT 5");
    $activeUsers = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    if (empty($activeUsers)) {
        // Eğer veri yoksa en az admin kullanıcısı var
        $stmt = $pdo->query("SELECT id, name, points, level FROM users LIMIT 1");
        $adminUser = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($adminUser) {
            $activeUsers = [$adminUser];
        } else {
            $activeUsers = [['id' => 0, 'name' => 'Henüz Kullanıcı Yok', 'points' => 0, 'level' => 'N/A']];
        }
    }
} catch (PDOException $e) {
    // Hata durumunda varsayılan kullanıcılar
    $activeUsers = [['id' => 0, 'name' => 'Veri Yüklenemedi', 'points' => 0, 'level' => 'N/A']];
}

// Kategori dağılımı
try {
    $stmt = $pdo->query("SELECT c.name, COUNT(p.id) as count 
                         FROM posts p 
                         JOIN categories c ON p.category_id = c.id 
                         GROUP BY c.name 
                         ORDER BY count DESC 
                         LIMIT 6");
    $categoryData = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    if (empty($categoryData)) {
        // Eğer veri yoksa mevcut kategorileri göster (0 sayısı ile)
        $stmt = $pdo->query("SELECT name, 0 as count FROM categories LIMIT 6");
        $categoryData = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        if (empty($categoryData)) {
            $categoryData = [['name' => 'Veri Yok', 'count' => 0]];
        }
    }
} catch (PDOException $e) {
    // Hata durumunda varsayılan kategoriler
    $categoryData = [['name' => 'Veri Yüklenemedi', 'count' => 0]];
}

// JSON formatında verileri hazırla
$weeklyPostsJson = json_encode($lastWeekPostData);
$weeklyCommentsJson = json_encode($lastWeekCommentData);
$weeklyUsersJson = json_encode($lastWeekUserData);
$weeklyDatesJson = json_encode($lastWeekDates);

// Şehir dağılımı için veri hazırla
$cityLabels = [];
$cityCounts = [];
foreach ($cityData as $city) {
    $cityLabels[] = $city['name'];
    $cityCounts[] = $city['count'];
}
$cityLabelsJson = json_encode($cityLabels);
$cityCountsJson = json_encode($cityCounts);

// Kategori dağılımı için veri hazırla
$categoryLabels = [];
$categoryCounts = [];
foreach ($categoryData as $category) {
    $categoryLabels[] = $category['name'];
    $categoryCounts[] = $category['count'];
}
$categoryLabelsJson = json_encode($categoryLabels);
$categoryCountsJson = json_encode($categoryCounts);
?>

<div class="container-fluid">
    <h1 class="h3 mb-4 text-gray-800">İstatistikler</h1>
    
    <!-- Günlük İstatistik Kartları -->
    <div class="row">
        <div class="col-xl-3 col-md-6 mb-4">
            <div class="card border-left-primary shadow h-100 py-2">
                <div class="card-body">
                    <div class="row no-gutters align-items-center">
                        <div class="col mr-2">
                            <div class="text-xs font-weight-bold text-primary text-uppercase mb-1">
                                Günlük Yeni Paylaşımlar</div>
                            <div class="h5 mb-0 font-weight-bold text-gray-800"><?= $dailyStats['new_posts'] ?></div>
                        </div>
                        <div class="col-auto">
                            <i class="fas fa-clipboard-list fa-2x text-gray-300"></i>
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
                                Günlük Yeni Yorumlar</div>
                            <div class="h5 mb-0 font-weight-bold text-gray-800"><?= $dailyStats['new_comments'] ?></div>
                        </div>
                        <div class="col-auto">
                            <i class="fas fa-comments fa-2x text-gray-300"></i>
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
                                Günlük Yeni Kullanıcılar</div>
                            <div class="h5 mb-0 font-weight-bold text-gray-800"><?= $dailyStats['new_users'] ?></div>
                        </div>
                        <div class="col-auto">
                            <i class="fas fa-user-plus fa-2x text-gray-300"></i>
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
                                Günlük Çözülen Sorunlar</div>
                            <div class="h5 mb-0 font-weight-bold text-gray-800"><?= $dailyStats['resolved_issues'] ?></div>
                        </div>
                        <div class="col-auto">
                            <i class="fas fa-check-circle fa-2x text-gray-300"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Aylık İstatistik Kartları -->
    <div class="row">
        <div class="col-xl-3 col-md-6 mb-4">
            <div class="card border-left-primary shadow h-100 py-2">
                <div class="card-body">
                    <div class="row no-gutters align-items-center">
                        <div class="col mr-2">
                            <div class="text-xs font-weight-bold text-primary text-uppercase mb-1">
                                Aylık Paylaşımlar</div>
                            <div class="h5 mb-0 font-weight-bold text-gray-800"><?= $monthlyStats['new_posts'] ?></div>
                        </div>
                        <div class="col-auto">
                            <i class="fas fa-calendar fa-2x text-gray-300"></i>
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
                                Aylık Yorumlar</div>
                            <div class="h5 mb-0 font-weight-bold text-gray-800"><?= $monthlyStats['new_comments'] ?></div>
                        </div>
                        <div class="col-auto">
                            <i class="fas fa-comments fa-2x text-gray-300"></i>
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
                                Aylık Yeni Kullanıcılar</div>
                            <div class="h5 mb-0 font-weight-bold text-gray-800"><?= $monthlyStats['new_users'] ?></div>
                        </div>
                        <div class="col-auto">
                            <i class="fas fa-users fa-2x text-gray-300"></i>
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
                                Aylık Çözülen Sorunlar</div>
                            <div class="h5 mb-0 font-weight-bold text-gray-800"><?= $monthlyStats['resolved_issues'] ?></div>
                        </div>
                        <div class="col-auto">
                            <i class="fas fa-check-double fa-2x text-gray-300"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Grafikler -->
    <div class="row">
        <!-- Haftalık Aktivite Grafiği -->
        <div class="col-xl-8 col-lg-7">
            <div class="card shadow mb-4">
                <div class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
                    <h6 class="m-0 font-weight-bold text-primary">Haftalık Aktivite</h6>
                </div>
                <div class="card-body">
                    <div class="chart-area">
                        <canvas id="weeklyActivityChart"></canvas>
                    </div>
                </div>
            </div>
        </div>

        <!-- Şehir Dağılımı Pasta Grafiği -->
        <div class="col-xl-4 col-lg-5">
            <div class="card shadow mb-4">
                <div class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
                    <h6 class="m-0 font-weight-bold text-primary">Şehir Dağılımı</h6>
                </div>
                <div class="card-body">
                    <div class="chart-pie pt-4 pb-2">
                        <canvas id="cityDistributionChart"></canvas>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="row">
        <!-- Kategori Dağılımı Grafiği -->
        <div class="col-xl-6 col-lg-6">
            <div class="card shadow mb-4">
                <div class="card-header py-3">
                    <h6 class="m-0 font-weight-bold text-primary">Kategori Dağılımı</h6>
                </div>
                <div class="card-body">
                    <div class="chart-bar">
                        <canvas id="categoryDistributionChart"></canvas>
                    </div>
                </div>
            </div>
        </div>

        <!-- En Aktif Kullanıcılar -->
        <div class="col-xl-6 col-lg-6">
            <div class="card shadow mb-4">
                <div class="card-header py-3">
                    <h6 class="m-0 font-weight-bold text-primary">En Aktif Kullanıcılar</h6>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-bordered" width="100%" cellspacing="0">
                            <thead>
                                <tr>
                                    <th>Kullanıcı</th>
                                    <th>Puan</th>
                                    <th>Seviye</th>
                                </tr>
                            </thead>
                            <tbody>
                                <?php foreach ($activeUsers as $user): ?>
                                <tr>
                                    <td><?= $user['name'] ?></td>
                                    <td><?= $user['points'] ?></td>
                                    <td><?= $user['level'] ?></td>
                                </tr>
                                <?php endforeach; ?>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Chart.js Kütüphanesi -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<!-- Chart.js Scriptleri -->
<script>
    document.addEventListener('DOMContentLoaded', function() {
        // Haftalık Aktivite Grafiği
        var weeklyCtx = document.getElementById('weeklyActivityChart').getContext('2d');
        var weeklyActivityChart = new Chart(weeklyCtx, {
            type: 'line',
            data: {
                labels: <?= $weeklyDatesJson ?>,
                datasets: [{
                    label: 'Paylaşımlar',
                    data: <?= $weeklyPostsJson ?>,
                    backgroundColor: 'rgba(78, 115, 223, 0.05)',
                    borderColor: 'rgba(78, 115, 223, 1)',
                    pointBackgroundColor: 'rgba(78, 115, 223, 1)',
                    pointBorderColor: '#fff',
                    pointHoverBackgroundColor: '#fff',
                    pointHoverBorderColor: 'rgba(78, 115, 223, 1)',
                    fill: true
                }, {
                    label: 'Yorumlar',
                    data: <?= $weeklyCommentsJson ?>,
                    backgroundColor: 'rgba(28, 200, 138, 0.05)',
                    borderColor: 'rgba(28, 200, 138, 1)',
                    pointBackgroundColor: 'rgba(28, 200, 138, 1)',
                    pointBorderColor: '#fff',
                    pointHoverBackgroundColor: '#fff',
                    pointHoverBorderColor: 'rgba(28, 200, 138, 1)',
                    fill: true
                }, {
                    label: 'Yeni Kullanıcılar',
                    data: <?= $weeklyUsersJson ?>,
                    backgroundColor: 'rgba(54, 185, 204, 0.05)',
                    borderColor: 'rgba(54, 185, 204, 1)',
                    pointBackgroundColor: 'rgba(54, 185, 204, 1)',
                    pointBorderColor: '#fff',
                    pointHoverBackgroundColor: '#fff',
                    pointHoverBorderColor: 'rgba(54, 185, 204, 1)',
                    fill: true
                }]
            },
            options: {
                maintainAspectRatio: false,
                responsive: true,
                scales: {
                    y: {
                        beginAtZero: true
                    }
                }
            }
        });

        // Şehir Dağılımı Pasta Grafiği
        var cityCtx = document.getElementById('cityDistributionChart').getContext('2d');
        var cityDistributionChart = new Chart(cityCtx, {
            type: 'doughnut',
            data: {
                labels: <?= $cityLabelsJson ?>,
                datasets: [{
                    data: <?= $cityCountsJson ?>,
                    backgroundColor: [
                        '#4e73df', '#1cc88a', '#36b9cc', '#f6c23e', '#e74a3b', '#858796'
                    ],
                    hoverBackgroundColor: [
                        '#2e59d9', '#17a673', '#2c9faf', '#f4b619', '#e02d1b', '#6e707e'
                    ],
                    hoverBorderColor: "rgba(234, 236, 244, 1)",
                }]
            },
            options: {
                maintainAspectRatio: false,
                responsive: true,
                plugins: {
                    legend: {
                        position: 'right'
                    }
                }
            }
        });

        // Kategori Dağılımı Çubuk Grafiği
        var categoryCtx = document.getElementById('categoryDistributionChart').getContext('2d');
        var categoryDistributionChart = new Chart(categoryCtx, {
            type: 'bar',
            data: {
                labels: <?= $categoryLabelsJson ?>,
                datasets: [{
                    label: 'Şikayet Sayısı',
                    data: <?= $categoryCountsJson ?>,
                    backgroundColor: [
                        'rgba(78, 115, 223, 0.7)',
                        'rgba(28, 200, 138, 0.7)',
                        'rgba(54, 185, 204, 0.7)',
                        'rgba(246, 194, 62, 0.7)',
                        'rgba(231, 74, 59, 0.7)',
                        'rgba(133, 135, 150, 0.7)'
                    ],
                    borderWidth: 1
                }]
            },
            options: {
                maintainAspectRatio: false,
                responsive: true,
                scales: {
                    y: {
                        beginAtZero: true
                    }
                }
            }
        });
    });
</script>