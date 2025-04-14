<?php
// Arama Önerileri Yönetim Sayfası

// Değişkenleri başlat
$success_message = '';
$error_message = '';
$suggestion_id = isset($_GET['id']) ? intval($_GET['id']) : 0;

// Veritabanı bağlantısını al
$conn = pg_connect("host={$db_host} port={$db_port} dbname={$db_name} user={$db_user} password={$db_password}");
if (!$conn) {
    $error_message = "Veritabanı bağlantı hatası: " . pg_last_error();
}

// Tablo var mı kontrol et, yoksa oluştur
$create_table_query = "
CREATE TABLE IF NOT EXISTS search_suggestions (
    id SERIAL PRIMARY KEY,
    text VARCHAR(100) NOT NULL,
    display_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);";

$result = pg_query($conn, $create_table_query);
if (!$result) {
    $error_message = "Tablo oluşturma hatası: " . pg_last_error($conn);
}

// Yeni öneri ekleme
if ($_SERVER['REQUEST_METHOD'] == 'POST' && isset($_POST['add_suggestion'])) {
    $text = $_POST['text'] ?? '';
    $display_order = isset($_POST['display_order']) ? intval($_POST['display_order']) : 0;
    $is_active = isset($_POST['is_active']) ? true : false;
    
    if (empty($text)) {
        $error_message = "Öneri metni boş olamaz!";
    } else {
        try {
            $insert_query = "INSERT INTO search_suggestions (text, display_order, is_active) VALUES ($1, $2, $3)";
            $result = pg_query_params($conn, $insert_query, array($text, $display_order, $is_active));
            
            if ($result) {
                $success_message = "Arama önerisi başarıyla eklendi.";
            } else {
                $error_message = "Arama önerisi eklenirken hata oluştu: " . pg_last_error($conn);
            }
        } catch (Exception $e) {
            $error_message = "Hata: " . $e->getMessage();
        }
    }
}

// Öneri güncelleme
if ($_SERVER['REQUEST_METHOD'] == 'POST' && isset($_POST['update_suggestion'])) {
    $suggestion_id = isset($_POST['suggestion_id']) ? intval($_POST['suggestion_id']) : 0;
    $text = $_POST['text'] ?? '';
    $display_order = isset($_POST['display_order']) ? intval($_POST['display_order']) : 0;
    $is_active = isset($_POST['is_active']) ? true : false;
    
    if (empty($text)) {
        $error_message = "Öneri metni boş olamaz!";
    } else if ($suggestion_id <= 0) {
        $error_message = "Geçersiz öneri ID!";
    } else {
        try {
            $update_query = "UPDATE search_suggestions SET text = $1, display_order = $2, is_active = $3, updated_at = NOW() WHERE id = $4";
            $result = pg_query_params($conn, $update_query, array($text, $display_order, $is_active, $suggestion_id));
            
            if ($result) {
                $success_message = "Arama önerisi başarıyla güncellendi.";
            } else {
                $error_message = "Arama önerisi güncellenirken hata oluştu: " . pg_last_error($conn);
            }
        } catch (Exception $e) {
            $error_message = "Hata: " . $e->getMessage();
        }
    }
}

// Öneri silme
if (isset($_GET['action']) && $_GET['action'] == 'delete' && $suggestion_id > 0) {
    try {
        $delete_query = "DELETE FROM search_suggestions WHERE id = $1";
        $result = pg_query_params($conn, $delete_query, array($suggestion_id));
        
        if ($result) {
            $success_message = "Arama önerisi başarıyla silindi.";
        } else {
            $error_message = "Arama önerisi silinirken hata oluştu: " . pg_last_error($conn);
        }
    } catch (Exception $e) {
        $error_message = "Hata: " . $e->getMessage();
    }
}

// Tüm önerileri getir
try {
    $query = "SELECT * FROM search_suggestions ORDER BY display_order ASC, text ASC";
    $pgresult = pg_query($conn, $query);
    
    if (!$pgresult) {
        throw new Exception("Veritabanı sorgu hatası: " . pg_last_error($conn));
    }
    
    $suggestions = [];
    while ($row = pg_fetch_assoc($pgresult)) {
        $suggestions[] = $row;
    }
} catch (Exception $e) {
    $error_message = "Arama önerileri alınırken hata oluştu: " . $e->getMessage();
    $suggestions = [];
}

// Düzenlenecek öneriyi getir
$edit_suggestion = null;
if (isset($_GET['action']) && $_GET['action'] == 'edit' && $suggestion_id > 0) {
    try {
        $result = pg_query_params($conn, "SELECT * FROM search_suggestions WHERE id = $1", array($suggestion_id));
        
        if (pg_num_rows($result) > 0) {
            $edit_suggestion = pg_fetch_assoc($result);
        } else {
            $error_message = "Arama önerisi bulunamadı.";
        }
    } catch (Exception $e) {
        $error_message = "Arama önerisi bilgisi alınırken hata oluştu: " . $e->getMessage();
    }
}

// Son eklenen öneri sırasını al
$max_order = 0;
foreach ($suggestions as $suggestion) {
    $display_order = isset($suggestion['display_order']) ? intval($suggestion['display_order']) : 0;
    if ($display_order > $max_order) {
        $max_order = $display_order;
    }
}
?>

<div class="container-fluid">
    <!-- Success/Error Messages -->
    <?php if (isset($success_message) && !empty($success_message)): ?>
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <?php echo $success_message; ?>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    <?php endif; ?>
    
    <?php if (isset($error_message) && !empty($error_message)): ?>
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <?php echo $error_message; ?>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    <?php endif; ?>
    
    <!-- Page Header -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="h3 mb-0 text-gray-800">Arama Önerileri</h1>
        <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addSuggestionModal">
            <i class="bi bi-plus-circle"></i> Yeni Öneri Ekle
        </button>
    </div>
    
    <!-- Açıklama -->
    <div class="alert alert-info mb-4">
        <p class="mb-0">
            <i class="bi bi-info-circle me-2"></i> Bu sayfada, uygulamanın arama sayfasında görüntülenecek öneri kelimelerini yönetebilirsiniz. 
            Bu öneriler kullanıcılara arama yaparken gösterilir ve sık aranan içerikleri kolayca bulmalarına yardımcı olur.
        </p>
    </div>
    
    <!-- Öneri Düzenleme Formu -->
    <?php if ($edit_suggestion): ?>
        <div class="card mb-4">
            <div class="card-header d-flex justify-content-between align-items-center">
                <h5 class="mb-0">"<?php echo htmlspecialchars($edit_suggestion['text']); ?>" Önerisini Düzenle</h5>
                <a href="?page=search_suggestions" class="btn btn-sm btn-outline-secondary">
                    <i class="bi bi-x-lg"></i> İptal
                </a>
            </div>
            <div class="card-body">
                <form method="post" action="?page=search_suggestions">
                    <input type="hidden" name="suggestion_id" value="<?php echo $edit_suggestion['id']; ?>">
                    
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label for="text" class="form-label">Öneri Metni</label>
                            <input type="text" class="form-control" id="text" name="text" value="<?php echo htmlspecialchars($edit_suggestion['text']); ?>" required>
                            <div class="form-text">Arama çubuğunda gösterilecek metin.</div>
                        </div>
                        
                        <div class="col-md-6 mb-3">
                            <div class="d-flex justify-content-between">
                                <div>
                                    <label for="display_order" class="form-label">Görüntüleme Sırası</label>
                                    <input type="number" class="form-control" id="display_order" name="display_order" value="<?php echo intval($edit_suggestion['display_order'] ?? 0); ?>" min="0">
                                    <div class="form-text">Düşük sayı daha önce gösterilir.</div>
                                </div>
                                <div class="ms-3">
                                    <label class="form-label">Durum</label>
                                    <div class="form-check form-switch mt-2">
                                        <input class="form-check-input" type="checkbox" id="is_active" name="is_active" <?php echo ($edit_suggestion['is_active'] == 't') ? 'checked' : ''; ?>>
                                        <label class="form-check-label" for="is_active">Aktif</label>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="d-flex justify-content-between">
                        <a href="?page=search_suggestions" class="btn btn-outline-secondary">İptal</a>
                        <button type="submit" name="update_suggestion" class="btn btn-primary">Kaydet</button>
                    </div>
                </form>
            </div>
        </div>
    <?php endif; ?>
    
    <!-- Öneriler Tablosu -->
    <div class="card">
        <div class="card-header">
            <h5 class="mb-0">Tüm Arama Önerileri</h5>
        </div>
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-hover">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Öneri Metni</th>
                            <th class="text-center">Sıra</th>
                            <th class="text-center">Durum</th>
                            <th class="text-center">Oluşturulma Tarihi</th>
                            <th class="text-end">İşlemler</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php if (count($suggestions) > 0): ?>
                            <?php foreach ($suggestions as $suggestion): ?>
                                <tr>
                                    <td><?php echo $suggestion['id']; ?></td>
                                    <td><?php echo htmlspecialchars($suggestion['text']); ?></td>
                                    <td class="text-center"><?php echo isset($suggestion['display_order']) ? intval($suggestion['display_order']) : 0; ?></td>
                                    <td class="text-center">
                                        <?php if (isset($suggestion['is_active']) && $suggestion['is_active'] == 't'): ?>
                                            <span class="badge bg-success">Aktif</span>
                                        <?php else: ?>
                                            <span class="badge bg-danger">Pasif</span>
                                        <?php endif; ?>
                                    </td>
                                    <td class="text-center"><?php echo date('d.m.Y H:i', strtotime($suggestion['created_at'])); ?></td>
                                    <td class="text-end">
                                        <a href="?page=search_suggestions&action=edit&id=<?php echo $suggestion['id']; ?>" class="btn btn-sm btn-outline-primary">
                                            <i class="bi bi-pencil"></i>
                                        </a>
                                        <a href="?page=search_suggestions&action=delete&id=<?php echo $suggestion['id']; ?>" class="btn btn-sm btn-outline-danger" onclick="return confirm('Bu arama önerisini silmek istediğinize emin misiniz?');">
                                            <i class="bi bi-trash"></i>
                                        </a>
                                    </td>
                                </tr>
                            <?php endforeach; ?>
                        <?php else: ?>
                            <tr>
                                <td colspan="6" class="text-center">Henüz arama önerisi bulunmuyor.</td>
                            </tr>
                        <?php endif; ?>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- Yeni Öneri Ekleme Modal -->
<div class="modal fade" id="addSuggestionModal" tabindex="-1" aria-labelledby="addSuggestionModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <form method="post" action="?page=search_suggestions">
                <div class="modal-header">
                    <h5 class="modal-title" id="addSuggestionModalLabel">Yeni Arama Önerisi Ekle</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label for="add_text" class="form-label">Öneri Metni</label>
                            <input type="text" class="form-control" id="add_text" name="text" required>
                            <div class="form-text">Arama çubuğunda gösterilecek metin.</div>
                        </div>
                        
                        <div class="col-md-6 mb-3">
                            <div class="d-flex justify-content-between">
                                <div>
                                    <label for="add_display_order" class="form-label">Görüntüleme Sırası</label>
                                    <input type="number" class="form-control" id="add_display_order" name="display_order" value="<?php echo $max_order + 1; ?>" min="0">
                                    <div class="form-text">Düşük sayı daha önce gösterilir.</div>
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
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">İptal</button>
                    <button type="submit" name="add_suggestion" class="btn btn-primary">Ekle</button>
                </div>
            </form>
        </div>
    </div>
</div>