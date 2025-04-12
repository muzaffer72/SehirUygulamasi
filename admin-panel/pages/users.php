<?php
// Kullanıcılar Sayfası

// İşlemleri yönet
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['update_user'])) {
    // Kullanıcı güncelleme işlemi (Gerçek veritabanı)
    $userId = isset($_POST['user_id']) ? (int)$_POST['user_id'] : 0;
    $username = isset($_POST['username']) ? $_POST['username'] : '';
    $email = isset($_POST['email']) ? $_POST['email'] : '';
    $userLevel = isset($_POST['user_level']) ? $_POST['user_level'] : 'newUser';
    $points = isset($_POST['points']) ? (int)$_POST['points'] : 0;
    // PostgreSQL'de boolean için true/false kullanılmalı
    $isVerified = isset($_POST['status']) ? 'true' : 'false';

    if ($userId > 0) {
        try {
            // Username alanını da güncelleme sorgusuna ekleyelim
            $query = "UPDATE users SET username = ?, email = ?, level = ?, points = ?, is_verified = $isVerified WHERE id = ?";
            $stmt = $db->prepare($query);
            // Hata ayıklama, parametreleri görelim
            error_log("Bind parameters: username=$username, email=$email, userLevel=$userLevel, points=$points, isVerified=$isVerified, userId=$userId");
            $stmt->bind_param("sssii", $username, $email, $userLevel, $points, $userId);
            $result = $stmt->execute();
            // Hata mesajını kontrol et
            if (!$result) {
                error_log("Query execution error: " . $stmt->error);
            }

            if ($result) {
                $success_message = 'Kullanıcı başarıyla güncellendi.';
            } else {
                $error_message = 'Kullanıcı güncellenirken bir hata oluştu.';
            }
        } catch (Exception $e) {
            $error_message = 'Veritabanı hatası: ' . $e->getMessage();
        }
    }
}

if (isset($_GET['op']) && $_GET['op'] == 'ban' && isset($_GET['id'])) {
    // Kullanıcı engelleme işlemi (Gerçek veritabanı)
    $userId = (int)$_GET['id'];
    
    try {
        // PostgreSQL boolean için true/false kullanılmalı
        $query = "UPDATE users SET is_verified = false WHERE id = ?";
        $stmt = $db->prepare($query);
        $stmt->bind_param("i", $userId);
        $result = $stmt->execute();
        
        if ($result) {
            $success_message = 'Kullanıcı başarıyla engellendi.';
        } else {
            $error_message = 'Kullanıcı engellenirken bir hata oluştu.';
        }
    } catch (Exception $e) {
        $error_message = 'Veritabanı hatası: ' . $e->getMessage();
    }
}

if (isset($_GET['op']) && $_GET['op'] == 'unban' && isset($_GET['id'])) {
    // Kullanıcı engelini kaldırma işlemi (Gerçek veritabanı)
    $userId = (int)$_GET['id'];
    
    try {
        // PostgreSQL boolean için true/false kullanılmalı
        $query = "UPDATE users SET is_verified = true WHERE id = ?";
        $stmt = $db->prepare($query);
        $stmt->bind_param("i", $userId);
        $result = $stmt->execute();
        
        if ($result) {
            $success_message = 'Kullanıcı engeli başarıyla kaldırıldı.';
        } else {
            $error_message = 'Kullanıcı engeli kaldırılırken bir hata oluştu.';
        }
    } catch (Exception $e) {
        $error_message = 'Veritabanı hatası: ' . $e->getMessage();
    }
}

// Veritabanından kullanıcıları çek
try {
    $query = "SELECT * FROM users ORDER BY id DESC";
    $result = $db->query($query);
    $users = [];
    
    while ($row = $result->fetch_assoc()) {
        $users[] = $row;
    }
} catch (Exception $e) {
    $error_message = 'Kullanıcılar alınırken bir hata oluştu: ' . $e->getMessage();
    // Hata durumunda gösterilecek örnek boş liste
    $users = [];
}

// Kullanıcı Düzenleme Ekranı
if (isset($_GET['op']) && $_GET['op'] == 'edit' && isset($_GET['id'])) {
    $userId = (int)$_GET['id'];
    
    // Veritabanından kullanıcıyı çek
    try {
        $query = "SELECT * FROM users WHERE id = ?";
        $stmt = $db->prepare($query);
        $stmt->bind_param("i", $userId);
        $stmt->execute();
        $result = $stmt->get_result();
        $user = $result->fetch_assoc();
    } catch (Exception $e) {
        $error_message = 'Kullanıcı bilgileri alınırken bir hata oluştu: ' . $e->getMessage();
        $user = null;
    }
    
    if ($user) {
        ?>
        <div class="container mt-4">
            <div class="card">
                <div class="card-header bg-primary text-white">
                    <h5 class="mb-0">Kullanıcı Düzenle</h5>
                </div>
                <div class="card-body">
                    <form method="post" action="?page=users">
                        <input type="hidden" name="user_id" value="<?php echo $user['id']; ?>">
                        
                        <div class="mb-3">
                            <label for="username" class="form-label">Kullanıcı Adı</label>
                            <input type="text" class="form-control" id="username" name="username" value="<?php echo isset($user['username']) ? $user['username'] : ''; ?>" required>
                        </div>
                        
                        <div class="mb-3">
                            <label for="email" class="form-label">E-posta</label>
                            <input type="email" class="form-control" id="email" name="email" value="<?php echo isset($user['email']) ? $user['email'] : ''; ?>" required>
                        </div>
                        
                        <div class="mb-3">
                            <label for="user_level" class="form-label">Kullanıcı Seviyesi</label>
                            <select class="form-select" id="user_level" name="user_level" required>
                                <option value="newUser" <?php echo ($user['level'] == 'newUser') ? 'selected' : ''; ?>>Yeni Kullanıcı</option>
                                <option value="contributor" <?php echo ($user['level'] == 'contributor') ? 'selected' : ''; ?>>Katkıda Bulunan</option>
                                <option value="active" <?php echo ($user['level'] == 'active') ? 'selected' : ''; ?>>Aktif Kullanıcı</option>
                                <option value="expert" <?php echo ($user['level'] == 'expert') ? 'selected' : ''; ?>>Uzman</option>
                                <option value="master" <?php echo ($user['level'] == 'master') ? 'selected' : ''; ?>>Usta</option>
                            </select>
                        </div>
                        
                        <div class="mb-3">
                            <label for="points" class="form-label">Kullanıcı Puanı</label>
                            <input type="number" class="form-control" id="points" name="points" value="<?php echo isset($user['points']) ? $user['points'] : 0; ?>" min="0">
                        </div>
                        
                        <div class="mb-3 form-check">
                            <input type="checkbox" class="form-check-input" id="status" name="status" <?php echo ($user['is_verified'] == 1) ? 'checked' : ''; ?>>
                            <label class="form-check-label" for="status">Aktif</label>
                        </div>
                        
                        <div class="d-grid gap-2 d-md-flex justify-content-md-end">
                            <a href="?page=users" class="btn btn-secondary me-md-2">İptal</a>
                            <button type="submit" name="update_user" class="btn btn-primary">Güncelle</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
        <?php
    } else {
        echo '<div class="alert alert-danger">Kullanıcı bulunamadı.</div>';
    }
} else {
    // Kullanıcılar Listesi
    ?>
    <div class="container-fluid mt-4">
        <?php if (isset($success_message)): ?>
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <?php echo $success_message; ?>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        <?php endif; ?>
        
        <div class="card shadow mb-4">
            <div class="card-header py-3 d-flex justify-content-between align-items-center">
                <h6 class="m-0 font-weight-bold text-primary">Kullanıcılar</h6>
            </div>
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-bordered" id="dataTable" width="100%" cellspacing="0">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Kullanıcı Adı</th>
                                <th>E-posta</th>
                                <th>Seviye</th>
                                <th>Puan</th>
                                <th>Durum</th>
                                <th>Kayıt Tarihi</th>
                                <th>İşlemler</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php 
                            if (empty($users)): 
                            ?>
                                <tr>
                                    <td colspan="8" class="text-center">Henüz kayıtlı kullanıcı bulunmamaktadır.</td>
                                </tr>
                            <?php 
                            else:
                                foreach ($users as $user): 
                            ?>
                                <tr>
                                    <td><?php echo $user['id']; ?></td>
                                    <td><?php echo $user['username'] ?? $user['email']; ?></td>
                                    <td><?php echo $user['email']; ?></td>
                                    <td><?php echo formatUserLevel($user['level']); ?></td>
                                    <td><?php echo $user['points'] ?? 0; ?></td>
                                    <td>
                                        <?php if ($user['is_verified'] == 1 || $user['is_verified'] === true || $user['is_verified'] === 't'): ?>
                                            <span class="badge bg-success">Aktif</span>
                                        <?php else: ?>
                                            <span class="badge bg-danger">Engelli</span>
                                        <?php endif; ?>
                                    </td>
                                    <td><?php echo isset($user['created_at']) ? date('d.m.Y H:i', strtotime($user['created_at'])) : 'Bilinmiyor'; ?></td>
                                    <td>
                                        <a href="?page=users&op=edit&id=<?php echo $user['id']; ?>" class="btn btn-sm btn-primary me-1"><i class="bi bi-pencil"></i></a>
                                        <?php if ($user['is_verified'] == 1 || $user['is_verified'] === true || $user['is_verified'] === 't'): ?>
                                            <a href="?page=users&op=ban&id=<?php echo $user['id']; ?>" class="btn btn-sm btn-danger" onclick="return confirm('Bu kullanıcıyı engellemek istediğinizden emin misiniz?');"><i class="bi bi-ban"></i></a>
                                        <?php else: ?>
                                            <a href="?page=users&op=unban&id=<?php echo $user['id']; ?>" class="btn btn-sm btn-success"><i class="bi bi-check-circle"></i></a>
                                        <?php endif; ?>
                                    </td>
                                </tr>
                            <?php 
                                endforeach; 
                            endif;
                            ?>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
    <?php
}

// Kullanıcı seviyesi formatla
function formatUserLevel($level) {
    switch ($level) {
        case 'newUser':
            return 'Yeni Kullanıcı';
        case 'contributor':
            return 'Katkıda Bulunan';
        case 'active':
            return 'Aktif Kullanıcı';
        case 'expert':
            return 'Uzman';
        case 'master':
            return 'Usta';
        default:
            return 'Bilinmiyor';
    }
}
?>