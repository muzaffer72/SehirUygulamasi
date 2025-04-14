<?php
// Kategoriler yönetim sayfası

// DB bağlantısını kontrol et
if (!isset($db)) {
    require_once 'includes/db_config.php';
}

// Kategori ID'si var mı kontrol et
$category_id = isset($_GET['id']) ? intval($_GET['id']) : 0;

// Kategori silme işlemi
if (isset($_GET['action']) && $_GET['action'] == 'delete' && $category_id > 0) {
    try {
        // İlişkili şikayetleri ve anketleri kontrol et
        $check_usage_query = "
            SELECT 
                (SELECT COUNT(*) FROM posts WHERE category_id = ?) as post_count,
                (SELECT COUNT(*) FROM surveys WHERE category_id = ?) as survey_count
        ";
        
        $check_stmt = $db->prepare($check_usage_query);
        $check_stmt->bind_param("ii", $category_id, $category_id);
        $check_stmt->execute();
        $check_result = $check_stmt->get_result();
        $usage = $check_result->fetch_assoc();
        
        if ($usage['post_count'] > 0 || $usage['survey_count'] > 0) {
            $error_message = "Bu kategori silinemiyor. {$usage['post_count']} şikayet ve {$usage['survey_count']} anket bu kategoriye bağlı.";
        } else {
            // Kategoriyi sil
            $delete_query = "DELETE FROM categories WHERE id = ?";
            $stmt = $db->prepare($delete_query);
            $stmt->bind_param("i", $category_id);
            
            if ($stmt->execute()) {
                $success_message = "Kategori başarıyla silindi.";
                // Kategori listesine yönlendir
                header("Location: ?page=categories&success=1");
                exit;
            } else {
                $error_message = "Kategori silinirken hata oluştu: " . $db->error;
            }
        }
    } catch (Exception $e) {
        $error_message = "Kategori silinirken hata oluştu: " . $e->getMessage();
    }
}

// Kategori ekleme işlemi
if (isset($_POST['add_category'])) {
    $name = trim($_POST['name']);
    $description = trim($_POST['description'] ?? '');
    $icon = trim($_POST['icon'] ?? '');
    $color = trim($_POST['color'] ?? '#1976d2');
    $is_active = isset($_POST['is_active']) ? 1 : 0;
    $display_order = isset($_POST['display_order']) ? intval($_POST['display_order']) : 0;
    
    if (empty($name)) {
        $error_message = "Kategori adı zorunludur.";
    } else {
        try {
            // Kategori adının benzersiz olduğunu kontrol et
            $check_query = "SELECT COUNT(*) as count FROM categories WHERE name = ?";
            $check_stmt = $db->prepare($check_query);
            $check_stmt->bind_param("s", $name);
            $check_stmt->execute();
            $check_result = $check_stmt->get_result();
            $check_data = $check_result->fetch_assoc();
            
            if ($check_data['count'] > 0) {
                $error_message = "Bu isimde bir kategori zaten var.";
            } else {
                // Kategoriyi ekle
                $insert_query = "INSERT INTO categories (name, description, icon, color, is_active, display_order) VALUES (?, ?, ?, ?, ?, ?)";
                $stmt = $db->prepare($insert_query);
                $stmt->bind_param("ssssii", $name, $description, $icon, $color, $is_active, $display_order);
                
                if ($stmt->execute()) {
                    $success_message = "Kategori başarıyla eklendi.";
                    // Formu temizle
                    unset($_POST);
                } else {
                    $error_message = "Kategori eklenirken hata oluştu: " . $db->error;
                }
            }
        } catch (Exception $e) {
            $error_message = "Kategori eklenirken hata oluştu: " . $e->getMessage();
        }
    }
}

// Kategori güncelleme işlemi
if (isset($_POST['update_category'])) {
    $category_id = intval($_POST['category_id']);
    $name = trim($_POST['name']);
    $description = trim($_POST['description'] ?? '');
    $icon = trim($_POST['icon'] ?? '');
    $color = trim($_POST['color'] ?? '#1976d2');
    $is_active = isset($_POST['is_active']) ? 1 : 0;
    $display_order = isset($_POST['display_order']) ? intval($_POST['display_order']) : 0;
    
    if (empty($name)) {
        $error_message = "Kategori adı zorunludur.";
    } else {
        try {
            // Kategori adının benzersiz olduğunu kontrol et (kendi ID'si hariç)
            $check_query = "SELECT COUNT(*) as count FROM categories WHERE name = ? AND id != ?";
            $check_stmt = $db->prepare($check_query);
            $check_stmt->bind_param("si", $name, $category_id);
            $check_stmt->execute();
            $check_result = $check_stmt->get_result();
            $check_data = $check_result->fetch_assoc();
            
            if ($check_data['count'] > 0) {
                $error_message = "Bu isimde bir kategori zaten var.";
            } else {
                // Kategoriyi güncelle
                $update_query = "UPDATE categories SET name = ?, description = ?, icon = ?, color = ?, is_active = ?, display_order = ? WHERE id = ?";
                $stmt = $db->prepare($update_query);
                $stmt->bind_param("ssssiii", $name, $description, $icon, $color, $is_active, $display_order, $category_id);
                
                if ($stmt->execute()) {
                    $success_message = "Kategori başarıyla güncellendi.";
                } else {
                    $error_message = "Kategori güncellenirken hata oluştu: " . $db->error;
                }
            }
        } catch (Exception $e) {
            $error_message = "Kategori güncellenirken hata oluştu: " . $e->getMessage();
        }
    }
}

// Tüm kategorileri getir
try {
    $query = "SELECT 
                c.*,
                (SELECT COUNT(*) FROM posts WHERE category_id = c.id) as post_count,
                (SELECT COUNT(*) FROM surveys WHERE category_id = c.id) as survey_count
              FROM categories c
              ORDER BY c.name ASC";
    
    $pgresult = pg_query($conn, $query);
    
    if (!$pgresult) {
        throw new Exception("Veritabanı sorgu hatası: " . pg_last_error($conn));
    }
    
    $categories = [];
    while ($row = pg_fetch_assoc($pgresult)) {
        $categories[] = $row;
    }
} catch (Exception $e) {
    $error_message = "Kategoriler alınırken hata oluştu: " . $e->getMessage();
    $categories = [];
}

// Düzenlenecek kategoriyi getir
$edit_category = null;
if (isset($_GET['action']) && $_GET['action'] == 'edit' && $category_id > 0) {
    try {
        $query = "SELECT * FROM categories WHERE id = ?";
        $stmt = $db->prepare($query);
        $result = pg_query_params($conn, "SELECT * FROM categories WHERE id = $1", array($category_id));
        
        if (pg_num_rows($result) > 0) {
            $edit_category = pg_fetch_assoc($result);
        } else {
            $error_message = "Kategori bulunamadı.";
        }
    } catch (Exception $e) {
        $error_message = "Kategori bilgisi alınırken hata oluştu: " . $e->getMessage();
    }
}

// Son eklenen kategori ID'sini al
$max_order = 0;
foreach ($categories as $cat) {
    $display_order = isset($cat['display_order']) ? intval($cat['display_order']) : 0;
    if ($display_order > $max_order) {
        $max_order = $display_order;
    }
}
?>

<div class="container-fluid">
    <!-- Success/Error Messages -->
    <?php if (isset($success_message)): ?>
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
    
    <!-- Page Header -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="h3 mb-0 text-gray-800">Kategoriler</h1>
        <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addCategoryModal">
            <i class="bi bi-plus-circle"></i> Yeni Kategori Ekle
        </button>
    </div>
    
    <!-- Kategori Düzenleme Formu -->
    <?php if ($edit_category): ?>
        <div class="card mb-4">
            <div class="card-header d-flex justify-content-between align-items-center">
                <h5 class="mb-0"><?php echo htmlspecialchars($edit_category['name']); ?> Kategorisini Düzenle</h5>
                <a href="?page=categories" class="btn btn-sm btn-outline-secondary">
                    <i class="bi bi-x-lg"></i> İptal
                </a>
            </div>
            <div class="card-body">
                <form method="post" action="?page=categories">
                    <input type="hidden" name="category_id" value="<?php echo $edit_category['id']; ?>">
                    
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label for="name" class="form-label">Kategori Adı</label>
                            <input type="text" class="form-control" id="name" name="name" value="<?php echo htmlspecialchars($edit_category['name']); ?>" required>
                        </div>
                        
                        <div class="col-md-6 mb-3">
                            <label for="icon" class="form-label">İkon (Font Awesome veya Bootstrap Icon kodu)</label>
                            <input type="text" class="form-control" id="icon" name="icon" value="<?php echo htmlspecialchars($edit_category['icon'] ?? ''); ?>" placeholder="Örn: bi-house, fa-home">
                            <div class="form-text">Bootstrap Icons için "bi-" ön ekiyle başlayan kod. Örn: bi-house</div>
                        </div>
                        
                        <div class="col-md-6 mb-3">
                            <label for="color" class="form-label">Renk</label>
                            <div class="input-group">
                                <input type="color" class="form-control form-control-color" id="color" name="color" value="<?php echo htmlspecialchars($edit_category['color'] ?? '#1976d2'); ?>">
                                <input type="text" class="form-control" id="colorText" value="<?php echo htmlspecialchars($edit_category['color'] ?? '#1976d2'); ?>" readonly>
                            </div>
                        </div>
                        
                        <div class="col-md-6 mb-3">
                            <div class="d-flex justify-content-between">
                                <div>
                                    <label for="display_order" class="form-label">Görüntüleme Sırası</label>
                                    <input type="number" class="form-control" id="display_order" name="display_order" value="<?php echo intval($edit_category['display_order'] ?? 0); ?>" min="0">
                                </div>
                                <div class="ms-3">
                                    <label class="form-label">Durum</label>
                                    <div class="form-check form-switch mt-2">
                                        <input class="form-check-input" type="checkbox" id="is_active" name="is_active" <?php echo ($edit_category['is_active'] ?? 1) ? 'checked' : ''; ?>>
                                        <label class="form-check-label" for="is_active">Aktif</label>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <div class="col-md-12 mb-3">
                            <label for="description" class="form-label">Açıklama</label>
                            <textarea class="form-control" id="description" name="description" rows="3"><?php echo htmlspecialchars($edit_category['description'] ?? ''); ?></textarea>
                        </div>
                    </div>
                    
                    <div class="d-flex justify-content-between">
                        <a href="?page=categories" class="btn btn-outline-secondary">İptal</a>
                        <button type="submit" name="update_category" class="btn btn-primary">Kaydet</button>
                    </div>
                </form>
            </div>
        </div>
    <?php endif; ?>
    
    <!-- Kategoriler Tablosu -->
    <div class="card">
        <div class="card-header">
            <h5 class="mb-0">Tüm Kategoriler</h5>
        </div>
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-hover">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Kategori</th>
                            <th>Açıklama</th>
                            <th class="text-center">Şikayet</th>
                            <th class="text-center">Anket</th>
                            <th class="text-center">Sıra</th>
                            <th class="text-center">Durum</th>
                            <th class="text-end">İşlemler</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php if (count($categories) > 0): ?>
                            <?php foreach ($categories as $category): ?>
                                <tr>
                                    <td><?php echo $category['id']; ?></td>
                                    <td>
                                        <div class="d-flex align-items-center">
                                            <?php if (!empty($category['icon'])): ?>
                                                <span class="me-2">
                                                    <i class="<?php echo htmlspecialchars($category['icon']); ?>" style="color: <?php echo htmlspecialchars($category['color'] ?? '#1976d2'); ?>"></i>
                                                </span>
                                            <?php else: ?>
                                                <span class="badge rounded-circle p-2 me-2" style="background-color: <?php echo htmlspecialchars($category['color'] ?? '#1976d2'); ?>">
                                                    &nbsp;
                                                </span>
                                            <?php endif; ?>
                                            <?php echo htmlspecialchars($category['name']); ?>
                                        </div>
                                    </td>
                                    <td><?php echo htmlspecialchars($category['description'] ?? ''); ?></td>
                                    <td class="text-center"><?php echo intval($category['post_count']); ?></td>
                                    <td class="text-center"><?php echo intval($category['survey_count']); ?></td>
                                    <td class="text-center"><?php echo isset($category['display_order']) ? intval($category['display_order']) : 0; ?></td>
                                    <td class="text-center">
                                        <?php if (isset($category['is_active']) && $category['is_active']): ?>
                                            <span class="badge bg-success">Aktif</span>
                                        <?php else: ?>
                                            <span class="badge bg-danger">Pasif</span>
                                        <?php endif; ?>
                                    </td>
                                    <td class="text-end">
                                        <a href="?page=categories&action=edit&id=<?php echo $category['id']; ?>" class="btn btn-sm btn-outline-primary">
                                            <i class="bi bi-pencil"></i>
                                        </a>
                                        
                                        <?php if ($category['post_count'] == 0 && $category['survey_count'] == 0): ?>
                                            <a href="?page=categories&action=delete&id=<?php echo $category['id']; ?>" class="btn btn-sm btn-outline-danger" onclick="return confirm('Bu kategoriyi silmek istediğinize emin misiniz?');">
                                                <i class="bi bi-trash"></i>
                                            </a>
                                        <?php else: ?>
                                            <button class="btn btn-sm btn-outline-danger" disabled data-bs-toggle="tooltip" title="Bu kategori şikayet veya anketlerde kullanıldığı için silinemez.">
                                                <i class="bi bi-trash"></i>
                                            </button>
                                        <?php endif; ?>
                                    </td>
                                </tr>
                            <?php endforeach; ?>
                        <?php else: ?>
                            <tr>
                                <td colspan="8" class="text-center">Henüz kategori bulunmuyor.</td>
                            </tr>
                        <?php endif; ?>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- Yeni Kategori Ekleme Modal -->
<div class="modal fade" id="addCategoryModal" tabindex="-1" aria-labelledby="addCategoryModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <form method="post" action="?page=categories">
                <div class="modal-header">
                    <h5 class="modal-title" id="addCategoryModalLabel">Yeni Kategori Ekle</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label for="add_name" class="form-label">Kategori Adı</label>
                            <input type="text" class="form-control" id="add_name" name="name" required>
                        </div>
                        
                        <div class="col-md-6 mb-3">
                            <label for="add_icon" class="form-label">İkon (Bootstrap Icons kodu)</label>
                            <input type="text" class="form-control" id="add_icon" name="icon" placeholder="Örn: bi-house">
                            <div class="form-text">Bootstrap Icons için "bi-" ön ekiyle başlayan kod. Örn: bi-house</div>
                        </div>
                        
                        <div class="col-md-6 mb-3">
                            <label for="add_color" class="form-label">Renk</label>
                            <div class="input-group">
                                <input type="color" class="form-control form-control-color" id="add_color" name="color" value="#1976d2">
                                <input type="text" class="form-control" id="add_colorText" value="#1976d2" readonly>
                            </div>
                        </div>
                        
                        <div class="col-md-6 mb-3">
                            <div class="d-flex justify-content-between">
                                <div>
                                    <label for="add_display_order" class="form-label">Görüntüleme Sırası</label>
                                    <input type="number" class="form-control" id="add_display_order" name="display_order" value="<?php echo $max_order + 1; ?>" min="0">
                                </div>
                                <div class="ms-3">
                                    <label class="form-label">Durum</label>
                                    <div class="form-check form-switch mt-2">
                                        <input class="form-check-input" type="checkbox" id="add_is_active" name="is_active" checked>
                                        <label class="form-check-label" for="add_is_active">Aktif</label>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <div class="col-md-12 mb-3">
                            <label for="add_description" class="form-label">Açıklama</label>
                            <textarea class="form-control" id="add_description" name="description" rows="3"></textarea>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">İptal</button>
                    <button type="submit" name="add_category" class="btn btn-primary">Ekle</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    // Renk girişi için yardımcı script
    document.addEventListener('DOMContentLoaded', function() {
        // Edit form color sync
        const colorInput = document.getElementById('color');
        const colorText = document.getElementById('colorText');
        
        if (colorInput && colorText) {
            colorInput.addEventListener('input', function() {
                colorText.value = colorInput.value;
            });
        }
        
        // Add form color sync
        const addColorInput = document.getElementById('add_color');
        const addColorText = document.getElementById('add_colorText');
        
        if (addColorInput && addColorText) {
            addColorInput.addEventListener('input', function() {
                addColorText.value = addColorInput.value;
            });
        }
        
        // Bootstrap tooltips
        const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
        if (typeof bootstrap !== 'undefined') {
            tooltipTriggerList.map(function (tooltipTriggerEl) {
                return new bootstrap.Tooltip(tooltipTriggerEl);
            });
        }
    });
</script>