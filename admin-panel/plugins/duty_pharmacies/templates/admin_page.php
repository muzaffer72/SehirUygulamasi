<?php
// Nöbetçi Eczane Yönetim Sayfası
requireAdmin();

// Eklenti yüklü ve aktif mi kontrol et
$plugin_active = isPluginActive($db, 'duty_pharmacies');
if (!$plugin_active) {
    echo '<div class="alert alert-warning">
            <h4>Nöbetçi Eczaneler eklentisi aktif değil!</h4>
            <p>Bu özelliği kullanmak için önce <a href="?page=plugins">Eklenti Yönetimi</a> sayfasından eklentiyi etkinleştirin.</p>
          </div>';
    return;
}

// Eczane servisini kontrol et
$is_pharmacy_service_running = false;
$service_url = "http://0.0.0.0:5001/status";
$context = stream_context_create(['http' => ['timeout' => 2]]);
$response = @file_get_contents($service_url, false, $context);

if ($response !== false) {
    $data = json_decode($response, true);
    $is_pharmacy_service_running = isset($data['status']) && $data['status'] === 'running';
}

// Ayarları yükle
$settings = get_pharmacy_settings($db);

// Form verilerini işle
$success_message = '';
$error_message = '';

if (isset($_POST['save_settings'])) {
    $new_settings = [
        'google_maps_api_key' => $_POST['google_maps_api_key'] ?? '',
        'enable_directions' => isset($_POST['enable_directions']),
        'enable_proximity_search' => isset($_POST['enable_proximity_search']),
        'max_results' => intval($_POST['max_results'] ?? 20),
        'cache_time' => intval($_POST['cache_time'] ?? 3600),
        'display_phone' => isset($_POST['display_phone']),
        'display_address' => isset($_POST['display_address'])
    ];
    
    if (save_pharmacy_settings($db, $new_settings)) {
        $settings = $new_settings;
        $success_message = 'Ayarlar başarıyla kaydedildi!';
    } else {
        $error_message = 'Ayarlar kaydedilirken bir hata oluştu.';
    }
}

// Test için şehir ve ilçe verilerini al
$test_city = 'Ankara';
$test_district = 'Çankaya';

// Test verisi al
$test_pharmacies = [];
if ($is_pharmacy_service_running) {
    $test_data = get_duty_pharmacies($test_city, $test_district);
    $test_pharmacies = $test_data['pharmacies'] ?? [];
}
?>

<div class="container-fluid py-4">
    <h1 class="mb-4">Nöbetçi Eczaneler Yönetimi</h1>
    
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
                    <strong>Servis Durumu</strong>
                </div>
                <div class="card-body">
                    <?php if ($is_pharmacy_service_running): ?>
                        <div class="alert alert-success">
                            <h4 class="alert-heading"><i class="bi bi-check-circle-fill me-2"></i> Eczane Servisi Çalışıyor</h4>
                            <p>Nöbetçi eczane servisi şu anda aktif ve çalışıyor. Aşağıdaki yollarla ulaşabilirsiniz:</p>
                            <hr>
                            <p class="mb-0">
                                <strong>API URL:</strong> <code>http://0.0.0.0:5001/pharmacies</code><br>
                                <strong>Web Arayüzü:</strong> <a href="/mobile/pharmacies" target="_blank" class="btn btn-sm btn-primary mt-2">
                                    <i class="bi bi-box-arrow-up-right me-1"></i> Web Arayüzünü Aç
                                </a>
                            </p>
                        </div>
                    <?php else: ?>
                        <div class="alert alert-danger">
                            <h4 class="alert-heading"><i class="bi bi-exclamation-triangle-fill me-2"></i> Eczane Servisi Çalışmıyor</h4>
                            <p>Nöbetçi eczane servisi şu anda erişilebilir değil. Lütfen "Eczane Servisi" iş akışının çalıştığından emin olun.</p>
                            <hr>
                            <p class="mb-0">
                                <strong>Kontrol edilen servis URL:</strong> <code><?= $service_url ?></code>
                            </p>
                        </div>
                    <?php endif; ?>
                </div>
            </div>
            
            <div class="card mb-4">
                <div class="card-header">
                    <strong>Eczane Eklentisi Ayarları</strong>
                </div>
                <div class="card-body">
                    <form method="post" action="">
                        <div class="mb-3">
                            <label for="google_maps_api_key" class="form-label">Google Maps API Anahtarı</label>
                            <input type="text" class="form-control" id="google_maps_api_key" name="google_maps_api_key" 
                                   value="<?= htmlspecialchars($settings['google_maps_api_key'] ?? '') ?>">
                            <div class="form-text">Harita görünümü ve yol tarifi için Google Maps API anahtarı gereklidir.</div>
                        </div>
                        
                        <div class="mb-3">
                            <label for="max_results" class="form-label">Maksimum Sonuç Sayısı</label>
                            <input type="number" class="form-control" id="max_results" name="max_results" min="5" max="100" 
                                   value="<?= intval($settings['max_results'] ?? 20) ?>">
                        </div>
                        
                        <div class="mb-3">
                            <label for="cache_time" class="form-label">Önbellek Süresi (saniye)</label>
                            <input type="number" class="form-control" id="cache_time" name="cache_time" min="0" max="86400" 
                                   value="<?= intval($settings['cache_time'] ?? 3600) ?>">
                            <div class="form-text">0 değeri önbelleği devre dışı bırakır. Önerilen değer: 3600 (1 saat)</div>
                        </div>
                        
                        <div class="mb-3">
                            <div class="form-check form-switch">
                                <input class="form-check-input" type="checkbox" id="enable_directions" name="enable_directions" 
                                       <?= ($settings['enable_directions'] ?? true) ? 'checked' : '' ?>>
                                <label class="form-check-label" for="enable_directions">Yol Tarifi Özelliğini Etkinleştir</label>
                            </div>
                        </div>
                        
                        <div class="mb-3">
                            <div class="form-check form-switch">
                                <input class="form-check-input" type="checkbox" id="enable_proximity_search" name="enable_proximity_search" 
                                       <?= ($settings['enable_proximity_search'] ?? true) ? 'checked' : '' ?>>
                                <label class="form-check-label" for="enable_proximity_search">Konuma Göre Sıralama Özelliğini Etkinleştir</label>
                            </div>
                        </div>
                        
                        <div class="mb-3">
                            <div class="form-check form-switch">
                                <input class="form-check-input" type="checkbox" id="display_phone" name="display_phone" 
                                       <?= ($settings['display_phone'] ?? true) ? 'checked' : '' ?>>
                                <label class="form-check-label" for="display_phone">Telefon Numaralarını Göster</label>
                            </div>
                        </div>
                        
                        <div class="mb-3">
                            <div class="form-check form-switch">
                                <input class="form-check-input" type="checkbox" id="display_address" name="display_address" 
                                       <?= ($settings['display_address'] ?? true) ? 'checked' : '' ?>>
                                <label class="form-check-label" for="display_address">Adresleri Göster</label>
                            </div>
                        </div>
                        
                        <div class="d-grid gap-2">
                            <button type="submit" name="save_settings" class="btn btn-primary">
                                <i class="bi bi-save me-1"></i> Ayarları Kaydet
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
        
        <div class="col-md-6">
            <div class="card mb-4">
                <div class="card-header">
                    <strong>Test Verisi</strong>
                </div>
                <div class="card-body">
                    <p class="text-muted">Aşağıda <?= $test_city ?> / <?= $test_district ?> için örnek eczane verisi gösteriliyor.</p>
                    
                    <?php if (!$is_pharmacy_service_running): ?>
                        <div class="alert alert-warning">
                            <i class="bi bi-exclamation-triangle-fill me-2"></i> Eczane servisi çalışmadığı için test verisi alınamıyor.
                        </div>
                    <?php elseif (empty($test_pharmacies)): ?>
                        <div class="alert alert-info">
                            <i class="bi bi-info-circle-fill me-2"></i> Seçilen bölge için nöbetçi eczane bulunamadı.
                        </div>
                    <?php else: ?>
                        <div class="table-responsive">
                            <table class="table table-hover">
                                <thead>
                                    <tr>
                                        <th scope="col">#</th>
                                        <th scope="col">Eczane Adı</th>
                                        <th scope="col">Telefon</th>
                                        <th scope="col">Adres</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <?php foreach ($test_pharmacies as $i => $pharmacy): ?>
                                        <tr>
                                            <th scope="row"><?= $i + 1 ?></th>
                                            <td><?= htmlspecialchars($pharmacy['name']) ?></td>
                                            <td><?= htmlspecialchars($pharmacy['phone']) ?></td>
                                            <td><?= htmlspecialchars($pharmacy['address']) ?></td>
                                        </tr>
                                    <?php endforeach; ?>
                                </tbody>
                            </table>
                        </div>
                        
                        <p class="mt-3 mb-0">Toplam <?= count($test_pharmacies) ?> nöbetçi eczane bulundu.</p>
                    <?php endif; ?>
                </div>
            </div>
            
            <div class="card mb-4">
                <div class="card-header">
                    <strong>Kullanım Talimatları</strong>
                </div>
                <div class="card-body">
                    <h5>Eklenti Hakkında</h5>
                    <p>Nöbetçi Eczaneler eklentisi, şehirleriniz için nöbetçi eczane bilgilerini göstermenizi sağlar. Eklenti, il sağlık müdürlüklerinden eczane verilerini otomatik olarak çeker ve kullanıcılarınıza sunar.</p>
                    
                    <h5>Özellikler</h5>
                    <ul>
                        <li>Şehir ve ilçe bazında nöbetçi eczane listeleme</li>
                        <li>Konum tabanlı arama ve mesafeye göre sıralama</li>
                        <li>Google Maps entegrasyonu ile yol tarifi</li>
                        <li>Web ve mobil uyumlu arayüz</li>
                        <li>API desteği</li>
                    </ul>
                    
                    <h5>API Kullanımı</h5>
                    <p>Bu eklentinin API'sini diğer uygulamalarınızda kullanabilirsiniz:</p>
                    <pre><code>GET /api/pharmacies?city={ŞehirAdı}&district={İlçeAdı}</code></pre>
                    <p>Konum bazlı aramalar için:</p>
                    <pre><code>GET /api/pharmacies/by_distance?city={ŞehirAdı}&lat={Enlem}&lng={Boylam}</code></pre>
                    
                    <h5>Web Sayfası</h5>
                    <p>Eczane listesini web sayfanızda göstermek için:</p>
                    <pre><code>/mobile/pharmacies</code></pre>
                    <p>Bu URL, tam fonksiyonel bir arama aracı ile birlikte nöbetçi eczane listesi sunar.</p>
                </div>
            </div>
        </div>
    </div>
</div>