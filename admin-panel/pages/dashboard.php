<?php
// İstatistik verileri (gerçek uygulamada veritabanından çekilecek)
$dailyStats = [
    'new_posts' => 12,
    'new_comments' => 32,
    'new_users' => 5,
    'resolved_issues' => 3
];

$monthlyStats = [
    'new_posts' => 176,
    'new_comments' => 528,
    'new_users' => 63,
    'resolved_issues' => 47
];

// Son 7 günlük veriler
$lastWeekPostData = [5, 8, 12, 7, 10, 15, 12];
$lastWeekCommentData = [15, 22, 32, 18, 25, 38, 32];
$lastWeekUserData = [3, 2, 5, 1, 4, 2, 5];
$lastWeekDates = [];
$today = new DateTime();

// Son 7 günün tarihlerini oluştur
for ($i = 6; $i >= 0; $i--) {
    $date = clone $today;
    $date->modify("-$i day");
    $lastWeekDates[] = $date->format('d.m');
}

// Şehirlere göre aktif şikayet dağılımı (mock veri)
$cityData = [
    ['name' => 'İstanbul', 'count' => 42],
    ['name' => 'Ankara', 'count' => 28],
    ['name' => 'İzmir', 'count' => 21],
    ['name' => 'Bursa', 'count' => 15],
    ['name' => 'Antalya', 'count' => 14],
    ['name' => 'Adana', 'count' => 12],
];

// En aktif kullanıcılar (mock veri)
$activeUsers = [
    ['id' => 1, 'name' => 'Ahmet Yılmaz', 'points' => 1850, 'level' => 'Şehir Uzmanı'],
    ['id' => 2, 'name' => 'Ayşe Demir', 'points' => 1230, 'level' => 'Şehir Aşığı'],
    ['id' => 3, 'name' => 'Mehmet Kaya', 'points' => 980, 'level' => 'Şehir Sevdalısı'],
    ['id' => 4, 'name' => 'Zeynep Şahin', 'points' => 760, 'level' => 'Şehir Sevdalısı'],
    ['id' => 5, 'name' => 'Mustafa Öztürk', 'points' => 425, 'level' => 'Şehrini Seven'],
];

// Kategori dağılımı (mock veri)
$categoryData = [
    ['name' => 'Altyapı', 'count' => 35],
    ['name' => 'Çevre Temizliği', 'count' => 28],
    ['name' => 'Ulaşım', 'count' => 23],
    ['name' => 'Park ve Bahçeler', 'count' => 17],
    ['name' => 'Güvenlik', 'count' => 14],
    ['name' => 'Diğer', 'count' => 10],
];

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