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
                    </div>
                    <div class="col-md-6">
                        <p><strong>Başlangıç:</strong> <?= htmlspecialchars($survey['start_date']) ?></p>
                        <p><strong>Bitiş:</strong> <?= htmlspecialchars($survey['end_date']) ?></p>
                        <p><strong>Toplam Oy:</strong> <?= number_format($survey['total_votes']) ?> / <?= number_format($survey['total_users']) ?> (<?= round(($survey['total_votes'] / $survey['total_users']) * 100, 1) ?>%)</p>
                    </div>
                </div>
                
                <h5 class="mb-3">Anket Seçenekleri</h5>
                
                <?php if (empty($survey['options'])): ?>
                    <p class="text-muted">Bu anket için hiç seçenek tanımlanmamış.</p>
                <?php else: ?>
                    <?php foreach ($survey['options'] as $option): ?>
                        <div class="mb-3">
                            <div class="d-flex justify-content-between">
                                <span><?= htmlspecialchars($option['text']) ?></span>
                                <span><?= $option['vote_count'] ?> oy (<?= $survey['total_votes'] > 0 ? round(($option['vote_count'] / $survey['total_votes']) * 100, 1) : 0 ?>%)</span>
                            </div>
                            <div class="progress" style="height: 10px;">
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
    
    <script>
        // Anket kapsamına göre seçenekleri göster/gizle
        function toggleScopeOptions() {
            const scopeType = document.getElementById('scope_type').value;
            const cityOptions = document.getElementById('city-options');
            const districtOptions = document.getElementById('district-options');
            
            // Tüm seçenekleri sıfırla
            cityOptions.style.display = 'none';
            districtOptions.style.display = 'none';
            
            // Seçime göre göster
            if (scopeType === 'city') {
                cityOptions.style.display = 'flex';
            } else if (scopeType === 'district') {
                districtOptions.style.display = 'flex';
            }
        }
        
        // İle göre ilçeleri yükle
        function loadDistricts() {
            const cityId = document.getElementById('district_city_id').value;
            const districtSelect = document.getElementById('district_id');
            
            // Seçim yapılmadıysa ilçe seçimini devre dışı bırak
            if (!cityId) {
                districtSelect.disabled = true;
                districtSelect.innerHTML = '<option value="">Önce il seçiniz...</option>';
                return;
            }
            
            // İlçeleri filtrele
            const districts = <?= json_encode($districts) ?>;
            const cityDistricts = districts.filter(d => d.city_id == cityId);
            
            // İlçe seçeneği yoksa uyarı göster
            if (cityDistricts.length === 0) {
                districtSelect.disabled = true;
                districtSelect.innerHTML = '<option value="">Bu il için ilçe tanımlanmamış</option>';
                return;
            }
            
            // İlçeleri yükle
            districtSelect.disabled = false;
            districtSelect.innerHTML = '<option value="">Seçiniz...</option>';
            
            cityDistricts.forEach(district => {
                const option = document.createElement('option');
                option.value = district.id;
                option.textContent = district.name;
                districtSelect.appendChild(option);
            });
        }
        
        // Yeni seçenek ekle
        function addOption() {
            const container = document.getElementById('options-container');
            const optionCount = container.children.length + 1;
            
            const optionDiv = document.createElement('div');
            optionDiv.className = 'input-group mb-2';
            optionDiv.innerHTML = `
                <input type="text" class="form-control" name="options[]" placeholder="Seçenek ${optionCount}" required>
                <button class="btn btn-outline-danger" type="button" onclick="removeOption(this)">Sil</button>
            `;
            
            container.appendChild(optionDiv);
        }
        
        // Seçenek sil
        function removeOption(button) {
            const container = document.getElementById('options-container');
            
            // En az 2 seçenek olmalı
            if (container.children.length <= 2) {
                alert('En az 2 seçenek olmalıdır.');
                return;
            }
            
            button.parentElement.remove();
            
            // Kalan seçeneklerin placeholderlarını güncelle
            Array.from(container.children).forEach((div, index) => {
                const input = div.querySelector('input');
                input.placeholder = `Seçenek ${index + 1}`;
            });
        }
    </script>
    <?php
    return;
}

// Anketleri listele
?>
<div class="card mb-4">
    <div class="card-header d-flex justify-content-between align-items-center">
        <span>Anketler</span>
        <a href="?page=surveys&add_survey=1" class="btn btn-sm btn-primary">
            <i class="bi bi-plus"></i> Yeni Anket Ekle
        </a>
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