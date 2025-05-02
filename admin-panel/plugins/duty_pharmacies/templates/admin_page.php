<?php
// Nöbetçi Eczaneler Yönetim Sayfası
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

// Eklenti dosyalarını dahil et
if (file_exists(__DIR__ . '/../plugins/duty_pharmacies/main.php')) {
    require_once __DIR__ . '/../plugins/duty_pharmacies/main.php';
} else {
    echo '<div class="alert alert-danger">
            <h4>Eklenti dosyaları bulunamadı!</h4>
            <p>Nöbetçi Eczaneler eklentisi dosyaları eksik veya hasarlı olabilir.</p>
          </div>';
    return;
}

// Şehir ve ilçeleri yükle
$cities = [];
$districts = [];

try {
    // Şehirleri veritabanından al
    $city_query = "SELECT id, name FROM cities ORDER BY name ASC";
    $city_result = $db->query($city_query);
    
    if ($city_result) {
        while ($row = $city_result->fetch_assoc()) {
            $cities[] = $row;
        }
    }
    
    // İlçeleri veritabanından al
    $district_query = "SELECT id, city_id, name FROM districts ORDER BY name ASC";
    $district_result = $db->query($district_query);
    
    if ($district_result) {
        while ($row = $district_result->fetch_assoc()) {
            $districts[] = $row;
        }
    }
} catch (Exception $e) {
    echo '<div class="alert alert-danger">
            <h4>Veritabanı hatası!</h4>
            <p>Şehir ve ilçe verilerini yüklerken bir hata oluştu: ' . $e->getMessage() . '</p>
          </div>';
}

// Eklenti ayarlarını al
$pharmacy_settings = get_pharmacy_settings($db);
$api_endpoint = $pharmacy_settings['api_endpoint'] ?? 'http://0.0.0.0:5001/pharmacies';
$show_distance = $pharmacy_settings['show_distance'] ?? false;
$enable_directions = $pharmacy_settings['enable_directions'] ?? false;
$google_maps_api_key = $pharmacy_settings['google_maps_api_key'] ?? '';
$display_mode = $pharmacy_settings['display_mode'] ?? 'both';

// Form verilerini işle
$selected_city = $_POST['city'] ?? $_GET['city'] ?? ($cities[0]['id'] ?? 0);
$selected_district = $_POST['district'] ?? $_GET['district'] ?? 'all';
$latitude = $_POST['lat'] ?? $_GET['lat'] ?? null;
$longitude = $_POST['lng'] ?? $_GET['lng'] ?? null;

// Eczane verilerini yükle
$pharmacy_data = null;
$error_message = null;

if ($selected_city) {
    // Şehir adını al
    $city_name = '';
    foreach ($cities as $city) {
        if ($city['id'] == $selected_city) {
            $city_name = $city['name'];
            break;
        }
    }
    
    // İlçe adını al (eğer seçilmişse)
    $district_name = ($selected_district != 'all') ? '' : null;
    if ($selected_district != 'all') {
        foreach ($districts as $district) {
            if ($district['id'] == $selected_district) {
                $district_name = $district['name'];
                break;
            }
        }
    }
    
    // Eczane verilerini getir
    try {
        $pharmacy_data = get_cached_pharmacies($city_name, $district_name, $latitude, $longitude);
        
        if (isset($pharmacy_data['error'])) {
            $error_message = $pharmacy_data['error'];
        }
    } catch (Exception $e) {
        $error_message = "Eczane verileri alınırken bir hata oluştu: " . $e->getMessage();
    }
}
?>

<div class="container-fluid py-4">
    <h1 class="mb-4">Nöbetçi Eczaneler</h1>
    
    <div class="card mb-4">
        <div class="card-header d-flex justify-content-between align-items-center">
            <strong>Nöbetçi Eczane Filtresi</strong>
        </div>
        <div class="card-body">
            <form method="post" action="?page=duty_pharmacies" id="pharmacyFilterForm">
                <div class="row">
                    <div class="col-md-4">
                        <div class="mb-3">
                            <label for="city" class="form-label">Şehir</label>
                            <select class="form-select" id="city" name="city" required>
                                <option value="">Şehir Seçin</option>
                                <?php foreach ($cities as $city): ?>
                                    <option value="<?= $city['id'] ?>" <?= ($selected_city == $city['id']) ? 'selected' : '' ?>>
                                        <?= htmlspecialchars($city['name']) ?>
                                    </option>
                                <?php endforeach; ?>
                            </select>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="mb-3">
                            <label for="district" class="form-label">İlçe</label>
                            <select class="form-select" id="district" name="district">
                                <option value="all">Tüm İlçeler</option>
                                <?php 
                                // Seçilen şehre göre ilçeleri filtrele
                                $filtered_districts = array_filter($districts, function($d) use ($selected_city) {
                                    return $d['city_id'] == $selected_city;
                                });
                                
                                foreach ($filtered_districts as $district): 
                                ?>
                                    <option value="<?= $district['id'] ?>" <?= ($selected_district == $district['id']) ? 'selected' : '' ?>>
                                        <?= htmlspecialchars($district['name']) ?>
                                    </option>
                                <?php endforeach; ?>
                            </select>
                        </div>
                    </div>
                    <?php if ($show_distance): ?>
                    <div class="col-md-4">
                        <div class="mb-3">
                            <label class="form-label">Konum</label>
                            <div class="input-group">
                                <input type="text" class="form-control" id="locationInput" placeholder="Konumunuzu girin">
                                <button class="btn btn-outline-secondary" type="button" id="getLocation">
                                    <i class="bi bi-geo-alt"></i>
                                </button>
                                <input type="hidden" name="lat" id="lat" value="<?= $latitude ?>">
                                <input type="hidden" name="lng" id="lng" value="<?= $longitude ?>">
                            </div>
                            <div class="form-text">Mesafeye göre sıralama için konum bilgisi gereklidir.</div>
                        </div>
                    </div>
                    <?php endif; ?>
                </div>
                <div class="d-grid gap-2 d-md-flex justify-content-md-end">
                    <button type="submit" class="btn btn-primary">
                        <i class="bi bi-search me-1"></i> Eczaneleri Getir
                    </button>
                </div>
            </form>
        </div>
    </div>
    
    <?php if ($error_message): ?>
        <div class="alert alert-danger">
            <h4>Hata!</h4>
            <p><?= htmlspecialchars($error_message) ?></p>
        </div>
    <?php elseif ($pharmacy_data && isset($pharmacy_data['pharmacies'])): ?>
        
        <?php if (empty($pharmacy_data['pharmacies'])): ?>
            <div class="alert alert-info">
                <h4>Eczane Bulunamadı</h4>
                <p>Seçilen kriterlere uygun nöbetçi eczane bulunamadı.</p>
            </div>
        <?php else: ?>
            <div class="card mb-4">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <strong>Nöbetçi Eczaneler (<?= count($pharmacy_data['pharmacies']) ?> adet)</strong>
                    <div>
                        <button class="btn btn-sm btn-outline-secondary me-2" id="refreshData">
                            <i class="bi bi-arrow-clockwise me-1"></i> Yenile
                        </button>
                        <?php if ($display_mode == 'both' || $display_mode == 'list'): ?>
                            <button class="btn btn-sm btn-outline-secondary me-2 view-toggle active" data-view="list">
                                <i class="bi bi-list-ul me-1"></i> Liste
                            </button>
                        <?php endif; ?>
                        <?php if ($display_mode == 'both' || $display_mode == 'map'): ?>
                            <button class="btn btn-sm btn-outline-secondary view-toggle" data-view="map">
                                <i class="bi bi-map me-1"></i> Harita
                            </button>
                        <?php endif; ?>
                    </div>
                </div>
                
                <!-- Liste Görünümü -->
                <?php if ($display_mode == 'both' || $display_mode == 'list'): ?>
                <div class="view-section" id="listView">
                    <div class="table-responsive">
                        <table class="table table-hover">
                            <thead>
                                <tr>
                                    <th>#</th>
                                    <th>Eczane Adı</th>
                                    <th>Adres</th>
                                    <th>Telefon</th>
                                    <th>İlçe</th>
                                    <?php if ($show_distance && $latitude && $longitude): ?>
                                        <th>Mesafe</th>
                                    <?php endif; ?>
                                    <th>İşlemler</th>
                                </tr>
                            </thead>
                            <tbody>
                                <?php foreach ($pharmacy_data['pharmacies'] as $index => $pharmacy): ?>
                                <tr>
                                    <td><?= $index + 1 ?></td>
                                    <td><?= htmlspecialchars($pharmacy['name']) ?></td>
                                    <td><?= htmlspecialchars($pharmacy['address']) ?></td>
                                    <td><?= htmlspecialchars($pharmacy['phone']) ?></td>
                                    <td><?= htmlspecialchars($pharmacy['district']) ?></td>
                                    <?php if ($show_distance && $latitude && $longitude && isset($pharmacy['distance'])): ?>
                                        <td><?= number_format($pharmacy['distance'], 1) ?> km</td>
                                    <?php endif; ?>
                                    <td>
                                        <?php if ($enable_directions && isset($pharmacy['latitude']) && isset($pharmacy['longitude'])): ?>
                                            <a href="https://www.google.com/maps/dir/?api=1&destination=<?= $pharmacy['latitude'] ?>,<?= $pharmacy['longitude'] ?>&travelmode=driving" 
                                               class="btn btn-sm btn-outline-primary" target="_blank">
                                                <i class="bi bi-signpost-2 me-1"></i> Yol Tarifi
                                            </a>
                                        <?php else: ?>
                                            <button class="btn btn-sm btn-outline-primary copy-address" 
                                                    data-address="<?= htmlspecialchars($pharmacy['address']) ?>">
                                                <i class="bi bi-clipboard me-1"></i> Adresi Kopyala
                                            </button>
                                        <?php endif; ?>
                                    </td>
                                </tr>
                                <?php endforeach; ?>
                            </tbody>
                        </table>
                    </div>
                </div>
                <?php endif; ?>
                
                <!-- Harita Görünümü -->
                <?php if ($display_mode == 'both' || $display_mode == 'map'): ?>
                <div class="view-section <?= ($display_mode == 'both') ? 'd-none' : '' ?>" id="mapView">
                    <?php if ($google_maps_api_key): ?>
                    <div id="pharmacyMap" style="height: 500px; width: 100%;"></div>
                    <?php else: ?>
                    <div class="alert alert-warning m-3">
                        <h4>Google Maps API anahtarı ayarlanmamış!</h4>
                        <p>Harita görünümü için eklenti ayarlarından Google Maps API anahtarı tanımlamanız gerekiyor.</p>
                    </div>
                    <?php endif; ?>
                </div>
                <?php endif; ?>
            </div>
        <?php endif; ?>
        
    <?php elseif ($selected_city): ?>
        <div class="alert alert-info">
            <h4>Veri Yok</h4>
            <p>Lütfen bir şehir seçin ve eczaneleri getirin.</p>
        </div>
    <?php endif; ?>
    
    <div class="card mb-4">
        <div class="card-header">
            <strong>Kullanım Bilgileri</strong>
        </div>
        <div class="card-body">
            <p>Bu modül, Türkiye genelinde nöbetçi eczane bilgilerini göstermektedir.</p>
            <ul>
                <li>İl ve ilçe bazında filtreleme yapabilirsiniz.</li>
                <?php if ($show_distance): ?>
                <li>Konum bilgisi girerek, eczaneleri size olan uzaklığına göre sıralayabilirsiniz.</li>
                <?php endif; ?>
                <?php if ($enable_directions): ?>
                <li>Yol tarifi butonuna tıklayarak Google Maps üzerinden seçtiğiniz eczaneye nasıl gideceğinizi görebilirsiniz.</li>
                <?php endif; ?>
                <li>Eklenti ayarlarını <a href="?page=plugins">Eklenti Yönetimi</a> sayfasından değiştirebilirsiniz.</li>
            </ul>
            <p class="text-muted"><small>Son güncelleme: <?= date('d.m.Y H:i') ?></small></p>
        </div>
    </div>
</div>

<?php if ($display_mode == 'both' || $display_mode == 'map'): ?>
<!-- Google Maps ve ilgili JavaScript kodları -->
<?php if ($google_maps_api_key): ?>
<script src="https://maps.googleapis.com/maps/api/js?key=<?= htmlspecialchars($google_maps_api_key) ?>&libraries=places&callback=initMap" async defer></script>
<?php endif; ?>

<script>
document.addEventListener('DOMContentLoaded', function() {
    // Şehir seçildiğinde ilçeleri güncelle
    document.getElementById('city').addEventListener('change', function() {
        const cityId = this.value;
        const districtSelect = document.getElementById('district');
        
        // Tüm ilçeleri temizle
        districtSelect.innerHTML = '<option value="all">Tüm İlçeler</option>';
        
        if (!cityId) return;
        
        // İlgili şehrin ilçelerini filtrele
        <?php echo "const allDistricts = " . json_encode($districts) . ";\n"; ?>
        
        const filteredDistricts = allDistricts.filter(district => district.city_id == cityId);
        
        // İlçeleri ekle
        filteredDistricts.forEach(district => {
            const option = document.createElement('option');
            option.value = district.id;
            option.textContent = district.name;
            districtSelect.appendChild(option);
        });
    });
    
    <?php if ($show_distance): ?>
    // Konum alma butonu
    document.getElementById('getLocation').addEventListener('click', function() {
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(function(position) {
                document.getElementById('lat').value = position.coords.latitude;
                document.getElementById('lng').value = position.coords.longitude;
                document.getElementById('locationInput').value = 'Konum alındı';
            }, function(error) {
                alert('Konum alınamadı: ' + error.message);
            });
        } else {
            alert('Tarayıcınız konum özelliğini desteklemiyor.');
        }
    });
    <?php endif; ?>
    
    // Liste/Harita geçişleri
    document.querySelectorAll('.view-toggle').forEach(button => {
        button.addEventListener('click', function() {
            const view = this.getAttribute('data-view');
            
            // Buton durumlarını güncelle
            document.querySelectorAll('.view-toggle').forEach(btn => {
                btn.classList.remove('active');
            });
            this.classList.add('active');
            
            // Görünümleri güncelle
            document.querySelectorAll('.view-section').forEach(section => {
                section.classList.add('d-none');
            });
            document.getElementById(view + 'View').classList.remove('d-none');
        });
    });
    
    // Adresi kopyalama butonu
    document.querySelectorAll('.copy-address').forEach(button => {
        button.addEventListener('click', function() {
            const address = this.getAttribute('data-address');
            navigator.clipboard.writeText(address).then(() => {
                alert('Adres panoya kopyalandı');
            });
        });
    });
    
    // Verileri yenileme butonu
    document.getElementById('refreshData')?.addEventListener('click', function() {
        document.getElementById('pharmacyFilterForm').submit();
    });
});

<?php if ($google_maps_api_key && !empty($pharmacy_data['pharmacies'])): ?>
// Google Maps başlatma
function initMap() {
    const pharmacies = <?= json_encode($pharmacy_data['pharmacies']) ?>;
    
    if (pharmacies.length === 0) return;
    
    // Harita merkezi
    let mapCenter;
    
    // Kullanıcı konumu varsa onu merkez al
    <?php if ($latitude && $longitude): ?>
    mapCenter = { lat: <?= $latitude ?>, lng: <?= $longitude ?> };
    <?php else: ?>
    // İlk eczanenin konumunu merkez al
    const firstPharmacy = pharmacies[0];
    if (firstPharmacy.latitude && firstPharmacy.longitude) {
        mapCenter = { lat: parseFloat(firstPharmacy.latitude), lng: parseFloat(firstPharmacy.longitude) };
    } else {
        // Varsayılan konum (Türkiye ortası)
        mapCenter = { lat: 39.925533, lng: 32.866287 };
    }
    <?php endif; ?>
    
    // Harita oluştur
    const map = new google.maps.Map(document.getElementById('pharmacyMap'), {
        zoom: 12,
        center: mapCenter
    });
    
    // Kullanıcı konumu işaretleyicisi
    <?php if ($latitude && $longitude): ?>
    new google.maps.Marker({
        position: mapCenter,
        map: map,
        icon: {
            path: google.maps.SymbolPath.CIRCLE,
            scale: 10,
            fillColor: '#4285F4',
            fillOpacity: 0.8,
            strokeColor: 'white',
            strokeWeight: 2
        },
        title: 'Konumunuz'
    });
    <?php endif; ?>
    
    // Eczane işaretleyicileri
    const bounds = new google.maps.LatLngBounds();
    const infoWindow = new google.maps.InfoWindow();
    
    pharmacies.forEach((pharmacy, index) => {
        if (!pharmacy.latitude || !pharmacy.longitude) return;
        
        const position = { 
            lat: parseFloat(pharmacy.latitude), 
            lng: parseFloat(pharmacy.longitude) 
        };
        
        // Harita sınırlarını güncelle
        bounds.extend(position);
        
        // İşaretleyici oluştur
        const marker = new google.maps.Marker({
            position: position,
            map: map,
            label: (index + 1).toString(),
            title: pharmacy.name
        });
        
        // Bilgi penceresi içeriği
        const content = `
            <div>
                <h5>${pharmacy.name}</h5>
                <p><strong>Adres:</strong> ${pharmacy.address}</p>
                <p><strong>Telefon:</strong> ${pharmacy.phone}</p>
                ${pharmacy.distance ? `<p><strong>Mesafe:</strong> ${pharmacy.distance.toFixed(1)} km</p>` : ''}
                <a href="https://www.google.com/maps/dir/?api=1&destination=${pharmacy.latitude},${pharmacy.longitude}&travelmode=driving" 
                   class="btn btn-sm btn-primary" target="_blank">Yol Tarifi Al</a>
            </div>
        `;
        
        // İşaretleyici tıklama olayı
        marker.addListener('click', () => {
            infoWindow.setContent(content);
            infoWindow.open(map, marker);
        });
    });
    
    // Haritayı tüm işaretleyicileri gösterecek şekilde ayarla
    if (pharmacies.length > 1) {
        map.fitBounds(bounds);
    }
}
<?php endif; ?>
</script>
<?php endif; ?>