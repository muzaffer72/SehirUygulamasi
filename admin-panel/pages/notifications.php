<?php
// Veritabanı bağlantısını al
require_once 'db_connection.php';

// İşlem türünü kontrol et
$op = isset($_GET['op']) ? $_GET['op'] : '';
$id = isset($_GET['id']) ? (int)$_GET['id'] : 0;
$userId = isset($_GET['user_id']) ? (int)$_GET['user_id'] : 0;
$type = isset($_GET['type']) ? $_GET['type'] : '';
$isRead = isset($_GET['is_read']) ? (int)$_GET['is_read'] : -1; // -1 = tümü
$isArchived = isset($_GET['is_archived']) ? (int)$_GET['is_archived'] : -1; // -1 = tümü

// API yanıtı
$apiResponse = null;

// Sayfalama için değişkenler
$page = isset($_GET['p']) ? (int)$_GET['p'] : 1;
$limit = 20;
$offset = ($page - 1) * $limit;

// Mesaj ve hata değişkenleri
$message = '';
$error = '';

// Bildirimi Okundu/Okunmadı olarak işaretle
if ($op === 'toggle_read' && $id > 0) {
    try {
        $checkQuery = "SELECT * FROM notifications WHERE id = $id";
        $checkResult = pg_query($conn, $checkQuery);
        
        if (!$checkResult) {
            throw new Exception("PostgreSQL sorgu hatası: " . pg_last_error($conn));
        }
        
        $notification = pg_fetch_assoc($checkResult);
        
        if (!$notification) {
            throw new Exception("Belirtilen bildirim bulunamadı.");
        }
        
        $newIsRead = $notification['is_read'] == 't' ? 'f' : 't';
        
        $updateQuery = "UPDATE notifications SET is_read = '$newIsRead' WHERE id = $id";
        $updateResult = pg_query($conn, $updateQuery);
        
        if (!$updateResult) {
            throw new Exception("Bildirim güncellenirken hata: " . pg_last_error($conn));
        }
        
        $status = $newIsRead == 't' ? 'okundu' : 'okunmadı';
        $message = "Bildirim $status olarak işaretlendi!";
        
        header("Location: ?page=notifications&message=" . urlencode($message));
        exit;
    } catch (Exception $e) {
        $error = $e->getMessage();
    }
}

// Bildirimi Arşivle/Arşivden Çıkar
if ($op === 'toggle_archive' && $id > 0) {
    try {
        $checkQuery = "SELECT * FROM notifications WHERE id = $id";
        $checkResult = pg_query($conn, $checkQuery);
        
        if (!$checkResult) {
            throw new Exception("PostgreSQL sorgu hatası: " . pg_last_error($conn));
        }
        
        $notification = pg_fetch_assoc($checkResult);
        
        if (!$notification) {
            throw new Exception("Belirtilen bildirim bulunamadı.");
        }
        
        $newIsArchived = $notification['is_archived'] == 't' ? 'f' : 't';
        
        $updateQuery = "UPDATE notifications SET is_archived = '$newIsArchived' WHERE id = $id";
        $updateResult = pg_query($conn, $updateQuery);
        
        if (!$updateResult) {
            throw new Exception("Bildirim güncellenirken hata: " . pg_last_error($conn));
        }
        
        $status = $newIsArchived == 't' ? 'arşivlendi' : 'arşivden çıkarıldı';
        $message = "Bildirim $status!";
        
        header("Location: ?page=notifications&message=" . urlencode($message));
        exit;
    } catch (Exception $e) {
        $error = $e->getMessage();
    }
}

// Bildirimi Sil
if ($op === 'delete' && $id > 0) {
    try {
        $deleteQuery = "DELETE FROM notifications WHERE id = $id";
        $deleteResult = pg_query($conn, $deleteQuery);
        
        if (!$deleteResult) {
            throw new Exception("Bildirim silinirken hata: " . pg_last_error($conn));
        }
        
        $message = "Bildirim başarıyla silindi!";
        header("Location: ?page=notifications&message=" . urlencode($message));
        exit;
    } catch (Exception $e) {
        $error = $e->getMessage();
    }
}

// Tüm Bildirimleri Okundu Olarak İşaretle
if ($op === 'mark_all_read' && $userId > 0) {
    try {
        $updateQuery = "UPDATE notifications SET is_read = TRUE WHERE user_id = $userId AND is_read = FALSE";
        $updateResult = pg_query($conn, $updateQuery);
        
        if (!$updateResult) {
            throw new Exception("Bildirimler güncellenirken hata: " . pg_last_error($conn));
        }
        
        $message = "Tüm bildirimler okundu olarak işaretlendi!";
        header("Location: ?page=notifications&message=" . urlencode($message));
        exit;
    } catch (Exception $e) {
        $error = $e->getMessage();
    }
}

// Gruplu Bildirimleri İşaretle
if ($op === 'mark_group_read' && !empty($_GET['group_id'])) {
    try {
        $groupId = pg_escape_string($conn, $_GET['group_id']);
        
        $updateQuery = "UPDATE notifications SET is_read = TRUE WHERE group_id = '$groupId' AND is_read = FALSE";
        $updateResult = pg_query($conn, $updateQuery);
        
        if (!$updateResult) {
            throw new Exception("Bildirimler güncellenirken hata: " . pg_last_error($conn));
        }
        
        $message = "İlgili bildirimlerin tümü okundu olarak işaretlendi!";
        header("Location: ?page=notifications&message=" . urlencode($message));
        exit;
    } catch (Exception $e) {
        $error = $e->getMessage();
    }
}

// Toplu API İşlemi
if ($op === 'api_test') {
    try {
        $action = $_POST['api_action'] ?? '';
        $targetUserId = (int)($_POST['target_user_id'] ?? 0);
        
        if ($targetUserId <= 0) {
            throw new Exception("Geçerli bir kullanıcı ID'si gereklidir.");
        }
        
        $result = null;
        
        switch ($action) {
            case 'mark_all_read':
                $updateQuery = "UPDATE notifications SET is_read = TRUE WHERE user_id = $targetUserId AND is_read = FALSE";
                $updateResult = pg_query($conn, $updateQuery);
                
                if (!$updateResult) {
                    throw new Exception("İşlem sırasında hata: " . pg_last_error($conn));
                }
                
                $affected = pg_affected_rows($updateResult);
                $result = ["success" => true, "message" => "$affected bildirim okundu olarak işaretlendi"];
                break;
                
            case 'mark_all_archived':
                $updateQuery = "UPDATE notifications SET is_archived = TRUE WHERE user_id = $targetUserId AND is_archived = FALSE";
                $updateResult = pg_query($conn, $updateQuery);
                
                if (!$updateResult) {
                    throw new Exception("İşlem sırasında hata: " . pg_last_error($conn));
                }
                
                $affected = pg_affected_rows($updateResult);
                $result = ["success" => true, "message" => "$affected bildirim arşivlendi"];
                break;
                
            case 'get_unread_count':
                $countQuery = "SELECT COUNT(*) as count FROM notifications WHERE user_id = $targetUserId AND is_read = FALSE AND is_archived = FALSE";
                $countResult = pg_query($conn, $countQuery);
                
                if (!$countResult) {
                    throw new Exception("İşlem sırasında hata: " . pg_last_error($conn));
                }
                
                $countRow = pg_fetch_assoc($countResult);
                $count = $countRow['count'];
                $result = ["success" => true, "unread_count" => $count];
                break;
                
            case 'get_notifications':
                $notifyQuery = "
                    SELECT * FROM notifications 
                    WHERE user_id = $targetUserId AND is_archived = FALSE
                    ORDER BY created_at DESC
                    LIMIT 10
                ";
                $notifyResult = pg_query($conn, $notifyQuery);
                
                if (!$notifyResult) {
                    throw new Exception("İşlem sırasında hata: " . pg_last_error($conn));
                }
                
                $notifications = pg_fetch_all($notifyResult) ?: [];
                $result = ["success" => true, "notifications" => $notifications];
                break;
                
            default:
                throw new Exception("Geçersiz API işlemi.");
        }
        
        $apiResponse = json_encode($result, JSON_PRETTY_PRINT);
    } catch (Exception $e) {
        $error = $e->getMessage();
        $apiResponse = json_encode(["success" => false, "error" => $error], JSON_PRETTY_PRINT);
    }
}

// Yeni Bildirim Oluştur
if ($op === 'add') {
    try {
        // Form gönderildi mi kontrol et
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            // Form verilerini al
            $targetUserId = (int)$_POST['user_id'];
            $title = pg_escape_string($conn, $_POST['title']);
            $content = pg_escape_string($conn, $_POST['content']);
            $notificationType = pg_escape_string($conn, $_POST['type']);
            $sourceId = !empty($_POST['source_id']) ? (int)$_POST['source_id'] : 'NULL';
            $sourceType = !empty($_POST['source_type']) ? "'" . pg_escape_string($conn, $_POST['source_type']) . "'" : 'NULL';
            $data = !empty($_POST['data']) ? "'" . pg_escape_string($conn, $_POST['data']) . "'" : 'NULL';
            $groupId = !empty($_POST['group_id']) ? "'" . pg_escape_string($conn, $_POST['group_id']) . "'" : 'NULL';
            
            if ($targetUserId <= 0) {
                throw new Exception("Geçerli bir kullanıcı seçmelisiniz.");
            }
            
            if (empty($title) || empty($content) || empty($notificationType)) {
                throw new Exception("Başlık, içerik ve bildirim türü zorunludur.");
            }
            
            // Veritabanına kaydet
            $insertQuery = "
                INSERT INTO notifications 
                (user_id, title, content, type, source_id, source_type, data, group_id, created_at) 
                VALUES 
                ($targetUserId, '$title', '$content', '$notificationType', $sourceId, $sourceType, $data, $groupId, NOW())
            ";
            
            $insertResult = pg_query($conn, $insertQuery);
            
            if (!$insertResult) {
                throw new Exception("Bildirim eklenirken hata: " . pg_last_error($conn));
            }
            
            $message = "Bildirim başarıyla oluşturuldu!";
            
            // Ana sayfaya yönlendir
            header("Location: ?page=notifications&message=" . urlencode($message));
            exit;
        }
    } catch (Exception $e) {
        $error = $e->getMessage();
    }
}

// Filtreleme koşulları oluştur
$conditions = [];

if ($userId > 0) {
    $conditions[] = "n.user_id = $userId";
}

if (!empty($type)) {
    $type = pg_escape_string($conn, $type);
    $conditions[] = "n.type = '$type'";
}

if ($isRead >= 0) {
    $isReadValue = $isRead ? 'TRUE' : 'FALSE';
    $conditions[] = "n.is_read = $isReadValue";
}

if ($isArchived >= 0) {
    $isArchivedValue = $isArchived ? 'TRUE' : 'FALSE';
    $conditions[] = "n.is_archived = $isArchivedValue";
}

$whereClause = !empty($conditions) ? " WHERE " . implode(" AND ", $conditions) : "";

// Bildirimleri getir
try {
    $query = "
        SELECT n.*, 
               u.username as user_username, u.name as user_name
        FROM notifications n
        LEFT JOIN users u ON n.user_id = u.id
        $whereClause
        ORDER BY n.created_at DESC
        LIMIT $limit OFFSET $offset
    ";
    
    $result = pg_query($conn, $query);
    
    if (!$result) {
        throw new Exception("PostgreSQL sorgu hatası: " . pg_last_error($conn));
    }
    
    $notifications = pg_fetch_all($result) ?: [];
    
    // Toplam sayıyı getir
    $countQuery = "
        SELECT COUNT(*) as total
        FROM notifications n
        $whereClause
    ";
    
    $countResult = pg_query($conn, $countQuery);
    
    if (!$countResult) {
        throw new Exception("PostgreSQL sayaç sorgusu hatası: " . pg_last_error($conn));
    }
    
    $countRow = pg_fetch_assoc($countResult);
    $totalRows = $countRow['total'];
    
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
    $usersResult = pg_query($conn, $usersQuery);
    
    if (!$usersResult) {
        throw new Exception("PostgreSQL sorgu hatası: " . pg_last_error($conn));
    }
    
    $users = pg_fetch_all($usersResult) ?: [];
} catch (Exception $e) {
    $error = "Kullanıcılar alınırken hata: " . $e->getMessage();
    $users = [];
}

// Grup bilgilerini al
try {
    $groupsQuery = "
        SELECT group_id, COUNT(*) as notification_count 
        FROM notifications 
        WHERE group_id IS NOT NULL 
        GROUP BY group_id 
        ORDER BY MAX(created_at) DESC
        LIMIT 100
    ";
    $groupsResult = pg_query($conn, $groupsQuery);
    
    if (!$groupsResult) {
        throw new Exception("PostgreSQL sorgu hatası: " . pg_last_error($conn));
    }
    
    $groups = pg_fetch_all($groupsResult) ?: [];
} catch (Exception $e) {
    $error = "Grup bilgileri alınırken hata: " . $e->getMessage();
    $groups = [];
}

// Bildirim türlerini getir
$notificationTypes = [
    'like' => 'Beğeni',
    'comment' => 'Yorum',
    'reply' => 'Yanıt',
    'status_update' => 'Durum Güncelleme',
    'system' => 'Sistem',
    'welcome' => 'Karşılama',
    'achievement' => 'Başarı',
    'survey' => 'Anket',
    'post_solved' => 'Şikayet Çözüldü'
];

// Bildirim türü sayılarını getir
try {
    $typeCountQuery = "
        SELECT type, COUNT(*) as count 
        FROM notifications 
        GROUP BY type 
        ORDER BY count DESC
    ";
    $typeCountResult = pg_query($conn, $typeCountQuery);
    
    if (!$typeCountResult) {
        throw new Exception("PostgreSQL sorgu hatası: " . pg_last_error($conn));
    }
    
    $typeCounts = pg_fetch_all($typeCountResult) ?: [];
} catch (Exception $e) {
    $error = "Bildirim türü istatistikleri alınırken hata: " . $e->getMessage();
    $typeCounts = [];
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
        <!-- Ana Kartlar -->
        <div class="col-md-8">
            <div class="card shadow mb-4">
                <div class="card-header py-3 d-flex justify-content-between align-items-center">
                    <h6 class="m-0 font-weight-bold text-primary">Bildirim Yönetimi</h6>
                    <div>
                        <a href="?page=notifications&op=add" class="btn btn-primary btn-sm me-2">
                            <i class="bi bi-plus-circle"></i> Yeni Bildirim
                        </a>
                        <?php if ($userId > 0): ?>
                            <a href="?page=notifications&op=mark_all_read&user_id=<?php echo $userId; ?>" 
                               class="btn btn-info btn-sm"
                               onclick="return confirm('Bu kullanıcının tüm bildirimlerini okundu olarak işaretlemek istediğinize emin misiniz?')">
                                <i class="bi bi-check-all"></i> Tümünü Okundu İşaretle
                            </a>
                        <?php endif; ?>
                    </div>
                </div>
                
                <div class="card-body">
                    <?php if ($op === 'add'): ?>
                        <!-- Yeni Bildirim Form -->
                        <div class="card mb-4">
                            <div class="card-header">
                                <h6 class="m-0 font-weight-bold text-primary">Yeni Bildirim Oluştur</h6>
                            </div>
                            <div class="card-body">
                                <form method="post">
                                    <div class="mb-3">
                                        <label for="user_id" class="form-label">Kullanıcı</label>
                                        <select class="form-select" id="user_id" name="user_id" required>
                                            <option value="">Kullanıcı seçin</option>
                                            <?php foreach ($users as $user): ?>
                                                <option value="<?php echo $user['id']; ?>">
                                                    <?php echo htmlspecialchars($user['name'] . ' (' . $user['username'] . ')'); ?>
                                                </option>
                                            <?php endforeach; ?>
                                        </select>
                                    </div>
                                    
                                    <div class="mb-3">
                                        <label for="title" class="form-label">Başlık</label>
                                        <input type="text" class="form-control" id="title" name="title" required>
                                    </div>
                                    
                                    <div class="mb-3">
                                        <label for="content" class="form-label">İçerik</label>
                                        <textarea class="form-control" id="content" name="content" rows="3" required></textarea>
                                    </div>
                                    
                                    <div class="mb-3">
                                        <label for="type" class="form-label">Bildirim Türü</label>
                                        <select class="form-select" id="type" name="type" required>
                                            <option value="">Tür seçin</option>
                                            <?php foreach ($notificationTypes as $key => $label): ?>
                                                <option value="<?php echo $key; ?>"><?php echo $label; ?></option>
                                            <?php endforeach; ?>
                                        </select>
                                    </div>
                                    
                                    <div class="row mb-3">
                                        <div class="col-md-6">
                                            <label for="source_id" class="form-label">Kaynak ID (Opsiyonel)</label>
                                            <input type="number" class="form-control" id="source_id" name="source_id" min="1">
                                            <div class="form-text">İlgili içeriğin ID'si (gönderi, yorum vb.)</div>
                                        </div>
                                        <div class="col-md-6">
                                            <label for="source_type" class="form-label">Kaynak Türü (Opsiyonel)</label>
                                            <input type="text" class="form-control" id="source_type" name="source_type">
                                            <div class="form-text">Örn: post, comment, survey</div>
                                        </div>
                                    </div>
                                    
                                    <div class="mb-3">
                                        <label for="data" class="form-label">Ek Veriler (Opsiyonel)</label>
                                        <textarea class="form-control" id="data" name="data" rows="2"></textarea>
                                        <div class="form-text">JSON formatında ek bilgiler</div>
                                    </div>
                                    
                                    <div class="mb-3">
                                        <label for="group_id" class="form-label">Grup ID (Opsiyonel)</label>
                                        <input type="text" class="form-control" id="group_id" name="group_id">
                                        <div class="form-text">Benzer bildirimleri gruplamak için</div>
                                    </div>
                                    
                                    <div class="d-flex justify-content-between">
                                        <a href="?page=notifications" class="btn btn-secondary">İptal</a>
                                        <button type="submit" class="btn btn-primary">Bildirim Gönder</button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    <?php elseif ($op === 'api_test'): ?>
                        <!-- API Test Sayfası -->
                        <div class="card mb-4">
                            <div class="card-header">
                                <h6 class="m-0 font-weight-bold text-primary">API Testi</h6>
                            </div>
                            <div class="card-body">
                                <form method="post" action="?page=notifications&op=api_test">
                                    <div class="mb-3">
                                        <label for="target_user_id" class="form-label">Hedef Kullanıcı</label>
                                        <select class="form-select" id="target_user_id" name="target_user_id" required>
                                            <option value="">Kullanıcı seçin</option>
                                            <?php foreach ($users as $user): ?>
                                                <option value="<?php echo $user['id']; ?>">
                                                    <?php echo htmlspecialchars($user['name'] . ' (' . $user['username'] . ')'); ?>
                                                </option>
                                            <?php endforeach; ?>
                                        </select>
                                    </div>
                                    
                                    <div class="mb-3">
                                        <label for="api_action" class="form-label">API İşlemi</label>
                                        <select class="form-select" id="api_action" name="api_action" required>
                                            <option value="">İşlem seçin</option>
                                            <option value="mark_all_read">Tümünü Okundu İşaretle</option>
                                            <option value="mark_all_archived">Tümünü Arşivle</option>
                                            <option value="get_unread_count">Okunmamış Sayısını Al</option>
                                            <option value="get_notifications">Bildirimleri Getir</option>
                                        </select>
                                    </div>
                                    
                                    <div class="d-flex justify-content-between">
                                        <a href="?page=notifications" class="btn btn-secondary">İptal</a>
                                        <button type="submit" class="btn btn-primary">İşlemi Çalıştır</button>
                                    </div>
                                </form>
                                
                                <?php if ($apiResponse): ?>
                                    <div class="mt-4">
                                        <h5>API Yanıtı:</h5>
                                        <pre class="bg-light p-3 rounded"><code><?php echo htmlspecialchars($apiResponse); ?></code></pre>
                                    </div>
                                <?php endif; ?>
                            </div>
                        </div>
                    <?php else: ?>
                        <!-- Filtreleme -->
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
                                            <label for="type" class="form-label">Bildirim Türü</label>
                                            <select class="form-select" id="type" name="type">
                                                <option value="">Tüm Türler</option>
                                                <?php foreach ($notificationTypes as $key => $label): ?>
                                                    <option value="<?php echo $key; ?>" <?php echo $type == $key ? 'selected' : ''; ?>>
                                                        <?php echo $label; ?>
                                                    </option>
                                                <?php endforeach; ?>
                                            </select>
                                        </div>
                                        <div class="col-md-2">
                                            <label for="is_read" class="form-label">Okunma Durumu</label>
                                            <select class="form-select" id="is_read" name="is_read">
                                                <option value="-1" <?php echo $isRead == -1 ? 'selected' : ''; ?>>Tümü</option>
                                                <option value="0" <?php echo $isRead === 0 ? 'selected' : ''; ?>>Okunmamış</option>
                                                <option value="1" <?php echo $isRead === 1 ? 'selected' : ''; ?>>Okunmuş</option>
                                            </select>
                                        </div>
                                        <div class="col-md-2">
                                            <label for="is_archived" class="form-label">Arşiv Durumu</label>
                                            <select class="form-select" id="is_archived" name="is_archived">
                                                <option value="-1" <?php echo $isArchived == -1 ? 'selected' : ''; ?>>Tümü</option>
                                                <option value="0" <?php echo $isArchived === 0 ? 'selected' : ''; ?>>Arşivlenmemiş</option>
                                                <option value="1" <?php echo $isArchived === 1 ? 'selected' : ''; ?>>Arşivlenmiş</option>
                                            </select>
                                        </div>
                                        <div class="col-md-2">
                                            <button type="submit" class="btn btn-primary w-100">Filtrele</button>
                                        </div>
                                    </div>
                                    <div class="row mt-2">
                                        <div class="col-md-12 text-end">
                                            <a href="?page=notifications" class="btn btn-outline-secondary btn-sm">Filtreleri Sıfırla</a>
                                        </div>
                                    </div>
                                </form>
                            </div>
                        </div>
                        
                        <!-- Toplam Sayı -->
                        <div class="row mb-3">
                            <div class="col-md-12">
                                <p class="text-muted">Toplam <?php echo $totalRows; ?> bildirim bulundu.</p>
                            </div>
                        </div>
                        
                        <!-- Bildirim Tablosu -->
                        <div class="table-responsive">
                            <table class="table table-bordered table-hover">
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Kullanıcı</th>
                                        <th>Başlık/İçerik</th>
                                        <th>Tür</th>
                                        <th>Durum</th>
                                        <th>Tarih</th>
                                        <th>İşlemler</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <?php if (empty($notifications)): ?>
                                        <tr>
                                            <td colspan="7" class="text-center">Hiç bildirim bulunamadı.</td>
                                        </tr>
                                    <?php else: ?>
                                        <?php foreach ($notifications as $notification): ?>
                                            <tr class="<?php echo $notification['is_read'] == 't' ? '' : 'table-light'; ?> <?php echo $notification['is_archived'] == 't' ? 'table-secondary' : ''; ?>">
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
                                                    <strong><?php echo htmlspecialchars($notification['title']); ?></strong>
                                                    <p class="mb-0 small"><?php echo htmlspecialchars($notification['content']); ?></p>
                                                    <?php if (!empty($notification['group_id'])): ?>
                                                        <span class="badge bg-info">Grup: <?php echo htmlspecialchars($notification['group_id']); ?></span>
                                                    <?php endif; ?>
                                                </td>
                                                <td>
                                                    <span class="badge bg-<?php echo getBadgeColorForType($notification['type']); ?>">
                                                        <?php echo $notificationTypes[$notification['type']] ?? $notification['type']; ?>
                                                    </span>
                                                </td>
                                                <td>
                                                    <?php if ($notification['is_read'] == 't'): ?>
                                                        <span class="badge bg-success">Okundu</span>
                                                    <?php else: ?>
                                                        <span class="badge bg-warning text-dark">Okunmadı</span>
                                                    <?php endif; ?>
                                                    
                                                    <?php if ($notification['is_archived'] == 't'): ?>
                                                        <span class="badge bg-secondary">Arşivlenmiş</span>
                                                    <?php endif; ?>
                                                </td>
                                                <td><?php echo date('d.m.Y H:i', strtotime($notification['created_at'])); ?></td>
                                                <td>
                                                    <div class="btn-group btn-group-sm">
                                                        <?php if ($notification['is_read'] == 't'): ?>
                                                            <a href="?page=notifications&op=toggle_read&id=<?php echo $notification['id']; ?>" 
                                                               class="btn btn-outline-warning btn-sm" title="Okunmadı olarak işaretle">
                                                                <i class="bi bi-eye-slash"></i>
                                                            </a>
                                                        <?php else: ?>
                                                            <a href="?page=notifications&op=toggle_read&id=<?php echo $notification['id']; ?>" 
                                                               class="btn btn-outline-success btn-sm" title="Okundu olarak işaretle">
                                                                <i class="bi bi-eye"></i>
                                                            </a>
                                                        <?php endif; ?>
                                                        
                                                        <?php if ($notification['is_archived'] == 't'): ?>
                                                            <a href="?page=notifications&op=toggle_archive&id=<?php echo $notification['id']; ?>" 
                                                               class="btn btn-outline-primary btn-sm" title="Arşivden çıkar">
                                                                <i class="bi bi-archive"></i>
                                                            </a>
                                                        <?php else: ?>
                                                            <a href="?page=notifications&op=toggle_archive&id=<?php echo $notification['id']; ?>" 
                                                               class="btn btn-outline-secondary btn-sm" title="Arşivle">
                                                                <i class="bi bi-archive-fill"></i>
                                                            </a>
                                                        <?php endif; ?>
                                                        
                                                        <a href="?page=notifications&op=delete&id=<?php echo $notification['id']; ?>" 
                                                           class="btn btn-outline-danger btn-sm" title="Sil"
                                                           onclick="return confirm('Bu bildirimi silmek istediğinize emin misiniz?')">
                                                            <i class="bi bi-trash"></i>
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
                            <nav class="mt-4">
                                <ul class="pagination justify-content-center">
                                    <?php if ($page > 1): ?>
                                        <li class="page-item">
                                            <a class="page-link" href="?page=notifications&p=1<?php echo (!empty($whereClause) ? "&user_id=$userId&type=$type&is_read=$isRead&is_archived=$isArchived" : ''); ?>">
                                                İlk
                                            </a>
                                        </li>
                                        <li class="page-item">
                                            <a class="page-link" href="?page=notifications&p=<?php echo $page - 1; ?><?php echo (!empty($whereClause) ? "&user_id=$userId&type=$type&is_read=$isRead&is_archived=$isArchived" : ''); ?>">
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
                                            <a class="page-link" href="?page=notifications&p=<?php echo $i; ?><?php echo (!empty($whereClause) ? "&user_id=$userId&type=$type&is_read=$isRead&is_archived=$isArchived" : ''); ?>">
                                                <?php echo $i; ?>
                                            </a>
                                        </li>
                                    <?php endfor; ?>

                                    <?php if ($page < $totalPages): ?>
                                        <li class="page-item">
                                            <a class="page-link" href="?page=notifications&p=<?php echo $page + 1; ?><?php echo (!empty($whereClause) ? "&user_id=$userId&type=$type&is_read=$isRead&is_archived=$isArchived" : ''); ?>">
                                                Sonraki
                                            </a>
                                        </li>
                                        <li class="page-item">
                                            <a class="page-link" href="?page=notifications&p=<?php echo $totalPages; ?><?php echo (!empty($whereClause) ? "&user_id=$userId&type=$type&is_read=$isRead&is_archived=$isArchived" : ''); ?>">
                                                Son
                                            </a>
                                        </li>
                                    <?php endif; ?>
                                </ul>
                            </nav>
                        <?php endif; ?>
                    <?php endif; ?>
                </div>
            </div>
        </div>
        
        <!-- Yan Bölüm: İstatistikler -->
        <div class="col-md-4">
            <!-- API Test Paneli -->
            <div class="card shadow mb-4">
                <div class="card-header py-3">
                    <h6 class="m-0 font-weight-bold text-primary">API İşlemleri</h6>
                </div>
                <div class="card-body">
                    <p>API endpointleri test etmek için aşağıdaki işlemleri kullanabilirsiniz:</p>
                    <div class="list-group">
                        <a href="?page=notifications&op=api_test" class="list-group-item list-group-item-action">
                            <i class="bi bi-code-slash me-2"></i> API Testi
                        </a>
                    </div>
                </div>
            </div>
            
            <!-- Bildirim Türleri İstatistikleri -->
            <div class="card shadow mb-4">
                <div class="card-header py-3">
                    <h6 class="m-0 font-weight-bold text-primary">Bildirim Türleri</h6>
                </div>
                <div class="card-body">
                    <?php if (empty($typeCounts)): ?>
                        <p class="text-muted">Bildirim türü istatistikleri bulunamadı.</p>
                    <?php else: ?>
                        <div class="list-group">
                            <?php foreach ($typeCounts as $typeCount): ?>
                                <a href="?page=notifications&type=<?php echo $typeCount['type']; ?>" class="list-group-item list-group-item-action d-flex justify-content-between align-items-center">
                                    <span>
                                        <span class="badge bg-<?php echo getBadgeColorForType($typeCount['type']); ?> me-2">
                                            <?php echo $typeCount['type']; ?>
                                        </span>
                                        <?php echo $notificationTypes[$typeCount['type']] ?? $typeCount['type']; ?>
                                    </span>
                                    <span class="badge bg-primary rounded-pill"><?php echo $typeCount['count']; ?></span>
                                </a>
                            <?php endforeach; ?>
                        </div>
                    <?php endif; ?>
                </div>
            </div>
            
            <!-- Bildirim Grupları -->
            <?php if (!empty($groups)): ?>
                <div class="card shadow mb-4">
                    <div class="card-header py-3">
                        <h6 class="m-0 font-weight-bold text-primary">Bildirim Grupları</h6>
                    </div>
                    <div class="card-body">
                        <div class="list-group">
                            <?php foreach ($groups as $group): ?>
                                <div class="list-group-item d-flex justify-content-between align-items-center">
                                    <div>
                                        <span class="fw-bold"><?php echo htmlspecialchars($group['group_id']); ?></span>
                                        <span class="badge bg-info ms-2"><?php echo $group['notification_count']; ?> bildirim</span>
                                    </div>
                                    <a href="?page=notifications&op=mark_group_read&group_id=<?php echo $group['group_id']; ?>" 
                                       class="btn btn-sm btn-outline-success" 
                                       onclick="return confirm('Bu gruptaki tüm bildirimleri okundu olarak işaretlemek istediğinize emin misiniz?')">
                                        <i class="bi bi-check-all"></i> Tümünü Okundu İşaretle
                                    </a>
                                </div>
                            <?php endforeach; ?>
                        </div>
                    </div>
                </div>
            <?php endif; ?>
        </div>
    </div>
</div>

<?php
// Badge renklerini belirle
function getBadgeColorForType($type) {
    $colors = [
        'like' => 'info',
        'comment' => 'primary',
        'reply' => 'primary',
        'status_update' => 'success',
        'system' => 'dark',
        'welcome' => 'primary',
        'achievement' => 'warning',
        'survey' => 'secondary',
        'post_solved' => 'success'
    ];
    
    return $colors[$type] ?? 'secondary';
}
?>