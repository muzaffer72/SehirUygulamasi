<?php
// Simple admin panel for ŞikayetVar application

session_start();

// Database connection
require_once 'db_config.php';

// Configuration
$config = [
    'admin_user' => 'admin',
    'admin_pass' => 'admin123' // In a production environment, use hashed passwords
];

// Mock data (would come from the database in a real application)
$posts = [
    [
        'id' => 1,
        'title' => 'Sokak lambası çalışmıyor',
        'content' => 'Evimin önündeki sokak lambası 3 gündür çalışmıyor. Akşamları dışarı çıkmak tehlikeli oluyor.',
        'user_id' => 2,
        'city_id' => 34, // İstanbul
        'district_id' => 4, // Beşiktaş
        'category_id' => 1, // Altyapı
        'status' => 'inProgress',
        'likes' => 25,
        'highlights' => 5,
        'created_at' => '2024-01-15 14:30:00'
    ],
    [
        'id' => 2,
        'title' => 'Çöpler toplanmıyor',
        'content' => 'Mahallemizde çöpler düzenli toplanmıyor. Kötü koku ve sağlık sorunlarına yol açıyor.',
        'user_id' => 3,
        'city_id' => 6, // Ankara
        'district_id' => 12, // Çankaya
        'category_id' => 2, // Temizlik
        'status' => 'awaitingSolution',
        'likes' => 42,
        'highlights' => 12,
        'created_at' => '2024-01-20 09:15:00'
    ],
    [
        'id' => 3,
        'title' => 'Otobüs durağı hasarlı',
        'content' => 'Ana caddedeki otobüs durağının camları kırık ve oturacak yerler hasarlı. Yağmurlu havalarda beklemek imkansız oluyor.',
        'user_id' => 1,
        'city_id' => 35, // İzmir
        'district_id' => 18, // Konak
        'category_id' => 3, // Ulaşım
        'status' => 'solved',
        'likes' => 18,
        'highlights' => 3,
        'created_at' => '2024-01-25 16:45:00'
    ],
];

$users = [
    [
        'id' => 1,
        'name' => 'Ahmet Yılmaz',
        'email' => 'ahmet@example.com',
        'is_verified' => true,
        'city_id' => 35,
        'district_id' => 18,
        'created_at' => '2023-12-01 10:00:00'
    ],
    [
        'id' => 2,
        'name' => 'Ayşe Kaya',
        'email' => 'ayse@example.com',
        'is_verified' => true,
        'city_id' => 34,
        'district_id' => 4,
        'created_at' => '2023-12-05 14:30:00'
    ],
    [
        'id' => 3,
        'name' => 'Mehmet Demir',
        'email' => 'mehmet@example.com',
        'is_verified' => false,
        'city_id' => 6,
        'district_id' => 12,
        'created_at' => '2023-12-10 09:15:00'
    ],
];

$surveys = [
    [
        'id' => 1,
        'title' => 'Yeni park projesi',
        'description' => 'Mahallemize yapılacak yeni park için hangisi daha uygun olur?',
        'city_id' => 34,
        'category_id' => 4,
        'is_active' => true,
        'start_date' => '2024-02-01',
        'end_date' => '2024-03-01',
        'total_votes' => 125,
        'options' => [
            ['id' => 1, 'text' => 'Çocuk oyun alanları ağırlıklı park', 'vote_count' => 75],
            ['id' => 2, 'text' => 'Spor alanları ağırlıklı park', 'vote_count' => 35],
            ['id' => 3, 'text' => 'Piknik alanları ağırlıklı park', 'vote_count' => 15]
        ]
    ],
    [
        'id' => 2,
        'title' => 'Toplu taşıma saatleri',
        'description' => 'Otobüs seferlerinin hangi saatlerde artırılmasını istersiniz?',
        'city_id' => 6,
        'category_id' => 3,
        'is_active' => true,
        'start_date' => '2024-02-15',
        'end_date' => '2024-03-15',
        'total_votes' => 210,
        'options' => [
            ['id' => 1, 'text' => 'Sabah (07:00-09:00)', 'vote_count' => 95],
            ['id' => 2, 'text' => 'Öğle (12:00-14:00)', 'vote_count' => 25],
            ['id' => 3, 'text' => 'Akşam (17:00-19:00)', 'vote_count' => 90]
        ]
    ]
];

$cities = [
    ['id' => 6, 'name' => 'Ankara'],
    ['id' => 34, 'name' => 'İstanbul'],
    ['id' => 35, 'name' => 'İzmir']
];

$districts = [
    ['id' => 4, 'name' => 'Beşiktaş', 'city_id' => 34],
    ['id' => 12, 'name' => 'Çankaya', 'city_id' => 6],
    ['id' => 18, 'name' => 'Konak', 'city_id' => 35]
];

$categories = [
    ['id' => 1, 'name' => 'Altyapı', 'icon_name' => 'build'],
    ['id' => 2, 'name' => 'Temizlik', 'icon_name' => 'cleaning_services'],
    ['id' => 3, 'name' => 'Ulaşım', 'icon_name' => 'directions_bus'],
    ['id' => 4, 'name' => 'Park ve Bahçeler', 'icon_name' => 'nature']
];

// Authentication
if (isset($_POST['login'])) {
    $username = $_POST['username'] ?? '';
    $password = $_POST['password'] ?? '';
    
    if ($username === $config['admin_user'] && $password === $config['admin_pass']) {
        $_SESSION['user'] = $config['admin_user'];
        $_SESSION['login_time'] = time();
    } else {
        $login_error = 'Geçersiz kullanıcı adı veya şifre.';
    }
}

if (isset($_GET['logout'])) {
    session_destroy();
    header('Location: index.php');
    exit;
}

// Handle actions
if (isset($_POST['update_post_status'])) {
    $post_id = $_POST['post_id'] ?? 0;
    $new_status = $_POST['status'] ?? '';
    
    // In a real app, update the database
    foreach ($posts as &$post) {
        if ($post['id'] == $post_id) {
            $post['status'] = $new_status;
            break;
        }
    }
    
    $success_message = 'Şikayet durumu güncellendi.';
}

if (isset($_POST['add_survey'])) {
    // In a real app, save to database
    $success_message = 'Anket başarıyla eklendi.';
}

if (isset($_POST['verify_user'])) {
    $user_id = $_POST['user_id'] ?? 0;
    
    // In a real app, update the database
    foreach ($users as &$user) {
        if ($user['id'] == $user_id) {
            $user['is_verified'] = true;
            break;
        }
    }
    
    $success_message = 'Kullanıcı doğrulandı.';
}

// Helper functions
function get_status_label($status) {
    switch ($status) {
        case 'awaitingSolution':
            return '<span class="badge text-bg-warning">Çözüm Bekliyor</span>';
        case 'inProgress':
            return '<span class="badge text-bg-primary">İşleme Alındı</span>';
        case 'solved':
            return '<span class="badge text-bg-success">Çözüldü</span>';
        case 'rejected':
            return '<span class="badge text-bg-danger">Reddedildi</span>';
        default:
            return '<span class="badge text-bg-secondary">Bilinmiyor</span>';
    }
}

function get_city_name($city_id) {
    global $cities;
    foreach ($cities as $city) {
        if ($city['id'] == $city_id) {
            return $city['name'];
        }
    }
    return 'Bilinmiyor';
}

function get_district_name($district_id) {
    global $districts;
    foreach ($districts as $district) {
        if ($district['id'] == $district_id) {
            return $district['name'];
        }
    }
    return 'Bilinmiyor';
}

function get_category_name($category_id) {
    global $categories;
    foreach ($categories as $category) {
        if ($category['id'] == $category_id) {
            return $category['name'];
        }
    }
    return 'Bilinmiyor';
}

function get_user_name($user_id) {
    global $users;
    foreach ($users as $user) {
        if ($user['id'] == $user_id) {
            return $user['name'];
        }
    }
    return 'Bilinmiyor';
}

// Get counts
$total_posts = count($posts);
$solved_posts = 0;
$active_surveys = 0;
$verified_users = 0;

foreach ($posts as $post) {
    if ($post['status'] === 'solved') {
        $solved_posts++;
    }
}

foreach ($surveys as $survey) {
    if ($survey['is_active']) {
        $active_surveys++;
    }
}

foreach ($users as $user) {
    if ($user['is_verified']) {
        $verified_users++;
    }
}

// Get current page
$page = $_GET['page'] ?? 'dashboard';

// Check if page file exists in pages directory
$page_file = "pages/{$page}.php";
?>
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ŞikayetVar - Admin Panel</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f8f9fa;
        }
        .sidebar {
            min-height: 100vh;
            background-color: #343a40;
            color: white;
        }
        .sidebar a {
            color: rgba(255, 255, 255, 0.75);
            text-decoration: none;
            padding: 10px 15px;
            display: block;
            transition: all 0.3s;
        }
        .sidebar a:hover, .sidebar a.active {
            color: white;
            background-color: rgba(255, 255, 255, 0.1);
        }
        .sidebar .app-title {
            font-size: 1.5rem;
            padding: 20px 15px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            margin-bottom: 15px;
            font-weight: bold;
        }
        .sidebar i {
            margin-right: 10px;
        }
        .content {
            padding: 20px;
        }
        .login-container {
            max-width: 400px;
            margin: 100px auto;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
            background-color: white;
        }
        .card {
            border: none;
            border-radius: 10px;
            box-shadow: 0 0.125rem 0.25rem rgba(0, 0, 0, 0.075);
        }
        .card-header {
            background-color: #fff;
            border-bottom: 1px solid rgba(0, 0, 0, 0.125);
            font-weight: bold;
        }
        .stat-card {
            border-left: 4px solid;
            border-radius: 5px;
            transition: transform 0.3s;
        }
        .stat-card:hover {
            transform: translateY(-5px);
        }
        .stat-card-primary {
            border-left-color: #0d6efd;
        }
        .stat-card-success {
            border-left-color: #198754;
        }
        .stat-card-warning {
            border-left-color: #ffc107;
        }
        .stat-card-info {
            border-left-color: #0dcaf0;
        }
        .stat-card .card-title {
            font-size: 0.8rem;
            text-transform: uppercase;
            color: #6c757d;
        }
        .stat-card .stat-value {
            font-size: 1.5rem;
            font-weight: bold;
        }
        .post-card {
            transition: transform 0.3s;
        }
        .post-card:hover {
            transform: translateY(-5px);
        }
    </style>
</head>
<body>
    <?php if (!isset($_SESSION['user'])): ?>
        <!-- Login Form -->
        <div class="login-container">
            <h2 class="text-center mb-4">ŞikayetVar Admin Panel</h2>
            <?php if (isset($login_error)): ?>
                <div class="alert alert-danger" role="alert">
                    <?= $login_error ?>
                </div>
            <?php endif; ?>
            <form method="post">
                <div class="mb-3">
                    <label for="username" class="form-label">Kullanıcı Adı</label>
                    <input type="text" class="form-control" id="username" name="username" required>
                </div>
                <div class="mb-3">
                    <label for="password" class="form-label">Şifre</label>
                    <input type="password" class="form-control" id="password" name="password" required>
                </div>
                <button type="submit" name="login" class="btn btn-primary w-100">Giriş Yap</button>
            </form>
            <div class="mt-3 text-center text-muted">
                <small>Demo Kullanıcı: admin / Şifre: admin123</small>
            </div>
        </div>
    <?php else: ?>
        <!-- Admin Dashboard -->
        <div class="container-fluid">
            <div class="row">
                <!-- Sidebar -->
                <div class="col-md-3 col-lg-2 p-0 sidebar">
                    <div class="app-title">ŞikayetVar</div>
                    <nav>
                        <a href="?page=dashboard" class="<?= $page === 'dashboard' ? 'active' : '' ?>">
                            <i class="bi bi-speedometer2"></i> Dashboard
                        </a>
                        <a href="?page=posts" class="<?= $page === 'posts' ? 'active' : '' ?>">
                            <i class="bi bi-file-earmark-text"></i> Şikayetler
                        </a>
                        <a href="?page=surveys" class="<?= $page === 'surveys' ? 'active' : '' ?>">
                            <i class="bi bi-bar-chart"></i> Anketler
                        </a>
                        <a href="?page=users" class="<?= $page === 'users' ? 'active' : '' ?>">
                            <i class="bi bi-people"></i> Kullanıcılar
                        </a>
                        <a href="?page=settings" class="<?= $page === 'settings' ? 'active' : '' ?>">
                            <i class="bi bi-gear"></i> Ayarlar
                        </a>
                        <a href="?page=profanity_filter" class="<?= $page === 'profanity_filter' ? 'active' : '' ?>">
                            <i class="bi bi-shield-exclamation"></i> Küfür Filtresi
                        </a>
                        <a href="?logout=1" class="mt-5">
                            <i class="bi bi-box-arrow-right"></i> Çıkış Yap
                        </a>
                    </nav>
                </div>

                <!-- Main Content -->
                <div class="col-md-9 col-lg-10 content">
                    <?php if (isset($success_message)): ?>
                        <div class="alert alert-success alert-dismissible fade show" role="alert">
                            <?= $success_message ?>
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                        </div>
                    <?php endif; ?>

                    <?php if ($page === 'dashboard'): ?>
                        <?php include($page_file); ?>
                    <?php elseif ($page === 'profanity_filter'): ?>
                        <?php include($page_file); ?>
                    <?php elseif (isset($_SESSION['user']) && file_exists($page_file)): ?>
                        <?php include($page_file); ?>
                        <div class="card mb-4">
                            <div class="card-header d-flex justify-content-between align-items-center">
                                <span>Son Şikayetler</span>
                                <a href="?page=posts" class="btn btn-sm btn-outline-primary">Tümünü Gör</a>
                            </div>
                            <div class="card-body">
                                <div class="table-responsive">
                                    <table class="table table-hover">
                                        <thead>
                                            <tr>
                                                <th>ID</th>
                                                <th>Başlık</th>
                                                <th>Kullanıcı</th>
                                                <th>Konum</th>
                                                <th>Durum</th>
                                                <th>Tarih</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <?php foreach (array_slice($posts, 0, 5) as $post): ?>
                                            <tr>
                                                <td><?= $post['id'] ?></td>
                                                <td><?= $post['title'] ?></td>
                                                <td><?= get_user_name($post['user_id']) ?></td>
                                                <td><?= get_city_name($post['city_id']) ?>, <?= get_district_name($post['district_id']) ?></td>
                                                <td><?= get_status_label($post['status']) ?></td>
                                                <td><?= date('d.m.Y', strtotime($post['created_at'])) ?></td>
                                            </tr>
                                            <?php endforeach; ?>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>

                        <!-- Stats Charts -->
                        <div class="row">
                            <div class="col-md-6 mb-4">
                                <div class="card">
                                    <div class="card-header">Kategori Dağılımı</div>
                                    <div class="card-body">
                                        <div class="text-center p-5 text-muted">
                                            <i class="bi bi-bar-chart" style="font-size: 3rem;"></i>
                                            <p class="mt-3">Grafik burada gösterilecektir.</p>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-6 mb-4">
                                <div class="card">
                                    <div class="card-header">Şehirlere Göre Şikayet Sayısı</div>
                                    <div class="card-body">
                                        <div class="text-center p-5 text-muted">
                                            <i class="bi bi-pie-chart" style="font-size: 3rem;"></i>
                                            <p class="mt-3">Grafik burada gösterilecektir.</p>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                    <?php elseif ($page === 'posts'): ?>
                        <!-- Posts Page -->
                        <div class="d-flex justify-content-between align-items-center mb-4">
                            <h2>Şikayetler</h2>
                            <div>
                                <button class="btn btn-primary" type="button">Rapor Oluştur</button>
                            </div>
                        </div>
                        
                        <!-- Geliştirilmiş Filtreleme Alanı -->
                        <div class="card mb-4">
                            <div class="card-header">
                                <h5 class="mb-0">Filtrele</h5>
                            </div>
                            <div class="card-body">
                                <form method="get" action="">
                                    <input type="hidden" name="page" value="posts">
                                    <div class="row g-3">
                                        <div class="col-md-3">
                                            <label for="filter_city" class="form-label">Şehir</label>
                                            <select class="form-select" id="filter_city" name="city_id">
                                                <option value="">Tümü</option>
                                                <?php foreach ($cities as $city): ?>
                                                <option value="<?= $city['id'] ?>"><?= $city['name'] ?></option>
                                                <?php endforeach; ?>
                                            </select>
                                        </div>
                                        <div class="col-md-3">
                                            <label for="filter_district" class="form-label">İlçe</label>
                                            <select class="form-select" id="filter_district" name="district_id">
                                                <option value="">Tümü</option>
                                                <?php foreach ($districts as $district): ?>
                                                <option value="<?= $district['id'] ?>" data-city="<?= $district['city_id'] ?>"><?= $district['name'] ?></option>
                                                <?php endforeach; ?>
                                            </select>
                                        </div>
                                        <div class="col-md-3">
                                            <label for="filter_category" class="form-label">Kategori</label>
                                            <select class="form-select" id="filter_category" name="category_id">
                                                <option value="">Tümü</option>
                                                <?php foreach ($categories as $category): ?>
                                                <option value="<?= $category['id'] ?>"><?= $category['name'] ?></option>
                                                <?php endforeach; ?>
                                            </select>
                                        </div>
                                        <div class="col-md-3">
                                            <label for="filter_status" class="form-label">Durum</label>
                                            <select class="form-select" id="filter_status" name="status">
                                                <option value="">Tümü</option>
                                                <option value="awaitingSolution">Çözüm Bekleyen</option>
                                                <option value="inProgress">İşleme Alınan</option>
                                                <option value="solved">Çözüldü</option>
                                                <option value="rejected">Reddedildi</option>
                                            </select>
                                        </div>
                                    </div>
                                    
                                    <div class="row g-3 mt-2">
                                        <div class="col-md-3">
                                            <label for="filter_type" class="form-label">İçerik Tipi</label>
                                            <select class="form-select" id="filter_type" name="post_type">
                                                <option value="">Tümü</option>
                                                <option value="problem">Şikayetler</option>
                                                <option value="suggestion">Öneriler</option>
                                                <option value="announcement">Duyurular</option>
                                            </select>
                                        </div>
                                        <div class="col-md-3">
                                            <label for="filter_media" class="form-label">Medya</label>
                                            <select class="form-select" id="filter_media" name="media_type">
                                                <option value="">Tümü</option>
                                                <option value="image">Resimli Paylaşımlar</option>
                                                <option value="video">Videolu Paylaşımlar</option>
                                                <option value="none">Medyasız Paylaşımlar</option>
                                            </select>
                                        </div>
                                        <div class="col-md-3">
                                            <label for="filter_date" class="form-label">Tarih</label>
                                            <select class="form-select" id="filter_date" name="date_filter">
                                                <option value="">Tümü</option>
                                                <option value="today">Bugün</option>
                                                <option value="week">Bu Hafta</option>
                                                <option value="month">Bu Ay</option>
                                            </select>
                                        </div>
                                        <div class="col-md-3 d-flex align-items-end">
                                            <button type="submit" class="btn btn-primary w-100">Filtrele</button>
                                        </div>
                                    </div>
                                </form>
                            </div>
                        </div>

                        <div class="row">
                            <?php 
                            // Filtreleme işlemleri
                            $filtered_posts = $posts;
                            
                            // Şehir filtreleme
                            if (isset($_GET['city_id']) && $_GET['city_id'] !== '') {
                                $city_id = intval($_GET['city_id']);
                                $filtered_posts = array_filter($filtered_posts, function($post) use ($city_id) {
                                    return $post['city_id'] == $city_id;
                                });
                            }
                            
                            // İlçe filtreleme
                            if (isset($_GET['district_id']) && $_GET['district_id'] !== '') {
                                $district_id = intval($_GET['district_id']);
                                $filtered_posts = array_filter($filtered_posts, function($post) use ($district_id) {
                                    return $post['district_id'] == $district_id;
                                });
                            }
                            
                            // Kategori filtreleme
                            if (isset($_GET['category_id']) && $_GET['category_id'] !== '') {
                                $category_id = intval($_GET['category_id']);
                                $filtered_posts = array_filter($filtered_posts, function($post) use ($category_id) {
                                    return $post['category_id'] == $category_id;
                                });
                            }
                            
                            // Durum filtreleme
                            if (isset($_GET['status']) && $_GET['status'] !== '') {
                                $status = $_GET['status'];
                                $filtered_posts = array_filter($filtered_posts, function($post) use ($status) {
                                    return $post['status'] == $status;
                                });
                            }
                            
                            // İçerik tipi filtreleme (Gerçek veri tabanında post_type alanı olmalı)
                            if (isset($_GET['post_type']) && $_GET['post_type'] !== '') {
                                $post_type = $_GET['post_type'];
                                $filtered_posts = array_filter($filtered_posts, function($post) use ($post_type) {
                                    return isset($post['post_type']) && $post['post_type'] == $post_type;
                                });
                            }
                            
                            // Medya filtreleme (Gerçek veri tabanında media_type alanı olmalı)
                            if (isset($_GET['media_type']) && $_GET['media_type'] !== '') {
                                $media_type = $_GET['media_type'];
                                $filtered_posts = array_filter($filtered_posts, function($post) use ($media_type) {
                                    // Bu kısım gerçek veritabanı yapısına göre değiştirilmeli
                                    return isset($post['media_type']) && $post['media_type'] == $media_type;
                                });
                            }
                            
                            // Tarih filtreleme
                            if (isset($_GET['date_filter']) && $_GET['date_filter'] !== '') {
                                $today = date('Y-m-d');
                                $date_filter = $_GET['date_filter'];
                                
                                if ($date_filter === 'today') {
                                    $filtered_posts = array_filter($filtered_posts, function($post) use ($today) {
                                        return date('Y-m-d', strtotime($post['created_at'])) == $today;
                                    });
                                } else if ($date_filter === 'week') {
                                    $week_ago = date('Y-m-d', strtotime('-7 days'));
                                    $filtered_posts = array_filter($filtered_posts, function($post) use ($week_ago) {
                                        return date('Y-m-d', strtotime($post['created_at'])) >= $week_ago;
                                    });
                                } else if ($date_filter === 'month') {
                                    $month_ago = date('Y-m-d', strtotime('-30 days'));
                                    $filtered_posts = array_filter($filtered_posts, function($post) use ($month_ago) {
                                        return date('Y-m-d', strtotime($post['created_at'])) >= $month_ago;
                                    });
                                }
                            }
                            
                            // Sonuçları göster
                            if (empty($filtered_posts)): 
                            ?>
                                <div class="col-12 text-center my-5">
                                    <div class="alert alert-info">
                                        <i class="bi bi-info-circle me-2"></i> Seçilen kriterlere uygun içerik bulunamadı.
                                    </div>
                                </div>
                            <?php else: ?>
                                <?php foreach ($filtered_posts as $post): ?>
                                <div class="col-md-4 col-sm-6 mb-3">
                                    <div class="card post-card h-100 shadow-sm">
                                        <div class="card-header bg-white d-flex justify-content-between align-items-center py-2">
                                            <h6 class="card-title mb-0 text-truncate" title="<?= $post['title'] ?>">
                                                <?= strlen($post['title']) > 25 ? substr($post['title'], 0, 22) . '...' : $post['title'] ?>
                                            </h6>
                                            <?= get_status_label($post['status']) ?>
                                        </div>
                                        <div class="card-body py-2">
                                            <p class="card-subtitle mb-2 text-muted small">
                                                <i class="bi bi-person"></i> <?= get_user_name($post['user_id']) ?><br>
                                                <i class="bi bi-geo-alt"></i> <?= get_city_name($post['city_id']) ?>, <?= get_district_name($post['district_id']) ?><br>
                                                <i class="bi bi-tag"></i> <?= get_category_name($post['category_id']) ?>
                                            </p>
                                            <p class="card-text small" style="max-height: 80px; overflow: hidden;">
                                                <?= strlen($post['content']) > 100 ? substr($post['content'], 0, 97) . '...' : $post['content'] ?>
                                            </p>
                                            <div class="d-flex justify-content-between align-items-center small">
                                                <span class="text-muted">
                                                    <i class="bi bi-heart"></i> <?= $post['likes'] ?>
                                                    <i class="bi bi-star ms-2"></i> <?= $post['highlights'] ?>
                                                </span>
                                                <span class="text-muted"><?= date('d.m.Y', strtotime($post['created_at'])) ?></span>
                                            </div>
                                        </div>
                                        <div class="card-footer bg-white pt-2 pb-2">
                                            <form method="post" class="d-flex">
                                                <input type="hidden" name="post_id" value="<?= $post['id'] ?>">
                                                <select name="status" class="form-select form-select-sm me-1">
                                                    <option value="awaitingSolution" <?= $post['status'] === 'awaitingSolution' ? 'selected' : '' ?>>Bekliyor</option>
                                                    <option value="inProgress" <?= $post['status'] === 'inProgress' ? 'selected' : '' ?>>İşlemde</option>
                                                    <option value="solved" <?= $post['status'] === 'solved' ? 'selected' : '' ?>>Çözüldü</option>
                                                    <option value="rejected" <?= $post['status'] === 'rejected' ? 'selected' : '' ?>>Ret</option>
                                                </select>
                                                <button type="submit" name="update_post_status" class="btn btn-primary btn-sm">Güncelle</button>
                                            </form>
                                        </div>
                                    </div>
                                </div>
                                <?php endforeach; ?>
                            <?php endif; ?>
                        </div>

                    <?php elseif ($page === 'surveys'): ?>
                        <!-- Surveys Page -->
                        <div class="d-flex justify-content-between align-items-center mb-4">
                            <h2>Anketler</h2>
                            <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addSurveyModal">Yeni Anket Ekle</button>
                        </div>

                        <div class="row">
                            <?php foreach ($surveys as $survey): ?>
                            <div class="col-md-6 mb-4">
                                <div class="card h-100">
                                    <div class="card-header d-flex justify-content-between align-items-center">
                                        <span><?= $survey['title'] ?></span>
                                        <?php if ($survey['is_active']): ?>
                                            <span class="badge text-bg-success">Aktif</span>
                                        <?php else: ?>
                                            <span class="badge text-bg-secondary">Kapalı</span>
                                        <?php endif; ?>
                                    </div>
                                    <div class="card-body">
                                        <p class="card-text"><?= $survey['description'] ?></p>
                                        <div class="mb-3">
                                            <strong>Seçenekler:</strong>
                                            <ul class="list-group mt-2">
                                                <?php foreach ($survey['options'] as $option): ?>
                                                <li class="list-group-item d-flex justify-content-between align-items-center">
                                                    <?= $option['text'] ?>
                                                    <span class="badge text-bg-primary rounded-pill"><?= $option['vote_count'] ?> oy</span>
                                                </li>
                                                <?php endforeach; ?>
                                            </ul>
                                        </div>
                                        <p>
                                            <i class="bi bi-geo-alt text-muted"></i> <?= get_city_name($survey['city_id']) ?> |
                                            <i class="bi bi-tag text-muted"></i> <?= get_category_name($survey['category_id']) ?>
                                        </p>
                                        <p>
                                            <i class="bi bi-calendar text-muted"></i> <?= date('d.m.Y', strtotime($survey['start_date'])) ?> - <?= date('d.m.Y', strtotime($survey['end_date'])) ?>
                                        </p>
                                        <p class="mb-0">
                                            <strong>Toplam Katılım:</strong> <?= $survey['total_votes'] ?> oy
                                        </p>
                                    </div>
                                    <div class="card-footer bg-white">
                                        <div class="d-flex justify-content-between">
                                            <button class="btn btn-outline-primary btn-sm">Düzenle</button>
                                            <button class="btn btn-outline-danger btn-sm">Kaldır</button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <?php endforeach; ?>
                        </div>

                        <!-- Add Survey Modal -->
                        <div class="modal fade" id="addSurveyModal" tabindex="-1">
                            <div class="modal-dialog modal-lg">
                                <div class="modal-content">
                                    <div class="modal-header">
                                        <h5 class="modal-title">Yeni Anket Ekle</h5>
                                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                    </div>
                                    <div class="modal-body">
                                        <form method="post">
                                            <div class="mb-3">
                                                <label for="surveyTitle" class="form-label">Anket Başlığı</label>
                                                <input type="text" class="form-control" id="surveyTitle" name="title" required>
                                            </div>
                                            <div class="mb-3">
                                                <label for="surveyDescription" class="form-label">Açıklama</label>
                                                <textarea class="form-control" id="surveyDescription" name="description" rows="3" required></textarea>
                                            </div>
                                            <div class="row">
                                                <div class="col-md-6 mb-3">
                                                    <label for="surveyCity" class="form-label">Şehir</label>
                                                    <select class="form-select" id="surveyCity" name="city_id">
                                                        <option value="">Seçiniz</option>
                                                        <?php foreach ($cities as $city): ?>
                                                        <option value="<?= $city['id'] ?>"><?= $city['name'] ?></option>
                                                        <?php endforeach; ?>
                                                    </select>
                                                </div>
                                                <div class="col-md-6 mb-3">
                                                    <label for="surveyCategory" class="form-label">Kategori</label>
                                                    <select class="form-select" id="surveyCategory" name="category_id" required>
                                                        <option value="">Seçiniz</option>
                                                        <?php foreach ($categories as $category): ?>
                                                        <option value="<?= $category['id'] ?>"><?= $category['name'] ?></option>
                                                        <?php endforeach; ?>
                                                    </select>
                                                </div>
                                            </div>
                                            <div class="row">
                                                <div class="col-md-6 mb-3">
                                                    <label for="surveyStartDate" class="form-label">Başlangıç Tarihi</label>
                                                    <input type="date" class="form-control" id="surveyStartDate" name="start_date" required>
                                                </div>
                                                <div class="col-md-6 mb-3">
                                                    <label for="surveyEndDate" class="form-label">Bitiş Tarihi</label>
                                                    <input type="date" class="form-control" id="surveyEndDate" name="end_date" required>
                                                </div>
                                            </div>
                                            
                                            <div class="mb-3">
                                                <label class="form-label">Anket Seçenekleri</label>
                                                <div id="optionsContainer">
                                                    <div class="input-group mb-2">
                                                        <input type="text" class="form-control" name="options[]" placeholder="Seçenek 1" required>
                                                        <button type="button" class="btn btn-outline-danger remove-option" disabled><i class="bi bi-trash"></i></button>
                                                    </div>
                                                    <div class="input-group mb-2">
                                                        <input type="text" class="form-control" name="options[]" placeholder="Seçenek 2" required>
                                                        <button type="button" class="btn btn-outline-danger remove-option"><i class="bi bi-trash"></i></button>
                                                    </div>
                                                </div>
                                                <button type="button" class="btn btn-outline-secondary btn-sm" id="addOption">
                                                    <i class="bi bi-plus"></i> Seçenek Ekle
                                                </button>
                                            </div>
                                            
                                            <div class="modal-footer">
                                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">İptal</button>
                                                <button type="submit" name="add_survey" class="btn btn-primary">Anketi Ekle</button>
                                            </div>
                                        </form>
                                    </div>
                                </div>
                            </div>
                        </div>

                    <?php elseif ($page === 'users'): ?>
                        <!-- Users Page -->
                        <h2 class="mb-4">Kullanıcılar</h2>
                        
                        <div class="card">
                            <div class="card-body">
                                <div class="table-responsive">
                                    <table class="table table-hover">
                                        <thead>
                                            <tr>
                                                <th>ID</th>
                                                <th>Ad Soyad</th>
                                                <th>E-posta</th>
                                                <th>Konum</th>
                                                <th>Durum</th>
                                                <th>Kayıt Tarihi</th>
                                                <th>İşlemler</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <?php foreach ($users as $user): ?>
                                            <tr>
                                                <td><?= $user['id'] ?></td>
                                                <td><?= $user['name'] ?></td>
                                                <td><?= $user['email'] ?></td>
                                                <td><?= get_city_name($user['city_id']) ?>, <?= get_district_name($user['district_id']) ?></td>
                                                <td>
                                                    <?php if ($user['is_verified']): ?>
                                                        <span class="badge text-bg-success">Doğrulanmış</span>
                                                    <?php else: ?>
                                                        <span class="badge text-bg-warning">Doğrulanmamış</span>
                                                    <?php endif; ?>
                                                </td>
                                                <td><?= date('d.m.Y', strtotime($user['created_at'])) ?></td>
                                                <td>
                                                    <div class="btn-group">
                                                        <button type="button" class="btn btn-sm btn-outline-secondary">Detay</button>
                                                        <?php if (!$user['is_verified']): ?>
                                                        <form method="post" class="d-inline">
                                                            <input type="hidden" name="user_id" value="<?= $user['id'] ?>">
                                                            <button type="submit" name="verify_user" class="btn btn-sm btn-outline-success">Doğrula</button>
                                                        </form>
                                                        <?php endif; ?>
                                                    </div>
                                                </td>
                                            </tr>
                                            <?php endforeach; ?>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>

                    <?php elseif ($page === 'settings'): ?>
                        <!-- Settings Page -->
                        <h2 class="mb-4">Ayarlar</h2>
                        
                        <div class="row">
                            <div class="col-md-6">
                                <div class="card mb-4">
                                    <div class="card-header">
                                        Genel Ayarlar
                                    </div>
                                    <div class="card-body">
                                        <form>
                                            <div class="mb-3">
                                                <label for="siteName" class="form-label">Site Adı</label>
                                                <input type="text" class="form-control" id="siteName" value="ŞikayetVar">
                                            </div>
                                            <div class="mb-3">
                                                <label for="siteDescription" class="form-label">Site Açıklaması</label>
                                                <textarea class="form-control" id="siteDescription" rows="2">Belediye ve Valilik'e yönelik şikayet ve öneri paylaşım platformu</textarea>
                                            </div>
                                            <div class="mb-3">
                                                <label for="adminEmail" class="form-label">Yönetici E-postası</label>
                                                <input type="email" class="form-control" id="adminEmail" value="admin@sikayetvar.com">
                                            </div>
                                            <div class="mb-3 form-check">
                                                <input type="checkbox" class="form-check-input" id="maintenanceMode">
                                                <label class="form-check-label" for="maintenanceMode">Bakım Modu</label>
                                            </div>
                                            <button type="submit" class="btn btn-primary">Kaydet</button>
                                        </form>
                                    </div>
                                </div>
                                
                                <div class="card">
                                    <div class="card-header">
                                        Bildirim Ayarları
                                    </div>
                                    <div class="card-body">
                                        <form>
                                            <div class="mb-3 form-check">
                                                <input type="checkbox" class="form-check-input" id="emailNotifications" checked>
                                                <label class="form-check-label" for="emailNotifications">E-posta Bildirimleri</label>
                                            </div>
                                            <div class="mb-3 form-check">
                                                <input type="checkbox" class="form-check-input" id="pushNotifications" checked>
                                                <label class="form-check-label" for="pushNotifications">Push Bildirimleri</label>
                                            </div>
                                            <div class="mb-3 form-check">
                                                <input type="checkbox" class="form-check-input" id="newPostNotifications" checked>
                                                <label class="form-check-label" for="newPostNotifications">Yeni Şikayet Bildirimleri</label>
                                            </div>
                                            <div class="mb-3 form-check">
                                                <input type="checkbox" class="form-check-input" id="newUserNotifications" checked>
                                                <label class="form-check-label" for="newUserNotifications">Yeni Kullanıcı Bildirimleri</label>
                                            </div>
                                            <button type="submit" class="btn btn-primary">Kaydet</button>
                                        </form>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="col-md-6">
                                <div class="card mb-4">
                                    <div class="card-header">
                                        Güvenlik Ayarları
                                    </div>
                                    <div class="card-body">
                                        <form>
                                            <div class="mb-3">
                                                <label for="currentPassword" class="form-label">Mevcut Şifre</label>
                                                <input type="password" class="form-control" id="currentPassword">
                                            </div>
                                            <div class="mb-3">
                                                <label for="newPassword" class="form-label">Yeni Şifre</label>
                                                <input type="password" class="form-control" id="newPassword">
                                            </div>
                                            <div class="mb-3">
                                                <label for="confirmPassword" class="form-label">Şifre Tekrar</label>
                                                <input type="password" class="form-control" id="confirmPassword">
                                            </div>
                                            <button type="submit" class="btn btn-primary">Şifreyi Değiştir</button>
                                        </form>
                                    </div>
                                </div>
                                
                                <div class="card">
                                    <div class="card-header">
                                        API Ayarları
                                    </div>
                                    <div class="card-body">
                                        <div class="mb-3">
                                            <label for="apiKey" class="form-label">API Anahtarı</label>
                                            <div class="input-group">
                                                <input type="text" class="form-control" id="apiKey" value="sk_test_51LkGa8AMDsKvMf9I1kQgCYfMtdVXtxX52" readonly>
                                                <button class="btn btn-outline-secondary" type="button"><i class="bi bi-clipboard"></i></button>
                                            </div>
                                        </div>
                                        <div class="mb-3">
                                            <label for="webhookUrl" class="form-label">Webhook URL</label>
                                            <input type="text" class="form-control" id="webhookUrl" value="https://sikayetvar.com/api/webhook">
                                        </div>
                                        <div class="d-flex justify-content-between">
                                            <button type="button" class="btn btn-primary">Yeni API Anahtarı Oluştur</button>
                                            <button type="button" class="btn btn-outline-secondary">Test Et</button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    <?php endif; ?>
                </div>
            </div>
        </div>
    <?php endif; ?>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Add option to survey form
        document.addEventListener('DOMContentLoaded', function() {
            const addOptionBtn = document.getElementById('addOption');
            const optionsContainer = document.getElementById('optionsContainer');
            
            if (addOptionBtn && optionsContainer) {
                let optionCount = 2;
                
                addOptionBtn.addEventListener('click', function() {
                    optionCount++;
                    const optionDiv = document.createElement('div');
                    optionDiv.className = 'input-group mb-2';
                    optionDiv.innerHTML = `
                        <input type="text" class="form-control" name="options[]" placeholder="Seçenek ${optionCount}" required>
                        <button type="button" class="btn btn-outline-danger remove-option"><i class="bi bi-trash"></i></button>
                    `;
                    optionsContainer.appendChild(optionDiv);
                    
                    // Enable all remove buttons when we have more than 2 options
                    if (optionCount > 2) {
                        const removeButtons = document.querySelectorAll('.remove-option');
                        removeButtons.forEach(button => {
                            button.disabled = false;
                        });
                    }
                });
                
                // Remove option
                optionsContainer.addEventListener('click', function(e) {
                    if (e.target.closest('.remove-option')) {
                        const button = e.target.closest('.remove-option');
                        const optionDiv = button.parentElement;
                        optionDiv.remove();
                        optionCount--;
                        
                        // Disable all remove buttons when we have only 2 options
                        if (optionCount <= 2) {
                            const removeButtons = document.querySelectorAll('.remove-option');
                            removeButtons.forEach(button => {
                                button.disabled = true;
                            });
                        }
                    }
                });
            }
        });
    </script>
    
    <!-- Şehir ve İlçe Filtreleri İçin JavaScript -->
    <script>
    document.addEventListener('DOMContentLoaded', function() {
        // Şehir seçildiğinde ilçeleri filtrele
        const citySelect = document.getElementById('filter_city');
        const districtSelect = document.getElementById('filter_district');
        
        if (citySelect && districtSelect) {
            // Tüm ilçe seçeneklerini sakla
            const allDistricts = Array.from(districtSelect.options);
            
            citySelect.addEventListener('change', function() {
                const selectedCityId = citySelect.value;
                
                // İlçe seçimini sıfırla
                districtSelect.innerHTML = '<option value="">Tümü</option>';
                
                if (selectedCityId === '') {
                    // Eğer "Tümü" seçildiyse, tüm ilçeleri göster
                    allDistricts.forEach(function(district) {
                        if (district.value !== '') {
                            districtSelect.appendChild(district.cloneNode(true));
                        }
                    });
                } else {
                    // Seçilen şehre ait ilçeleri filtrele
                    allDistricts.forEach(function(district) {
                        if (district.value !== '' && district.dataset.city === selectedCityId) {
                            districtSelect.appendChild(district.cloneNode(true));
                        }
                    });
                }
            });
        }
    });
    </script>
</body>
</html>