<?php
// React Native Mobil Uygulama Yönetim Sayfası
requireAdmin();

// Eklenti yüklü ve aktif mi kontrol et
$plugin_active = isPluginActive($db, 'react_native_app');
if (!$plugin_active) {
    echo '<div class="alert alert-warning">
            <h4>React Native Mobil Uygulama eklentisi aktif değil!</h4>
            <p>Bu özelliği kullanmak için önce <a href="?page=plugins">Eklenti Yönetimi</a> sayfasından eklentiyi etkinleştirin.</p>
          </div>';
    return;
}

// Eklenti dosyalarını dahil et
if (file_exists(__DIR__ . '/../plugins/react_native_app/main.php')) {
    require_once __DIR__ . '/../plugins/react_native_app/main.php';
} else {
    echo '<div class="alert alert-danger">
            <h4>Eklenti dosyaları bulunamadı!</h4>
            <p>React Native Mobil Uygulama eklentisi dosyaları eksik veya hasarlı olabilir.</p>
          </div>';
    return;
}

// Eklenti ayarlarını al
$app_settings = get_app_settings($db);

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
                    <div class="table-responsive">
                        <table class="table table-striped">
                            <tbody>
                                <tr>
                                    <th style="width: 30%">Uygulama Adı</th>
                                    <td><?= htmlspecialchars($app_settings['app_name'] ?? 'ŞikayetVar') ?></td>
                                </tr>
                                <tr>
                                    <th>Versiyon</th>
                                    <td><?= htmlspecialchars($app_settings['app_version'] ?? '1.0.0') ?></td>
                                </tr>
                                <tr>
                                    <th>API URL</th>
                                    <td><?= htmlspecialchars($app_settings['api_url'] ?? 'https://workspace.mail852.repl.co/api') ?></td>
                                </tr>
                                <tr>
                                    <th>Ana Renk</th>
                                    <td>
                                        <div class="d-flex align-items-center">
                                            <div style="width: 20px; height: 20px; background-color: <?= htmlspecialchars($app_settings['primary_color'] ?? '#1976d2') ?>; border-radius: 4px; margin-right: 10px;"></div>
                                            <?= htmlspecialchars($app_settings['primary_color'] ?? '#1976d2') ?>
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <th>Aktif Özellikler</th>
                                    <td>
                                        <?php
                                        $features = explode(',', $app_settings['features'] ?? 'complaints,surveys,pharmacies,profile');
                                        foreach ($features as $feature) {
                                            echo '<span class="badge bg-primary me-1">' . trim($feature) . '</span>';
                                        }
                                        ?>
                                    </td>
                                </tr>
                                <tr>
                                    <th>Push Bildirimleri</th>
                                    <td><?= ($app_settings['enable_push_notifications'] ?? '1') === '1' ? '<span class="badge bg-success">Aktif</span>' : '<span class="badge bg-secondary">Pasif</span>' ?></td>
                                </tr>
                                <tr>
                                    <th>Debug Modu</th>
                                    <td><?= ($app_settings['debug_mode'] ?? '1') === '1' ? '<span class="badge bg-warning">Aktif</span>' : '<span class="badge bg-secondary">Pasif</span>' ?></td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                    
                    <div class="mt-3">
                        <a href="?page=plugins" class="btn btn-primary">
                            <i class="bi bi-gear me-1"></i> Uygulama Ayarlarını Düzenle
                        </a>
                    </div>
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
                    <strong>Kullanım Talimatları</strong>
                </div>
                <div class="card-body">
                    <h5>Gereksinimler</h5>
                    <ul>
                        <li>Node.js 18 veya üstü</li>
                        <li>npm veya yarn</li>
                        <li>JDK 11</li>
                        <li>Android Studio (Android için)</li>
                        <li>Xcode (iOS için)</li>
                    </ul>
                    
                    <h5>Kurulum Adımları</h5>
                    <ol>
                        <li>"React Native Projesi Oluştur" butonuna tıklayın</li>
                        <li>Oluşturulan <code>react_native_app</code> klasörüne gidin</li>
                        <li>Terminal'de <code>npm install</code> komutunu çalıştırın</li>
                        <li>
                            Android için:
                            <ul>
                                <li>Android Studio'yu yükleyin ve bir emülatör oluşturun</li>
                                <li>Terminal'de <code>npm run android</code> komutunu çalıştırın</li>
                            </ul>
                        </li>
                        <li>
                            iOS için (sadece macOS):
                            <ul>
                                <li><code>ios</code> klasöründe <code>pod install</code> komutunu çalıştırın</li>
                                <li>Terminal'de <code>npm run ios</code> komutunu çalıştırın</li>
                            </ul>
                        </li>
                    </ol>
                    
                    <div class="alert alert-warning">
                        <i class="bi bi-info-circle me-2"></i> React Native ile geliştirmeyi tercih etmek, Flutter ile yaşanan derleme sorunlarını çözmeye yardımcı olabilir. Özellikle Flutter'in kullandığı bazı native bağımlılıklarla ve versiyonlama sorunlarıyla karşılaşma olasılığınız daha düşüktür.
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>