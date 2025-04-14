<?php
// Admin paneli bildirim yönetim sayfası
requireAdmin();

// Kategorileri al
try {
    $categories_query = "SELECT * FROM categories ORDER BY name ASC";
    $categories_stmt = $db->prepare($categories_query);
    $categories_stmt->execute();
    $categories_result = $categories_stmt->get_result();
    $notification_categories = [];
    while ($row = $categories_result->fetch_assoc()) {
        $notification_categories[] = $row;
    }
} catch (Exception $e) {
    echo '<div class="alert alert-danger">Kategori verilerini alma hatası: ' . $e->getMessage() . '</div>';
    $notification_categories = [];
}

// Şehirleri al
try {
    $cities_query = "SELECT * FROM cities ORDER BY name ASC";
    $cities_stmt = $db->prepare($cities_query);
    $cities_stmt->execute();
    $cities_result = $cities_stmt->get_result();
    $notification_cities = [];
    while ($row = $cities_result->fetch_assoc()) {
        $notification_cities[] = $row;
    }
} catch (Exception $e) {
    echo '<div class="alert alert-danger">Şehir verilerini alma hatası: ' . $e->getMessage() . '</div>';
    $notification_cities = [];
}

// Kullanıcıları al
try {
    $users_query = "SELECT id, username, name, email FROM users ORDER BY id DESC LIMIT 100";
    $users_stmt = $db->prepare($users_query);
    $users_stmt->execute();
    $users_result = $users_stmt->get_result();
    $notification_users = [];
    while ($row = $users_result->fetch_assoc()) {
        $notification_users[] = $row;
    }
} catch (Exception $e) {
    echo '<div class="alert alert-danger">Kullanıcı verilerini alma hatası: ' . $e->getMessage() . '</div>';
    $notification_users = [];
}

// Bildirimleri al
try {
    $notifications_query = "
        SELECT n.*, 
               u.username as target_user_name,
               c.name as target_city_name
        FROM notifications n
        LEFT JOIN users u ON n.target_id = u.id AND n.target_type = 'user'
        LEFT JOIN cities c ON n.target_id = c.id AND n.target_type = 'city'
        ORDER BY n.created_at DESC
        LIMIT 50
    ";
    $notifications_stmt = $db->prepare($notifications_query);
    $notifications_stmt->execute();
    $notifications_result = $notifications_stmt->get_result();
    $notifications = [];
    while ($row = $notifications_result->fetch_assoc()) {
        $notifications[] = $row;
    }
} catch (Exception $e) {
    echo '<div class="alert alert-danger">Bildirim verilerini alma hatası: ' . $e->getMessage() . '</div>';
    $notifications = [];
}

// Yeni bildirim gönderme işlemi
if (isset($_POST['send_notification'])) {
    $title = $_POST['title'] ?? '';
    $message = $_POST['message'] ?? '';
    $target_type = $_POST['target_type'] ?? 'all';
    $target_id = null;
    
    if ($target_type == 'user' && isset($_POST['user_id']) && !empty($_POST['user_id'])) {
        $target_id = intval($_POST['user_id']);
    } else if ($target_type == 'city' && isset($_POST['city_id']) && !empty($_POST['city_id'])) {
        $target_id = intval($_POST['city_id']);
    } else if ($target_type == 'category' && isset($_POST['category_id']) && !empty($_POST['category_id'])) {
        $target_id = intval($_POST['category_id']);
    }
    
    // Geçerli tarih ve saat bilgisini al
    $created_at = date('Y-m-d H:i:s');
    
    // Veritabanına kaydet
    try {
        $insert_query = "
            INSERT INTO notifications (title, message, target_type, target_id, created_at) 
            VALUES (?, ?, ?, ?, ?)
        ";
        $insert_stmt = $db->prepare($insert_query);
        $insert_stmt->bind_param("sssss", $title, $message, $target_type, $target_id, $created_at);
        $result = $insert_stmt->execute();
        
        if ($result) {
            // FCM ile bildirim gönder
            $success = sendFirebaseNotification($title, $message, $target_type, $target_id);
            
            if ($success) {
                echo '<div class="alert alert-success">Bildirim başarıyla gönderildi.</div>';
            } else {
                echo '<div class="alert alert-warning">Bildirim veritabanına kaydedildi ancak FCM üzerinden gönderimde bir sorun oluştu.</div>';
            }
            
            // Sayfayı yenile
            header("Location: ?page=notifications&success=" . urlencode("Bildirim başarıyla gönderildi."));
            exit;
        } else {
            echo '<div class="alert alert-danger">Bildirim gönderilirken bir hata oluştu: ' . $db->error() . '</div>';
        }
    } catch (Exception $e) {
        echo '<div class="alert alert-danger">Bildirim gönderilirken bir hata oluştu: ' . $e->getMessage() . '</div>';
    }
}

// Firebase bildirim gönderme fonksiyonu
function sendFirebaseNotification($title, $message, $target_type, $target_id) {
    $firebase_server_key = getenv('FIREBASE_SERVER_KEY');
    
    if (empty($firebase_server_key)) {
        error_log("Firebase Server Key bulunamadı");
        return false;
    }
    
    $url = 'https://fcm.googleapis.com/fcm/send';
    
    // Mesaj içeriğini hazırla
    $notification = [
        'title' => $title,
        'body' => $message,
        'sound' => 'default',
        'badge' => '1',
        'click_action' => 'FLUTTER_NOTIFICATION_CLICK'
    ];
    
    $data = [
        'title' => $title,
        'message' => $message,
        'type' => 'notification',
        'target_type' => $target_type,
        'target_id' => $target_id,
        'timestamp' => time()
    ];
    
    // Hedefi belirle
    $fields = [];
    if ($target_type == 'user' && $target_id) {
        // Kullanıcı token'ını al
        global $db;
        $token_query = "SELECT device_token FROM users WHERE id = ?";
        $token_stmt = $db->prepare($token_query);
        $token_stmt->bind_param("i", $target_id);
        $token_stmt->execute();
        $token_result = $token_stmt->get_result();
        $user = $token_result->fetch_assoc();
        
        if ($user && !empty($user['device_token'])) {
            $fields = [
                'to' => $user['device_token'],
                'notification' => $notification,
                'data' => $data,
                'priority' => 'high'
            ];
        } else {
            error_log("Kullanıcı token'ı bulunamadı. ID: " . $target_id);
            return false;
        }
    } else if ($target_type == 'city' && $target_id) {
        // Şehir konusu
        $topic = 'city_' . $target_id;
        $fields = [
            'to' => '/topics/' . $topic,
            'notification' => $notification,
            'data' => $data,
            'priority' => 'high'
        ];
    } else if ($target_type == 'category' && $target_id) {
        // Kategori konusu
        $topic = 'category_' . $target_id;
        $fields = [
            'to' => '/topics/' . $topic,
            'notification' => $notification,
            'data' => $data,
            'priority' => 'high'
        ];
    } else {
        // Tüm kullanıcılar
        $fields = [
            'to' => '/topics/all',
            'notification' => $notification,
            'data' => $data,
            'priority' => 'high'
        ];
    }
    
    // HTTP isteği için başlıkları hazırla
    $headers = [
        'Authorization: key=' . $firebase_server_key,
        'Content-Type: application/json'
    ];
    
    // cURL ile isteği gönder
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($fields));
    
    $result = curl_exec($ch);
    
    // Hata kontrolü
    if ($result === false) {
        error_log('Firebase Bildirim Hatası: ' . curl_error($ch));
        curl_close($ch);
        return false;
    }
    
    curl_close($ch);
    
    // Başarı kontrolü
    $result_data = json_decode($result, true);
    if (isset($result_data['success']) && $result_data['success'] == 1) {
        error_log('Firebase Bildirim Başarılı: ' . $result);
        return true;
    } else {
        error_log('Firebase Bildirim Başarısız: ' . $result);
        return false;
    }
}
?>

<div class="row mb-4">
    <div class="col-md-12">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h1 class="h3 mb-0 text-gray-800">Bildirim Yönetimi</h1>
        </div>
    </div>
</div>

<div class="row mb-4">
    <div class="col-lg-6">
        <div class="card shadow h-100">
            <div class="card-header py-3 d-flex justify-content-between align-items-center">
                <h6 class="m-0 font-weight-bold text-primary">Yeni Bildirim Gönder</h6>
            </div>
            <div class="card-body">
                <form method="post" action="?page=notifications">
                    <div class="mb-3">
                        <label for="title" class="form-label">Bildirim Başlığı</label>
                        <input type="text" class="form-control" id="title" name="title" required>
                    </div>
                    <div class="mb-3">
                        <label for="message" class="form-label">Bildirim Mesajı</label>
                        <textarea class="form-control" id="message" name="message" rows="3" required></textarea>
                    </div>
                    <div class="mb-3">
                        <label for="target_type" class="form-label">Bildirim Hedefi</label>
                        <select class="form-select" id="target_type" name="target_type">
                            <option value="all" selected>Tüm Kullanıcılar</option>
                            <option value="user">Belirli Kullanıcı</option>
                            <option value="city">Belirli Şehir</option>
                            <option value="category">Belirli Kategori</option>
                        </select>
                    </div>
                    
                    <!-- Koşullu gösterilen seçim alanları -->
                    <div id="user_select" class="mb-3 d-none">
                        <label for="user_id" class="form-label">Kullanıcı</label>
                        <select class="form-select" id="user_id" name="user_id">
                            <option value="">Kullanıcı Seçin</option>
                            <?php foreach ($notification_users as $user): ?>
                                <option value="<?= $user['id'] ?>"><?= htmlspecialchars($user['name']) ?> (<?= htmlspecialchars($user['username']) ?>)</option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                    
                    <div id="city_select" class="mb-3 d-none">
                        <label for="city_id" class="form-label">Şehir</label>
                        <select class="form-select" id="city_id" name="city_id">
                            <option value="">Şehir Seçin</option>
                            <?php foreach ($notification_cities as $city): ?>
                                <option value="<?= $city['id'] ?>"><?= htmlspecialchars($city['name']) ?></option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                    
                    <div id="category_select" class="mb-3 d-none">
                        <label for="category_id" class="form-label">Kategori</label>
                        <select class="form-select" id="category_id" name="category_id">
                            <option value="">Kategori Seçin</option>
                            <?php foreach ($notification_categories as $category): ?>
                                <option value="<?= $category['id'] ?>"><?= htmlspecialchars($category['name']) ?></option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                    
                    <button type="submit" name="send_notification" class="btn btn-primary">Bildirim Gönder</button>
                </form>
            </div>
        </div>
    </div>
    
    <div class="col-lg-6">
        <div class="card shadow h-100">
            <div class="card-header py-3 d-flex justify-content-between align-items-center">
                <h6 class="m-0 font-weight-bold text-primary">Bildirim Geçmişi</h6>
                <button class="btn btn-sm btn-outline-primary" id="refreshNotifications">
                    <i class="bi bi-arrow-clockwise"></i> Yenile
                </button>
            </div>
            <div class="card-body">
                <?php if (empty($notifications)): ?>
                    <div class="alert alert-info">Henüz bildirim gönderilmemiş.</div>
                <?php else: ?>
                    <div class="table-responsive">
                        <table class="table table-hover table-striped">
                            <thead>
                                <tr>
                                    <th>Başlık</th>
                                    <th>Hedef</th>
                                    <th>Tarih</th>
                                    <th>Durum</th>
                                </tr>
                            </thead>
                            <tbody>
                                <?php foreach ($notifications as $notification): ?>
                                    <tr>
                                        <td>
                                            <strong><?= htmlspecialchars($notification['title']) ?></strong>
                                            <div class="small text-muted"><?= htmlspecialchars($notification['message']) ?></div>
                                        </td>
                                        <td>
                                            <?php
                                            switch ($notification['target_type']) {
                                                case 'user':
                                                    echo '<span class="badge bg-primary">Kullanıcı</span> ';
                                                    echo htmlspecialchars($notification['target_user_name'] ?? 'Bilinmiyor');
                                                    break;
                                                case 'city':
                                                    echo '<span class="badge bg-success">Şehir</span> ';
                                                    echo htmlspecialchars($notification['target_city_name'] ?? 'Bilinmiyor');
                                                    break;
                                                case 'category':
                                                    echo '<span class="badge bg-info">Kategori</span> ';
                                                    echo htmlspecialchars(get_category_name($notification['target_id']));
                                                    break;
                                                default:
                                                    echo '<span class="badge bg-secondary">Tümü</span>';
                                            }
                                            ?>
                                        </td>
                                        <td><?= date('d.m.Y H:i', strtotime($notification['created_at'])) ?></td>
                                        <td>
                                            <?php if (isset($notification['status']) && $notification['status'] == 'error'): ?>
                                                <span class="badge bg-danger">Hata</span>
                                            <?php else: ?>
                                                <span class="badge bg-success">Gönderildi</span>
                                            <?php endif; ?>
                                        </td>
                                    </tr>
                                <?php endforeach; ?>
                            </tbody>
                        </table>
                    </div>
                <?php endif; ?>
            </div>
        </div>
    </div>
</div>

<div class="row mb-4">
    <div class="col-lg-12">
        <div class="card shadow">
            <div class="card-header py-3">
                <h6 class="m-0 font-weight-bold text-primary">Bildirim Ayarları</h6>
            </div>
            <div class="card-body">
                <div class="row">
                    <div class="col-md-6">
                        <div class="mb-3">
                            <label class="form-label fw-bold">Firebase Durum Kontrolü</label>
                            <div class="d-flex align-items-center">
                                <?php if (!empty(getenv('FIREBASE_SERVER_KEY')) && !empty(getenv('FIREBASE_API_KEY'))): ?>
                                    <div class="badge bg-success me-2">Bağlantı Kuruldu</div>
                                    <div>Firebase API anahtarları yapılandırılmış.</div>
                                <?php else: ?>
                                    <div class="badge bg-danger me-2">Bağlantı Hatası</div>
                                    <div>Firebase API anahtarları yapılandırılmamış.</div>
                                <?php endif; ?>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="mb-3">
                            <label class="form-label fw-bold">İstatistikler</label>
                            <div class="d-flex flex-column">
                                <div class="mb-1">
                                    <span class="badge bg-primary">Toplam: </span>
                                    <span><?= count($notifications) ?> bildirim</span>
                                </div>
                                <div class="mb-1">
                                    <span class="badge bg-success">Başarılı: </span>
                                    <span>
                                        <?php
                                        $successful = array_filter($notifications, function($n) {
                                            return !isset($n['status']) || $n['status'] != 'error';
                                        });
                                        echo count($successful);
                                        ?> bildirim
                                    </span>
                                </div>
                                <div>
                                    <span class="badge bg-danger">Hatalı: </span>
                                    <span>
                                        <?php
                                        $failed = array_filter($notifications, function($n) {
                                            return isset($n['status']) && $n['status'] == 'error';
                                        });
                                        echo count($failed);
                                        ?> bildirim
                                    </span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
// Bildirim hedef tipine göre ilgili seçim alanını göster
document.addEventListener('DOMContentLoaded', function() {
    const targetTypeSelect = document.getElementById('target_type');
    const userSelect = document.getElementById('user_select');
    const citySelect = document.getElementById('city_select');
    const categorySelect = document.getElementById('category_select');
    
    function updateTargetFields() {
        const selectedValue = targetTypeSelect.value;
        
        // Önce hepsini gizle
        userSelect.classList.add('d-none');
        citySelect.classList.add('d-none');
        categorySelect.classList.add('d-none');
        
        // Seçilen hedef tipine göre ilgili alanı göster
        if (selectedValue === 'user') {
            userSelect.classList.remove('d-none');
        } else if (selectedValue === 'city') {
            citySelect.classList.remove('d-none');
        } else if (selectedValue === 'category') {
            categorySelect.classList.remove('d-none');
        }
    }
    
    // Sayfa yüklendiğinde mevcut değere göre güncelle
    updateTargetFields();
    
    // Değer değiştiğinde güncelle
    targetTypeSelect.addEventListener('change', updateTargetFields);
    
    // Bildirim geçmişini yenile butonu
    const refreshButton = document.getElementById('refreshNotifications');
    if (refreshButton) {
        refreshButton.addEventListener('click', function() {
            window.location.href = '?page=notifications';
        });
    }
});
</script>