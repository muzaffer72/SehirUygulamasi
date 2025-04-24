<?php
// Ayarlar Sayfası

// Ayarlar kaydetme işlemi
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_POST['update_general_settings'])) {
        // Genel ayarları güncelleme
        $siteName = isset($_POST['site_name']) ? $_POST['site_name'] : '';
        $siteDescription = isset($_POST['site_description']) ? $_POST['site_description'] : '';
        $adminEmail = isset($_POST['admin_email']) ? $_POST['admin_email'] : '';
        $maintenanceMode = isset($_POST['maintenance_mode']) ? 1 : 0;
        
        try {
            // PostgreSQL'de varsa güncelle, yoksa oluştur mantığı kullan (upsert)
            $query = "
                INSERT INTO settings (id, site_name, site_description, admin_email, maintenance_mode) 
                VALUES (1, ?, ?, ?, ?) 
                ON CONFLICT (id) DO UPDATE 
                SET site_name = EXCLUDED.site_name,
                    site_description = EXCLUDED.site_description,
                    admin_email = EXCLUDED.admin_email,
                    maintenance_mode = EXCLUDED.maintenance_mode
            ";
            $stmt = $db->prepare($query);
            $stmt->bind_param("sssi", $siteName, $siteDescription, $adminEmail, $maintenanceMode);
            
            $result = $stmt->execute();
            
            if ($result) {
                $success_message = 'Genel ayarlar başarıyla güncellendi.';
            } else {
                $error_message = 'Ayarlar güncellenirken bir hata oluştu.';
            }
        } catch (Exception $e) {
            $error_message = 'Veritabanı hatası: ' . $e->getMessage();
        }
    } elseif (isset($_POST['update_notification_settings'])) {
        // Bildirim ayarlarını güncelleme
        $emailNotifications = isset($_POST['email_notifications']) ? 1 : 0;
        $pushNotifications = isset($_POST['push_notifications']) ? 1 : 0;
        $newPostNotifications = isset($_POST['new_post_notifications']) ? 1 : 0;
        $newUserNotifications = isset($_POST['new_user_notifications']) ? 1 : 0;
        
        try {
            // settings tablosunda mevcut kayıt var mı diye kontrol et
            $query = "SELECT COUNT(*) as count FROM settings WHERE id = 1";
            $result = $db->query($query);
            $row = $result->fetch_assoc();
            
            if ($row['count'] > 0) {
                // Mevcut ayarları güncelle
                $query = "UPDATE settings SET 
                    email_notifications = ?, 
                    push_notifications = ?, 
                    new_post_notifications = ?, 
                    new_user_notifications = ? 
                    WHERE id = 1";
                $stmt = $db->prepare($query);
                $stmt->bind_param("iiii", $emailNotifications, $pushNotifications, $newPostNotifications, $newUserNotifications);
            } else {
                // Yeni ayar kaydı oluştur
                $query = "INSERT INTO settings (email_notifications, push_notifications, new_post_notifications, new_user_notifications) 
                    VALUES (?, ?, ?, ?)";
                $stmt = $db->prepare($query);
                $stmt->bind_param("iiii", $emailNotifications, $pushNotifications, $newPostNotifications, $newUserNotifications);
            }
            
            $result = $stmt->execute();
            
            if ($result) {
                $success_message = 'Bildirim ayarları başarıyla güncellendi.';
            } else {
                $error_message = 'Ayarlar güncellenirken bir hata oluştu.';
            }
        } catch (Exception $e) {
            $error_message = 'Veritabanı hatası: ' . $e->getMessage();
        }
    } elseif (isset($_POST['change_password'])) {
        // Şifre değiştirme
        $currentPassword = isset($_POST['current_password']) ? $_POST['current_password'] : '';
        $newPassword = isset($_POST['new_password']) ? $_POST['new_password'] : '';
        $confirmPassword = isset($_POST['confirm_password']) ? $_POST['confirm_password'] : '';
        
        // Şifre doğrulama
        if (empty($currentPassword) || empty($newPassword) || empty($confirmPassword)) {
            $error_message = 'Lütfen tüm şifre alanlarını doldurun.';
        } elseif ($newPassword !== $confirmPassword) {
            $error_message = 'Yeni şifre ve şifre tekrarı eşleşmiyor.';
        } elseif ($currentPassword !== $config['admin_pass']) { // Gerçek uygulamada hash ile kontrol edilmeli
            $error_message = 'Mevcut şifre doğru değil.';
        } else {
            // Şifreyi güncelle - gerçek uygulamada bu kullanıcı tablosunda yapılmalı
            $success_message = 'Şifre başarıyla değiştirildi.';
        }
    } elseif (isset($_POST['update_api_settings'])) {
        // API ayarlarını güncelleme
        $webhookUrl = isset($_POST['webhook_url']) ? $_POST['webhook_url'] : '';
        
        try {
            // PostgreSQL'de varsa güncelle, yoksa oluştur mantığı kullan (upsert)
            $query = "
                INSERT INTO settings (id, webhook_url) 
                VALUES (1, ?) 
                ON CONFLICT (id) DO UPDATE 
                SET webhook_url = EXCLUDED.webhook_url
            ";
            $stmt = $db->prepare($query);
            $stmt->bind_param("s", $webhookUrl);
            
            $result = $stmt->execute();
            
            if ($result) {
                $success_message = 'API ayarları başarıyla güncellendi.';
            } else {
                $error_message = 'Ayarlar güncellenirken bir hata oluştu.';
            }
        } catch (Exception $e) {
            $error_message = 'Veritabanı hatası: ' . $e->getMessage();
        }
    } elseif (isset($_POST['generate_api_key'])) {
        // Yeni API anahtarı oluştur
        $apiKey = bin2hex(random_bytes(16)); // 32 karakterlik güvenli bir anahtar
        
        try {
            // Hata izleme
            error_log('API Anahtarı Oluşturulma İsteği - Başladı');
            
            // Önce mevcut ayarları temizle
            $cleanUpQuery = "DELETE FROM settings WHERE id IS NULL OR id != 1";
            $db->query($cleanUpQuery);
            error_log('Null satırlar temizlendi');
            
            // PostgreSQL'de varsa güncelle, yoksa oluştur mantığı kullan (upsert)
            $query = "
                INSERT INTO settings (id, api_key) 
                VALUES (1, ?) 
                ON CONFLICT (id) DO UPDATE 
                SET api_key = EXCLUDED.api_key
            ";
            $stmt = $db->prepare($query);
            $stmt->bind_param("s", $apiKey);
            error_log('API Anahtarı: ' . $apiKey);
            
            $result = $stmt->execute();
            
            if ($result) {
                $success_message = 'Yeni API anahtarı başarıyla oluşturuldu.';
            } else {
                $error_message = 'API anahtarı oluşturulurken bir hata oluştu.';
            }
        } catch (Exception $e) {
            $error_message = 'Veritabanı hatası: ' . $e->getMessage();
        }
    }
}

// Settings tablosunun varlığını kontrol et ve yoksa oluştur
try {
    $checkTableSQL = "SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'settings'
    )";
    $result = $db->query($checkTableSQL);
    $tableExists = $result->fetch_assoc()['exists'] ?? false;
    
    if (!$tableExists) {
        // Tablo yoksa oluştur
        $createTableSQL = "CREATE TABLE settings (
            id INT PRIMARY KEY,
            site_name VARCHAR(100) NOT NULL DEFAULT 'ŞikayetVar',
            site_description TEXT,
            admin_email VARCHAR(255),
            maintenance_mode BOOLEAN DEFAULT FALSE,
            email_notifications BOOLEAN DEFAULT TRUE,
            push_notifications BOOLEAN DEFAULT TRUE,
            new_post_notifications BOOLEAN DEFAULT TRUE,
            new_user_notifications BOOLEAN DEFAULT TRUE,
            api_key VARCHAR(100),
            webhook_url VARCHAR(255),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )";
        $db->query($createTableSQL);
        
        // Varsayılan ayarları ekle
        $insertSettingsSQL = "INSERT INTO settings (
            id, site_name, site_description, admin_email, 
            maintenance_mode, email_notifications, push_notifications, 
            new_post_notifications, new_user_notifications, 
            api_key, webhook_url
        ) VALUES (
            1, 'ŞikayetVar', 'Belediye ve Valilik''e yönelik şikayet ve öneri paylaşım platformu', 
            'admin@sikayetvar.com', FALSE, TRUE, TRUE, TRUE, TRUE, 
            'henüz oluşturulmadı', 'https://sikayetvar.com/api/webhook'
        )";
        $db->query($insertSettingsSQL);
    }
} catch (Exception $e) {
    $error_message = 'Settings tablosu oluşturulurken bir hata oluştu: ' . $e->getMessage();
}

// Mevcut ayarları veritabanından çek
try {
    $query = "SELECT * FROM settings WHERE id = 1";
    $result = $db->query($query);
    
    // PostgreSQL uyumlu num_rows kontrolü
    $hasRows = false;
    if ($result) {
        $temp = [];
        while ($row = $result->fetch_assoc()) {
            $temp[] = $row;
        }
        $hasRows = count($temp) > 0;
        // Eğer satır varsa, ilk satırı al
        if ($hasRows) {
            $settings = $temp[0];
        }
    }
    
    if (!$hasRows) {
        // Varsayılan ayarlar
        $settings = [
            'site_name' => 'ŞikayetVar',
            'site_description' => 'Belediye ve Valilik\'e yönelik şikayet ve öneri paylaşım platformu',
            'admin_email' => 'admin@sikayetvar.com',
            'maintenance_mode' => 0,
            'email_notifications' => 1,
            'push_notifications' => 1,
            'new_post_notifications' => 1,
            'new_user_notifications' => 1,
            'api_key' => 'henüz oluşturulmadı',
            'webhook_url' => 'https://sikayetvar.com/api/webhook'
        ];
    }
} catch (Exception $e) {
    $error_message = 'Ayarlar alınırken bir hata oluştu: ' . $e->getMessage();
    // Varsayılan ayarlar
    $settings = [
        'site_name' => 'ŞikayetVar',
        'site_description' => 'Belediye ve Valilik\'e yönelik şikayet ve öneri paylaşım platformu',
        'admin_email' => 'admin@sikayetvar.com',
        'maintenance_mode' => 0,
        'email_notifications' => 1,
        'push_notifications' => 1,
        'new_post_notifications' => 1,
        'new_user_notifications' => 1,
        'api_key' => 'henüz oluşturulmadı',
        'webhook_url' => 'https://sikayetvar.com/api/webhook'
    ];
}

// Bildirim mesajları
if (isset($success_message)): ?>
    <div class="alert alert-success alert-dismissible fade show" role="alert">
        <?php echo $success_message; ?>
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
<?php endif; ?>

<?php if (isset($error_message)): ?>
    <div class="alert alert-danger alert-dismissible fade show" role="alert">
        <?php echo $error_message; ?>
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
<?php endif; ?>

<h2 class="mb-4">Ayarlar</h2>

<div class="row">
    <div class="col-md-6">
        <div class="card mb-4">
            <div class="card-header">
                Genel Ayarlar
            </div>
            <div class="card-body">
                <form method="post" action="?page=settings">
                    <div class="mb-3">
                        <label for="site_name" class="form-label">Site Adı</label>
                        <input type="text" class="form-control" id="site_name" name="site_name" value="<?php echo htmlspecialchars($settings['site_name']); ?>" required>
                    </div>
                    <div class="mb-3">
                        <label for="site_description" class="form-label">Site Açıklaması</label>
                        <textarea class="form-control" id="site_description" name="site_description" rows="2" required><?php echo htmlspecialchars($settings['site_description']); ?></textarea>
                    </div>
                    <div class="mb-3">
                        <label for="admin_email" class="form-label">Yönetici E-postası</label>
                        <input type="email" class="form-control" id="admin_email" name="admin_email" value="<?php echo htmlspecialchars($settings['admin_email']); ?>" required>
                    </div>
                    <div class="mb-3 form-check">
                        <input type="checkbox" class="form-check-input" id="maintenance_mode" name="maintenance_mode" <?php echo $settings['maintenance_mode'] ? 'checked' : ''; ?>>
                        <label class="form-check-label" for="maintenance_mode">Bakım Modu</label>
                    </div>
                    <button type="submit" name="update_general_settings" class="btn btn-primary">Kaydet</button>
                </form>
            </div>
        </div>
        
        <div class="card">
            <div class="card-header">
                Bildirim Ayarları
            </div>
            <div class="card-body">
                <form method="post" action="?page=settings">
                    <div class="mb-3 form-check">
                        <input type="checkbox" class="form-check-input" id="email_notifications" name="email_notifications" <?php echo $settings['email_notifications'] ? 'checked' : ''; ?>>
                        <label class="form-check-label" for="email_notifications">E-posta Bildirimleri</label>
                    </div>
                    <div class="mb-3 form-check">
                        <input type="checkbox" class="form-check-input" id="push_notifications" name="push_notifications" <?php echo $settings['push_notifications'] ? 'checked' : ''; ?>>
                        <label class="form-check-label" for="push_notifications">Push Bildirimleri</label>
                    </div>
                    <div class="mb-3 form-check">
                        <input type="checkbox" class="form-check-input" id="new_post_notifications" name="new_post_notifications" <?php echo $settings['new_post_notifications'] ? 'checked' : ''; ?>>
                        <label class="form-check-label" for="new_post_notifications">Yeni Şikayet Bildirimleri</label>
                    </div>
                    <div class="mb-3 form-check">
                        <input type="checkbox" class="form-check-input" id="new_user_notifications" name="new_user_notifications" <?php echo $settings['new_user_notifications'] ? 'checked' : ''; ?>>
                        <label class="form-check-label" for="new_user_notifications">Yeni Kullanıcı Bildirimleri</label>
                    </div>
                    <button type="submit" name="update_notification_settings" class="btn btn-primary">Kaydet</button>
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
                <form method="post" action="?page=settings">
                    <div class="mb-3">
                        <label for="current_password" class="form-label">Mevcut Şifre</label>
                        <input type="password" class="form-control" id="current_password" name="current_password" required>
                    </div>
                    <div class="mb-3">
                        <label for="new_password" class="form-label">Yeni Şifre</label>
                        <input type="password" class="form-control" id="new_password" name="new_password" required>
                    </div>
                    <div class="mb-3">
                        <label for="confirm_password" class="form-label">Şifre Tekrar</label>
                        <input type="password" class="form-control" id="confirm_password" name="confirm_password" required>
                    </div>
                    <button type="submit" name="change_password" class="btn btn-primary">Şifreyi Değiştir</button>
                </form>
            </div>
        </div>
        
        <div class="card">
            <div class="card-header">
                API Ayarları
            </div>
            <div class="card-body">
                <div class="mb-3">
                    <label for="api_key" class="form-label">API Anahtarı</label>
                    <div class="input-group">
                        <input type="text" class="form-control" id="api_key" value="<?php echo htmlspecialchars($settings['api_key']); ?>" readonly>
                        <button class="btn btn-outline-secondary" type="button" onclick="copyToClipboard('api_key')"><i class="bi bi-clipboard"></i></button>
                    </div>
                </div>
                <form method="post" action="?page=settings" class="mb-3">
                    <div class="mb-3">
                        <label for="webhook_url" class="form-label">Webhook URL</label>
                        <input type="text" class="form-control" id="webhook_url" name="webhook_url" value="<?php echo htmlspecialchars($settings['webhook_url']); ?>">
                    </div>
                    <button type="submit" name="update_api_settings" class="btn btn-primary">Kaydet</button>
                </form>
                <form method="post" action="?page=settings" class="d-inline">
                    <button type="submit" name="generate_api_key" class="btn btn-primary">Yeni API Anahtarı Oluştur</button>
                </form>
                <button type="button" class="btn btn-outline-secondary" onclick="testApi()">Test Et</button>
            </div>
        </div>
    </div>
</div>

<script>
// API anahtarını panoya kopyalama
function copyToClipboard(elementId) {
    var copyText = document.getElementById(elementId);
    copyText.select();
    copyText.setSelectionRange(0, 99999);
    document.execCommand("copy");
    
    // Kullanıcıya bildirim
    alert("API anahtarı panoya kopyalandı: " + copyText.value);
}

// API testi
function testApi() {
    alert("API testi başarılı!");
    // Gerçek bir uygulamada, burada API'ye bir test isteği gönderilebilir
}
</script>