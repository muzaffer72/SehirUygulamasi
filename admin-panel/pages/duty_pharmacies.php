<?php
include_once 'db_connection.php';

// API uç noktası oluştur
function createPharmacyAPI() {
    global $pdo;
    
    // API Proxy'e eczane endpointleri ekle
    $endpoints = [
        [
            'path' => '/api/pharmacies',
            'method' => 'GET',
            'description' => 'Şehir ve ilçe bazlı nöbetçi eczaneleri listeler',
            'params' => json_encode([
                'city' => 'Şehir adı (zorunlu)',
                'district' => 'İlçe adı (opsiyonel)'
            ]),
            'is_active' => true
        ],
        [
            'path' => '/api/pharmacies/closest',
            'method' => 'GET',
            'description' => 'Konum bazlı en yakın nöbetçi eczaneleri listeler',
            'params' => json_encode([
                'city' => 'Şehir adı (zorunlu)',
                'district' => 'İlçe adı (opsiyonel)',
                'lat' => 'Enlem (zorunlu)',
                'lng' => 'Boylam (zorunlu)',
                'limit' => 'Maksimum eczane sayısı (opsiyonel, varsayılan: 10)'
            ]),
            'is_active' => true
        ]
    ];
    
    // API endpointleri varsa ekleme, yoksa güncelle
    try {
        $stmt = $pdo->prepare("SELECT COUNT(*) FROM api_endpoints WHERE path = ?");
        
        foreach ($endpoints as $endpoint) {
            $stmt->execute([$endpoint['path']]);
            $exists = $stmt->fetchColumn() > 0;
            
            if (!$exists) {
                $insertStmt = $pdo->prepare("INSERT INTO api_endpoints (path, method, description, params, is_active) VALUES (?, ?, ?, ?, ?)");
                $insertStmt->execute([
                    $endpoint['path'],
                    $endpoint['method'],
                    $endpoint['description'],
                    $endpoint['params'],
                    $endpoint['is_active']
                ]);
                echo "<div class='alert alert-success'>Endpoint eklendi: " . $endpoint['path'] . "</div>";
            } else {
                $updateStmt = $pdo->prepare("UPDATE api_endpoints SET method = ?, description = ?, params = ?, is_active = ? WHERE path = ?");
                $updateStmt->execute([
                    $endpoint['method'],
                    $endpoint['description'],
                    $endpoint['params'],
                    $endpoint['is_active'],
                    $endpoint['path']
                ]);
                echo "<div class='alert alert-info'>Endpoint güncellendi: " . $endpoint['path'] . "</div>";
            }
        }
    } catch (PDOException $e) {
        echo "<div class='alert alert-danger'>API endpoint kaydedilemedi: " . $e->getMessage() . "</div>";
    }
}

// Eczane API'sini etkinleştir/devre dışı bırak
if (isset($_POST['toggle_pharmacy_api'])) {
    $enabled = isset($_POST['pharmacy_api_enabled']) ? 1 : 0;
    
    try {
        // Önce ayarın var olup olmadığını kontrol et
        $stmt = $pdo->prepare("SELECT COUNT(*) FROM settings WHERE setting_key = 'pharmacy_api_enabled'");
        $stmt->execute();
        $exists = $stmt->fetchColumn() > 0;
        
        if ($exists) {
            $stmt = $pdo->prepare("UPDATE settings SET setting_value = ? WHERE setting_key = 'pharmacy_api_enabled'");
            $stmt->execute([$enabled]);
        } else {
            $stmt = $pdo->prepare("INSERT INTO settings (setting_key, setting_value) VALUES ('pharmacy_api_enabled', ?)");
            $stmt->execute([$enabled]);
        }
        
        echo "<div class='alert alert-success'>Nöbetçi Eczane API ayarları güncellendi.</div>";
        
        // API etkinleştirilmişse, endpoint'leri de kaydet
        if ($enabled) {
            createPharmacyAPI();
        }
        
    } catch (PDOException $e) {
        echo "<div class='alert alert-danger'>Ayarlar kaydedilemedi: " . $e->getMessage() . "</div>";
    }
}

// API'nin etkin olup olmadığını kontrol et
$pharmacyApiEnabled = 0;
try {
    $stmt = $pdo->prepare("SELECT setting_value FROM settings WHERE setting_key = 'pharmacy_api_enabled'");
    $stmt->execute();
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    $pharmacyApiEnabled = $result ? intval($result['setting_value']) : 0;
} catch (PDOException $e) {
    echo "<div class='alert alert-danger'>Ayarlar okunamadı: " . $e->getMessage() . "</div>";
}

// Test fonksiyonu - API'yi test etmek için
$testResult = null;
if (isset($_POST['test_pharmacy_api'])) {
    $city = isset($_POST['test_city']) ? $_POST['test_city'] : 'Istanbul';
    $district = isset($_POST['test_district']) ? $_POST['test_district'] : '';
    
    // Python API'ye istek gönder
    $url = "http://localhost:5001/api/pharmacies?city=" . urlencode($city);
    if (!empty($district)) {
        $url .= "&district=" . urlencode($district);
    }
    
    try {
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt($ch, CURLOPT_TIMEOUT, 10);
        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        
        if ($httpCode == 200) {
            $testResult = json_decode($response, true);
        } else {
            echo "<div class='alert alert-danger'>API test edilemedi. HTTP Kodu: $httpCode</div>";
        }
    } catch (Exception $e) {
        echo "<div class='alert alert-danger'>API test edilemedi: " . $e->getMessage() . "</div>";
    }
}

// Şehir ve ilçe listelerini al
$cities = [];
$districts = [];
try {
    $stmt = $pdo->query("SELECT id, name FROM cities ORDER BY name");
    $cities = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    if (isset($_POST['test_city_id'])) {
        $cityId = intval($_POST['test_city_id']);
        $stmt = $pdo->prepare("SELECT id, name FROM districts WHERE city_id = ? ORDER BY name");
        $stmt->execute([$cityId]);
        $districts = $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
} catch (PDOException $e) {
    echo "<div class='alert alert-danger'>Şehir/ilçe listesi alınamadı: " . $e->getMessage() . "</div>";
}
?>

<div class="container-fluid">
    <h2 class="mb-4">Nöbetçi Eczane Yönetimi</h2>
    
    <div class="row">
        <div class="col-lg-4">
            <div class="card mb-4">
                <div class="card-header">
                    <h5 class="card-title m-0">API Ayarları</h5>
                </div>
                <div class="card-body">
                    <form method="post">
                        <div class="form-check form-switch mb-3">
                            <input class="form-check-input" type="checkbox" id="pharmacy_api_enabled" name="pharmacy_api_enabled" <?= $pharmacyApiEnabled ? 'checked' : '' ?>>
                            <label class="form-check-label" for="pharmacy_api_enabled">Nöbetçi Eczane API Aktif</label>
                        </div>
                        <p class="text-muted small">Bu özellik, belediye sayfalarında nöbetçi eczanelerin gösterilmesini sağlar.</p>
                        <button type="submit" name="toggle_pharmacy_api" class="btn btn-primary">Ayarları Kaydet</button>
                    </form>
                </div>
            </div>
            
            <div class="card mb-4">
                <div class="card-header">
                    <h5 class="card-title m-0">API Test</h5>
                </div>
                <div class="card-body">
                    <form method="post">
                        <div class="mb-3">
                            <label for="test_city" class="form-label">Şehir</label>
                            <input type="text" class="form-control" id="test_city" name="test_city" value="Istanbul">
                        </div>
                        <div class="mb-3">
                            <label for="test_district" class="form-label">İlçe (Opsiyonel)</label>
                            <input type="text" class="form-control" id="test_district" name="test_district" value="Kadikoy">
                        </div>
                        <button type="submit" name="test_pharmacy_api" class="btn btn-info">API'yi Test Et</button>
                    </form>
                </div>
            </div>
        </div>
        
        <div class="col-lg-8">
            <div class="card mb-4">
                <div class="card-header">
                    <h5 class="card-title m-0">Nöbetçi Eczane Bilgileri</h5>
                </div>
                <div class="card-body">
                    <?php if ($pharmacyApiEnabled): ?>
                        <div class="alert alert-success">
                            <i class="bi bi-check-circle-fill"></i> Nöbetçi eczane API'si aktif. Belediye sayfalarında nöbetçi eczaneler görüntülenecek.
                        </div>
                        
                        <?php if ($testResult): ?>
                            <h6 class="mt-4">API Test Sonuçları:</h6>
                            <?php if ($testResult['status'] === 'success'): ?>
                                <div class="alert alert-info">
                                    <p><strong>Şehir:</strong> <?= htmlspecialchars($testResult['city']) ?></p>
                                    <?php if (!empty($testResult['district'])): ?>
                                        <p><strong>İlçe:</strong> <?= htmlspecialchars($testResult['district']) ?></p>
                                    <?php endif; ?>
                                    <p><strong>Tarih:</strong> <?= htmlspecialchars($testResult['date']) ?></p>
                                    <p><strong>Bulunan Eczane Sayısı:</strong> <?= $testResult['count'] ?></p>
                                </div>
                                
                                <?php if ($testResult['count'] > 0): ?>
                                    <div class="table-responsive">
                                        <table class="table table-bordered table-striped">
                                            <thead>
                                                <tr>
                                                    <th>Eczane Adı</th>
                                                    <th>Adres</th>
                                                    <th>Telefon</th>
                                                    <th>Konum</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <?php foreach ($testResult['pharmacies'] as $pharmacy): ?>
                                                <tr>
                                                    <td><?= htmlspecialchars($pharmacy['name']) ?></td>
                                                    <td><?= htmlspecialchars($pharmacy['address']) ?></td>
                                                    <td><?= htmlspecialchars($pharmacy['phone']) ?></td>
                                                    <td>
                                                        <?php if (!empty($pharmacy['location']['maps_url'])): ?>
                                                            <a href="<?= htmlspecialchars($pharmacy['location']['maps_url']) ?>" target="_blank" class="btn btn-sm btn-outline-primary">
                                                                <i class="bi bi-geo-alt"></i> Haritada Göster
                                                            </a>
                                                        <?php else: ?>
                                                            <span class="text-muted">Konum bilgisi yok</span>
                                                        <?php endif; ?>
                                                    </td>
                                                </tr>
                                                <?php endforeach; ?>
                                            </tbody>
                                        </table>
                                    </div>
                                <?php else: ?>
                                    <div class="alert alert-warning">
                                        Nöbetçi eczane bulunamadı.
                                    </div>
                                <?php endif; ?>
                                
                            <?php else: ?>
                                <div class="alert alert-danger">
                                    <p><strong>Hata:</strong> <?= htmlspecialchars($testResult['message']) ?></p>
                                </div>
                            <?php endif; ?>
                        <?php endif; ?>
                        
                    <?php else: ?>
                        <div class="alert alert-warning">
                            <i class="bi bi-exclamation-triangle-fill"></i> Nöbetçi eczane API'si devre dışı. Etkinleştirmek için soldaki paneli kullanın.
                        </div>
                    <?php endif; ?>
                </div>
            </div>
            
            <div class="card">
                <div class="card-header">
                    <h5 class="card-title m-0">Entegrasyon Bilgileri</h5>
                </div>
                <div class="card-body">
                    <p>Nöbetçi eczane özelliği, aşağıdaki API uç noktalarını kullanarak çalışır:</p>
                    <ul>
                        <li><code>/api/pharmacies?city=ŞEHIR&district=ILÇE</code> - Belirli bir şehir ve ilçedeki nöbetçi eczaneleri listeler</li>
                        <li><code>/api/pharmacies/closest?city=ŞEHIR&district=ILÇE&lat=ENLEM&lng=BOYLAM&limit=ADET</code> - En yakın nöbetçi eczaneleri listeler</li>
                    </ul>
                    <p>Bu özellik Python ile çalışır ve veriler çeşitli web kaynaklarından toplanır. Veriler saatlik olarak önbelleğe alınır.</p>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
// İlçe listesi için AJAX
document.addEventListener('DOMContentLoaded', function() {
    const citySelect = document.getElementById('test_city_id');
    const districtSelect = document.getElementById('test_district_id');
    
    if (citySelect && districtSelect) {
        citySelect.addEventListener('change', function() {
            const cityId = this.value;
            if (!cityId) {
                districtSelect.innerHTML = '<option value="">İlçe Seçiniz</option>';
                return;
            }
            
            fetch(`api.php?action=get_districts&city_id=${cityId}`)
                .then(response => response.json())
                .then(data => {
                    let options = '<option value="">İlçe Seçiniz</option>';
                    if (data.success && data.districts.length > 0) {
                        data.districts.forEach(district => {
                            options += `<option value="${district.id}">${district.name}</option>`;
                        });
                    }
                    districtSelect.innerHTML = options;
                })
                .catch(error => console.error('İlçe listesi alınamadı:', error));
        });
    }
});
</script>