<?php
// Oturum kontrolü
require_once 'includes/session_check.php';
require_once 'includes/header.php';
require_once 'includes/db_connection.php';
require_once 'includes/functions.php';

// Bildirim verisi için sorgu
$notifications_query = "SELECT * FROM notifications ORDER BY created_at DESC";
$notifications_result = pg_query($db_connection, $notifications_query);

// Kullanıcı verileri için sorgu
$users_query = "SELECT id, username, full_name FROM users";
$users_result = pg_query($db_connection, $users_query);

// Şehirler verisi için sorgu
$cities_query = "SELECT id, name FROM cities ORDER BY name";
$cities_result = pg_query($db_connection, $cities_query);

// Kullanıcı listesini al
$users = [];
while ($user = pg_fetch_assoc($users_result)) {
    $users[] = $user;
}

// Şehirler listesini al
$cities = [];
while ($city = pg_fetch_assoc($cities_result)) {
    $cities[] = $city;
}

// Bildirim listesini al
$notifications = [];
while ($notification = pg_fetch_assoc($notifications_result)) {
    $notifications[] = $notification;
}

// Yeni bildirim oluşturma işlemi
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action']) && $_POST['action'] === 'create') {
    $title = htmlspecialchars($_POST['title'], ENT_QUOTES, 'UTF-8');
    $message = htmlspecialchars($_POST['message'], ENT_QUOTES, 'UTF-8');
    $target_type = $_POST['target_type'];
    $target_id = null;
    
    // Hedef tipine göre hedef ID'yi belirle
    if ($target_type === 'user' && !empty($_POST['user_id'])) {
        $target_id = $_POST['user_id'];
    } else if ($target_type === 'city' && !empty($_POST['city_id'])) {
        $target_id = $_POST['city_id'];
    }
    
    // Bildirim oluşturma tarihi
    $created_at = date('Y-m-d H:i:s');
    
    // Veritabanına bildirim ekle
    $insert_query = "INSERT INTO notifications (title, message, target_type, target_id, created_at, status) 
                     VALUES ($1, $2, $3, $4, $5, 'pending')";
    $result = pg_query_params($db_connection, $insert_query, [
        $title, $message, $target_type, $target_id, $created_at
    ]);
    
    if ($result) {
        // Bildirim ID'sini al
        $notification_id = pg_last_oid($result);
        
        // Firebase API ile bildirimi gönder
        $api_result = sendFirebaseNotification($title, $message, $target_type, $target_id);
        
        if ($api_result) {
            // Bildirim durumunu güncelle
            $update_query = "UPDATE notifications SET status = 'sent' WHERE id = $1";
            pg_query_params($db_connection, $update_query, [$notification_id]);
            
            $_SESSION['success_message'] = "Bildirim başarıyla gönderildi.";
        } else {
            // Hata durumunu güncelle
            $update_query = "UPDATE notifications SET status = 'error' WHERE id = $1";
            pg_query_params($db_connection, $update_query, [$notification_id]);
            
            $_SESSION['error_message'] = "Bildirim gönderilirken bir hata oluştu.";
        }
    } else {
        $_SESSION['error_message'] = "Bildirim kaydedilirken bir hata oluştu.";
    }
    
    // Sayfayı yeniden yükle
    header("Location: notifications.php");
    exit;
}

// Bildirim silme işlemi
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action']) && $_POST['action'] === 'delete') {
    $notification_id = $_POST['notification_id'];
    
    $delete_query = "DELETE FROM notifications WHERE id = $1";
    $result = pg_query_params($db_connection, $delete_query, [$notification_id]);
    
    if ($result) {
        $_SESSION['success_message'] = "Bildirim başarıyla silindi.";
    } else {
        $_SESSION['error_message'] = "Bildirim silinirken bir hata oluştu.";
    }
    
    // Sayfayı yeniden yükle
    header("Location: notifications.php");
    exit;
}

// Başarı/hata mesajlarını göster
if (isset($_SESSION['success_message'])) {
    echo '<div class="alert alert-success">' . $_SESSION['success_message'] . '</div>';
    unset($_SESSION['success_message']);
}

if (isset($_SESSION['error_message'])) {
    echo '<div class="alert alert-danger">' . $_SESSION['error_message'] . '</div>';
    unset($_SESSION['error_message']);
}
?>

<div class="container-fluid">
    <h1 class="h3 mb-4 text-gray-800">Bildirim Yönetimi</h1>
    
    <div class="row">
        <!-- Bildirim Oluşturma Formu -->
        <div class="col-lg-4">
            <div class="card shadow mb-4">
                <div class="card-header py-3">
                    <h6 class="m-0 font-weight-bold text-primary">Yeni Bildirim Oluştur</h6>
                </div>
                <div class="card-body">
                    <form method="post" action="notifications.php">
                        <input type="hidden" name="action" value="create">
                        
                        <div class="form-group">
                            <label for="title">Başlık</label>
                            <input type="text" class="form-control" id="title" name="title" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="message">Mesaj</label>
                            <textarea class="form-control" id="message" name="message" rows="3" required></textarea>
                        </div>
                        
                        <div class="form-group">
                            <label for="target_type">Bildirim Hedefi</label>
                            <select class="form-control" id="target_type" name="target_type" required>
                                <option value="all">Tüm Kullanıcılar</option>
                                <option value="user">Belirli Kullanıcı</option>
                                <option value="city">Belirli Şehir</option>
                            </select>
                        </div>
                        
                        <div class="form-group user-target" style="display: none;">
                            <label for="user_id">Kullanıcı Seçin</label>
                            <select class="form-control" id="user_id" name="user_id">
                                <option value="">Seçin...</option>
                                <?php foreach ($users as $user): ?>
                                    <option value="<?php echo $user['id']; ?>">
                                        <?php echo htmlspecialchars($user['full_name'] . ' (' . $user['username'] . ')', ENT_QUOTES, 'UTF-8'); ?>
                                    </option>
                                <?php endforeach; ?>
                            </select>
                        </div>
                        
                        <div class="form-group city-target" style="display: none;">
                            <label for="city_id">Şehir Seçin</label>
                            <select class="form-control" id="city_id" name="city_id">
                                <option value="">Seçin...</option>
                                <?php foreach ($cities as $city): ?>
                                    <option value="<?php echo $city['id']; ?>">
                                        <?php echo htmlspecialchars($city['name'], ENT_QUOTES, 'UTF-8'); ?>
                                    </option>
                                <?php endforeach; ?>
                            </select>
                        </div>
                        
                        <button type="submit" class="btn btn-primary">Bildirim Gönder</button>
                    </form>
                </div>
            </div>
        </div>
        
        <!-- Bildirim Listesi -->
        <div class="col-lg-8">
            <div class="card shadow mb-4">
                <div class="card-header py-3">
                    <h6 class="m-0 font-weight-bold text-primary">Bildirim Listesi</h6>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-bordered" id="notificationsTable" width="100%" cellspacing="0">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Başlık</th>
                                    <th>Mesaj</th>
                                    <th>Hedef</th>
                                    <th>Durum</th>
                                    <th>Oluşturuldu</th>
                                    <th>İşlemler</th>
                                </tr>
                            </thead>
                            <tbody>
                                <?php foreach ($notifications as $notification): ?>
                                    <tr>
                                        <td><?php echo $notification['id']; ?></td>
                                        <td><?php echo htmlspecialchars($notification['title'], ENT_QUOTES, 'UTF-8'); ?></td>
                                        <td><?php echo htmlspecialchars($notification['message'], ENT_QUOTES, 'UTF-8'); ?></td>
                                        <td>
                                            <?php 
                                                if ($notification['target_type'] === 'all') {
                                                    echo 'Tüm Kullanıcılar';
                                                } else if ($notification['target_type'] === 'user') {
                                                    // Kullanıcı bilgisini bul
                                                    $target_user = null;
                                                    foreach ($users as $user) {
                                                        if ($user['id'] == $notification['target_id']) {
                                                            $target_user = $user;
                                                            break;
                                                        }
                                                    }
                                                    echo 'Kullanıcı: ' . ($target_user ? htmlspecialchars($target_user['username'], ENT_QUOTES, 'UTF-8') : 'Bilinmiyor');
                                                } else if ($notification['target_type'] === 'city') {
                                                    // Şehir bilgisini bul
                                                    $target_city = null;
                                                    foreach ($cities as $city) {
                                                        if ($city['id'] == $notification['target_id']) {
                                                            $target_city = $city;
                                                            break;
                                                        }
                                                    }
                                                    echo 'Şehir: ' . ($target_city ? htmlspecialchars($target_city['name'], ENT_QUOTES, 'UTF-8') : 'Bilinmiyor');
                                                }
                                            ?>
                                        </td>
                                        <td>
                                            <?php 
                                                if ($notification['status'] === 'pending') {
                                                    echo '<span class="badge badge-warning">Bekliyor</span>';
                                                } else if ($notification['status'] === 'sent') {
                                                    echo '<span class="badge badge-success">Gönderildi</span>';
                                                } else if ($notification['status'] === 'error') {
                                                    echo '<span class="badge badge-danger">Hata</span>';
                                                }
                                            ?>
                                        </td>
                                        <td><?php echo date('d.m.Y H:i', strtotime($notification['created_at'])); ?></td>
                                        <td>
                                            <form method="post" action="notifications.php" onsubmit="return confirm('Bu bildirimi silmek istediğinizden emin misiniz?');">
                                                <input type="hidden" name="action" value="delete">
                                                <input type="hidden" name="notification_id" value="<?php echo $notification['id']; ?>">
                                                <button type="submit" class="btn btn-danger btn-sm">Sil</button>
                                            </form>
                                        </td>
                                    </tr>
                                <?php endforeach; ?>
                                
                                <?php if (empty($notifications)): ?>
                                    <tr>
                                        <td colspan="7" class="text-center">Henüz bildirim bulunmuyor.</td>
                                    </tr>
                                <?php endif; ?>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    // Bildirim hedefi seçimine göre form alanlarını göster/gizle
    document.getElementById('target_type').addEventListener('change', function() {
        var userTarget = document.querySelector('.user-target');
        var cityTarget = document.querySelector('.city-target');
        
        if (this.value === 'user') {
            userTarget.style.display = 'block';
            cityTarget.style.display = 'none';
        } else if (this.value === 'city') {
            userTarget.style.display = 'none';
            cityTarget.style.display = 'block';
        } else {
            userTarget.style.display = 'none';
            cityTarget.style.display = 'none';
        }
    });
    
    // DataTables ile tablo düzenleme
    $(document).ready(function() {
        $('#notificationsTable').DataTable({
            "order": [[5, "desc"]] // Oluşturulma tarihine göre sırala
        });
    });
</script>

<?php
require_once 'includes/footer.php';
?>