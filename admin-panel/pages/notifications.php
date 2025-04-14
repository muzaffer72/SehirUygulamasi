<?php
// Bildirimler Yönetim Sayfası
$page_title = 'Bildirim Yönetimi';

// İşlem yönetimi
$operation = isset($_GET['op']) ? $_GET['op'] : '';
$message = '';
$error = '';

// Bildirim silme işlemi
if ($operation === 'delete' && isset($_GET['id'])) {
    $notificationId = (int)$_GET['id'];
    
    try {
        $query = "DELETE FROM notifications WHERE id = ?";
        $stmt = $db->prepare($query);
        $stmt->bind_param("i", $notificationId);
        $result = $stmt->execute();
        
        if ($result) {
            $message = "Bildirim başarıyla silindi.";
        } else {
            $error = "Bildirim silinirken bir hata oluştu.";
        }
    } catch (Exception $e) {
        $error = "Veritabanı hatası: " . $e->getMessage();
    }
}

// Toplu okundu işaretleme
if ($operation === 'mark_all_read' && isset($_GET['user_id'])) {
    $userId = (int)$_GET['user_id'];
    
    try {
        $query = "UPDATE notifications SET is_read = TRUE WHERE user_id = ? AND is_read = FALSE";
        $stmt = $db->prepare($query);
        $stmt->bind_param("i", $userId);
        $result = $stmt->execute();
        
        $affectedRows = $stmt->affected_rows;
        
        if ($result && $affectedRows > 0) {
            $message = "$affectedRows bildirim okundu olarak işaretlendi.";
        } else {
            $message = "Okunmamış bildirim bulunamadı.";
        }
    } catch (Exception $e) {
        $error = "Veritabanı hatası: " . $e->getMessage();
    }
}

// Tüm bildirimleri temizleme
if ($operation === 'clear_all' && isset($_GET['user_id'])) {
    $userId = (int)$_GET['user_id'];
    
    try {
        $query = "DELETE FROM notifications WHERE user_id = ?";
        $stmt = $db->prepare($query);
        $stmt->bind_param("i", $userId);
        $result = $stmt->execute();
        
        $affectedRows = $stmt->affected_rows;
        
        if ($result && $affectedRows > 0) {
            $message = "$affectedRows bildirim başarıyla silindi.";
        } else {
            $message = "Silinecek bildirim bulunamadı.";
        }
    } catch (Exception $e) {
        $error = "Veritabanı hatası: " . $e->getMessage();
    }
}

// Yönetici bildirimi ekleme işlemi
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['add_admin_notification'])) {
    $scope_type = isset($_POST['scope_type']) ? $_POST['scope_type'] : 'user';
    $title = isset($_POST['title']) ? $_POST['title'] : '';
    $content = isset($_POST['content']) ? $_POST['content'] : '';
    $type = isset($_POST['type']) ? $_POST['type'] : 'system';
    $image_url = isset($_POST['image_url']) ? $_POST['image_url'] : null;
    $action_url = isset($_POST['action_url']) ? $_POST['action_url'] : null;
    
    // Kapsam türüne göre işlem yap
    $scope_id = null;
    $userIds = [];
    
    // Gerekli değerlerin alınması
    switch ($scope_type) {
        case 'user':
            $userId = isset($_POST['user_id']) ? (int)$_POST['user_id'] : 0;
            if ($userId <= 0) {
                $error = "Lütfen geçerli bir kullanıcı seçin.";
                break;
            }
            $scope_id = $userId;
            $userIds[] = $userId;
            break;
            
        case 'all':
            // Tüm kullanıcılar için bildirimi veritabanına ekleyeceğiz
            try {
                $userQuery = "SELECT id FROM users";
                $userResult = $db->query($userQuery);
                while ($user = $userResult->fetch_assoc()) {
                    $userIds[] = $user['id'];
                }
            } catch (Exception $e) {
                $error = "Kullanıcılar alınırken hata: " . $e->getMessage();
            }
            break;
            
        case 'city':
            $cityId = isset($_POST['city_id']) ? (int)$_POST['city_id'] : 0;
            if ($cityId <= 0) {
                $error = "Lütfen geçerli bir şehir seçin.";
                break;
            }
            $scope_id = $cityId;
            
            // Şehirdeki kullanıcıları bul
            try {
                $userQuery = "SELECT id FROM users WHERE city_id = ?";
                $stmt = $db->prepare($userQuery);
                $stmt->bind_param("i", $cityId);
                $stmt->execute();
                $result = $stmt->get_result();
                
                while ($user = $result->fetch_assoc()) {
                    $userIds[] = $user['id'];
                }
            } catch (Exception $e) {
                $error = "Şehirdeki kullanıcılar alınırken hata: " . $e->getMessage();
            }
            break;
            
        case 'district':
            $districtId = isset($_POST['district_id']) ? (int)$_POST['district_id'] : 0;
            if ($districtId <= 0) {
                $error = "Lütfen geçerli bir ilçe seçin.";
                break;
            }
            $scope_id = $districtId;
            
            // İlçedeki kullanıcıları bul
            try {
                $userQuery = "SELECT id FROM users WHERE district_id = ?";
                $stmt = $db->prepare($userQuery);
                $stmt->bind_param("i", $districtId);
                $stmt->execute();
                $result = $stmt->get_result();
                
                while ($user = $result->fetch_assoc()) {
                    $userIds[] = $user['id'];
                }
            } catch (Exception $e) {
                $error = "İlçedeki kullanıcılar alınırken hata: " . $e->getMessage();
            }
            break;
    }
    
    // Bildirimleri ekle
    if (!empty($userIds) && !empty($title) && !empty($content)) {
        $successCount = 0;
        $totalCount = count($userIds);
        
        try {
            $db->begin_transaction();
            
            foreach ($userIds as $userId) {
                $query = "INSERT INTO notifications (
                    user_id, title, content, type, notification_type, 
                    scope_type, scope_id, image_url, action_url, is_sent
                ) VALUES (?, ?, ?, ?, 'system', ?, ?, ?, ?, TRUE)";
                
                $stmt = $db->prepare($query);
                $stmt->bind_param("issssiss", 
                    $userId, $title, $content, $type, 
                    $scope_type, $scope_id, $image_url, $action_url
                );
                
                if ($stmt->execute()) {
                    $successCount++;
                }
            }
            
            $db->commit();
            $message = "Yönetici bildirimi $successCount kullanıcıya başarıyla gönderildi.";
            
        } catch (Exception $e) {
            $db->rollback();
            $error = "Bildirim gönderilirken hata: " . $e->getMessage();
        }
    } else if (empty($userIds) && !isset($error)) {
        $error = "Seçilen kapsam için kullanıcı bulunamadı.";
    } else if (!isset($error)) {
        $error = "Lütfen tüm zorunlu alanları doldurun.";
    }
}

// Eski bildirim ekleme işlemi (kullanıcı etkileşimi için otomatik)
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['add_notification'])) {
    $userId = isset($_POST['user_id']) ? (int)$_POST['user_id'] : 0;
    $title = isset($_POST['title']) ? $_POST['title'] : '';
    $content = isset($_POST['content']) ? $_POST['content'] : '';
    $type = isset($_POST['type']) ? $_POST['type'] : 'system';
    
    if ($userId > 0 && !empty($title) && !empty($content)) {
        try {
            $query = "INSERT INTO notifications (
                user_id, title, content, type, notification_type, scope_type, is_sent
            ) VALUES (?, ?, ?, ?, 'interaction', 'user', TRUE)";
            
            $stmt = $db->prepare($query);
            $stmt->bind_param("isss", $userId, $title, $content, $type);
            $result = $stmt->execute();
            
            if ($result) {
                $message = "Kullanıcı etkileşim bildirimi başarıyla eklendi.";
            } else {
                $error = "Bildirim eklenirken bir hata oluştu.";
            }
        } catch (Exception $e) {
            $error = "Veritabanı hatası: " . $e->getMessage();
        }
    } else {
        $error = "Lütfen tüm zorunlu alanları doldurun.";
    }
}

// Filtreler için değerleri al
$userId = isset($_GET['user_id']) ? (int)$_GET['user_id'] : 0;
$isRead = isset($_GET['is_read']) ? $_GET['is_read'] : '';
$type = isset($_GET['type']) ? $_GET['type'] : '';

// Sayfalama
$page = isset($_GET['p']) ? (int)$_GET['p'] : 1;
$limit = 20;
$offset = ($page - 1) * $limit;

// Filtreleme koşulları oluştur
$conditions = [];
$params = [];
$types = "";

if ($userId > 0) {
    $conditions[] = "n.user_id = ?";
    $params[] = $userId;
    $types .= "i";
}

if ($isRead === '0' || $isRead === '1') {
    $conditions[] = "n.is_read = ?";
    $params[] = (int)$isRead;
    $types .= "i";
}

if (!empty($type)) {
    $conditions[] = "n.type = ?";
    $params[] = $type;
    $types .= "s";
}

$whereClause = !empty($conditions) ? " WHERE " . implode(" AND ", $conditions) : "";

// Bildirimleri getir
try {
    $query = "
        SELECT n.*, u.username as user_username, u.name as user_name
        FROM notifications n
        LEFT JOIN users u ON n.user_id = u.id
        $whereClause
        ORDER BY n.created_at DESC
        LIMIT ? OFFSET ?
    ";
    
    // Sorgu parametreleri
    $params[] = $limit;
    $params[] = $offset;
    $types .= "ii";
    
    $stmt = $db->prepare($query);
    
    if (!empty($params)) {
        $stmt->bind_param($types, ...$params);
    }
    
    $stmt->execute();
    $result = $stmt->get_result();
    $notifications = $result->fetch_all(MYSQLI_ASSOC);
    
    // Toplam sayıyı getir
    $countQuery = "
        SELECT COUNT(*) as total
        FROM notifications n
        $whereClause
    ";
    
    $countParams = $params;
    array_pop($countParams); // limit parametresini çıkar
    array_pop($countParams); // offset parametresini çıkar
    $countTypes = substr($types, 0, -2); // son iki karakteri çıkar (ii)
    
    $countStmt = $db->prepare($countQuery);
    
    if (!empty($countParams)) {
        $countStmt->bind_param($countTypes, ...$countParams);
    }
    
    $countStmt->execute();
    $countResult = $countStmt->get_result();
    $totalRows = $countResult->fetch_assoc()['total'];
    
    $totalPages = ceil($totalRows / $limit);
} catch (Exception $e) {
    $error = "Bildirimler alınırken bir hata oluştu: " . $e->getMessage();
    $notifications = [];
    $totalRows = 0;
    $totalPages = 0;
}

// Kullanıcıları al (filtre için)
try {
    $usersQuery = "SELECT id, username, name FROM users ORDER BY name ASC LIMIT 200";
    $usersResult = $db->query($usersQuery);
    $users = $usersResult->fetch_all(MYSQLI_ASSOC);
} catch (Exception $e) {
    $error = "Kullanıcılar alınırken hata: " . $e->getMessage();
    $users = [];
}

// Bildirim türleri
$notificationTypes = [
    'system' => 'Sistem',
    'like' => 'Beğeni',
    'comment' => 'Yorum',
    'reply' => 'Yanıt',
    'status_update' => 'Durum Güncellemesi',
    'mention' => 'Bahsetme',
    'award' => 'Ödül'
];

// Bildirim kapsamları
$scopeTypes = [
    'user' => 'Tek Kullanıcı',
    'all' => 'Tüm Kullanıcılar',
    'city' => 'Şehirdeki Kullanıcılar',
    'district' => 'İlçedeki Kullanıcılar'
];

// Şehirleri getir
try {
    $citiesQuery = "SELECT id, name FROM cities ORDER BY name ASC";
    $citiesResult = $db->query($citiesQuery);
    $cities = $citiesResult->fetch_all(MYSQLI_ASSOC);
} catch (Exception $e) {
    $error = "Şehirler alınırken hata: " . $e->getMessage();
    $cities = [];
}

// İlçeleri getir
try {
    $districtsQuery = "SELECT id, name, city_id FROM districts ORDER BY name ASC";
    $districtsResult = $db->query($districtsQuery);
    $districts = $districtsResult->fetch_all(MYSQLI_ASSOC);
} catch (Exception $e) {
    $error = "İlçeler alınırken hata: " . $e->getMessage();
    $districts = [];
}
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
    
    <div class="row">
        <!-- Yönetici Bildirim Formu -->
        <div class="col-md-4 mb-4">
            <div class="card shadow">
                <div class="card-header py-3">
                    <h6 class="m-0 font-weight-bold text-primary">Yönetici Bildirimi Gönder</h6>
                </div>
                <div class="card-body">
                    <form method="post" action="?page=notifications">
                        <input type="hidden" name="notification_type" value="system">
                        
                        <!-- Bildirim Kapsamı (Kime Gönderilecek) -->
                        <div class="mb-3">
                            <label for="scope_type" class="form-label">Bildirim Kapsamı <span class="text-danger">*</span></label>
                            <select class="form-select" id="scope_type" name="scope_type" required onchange="handleScopeChange()">
                                <?php foreach ($scopeTypes as $value => $label): ?>
                                    <option value="<?php echo $value; ?>"><?php echo $label; ?></option>
                                <?php endforeach; ?>
                            </select>
                        </div>
                        
                        <!-- Tek Kullanıcı Seçimi -->
                        <div class="mb-3" id="user_selector_container">
                            <label for="user_id" class="form-label">Kullanıcı Seçin <span class="text-danger">*</span></label>
                            <select class="form-select" id="user_id" name="user_id">
                                <option value="">Kullanıcı Seçin</option>
                                <?php foreach ($users as $user): ?>
                                    <option value="<?php echo $user['id']; ?>">
                                        <?php echo htmlspecialchars($user['name'] . ' (' . $user['username'] . ')'); ?>
                                    </option>
                                <?php endforeach; ?>
                            </select>
                        </div>
                        
                        <!-- Şehir Seçimi -->
                        <div class="mb-3" id="city_selector_container" style="display: none;">
                            <label for="city_id" class="form-label">Şehir Seçin <span class="text-danger">*</span></label>
                            <select class="form-select" id="city_id" name="city_id" onchange="updateDistrictOptions()">
                                <option value="">Şehir Seçin</option>
                                <?php foreach ($cities as $city): ?>
                                    <option value="<?php echo $city['id']; ?>">
                                        <?php echo htmlspecialchars($city['name']); ?>
                                    </option>
                                <?php endforeach; ?>
                            </select>
                        </div>
                        
                        <!-- İlçe Seçimi -->
                        <div class="mb-3" id="district_selector_container" style="display: none;">
                            <label for="district_id" class="form-label">İlçe Seçin <span class="text-danger">*</span></label>
                            <select class="form-select" id="district_id" name="district_id">
                                <option value="">Önce Şehir Seçin</option>
                            </select>
                        </div>
                        
                        <div class="mb-3">
                            <label for="type" class="form-label">Bildirim Türü</label>
                            <select class="form-select" id="type" name="type">
                                <option value="system">Sistem</option>
                                <option value="status_update">Durum Güncellemesi</option>
                                <option value="award">Ödül</option>
                            </select>
                        </div>
                        
                        <div class="mb-3">
                            <label for="title" class="form-label">Başlık <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" id="title" name="title" required>
                        </div>
                        
                        <div class="mb-3">
                            <label for="content" class="form-label">İçerik <span class="text-danger">*</span></label>
                            <textarea class="form-control" id="content" name="content" rows="3" required></textarea>
                        </div>
                        
                        <div class="mb-3">
                            <label for="image_url" class="form-label">Resim URL (İsteğe Bağlı)</label>
                            <input type="text" class="form-control" id="image_url" name="image_url" placeholder="https://...">
                        </div>
                        
                        <div class="mb-3">
                            <label for="action_url" class="form-label">Bağlantı URL (İsteğe Bağlı)</label>
                            <input type="text" class="form-control" id="action_url" name="action_url" placeholder="https://...">
                        </div>
                        
                        <div class="d-grid">
                            <button type="submit" name="add_admin_notification" class="btn btn-primary">
                                <i class="bi bi-bell"></i> Bildirimi Gönder
                            </button>
                        </div>
                    </form>
                </div>
            </div>
            
            <div class="card shadow mt-4">
                <div class="card-header py-3">
                    <h6 class="m-0 font-weight-bold text-primary">Bildirim Türleri</h6>
                </div>
                <div class="card-body">
                    <ul class="list-group">
                        <li class="list-group-item list-group-item-info">
                            <strong>Sistem Bildirimleri</strong> - Yöneticiler tarafından oluşturulan bildirimler
                        </li>
                        <li class="list-group-item list-group-item-warning">
                            <strong>Kullanıcı Etkileşim Bildirimleri</strong> - Otomatik oluşan bildirimler (beğeni, yorum vb.)
                        </li>
                    </ul>
                    <div class="alert alert-info mt-3 mb-0">
                        <strong>Not:</strong> Etkileşim bildirimleri (beğeni, yorum, yanıt vb.) kullanıcılar arasında otomatik olarak gönderilir. Yönetici olarak sadece sistem bildirimlerini oluşturabilirsiniz.
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Bildirim Listesi -->
        <div class="col-md-8">
            <div class="card shadow mb-4">
                <div class="card-header py-3 d-flex justify-content-between align-items-center">
                    <h6 class="m-0 font-weight-bold text-primary">Bildirim Yönetimi</h6>
                </div>
                <div class="card-body">
                    <!-- Filtreler -->
                    <div class="row mb-4">
                        <div class="col-md-12">
                            <form method="get" action="" class="mb-3">
                                <input type="hidden" name="page" value="notifications">
                                <div class="row g-3 align-items-end">
                                    <div class="col-md-3">
                                        <label for="user_id" class="form-label">Kullanıcı</label>
                                        <select class="form-select" id="user_id" name="user_id">
                                            <option value="0">Tüm Kullanıcılar</option>
                                            <?php foreach ($users as $user): ?>
                                                <option value="<?php echo $user['id']; ?>" <?php echo $userId == $user['id'] ? 'selected' : ''; ?>>
                                                    <?php echo htmlspecialchars($user['name'] . ' (' . $user['username'] . ')'); ?>
                                                </option>
                                            <?php endforeach; ?>
                                        </select>
                                    </div>
                                    <div class="col-md-3">
                                        <label for="is_read" class="form-label">Okunma Durumu</label>
                                        <select class="form-select" id="is_read" name="is_read">
                                            <option value="">Tümü</option>
                                            <option value="0" <?php echo $isRead === '0' ? 'selected' : ''; ?>>Okunmamış</option>
                                            <option value="1" <?php echo $isRead === '1' ? 'selected' : ''; ?>>Okunmuş</option>
                                        </select>
                                    </div>
                                    <div class="col-md-3">
                                        <label for="type" class="form-label">Bildirim Türü</label>
                                        <select class="form-select" id="type" name="type">
                                            <option value="">Tüm Türler</option>
                                            <?php foreach ($notificationTypes as $value => $label): ?>
                                                <option value="<?php echo $value; ?>" <?php echo $type === $value ? 'selected' : ''; ?>>
                                                    <?php echo $label; ?>
                                                </option>
                                            <?php endforeach; ?>
                                        </select>
                                    </div>
                                    <div class="col-md-3">
                                        <button type="submit" class="btn btn-primary">Filtrele</button>
                                        <a href="?page=notifications" class="btn btn-secondary">Sıfırla</a>
                                    </div>
                                </div>
                            </form>
                            
                            <?php if ($userId > 0): ?>
                                <div class="btn-group mb-3">
                                    <a href="?page=notifications&op=mark_all_read&user_id=<?php echo $userId; ?>" 
                                       class="btn btn-success btn-sm"
                                       onclick="return confirm('Bu kullanıcının tüm bildirimlerini okundu olarak işaretlemek istediğinize emin misiniz?')">
                                        <i class="bi bi-check-all"></i> Tümünü Okundu İşaretle
                                    </a>
                                    <a href="?page=notifications&op=clear_all&user_id=<?php echo $userId; ?>" 
                                       class="btn btn-danger btn-sm"
                                       onclick="return confirm('Bu kullanıcının TÜM bildirimlerini silmek istediğinize emin misiniz? Bu işlem geri alınamaz!')">
                                        <i class="bi bi-trash"></i> Tüm Bildirimleri Temizle
                                    </a>
                                </div>
                            <?php endif; ?>
                        </div>
                    </div>
                    
                    <!-- Toplam Sayı -->
                    <div class="row mb-3">
                        <div class="col-md-12">
                            <p class="text-muted">Toplam <?php echo $totalRows; ?> bildirim bulundu.</p>
                        </div>
                    </div>
                    
                    <!-- Tablo -->
                    <div class="table-responsive">
                        <table class="table table-bordered table-striped">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Kullanıcı</th>
                                    <th>Tür</th>
                                    <th>Başlık</th>
                                    <th>İçerik</th>
                                    <th>Durum</th>
                                    <th>Tarih</th>
                                    <th>İşlemler</th>
                                </tr>
                            </thead>
                            <tbody>
                                <?php if (empty($notifications)): ?>
                                    <tr>
                                        <td colspan="8" class="text-center">Hiç bildirim bulunamadı.</td>
                                    </tr>
                                <?php else: ?>
                                    <?php foreach ($notifications as $notification): ?>
                                        <tr>
                                            <td><?php echo $notification['id']; ?></td>
                                            <td>
                                                <?php if (!empty($notification['user_name'])): ?>
                                                    <a href="?page=notifications&user_id=<?php echo $notification['user_id']; ?>">
                                                        <?php echo htmlspecialchars($notification['user_name']); ?> 
                                                        <small class="text-muted">(@<?php echo htmlspecialchars($notification['user_username']); ?>)</small>
                                                    </a>
                                                <?php else: ?>
                                                    <span class="text-muted">Bilinmeyen Kullanıcı</span>
                                                <?php endif; ?>
                                            </td>
                                            <td>
                                                <?php 
                                                    $badgeClass = 'bg-secondary';
                                                    $notificationType = isset($notification['type']) ? $notification['type'] : '';
                                                    
                                                    switch ($notificationType) {
                                                        case 'system':
                                                            $badgeClass = 'bg-primary';
                                                            break;
                                                        case 'like':
                                                            $badgeClass = 'bg-danger';
                                                            break;
                                                        case 'comment':
                                                        case 'reply':
                                                            $badgeClass = 'bg-info';
                                                            break;
                                                        case 'status_update':
                                                            $badgeClass = 'bg-success';
                                                            break;
                                                        case 'mention':
                                                            $badgeClass = 'bg-warning text-dark';
                                                            break;
                                                        case 'award':
                                                            $badgeClass = 'bg-warning';
                                                            break;
                                                    }
                                                    
                                                    $typeName = isset($notificationTypes[$notificationType]) ? $notificationTypes[$notificationType] : 'Bilinmiyor';
                                                ?>
                                                <span class="badge <?php echo $badgeClass; ?>"><?php echo $typeName; ?></span>
                                            </td>
                                            <td><?php echo htmlspecialchars($notification['title']); ?></td>
                                            <td><?php echo htmlspecialchars(mb_substr($notification['content'], 0, 60)) . (mb_strlen($notification['content']) > 60 ? '...' : ''); ?></td>
                                            <td>
                                                <?php if ($notification['is_read']): ?>
                                                    <span class="badge bg-secondary">Okunmuş</span>
                                                <?php else: ?>
                                                    <span class="badge bg-success">Yeni</span>
                                                <?php endif; ?>
                                            </td>
                                            <td><?php echo date('d.m.Y H:i', strtotime($notification['created_at'])); ?></td>
                                            <td>
                                                <div class="btn-group btn-group-sm">
                                                    <a href="?page=notifications&op=delete&id=<?php echo $notification['id']; ?>" 
                                                       class="btn btn-danger btn-sm"
                                                       onclick="return confirm('Bu bildirimi silmek istediğinize emin misiniz?')">
                                                        <i class="bi bi-trash"></i> Sil
                                                    </a>
                                                </div>
                                            </td>
                                        </tr>
                                    <?php endforeach; ?>
                                <?php endif; ?>
                            </tbody>
                        </table>
                    </div>
                    
                    <!-- Sayfalama -->
                    <?php if ($totalPages > 1): ?>
                        <nav>
                            <ul class="pagination justify-content-center">
                                <?php if ($page > 1): ?>
                                    <li class="page-item">
                                        <a class="page-link" href="?page=notifications&p=1<?php echo (!empty($whereClause) ? "&user_id=$userId&is_read=$isRead&type=$type" : ''); ?>">
                                            İlk
                                        </a>
                                    </li>
                                    <li class="page-item">
                                        <a class="page-link" href="?page=notifications&p=<?php echo $page - 1; ?><?php echo (!empty($whereClause) ? "&user_id=$userId&is_read=$isRead&type=$type" : ''); ?>">
                                            Önceki
                                        </a>
                                    </li>
                                <?php endif; ?>

                                <?php
                                $startPage = max(1, $page - 2);
                                $endPage = min($totalPages, $page + 2);
                                
                                for ($i = $startPage; $i <= $endPage; $i++):
                                ?>
                                    <li class="page-item <?php echo $i == $page ? 'active' : ''; ?>">
                                        <a class="page-link" href="?page=notifications&p=<?php echo $i; ?><?php echo (!empty($whereClause) ? "&user_id=$userId&is_read=$isRead&type=$type" : ''); ?>">
                                            <?php echo $i; ?>
                                        </a>
                                    </li>
                                <?php endfor; ?>

                                <?php if ($page < $totalPages): ?>
                                    <li class="page-item">
                                        <a class="page-link" href="?page=notifications&p=<?php echo $page + 1; ?><?php echo (!empty($whereClause) ? "&user_id=$userId&is_read=$isRead&type=$type" : ''); ?>">
                                            Sonraki
                                        </a>
                                    </li>
                                    <li class="page-item">
                                        <a class="page-link" href="?page=notifications&p=<?php echo $totalPages; ?><?php echo (!empty($whereClause) ? "&user_id=$userId&is_read=$isRead&type=$type" : ''); ?>">
                                            Son
                                        </a>
                                    </li>
                                <?php endif; ?>
                            </ul>
                        </nav>
                    <?php endif; ?>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Bildirim Sayfası JavaScript -->
<script src="js/notifications.js"></script>