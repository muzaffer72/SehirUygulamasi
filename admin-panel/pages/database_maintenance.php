<?php
// Ana index.php içinde oturum zaten başlatıldığı için burada tekrar başlatmıyoruz
// Oturum kontrolü index.php içinde yapıldığı için burada tekrar yapmamıza gerek yok

// Veritabanı bağlantısı ve gerekli fonksiyonları içe aktar
require_once 'db_connection.php';
require_once 'db_utils.php';

// İşlem durumu mesajları
$successMessage = '';
$errorMessage = '';
$tableStatus = [];
$backupSuccess = false;
$restoreSuccess = false;

// Veritabanı tabloları kontrol et ve durum tablosu oluştur
function checkDatabaseTables($db) {
    $allTables = [
        'settings', 'categories', 'users', 'cities', 'districts', 'posts', 'comments', 
        'media', 'user_likes', 'banned_words', 'notifications', 'surveys', 
        'survey_options', 'survey_regional_results', 'city_services', 'city_projects', 
        'city_events', 'city_stats', 'before_after_records', 'award_types', 
        'city_awards', 'political_parties', 'party_performance', 'search_suggestions', 
        'cities_services', 'system_logs'
    ];
    
    $status = [];
    
    foreach ($allTables as $table) {
        // Tablo var mı kontrol et
        $checkTableSQL = "SELECT EXISTS (
            SELECT FROM information_schema.tables 
            WHERE table_schema = 'public' 
            AND table_name = ?
        )";
        
        $stmt = $db->prepare($checkTableSQL);
        $stmt->bind_param('s', $table);
        $stmt->execute();
        $result = $stmt->get_result();
        $exists = $result->fetch_assoc()['exists'] ?? false;
        
        // Tablo durumunu kaydet
        $status[$table] = [
            'exists' => $exists,
            'name' => $table,
            'status' => $exists ? 'Mevcut' : 'Eksik'
        ];
    }
    
    return $status;
}

// Manuel tablo oluşturma işlemi
if (isset($_POST['create_tables'])) {
    try {
        // Tüm temel tabloları oluştur
        $results = ensureCoreTables($db);
        
        // Oluşturulan tabloları kontrol et
        $createdTables = array_keys(array_filter($results));
        if (count($createdTables) > 0) {
            $successMessage = "Tablolar başarıyla oluşturuldu: " . implode(', ', $createdTables);
            // Sistem log tablosuna kayıt ekle
            if (function_exists('addSystemLog')) {
                addSystemLog($db, 'database', 'Eksik tablolar oluşturuldu: ' . implode(', ', $createdTables), $_SESSION['admin_id'] ?? null);
            }
        } else {
            $successMessage = "Tüm tablolar zaten mevcut. Oluşturulan tablo yok.";
        }
    } catch (Exception $e) {
        $errorMessage = "Tablo oluşturma hatası: " . $e->getMessage();
        error_log("Tablo oluşturma hatası: " . $e->getMessage());
    }
}

// Veritabanı yedekleme işlemi
if (isset($_POST['backup_database'])) {
    try {
        // Yedekleme klasörü kontrolü
        $backupDir = __DIR__ . '/../backups';
        if (!file_exists($backupDir)) {
            mkdir($backupDir, 0755, true);
        }
        
        // Yedekleme dosya adı (timestamp ile)
        $timestamp = date('Y-m-d_H-i-s');
        $backupFileName = "database_backup_$timestamp.sql";
        $backupFilePath = "$backupDir/$backupFileName";
        
        // Veritabanı bilgilerini al
        $host = $db->connectionConfig['host'] ?? 'localhost';
        $port = $db->connectionConfig['port'] ?? '5432';
        $dbname = $db->connectionConfig['dbname'] ?? 'postgres';
        $username = $db->connectionConfig['user'] ?? 'postgres';
        
        // pg_dump komutunu oluştur
        $command = "PGPASSWORD='" . $db->connectionConfig['password'] . "' pg_dump -h $host -p $port -U $username -d $dbname -F p -f \"$backupFilePath\"";
        
        // Komutu çalıştır
        exec($command, $output, $returnCode);
        
        if ($returnCode === 0) {
            // Yedekleme başarılı
            $backupSuccess = true;
            $successMessage = "Veritabanı başarıyla yedeklendi: $backupFileName";
            
            // Sistem log tablosuna kayıt ekle
            if (function_exists('addSystemLog')) {
                addSystemLog($db, 'database', 'Veritabanı yedeği alındı: ' . $backupFileName, $_SESSION['admin_id'] ?? null);
            }
        } else {
            $errorMessage = "Veritabanı yedekleme hatası. Kod: $returnCode";
            error_log("Veritabanı yedekleme hatası: " . implode("\n", $output));
        }
    } catch (Exception $e) {
        $errorMessage = "Yedekleme hatası: " . $e->getMessage();
        error_log("Yedekleme hatası: " . $e->getMessage());
    }
}

// Veritabanı geri yükleme işlemi
if (isset($_POST['restore_database']) && isset($_FILES['backup_file']) && $_FILES['backup_file']['error'] === UPLOAD_ERR_OK) {
    try {
        // Geçici dosya yolunu al
        $tempFilePath = $_FILES['backup_file']['tmp_name'];
        
        // Veritabanı bilgilerini al
        $host = $db->connectionConfig['host'] ?? 'localhost';
        $port = $db->connectionConfig['port'] ?? '5432';
        $dbname = $db->connectionConfig['dbname'] ?? 'postgres';
        $username = $db->connectionConfig['user'] ?? 'postgres';
        
        // psql komutunu oluştur
        $command = "PGPASSWORD='" . $db->connectionConfig['password'] . "' psql -h $host -p $port -U $username -d $dbname -f \"$tempFilePath\"";
        
        // Komutu çalıştır
        exec($command, $output, $returnCode);
        
        if ($returnCode === 0) {
            // Geri yükleme başarılı
            $restoreSuccess = true;
            $successMessage = "Veritabanı başarıyla geri yüklendi.";
            
            // Sistem log tablosuna kayıt ekle
            if (function_exists('addSystemLog')) {
                addSystemLog($db, 'database', 'Veritabanı geri yüklendi', $_SESSION['admin_id'] ?? null);
            }
        } else {
            $errorMessage = "Veritabanı geri yükleme hatası. Kod: $returnCode";
            error_log("Veritabanı geri yükleme hatası: " . implode("\n", $output));
        }
    } catch (Exception $e) {
        $errorMessage = "Geri yükleme hatası: " . $e->getMessage();
        error_log("Geri yükleme hatası: " . $e->getMessage());
    }
}

// Tablo durum bilgilerini al
$tableStatus = checkDatabaseTables($db);

// Mevcut yedekleme dosyalarını listele
$backupDir = __DIR__ . '/../backups';
$backupFiles = [];
if (file_exists($backupDir)) {
    $files = scandir($backupDir);
    foreach ($files as $file) {
        if ($file != '.' && $file != '..' && pathinfo($file, PATHINFO_EXTENSION) == 'sql') {
            $filePath = "$backupDir/$file";
            $fileSize = filesize($filePath);
            $fileDate = date('Y-m-d H:i:s', filemtime($filePath));
            
            $backupFiles[] = [
                'name' => $file,
                'path' => $filePath,
                'size' => round($fileSize / 1024, 2) . ' KB',
                'date' => $fileDate
            ];
        }
    }
    
    // Dosyaları tarihe göre sırala (en yeni başta)
    usort($backupFiles, function($a, $b) {
        return strtotime($b['date']) - strtotime($a['date']);
    });
}

// System Log ekleme fonksiyonu (Eğer zaten tanımlanmamışsa)
if (!function_exists('addSystemLog')) {
    function addSystemLog($db, $logType, $message, $userId = null) {
        try {
            // Önce system_logs tablosunun varlığını kontrol et
            $checkTableSQL = "SELECT EXISTS (
                SELECT FROM information_schema.tables 
                WHERE table_schema = 'public' 
                AND table_name = 'system_logs'
            )";
            
            $stmt = $db->prepare($checkTableSQL);
            $stmt->execute();
            $result = $stmt->get_result();
            $tableExists = $result->fetch_assoc()['exists'] ?? false;
            
            if (!$tableExists) {
                // Tablo yoksa atla
                return false;
            }
            
            // IP adresi ve user agent bilgilerini al
            $ipAddress = $_SERVER['REMOTE_ADDR'] ?? null;
            $userAgent = $_SERVER['HTTP_USER_AGENT'] ?? null;
            
            // Log kaydını ekle
            $insertSQL = "INSERT INTO system_logs (log_type, message, user_id, ip_address, user_agent) 
                         VALUES (?, ?, ?, ?, ?)";
            
            $stmt = $db->prepare($insertSQL);
            $stmt->bind_param('ssiss', $logType, $message, $userId, $ipAddress, $userAgent);
            
            return $stmt->execute();
        } catch (Exception $e) {
            error_log("Log kayıt hatası: " . $e->getMessage());
            return false;
        }
    }
}

?>

<div class="container-fluid">
    <h1 class="h3 mb-4 text-gray-800">Veritabanı Bakımı</h1>
    
    <?php if (!empty($successMessage)): ?>
    <div class="alert alert-success alert-dismissible fade show" role="alert">
        <?php echo $successMessage; ?>
        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
            <span aria-hidden="true">&times;</span>
        </button>
    </div>
    <?php endif; ?>
    
    <?php if (!empty($errorMessage)): ?>
    <div class="alert alert-danger alert-dismissible fade show" role="alert">
        <?php echo $errorMessage; ?>
        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
            <span aria-hidden="true">&times;</span>
        </button>
    </div>
    <?php endif; ?>
    
    <div class="row">
        <!-- Tablo Kontrol Paneli -->
        <div class="col-lg-6">
            <div class="card shadow mb-4">
                <div class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
                    <h6 class="m-0 font-weight-bold text-primary">Veritabanı Tablo Durumu</h6>
                    <div class="dropdown no-arrow">
                        <a class="dropdown-toggle" href="#" role="button" id="dropdownMenuLink"
                            data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                            <i class="fas fa-ellipsis-v fa-sm fa-fw text-gray-400"></i>
                        </a>
                        <div class="dropdown-menu dropdown-menu-right shadow animated--fade-in"
                            aria-labelledby="dropdownMenuLink">
                            <div class="dropdown-header">Tablo İşlemleri:</div>
                            <a class="dropdown-item" href="#" onclick="document.getElementById('create_tables_form').submit()">Eksik Tabloları Oluştur</a>
                            <div class="dropdown-divider"></div>
                            <a class="dropdown-item" href="?page=database_maintenance">Yenile</a>
                        </div>
                    </div>
                </div>
                <div class="card-body">
                    <form action="" method="post" id="create_tables_form">
                        <input type="hidden" name="create_tables" value="1">
                    </form>
                    
                    <div class="table-responsive">
                        <table class="table table-bordered table-striped" id="tableStatus" width="100%" cellspacing="0">
                            <thead>
                                <tr>
                                    <th>Tablo Adı</th>
                                    <th>Durum</th>
                                </tr>
                            </thead>
                            <tbody>
                                <?php foreach ($tableStatus as $table): ?>
                                <tr>
                                    <td><?php echo htmlspecialchars($table['name']); ?></td>
                                    <td>
                                        <?php if ($table['exists']): ?>
                                            <span class="badge badge-success">Mevcut</span>
                                        <?php else: ?>
                                            <span class="badge badge-danger">Eksik</span>
                                        <?php endif; ?>
                                    </td>
                                </tr>
                                <?php endforeach; ?>
                            </tbody>
                        </table>
                    </div>
                    
                    <div class="mt-3">
                        <button type="button" class="btn btn-primary" onclick="document.getElementById('create_tables_form').submit()">
                            <i class="fas fa-tools fa-sm text-white-50 mr-1"></i> Eksik Tabloları Oluştur
                        </button>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Yedekleme ve Geri Yükleme Paneli -->
        <div class="col-lg-6">
            <div class="card shadow mb-4">
                <div class="card-header py-3">
                    <h6 class="m-0 font-weight-bold text-primary">Veritabanı Yedekleme ve Geri Yükleme</h6>
                </div>
                <div class="card-body">
                    <!-- Yedekleme Formu -->
                    <div class="mb-4">
                        <h5>Veritabanı Yedekleme</h5>
                        <p>Mevcut veritabanının tam bir yedeğini alır.</p>
                        
                        <form action="" method="post">
                            <input type="hidden" name="backup_database" value="1">
                            <button type="submit" class="btn btn-success">
                                <i class="fas fa-download fa-sm text-white-50 mr-1"></i> Veritabanını Yedekle
                            </button>
                        </form>
                        
                        <?php if ($backupSuccess): ?>
                        <div class="alert alert-success mt-2" role="alert">
                            Veritabanı başarıyla yedeklendi.
                        </div>
                        <?php endif; ?>
                    </div>
                    
                    <!-- Geri Yükleme Formu -->
                    <div class="mb-4">
                        <h5>Veritabanı Geri Yükleme</h5>
                        <p>Önceden alınmış bir yedeği geri yükler. <strong>DİKKAT:</strong> Bu işlem mevcut verileri değiştirebilir.</p>
                        
                        <form action="" method="post" enctype="multipart/form-data">
                            <div class="custom-file mb-3">
                                <input type="file" class="custom-file-input" id="backup_file" name="backup_file" accept=".sql" required>
                                <label class="custom-file-label" for="backup_file">Yedek dosyası seçin...</label>
                            </div>
                            <input type="hidden" name="restore_database" value="1">
                            <button type="submit" class="btn btn-warning">
                                <i class="fas fa-upload fa-sm text-white-50 mr-1"></i> Veritabanını Geri Yükle
                            </button>
                        </form>
                        
                        <?php if ($restoreSuccess): ?>
                        <div class="alert alert-success mt-2" role="alert">
                            Veritabanı başarıyla geri yüklendi.
                        </div>
                        <?php endif; ?>
                    </div>
                </div>
            </div>
            
            <!-- Mevcut Yedekler Paneli -->
            <div class="card shadow mb-4">
                <div class="card-header py-3">
                    <h6 class="m-0 font-weight-bold text-primary">Mevcut Yedekler</h6>
                </div>
                <div class="card-body">
                    <?php if (empty($backupFiles)): ?>
                        <p>Henüz hiç yedek bulunamadı.</p>
                    <?php else: ?>
                        <div class="table-responsive">
                            <table class="table table-bordered table-striped" id="backupFiles" width="100%" cellspacing="0">
                                <thead>
                                    <tr>
                                        <th>Dosya Adı</th>
                                        <th>Boyut</th>
                                        <th>Tarih</th>
                                        <th>İşlemler</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <?php foreach ($backupFiles as $file): ?>
                                    <tr>
                                        <td><?php echo htmlspecialchars($file['name']); ?></td>
                                        <td><?php echo htmlspecialchars($file['size']); ?></td>
                                        <td><?php echo htmlspecialchars($file['date']); ?></td>
                                        <td>
                                            <a href="download_backup.php?file=<?php echo urlencode($file['name']); ?>" class="btn btn-sm btn-primary">
                                                <i class="fas fa-download"></i> İndir
                                            </a>
                                        </td>
                                    </tr>
                                    <?php endforeach; ?>
                                </tbody>
                            </table>
                        </div>
                    <?php endif; ?>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
// Dosya seçme input'u için custom file label güncellemesi
document.querySelector('.custom-file-input').addEventListener('change', function(e) {
    var fileName = e.target.files[0].name;
    var nextSibling = e.target.nextElementSibling;
    nextSibling.innerText = fileName;
});

// DataTable'ları başlat
$(document).ready(function() {
    $('#tableStatus').DataTable({
        language: {
            url: '//cdn.datatables.net/plug-ins/1.10.24/i18n/Turkish.json'
        },
        order: [[1, 'asc']], // Eksik tablolar önce gösterilsin diye durum sütununa göre sırala
        pageLength: 10
    });
    
    $('#backupFiles').DataTable({
        language: {
            url: '//cdn.datatables.net/plug-ins/1.10.24/i18n/Turkish.json'
        },
        order: [[2, 'desc']], // En son yedekleri önce göster
        pageLength: 5
    });
});
</script>