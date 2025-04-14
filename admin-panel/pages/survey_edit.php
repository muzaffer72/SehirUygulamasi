<?php
// Anket Düzenleme Sayfası
// Bu sayfa anketlerin düzenlenmesini sağlar

// ID'yi kontrol et
if (!isset($_GET['id']) || empty($_GET['id'])) {
    echo '<div class="alert alert-danger">Anket ID bulunamadı.</div>';
    echo '<a href="?page=surveys" class="btn btn-primary">Anket Listesine Dön</a>';
    exit;
}

$survey_id = intval($_GET['id']);
$success_message = "";
$error_message = "";

// Anket bilgilerini getir
try {
    $query = "SELECT * FROM surveys WHERE id = ?";
    $stmt = $db->prepare($query);
    $stmt->bind_param("i", $survey_id);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows === 0) {
        echo '<div class="alert alert-danger">Anket bulunamadı.</div>';
        echo '<a href="?page=surveys" class="btn btn-primary">Anket Listesine Dön</a>';
        exit;
    }
    
    $survey = $result->fetch_assoc();
    
    // Anket seçeneklerini getir
    $options_query = "SELECT * FROM survey_options WHERE survey_id = ? ORDER BY id ASC";
    $options_stmt = $db->prepare($options_query);
    $options_stmt->bind_param("i", $survey_id);
    $options_stmt->execute();
    $options_result = $options_stmt->get_result();
    $options = [];
    while ($option = $options_result->fetch_assoc()) {
        $options[] = $option;
    }
} catch (Exception $e) {
    echo '<div class="alert alert-danger">Anket bilgisi alınamadı: ' . $e->getMessage() . '</div>';
    echo '<a href="?page=surveys" class="btn btn-primary">Anket Listesine Dön</a>';
    exit;
}

// Form gönderildiğinde
if ($_SERVER['REQUEST_METHOD'] == 'POST' && isset($_POST['update_survey'])) {
    $title = $_POST['title'] ?? '';
    $short_title = $_POST['short_title'] ?? '';
    $description = $_POST['description'] ?? '';
    $scope_type = $_POST['scope_type'] ?? 'general';
    $city_id = isset($_POST['city_id']) && $_POST['city_id'] != '' ? intval($_POST['city_id']) : null;
    $district_id = isset($_POST['district_id']) && $_POST['district_id'] != '' ? intval($_POST['district_id']) : null;
    $category_id = isset($_POST['category_id']) ? intval($_POST['category_id']) : 0;
    $is_active = isset($_POST['is_active']) ? 1 : 0;
    $is_pinned = isset($_POST['is_pinned']) ? 1 : 0;
    $start_date = $_POST['start_date'] ?? date('Y-m-d H:i:s');
    $end_date = $_POST['end_date'] ?? date('Y-m-d H:i:s', strtotime('+7 days'));
    $sort_order = isset($_POST['sort_order']) ? intval($_POST['sort_order']) : 0;
    
    // Seçenekler
    $option_texts = $_POST['option_texts'] ?? [];
    $option_ids = $_POST['option_ids'] ?? [];
    $option_vote_counts = $_POST['option_vote_counts'] ?? [];
    
    // Doğrulama
    if (empty($title) || empty($description) || $category_id <= 0) {
        $error_message = "Anket başlığı, açıklama ve kategori seçimi zorunludur!";
    } elseif (empty($option_texts) || count($option_texts) < 2) {
        $error_message = "En az 2 anket seçeneği eklenmelidir!";
    } else {
        try {
            // İşlem başlat
            $db->begin_transaction();
            
            // Anket bilgilerini güncelle
            $query = "UPDATE surveys SET 
                title = ?, 
                short_title = ?,
                description = ?,
                scope_type = ?,
                city_id = ?,
                district_id = ?,
                category_id = ?,
                is_active = ?,
                start_date = ?,
                end_date = ?,
                sort_order = ?,
                updated_at = NOW()
                WHERE id = ?";
                
            $stmt = $db->prepare($query);
            $stmt->bind_param("ssssiiiissii", 
                $title, 
                $short_title,
                $description,
                $scope_type,
                $city_id,
                $district_id,
                $category_id,
                $is_active,
                $start_date,
                $end_date,
                $sort_order,
                $survey_id
            );
            $stmt->execute();
            
            // Mevcut seçenekleri güncelle
            foreach ($option_ids as $index => $option_id) {
                if (empty($option_texts[$index])) continue;
                
                $option_text = $option_texts[$index];
                $vote_count = isset($option_vote_counts[$index]) ? intval($option_vote_counts[$index]) : 0;
                
                if ($option_id > 0) {
                    // Mevcut seçeneği güncelle
                    $option_query = "UPDATE survey_options SET 
                        text = ?, 
                        vote_count = ? 
                        WHERE id = ? AND survey_id = ?";
                    $option_stmt = $db->prepare($option_query);
                    $option_stmt->bind_param("siii", $option_text, $vote_count, $option_id, $survey_id);
                    $option_stmt->execute();
                } else {
                    // Yeni seçenek ekle
                    $option_query = "INSERT INTO survey_options (survey_id, text, vote_count, created_at) 
                                      VALUES (?, ?, ?, NOW())";
                    $option_stmt = $db->prepare($option_query);
                    $option_stmt->bind_param("isi", $survey_id, $option_text, $vote_count);
                    $option_stmt->execute();
                }
            }
            
            // İşlemi tamamla
            $db->commit();
            $success_message = "Anket başarıyla güncellendi.";
            
            // Güncel anket bilgilerini al
            $query = "SELECT * FROM surveys WHERE id = ?";
            $stmt = $db->prepare($query);
            $stmt->bind_param("i", $survey_id);
            $stmt->execute();
            $result = $stmt->get_result();
            $survey = $result->fetch_assoc();
            
            // Güncel anket seçeneklerini al
            $options_query = "SELECT * FROM survey_options WHERE survey_id = ? ORDER BY id ASC";
            $options_stmt = $db->prepare($options_query);
            $options_stmt->bind_param("i", $survey_id);
            $options_stmt->execute();
            $options_result = $options_stmt->get_result();
            $options = [];
            while ($option = $options_result->fetch_assoc()) {
                $options[] = $option;
            }
        } catch (Exception $e) {
            // Hata durumunda işlemi geri al
            $db->rollback();
            $error_message = "Anket güncellenirken hata oluştu: " . $e->getMessage();
        }
    }
}

// Şehirleri getir
try {
    $query = "SELECT id, name FROM cities ORDER BY name ASC";
    $stmt = $db->prepare($query);
    $stmt->execute();
    $result = $stmt->get_result();
    $cities = [];
    while ($row = $result->fetch_assoc()) {
        $cities[] = $row;
    }
} catch (Exception $e) {
    $error_message = "Şehir listesi alınamadı: " . $e->getMessage();
    $cities = [];
}

// İlçeleri getir
try {
    $query = "SELECT d.id, d.name, d.city_id, c.name as city_name 
              FROM districts d 
              LEFT JOIN cities c ON d.city_id = c.id 
              ORDER BY c.name ASC, d.name ASC";
    $stmt = $db->prepare($query);
    $stmt->execute();
    $result = $stmt->get_result();
    $districts = [];
    while ($row = $result->fetch_assoc()) {
        $districts[] = $row;
    }
} catch (Exception $e) {
    $error_message = "İlçe listesi alınamadı: " . $e->getMessage();
    $districts = [];
}

// Kategorileri getir
try {
    $query = "SELECT id, name FROM categories ORDER BY name ASC";
    $stmt = $db->prepare($query);
    $stmt->execute();
    $result = $stmt->get_result();
    $categories = [];
    while ($row = $result->fetch_assoc()) {
        $categories[] = $row;
    }
} catch (Exception $e) {
    $error_message = "Kategori listesi alınamadı: " . $e->getMessage();
    $categories = [];
}

?>

<div class="container mt-4">
    <?php if (!empty($success_message)): ?>
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <?php echo $success_message; ?>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    <?php endif; ?>
    
    <?php if (!empty($error_message)): ?>
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <?php echo $error_message; ?>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    <?php endif; ?>

    <div class="card shadow-sm">
        <div class="card-header d-flex justify-content-between align-items-center">
            <h5 class="mb-0"><?php echo htmlspecialchars($survey['title']); ?> - Düzenle</h5>
            <div>
                <a href="?page=surveys" class="btn btn-sm btn-outline-secondary me-1">
                    <i class="bi bi-arrow-left"></i> Anket Listesine Dön
                </a>
                <a href="?page=survey_delete&id=<?php echo $survey_id; ?>" class="btn btn-sm btn-outline-danger">
                    <i class="bi bi-trash"></i> Anket Sil
                </a>
            </div>
        </div>
        <div class="card-body">
            <form method="post" action="?page=survey_edit&id=<?php echo $survey_id; ?>">
                <!-- Temel Bilgiler -->
                <div class="row mb-4">
                    <div class="col-md-12">
                        <h5>Anket Bilgileri</h5>
                        <hr>
                    </div>
                    
                    <div class="col-md-6">
                        <div class="mb-3">
                            <label for="title" class="form-label">Anket Başlığı</label>
                            <input type="text" class="form-control" id="title" name="title" 
                                   value="<?php echo htmlspecialchars($survey['title'] ?? ''); ?>" required>
                            <div class="form-text">Ana başlık, 100 karakterden az olmalıdır.</div>
                        </div>
                    </div>
                    
                    <div class="col-md-6">
                        <div class="mb-3">
                            <label for="short_title" class="form-label">Kısa Başlık</label>
                            <input type="text" class="form-control" id="short_title" name="short_title" 
                                   value="<?php echo htmlspecialchars($survey['short_title'] ?? ''); ?>">
                            <div class="form-text">Liste görünümünde kullanılacak kısa başlık, 30 karakterden az olmalıdır.</div>
                        </div>
                    </div>
                    
                    <div class="col-md-12">
                        <div class="mb-3">
                            <label for="description" class="form-label">Açıklama</label>
                            <textarea class="form-control" id="description" name="description" rows="3" required><?php echo htmlspecialchars($survey['description'] ?? ''); ?></textarea>
                            <div class="form-text">Anket ile ilgili kısa açıklama.</div>
                        </div>
                    </div>
                    
                    <div class="col-md-6">
                        <div class="mb-3">
                            <label for="category_id" class="form-label">Kategori</label>
                            <select class="form-select" id="category_id" name="category_id" required>
                                <option value="">Kategori Seçin</option>
                                <?php foreach ($categories as $category): ?>
                                    <option value="<?php echo $category['id']; ?>" 
                                        <?php echo (isset($survey['category_id']) && $survey['category_id'] == $category['id']) ? 'selected' : ''; ?>>
                                        <?php echo htmlspecialchars($category['name']); ?>
                                    </option>
                                <?php endforeach; ?>
                            </select>
                        </div>
                    </div>
                    
                    <div class="col-md-6">
                        <div class="mb-3">
                            <label for="scope_type" class="form-label">Anket Kapsamı</label>
                            <select class="form-select" id="scope_type" name="scope_type" required>
                                <option value="general" <?php echo (isset($survey['scope_type']) && $survey['scope_type'] == 'general') ? 'selected' : ''; ?>>Genel (Tüm Türkiye)</option>
                                <option value="city" <?php echo (isset($survey['scope_type']) && $survey['scope_type'] == 'city') ? 'selected' : ''; ?>>Şehir Bazlı</option>
                                <option value="district" <?php echo (isset($survey['scope_type']) && $survey['scope_type'] == 'district') ? 'selected' : ''; ?>>İlçe Bazlı</option>
                            </select>
                        </div>
                    </div>
                    
                    <div class="col-md-6 city-selection" style="<?php echo isset($survey['scope_type']) && ($survey['scope_type'] == 'city' || $survey['scope_type'] == 'district') ? '' : 'display: none;'; ?>">
                        <div class="mb-3">
                            <label for="city_id" class="form-label">Şehir</label>
                            <select class="form-select" id="city_id" name="city_id">
                                <option value="">Şehir Seçin</option>
                                <?php foreach ($cities as $city): ?>
                                    <option value="<?php echo $city['id']; ?>" 
                                        <?php echo (isset($survey['city_id']) && $survey['city_id'] == $city['id']) ? 'selected' : ''; ?>>
                                        <?php echo htmlspecialchars($city['name']); ?>
                                    </option>
                                <?php endforeach; ?>
                            </select>
                        </div>
                    </div>
                    
                    <div class="col-md-6 district-selection" style="<?php echo isset($survey['scope_type']) && $survey['scope_type'] == 'district' ? '' : 'display: none;'; ?>">
                        <div class="mb-3">
                            <label for="district_id" class="form-label">İlçe</label>
                            <select class="form-select" id="district_id" name="district_id">
                                <option value="">İlçe Seçin</option>
                                <?php foreach ($districts as $district): ?>
                                    <?php if (isset($survey['city_id']) && $district['city_id'] == $survey['city_id']): ?>
                                        <option value="<?php echo $district['id']; ?>" data-city="<?php echo $district['city_id']; ?>"
                                            <?php echo (isset($survey['district_id']) && $survey['district_id'] == $district['id']) ? 'selected' : ''; ?>>
                                            <?php echo htmlspecialchars($district['name']); ?>
                                        </option>
                                    <?php endif; ?>
                                <?php endforeach; ?>
                            </select>
                        </div>
                    </div>
                </div>
                
                <!-- Tarih ve Durum Bilgileri -->
                <div class="row mb-4">
                    <div class="col-md-12">
                        <h5>Zaman ve Durum Bilgileri</h5>
                        <hr>
                    </div>
                    
                    <div class="col-md-4">
                        <div class="mb-3">
                            <label for="start_date" class="form-label">Başlangıç Tarihi</label>
                            <input type="datetime-local" class="form-control" id="start_date" name="start_date" 
                                   value="<?php echo isset($survey['start_date']) ? date('Y-m-d\TH:i', strtotime($survey['start_date'])) : date('Y-m-d\TH:i'); ?>">
                        </div>
                    </div>
                    
                    <div class="col-md-4">
                        <div class="mb-3">
                            <label for="end_date" class="form-label">Bitiş Tarihi</label>
                            <input type="datetime-local" class="form-control" id="end_date" name="end_date" 
                                   value="<?php echo isset($survey['end_date']) ? date('Y-m-d\TH:i', strtotime($survey['end_date'])) : date('Y-m-d\TH:i', strtotime('+7 days')); ?>">
                        </div>
                    </div>
                    
                    <div class="col-md-2">
                        <div class="mb-3">
                            <label for="sort_order" class="form-label">Sıralama</label>
                            <input type="number" class="form-control" id="sort_order" name="sort_order" 
                                   value="<?php echo htmlspecialchars($survey['sort_order'] ?? '0'); ?>">
                            <div class="form-text">Düşük sayı daha önce gösterilir.</div>
                        </div>
                    </div>
                    
                    <div class="col-md-2">
                        <div class="mb-3 pt-4">
                            <div class="form-check form-switch mb-2">
                                <input class="form-check-input" type="checkbox" id="is_active" name="is_active" 
                                       <?php echo (isset($survey['is_active']) && $survey['is_active']) ? 'checked' : ''; ?>>
                                <label class="form-check-label" for="is_active">Aktif</label>
                            </div>
                            <div class="form-check form-switch">
                                <input class="form-check-input" type="checkbox" id="is_pinned" name="is_pinned" 
                                       <?php echo (isset($survey['is_pinned']) && $survey['is_pinned']) ? 'checked' : ''; ?>>
                                <label class="form-check-label" for="is_pinned">Başa Tuttur <i class="bi bi-pin-angle-fill text-primary"></i></label>
                                <div class="form-text">Bu anket arama sonuçlarında üst sırada gösterilir.</div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Anket Seçenekleri -->
                <div class="row mb-4">
                    <div class="col-md-12">
                        <h5>Anket Seçenekleri</h5>
                        <hr>
                    </div>
                    
                    <div class="col-md-12">
                        <div id="options-container">
                            <?php foreach ($options as $index => $option): ?>
                                <div class="row mb-2 option-row">
                                    <div class="col-md-7">
                                        <input type="hidden" name="option_ids[]" value="<?php echo $option['id']; ?>">
                                        <input type="text" class="form-control" placeholder="Seçenek metni" 
                                               name="option_texts[]" value="<?php echo htmlspecialchars($option['text']); ?>" required>
                                    </div>
                                    <div class="col-md-3">
                                        <input type="number" class="form-control" placeholder="Oy sayısı" 
                                               name="option_vote_counts[]" value="<?php echo $option['vote_count']; ?>">
                                    </div>
                                    <div class="col-md-2">
                                        <button type="button" class="btn btn-outline-danger btn-sm remove-option">
                                            <i class="bi bi-trash"></i> Kaldır
                                        </button>
                                    </div>
                                </div>
                            <?php endforeach; ?>
                            
                            <!-- Yeni seçenek ekleme için boş satır -->
                            <?php if (empty($options)): ?>
                                <div class="row mb-2 option-row">
                                    <div class="col-md-7">
                                        <input type="hidden" name="option_ids[]" value="0">
                                        <input type="text" class="form-control" placeholder="Seçenek metni" name="option_texts[]" required>
                                    </div>
                                    <div class="col-md-3">
                                        <input type="number" class="form-control" placeholder="Oy sayısı" name="option_vote_counts[]" value="0">
                                    </div>
                                    <div class="col-md-2">
                                        <button type="button" class="btn btn-outline-danger btn-sm remove-option">
                                            <i class="bi bi-trash"></i> Kaldır
                                        </button>
                                    </div>
                                </div>
                            <?php endif; ?>
                        </div>
                        
                        <button type="button" id="add-option" class="btn btn-outline-secondary mt-2">
                            <i class="bi bi-plus-circle"></i> Yeni Seçenek Ekle
                        </button>
                    </div>
                </div>
                
                <!-- Kaydet ve İptal Butonları -->
                <div class="d-flex justify-content-between">
                    <div>
                        <a href="?page=surveys" class="btn btn-outline-secondary">İptal</a>
                        <a href="?page=survey_delete&id=<?php echo $survey_id; ?>" 
                           class="btn btn-outline-danger ms-2" 
                           onclick="return confirm('Bu anketi silmek için onay sayfasına yönlendirileceksiniz?');">
                            <i class="bi bi-trash"></i> Anketi Sil
                        </a>
                    </div>
                    <button type="submit" name="update_survey" class="btn btn-primary">Güncelle</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        // Kapsam değişikliğinde şehir/ilçe seçimlerini göster/gizle
        const scopeTypeSelect = document.getElementById('scope_type');
        const citySelection = document.querySelector('.city-selection');
        const districtSelection = document.querySelector('.district-selection');
        const citySelect = document.getElementById('city_id');
        const districtSelect = document.getElementById('district_id');
        
        scopeTypeSelect.addEventListener('change', function() {
            if (this.value === 'city' || this.value === 'district') {
                citySelection.style.display = 'block';
                districtSelection.style.display = this.value === 'district' ? 'block' : 'none';
            } else {
                citySelection.style.display = 'none';
                districtSelection.style.display = 'none';
            }
        });
        
        // Şehir değiştiğinde ilçeleri filtrele
        citySelect.addEventListener('change', function() {
            const cityId = this.value;
            const districtOptions = districtSelect.querySelectorAll('option');
            
            // İlk seçeneği (İlçe Seçin) koru, diğerlerini temizle
            districtSelect.innerHTML = '<option value="">İlçe Seçin</option>';
            
            // Şehirlere göre ilçeleri doldur
            <?php foreach ($districts as $district): ?>
                if ('<?php echo $district['city_id']; ?>' === cityId) {
                    const option = document.createElement('option');
                    option.value = '<?php echo $district['id']; ?>';
                    option.textContent = '<?php echo htmlspecialchars($district['name']); ?>';
                    option.dataset.city = '<?php echo $district['city_id']; ?>';
                    districtSelect.appendChild(option);
                }
            <?php endforeach; ?>
        });
        
        // Seçenek ekleme ve kaldırma işlemleri
        const optionsContainer = document.getElementById('options-container');
        const addOptionButton = document.getElementById('add-option');
        
        // Yeni seçenek ekleme
        addOptionButton.addEventListener('click', function() {
            const newRow = document.createElement('div');
            newRow.className = 'row mb-2 option-row';
            newRow.innerHTML = `
                <div class="col-md-7">
                    <input type="hidden" name="option_ids[]" value="0">
                    <input type="text" class="form-control" placeholder="Seçenek metni" name="option_texts[]" required>
                </div>
                <div class="col-md-3">
                    <input type="number" class="form-control" placeholder="Oy sayısı" name="option_vote_counts[]" value="0">
                </div>
                <div class="col-md-2">
                    <button type="button" class="btn btn-outline-danger btn-sm remove-option">
                        <i class="bi bi-trash"></i> Kaldır
                    </button>
                </div>
            `;
            optionsContainer.appendChild(newRow);
            
            // Yeni eklenen satırın kaldırma butonuna dinleyici ekle
            newRow.querySelector('.remove-option').addEventListener('click', removeOption);
        });
        
        // Mevcut kaldırma butonlarına dinleyici ekle
        function addRemoveListeners() {
            document.querySelectorAll('.remove-option').forEach(button => {
                button.addEventListener('click', removeOption);
            });
        }
        
        // Seçenek kaldırma fonksiyonu
        function removeOption(e) {
            const optionRow = e.target.closest('.option-row');
            
            // En az 2 seçenek olmalı
            if (document.querySelectorAll('.option-row').length > 2) {
                optionRow.remove();
            } else {
                alert('Anket için en az 2 seçenek gereklidir!');
            }
        }
        
        // Sayfa yüklendiğinde kaldırma dinleyicilerini ekle
        addRemoveListeners();
        
        // Form gönderilmeden önce kontrol
        const form = document.querySelector('form');
        form.addEventListener('submit', function(e) {
            const optionRows = document.querySelectorAll('.option-row');
            
            if (optionRows.length < 2) {
                e.preventDefault();
                alert('Anket için en az 2 seçenek eklemelisiniz!');
            }
            
            // Boş seçenek kontrolü
            let hasEmptyOption = false;
            optionRows.forEach(row => {
                const optionText = row.querySelector('input[name="option_texts[]"]').value.trim();
                if (optionText === '') {
                    hasEmptyOption = true;
                }
            });
            
            if (hasEmptyOption) {
                e.preventDefault();
                alert('Tüm seçenek metinleri doldurulmalıdır!');
            }
        });
    });
</script>