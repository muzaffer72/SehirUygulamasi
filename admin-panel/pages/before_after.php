<?php
// Veritabanı bağlantısını al
require_once 'db_connection.php';

// İşlem türünü kontrol et
$op = isset($_GET['op']) ? $_GET['op'] : '';
$id = isset($_GET['id']) ? (int)$_GET['id'] : 0;
$postId = isset($_GET['post_id']) ? (int)$_GET['post_id'] : 0;

// Sayfalama için değişkenler
$page = isset($_GET['p']) ? (int)$_GET['p'] : 1;
$limit = 10;
$offset = ($page - 1) * $limit;

// Mesaj ve hata değişkenleri
$message = '';
$error = '';

// İşlem: Yeni Öncesi/Sonrası Kaydı Oluştur
if ($op === 'add') {
    try {
        // Önce şikayetin var olup olmadığını kontrol et
        $postQuery = "SELECT id, title, status FROM posts WHERE id = $postId";
        $postResult = pg_query($conn, $postQuery);
        
        if (!$postResult) {
            throw new Exception("PostgreSQL sorgu hatası: " . pg_last_error($conn));
        }
        
        $post = pg_fetch_assoc($postResult);
        
        if (!$post) {
            throw new Exception("Belirtilen şikayet bulunamadı.");
        }
        
        if ($post['status'] !== 'solved') {
            throw new Exception("Sadece çözülen şikayetler için öncesi/sonrası kayıtları eklenebilir.");
        }
        
        // Form gönderildi mi kontrol et
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            // Form verilerini al
            $description = pg_escape_string($conn, $_POST['description'] ?? '');
            $recordedBy = $_SESSION['user_id'] ?? 1; // Varsayılan olarak admin
            
            // Dosya yüklemelerini kontrol et
            $targetDir = "../uploads/before_after/";
            
            // Dizin yoksa oluştur
            if (!file_exists($targetDir)) {
                mkdir($targetDir, 0777, true);
            }
            
            $beforeImageName = '';
            $afterImageName = '';
            
            // Öncesi görseli
            if (isset($_FILES["before_image"]) && $_FILES["before_image"]["error"] == 0) {
                $beforeImageName = uniqid() . "_" . basename($_FILES["before_image"]["name"]);
                $beforeTargetFile = $targetDir . $beforeImageName;
                
                // Dosya türünü kontrol et
                $imageFileType = strtolower(pathinfo($beforeTargetFile, PATHINFO_EXTENSION));
                if ($imageFileType != "jpg" && $imageFileType != "png" && $imageFileType != "jpeg") {
                    throw new Exception("Sadece JPG, JPEG ve PNG dosyaları yüklenebilir.");
                }
                
                // Dosyayı yükle
                if (!move_uploaded_file($_FILES["before_image"]["tmp_name"], $beforeTargetFile)) {
                    throw new Exception("Öncesi görseli yüklenirken bir hata oluştu.");
                }
                
                $beforeImageUrl = "/uploads/before_after/" . $beforeImageName;
            } else {
                throw new Exception("Öncesi görseli gereklidir.");
            }
            
            // Sonrası görseli
            if (isset($_FILES["after_image"]) && $_FILES["after_image"]["error"] == 0) {
                $afterImageName = uniqid() . "_" . basename($_FILES["after_image"]["name"]);
                $afterTargetFile = $targetDir . $afterImageName;
                
                // Dosya türünü kontrol et
                $imageFileType = strtolower(pathinfo($afterTargetFile, PATHINFO_EXTENSION));
                if ($imageFileType != "jpg" && $imageFileType != "png" && $imageFileType != "jpeg") {
                    throw new Exception("Sadece JPG, JPEG ve PNG dosyaları yüklenebilir.");
                }
                
                // Dosyayı yükle
                if (!move_uploaded_file($_FILES["after_image"]["tmp_name"], $afterTargetFile)) {
                    throw new Exception("Sonrası görseli yüklenirken bir hata oluştu.");
                }
                
                $afterImageUrl = "/uploads/before_after/" . $afterImageName;
            } else {
                throw new Exception("Sonrası görseli gereklidir.");
            }
            
            // Veritabanına kaydet
            $insertQuery = "
                INSERT INTO before_after_records 
                (post_id, before_image_url, after_image_url, description, recorded_by, record_date) 
                VALUES 
                ($postId, '$beforeImageUrl', '$afterImageUrl', '$description', $recordedBy, NOW())
            ";
            
            $insertResult = pg_query($conn, $insertQuery);
            
            if (!$insertResult) {
                throw new Exception("Kayıt eklenirken hata: " . pg_last_error($conn));
            }
            
            $message = "Öncesi/Sonrası kaydı başarıyla eklendi!";
            
            // Ana sayfaya yönlendir
            header("Location: ?page=before_after&message=" . urlencode($message));
            exit;
        }
    } catch (Exception $e) {
        $error = $e->getMessage();
    }
}

// İşlem: Kayıt Sil
if ($op === 'delete' && $id > 0) {
    try {
        // Kaydın var olup olmadığını kontrol et
        $checkQuery = "SELECT * FROM before_after_records WHERE id = $id";
        $checkResult = pg_query($conn, $checkQuery);
        
        if (!$checkResult) {
            throw new Exception("PostgreSQL sorgu hatası: " . pg_last_error($conn));
        }
        
        $record = pg_fetch_assoc($checkResult);
        
        if (!$record) {
            throw new Exception("Belirtilen kayıt bulunamadı.");
        }
        
        // Dosyaları sil
        $beforeImagePath = $_SERVER['DOCUMENT_ROOT'] . $record['before_image_url'];
        $afterImagePath = $_SERVER['DOCUMENT_ROOT'] . $record['after_image_url'];
        
        if (file_exists($beforeImagePath)) {
            unlink($beforeImagePath);
        }
        
        if (file_exists($afterImagePath)) {
            unlink($afterImagePath);
        }
        
        // Kaydı veritabanından sil
        $deleteQuery = "DELETE FROM before_after_records WHERE id = $id";
        $deleteResult = pg_query($conn, $deleteQuery);
        
        if (!$deleteResult) {
            throw new Exception("Kayıt silinirken hata: " . pg_last_error($conn));
        }
        
        $message = "Kayıt başarıyla silindi!";
        header("Location: ?page=before_after&message=" . urlencode($message));
        exit;
    } catch (Exception $e) {
        $error = $e->getMessage();
    }
}

// Tüm Öncesi/Sonrası kayıtlarını getir
try {
    $query = "
        SELECT ba.*, 
               p.title as post_title, 
               u.name as recorder_name
        FROM before_after_records ba
        LEFT JOIN posts p ON ba.post_id = p.id
        LEFT JOIN users u ON ba.recorded_by = u.id
        ORDER BY ba.record_date DESC
        LIMIT $limit OFFSET $offset
    ";
    
    $result = pg_query($conn, $query);
    
    if (!$result) {
        throw new Exception("PostgreSQL sorgu hatası: " . pg_last_error($conn));
    }
    
    $records = pg_fetch_all($result) ?: [];
    
    // Toplam kayıt sayısını al
    $countQuery = "SELECT COUNT(*) as total FROM before_after_records";
    $countResult = pg_query($conn, $countQuery);
    
    if (!$countResult) {
        throw new Exception("PostgreSQL sayaç sorgusu hatası: " . pg_last_error($conn));
    }
    
    $countRow = pg_fetch_assoc($countResult);
    $totalRows = $countRow['total'];
    
    $totalPages = ceil($totalRows / $limit);
} catch (Exception $e) {
    $error = "Kayıtlar alınırken bir hata oluştu: " . $e->getMessage();
    $records = [];
    $totalRows = 0;
    $totalPages = 0;
}

// Çözülen şikayetleri al (form için)
try {
    $solvedPostsQuery = "
        SELECT id, title, content, status 
        FROM posts 
        WHERE status = 'solved'
        ORDER BY created_at DESC 
        LIMIT 100
    ";
    
    $solvedPostsResult = pg_query($conn, $solvedPostsQuery);
    
    if (!$solvedPostsResult) {
        throw new Exception("PostgreSQL sorgu hatası: " . pg_last_error($conn));
    }
    
    $solvedPosts = pg_fetch_all($solvedPostsResult) ?: [];
} catch (Exception $e) {
    $error = "Çözülen şikayetler alınırken hata: " . $e->getMessage();
    $solvedPosts = [];
}
?>

<div class="container-fluid mt-4">
    <?php if (!empty($message)): ?>
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <?php echo $message; ?>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    <?php endif; ?>
    
    <?php if (!empty($error)): ?>
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <?php echo $error; ?>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    <?php endif; ?>
    
    <div class="card shadow mb-4">
        <div class="card-header py-3 d-flex justify-content-between align-items-center">
            <h6 class="m-0 font-weight-bold text-primary">Öncesi/Sonrası Görselleri</h6>
            <a href="?page=before_after&op=add" class="btn btn-primary btn-sm">
                <i class="bi bi-plus-circle"></i> Yeni Ekle
            </a>
        </div>
        
        <div class="card-body">
            <?php if ($op === 'add'): ?>
                <!-- Yeni Öncesi/Sonrası Kaydı Form -->
                <div class="card mb-4">
                    <div class="card-header">
                        <h6 class="m-0 font-weight-bold text-primary">Yeni Öncesi/Sonrası Kaydı Ekle</h6>
                    </div>
                    <div class="card-body">
                        <form method="post" enctype="multipart/form-data">
                            <div class="mb-3">
                                <label for="post_id" class="form-label">Çözülen Şikayet</label>
                                <select class="form-select" id="post_id" name="post_id" required>
                                    <option value="">Şikayet seçin</option>
                                    <?php foreach ($solvedPosts as $post): ?>
                                        <option value="<?php echo $post['id']; ?>" <?php echo $postId == $post['id'] ? 'selected' : ''; ?>>
                                            <?php echo htmlspecialchars($post['title']); ?>
                                        </option>
                                    <?php endforeach; ?>
                                </select>
                                <div class="form-text">Bu kayıt hangi çözülmüş şikayetle ilgili?</div>
                            </div>
                            
                            <div class="row mb-3">
                                <div class="col-md-6">
                                    <label for="before_image" class="form-label">Öncesi Görseli</label>
                                    <input type="file" class="form-control" id="before_image" name="before_image" accept="image/*" required>
                                    <div class="form-text">Sorun çözülmeden önceki durumu gösteren görsel</div>
                                </div>
                                <div class="col-md-6">
                                    <label for="after_image" class="form-label">Sonrası Görseli</label>
                                    <input type="file" class="form-control" id="after_image" name="after_image" accept="image/*" required>
                                    <div class="form-text">Sorun çözüldükten sonraki durumu gösteren görsel</div>
                                </div>
                            </div>
                            
                            <div class="mb-3">
                                <label for="description" class="form-label">Açıklama</label>
                                <textarea class="form-control" id="description" name="description" rows="3" placeholder="Yapılan çözüm hakkında bilgi verin"></textarea>
                            </div>
                            
                            <div class="d-flex justify-content-between">
                                <a href="?page=before_after" class="btn btn-secondary">İptal</a>
                                <button type="submit" class="btn btn-primary">Kaydet</button>
                            </div>
                        </form>
                    </div>
                </div>
            <?php else: ?>
                <!-- Kayıtların Listesi -->
                <div class="row mb-3">
                    <div class="col-md-12">
                        <p class="text-muted">Toplam <?php echo $totalRows; ?> kayıt bulundu.</p>
                    </div>
                </div>
                
                <div class="row row-cols-1 row-cols-md-2 row-cols-lg-3 g-4">
                    <?php if (empty($records)): ?>
                        <div class="col-12">
                            <div class="alert alert-info">
                                Henüz hiç öncesi/sonrası kaydı bulunmuyor.
                            </div>
                        </div>
                    <?php else: ?>
                        <?php foreach ($records as $record): ?>
                            <div class="col">
                                <div class="card h-100">
                                    <div class="card-header d-flex justify-content-between align-items-center">
                                        <h6 class="card-title mb-0">
                                            <a href="?page=posts&op=view&id=<?php echo $record['post_id']; ?>">
                                                <?php echo htmlspecialchars(mb_substr($record['post_title'] ?? 'İsimsiz Şikayet', 0, 30) . (mb_strlen($record['post_title'] ?? '') > 30 ? '...' : '')); ?>
                                            </a>
                                        </h6>
                                        <div class="dropdown">
                                            <button class="btn btn-sm btn-outline-secondary dropdown-toggle" type="button" data-bs-toggle="dropdown">
                                                <i class="bi bi-three-dots-vertical"></i>
                                            </button>
                                            <ul class="dropdown-menu">
                                                <li>
                                                    <a class="dropdown-item text-danger" href="?page=before_after&op=delete&id=<?php echo $record['id']; ?>" 
                                                       onclick="return confirm('Bu kaydı silmek istediğinize emin misiniz?')">
                                                        <i class="bi bi-trash"></i> Sil
                                                    </a>
                                                </li>
                                            </ul>
                                        </div>
                                    </div>
                                    <div class="card-body">
                                        <div class="comparison-container">
                                            <div class="row">
                                                <div class="col-6">
                                                    <div class="text-center mb-2">
                                                        <span class="badge bg-secondary">Öncesi</span>
                                                    </div>
                                                    <img src="<?php echo $record['before_image_url']; ?>" class="img-fluid rounded mb-2" alt="Öncesi">
                                                </div>
                                                <div class="col-6">
                                                    <div class="text-center mb-2">
                                                        <span class="badge bg-success">Sonrası</span>
                                                    </div>
                                                    <img src="<?php echo $record['after_image_url']; ?>" class="img-fluid rounded mb-2" alt="Sonrası">
                                                </div>
                                            </div>
                                            <?php if (!empty($record['description'])): ?>
                                                <p class="mt-2"><?php echo htmlspecialchars($record['description']); ?></p>
                                            <?php endif; ?>
                                        </div>
                                    </div>
                                    <div class="card-footer text-muted">
                                        <small>
                                            Kaydeden: <?php echo htmlspecialchars($record['recorder_name'] ?? 'Bilinmiyor'); ?><br>
                                            Tarih: <?php echo date('d.m.Y H:i', strtotime($record['record_date'])); ?>
                                        </small>
                                    </div>
                                </div>
                            </div>
                        <?php endforeach; ?>
                    <?php endif; ?>
                </div>
                
                <!-- Sayfalama -->
                <?php if ($totalPages > 1): ?>
                    <nav class="mt-4">
                        <ul class="pagination justify-content-center">
                            <?php if ($page > 1): ?>
                                <li class="page-item">
                                    <a class="page-link" href="?page=before_after&p=1">
                                        İlk
                                    </a>
                                </li>
                                <li class="page-item">
                                    <a class="page-link" href="?page=before_after&p=<?php echo $page - 1; ?>">
                                        Önceki
                                    </a>
                                </li>
                            <?php endif; ?>

                            <?php
                            $startPage = max(1, $page - 2);
                            $endPage = min($totalPages, $page + 2);
                            
                            for ($i = $startPage; $i <= $endPage; $i++):
                            ?>
                                <li class="page-item <?php echo $i == $page ? 'active' : ''; ?>">
                                    <a class="page-link" href="?page=before_after&p=<?php echo $i; ?>">
                                        <?php echo $i; ?>
                                    </a>
                                </li>
                            <?php endfor; ?>

                            <?php if ($page < $totalPages): ?>
                                <li class="page-item">
                                    <a class="page-link" href="?page=before_after&p=<?php echo $page + 1; ?>">
                                        Sonraki
                                    </a>
                                </li>
                                <li class="page-item">
                                    <a class="page-link" href="?page=before_after&p=<?php echo $totalPages; ?>">
                                        Son
                                    </a>
                                </li>
                            <?php endif; ?>
                        </ul>
                    </nav>
                <?php endif; ?>
            <?php endif; ?>
        </div>
    </div>
</div>

<style>
.comparison-container {
    overflow: hidden;
}
.comparison-container img {
    max-height: 180px;
    object-fit: cover;
    width: 100%;
    border: 1px solid #ddd;
}
</style>