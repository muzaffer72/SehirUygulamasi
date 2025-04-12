<?php
// Anketler sayfası
// Global değişkenler: $surveys, $cities, $districts, $categories

// Anket detaylarını görüntüleme
if (isset($_GET['view_survey'])) {
    $survey_id = (int)$_GET['view_survey'];
    $survey = null;
    
    foreach ($surveys as $s) {
        if ($s['id'] == $survey_id) {
            $survey = $s;
            break;
        }
    }
    
    if ($survey) {
        ?>
        <div class="card mb-4">
            <div class="card-header d-flex justify-content-between align-items-center">
                <span>Anket Detayları</span>
                <a href="?page=surveys" class="btn btn-sm btn-outline-secondary">Geri Dön</a>
            </div>
            <div class="card-body">
                <h4><?= htmlspecialchars($survey['title']) ?></h4>
                <p class="mb-1"><strong>Kısa Başlık:</strong> <?= htmlspecialchars($survey['short_title']) ?></p>
                <p class="text-muted"><?= htmlspecialchars($survey['description']) ?></p>
                
                <div class="row mb-3">
                    <div class="col-md-6">
                        <div class="card h-100">
                            <div class="card-header">
                                <h5 class="card-title mb-0">Genel Bilgiler</h5>
                            </div>
                            <div class="card-body">
                                <p><strong>Kapsam:</strong> 
                                    <?php
                                    switch ($survey['scope_type']) {
                                        case 'general':
                                            echo 'Genel (Tüm Türkiye)';
                                            break;
                                        case 'city':
                                            echo 'İl Bazlı: ' . get_city_name($survey['city_id']);
                                            break;
                                        case 'district':
                                            echo 'İlçe Bazlı: ' . get_district_name($survey['district_id']) . ', ' . get_city_name($survey['city_id']);
                                            break;
                                    }
                                    ?>
                                </p>
                                <p><strong>Kategori:</strong> <?= get_category_name($survey['category_id']) ?></p>
                                <p><strong>Durum:</strong> 
                                    <?= $survey['is_active'] 
                                        ? '<span class="badge text-bg-success">Aktif</span>' 
                                        : '<span class="badge text-bg-danger">Pasif</span>' ?>
                                </p>
                                <p><strong>Başlangıç:</strong> <?= htmlspecialchars($survey['start_date']) ?></p>
                                <p><strong>Bitiş:</strong> <?= htmlspecialchars($survey['end_date']) ?></p>
                                <p><strong>Toplam Oy:</strong> <?= number_format($survey['total_votes']) ?> / <?= number_format($survey['total_users']) ?> (<?= round(($survey['total_votes'] / $survey['total_users']) * 100, 1) ?>%)</p>
                                <div class="d-flex justify-content-between align-items-center mt-3">
                                    <a href="?page=surveys&edit_survey=<?= $survey['id'] ?>" class="btn btn-sm btn-outline-primary">
                                        <i class="bi bi-pencil me-1"></i> Düzenle
                                    </a>
                                    <div class="form-check form-switch">
                                        <input class="form-check-input" type="checkbox" id="toggle-active-status" <?= $survey['is_active'] ? 'checked' : '' ?>>
                                        <label class="form-check-label" for="toggle-active-status">Aktif/Pasif</label>
                                        <script>
                                            // Anket ID'sini JS tarafına aktar
                                            window.surveyId = <?= $survey_id ?>;
                                        </script>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="card h-100">
                            <div class="card-header">
                                <h5 class="card-title mb-0">Katılım Özeti</h5>
                            </div>
                            <div class="card-body d-flex flex-column justify-content-center">
                                <div class="text-center mb-3">
                                    <div class="display-4 fw-bold text-primary"><?= round(($survey['total_votes'] / $survey['total_users']) * 100, 1) ?>%</div>
                                    <div class="text-muted">Katılım Oranı</div>
                                </div>
                                
                                <div class="progress mb-3" style="height: 20px;">
                                    <div class="progress-bar bg-primary" role="progressbar" 
                                        style="width: <?= round(($survey['total_votes'] / $survey['total_users']) * 100, 1) ?>%;" 
                                        aria-valuenow="<?= $survey['total_votes'] ?>" 
                                        aria-valuemin="0" 
                                        aria-valuemax="<?= $survey['total_users'] ?>">
                                        <?= number_format($survey['total_votes']) ?> / <?= number_format($survey['total_users']) ?>
                                    </div>
                                </div>
                                
                                <div class="row text-center">
                                    <div class="col-6">
                                        <div class="h3 mb-0"><?= number_format($survey['total_votes']) ?></div>
                                        <div class="text-muted">Oy Sayısı</div>
                                    </div>
                                    <div class="col-6">
                                        <div class="h3 mb-0"><?= number_format($survey['total_users']) ?></div>
                                        <div class="text-muted">Hedef Kitle</div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="row mb-3" id="survey-options-chart">
                    <div class="col-md-8">
                        <div class="card">
                            <div class="card-header">
                                <h5 class="card-title mb-0">Anket Seçenekleri</h5>
                            </div>
                            <div class="card-body">
                                <?php if (empty($survey['options'])): ?>
                                    <p class="text-muted">Bu anket için hiç seçenek tanımlanmamış.</p>
                                <?php else: ?>
                                    <!-- Chart.js kütüphanesini ekleyelim -->
                                    <script src="https://cdn.jsdelivr.net/npm/chart.js@3.9.1/dist/chart.min.js"></script>
                                    
                                    <script>
                                        // Anket seçeneklerini grafikler için global değişkene aktarıyoruz
                                        window.surveyOptions = <?= json_encode($survey['options']) ?>;
                                        
                                        // Bölgesel dağılım verisi (eğer varsa)
                                        window.surveyRegionalData = [
                                            // Örnek veri, gerçek uygulamada veritabanından gelir
                                            {"name": "İstanbul", "vote_count": 120},
                                            {"name": "Ankara", "vote_count": 85},
                                            {"name": "İzmir", "vote_count": 65},
                                            {"name": "Bursa", "vote_count": 45},
                                            {"name": "Antalya", "vote_count": 30}
                                        ];
                                    </script>
                                    
                                    <?php foreach ($survey['options'] as $option): ?>
                                        <div class="mb-3">
                                            <div class="d-flex justify-content-between">
                                                <span><?= htmlspecialchars($option['text']) ?></span>
                                                <span><?= $option['vote_count'] ?> oy (<?= $survey['total_votes'] > 0 ? round(($option['vote_count'] / $survey['total_votes']) * 100, 1) : 0 ?>%)</span>
                                            </div>
                                            <div class="progress" style="height: 15px;">
                                                <div 
                                                    class="progress-bar" 
                                                    role="progressbar" 
                                                    style="width: <?= $survey['total_votes'] > 0 ? round(($option['vote_count'] / $survey['total_votes']) * 100, 1) : 0 ?>%;" 
                                                    aria-valuenow="<?= $option['vote_count'] ?>" 
                                                    aria-valuemin="0" 
                                                    aria-valuemax="<?= $survey['total_votes'] ?>">
                                                </div>
                                            </div>
                                        </div>
                                    <?php endforeach; ?>
                                <?php endif; ?>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-md-4">
                        <div class="card">
                            <div class="card-header">
                                <h5 class="card-title mb-0">Grafik Gösterimi</h5>
                            </div>
                            <div class="card-body">
                                <?php if (!empty($survey['options'])): ?>
                                    <canvas id="options-chart" width="100%" height="250"></canvas>
                                <?php else: ?>
                                    <p class="text-muted">Grafik için yeterli veri yok.</p>
                                <?php endif; ?>
                            </div>
                        </div>
                        
                        <?php if ($survey['scope_type'] === 'general'): ?>
                        <div class="card mt-3">
                            <div class="card-header">
                                <h5 class="card-title mb-0">Bölgesel Dağılım</h5>
                            </div>
                            <div class="card-body">
                                <canvas id="regional-chart" width="100%" height="250"></canvas>
                            </div>
                        </div>
                        <?php endif; ?>
                    </div>
                </div>
            </div>
        </div>
        <?php
        return;
    }
}

// Anket ekleme formu
if (isset($_GET['add_survey'])) {
    ?>
    <div class="card mb-4">
        <div class="card-header d-flex justify-content-between align-items-center">
            <span>Yeni Anket Ekle</span>
            <a href="?page=surveys" class="btn btn-sm btn-outline-secondary">Geri Dön</a>
        </div>
        <div class="card-body">
            <form method="post" action="?page=surveys">
                <div class="mb-3">
                    <label for="title" class="form-label">Anket Başlığı</label>
                    <input type="text" class="form-control" id="title" name="title" required>
                    <div class="form-text">Anketin tam başlığı (admin panelde ve detay sayfasında görünür)</div>
                </div>
                
                <div class="mb-3">
                    <label for="short_title" class="form-label">Kısa Başlık</label>
                    <input type="text" class="form-control" id="short_title" name="short_title" required>
                    <div class="form-text">Anketin kısa başlığı (anasayfada ve listelerde görünür)</div>
                </div>
                
                <div class="mb-3">
                    <label for="description" class="form-label">Açıklama</label>
                    <textarea class="form-control" id="description" name="description" rows="3" required></textarea>
                </div>
                
                <div class="row">
                    <div class="col-md-6">
                        <div class="mb-3">
                            <label for="category_id" class="form-label">Kategori</label>
                            <select class="form-select" id="category_id" name="category_id" required>
                                <option value="">Seçiniz...</option>
                                <?php foreach ($categories as $category): ?>
                                    <option value="<?= $category['id'] ?>"><?= htmlspecialchars($category['name']) ?></option>
                                <?php endforeach; ?>
                            </select>
                        </div>
                    </div>
                    
                    <div class="col-md-6">
                        <div class="mb-3">
                            <label for="scope_type" class="form-label">Anket Kapsamı</label>
                            <select class="form-select" id="scope_type" name="scope_type" required onchange="toggleScopeOptions()">
                                <option value="">Seçiniz...</option>
                                <option value="general">Genel (Tüm Türkiye)</option>
                                <option value="city">İl Bazlı</option>
                                <option value="district">İlçe Bazlı</option>
                            </select>
                        </div>
                    </div>
                </div>
                
                <div class="row scope-options" id="city-options" style="display: none;">
                    <div class="col-md-6">
                        <div class="mb-3">
                            <label for="city_id" class="form-label">İl</label>
                            <select class="form-select" id="city_id" name="city_id">
                                <option value="all">Tüm Türkiye</option>
                                <?php foreach ($cities as $city): ?>
                                    <option value="<?= $city['id'] ?>"><?= htmlspecialchars($city['name']) ?></option>
                                <?php endforeach; ?>
                            </select>
                        </div>
                    </div>
                </div>
                
                <div class="row scope-options" id="district-options" style="display: none;">
                    <div class="col-md-6">
                        <div class="mb-3">
                            <label for="district_city_id" class="form-label">İl</label>
                            <select class="form-select" id="district_city_id" name="district_city_id" onchange="loadDistricts()">
                                <option value="">Seçiniz...</option>
                                <?php foreach ($cities as $city): ?>
                                    <option value="<?= $city['id'] ?>"><?= htmlspecialchars($city['name']) ?></option>
                                <?php endforeach; ?>
                            </select>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="mb-3">
                            <label for="district_id" class="form-label">İlçe</label>
                            <select class="form-select" id="district_id" name="district_id" disabled>
                                <option value="">Önce il seçiniz...</option>
                            </select>
                        </div>
                    </div>
                </div>
                
                <div class="row">
                    <div class="col-md-6">
                        <div class="mb-3">
                            <label for="start_date" class="form-label">Başlangıç Tarihi</label>
                            <input type="date" class="form-control" id="start_date" name="start_date" required>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="mb-3">
                            <label for="end_date" class="form-label">Bitiş Tarihi</label>
                            <input type="date" class="form-control" id="end_date" name="end_date" required>
                        </div>
                    </div>
                </div>
                
                <div class="mb-3">
                    <label for="totalUsers" class="form-label">Hedef Katılımcı Sayısı</label>
                    <input type="number" class="form-control" id="totalUsers" name="total_users" min="100" value="1000">
                    <div class="form-text">Anketin katılım oranı hesaplamasında kullanılacak hedef sayı</div>
                </div>
                
                <div class="mb-3">
                    <div class="form-check">
                        <input class="form-check-input" type="checkbox" id="is_active" name="is_active" checked>
                        <label class="form-check-label" for="is_active">
                            Anket Aktif
                        </label>
                    </div>
                </div>
                
                <div class="mb-3">
                    <h5>Anket Seçenekleri</h5>
                    <p class="text-muted small">En az 2 seçenek ekleyin.</p>
                    
                    <div id="options-container">
                        <div class="input-group mb-2">
                            <input type="text" class="form-control" name="options[]" placeholder="Seçenek 1" required>
                            <button class="btn btn-outline-danger" type="button" onclick="removeOption(this)">Sil</button>
                        </div>
                        <div class="input-group mb-2">
                            <input type="text" class="form-control" name="options[]" placeholder="Seçenek 2" required>
                            <button class="btn btn-outline-danger" type="button" onclick="removeOption(this)">Sil</button>
                        </div>
                    </div>
                    
                    <button type="button" class="btn btn-outline-secondary btn-sm" onclick="addOption()">
                        <i class="bi bi-plus"></i> Seçenek Ekle
                    </button>
                </div>
                
                <button type="submit" name="add_survey" class="btn btn-primary">Anketi Kaydet</button>
            </form>
        </div>
    </div>
    
    <!-- Chart.js kütüphanesini dahil et - spesifik versiyon belirterek -->
<script src="https://cdn.jsdelivr.net/npm/chart.js@3.9.1/dist/chart.min.js"></script>

<!-- Anketler sayfası JS dosyasını yükle -->
<script>
    // İlçeleri global değişkene aktar (loadDistricts fonksiyonunda kullanılıyor)
    window.allDistricts = <?= json_encode($districts) ?>;
</script>
<script src="js/surveys.js"></script>
    <?php
    return;
}

// Anketleri listele
?>
<div class="card mb-4">
    <div class="card-header d-flex justify-content-between align-items-center">
        <div class="d-flex align-items-center">
            <span class="me-2">Anketler</span>
            <button class="btn btn-sm btn-outline-secondary" id="toggle-filters">
                <i class="bi bi-funnel me-1"></i> Filtrele
                <i class="bi bi-chevron-down ms-1" id="filter-toggle-icon"></i>
            </button>
        </div>
        <a href="?page=surveys&add_survey=1" class="btn btn-sm btn-primary">
            <i class="bi bi-plus"></i> Yeni Anket Ekle
        </a>
    </div>
    
    <!-- Filtreleme seçenekleri -->
    <div class="card-body border-bottom" id="filter-content">
        <form id="survey-filter-form" method="get" action="">
            <input type="hidden" name="page" value="surveys">
            
            <div class="row g-3">
                <!-- Statü filtresi -->
                <div class="col-md-3">
                    <div class="form-group">
                        <label class="form-label">Durum</label>
                        <select name="status" class="form-select">
                            <option value="">Tümü</option>
                            <option value="active" <?= isset($_GET['status']) && $_GET['status'] === 'active' ? 'selected' : '' ?>>Aktif</option>
                            <option value="inactive" <?= isset($_GET['status']) && $_GET['status'] === 'inactive' ? 'selected' : '' ?>>Pasif</option>
                        </select>
                    </div>
                </div>
                
                <!-- Kapsam filtresi -->
                <div class="col-md-3">
                    <div class="form-group">
                        <label class="form-label">Kapsam</label>
                        <select name="scope_type" class="form-select">
                            <option value="">Tümü</option>
                            <option value="general" <?= isset($_GET['scope_type']) && $_GET['scope_type'] === 'general' ? 'selected' : '' ?>>Genel</option>
                            <option value="city" <?= isset($_GET['scope_type']) && $_GET['scope_type'] === 'city' ? 'selected' : '' ?>>İl Bazlı</option>
                            <option value="district" <?= isset($_GET['scope_type']) && $_GET['scope_type'] === 'district' ? 'selected' : '' ?>>İlçe Bazlı</option>
                        </select>
                    </div>
                </div>
                
                <!-- Kategori filtresi -->
                <div class="col-md-3">
                    <div class="form-group">
                        <label class="form-label">Kategori</label>
                        <select name="category_id" class="form-select">
                            <option value="">Tümü</option>
                            <?php foreach ($categories as $category): ?>
                                <option value="<?= $category['id'] ?>" <?= isset($_GET['category_id']) && $_GET['category_id'] == $category['id'] ? 'selected' : '' ?>>
                                    <?= htmlspecialchars($category['name']) ?>
                                </option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                </div>
                
                <!-- Tarih aralığı filtresi -->
                <div class="col-md-3">
                    <div class="form-group">
                        <label class="form-label">Tarih Aralığı</label>
                        <div class="input-group input-group-sm">
                            <input type="date" class="form-control" name="start_date" id="filter_start_date" 
                                value="<?= isset($_GET['start_date']) ? $_GET['start_date'] : '' ?>">
                            <span class="input-group-text">-</span>
                            <input type="date" class="form-control" name="end_date" id="filter_end_date"
                                value="<?= isset($_GET['end_date']) ? $_GET['end_date'] : '' ?>">
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="mt-3 text-end">
                <a href="?page=surveys" class="btn btn-sm btn-outline-secondary me-2">Sıfırla</a>
                <button type="submit" class="btn btn-sm btn-primary">Filtrele</button>
            </div>
        </form>
    </div>
    
    <div class="card-body">
        <div class="table-responsive">
            <table class="table table-hover">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Başlık</th>
                        <th>Kısa Başlık</th>
                        <th>Kapsam</th>
                        <th>Başlangıç</th>
                        <th>Bitiş</th>
                        <th>Katılım</th>
                        <th>Durum</th>
                        <th>İşlemler</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if (empty($surveys)): ?>
                        <tr>
                            <td colspan="8" class="text-center">Henüz anket bulunmuyor.</td>
                        </tr>
                    <?php else: ?>
                        <?php foreach ($surveys as $survey): ?>
                            <tr>
                                <td><?= $survey['id'] ?></td>
                                <td><?= htmlspecialchars($survey['title']) ?></td>
                                <td><?= htmlspecialchars($survey['short_title']) ?></td>
                                <td>
                                    <?php
                                    switch ($survey['scope_type']) {
                                        case 'general':
                                            echo 'Genel';
                                            break;
                                        case 'city':
                                            echo 'İl: ' . ($survey['city_id'] === 'all' ? 'Tüm Türkiye' : get_city_name($survey['city_id']));
                                            break;
                                        case 'district':
                                            echo 'İlçe: ' . get_district_name($survey['district_id']);
                                            break;
                                    }
                                    ?>
                                </td>
                                <td><?= htmlspecialchars($survey['start_date']) ?></td>
                                <td><?= htmlspecialchars($survey['end_date']) ?></td>
                                <td>
                                    <?= number_format($survey['total_votes']) ?> / <?= number_format($survey['total_users']) ?> 
                                    (<?= round(($survey['total_votes'] / $survey['total_users']) * 100, 1) ?>%)
                                </td>
                                <td>
                                    <?= $survey['is_active'] 
                                        ? '<span class="badge text-bg-success">Aktif</span>' 
                                        : '<span class="badge text-bg-danger">Pasif</span>' ?>
                                </td>
                                <td>
                                    <div class="btn-group btn-group-sm">
                                        <a href="?page=surveys&view_survey=<?= $survey['id'] ?>" class="btn btn-outline-primary">
                                            <i class="bi bi-eye"></i>
                                        </a>
                                        <a href="?page=surveys&edit_survey=<?= $survey['id'] ?>" class="btn btn-outline-secondary">
                                            <i class="bi bi-pencil"></i>
                                        </a>
                                    </div>
                                </td>
                            </tr>
                        <?php endforeach; ?>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>