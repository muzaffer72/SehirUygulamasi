<?php
// Anket Silme İşlemi Sayfası
// Bu sayfa survey_edit.php sayfasından yönlendirilerek anket silme işlemini yönetir

// Yetki kontrolü
requireAdmin();

// ID kontrolü
if (!isset($_GET['id']) || empty($_GET['id'])) {
    header("Location: ?page=surveys&error=" . urlencode("Anket ID bulunamadı."));
    exit;
}

$survey_id = intval($_GET['id']);

// Onay kontrolü
if (!isset($_GET['confirm']) || $_GET['confirm'] !== 'yes') {
    // Anket bilgilerini getir
    try {
        $query = "SELECT s.*, c.name as category_name, city.name as city_name, d.name as district_name 
                 FROM surveys s
                 LEFT JOIN categories c ON s.category_id = c.id
                 LEFT JOIN cities city ON s.city_id = city.id
                 LEFT JOIN districts d ON s.district_id = d.id
                 WHERE s.id = ?";
        $stmt = $db->prepare($query);
        $stmt->bind_param("i", $survey_id);
        $stmt->execute();
        $result = $stmt->get_result();
        
        if ($result->num_rows === 0) {
            header("Location: ?page=surveys&error=" . urlencode("Silinecek anket bulunamadı."));
            exit;
        }
        
        $survey = $result->fetch_assoc();
        
        // Anket seçeneklerini ve oy sayılarını getir
        $options_query = "SELECT * FROM survey_options WHERE survey_id = ? ORDER BY id ASC";
        $options_stmt = $db->prepare($options_query);
        $options_stmt->bind_param("i", $survey_id);
        $options_stmt->execute();
        $options_result = $options_stmt->get_result();
        $options = [];
        $total_votes = 0;
        
        while ($option = $options_result->fetch_assoc()) {
            $options[] = $option;
            $total_votes += $option['vote_count'];
        }
        
        // Bölgesel sonuçları sorgula
        $regional_query = "SELECT COUNT(*) as count FROM survey_regional_results WHERE survey_id = ?";
        $regional_stmt = $db->prepare($regional_query);
        $regional_stmt->bind_param("i", $survey_id);
        $regional_stmt->execute();
        $regional_result = $regional_stmt->get_result();
        $regional_count = $regional_result->fetch_assoc()['count'];
        
        ?>
        <div class="container mt-4">
            <div class="card shadow-sm">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <h5 class="mb-0 text-danger">Anket Silme Onayı</h5>
                    <a href="?page=survey_edit&id=<?php echo $survey_id; ?>" class="btn btn-sm btn-outline-secondary">
                        <i class="bi bi-arrow-left"></i> Geri Dön
                    </a>
                </div>
                <div class="card-body">
                    <div class="alert alert-danger">
                        <h5><i class="bi bi-exclamation-triangle-fill"></i> Uyarı</h5>
                        <p>"<strong><?php echo htmlspecialchars($survey['title']); ?></strong>" anketini silmek istediğinizden emin misiniz?</p>
                        
                        <div class="card mb-3">
                            <div class="card-body">
                                <h6>Anket Bilgileri:</h6>
                                <ul class="mb-0">
                                    <li><strong>Kısa Başlık:</strong> <?php echo htmlspecialchars($survey['short_title'] ?? '-'); ?></li>
                                    <li><strong>Kategori:</strong> <?php echo htmlspecialchars($survey['category_name'] ?? '-'); ?></li>
                                    <li><strong>Kapsam:</strong> 
                                        <?php 
                                        switch ($survey['scope_type']) {
                                            case 'general':
                                                echo 'Genel (Tüm Türkiye)';
                                                break;
                                            case 'city':
                                                echo 'Şehir Bazlı: ' . htmlspecialchars($survey['city_name'] ?? '-');
                                                break;
                                            case 'district':
                                                echo 'İlçe Bazlı: ' . htmlspecialchars($survey['district_name'] ?? '-') . ', ' . htmlspecialchars($survey['city_name'] ?? '-');
                                                break;
                                            default:
                                                echo 'Bilinmiyor';
                                        }
                                        ?>
                                    </li>
                                    <li><strong>Toplam Oy Sayısı:</strong> <?php echo number_format($total_votes, 0, ',', '.'); ?></li>
                                    <li><strong>Oluşturulma Tarihi:</strong> <?php echo date('d.m.Y H:i', strtotime($survey['created_at'])); ?></li>
                                    <li><strong>Durum:</strong> <?php echo $survey['is_active'] ? 'Aktif' : 'Pasif'; ?></li>
                                </ul>
                            </div>
                        </div>
                        
                        <?php if ($total_votes > 0 || $regional_count > 0): ?>
                            <div class="alert alert-warning">
                                <p><strong>Bu anket ile ilişkili veriler bulundu:</strong></p>
                                <ul>
                                    <?php if ($total_votes > 0): ?>
                                        <li><?php echo number_format($total_votes, 0, ',', '.'); ?> adet oy</li>
                                    <?php endif; ?>
                                    
                                    <?php if ($regional_count > 0): ?>
                                        <li><?php echo number_format($regional_count, 0, ',', '.'); ?> adet bölgesel anket sonucu</li>
                                    <?php endif; ?>
                                </ul>
                                <p class="mb-0"><strong>Bu anketi silerseniz, tüm oy verileri ve bölgesel sonuçlar da silinecektir!</strong></p>
                            </div>
                        <?php endif; ?>
                        
                        <div class="card mb-3">
                            <div class="card-body">
                                <h6>Anket Seçenekleri:</h6>
                                <table class="table table-sm table-borderless mb-0">
                                    <thead>
                                        <tr>
                                            <th>Seçenek</th>
                                            <th>Oy Sayısı</th>
                                            <th>Oran</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <?php foreach ($options as $option): ?>
                                            <tr>
                                                <td><?php echo htmlspecialchars($option['text']); ?></td>
                                                <td><?php echo number_format($option['vote_count'], 0, ',', '.'); ?></td>
                                                <td>
                                                    <?php if ($total_votes > 0): ?>
                                                        <?php $percentage = round(($option['vote_count'] / $total_votes) * 100, 1); ?>
                                                        <div class="progress" style="height: 20px;">
                                                            <div class="progress-bar" role="progressbar" 
                                                                 style="width: <?php echo $percentage; ?>%;" 
                                                                 aria-valuenow="<?php echo $percentage; ?>" 
                                                                 aria-valuemin="0" 
                                                                 aria-valuemax="100">
                                                                <?php echo $percentage; ?>%
                                                            </div>
                                                        </div>
                                                    <?php else: ?>
                                                        <div class="progress" style="height: 20px;">
                                                            <div class="progress-bar" role="progressbar" 
                                                                 style="width: 0%;" 
                                                                 aria-valuenow="0" 
                                                                 aria-valuemin="0" 
                                                                 aria-valuemax="100">
                                                                0%
                                                            </div>
                                                        </div>
                                                    <?php endif; ?>
                                                </td>
                                            </tr>
                                        <?php endforeach; ?>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                        
                        <div class="mt-3 d-flex justify-content-between">
                            <a href="?page=survey_edit&id=<?php echo $survey_id; ?>" class="btn btn-outline-secondary">
                                İptal
                            </a>
                            <a href="?page=survey_delete&id=<?php echo $survey_id; ?>&confirm=yes" class="btn btn-danger">
                                Evet, Anketi Sil
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <?php
    } catch (Exception $e) {
        header("Location: ?page=surveys&error=" . urlencode("Anket bilgisi alınamadı: " . $e->getMessage()));
        exit;
    }
} else {
    // Silme işlemini gerçekleştir
    try {
        // Anket bilgilerini silmeden önce getir
        $query = "SELECT title FROM surveys WHERE id = ?";
        $stmt = $db->prepare($query);
        $stmt->bind_param("i", $survey_id);
        $stmt->execute();
        $result = $stmt->get_result();
        
        if ($result->num_rows > 0) {
            $survey_name = $result->fetch_assoc()['title'];
            
            // İşlem başlat
            $db->begin_transaction();
            
            // İlişkili tabloları temizle
            $delete_options = "DELETE FROM survey_options WHERE survey_id = ?";
            $option_stmt = $db->prepare($delete_options);
            $option_stmt->bind_param("i", $survey_id);
            $option_stmt->execute();
            
            $delete_regional = "DELETE FROM survey_regional_results WHERE survey_id = ?";
            $regional_stmt = $db->prepare($delete_regional);
            $regional_stmt->bind_param("i", $survey_id);
            $regional_stmt->execute();
            
            // Anketi sil
            $delete_query = "DELETE FROM surveys WHERE id = ?";
            $delete_stmt = $db->prepare($delete_query);
            $delete_stmt->bind_param("i", $survey_id);
            $delete_stmt->execute();
            
            if ($delete_stmt->affected_rows > 0) {
                // İşlemi tamamla
                $db->commit();
                header("Location: ?page=surveys&message=" . urlencode("'$survey_name' anketi başarıyla silindi.") . "&deleted_id=" . $survey_id);
                exit;
            } else {
                $db->rollback();
                header("Location: ?page=surveys&error=" . urlencode("Anket silinirken bir hata oluştu."));
                exit;
            }
        } else {
            header("Location: ?page=surveys&error=" . urlencode("Silinecek anket bulunamadı."));
            exit;
        }
    } catch (Exception $e) {
        if ($db->inTransaction()) {
            $db->rollback();
        }
        header("Location: ?page=surveys&error=" . urlencode("Anket silme hatası: " . $e->getMessage()));
        exit;
    }
}
?>