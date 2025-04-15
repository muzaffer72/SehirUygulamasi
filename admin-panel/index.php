<?php
// Simple admin panel for ŞikayetVar application

session_start();

// Database connection
require_once 'db_connection.php';
// $db değişkeni db_connection.php içinde oluşturuldu

// Başarı mesajı varsa
$success_message = isset($_GET['success']) ? urldecode($_GET['success']) : null;

// Admin yetki kontrolü fonksiyonu
function requireAdmin() {
    if (!isset($_SESSION['user'])) {
        header('Location: index.php');
        exit;
    }
}

// Helper functions for displaying posts
function get_status_label($status) {
    if (!$status) return '<span class="badge text-bg-secondary">Bilinmiyor</span>';
    
    switch($status) {
        case 'awaitingSolution':
            return '<span class="badge text-bg-warning">Çözüm Bekliyor</span>';
        case 'inProgress':
            return '<span class="badge text-bg-info">İşleme Alındı</span>';
        case 'solved':
            return '<span class="badge text-bg-success">Çözüldü</span>';
        case 'rejected':
            return '<span class="badge text-bg-danger">Reddedildi</span>';
        default:
            return '<span class="badge text-bg-secondary">Bilinmiyor</span>';
    }
}

// Configuration
$config = [
    'admin_user' => 'admin',
    'admin_pass' => 'admin123' // In a production environment, use hashed passwords
];

// Veritabanından posts'ları al
try {
    $query = "
        SELECT p.*, c.name as city_name, d.name as district_name, cat.name as category_name, 
               u.email as user_email, u.name as user_name, u.username as user_username
        FROM posts p
        LEFT JOIN cities c ON p.city_id = c.id
        LEFT JOIN districts d ON p.district_id = d.id
        LEFT JOIN categories cat ON p.category_id = cat.id
        LEFT JOIN users u ON p.user_id = u.id
        WHERE 1=1
     ORDER BY p.created_at DESC LIMIT ? OFFSET ?
    ";
    $stmt = $db->prepare($query);
    // Sayfalama için parametreleri hazırla
    $posts_per_page = 16; // Sayfa başına gösterilecek kayıt sayısı
    $current_page = isset($_GET['paged']) && is_numeric($_GET['paged']) ? intval($_GET['paged']) : 1;
    $offset = ($current_page - 1) * $posts_per_page;
    $limit = $posts_per_page;
    
    $stmt->bind_param("ii", $limit, $offset);
    $stmt->execute();
    $result = $stmt->get_result();
    $posts = [];
    while ($row = $result->fetch_assoc()) {
        $posts[] = $row;
    }
    
    // Toplam kayıt sayısını al
    $count_query = "
        SELECT COUNT(*) as total 
        FROM posts p
        WHERE 1=1
    ";
    $count_stmt = $db->prepare($count_query);
    $count_stmt->execute();
    $count_result = $count_stmt->get_result();
    $total_posts = $count_result->fetch_assoc()['total'];
} catch (Exception $e) {
    echo '<div class="alert alert-danger">Veritabanı hatası: ' . $e->getMessage() . '</div>';
    $posts = [];
    $total_posts = 0;
}

// Kullanıcıları veritabanından al
try {
    $query = "SELECT * FROM users ORDER BY id DESC LIMIT 50";
    $stmt = $db->prepare($query);
    $stmt->execute();
    $result = $stmt->get_result();
    $users = [];
    while ($row = $result->fetch_assoc()) {
        $users[] = $row;
    }
} catch (Exception $e) {
    echo '<div class="alert alert-danger">Kullanıcı verilerini alma hatası: ' . $e->getMessage() . '</div>';
    $users = [];
}

// Şehirleri veritabanından al
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
    echo '<div class="alert alert-danger">Şehir verilerini alma hatası: ' . $e->getMessage() . '</div>';
    $cities = [];
}

// İlçeleri veritabanından al
try {
    $query = "SELECT * FROM districts ORDER BY name ASC";
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
}

// Kategorileri veritabanından al
try {
    $query = "SELECT * FROM categories ORDER BY name ASC";
    $stmt = $db->prepare($query);
    $stmt->execute();
    $result = $stmt->get_result();
    $categories = [];
    while ($row = $result->fetch_assoc()) {
        $categories[] = $row;
    }
} catch (Exception $e) {
    echo '<div class="alert alert-danger">Kategori verilerini alma hatası: ' . $e->getMessage() . '</div>';
    $categories = [];
}

// Anketleri veritabanından al
$surveys = [];
try {
    $query = "
        SELECT s.*, c.name as category_name, 
               city.name as city_name, d.name as district_name
        FROM surveys s
        LEFT JOIN categories c ON s.category_id = c.id
        LEFT JOIN cities city ON s.city_id = CAST(city.id AS INTEGER)
        LEFT JOIN districts d ON s.district_id = d.id
        ORDER BY s.is_pinned DESC, s.created_at DESC
        LIMIT 10
    ";
    
    $stmt = $db->prepare($query);
    $stmt->execute();
    $result = $stmt->get_result();
    $surveys = [];
    while ($row = $result->fetch_assoc()) {
        $surveys[] = $row;
    }
    
    // Her anket için oy seçeneklerini ve toplam oyları getir
    foreach ($surveys as &$survey) {
        $options_query = "
            SELECT id, text, vote_count
            FROM survey_options
            WHERE survey_id = ?
            ORDER BY id ASC
        ";
        
        $options_stmt = $db->prepare($options_query);
        $survey_id = isset($survey['id']) ? $survey['id'] : 0;
        $options_stmt->bind_param("i", $survey_id);
        $options_stmt->execute();
        $options_result = $options_stmt->get_result();
        $options = [];
        while ($row = $options_result->fetch_assoc()) {
            $options[] = $row;
        }
        
        // Toplam oy sayısını hesapla
        $total_votes = 0;
        foreach ($options as $option) {
            $total_votes += intval($option['vote_count']);
        }
        
        $survey['options'] = $options;
        $survey['total_votes'] = $total_votes;
    }
} catch (Exception $e) {
    echo '<div class="alert alert-danger">Anket verilerini alma hatası: ' . $e->getMessage() . '</div>';
}

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

function get_city_name($city_id) {
    if (!$city_id) return 'Bilinmiyor';
    global $cities;
    foreach ($cities as $city) {
        if (isset($city['id']) && $city['id'] == $city_id) {
            return isset($city['name']) ? $city['name'] : 'Bilinmiyor';
        }
    }
    return 'Bilinmiyor';
}

function get_district_name($district_id) {
    if (!$district_id) return 'Bilinmiyor';
    global $districts;
    foreach ($districts as $district) {
        if (isset($district['id']) && $district['id'] == $district_id) {
            return isset($district['name']) ? $district['name'] : 'Bilinmiyor';
        }
    }
    return 'Bilinmiyor';
}

function get_category_name($category_id) {
    if (!$category_id) return 'Bilinmiyor';
    global $categories;
    foreach ($categories as $category) {
        if (isset($category['id']) && $category['id'] == $category_id) {
            return isset($category['name']) ? $category['name'] : 'Bilinmiyor';
        }
    }
    return 'Bilinmiyor';
}

function get_user_name($user_id) {
    if (!$user_id) return 'Bilinmiyor';
    global $users;
    foreach ($users as $user) {
        if (isset($user['id']) && $user['id'] == $user_id) {
            return isset($user['name']) ? $user['name'] : 'Bilinmiyor';
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
    if (isset($post['status']) && $post['status'] === 'solved') {
        $solved_posts++;
    }
}

foreach ($surveys as $survey) {
    if (isset($survey['is_active']) && $survey['is_active']) {
        $active_surveys++;
    }
}

foreach ($users as $user) {
    if (isset($user['is_verified']) && $user['is_verified']) {
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
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
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
        .sidebar a:hover {
            color: white;
            background-color: rgba(255, 255, 255, 0.1);
        }
        .sidebar a.active {
            color: white;
            background-color: rgba(255, 255, 255, 0.15);
            border-left: 3px solid #0d6efd;
        }
        .sidebar .app-title {
            font-size: 1.5rem;
            padding: 20px 15px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            margin-bottom: 15px;
            font-weight: bold;
        }
        .menu-group {
            margin-bottom: 10px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.05);
            padding-bottom: 5px;
        }
        .menu-title {
            color: rgba(255, 255, 255, 0.5);
            font-size: 0.75rem;
            text-transform: uppercase;
            letter-spacing: 1px;
            padding: 10px 15px 5px;
            font-weight: bold;
        }
        }
        .sidebar i {
            margin-right: 10px;
        }
        /* Mobil navigasyon stilleri */
        .navbar-dark .navbar-toggler {
            border-color: rgba(255, 255, 255, 0.1);
        }
        .navbar-dark .navbar-toggler-icon {
            background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 30 30'%3e%3cpath stroke='rgba%28255, 255, 255, 0.55%29' stroke-linecap='round' stroke-miterlimit='10' stroke-width='2' d='M4 7h22M4 15h22M4 23h22'/%3e%3c/svg%3e");
        }
        .navbar-dark .nav-link {
            color: rgba(255, 255, 255, 0.75);
        }
        .navbar-dark .nav-link.active {
            color: #fff;
        }
        .navbar-dark .nav-link:hover {
            color: #fff;
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
        /* 4'lü grid için özel styling */
        .col-lg-25p {
            width: 25%;
            -ms-flex: 0 0 25%;
            flex: 0 0 25%;
            max-width: 25%;
        }
        @media (max-width: 1199.98px) {
            .col-lg-25p {
                width: 33.333333%;
                -ms-flex: 0 0 33.333333%;
                flex: 0 0 33.333333%;
                max-width: 33.333333%;
            }
        }
        @media (max-width: 991.98px) {
            .col-lg-25p {
                width: 50%;
                -ms-flex: 0 0 50%;
                flex: 0 0 50%;
                max-width: 50%;
            }
        }
        @media (max-width: 767.98px) {
            .col-lg-25p {
                width: 50%;
                -ms-flex: 0 0 50%;
                flex: 0 0 50%;
                max-width: 50%;
            }
        }
        @media (max-width: 575.98px) {
            .col-lg-25p {
                width: 100%;
                -ms-flex: 0 0 100%;
                flex: 0 0 100%;
                max-width: 100%;
            }
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
                <!-- Mobile Nav -->
                <nav class="navbar navbar-expand-lg navbar-dark bg-dark d-lg-none mb-4">
                    <div class="container-fluid">
                        <a class="navbar-brand" href="#">ŞikayetVar</a>
                        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#mobileNavbar" aria-controls="mobileNavbar" aria-expanded="false" aria-label="Toggle navigation">
                            <span class="navbar-toggler-icon"></span>
                        </button>
                        <div class="collapse navbar-collapse" id="mobileNavbar">
                            <ul class="navbar-nav me-auto mb-2 mb-lg-0">
                                <li class="nav-item">
                                    <a class="nav-link <?= $page === 'dashboard' ? 'active' : '' ?>" href="?page=dashboard">
                                        <i class="bi bi-speedometer2"></i> Dashboard
                                    </a>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link <?= $page === 'posts' ? 'active' : '' ?>" href="?page=posts">
                                        <i class="bi bi-file-earmark-text"></i> Şikayetler
                                    </a>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link <?= $page === 'surveys' ? 'active' : '' ?>" href="?page=surveys">
                                        <i class="bi bi-bar-chart"></i> Anketler
                                    </a>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link <?= $page === 'categories' ? 'active' : '' ?>" href="?page=categories">
                                        <i class="bi bi-tag"></i> Kategoriler
                                    </a>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link <?= $page === 'users' ? 'active' : '' ?>" href="?page=users">
                                        <i class="bi bi-people"></i> Kullanıcılar
                                    </a>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link <?= $page === 'settings' ? 'active' : '' ?>" href="?page=settings">
                                        <i class="bi bi-gear"></i> Ayarlar
                                    </a>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link <?= $page === 'profanity_filter' ? 'active' : '' ?>" href="?page=profanity_filter">
                                        <i class="bi bi-shield-exclamation"></i> Küfür Filtresi
                                    </a>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link <?= $page === 'notifications' ? 'active' : '' ?>" href="?page=notifications">
                                        <i class="bi bi-bell"></i> Bildirim Yönetimi
                                    </a>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link <?= $page === 'before_after' ? 'active' : '' ?>" href="?page=before_after">
                                        <i class="bi bi-images"></i> Öncesi/Sonrası
                                    </a>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link <?= $page === 'cities' ? 'active' : '' ?>" href="?page=cities">
                                        <i class="bi bi-buildings"></i> Şehirler
                                    </a>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link <?= $page === 'districts' ? 'active' : '' ?>" href="?page=districts">
                                        <i class="bi bi-geo-alt"></i> İlçeler
                                    </a>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link <?= $page === 'award_system' ? 'active' : '' ?>" href="?page=award_system">
                                        <i class="bi bi-trophy"></i> Ödül Sistemi
                                    </a>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link <?= $page === 'comments' ? 'active' : '' ?>" href="?page=comments">
                                        <i class="bi bi-chat-dots"></i> Yorumlar
                                    </a>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link <?= $page === 'user_likes' ? 'active' : '' ?>" href="?page=user_likes">
                                        <i class="bi bi-heart"></i> Beğeniler
                                    </a>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link <?= $page === 'notifications' ? 'active' : '' ?>" href="?page=notifications">
                                        <i class="bi bi-bell"></i> Bildirimler
                                    </a>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link <?= $page === 'backup' ? 'active' : '' ?>" href="?page=backup">
                                        <i class="bi bi-cloud-arrow-down"></i> Yedekleme
                                    </a>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link" href="?logout=1">
                                        <i class="bi bi-box-arrow-right"></i> Çıkış Yap
                                    </a>
                                </li>
                            </ul>
                        </div>
                    </div>
                </nav>

                <!-- Sidebar (desktop only) -->
                <div class="col-md-3 col-lg-2 p-0 sidebar d-none d-lg-block">
                    <div class="app-title">ŞikayetVar</div>
                    <nav>
                        <!-- Ana Menü -->
                        <div class="menu-group">
                            <div class="menu-title">Ana Menü</div>
                            <a href="?page=dashboard" class="<?= $page === 'dashboard' ? 'active' : '' ?>">
                                <i class="bi bi-speedometer2"></i> Dashboard
                            </a>
                        </div>
                        
                        <!-- İçerik Yönetimi -->
                        <div class="menu-group">
                            <div class="menu-title">İçerik Yönetimi</div>
                            <a href="?page=posts" class="<?= $page === 'posts' ? 'active' : '' ?>">
                                <i class="bi bi-file-earmark-text"></i> Şikayetler
                            </a>
                            <a href="?page=comments" class="<?= $page === 'comments' ? 'active' : '' ?>">
                                <i class="bi bi-chat-dots"></i> Yorumlar
                            </a>
                            <a href="?page=categories" class="<?= $page === 'categories' ? 'active' : '' ?>">
                                <i class="bi bi-tag"></i> Kategoriler
                            </a>
                            <a href="?page=user_likes" class="<?= $page === 'user_likes' ? 'active' : '' ?>">
                                <i class="bi bi-heart"></i> Beğeniler
                            </a>
                        </div>
                        
                        <!-- Kullanıcı Yönetimi -->
                        <div class="menu-group">
                            <div class="menu-title">Kullanıcı Yönetimi</div>
                            <a href="?page=users" class="<?= $page === 'users' ? 'active' : '' ?>">
                                <i class="bi bi-people"></i> Kullanıcılar
                            </a>
                            <a href="?page=notifications" class="<?= $page === 'notifications' ? 'active' : '' ?>">
                                <i class="bi bi-bell"></i> Bildirim Yönetimi
                            </a>
                            <a href="?page=before_after" class="<?= $page === 'before_after' ? 'active' : '' ?>">
                                <i class="bi bi-images"></i> Öncesi/Sonrası
                            </a>
                        </div>
                        
                        <!-- Lokasyon Yönetimi -->
                        <div class="menu-group">
                            <div class="menu-title">Lokasyon Yönetimi</div>
                            <a href="?page=cities" class="<?= $page === 'cities' ? 'active' : '' ?>">
                                <i class="bi bi-buildings"></i> Şehirler
                            </a>
                            <a href="?page=districts" class="<?= $page === 'districts' ? 'active' : '' ?>">
                                <i class="bi bi-geo-alt"></i> İlçeler
                            </a>
                        </div>
                        
                        <!-- İçerik Araçları -->
                        <div class="menu-group">
                            <div class="menu-title">İçerik Araçları</div>
                            <a href="?page=surveys" class="<?= $page === 'surveys' ? 'active' : '' ?>">
                                <i class="bi bi-bar-chart"></i> Anketler
                            </a>
                            <a href="?page=award_system" class="<?= $page === 'award_system' ? 'active' : '' ?>">
                                <i class="bi bi-trophy"></i> Ödül Sistemi
                            </a>
                            <a href="?page=search_suggestions" class="<?= $page === 'search_suggestions' ? 'active' : '' ?>">
                                <i class="bi bi-search"></i> Arama Önerileri
                            </a>
                        </div>
                        
                        <!-- Sistem Araçları -->
                        <div class="menu-group">
                            <div class="menu-title">Sistem Yönetimi</div>
                            <a href="?page=profanity_filter" class="<?= $page === 'profanity_filter' ? 'active' : '' ?>">
                                <i class="bi bi-shield-exclamation"></i> Küfür Filtresi
                            </a>
                            <a href="?page=backup" class="<?= $page === 'backup' ? 'active' : '' ?>">
                                <i class="bi bi-cloud-arrow-down"></i> Yedekleme
                            </a>
                            <a href="?page=settings" class="<?= $page === 'settings' ? 'active' : '' ?>">
                                <i class="bi bi-gear"></i> Ayarlar
                            </a>
                        </div>
                        
                        <a href="?logout=1" class="mt-4">
                            <i class="bi bi-box-arrow-right"></i> Çıkış Yap
                        </a>
                    </nav>
                </div>

                <!-- Main Content -->
                <div class="col-md-12 col-lg-10 content">
                    <?php if (isset($success_message)): ?>
                        <div class="alert alert-success alert-dismissible fade show" role="alert">
                            <?= $success_message ?>
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                        </div>
                    <?php endif; ?>

                    <?php if ($page === 'dashboard'): ?>
                        <?php include($page_file); ?>
                    <?php elseif (in_array($page, ['profanity_filter', 'backup', 'surveys', 'categories'])): ?>
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
                                            <?php 
                                            // Şikayetleri dinamik olarak getir 
                                            try {
                                                $latest_query = "
                                                    SELECT p.*, c.name as city_name, d.name as district_name, 
                                                            u.name as user_name, u.username as user_username
                                                    FROM posts p
                                                    LEFT JOIN cities c ON p.city_id = c.id
                                                    LEFT JOIN districts d ON p.district_id = d.id 
                                                    LEFT JOIN users u ON p.user_id = u.id
                                                    ORDER BY p.created_at DESC LIMIT 5
                                                ";
                                                $latest_stmt = $db->prepare($latest_query);
                                                $latest_stmt->execute();
                                                $latest_result = $latest_stmt->get_result();
                                                $latest_posts = [];
                                                while ($row = $latest_result->fetch_assoc()) {
                                                    $latest_posts[] = $row;
                                                }
                                            } catch (Exception $e) {
                                                $latest_posts = [];
                                            }

                                            if (count($latest_posts) > 0): 
                                                foreach ($latest_posts as $post): 
                                            ?>
                                            <tr>
                                                <td><?= $post['id'] ?? '?' ?></td>
                                                <td><?= $post['title'] ?? 'Başlıksız' ?></td>
                                                <td><?= $post['user_name'] ?? $post['user_username'] ?? 'Bilinmiyor' ?></td>
                                                <td><?= $post['city_name'] ?? 'Bilinmiyor' ?>, <?= $post['district_name'] ?? 'Bilinmiyor' ?></td>
                                                <td><?= get_status_label($post['status'] ?? '') ?></td>
                                                <td><?= isset($post['created_at']) && $post['created_at'] ? date('d.m.Y', strtotime($post['created_at'])) : 'Tarih yok' ?></td>
                                            </tr>
                                            <?php 
                                                endforeach; 
                                            else:
                                            ?>
                                            <tr>
                                                <td colspan="6" class="text-center">Henüz şikayet bulunmuyor.</td>
                                            </tr>
                                            <?php endif; ?>
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
                        <?php include 'pages/posts.php'; ?>

                    <?php elseif ($page === 'surveys'): ?>
                        <!-- Surveys Page -->
                        <div class="d-flex justify-content-between align-items-center mb-4">
                            <h2>Anketler</h2>
                            <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addSurveyModal">Yeni Anket Ekle</button>
                        </div>
                        
                        <!-- Anket Filtreleme -->
                        <div class="card mb-4">
                            <div class="card-header">
                                <h5 class="mb-0">Filtrele</h5>
                            </div>
                            <div class="card-body">
                                <form method="get" action="">
                                    <input type="hidden" name="page" value="surveys">
                                    <div class="row g-3">
                                        <div class="col-md-3">
                                            <label for="filter_survey_city" class="form-label">Şehir</label>
                                            <select class="form-select" id="filter_survey_city" name="survey_city_id">
                                                <option value="">Tümü</option>
                                                <?php foreach ($cities as $city): ?>
                                                <option value="<?= $city['id'] ?>"><?= $city['name'] ?></option>
                                                <?php endforeach; ?>
                                            </select>
                                        </div>
                                        <div class="col-md-3">
                                            <label for="filter_survey_district" class="form-label">İlçe</label>
                                            <select class="form-select" id="filter_survey_district" name="survey_district_id">
                                                <option value="">Tümü</option>
                                                <?php foreach ($districts as $district): ?>
                                                <option value="<?= $district['id'] ?>" data-city="<?= $district['city_id'] ?>"><?= $district['name'] ?></option>
                                                <?php endforeach; ?>
                                            </select>
                                        </div>
                                        <div class="col-md-3">
                                            <label for="filter_survey_category" class="form-label">Kategori</label>
                                            <select class="form-select" id="filter_survey_category" name="survey_category_id">
                                                <option value="">Tümü</option>
                                                <?php foreach ($categories as $category): ?>
                                                <option value="<?= $category['id'] ?>"><?= $category['name'] ?></option>
                                                <?php endforeach; ?>
                                            </select>
                                        </div>
                                        <div class="col-md-3">
                                            <label for="filter_survey_scope" class="form-label">Kapsam</label>
                                            <select class="form-select" id="filter_survey_scope" name="survey_scope">
                                                <option value="">Tümü</option>
                                                <option value="general">Genel</option>
                                                <option value="city">İl Bazlı</option>
                                                <option value="district">İlçe Bazlı</option>
                                            </select>
                                        </div>
                                    </div>
                                    <div class="row mt-3">
                                        <div class="col-md-3">
                                            <label for="filter_survey_status" class="form-label">Durum</label>
                                            <select class="form-select" id="filter_survey_status" name="survey_status">
                                                <option value="">Tümü</option>
                                                <option value="active">Aktif</option>
                                                <option value="inactive">Kapalı</option>
                                            </select>
                                        </div>
                                        <div class="col-md-3">
                                            <label for="filter_survey_date" class="form-label">Tarih</label>
                                            <select class="form-select" id="filter_survey_date" name="survey_date_filter">
                                                <option value="">Tümü</option>
                                                <option value="active">Aktif Anketler</option>
                                                <option value="upcoming">Gelecek Anketler</option>
                                                <option value="past">Geçmiş Anketler</option>
                                            </select>
                                        </div>
                                        <div class="col-md-6 d-flex align-items-end">
                                            <button type="submit" class="btn btn-primary w-100">Filtrele</button>
                                        </div>
                                    </div>
                                </form>
                            </div>
                        </div>

                        <div class="row">
                            <?php foreach ($surveys as $survey): ?>
                            <div class="col-md-6 mb-4">
                                <div class="card h-100">
                                    <div class="card-header d-flex justify-content-between align-items-center">
                                        <span><?= $survey['title'] ?></span>
                                        <div>
                                            <?php 
                                            // Kapsam türü
                                            $scope_type = isset($survey['scope_type']) ? $survey['scope_type'] : 'general';
                                            $scope_badge = '';
                                            
                                            switch($scope_type) {
                                                case 'general':
                                                    $scope_badge = '<span class="badge text-bg-info me-1">Genel</span>';
                                                    break;
                                                case 'city':
                                                    $scope_badge = '<span class="badge text-bg-primary me-1">İl Bazlı</span>';
                                                    break;
                                                case 'district':
                                                    $scope_badge = '<span class="badge text-bg-secondary me-1">İlçe Bazlı</span>';
                                                    break;
                                            }
                                            
                                            echo $scope_badge;
                                            
                                            // Aktif/Pasif durumu
                                            if ($survey['is_active']): 
                                            ?>
                                                <span class="badge text-bg-success">Aktif</span>
                                            <?php else: ?>
                                                <span class="badge text-bg-secondary">Kapalı</span>
                                            <?php endif; ?>
                                        </div>
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
                                            <?php if ($scope_type == 'general'): ?>
                                                <i class="bi bi-globe text-muted"></i> Genel Kapsam |
                                            <?php elseif ($scope_type == 'city'): ?>
                                                <i class="bi bi-geo-alt text-muted"></i> <?= get_city_name($survey['city_id']) ?> |
                                            <?php elseif ($scope_type == 'district'): ?>
                                                <i class="bi bi-geo-alt-fill text-muted"></i> <?= get_city_name($survey['city_id']) ?>, <?= get_district_name($survey['district_id']) ?> |
                                            <?php else: ?>
                                                <i class="bi bi-geo-alt text-muted"></i> <?= $survey['city_id'] ? get_city_name($survey['city_id']) : 'Genel' ?> |
                                            <?php endif; ?>
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
                                                <small class="text-muted">Yönetim panelinde görüntülenecek uzun başlık</small>
                                            </div>
                                            <div class="mb-3">
                                                <label for="surveyShortTitle" class="form-label">Kısa Başlık</label>
                                                <input type="text" class="form-control" id="surveyShortTitle" name="short_title" required maxlength="40">
                                                <small class="text-muted">Anasayfada anket widget'ında görüntülenecek kısa başlık (En fazla 40 karakter)</small>
                                            </div>
                                            <div class="mb-3">
                                                <label for="surveyDescription" class="form-label">Açıklama</label>
                                                <textarea class="form-control" id="surveyDescription" name="description" rows="3" required></textarea>
                                                <small class="text-muted">Anket detayları ve açıklaması</small>
                                            </div>
                                            <div class="mb-3">
                                                <label for="surveyScopeType" class="form-label">Anket Kapsamı</label>
                                                <select class="form-select" id="surveyScopeType" name="scope_type" required>
                                                    <option value="general">Genel (Tüm Kullanıcılar)</option>
                                                    <option value="city">İl Bazlı (Her İl Kendi Sonuçlarını Görecek)</option>
                                                    <option value="district">İlçe Bazlı (Her İlçe Kendi Sonuçlarını Görecek)</option>
                                                </select>
                                                <small class="form-text text-muted">
                                                    <ul class="mt-2">
                                                        <li><strong>Genel:</strong> Tüm kullanıcılar aynı anketi görür ve ortak sonuçlar görüntülenir. Tüm yanıtlar tek bir havuzda toplanır.</li>
                                                        <li><strong>İl Bazlı:</strong> 
                                                            <ul>
                                                                <li>Belirli bir il seçilirse: Sadece o il ve ilçelerine gösterilir, o ilin kendi sonuçları hesaplanır.</li>
                                                                <li>"Tüm Türkiye" seçilirse: Her il için ayrı anket oluşturulur. Her il kendi ve ilçelerinin toplamını görür.</li>
                                                            </ul>
                                                        </li>
                                                        <li><strong>İlçe Bazlı:</strong> 
                                                            <ul>
                                                                <li>Her ilçe için ayrı sonuçlar hesaplanır.</li>
                                                                <li>Bir kişi kendi ilçesinin sonuçlarını görür.</li>
                                                                <li>İl seçildiğinde, o ilin ve ilçelerinin genel ortalaması görüntülenebilir.</li>
                                                            </ul>
                                                        </li>
                                                    </ul>
                                                </small>
                                            </div>
                                        
                                            <div id="locationSelectors">
                                                <div class="row">
                                                    <div class="col-md-6 mb-3">
                                                        <label for="surveyCity" class="form-label">Şehir <span id="cityRequired" class="text-danger">*</span></label>
                                                        <select class="form-select" id="surveyCity" name="city_id">
                                                            <option value="">Seçiniz</option>
                                                            <option value="all">Tüm Türkiye</option>
                                                            <?php foreach ($cities as $city): ?>
                                                            <option value="<?= $city['id'] ?>"><?= $city['name'] ?></option>
                                                            <?php endforeach; ?>
                                                        </select>
                                                    </div>
                                                    <div class="col-md-6 mb-3" id="districtSelectorContainer">
                                                        <label for="surveyDistrict" class="form-label">İlçe <span id="districtRequired" class="text-danger d-none">*</span></label>
                                                        <select class="form-select" id="surveyDistrict" name="district_id">
                                                            <option value="">Seçiniz</option>
                                                            <?php foreach ($districts as $district): ?>
                                                            <option value="<?= $district['id'] ?>" data-city="<?= $district['city_id'] ?>"><?= $district['name'] ?></option>
                                                            <?php endforeach; ?>
                                                        </select>
                                                    </div>
                                                </div>
                                            </div>
                                            
                                            <div class="row">
                                                <div class="col-md-6 mb-3">
                                                    <label for="surveyCategory" class="form-label">Kategori</label>
                                                    <select class="form-select" id="surveyCategory" name="category_id" required>
                                                        <option value="">Seçiniz</option>
                                                        <?php foreach ($categories as $category): ?>
                                                        <option value="<?= $category['id'] ?>"><?= $category['name'] ?></option>
                                                        <?php endforeach; ?>
                                                    </select>
                                                </div>
                                                <div class="col-md-6 mb-3">
                                                    <label for="surveySortOrder" class="form-label">Görüntüleme Sırası</label>
                                                    <input type="number" class="form-control" id="surveySortOrder" name="sort_order" value="0" min="0">
                                                    <small class="form-text text-muted">Yüksek değerler üstte gösterilir</small>
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
    
    <!-- Filtre JavaScript'leri -->
    <script>
    document.addEventListener('DOMContentLoaded', function() {
        // Şehir seçildiğinde ilçeleri filtrele (Postlar için)
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
        
        // Anket şehir seçildiğinde ilçeleri filtrele
        const surveyCitySelect = document.getElementById('filter_survey_city');
        const surveyDistrictSelect = document.getElementById('filter_survey_district');
        
        if (surveyCitySelect && surveyDistrictSelect) {
            // Tüm ilçe seçeneklerini sakla
            const allSurveyDistricts = Array.from(surveyDistrictSelect.options);
            
            surveyCitySelect.addEventListener('change', function() {
                const selectedCityId = surveyCitySelect.value;
                
                // İlçe seçimini sıfırla
                surveyDistrictSelect.innerHTML = '<option value="">Tümü</option>';
                
                if (selectedCityId === '') {
                    // Eğer "Tümü" seçildiyse, tüm ilçeleri göster
                    allSurveyDistricts.forEach(function(district) {
                        if (district.value !== '') {
                            surveyDistrictSelect.appendChild(district.cloneNode(true));
                        }
                    });
                } else {
                    // Seçilen şehre ait ilçeleri filtrele
                    allSurveyDistricts.forEach(function(district) {
                        if (district.value !== '' && district.dataset.city === selectedCityId) {
                            surveyDistrictSelect.appendChild(district.cloneNode(true));
                        }
                    });
                }
            });
        }
        
        // Anket Ekleme Formunda Kapsam Değiştiğinde
        const scopeTypeSelect = document.getElementById('surveyScopeType');
        const surveyCity = document.getElementById('surveyCity');
        const surveyDistrict = document.getElementById('surveyDistrict');
        const cityRequired = document.getElementById('cityRequired');
        const districtRequired = document.getElementById('districtRequired');
        const locationSelectors = document.getElementById('locationSelectors');
        const districtSelectorContainer = document.getElementById('districtSelectorContainer');
        
        if (scopeTypeSelect && locationSelectors) {
            // İlçeleri şehre göre filtrele
            if (surveyCity && surveyDistrict) {
                const allSurveyFormDistricts = Array.from(surveyDistrict.options);
                
                surveyCity.addEventListener('change', function() {
                    const selectedCityId = surveyCity.value;
                    
                    // İlçe seçimini sıfırla
                    surveyDistrict.innerHTML = '<option value="">Seçiniz</option>';
                    
                    if (selectedCityId === '' || selectedCityId === 'all') {
                        // Şehir seçilmediyse veya "Tüm Türkiye" seçildiyse ilçeleri gösterme
                        surveyDistrict.disabled = true;
                        
                        if (selectedCityId === 'all') {
                            // "Tüm Türkiye" seçildiyse ve il bazlı anket ise bir uyarı gösterebiliriz
                            const scopeType = document.getElementById('surveyScopeType').value;
                            if (scopeType === 'city') {
                                // "Tüm Türkiye" seçildiğinde her il için ayrı sonuçlar hesaplanacağını belirten bilgi
                                const infoEl = document.createElement('div');
                                infoEl.className = 'alert alert-info mt-2';
                                infoEl.id = 'turkeyInfo';
                                infoEl.innerHTML = '<small><i class="bi bi-info-circle me-1"></i> Tüm Türkiye seçeneği ile her il için ayrı anket sonuçları hesaplanacak ve kullanıcılar kendi illerine ait sonuçları göreceklerdir.</small>';
                                
                                // Önceki bilgi mesajını kaldır
                                const existingInfo = document.getElementById('turkeyInfo');
                                if (existingInfo) existingInfo.remove();
                                
                                // Yeni bilgi mesajını ekle
                                surveyCity.parentNode.appendChild(infoEl);
                            }
                        }
                    } else {
                        // Şehir seçildiyse ilçeleri filtrele
                        surveyDistrict.disabled = false;
                        allSurveyFormDistricts.forEach(function(district) {
                            if (district.value !== '' && district.dataset.city === selectedCityId) {
                                surveyDistrict.appendChild(district.cloneNode(true));
                            }
                        });
                        
                        // Eğer varsa "Tüm Türkiye" bilgi mesajını kaldır
                        const existingInfo = document.getElementById('turkeyInfo');
                        if (existingInfo) existingInfo.remove();
                    }
                });
            }
            
            // Kapsam değiştiğinde gerekli alanları göster/gizle
            scopeTypeSelect.addEventListener('change', function() {
                const selectedScope = scopeTypeSelect.value;
                
                // Eğer varsa "Tüm Türkiye" bilgi mesajını kaldır
                const existingInfo = document.getElementById('turkeyInfo');
                if (existingInfo) existingInfo.remove();
                
                if (selectedScope === 'general') {
                    // Genel anket - Konum seçimleri gereksiz
                    if (cityRequired) cityRequired.classList.add('d-none');
                    if (districtRequired) districtRequired.classList.add('d-none');
                    if (surveyCity) surveyCity.required = false;
                    if (surveyDistrict) surveyDistrict.required = false;
                } 
                else if (selectedScope === 'city') {
                    // İl bazlı anket - Şehir gerekli, ilçe gereksiz
                    if (cityRequired) cityRequired.classList.remove('d-none');
                    if (districtRequired) districtRequired.classList.add('d-none');
                    if (surveyCity) surveyCity.required = true;
                    if (surveyDistrict) surveyDistrict.required = false;
                    
                    // Eğer "Tüm Türkiye" seçiliyse bilgi mesajını göster
                    if (surveyCity && surveyCity.value === 'all') {
                        // "Tüm Türkiye" seçildiğinde her il için ayrı sonuçlar hesaplanacağını belirten bilgi
                        const infoEl = document.createElement('div');
                        infoEl.className = 'alert alert-info mt-2';
                        infoEl.id = 'turkeyInfo';
                        infoEl.innerHTML = '<small><i class="bi bi-info-circle me-1"></i> Tüm Türkiye seçeneği ile her il için ayrı anket sonuçları hesaplanacak ve kullanıcılar kendi illerine ait sonuçları göreceklerdir.</small>';
                        
                        // Bilgi mesajını ekle
                        surveyCity.parentNode.appendChild(infoEl);
                    }
                }
                else if (selectedScope === 'district') {
                    // İlçe bazlı anket - Hem şehir hem ilçe gerekli
                    if (cityRequired) cityRequired.classList.remove('d-none');
                    if (districtRequired) districtRequired.classList.remove('d-none');
                    if (surveyCity) surveyCity.required = true;
                    if (surveyDistrict) surveyDistrict.required = true;
                }
            });
            
            // Sayfa yüklendiğinde kapsam tipine göre form alanlarını ayarla
            if (scopeTypeSelect.value) {
                const event = new Event('change');
                scopeTypeSelect.dispatchEvent(event);
            }
        }
    });
    </script>
    
    <!-- Anket demo verilerini ekleyen script -->
    <script src="js/survey-demo-data.js"></script>
    
    <!-- Anket sayfası için özel JavaScript -->
    <script src="js/surveys.js"></script>
</body>
</html>