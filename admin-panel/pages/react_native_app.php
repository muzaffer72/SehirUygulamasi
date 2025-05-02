<?php
// React Native Mobil Uygulama Yönetim Sayfası
// Eklenti sistemi olmadan çalışacak şekilde düzenlendi

// Sadece yöneticilerin erişmesini sağla
if (!isset($_SESSION['user']) || $_SESSION['user']['role'] !== 'admin') {
    header('Location: index.php');
    exit;
}

// React Native uygulama ayarlarını getir
$default_settings = [
    'app_name' => 'ŞikayetVar',
    'app_version' => '1.0.0',
    'api_url' => 'https://workspace.mail852.repl.co/api',
    'primary_color' => '#1976d2',
    'features' => 'complaints,surveys,pharmacies,profile',
    'enable_push_notifications' => '1',
    'debug_mode' => '1'
];

// Settings tablosundan ayarları al veya varsayılanları kullan
$app_settings = $default_settings;
$result = $db->query("SELECT value FROM settings WHERE name='react_native_app_settings'");
if ($result && $result->num_rows > 0) {
    $row = $result->fetch_assoc();
    $app_settings = json_decode($row['value'], true);
    if (!$app_settings) {
        $app_settings = $default_settings;
    }
}

// React Native projesi oluşturma fonksiyonu
function create_react_native_project($settings) {
    // React Native proje klasörü yolunu belirle
    $project_path = __DIR__ . '/../../react_native_app';
    
    // Klasör yoksa oluştur
    if (!file_exists($project_path)) {
        mkdir($project_path, 0755, true);
    }
    
    // Temel dosyaları oluştur
    $readme_content = <<<EOT
# {$settings['app_name']} React Native Uygulaması

Bu proje, ŞikayetVar platformunun React Native versiyonudur.

## Kurulum

1. Node.js 18 veya üstü yükleyin
2. `npm install` komutunu çalıştırın
3. Android için: Android Studio'yu yükleyin ve bir emülatör oluşturun
4. iOS için (sadece macOS): `cd ios && pod install` komutunu çalıştırın

## Çalıştırma

- Android: `npm run android`
- iOS: `npm run ios`
- Metro sunucusu: `npm start`

## Özellikler

- Şikayet gönderme ve takip etme
- Anketlere katılma
- Nöbetçi eczane bulma
- Kullanıcı profili yönetimi

## API Bağlantısı

API URL: {$settings['api_url']}

## Sürüm Geçmişi

- {$settings['app_version']}: İlk sürüm
EOT;
    file_put_contents($project_path . '/README.md', $readme_content);
    
    return [
        'success' => true,
        'message' => 'React Native Projesi başarıyla oluşturuldu!',
        'path' => $project_path
    ];
}

// Form verilerini işle
$success_message = '';
$error_message = '';

if (isset($_POST['build_app'])) {
    try {
        $result = create_react_native_project($app_settings);
        if ($result['success']) {
            $success_message = $result['message'] . ' - Konum: ' . $result['path'];
        } else {
            $error_message = $result['message'] ?? 'Proje oluşturulurken bir hata oluştu.';
        }
    } catch (Exception $e) {
        $error_message = 'Proje oluşturulurken bir hata oluştu: ' . $e->getMessage();
    }
}

// Ayarları kaydetme
if (isset($_POST['save_settings'])) {
    // Form verilerini al
    $app_settings = [
        'app_name' => $_POST['app_name'] ?? 'ŞikayetVar',
        'app_version' => $_POST['app_version'] ?? '1.0.0',
        'api_url' => $_POST['api_url'] ?? 'https://workspace.mail852.repl.co/api',
        'primary_color' => $_POST['primary_color'] ?? '#1976d2',
        'features' => $_POST['features'] ?? 'complaints,surveys,pharmacies,profile',
        'enable_push_notifications' => $_POST['enable_push_notifications'] ?? '0',
        'debug_mode' => $_POST['debug_mode'] ?? '0',
    ];
    
    // PostgreSQL ile uyumlu kaydetme işlemi
    $settings_json = json_encode($app_settings);
    $check_result = $db->query("SELECT * FROM settings WHERE name='react_native_app_settings'");
    
    if ($check_result && $check_result->num_rows > 0) {
        // Güncelle
        $stmt = $db->prepare("UPDATE settings SET value = ? WHERE name = 'react_native_app_settings'");
        $stmt->bind_param('s', $settings_json);
        if ($stmt->execute()) {
            $success_message = "Uygulama ayarları başarıyla güncellendi.";
        } else {
            $error_message = "Ayarlar güncellenirken bir hata oluştu.";
        }
    } else {
        // Yeni ekle
        $stmt = $db->prepare("INSERT INTO settings (name, value) VALUES ('react_native_app_settings', ?)");
        $stmt->bind_param('s', $settings_json);
        if ($stmt->execute()) {
            $success_message = "Uygulama ayarları başarıyla kaydedildi.";
        } else {
            $error_message = "Ayarlar kaydedilirken bir hata oluştu.";
        }
    }
}
?>

<div class="container-fluid py-4">
    <h1 class="mb-4">React Native Mobil Uygulama Yönetimi</h1>
    
    <?php if ($success_message): ?>
        <div class="alert alert-success alert-dismissible fade show">
            <?= $success_message ?>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    <?php endif; ?>
    
    <?php if ($error_message): ?>
        <div class="alert alert-danger alert-dismissible fade show">
            <?= $error_message ?>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    <?php endif; ?>
    
    <div class="row">
        <div class="col-md-6">
            <div class="card mb-4">
                <div class="card-header">
                    <strong>Mobil Uygulama Bilgileri</strong>
                </div>
                <div class="card-body">
                    <form method="post" action="">
                        <div class="mb-3">
                            <label for="app_name" class="form-label">Uygulama Adı</label>
                            <input type="text" class="form-control" id="app_name" name="app_name" value="<?= htmlspecialchars($app_settings['app_name']) ?>">
                        </div>
                        
                        <div class="mb-3">
                            <label for="app_version" class="form-label">Versiyon</label>
                            <input type="text" class="form-control" id="app_version" name="app_version" value="<?= htmlspecialchars($app_settings['app_version']) ?>">
                        </div>
                        
                        <div class="mb-3">
                            <label for="api_url" class="form-label">API URL</label>
                            <input type="text" class="form-control" id="api_url" name="api_url" value="<?= htmlspecialchars($app_settings['api_url']) ?>">
                        </div>
                        
                        <div class="mb-3">
                            <label for="primary_color" class="form-label">Ana Renk</label>
                            <div class="input-group">
                                <input type="color" class="form-control form-control-color" id="primary_color" name="primary_color" value="<?= htmlspecialchars($app_settings['primary_color']) ?>">
                                <input type="text" class="form-control" id="primary_color_text" value="<?= htmlspecialchars($app_settings['primary_color']) ?>">
                            </div>
                        </div>
                        
                        <div class="mb-3">
                            <label for="features" class="form-label">Aktif Özellikler (virgülle ayrılmış)</label>
                            <input type="text" class="form-control" id="features" name="features" value="<?= htmlspecialchars($app_settings['features']) ?>">
                            <div class="form-text">Örnek: complaints,surveys,pharmacies,profile</div>
                        </div>
                        
                        <div class="mb-3 form-check">
                            <input type="checkbox" class="form-check-input" id="enable_push_notifications" name="enable_push_notifications" value="1" <?= ($app_settings['enable_push_notifications'] === '1') ? 'checked' : '' ?>>
                            <label class="form-check-label" for="enable_push_notifications">Push Bildirimlerini Etkinleştir</label>
                        </div>
                        
                        <div class="mb-3 form-check">
                            <input type="checkbox" class="form-check-input" id="debug_mode" name="debug_mode" value="1" <?= ($app_settings['debug_mode'] === '1') ? 'checked' : '' ?>>
                            <label class="form-check-label" for="debug_mode">Debug Modunu Etkinleştir</label>
                        </div>
                        
                        <button type="submit" name="save_settings" class="btn btn-primary">Ayarları Kaydet</button>
                    </form>
                </div>
            </div>
            
            <div class="card mb-4">
                <div class="card-header">
                    <strong>Uygulama Oluştur</strong>
                </div>
                <div class="card-body">
                    <p class="text-muted mb-3">React Native teknolojisini kullanarak Android ve iOS uygulamaları oluşturun.</p>
                    
                    <form method="post" action="">
                        <div class="d-grid">
                            <button type="submit" name="build_app" class="btn btn-success">
                                <i class="bi bi-phone me-1"></i> React Native Projesi Oluştur
                            </button>
                        </div>
                    </form>
                    
                    <div class="mt-3">
                        <h5>Proje Klasörü</h5>
                        <div class="alert alert-info">
                            <p class="mb-0">
                                <strong>Konum:</strong> <code>react_native_app/</code>
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="col-md-6">
            <div class="card mb-4">
                <div class="card-header">
                    <strong>React Native vs Flutter Karşılaştırması</strong>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-striped">
                            <thead>
                                <tr>
                                    <th></th>
                                    <th>React Native</th>
                                    <th>Flutter</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <th>Programlama Dili</th>
                                    <td>JavaScript / TypeScript</td>
                                    <td>Dart</td>
                                </tr>
                                <tr>
                                    <th>Geliştirici</th>
                                    <td>Facebook</td>
                                    <td>Google</td>
                                </tr>
                                <tr>
                                    <th>Öğrenme Kolaylığı</th>
                                    <td><i class="bi bi-star-fill text-primary"></i> <i class="bi bi-star-fill text-primary"></i> <i class="bi bi-star-fill text-primary"></i> <i class="bi bi-star-fill text-primary"></i> <i class="bi bi-star text-primary"></i></td>
                                    <td><i class="bi bi-star-fill text-primary"></i> <i class="bi bi-star-fill text-primary"></i> <i class="bi bi-star-fill text-primary"></i> <i class="bi bi-star text-primary"></i> <i class="bi bi-star text-primary"></i></td>
                                </tr>
                                <tr>
                                    <th>Performans</th>
                                    <td><i class="bi bi-star-fill text-primary"></i> <i class="bi bi-star-fill text-primary"></i> <i class="bi bi-star-fill text-primary"></i> <i class="bi bi-star text-primary"></i> <i class="bi bi-star text-primary"></i></td>
                                    <td><i class="bi bi-star-fill text-primary"></i> <i class="bi bi-star-fill text-primary"></i> <i class="bi bi-star-fill text-primary"></i> <i class="bi bi-star-fill text-primary"></i> <i class="bi bi-star-fill text-primary"></i></td>
                                </tr>
                                <tr>
                                    <th>Topluluk Desteği</th>
                                    <td><i class="bi bi-star-fill text-primary"></i> <i class="bi bi-star-fill text-primary"></i> <i class="bi bi-star-fill text-primary"></i> <i class="bi bi-star-fill text-primary"></i> <i class="bi bi-star-fill text-primary"></i></td>
                                    <td><i class="bi bi-star-fill text-primary"></i> <i class="bi bi-star-fill text-primary"></i> <i class="bi bi-star-fill text-primary"></i> <i class="bi bi-star-fill text-primary"></i> <i class="bi bi-star text-primary"></i></td>
                                </tr>
                                <tr>
                                    <th>Paket Ekosistemi</th>
                                    <td><i class="bi bi-star-fill text-primary"></i> <i class="bi bi-star-fill text-primary"></i> <i class="bi bi-star-fill text-primary"></i> <i class="bi bi-star-fill text-primary"></i> <i class="bi bi-star-fill text-primary"></i></td>
                                    <td><i class="bi bi-star-fill text-primary"></i> <i class="bi bi-star-fill text-primary"></i> <i class="bi bi-star-fill text-primary"></i> <i class="bi bi-star-fill text-primary"></i> <i class="bi bi-star text-primary"></i></td>
                                </tr>
                                <tr>
                                    <th>Derleme Kolaylığı</th>
                                    <td><i class="bi bi-star-fill text-primary"></i> <i class="bi bi-star-fill text-primary"></i> <i class="bi bi-star-fill text-primary"></i> <i class="bi bi-star-fill text-primary"></i> <i class="bi bi-star text-primary"></i></td>
                                    <td><i class="bi bi-star-fill text-primary"></i> <i class="bi bi-star-fill text-primary"></i> <i class="bi bi-star text-primary"></i> <i class="bi bi-star text-primary"></i> <i class="bi bi-star text-primary"></i></td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
            
            <div class="card mb-4">
                <div class="card-header">
                    <strong>Örnek Ekran Görünümü: Nöbetçi Eczaneler</strong>
                </div>
                <div class="card-body">
                    <div class="bg-light p-3 rounded mb-3" style="font-family: 'Courier New', monospace; font-size: 0.9rem;">
<pre style="white-space: pre-wrap;">
/**
 * Nöbetçi Eczaneler Ekranı
 */

import React, { useState, useEffect } from 'react';
import { View, FlatList, Text, ActivityIndicator } from 'react-native';
import { fetchPharmacies } from '../services/pharmacyService';

const PharmaciesScreen = () => {
  const [loading, setLoading] = useState(true);
  const [pharmacies, setPharmacies] = useState([]);
  
  useEffect(() => {
    loadPharmacies();
  }, []);

  const loadPharmacies = async () => {
    try {
      const city = 'Ankara';
      const district = 'Çankaya';
      const result = await fetchPharmacies(city, district);
      setPharmacies(result.pharmacies);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  // Ekran render edilmesi...
}
</pre>
                    </div>
                    <p class="text-muted">Bu ekran, nöbetçi eczaneleri API üzerinden alarak listeliyor ve kullanıcıya harita üzerinde yol tarifi sağlıyor.</p>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
document.getElementById('primary_color').addEventListener('input', function() {
    document.getElementById('primary_color_text').value = this.value;
});

document.getElementById('primary_color_text').addEventListener('input', function() {
    document.getElementById('primary_color').value = this.value;
});
</script>