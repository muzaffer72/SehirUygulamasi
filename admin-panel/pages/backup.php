<?php
// Yetki kontrolü
requireAdmin();

// Yedekleme klasörünü oluştur
$backup_dir = '../export_data';
if (!file_exists($backup_dir)) {
    mkdir($backup_dir, 0755, true);
}

// Projeyi yedekle (kodları)
function backup_code() {
    global $backup_dir;
    $timestamp = date('Y-m-d_H-i-s');
    $backup_file = "$backup_dir/code_backup_$timestamp.zip";
    $project_root = realpath(__DIR__ . '/../../');
    
    // Hariç tutulacak klasörler ve dosyalar
    $exclude_paths = [
        '.git', 
        'node_modules',
        'vendor',
        'export_data',
        '.dart_tool',
        '.pub-cache',
        'build',
        '.pub'
    ];
    
    $exclude_args = '';
    foreach ($exclude_paths as $path) {
        $exclude_args .= " --exclude='$path'";
    }
    
    // Zip komutunu çalıştır
    $command = "cd $project_root && zip -r $backup_file ./ $exclude_args 2>&1";
    exec($command, $output, $return_var);
    
    if ($return_var !== 0) {
        return false;
    }
    
    return $backup_file;
}

// PostgreSQL yedekleme için yardımcı fonksiyonlar
function get_db_tables() {
    global $db;
    $query = "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name";
    $stmt = $db->prepare($query);
    $stmt->execute();
    $result = $stmt->get_result();
    $tables = [];
    while ($row = $result->fetch_assoc()) {
        $tables[] = $row['table_name'];
    }
    return $tables;
}

function export_table_data($table_name, $format = 'sql') {
    global $db, $backup_dir;
    $timestamp = date('Y-m-d_H-i-s');
    
    if ($format === 'sql') {
        $file_path = "$backup_dir/{$table_name}_$timestamp.sql";
        $f = fopen($file_path, 'w');
        
        // Tablo yapısını çıkar
        $query = "SELECT column_name, data_type, character_maximum_length 
                 FROM information_schema.columns 
                 WHERE table_name = ?
                 ORDER BY ordinal_position";
        $stmt = $db->prepare($query);
        $stmt->bind_param("s", $table_name);
        $stmt->execute();
        $result = $stmt->get_result();
        
        // CREATE TABLE ifadesi oluştur
        $create_table = "CREATE TABLE IF NOT EXISTS $table_name (\n";
        $columns = [];
        while ($row = $result->fetch_assoc()) {
            $col_def = "  " . $row['column_name'] . " " . $row['data_type'];
            if (!empty($row['character_maximum_length'])) {
                $col_def .= "(" . $row['character_maximum_length'] . ")";
            }
            $columns[] = $col_def;
        }
        $create_table .= implode(",\n", $columns);
        $create_table .= "\n);\n\n";
        fwrite($f, $create_table);
        
        // Veri çıkarma
        $data_query = "SELECT * FROM $table_name";
        $data_stmt = $db->prepare($data_query);
        $data_stmt->execute();
        $data_result = $data_stmt->get_result();
        
        while ($row = $data_result->fetch_assoc()) {
            $columns = array_keys($row);
            $values = array_map(function($val) use ($db) {
                if ($val === null) {
                    return "NULL";
                } else {
                    return "'" . addslashes($val) . "'";
                }
            }, array_values($row));
            
            $insert = "INSERT INTO $table_name (" . implode(", ", $columns) . ") VALUES (" . implode(", ", $values) . ");\n";
            fwrite($f, $insert);
        }
        
        fclose($f);
        return $file_path;
    } elseif ($format === 'json') {
        $file_path = "$backup_dir/{$table_name}_$timestamp.json";
        $query = "SELECT * FROM $table_name";
        $stmt = $db->prepare($query);
        $stmt->execute();
        $result = $stmt->get_result();
        
        $data = [];
        while ($row = $result->fetch_assoc()) {
            $data[] = $row;
        }
        
        file_put_contents($file_path, json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));
        return $file_path;
    } elseif ($format === 'csv') {
        $file_path = "$backup_dir/{$table_name}_$timestamp.csv";
        $f = fopen($file_path, 'w');
        
        // Sütun başlıklarını al
        $query = "SELECT column_name FROM information_schema.columns 
                 WHERE table_name = ? 
                 ORDER BY ordinal_position";
        $stmt = $db->prepare($query);
        $stmt->bind_param("s", $table_name);
        $stmt->execute();
        $result = $stmt->get_result();
        
        $headers = [];
        while ($row = $result->fetch_assoc()) {
            $headers[] = $row['column_name'];
        }
        
        // CSV başlık satırını yaz
        fputcsv($f, $headers);
        
        // Verileri al ve yaz
        $data_query = "SELECT * FROM $table_name";
        $data_stmt = $db->prepare($data_query);
        $data_stmt->execute();
        $data_result = $data_stmt->get_result();
        
        while ($row = $data_result->fetch_assoc()) {
            fputcsv($f, $row);
        }
        
        fclose($f);
        return $file_path;
    }
    
    return false;
}

function export_all_tables($format = 'sql') {
    $tables = get_db_tables();
    $exported_files = [];
    
    foreach ($tables as $table) {
        $file_path = export_table_data($table, $format);
        if ($file_path) {
            $exported_files[] = $file_path;
        }
    }
    
    return $exported_files;
}

function create_full_backup() {
    global $backup_dir;
    $timestamp = date('Y-m-d_H-i-s');
    $backup_file = "$backup_dir/full_backup_$timestamp.zip";
    
    // Tüm tabloları SQL, JSON ve CSV formatında dışa aktar
    $sql_files = export_all_tables('sql');
    $json_files = export_all_tables('json');
    $csv_files = export_all_tables('csv');
    
    // Tüm dosyaları ZIP arşivine ekle
    $zip = new ZipArchive();
    if ($zip->open($backup_file, ZipArchive::CREATE) === TRUE) {
        // SQL dosyalarını ekle
        foreach ($sql_files as $file) {
            $zip->addFile($file, basename($file));
        }
        
        // JSON dosyalarını ekle
        foreach ($json_files as $file) {
            $zip->addFile($file, basename($file));
        }
        
        // CSV dosyalarını ekle
        foreach ($csv_files as $file) {
            $zip->addFile($file, basename($file));
        }
        
        // Yükleme ve çıkarma işlemi tamamlandıktan sonra ZIP'i kapat
        $zip->close();
        
        // Geçici dosyaları temizle
        foreach (array_merge($sql_files, $json_files, $csv_files) as $file) {
            unlink($file);
        }
        
        return $backup_file;
    }
    
    return false;
}

function get_existing_backups() {
    global $backup_dir;
    $backups = [];
    
    if (file_exists($backup_dir)) {
        $files = scandir($backup_dir);
        foreach ($files as $file) {
            if (in_array($file, ['.', '..'])) continue;
            
            $file_path = "$backup_dir/$file";
            $backups[] = [
                'name' => $file,
                'path' => $file_path,
                'size' => filesize($file_path),
                'date' => date("Y-m-d H:i:s", filemtime($file_path))
            ];
        }
    }
    
    // Tarihe göre sırala (en yeniler üstte)
    usort($backups, function($a, $b) {
        return strtotime($b['date']) - strtotime($a['date']);
    });
    
    return $backups;
}

function format_file_size($size) {
    $units = ['B', 'KB', 'MB', 'GB', 'TB'];
    
    for ($i = 0; $size > 1024; $i++) {
        $size /= 1024;
    }
    
    return round($size, 2) . ' ' . $units[$i];
}

// İşlem yönetimi
$message = '';
$message_type = 'success';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_POST['create_backup'])) {
        $format = $_POST['format'] ?? 'sql';
        
        if ($format === 'full') {
            $backup_file = create_full_backup();
            if ($backup_file) {
                $message = "Tam yedekleme başarıyla tamamlandı: " . basename($backup_file);
            } else {
                $message = "Yedekleme oluşturulurken bir hata oluştu.";
                $message_type = 'danger';
            }
        } else {
            $table = $_POST['table'] ?? '';
            
            if ($table === 'all') {
                $files = export_all_tables($format);
                if (count($files) > 0) {
                    $message = count($files) . " tablo başarıyla yedeklendi.";
                } else {
                    $message = "Tablolar yedeklenirken bir hata oluştu.";
                    $message_type = 'danger';
                }
            } else {
                $file = export_table_data($table, $format);
                if ($file) {
                    $message = "Tablo başarıyla yedeklendi: " . basename($file);
                } else {
                    $message = "Tablo yedeklenirken bir hata oluştu.";
                    $message_type = 'danger';
                }
            }
        }
    } elseif (isset($_POST['delete_backup'])) {
        $backup_file = $_POST['backup_file'] ?? '';
        
        if (!empty($backup_file) && file_exists($backup_file) && is_file($backup_file)) {
            if (unlink($backup_file)) {
                $message = "Yedek dosyası başarıyla silindi: " . basename($backup_file);
            } else {
                $message = "Yedek dosyası silinirken bir hata oluştu.";
                $message_type = 'danger';
            }
        } else {
            $message = "Geçersiz yedek dosyası.";
            $message_type = 'danger';
        }
    }
}

// Tablo ve yedek listelerini al
$tables = get_db_tables();
$backups = get_existing_backups();
?>

<div class="container-fluid">
    <h2 class="mb-4">
        <i class="bi bi-database-fill-check"></i> Veritabanı Yedekleme
    </h2>
    
    <?php if (!empty($message)): ?>
        <div class="alert alert-<?= $message_type ?> alert-dismissible fade show" role="alert">
            <?= $message ?>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    <?php endif; ?>
    
    <div class="row">
        <div class="col-md-6">
            <div class="card mb-4">
                <div class="card-header">
                    <h5 class="card-title mb-0">Yeni Yedekleme Oluştur</h5>
                </div>
                <div class="card-body">
                    <form method="post">
                        <div class="mb-3">
                            <label for="table" class="form-label">Tablo Seçimi</label>
                            <select class="form-select" id="table" name="table">
                                <option value="all">Tüm Tablolar</option>
                                <?php foreach ($tables as $table): ?>
                                    <option value="<?= $table ?>"><?= $table ?></option>
                                <?php endforeach; ?>
                            </select>
                        </div>
                        
                        <div class="mb-3">
                            <label for="format" class="form-label">Yedekleme Formatı</label>
                            <select class="form-select" id="format" name="format">
                                <option value="sql">SQL</option>
                                <option value="json">JSON</option>
                                <option value="csv">CSV</option>
                                <option value="full">Tam Yedekleme (SQL+JSON+CSV)</option>
                            </select>
                        </div>
                        
                        <button type="submit" name="create_backup" class="btn btn-primary">
                            <i class="bi bi-download"></i> Yedeklemeyi Başlat
                        </button>
                    </form>
                </div>
            </div>
            
            <div class="card">
                <div class="card-header">
                    <h5 class="card-title mb-0">Veritabanı İstatistikleri</h5>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-sm">
                            <thead>
                                <tr>
                                    <th>Tablo Adı</th>
                                    <th>Kayıt Sayısı</th>
                                </tr>
                            </thead>
                            <tbody>
                                <?php foreach ($tables as $table): ?>
                                    <?php
                                    $count_query = "SELECT COUNT(*) as count FROM $table";
                                    $count_stmt = $db->prepare($count_query);
                                    $count_stmt->execute();
                                    $count_result = $count_stmt->get_result();
                                    $count = $count_result->fetch_assoc()['count'];
                                    ?>
                                    <tr>
                                        <td><?= $table ?></td>
                                        <td><?= $count ?></td>
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
                    <h5 class="card-title mb-0">Mevcut Yedeklemeler</h5>
                </div>
                <div class="card-body">
                    <?php if (count($backups) > 0): ?>
                        <div class="table-responsive">
                            <table class="table table-hover">
                                <thead>
                                    <tr>
                                        <th>Dosya Adı</th>
                                        <th>Boyut</th>
                                        <th>Tarih</th>
                                        <th>İşlemler</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <?php foreach ($backups as $backup): ?>
                                        <tr>
                                            <td><?= $backup['name'] ?></td>
                                            <td><?= format_file_size($backup['size']) ?></td>
                                            <td><?= $backup['date'] ?></td>
                                            <td>
                                                <div class="btn-group">
                                                    <a href="<?= $backup['path'] ?>" class="btn btn-sm btn-outline-primary" download>
                                                        <i class="bi bi-download"></i>
                                                    </a>
                                                    <form method="post" class="d-inline" onsubmit="return confirm('Bu yedek dosyasını silmek istediğinizden emin misiniz?');">
                                                        <input type="hidden" name="backup_file" value="<?= $backup['path'] ?>">
                                                        <button type="submit" name="delete_backup" class="btn btn-sm btn-outline-danger">
                                                            <i class="bi bi-trash"></i>
                                                        </button>
                                                    </form>
                                                </div>
                                            </td>
                                        </tr>
                                    <?php endforeach; ?>
                                </tbody>
                            </table>
                        </div>
                    <?php else: ?>
                        <div class="alert alert-info">
                            Henüz yedekleme yapılmamış.
                        </div>
                    <?php endif; ?>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    // Format seçimine göre tablo seçimini etkinleştir/devre dışı bırak
    const formatSelect = document.getElementById('format');
    const tableSelect = document.getElementById('table');
    
    formatSelect.addEventListener('change', function() {
        if (this.value === 'full') {
            tableSelect.value = 'all';
            tableSelect.disabled = true;
        } else {
            tableSelect.disabled = false;
        }
    });
});
</script>