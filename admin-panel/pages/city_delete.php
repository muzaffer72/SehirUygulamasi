<?php
// Şehir Silme İşlemi Sayfası
// Bu sayfa city_edit.php sayfasından yönlendirilerek şehir silme işlemini yönetir

// Yetki kontrolü
requireAdmin();

// ID kontrolü
if (!isset($_GET['id']) || empty($_GET['id'])) {
    header("Location: ?page=cities&error=" . urlencode("Şehir ID bulunamadı."));
    exit;
}

$city_id = intval($_GET['id']);

// Onay kontrolü
if (!isset($_GET['confirm']) || $_GET['confirm'] !== 'yes') {
    // Şehir bilgilerini getir
    try {
        $query = "SELECT name FROM cities WHERE id = ?";
        $stmt = $db->prepare($query);
        $stmt->bind_param("i", $city_id);
        $stmt->execute();
        $result = $stmt->get_result();
        
        if ($result->num_rows === 0) {
            header("Location: ?page=cities&error=" . urlencode("Silinecek şehir bulunamadı."));
            exit;
        }
        
        $city = $result->fetch_assoc();
        $city_name = $city['name'];
        
        // İlişkili ilçe sayısını kontrol et
        $district_query = "SELECT COUNT(*) as count FROM districts WHERE city_id = ?";
        $district_stmt = $db->prepare($district_query);
        $district_stmt->bind_param("i", $city_id);
        $district_stmt->execute();
        $district_result = $district_stmt->get_result();
        $district_count = $district_result->fetch_assoc()['count'];
        
        // İlişkili anket sayısını kontrol et
        $survey_query = "SELECT COUNT(*) as count FROM surveys WHERE city_id = ?";
        $survey_stmt = $db->prepare($survey_query);
        $survey_stmt->bind_param("i", $city_id);
        $survey_stmt->execute();
        $survey_result = $survey_stmt->get_result();
        $survey_count = $survey_result->fetch_assoc()['count'];
        
        // İlişkili post (şikayet) sayısını kontrol et
        $post_query = "SELECT COUNT(*) as count FROM posts WHERE city_id = ?";
        $post_stmt = $db->prepare($post_query);
        $post_stmt->bind_param("i", $city_id);
        $post_stmt->execute();
        $post_result = $post_stmt->get_result();
        $post_count = $post_result->fetch_assoc()['count'];
        
        // Toplam ilişkili veri sayısı
        $related_data_count = $district_count + $survey_count + $post_count;
        
        ?>
        <div class="container mt-4">
            <div class="card shadow-sm">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <h5 class="mb-0 text-danger">Şehir Silme Onayı</h5>
                    <a href="?page=city_edit&id=<?php echo $city_id; ?>" class="btn btn-sm btn-outline-secondary">
                        <i class="bi bi-arrow-left"></i> Geri Dön
                    </a>
                </div>
                <div class="card-body">
                    <div class="alert alert-danger">
                        <h5><i class="bi bi-exclamation-triangle-fill"></i> Uyarı</h5>
                        <p>"<strong><?php echo htmlspecialchars($city_name); ?></strong>" şehrini silmek istediğinizden emin misiniz?</p>
                        
                        <?php if ($related_data_count > 0): ?>
                            <div class="alert alert-warning">
                                <p><strong>Bu şehir ile ilişkili veriler bulundu:</strong></p>
                                <ul>
                                    <?php if ($district_count > 0): ?>
                                        <li><?php echo $district_count; ?> adet ilçe</li>
                                    <?php endif; ?>
                                    
                                    <?php if ($survey_count > 0): ?>
                                        <li><?php echo $survey_count; ?> adet anket</li>
                                    <?php endif; ?>
                                    
                                    <?php if ($post_count > 0): ?>
                                        <li><?php echo $post_count; ?> adet şikayet/öneri</li>
                                    <?php endif; ?>
                                </ul>
                                <p class="mb-0"><strong>Bu şehri silerseniz, ilişkili tüm veriler de silinecektir!</strong></p>
                            </div>
                        <?php endif; ?>
                        
                        <div class="mt-3 d-flex justify-content-between">
                            <a href="?page=city_edit&id=<?php echo $city_id; ?>" class="btn btn-outline-secondary">
                                İptal
                            </a>
                            <a href="?page=city_delete&id=<?php echo $city_id; ?>&confirm=yes" class="btn btn-danger">
                                Evet, Şehri Sil
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <?php
    } catch (Exception $e) {
        header("Location: ?page=cities&error=" . urlencode("Şehir bilgisi alınamadı: " . $e->getMessage()));
        exit;
    }
} else {
    // Silme işlemini gerçekleştir
    try {
        // Silme işlemi öncesi şehir adını al
        $name_query = "SELECT name FROM cities WHERE id = ?";
        $name_stmt = $db->prepare($name_query);
        $name_stmt->bind_param("i", $city_id);
        $name_stmt->execute();
        $name_result = $name_stmt->get_result();
        
        if ($name_result->num_rows > 0) {
            $city_name = $name_result->fetch_assoc()['name'];
            
            // İlişkili alt tabloları temizle - bu bloğu veritabanı yapısına göre düzenleyin
            $relations = [
                "districts" => "DELETE FROM districts WHERE city_id = ?",
                "city_services" => "DELETE FROM city_services WHERE city_id = ?",
                "city_projects" => "DELETE FROM city_projects WHERE city_id = ?",
                "city_events" => "DELETE FROM city_events WHERE city_id = ?",
                "city_stats" => "DELETE FROM city_stats WHERE city_id = ?",
                "city_awards" => "DELETE FROM city_awards WHERE city_id = ?",
                "city_party_relations" => "DELETE FROM city_party_relations WHERE city_id = ?"
            ];
            
            // İlişkili verileri sil
            foreach ($relations as $table => $query) {
                $rel_stmt = $db->prepare($query);
                $rel_stmt->bind_param("i", $city_id);
                $rel_stmt->execute();
            }
            
            // Şehri sil
            $delete_query = "DELETE FROM cities WHERE id = ?";
            $delete_stmt = $db->prepare($delete_query);
            $delete_stmt->bind_param("i", $city_id);
            $delete_stmt->execute();
            
            if ($delete_stmt->affected_rows > 0) {
                header("Location: ?page=cities&message=" . urlencode("'$city_name' şehri başarıyla silindi.") . "&deleted_id=" . $city_id);
                exit;
            } else {
                header("Location: ?page=cities&error=" . urlencode("Şehir silinirken bir hata oluştu."));
                exit;
            }
        } else {
            header("Location: ?page=cities&error=" . urlencode("Silinecek şehir bulunamadı."));
            exit;
        }
    } catch (Exception $e) {
        header("Location: ?page=cities&error=" . urlencode("Şehir silme hatası: " . $e->getMessage()));
        exit;
    }
}
?>