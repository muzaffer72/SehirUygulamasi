<?php
// Sayfa başlığını ayarla
$page_title = 'Ödül Sistemi Yönetimi';

// Veritabanı bağlantısını içe aktar
require_once 'db_connection.php';

// Kullanıcı isteklerini işle
if (isset($_POST['update_award_settings'])) {
    // İleri bir sürümde, otomatik ödül atama eşikleri gibi ayarları buradan güncelleyebiliriz
    $successMessage = "Ödül sistemi ayarları güncellendi.";
}

if (isset($_GET['run_auto_awards']) && $_GET['run_auto_awards'] == '1') {
    // Manuel olarak otomatik ödül kontrolünü çalıştır
    $output = [];
    exec('php ' . __DIR__ . '/../auto_award_checker.php 2>&1', $output);
    $checkResults = implode('<br>', $output);
}

if (isset($_POST['create_default_awards'])) {
    // Varsayılan ödül türlerini oluştur
    $output = [];
    exec('php ' . __DIR__ . '/../create_default_award_types.php 2>&1', $output);
    $setupResults = implode('<br>', $output);
}

// Ödül türlerini al
$awardTypes = [];
try {
    // Önce is_system sütununu kontrol et ve yoksa ekle
    $alterSql = "
        DO $$
        BEGIN
            IF NOT EXISTS (
                SELECT 1 FROM information_schema.columns 
                WHERE table_name='award_types' AND column_name='is_system'
            ) THEN
                ALTER TABLE award_types ADD COLUMN is_system BOOLEAN NOT NULL DEFAULT FALSE;
            END IF;
        END
        $$;
    ";
    $db->query($alterSql);
    
    $query = "SELECT * FROM award_types ORDER BY is_system DESC, name ASC";
    $result = $db->query($query);
    
    if ($result) {
        while ($row = $result->fetch_assoc()) {
            $awardTypes[] = $row;
        }
    }
} catch (Exception $e) {
    $errorMessage = "Ödül türleri alınırken hata: " . $e->getMessage();
}

// Sorun çözme oranına göre şehirleri getir
$cities = [];
try {
    $query = "
        SELECT c.id, c.name, 
               COALESCE(c.problem_solving_rate, 0) as problem_solving_rate,
               COUNT(ca.id) as award_count
        FROM cities c
        LEFT JOIN city_awards ca ON c.id = ca.city_id
        GROUP BY c.id, c.name, c.problem_solving_rate
        ORDER BY c.problem_solving_rate DESC NULLS LAST, c.name ASC
        LIMIT 20
    ";
    $result = $db->query($query);
    
    if ($result) {
        while ($row = $result->fetch_assoc()) {
            $cities[] = $row;
        }
    }
} catch (Exception $e) {
    $errorMessage = "Şehirler alınırken hata: " . $e->getMessage();
}

// Otomatik verilen ödüllerin sayısını al
$systemAwardCount = 0;
try {
    $query = "
        SELECT COUNT(*) as count 
        FROM city_awards ca
        JOIN award_types at ON ca.award_type_id = at.id
        WHERE at.is_system = TRUE
    ";
    $result = $db->query($query);
    
    if ($result && $row = $result->fetch_assoc()) {
        $systemAwardCount = $row['count'];
    }
} catch (Exception $e) {
    $errorMessage = "Ödül sayısı alınırken hata: " . $e->getMessage();
}

// Manuel verilen ödüllerin sayısını al
$manualAwardCount = 0;
try {
    $query = "
        SELECT COUNT(*) as count 
        FROM city_awards ca
        JOIN award_types at ON ca.award_type_id = at.id
        WHERE at.is_system = FALSE
    ";
    $result = $db->query($query);
    
    if ($result && $row = $result->fetch_assoc()) {
        $manualAwardCount = $row['count'];
    }
} catch (Exception $e) {
    $errorMessage = "Ödül sayısı alınırken hata: " . $e->getMessage();
}
?>

<div class="container-fluid mt-4">
    <?php if (isset($successMessage)): ?>
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <?php echo $successMessage; ?>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    <?php endif; ?>
    
    <?php if (isset($errorMessage)): ?>
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <?php echo $errorMessage; ?>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    <?php endif; ?>
    
    <?php if (isset($setupResults)): ?>
        <div class="alert alert-info alert-dismissible fade show" role="alert">
            <h5>Kurulum Sonuçları:</h5>
            <div><?php echo $setupResults; ?></div>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    <?php endif; ?>
    
    <?php if (isset($checkResults)): ?>
        <div class="alert alert-info alert-dismissible fade show" role="alert">
            <h5>Otomatik Ödül Kontrol Sonuçları:</h5>
            <div><?php echo $checkResults; ?></div>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    <?php endif; ?>

    <div class="row">
        <div class="col-md-12">
            <div class="card shadow mb-4">
                <div class="card-header py-3 d-flex justify-content-between align-items-center">
                    <h6 class="m-0 font-weight-bold text-primary">Ödül Sistemi Yönetimi</h6>
                </div>
                <div class="card-body">
                    <div class="row mb-4">
                        <div class="col-md-3">
                            <div class="card bg-primary text-white">
                                <div class="card-body">
                                    <h5 class="card-title">Toplam Ödüller</h5>
                                    <p class="display-4"><?php echo $systemAwardCount + $manualAwardCount; ?></p>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="card bg-success text-white">
                                <div class="card-body">
                                    <h5 class="card-title">Otomatik Ödüller</h5>
                                    <p class="display-4"><?php echo $systemAwardCount; ?></p>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="card bg-info text-white">
                                <div class="card-body">
                                    <h5 class="card-title">Manuel Ödüller</h5>
                                    <p class="display-4"><?php echo $manualAwardCount; ?></p>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="card bg-warning text-dark">
                                <div class="card-body">
                                    <h5 class="card-title">Ödül Türleri</h5>
                                    <p class="display-4"><?php echo count($awardTypes); ?></p>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="row mb-4">
                        <div class="col-md-12">
                            <div class="card">
                                <div class="card-header">
                                    <h5 class="mb-0">Sistem Ayarları</h5>
                                </div>
                                <div class="card-body">
                                    <div class="row">
                                        <div class="col-md-6">
                                            <form method="post" action="?page=award_system">
                                                <div class="mb-3">
                                                    <div class="d-grid">
                                                        <button type="submit" name="create_default_awards" class="btn btn-warning">
                                                            <i class="bi bi-gear"></i> Varsayılan Ödül Türlerini Oluştur/Güncelle
                                                        </button>
                                                    </div>
                                                    <small class="form-text text-muted">
                                                        Bu düğme, Bronz, Gümüş ve Altın ödül türlerini oluşturur veya günceller ve gerekli veritabanı yapısını oluşturur.
                                                    </small>
                                                </div>
                                            </form>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="mb-3">
                                                <div class="d-grid mb-2">
                                                    <a href="?page=award_system&run_auto_awards=1" class="btn btn-success">
                                                        <i class="bi bi-lightning"></i> Otomatik Ödül Kontrolünü Çalıştır
                                                    </a>
                                                </div>
                                                <div class="d-grid">
                                                    <a href="cron_setup.php" class="btn btn-info">
                                                        <i class="bi bi-clock-history"></i> Günlük Otomatik Kontrol Ayarla
                                                    </a>
                                                </div>
                                                <small class="form-text text-muted mt-2">
                                                    Otomatik ödül kontrolü, tüm şehir ve ilçe belediyelerinin sorun çözme oranlarını hesaplar ve kriterlere uyan belediyelere otomatik ödül verir. Ödüller 1 ay boyunca geçerlidir.
                                                </small>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="row">
                        <div class="col-md-6">
                            <div class="card">
                                <div class="card-header">
                                    <h5 class="mb-0">Ödül Türleri</h5>
                                </div>
                                <div class="card-body">
                                    <div class="table-responsive">
                                        <table class="table table-bordered">
                                            <thead>
                                                <tr>
                                                    <th>ID</th>
                                                    <th>Ödül Adı</th>
                                                    <th>Renk</th>
                                                    <th>Tip</th>
                                                    <th>İşlemler</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <?php foreach ($awardTypes as $type): ?>
                                                <tr>
                                                    <td><?php echo $type['id']; ?></td>
                                                    <td>
                                                        <span class="d-flex align-items-center">
                                                            <i class="bi <?php echo $type['icon']; ?> me-2" style="color: <?php echo $type['color']; ?>"></i>
                                                            <?php echo $type['name']; ?>
                                                        </span>
                                                    </td>
                                                    <td>
                                                        <span class="badge" style="background-color: <?php echo $type['color']; ?>">
                                                            <?php echo $type['color']; ?>
                                                        </span>
                                                    </td>
                                                    <td>
                                                        <?php if ($type['is_system']): ?>
                                                            <span class="badge bg-success">Otomatik</span>
                                                        <?php else: ?>
                                                            <span class="badge bg-primary">Manuel</span>
                                                        <?php endif; ?>
                                                    </td>
                                                    <td>
                                                        <a href="?page=award_types&op=edit&id=<?php echo $type['id']; ?>" class="btn btn-sm btn-primary">
                                                            <i class="bi bi-pencil"></i>
                                                        </a>
                                                    </td>
                                                </tr>
                                                <?php endforeach; ?>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <div class="col-md-6">
                            <div class="card">
                                <div class="card-header">
                                    <h5 class="mb-0">En Yüksek Sorun Çözme Oranına Sahip Şehirler</h5>
                                </div>
                                <div class="card-body">
                                    <div class="table-responsive">
                                        <table class="table table-bordered">
                                            <thead>
                                                <tr>
                                                    <th>Şehir</th>
                                                    <th>Çözüm Oranı</th>
                                                    <th>Ödül Sayısı</th>
                                                    <th>İşlemler</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <?php foreach ($cities as $city): ?>
                                                <tr>
                                                    <td><?php echo $city['name']; ?></td>
                                                    <td>
                                                        <?php 
                                                        $rate = $city['problem_solving_rate'] ?? 0;
                                                        $badgeClass = 'bg-secondary';
                                                        
                                                        if ($rate >= 75) {
                                                            $badgeClass = 'bg-success';
                                                        } elseif ($rate >= 50) {
                                                            $badgeClass = 'bg-info';
                                                        } elseif ($rate >= 25) {
                                                            $badgeClass = 'bg-warning text-dark';
                                                        }
                                                        ?>
                                                        <span class="badge <?php echo $badgeClass; ?>">
                                                            %<?php echo number_format($rate, 2); ?>
                                                        </span>
                                                    </td>
                                                    <td>
                                                        <span class="badge bg-primary">
                                                            <?php echo $city['award_count']; ?>
                                                        </span>
                                                    </td>
                                                    <td>
                                                        <a href="?page=city_profile&city_id=<?php echo $city['id']; ?>&tab=awards" class="btn btn-sm btn-info">
                                                            <i class="bi bi-eye"></i> Görüntüle
                                                        </a>
                                                    </td>
                                                </tr>
                                                <?php endforeach; ?>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    $(document).ready(function() {
        // İleri bir sürümde JavaScript işlemleri burada yer alabilir
    });
</script>