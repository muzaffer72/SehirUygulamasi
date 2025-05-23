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

// Tabloların mantıksal sırasını belirle (önce ana tablolar, sonra bağımlı tablolar)
function get_tables_in_order() {
    global $db;
    
    // Tüm tabloları al
    $tables = get_db_tables();
    
    // Foreign key bağımlılıklarını al
    $query = "
        SELECT
            tc.table_name AS table_name,
            ccu.table_name AS referenced_table
        FROM information_schema.table_constraints AS tc
        JOIN information_schema.constraint_column_usage AS ccu
            ON ccu.constraint_name = tc.constraint_name
        WHERE tc.constraint_type = 'FOREIGN KEY'
    ";
    
    $stmt = $db->prepare($query);
    $stmt->execute();
    $result = $stmt->get_result();
    
    // Bağımlılık tablosunu oluştur
    $dependencies = [];
    while ($row = $result->fetch_assoc()) {
        $table = $row['table_name'];
        $referenced = $row['referenced_table'];
        
        if (!isset($dependencies[$table])) {
            $dependencies[$table] = [];
        }
        
        // Bu tablo hangi tabloya bağımlı?
        $dependencies[$table][] = $referenced;
    }
    
    // Ana tablolar (bağımlılığı olmayan) ve bağımlı tablolar
    $independent_tables = [];
    $dependent_tables = [];
    
    foreach ($tables as $table) {
        if (isset($dependencies[$table])) {
            $dependent_tables[] = $table;
        } else {
            $independent_tables[] = $table;
        }
    }
    
    // Bağımlılık düzeyine göre bağımlı tabloları sırala
    $ordered_tables = $independent_tables;
    
    // Tüm bağımlı tablolar eklenene kadar devam et
    while (count($dependent_tables) > 0) {
        $tables_added_this_round = [];
        
        foreach ($dependent_tables as $index => $table) {
            $can_add = true;
            
            // Bu tablonun bağımlı olduğu tüm tablolar eklenmiş mi?
            foreach ($dependencies[$table] as $dep) {
                if (!in_array($dep, $ordered_tables)) {
                    $can_add = false;
                    break;
                }
            }
            
            // Evet, eklenebilir
            if ($can_add) {
                $ordered_tables[] = $table;
                $tables_added_this_round[] = $table;
                unset($dependent_tables[$index]);
            }
        }
        
        // Eğer bu turda hiç tablo eklenemezse, döngüsel bağımlılık var demektir
        // Bu durumda kalan tabloları mevcut sırayla ekle
        if (empty($tables_added_this_round)) {
            $ordered_tables = array_merge($ordered_tables, $dependent_tables);
            break;
        }
        
        // Dizindeksi resetle
        $dependent_tables = array_values($dependent_tables);
    }
    
    return $ordered_tables;
}

function export_table_data($table_name, $format = 'sql', $with_drop = false, $compress = false) {
    global $db, $backup_dir;
    $timestamp = date('Y-m-d_H-i-s');
    
    if ($format === 'sql') {
        $file_path = "$backup_dir/{$table_name}_$timestamp.sql";
        $f = fopen($file_path, 'w');
        
        // Başlangıç yorumu ve transaction başlat
        $header = "-- ŞikayetVar Veritabanı Yedeği\n";
        $header .= "-- Tablo: $table_name\n";
        $header .= "-- Tarih: " . date('Y-m-d H:i:s') . "\n\n";
        $header .= "START TRANSACTION;\n\n";
        fwrite($f, $header);
        
        // DROP TABLE komutunu ekle (isteğe bağlı)
        if ($with_drop) {
            $drop_statement = "DROP TABLE IF EXISTS $table_name;\n\n";
            fwrite($f, $drop_statement);
        }
        
        // Tablo yapısını çıkar
        $query = "SELECT column_name, data_type, character_maximum_length, column_default, is_nullable 
                 FROM information_schema.columns 
                 WHERE table_name = ?
                 ORDER BY ordinal_position";
        $stmt = $db->prepare($query);
        $stmt->bind_param("s", $table_name);
        $stmt->execute();
        $result = $stmt->get_result();
        
        // Birincil anahtar bilgisini al
        $pk_query = "SELECT a.attname as column_name
                    FROM pg_index i
                    JOIN pg_attribute a ON a.attrelid = i.indrelid AND a.attnum = ANY(i.indkey)
                    WHERE i.indrelid = ?::regclass AND i.indisprimary";
        $pk_stmt = $db->prepare($pk_query);
        $pk_stmt->bind_param("s", $table_name);
        $pk_stmt->execute();
        $pk_result = $pk_stmt->get_result();
        $primary_keys = [];
        while ($pk_row = $pk_result->fetch_assoc()) {
            $primary_keys[] = $pk_row['column_name'];
        }
        
        // CREATE TABLE ifadesi oluştur
        $create_table = "CREATE TABLE IF NOT EXISTS $table_name (\n";
        $columns = [];
        $column_defs = [];
        
        while ($row = $result->fetch_assoc()) {
            $column_defs[$row['column_name']] = $row;
            $col_def = "  \"" . $row['column_name'] . "\" " . $row['data_type'];
            
            if (!empty($row['character_maximum_length'])) {
                $col_def .= "(" . $row['character_maximum_length'] . ")";
            }
            
            // NULL/NOT NULL durumu
            $col_def .= ($row['is_nullable'] === 'YES') ? ' NULL' : ' NOT NULL';
            
            // Varsayılan değer
            if ($row['column_default'] !== null) {
                $col_def .= " DEFAULT " . $row['column_default'];
            }
            
            $columns[] = $col_def;
        }
        
        $create_table .= implode(",\n", $columns);
        
        // Birincil anahtar kısıtlaması ekle
        if (!empty($primary_keys)) {
            $create_table .= ",\n  PRIMARY KEY (\"" . implode('", "', $primary_keys) . "\")";
        }
        
        $create_table .= "\n);\n\n";
        fwrite($f, $create_table);
        
        // Veri çıkarma
        $data_query = "SELECT * FROM $table_name";
        $data_stmt = $db->prepare($data_query);
        $data_stmt->execute();
        $data_result = $data_stmt->get_result();
        
        // Her satır için INSERT komutunu oluştur
        while ($row = $data_result->fetch_assoc()) {
            $columns = array_keys($row);
            $quoted_columns = array_map(function($col) {
                return "\"" . $col . "\"";
            }, $columns);
            
            $values = array_map(function($val) use ($db) {
                if ($val === null) {
                    return "NULL";
                } else {
                    return "'" . addslashes($val) . "'";
                }
            }, array_values($row));
            
            // IF NOT EXISTS mantığı ile INSERT oluştur - çakışma durumunda güncelleme yap
            $insert = "INSERT INTO $table_name (" . implode(", ", $quoted_columns) . ") VALUES (" . implode(", ", $values) . ")";
            
            // ON CONFLICT kısmını ekle (PostgreSQL'in UPSERT özelliği)
            if (!empty($primary_keys)) {
                $insert .= " ON CONFLICT (\"" . implode('", "', $primary_keys) . "\") DO UPDATE SET ";
                $updates = [];
                foreach ($columns as $col) {
                    if (!in_array($col, $primary_keys)) {
                        $updates[] = "\"$col\" = EXCLUDED.\"$col\"";
                    }
                }
                $insert .= implode(", ", $updates);
            }
            
            $insert .= ";\n";
            fwrite($f, $insert);
        }
        
        // Transaction'ı tamamla
        fwrite($f, "\nCOMMIT;\n");
        
        fclose($f);
        
        // Sıkıştırma isteği varsa
        if ($compress) {
            $zip_path = "$backup_dir/{$table_name}_$timestamp.zip";
            $zip = new ZipArchive();
            if ($zip->open($zip_path, ZipArchive::CREATE) === TRUE) {
                $zip->addFile($file_path, basename($file_path));
                $zip->close();
                // Orijinal dosyayı sil
                unlink($file_path);
                return $zip_path;
            }
        }
        
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

function export_all_tables($format = 'sql', $with_drop = false, $as_zip = true) {
    global $backup_dir;
    $tables = get_db_tables();
    $timestamp = date('Y-m-d_H-i-s');
    
    // Eğer tek ZIP olarak istendiyse
    if ($as_zip) {
        $zip_path = "$backup_dir/db_backup_{$format}_{$timestamp}.zip";
        $zip = new ZipArchive();
        
        if ($zip->open($zip_path, ZipArchive::CREATE) !== TRUE) {
            return [];
        }
        
        $temp_dir = sys_get_temp_dir() . "/sikayetvar_export_" . time();
        if (!file_exists($temp_dir)) {
            mkdir($temp_dir, 0755, true);
        }
        
        // Her tablo için dosya oluştur (ancak yedekleme klasörüne değil, geçici klasöre)
        $files_count = 0;
        foreach ($tables as $table) {
            $file_name = "{$table}.{$format}";
            $file_path = "{$temp_dir}/{$file_name}";
            
            $content = '';
            
            if ($format === 'sql') {
                $content = generate_sql_export($table, $with_drop);
            } else if ($format === 'json') {
                $content = generate_json_export($table);
            } else if ($format === 'csv') {
                $content = generate_csv_export($table);
                // CSV için dosyaya yazma biraz farklı, doğrudan içerik dönmek yerine dosyaya yazıyor
                if ($content) {
                    $zip->addFile($content, $file_name);
                    $files_count++;
                    // CSV dosyasını sonradan silelim
                    @unlink($content);
                    continue;
                }
            }
            
            if ($content) {
                file_put_contents($file_path, $content);
                $zip->addFile($file_path, $file_name);
                $files_count++;
            }
        }
        
        // İçerik bilgisi ekle
        $readme = "# ŞikayetVar Veritabanı Yedeği ({$format} format)\n\n";
        $readme .= "Tarih: " . date('Y-m-d H:i:s') . "\n\n";
        $readme .= "Bu arşiv, veritabanının {$format} formatında yedeğini içerir.\n";
        $readme .= "İçerik:\n";
        $readme .= "- Tablo sayısı: " . count($tables) . "\n";
        $readme .= "- Başarılı yedeklenen tablo sayısı: " . $files_count . "\n";
        
        $zip->addFromString("README.txt", $readme);
        
        $zip->close();
        
        // Geçici dosyaları temizle
        if (file_exists($temp_dir)) {
            $temp_files = scandir($temp_dir);
            foreach ($temp_files as $file) {
                if (in_array($file, ['.', '..'])) continue;
                @unlink($temp_dir . '/' . $file);
            }
            @rmdir($temp_dir);
        }
        
        return [$zip_path]; // Tek bir dosya döndür
    } 
    // Eski davranış - her tablo için ayrı dosya
    else {
        $exported_files = [];
        foreach ($tables as $table) {
            $file_path = export_table_data($table, $format, $with_drop, false); // compress=false çünkü her dosya ayrı
            if ($file_path) {
                $exported_files[] = $file_path;
            }
        }
        return $exported_files;
    }
}

// SQL içeriği oluştur
function generate_sql_export($table_name, $with_drop = false) {
    global $db;
    
    // Başlangıç yorumu ve transaction başlat
    $output = "-- ŞikayetVar Veritabanı Yedeği\n";
    $output .= "-- Tablo: $table_name\n";
    $output .= "-- Tarih: " . date('Y-m-d H:i:s') . "\n\n";
    $output .= "START TRANSACTION;\n\n";
    
    // DROP TABLE komutunu ekle (isteğe bağlı)
    if ($with_drop) {
        $output .= "DROP TABLE IF EXISTS \"$table_name\";\n\n";
    }
    
    // Tablo yapısını çıkar
    $query = "SELECT column_name, data_type, character_maximum_length, column_default, is_nullable 
             FROM information_schema.columns 
             WHERE table_name = ?
             ORDER BY ordinal_position";
    $stmt = $db->prepare($query);
    $stmt->bind_param("s", $table_name);
    $stmt->execute();
    $result = $stmt->get_result();
    
    // Birincil anahtar bilgisini al
    $pk_query = "SELECT a.attname as column_name
                FROM pg_index i
                JOIN pg_attribute a ON a.attrelid = i.indrelid AND a.attnum = ANY(i.indkey)
                WHERE i.indrelid = ?::regclass AND i.indisprimary";
    $pk_stmt = $db->prepare($pk_query);
    $pk_stmt->bind_param("s", $table_name);
    $pk_stmt->execute();
    $pk_result = $pk_stmt->get_result();
    $primary_keys = [];
    while ($pk_row = $pk_result->fetch_assoc()) {
        $primary_keys[] = $pk_row['column_name'];
    }
    
    // CREATE TABLE ifadesi oluştur
    $create_table = "CREATE TABLE IF NOT EXISTS \"$table_name\" (\n";
    $columns = [];
    $column_defs = [];
    
    while ($row = $result->fetch_assoc()) {
        $column_defs[$row['column_name']] = $row;
        $col_def = "  \"" . $row['column_name'] . "\" " . $row['data_type'];
        
        if (!empty($row['character_maximum_length'])) {
            $col_def .= "(" . $row['character_maximum_length'] . ")";
        }
        
        // NULL/NOT NULL durumu
        $col_def .= ($row['is_nullable'] === 'YES') ? ' NULL' : ' NOT NULL';
        
        // Varsayılan değer
        if ($row['column_default'] !== null) {
            $col_def .= " DEFAULT " . $row['column_default'];
        }
        
        $columns[] = $col_def;
    }
    
    $create_table .= implode(",\n", $columns);
    
    // Birincil anahtar kısıtlaması ekle
    if (!empty($primary_keys)) {
        $create_table .= ",\n  PRIMARY KEY (\"" . implode('", "', $primary_keys) . "\")";
    }
    
    $create_table .= "\n);\n\n";
    $output .= $create_table;
    
    // Veri çıkarma
    $data_query = "SELECT * FROM \"$table_name\"";
    $data_stmt = $db->prepare($data_query);
    $data_stmt->execute();
    $data_result = $data_stmt->get_result();
    
    // Her satır için INSERT komutunu oluştur
    while ($row = $data_result->fetch_assoc()) {
        $columns = array_keys($row);
        $quoted_columns = array_map(function($col) {
            return "\"" . $col . "\"";
        }, $columns);
        
        $values = array_map('fix_value_for_sql', array_values($row));
        
        // IF NOT EXISTS mantığı ile INSERT oluştur - çakışma durumunda güncelleme yap
        $insert = "INSERT INTO \"$table_name\" (" . implode(", ", $quoted_columns) . ") VALUES (" . implode(", ", $values) . ")";
        
        // ON CONFLICT kısmını ekle (PostgreSQL'in UPSERT özelliği)
        if (!empty($primary_keys)) {
            $insert .= " ON CONFLICT (\"" . implode('", "', $primary_keys) . "\") DO UPDATE SET ";
            $updates = [];
            foreach ($columns as $col) {
                if (!in_array($col, $primary_keys)) {
                    $updates[] = "\"$col\" = EXCLUDED.\"$col\"";
                }
            }
            $insert .= implode(", ", $updates);
        }
        
        $insert .= ";\n";
        $output .= $insert;
    }
    
    // Transaction'ı tamamla
    $output .= "\nCOMMIT;\n";
    
    return $output;
}

// JSON içeriği oluştur
function generate_json_export($table_name) {
    global $db;
    
    $query = "SELECT * FROM \"$table_name\"";
    $stmt = $db->prepare($query);
    $stmt->execute();
    $result = $stmt->get_result();
    
    $data = [];
    while ($row = $result->fetch_assoc()) {
        $data[] = $row;
    }
    
    return json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
}

// PostgreSQL için değerleri doğru formatlayan yardımcı fonksiyon
function fix_value_for_sql($val) {
    if ($val === null) {
        return "NULL";
    } elseif ($val === "") {
        // Boş string değerlerini NULL olarak işle (boolean hatalarını önlemek için)
        return "NULL";
    } elseif ($val === "t" || $val === "true" || $val === "1" || $val === true) {
        // Boolean true değerlerini PostgreSQL uyumlu formata dönüştür
        return "TRUE";
    } elseif ($val === "f" || $val === "false" || $val === "0" || $val === false) {
        // Boolean false değerlerini PostgreSQL uyumlu formata dönüştür
        return "FALSE";
    } else {
        return "'" . addslashes($val) . "'";
    }
}

// CSV içeriği oluştur (dosya döndürür)
function generate_csv_export($table_name) {
    global $db, $backup_dir;
    $temp_file = tempnam(sys_get_temp_dir(), 'csv_');
    $f = fopen($temp_file, 'w');
    
    if (!$f) return false;
    
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
    $data_query = "SELECT * FROM \"$table_name\"";
    $data_stmt = $db->prepare($data_query);
    $data_stmt->execute();
    $data_result = $data_stmt->get_result();
    
    while ($row = $data_result->fetch_assoc()) {
        fputcsv($f, $row);
    }
    
    fclose($f);
    return $temp_file;
}

// Yeni eklenen birleştirilmiş SQL yedekleme fonksiyonu
function generate_unified_sql_export($with_drop = false, $export_type = 'full') {
    // $export_type seçenekleri:
    // 'full' = Tam yedek (tablolar + veriler + bağımlılıklar)
    // 'tables_only' = Sadece tablo yapısı
    // 'data_only' = Sadece veriler 
    // 'dependencies_only' = Sadece bağımlılıklar
    // 'tables_dependencies' = Tablolar ve bağımlılıklar (veri olmadan)
    global $db, $backup_dir;
    $timestamp = date('Y-m-d_H-i-s');
    $file_path = "$backup_dir/unified_db_backup_$timestamp.sql";
    $f = fopen($file_path, 'w');
    
    // Başlangıç yorumu
    $header = "-- ŞikayetVar Veritabanı Birleştirilmiş Yedeği\n";
    $header .= "-- Tarih: " . date('Y-m-d H:i:s') . "\n";
    $header .= "-- Bu dosya, veritabanının doğru sırayla (önce tablolar, sonra veriler, son olarak ilişkiler) içe aktarılmasını sağlar\n\n";
    $header .= "SET statement_timeout = 0;\n";
    $header .= "SET lock_timeout = 0;\n";
    $header .= "SET client_encoding = 'UTF8';\n";
    $header .= "SET standard_conforming_strings = on;\n\n";
    
    // İşlem başlat
    $header .= "START TRANSACTION;\n\n";
    fwrite($f, $header);
    
    // Tabloları mantıksal sırayla al
    $tables = get_tables_in_order();
    
    // 1. Adım: Tabloları oluştur (foreign key kısıtlamaları olmadan)
    fwrite($f, "-- 1. ADIM: TABLO YAPILARINI OLUŞTUR\n");
    fwrite($f, "-- -----------------------------\n\n");
    
    // Foreign key referanslarını daha sonra eklemek için sakla
    $foreign_keys = [];
    
    foreach ($tables as $table) {
        // DROP TABLE komutunu ekle (isteğe bağlı)
        if ($with_drop) {
            fwrite($f, "DROP TABLE IF EXISTS \"$table\" CASCADE;\n");
        }
        
        // Tablo yapısını çıkar (foreign key kısıtlamaları olmadan)
        $query = "SELECT column_name, data_type, character_maximum_length, column_default, is_nullable 
                 FROM information_schema.columns 
                 WHERE table_name = ?
                 ORDER BY ordinal_position";
        $stmt = $db->prepare($query);
        $stmt->bind_param("s", $table);
        $stmt->execute();
        $result = $stmt->get_result();
        
        // Birincil anahtar bilgisini al
        $pk_query = "SELECT a.attname as column_name
                    FROM pg_index i
                    JOIN pg_attribute a ON a.attrelid = i.indrelid AND a.attnum = ANY(i.indkey)
                    WHERE i.indrelid = ?::regclass AND i.indisprimary";
        $pk_stmt = $db->prepare($pk_query);
        $pk_stmt->bind_param("s", $table);
        $pk_stmt->execute();
        $pk_result = $pk_stmt->get_result();
        $primary_keys = [];
        while ($pk_row = $pk_result->fetch_assoc()) {
            $primary_keys[] = $pk_row['column_name'];
        }
        
        // Foreign key kısıtlamalarını al
        $fk_query = "SELECT
                    kcu.column_name, 
                    ccu.table_name AS foreign_table_name,
                    ccu.column_name AS foreign_column_name,
                    tc.constraint_name
                FROM 
                    information_schema.table_constraints AS tc 
                    JOIN information_schema.key_column_usage AS kcu
                    ON tc.constraint_name = kcu.constraint_name
                    AND tc.table_schema = kcu.table_schema
                    JOIN information_schema.constraint_column_usage AS ccu 
                    ON ccu.constraint_name = tc.constraint_name
                    AND ccu.table_schema = tc.table_schema
                WHERE tc.constraint_type = 'FOREIGN KEY' AND tc.table_name=?";
        
        $fk_stmt = $db->prepare($fk_query);
        $fk_stmt->bind_param("s", $table);
        $fk_stmt->execute();
        $fk_result = $fk_stmt->get_result();
        
        while ($fk_row = $fk_result->fetch_assoc()) {
            // Foreign key'i daha sonra eklemek üzere sakla
            $foreign_keys[] = [
                'table' => $table,
                'column' => $fk_row['column_name'],
                'foreign_table' => $fk_row['foreign_table_name'],
                'foreign_column' => $fk_row['foreign_column_name'],
                'constraint_name' => $fk_row['constraint_name']
            ];
        }
        
        // CREATE TABLE ifadesi oluştur
        $create_table = "CREATE TABLE \"$table\" (\n";
        $columns = [];
        
        // PostgreSQL sequence objeleri için ayrıca kontrol
        $sequence_query = "SELECT column_name, column_default 
                          FROM information_schema.columns 
                          WHERE table_name = ? 
                          AND column_default LIKE 'nextval%'";
        $seq_stmt = $db->prepare($sequence_query);
        $seq_stmt->bind_param("s", $table);
        $seq_stmt->execute();
        $seq_result = $seq_stmt->get_result();
        
        $sequences = [];
        while ($seq_row = $seq_result->fetch_assoc()) {
            // nextval('sequence_name'::regclass) içinden sequence adını çıkar
            preg_match("/nextval\('([^']+)'::regclass\)/", $seq_row['column_default'], $matches);
            if (!empty($matches[1])) {
                $sequences[$seq_row['column_name']] = $matches[1];
            }
        }
        
        // Tablo kolonlarını oluştur
        while ($row = $result->fetch_assoc()) {
            $col_name = $row['column_name'];
            $col_def = "  \"" . $col_name . "\" " . $row['data_type'];
            
            if (!empty($row['character_maximum_length'])) {
                $col_def .= "(" . $row['character_maximum_length'] . ")";
            }
            
            // NULL/NOT NULL durumu
            $col_def .= ($row['is_nullable'] === 'YES') ? ' NULL' : ' NOT NULL';
            
            // Varsayılan değer
            if ($row['column_default'] !== null) {
                // Sequence varsa, CREATE SEQUENCE komutunu ayrıca ekleyeceğiz
                if (isset($sequences[$col_name])) {
                    $col_def .= " DEFAULT nextval('" . $sequences[$col_name] . "'::regclass)";
                } else {
                    $col_def .= " DEFAULT " . $row['column_default'];
                }
            }
            
            $columns[] = $col_def;
        }
        
        // Her sequence için CREATE SEQUENCE komutunu ekle
        if (!empty($sequences)) {
            foreach ($sequences as $col_name => $sequence_name) {
                // DROP SEQUENCE iste ve ekle
                if ($with_drop) {
                    fwrite($f, "DROP SEQUENCE IF EXISTS \"$sequence_name\" CASCADE;\n");
                }
                
                // Sequence oluştur
                fwrite($f, "CREATE SEQUENCE IF NOT EXISTS \"$sequence_name\";\n");
            }
            fwrite($f, "\n");
        }
        
        $create_table .= implode(",\n", $columns);
        
        // Birincil anahtar kısıtlaması ekle
        if (!empty($primary_keys)) {
            $create_table .= ",\n  PRIMARY KEY (\"" . implode('", "', $primary_keys) . "\")";
        }
        
        $create_table .= "\n);\n\n";
        fwrite($f, $create_table);
    }
    
    // 2. Adım: Verileri tabloların içine aktar (sadece 'full' veya 'data_only' seçildiğinde)
    if ($export_type == 'full' || $export_type == 'data_only') {
        fwrite($f, "\n-- 2. ADIM: VERİLERİ AKTAR\n");
        fwrite($f, "-- -----------------------------\n\n");
        
        foreach ($tables as $table) {
            fwrite($f, "-- Tablo: $table için veri\n");
            
            // Veri çıkarma
            $data_query = "SELECT * FROM \"$table\"";
            $data_result = $db->query($data_query);
            
            // Tablo boşsa not düş ve devam et
            if ($data_result->num_rows == 0) {
                fwrite($f, "-- Bu tablo boş, veri yok\n\n");
                continue;
            }
            
            // Her satır için INSERT komutunu oluştur
            while ($row = $data_result->fetch_assoc()) {
                $columns = array_keys($row);
                $quoted_columns = array_map(function($col) {
                    return "\"" . $col . "\"";
                }, $columns);
                
                $values = array_map('fix_value_for_sql', array_values($row));
                
                $insert = "INSERT INTO \"$table\" (" . implode(", ", $quoted_columns) . ") VALUES (" . implode(", ", $values) . ")";
                
                // ON CONFLICT kısmı yerine SKIP yedeği tutmak için
                $insert .= ";\n";
                fwrite($f, $insert);
            }
            
            fwrite($f, "\n");
        }
    } else if ($export_type == 'tables_only' || $export_type == 'tables_dependencies' || $export_type == 'dependencies_only') {
        fwrite($f, "\n-- VERİ AKTARMA DEVRE DIŞI: Bu yedekte yalnızca " . 
               ($export_type == 'tables_only' ? 'tablo yapıları' : 
               ($export_type == 'dependencies_only' ? 'ilişki tanımları' : 'tablo yapıları ve ilişkiler')) . 
               " bulunmaktadır.\n\n");
    }
    
    // 3. Adım: İlişkileri (foreign key kısıtlamaları) ekle (sadece 'dependencies_only' olmadığında)
    if (!empty($foreign_keys) && ($export_type == 'full' || $export_type == 'tables_dependencies' || $export_type == 'dependencies_only')) {
        fwrite($f, "\n-- 3. ADIM: İLİŞKİLERİ (FOREIGN KEY KISITLAMALARI) EKLE\n");
        fwrite($f, "-- -----------------------------\n\n");
        
        foreach ($foreign_keys as $fk) {
            $add_constraint = "ALTER TABLE \"" . $fk['table'] . "\" ADD CONSTRAINT \"" . $fk['constraint_name'] . "\" ";
            $add_constraint .= "FOREIGN KEY (\"" . $fk['column'] . "\") REFERENCES \"" . $fk['foreign_table'] . "\" (\"" . $fk['foreign_column'] . "\")";
            $add_constraint .= " ON UPDATE CASCADE ON DELETE CASCADE"; // Veya başka bir kural
            $add_constraint .= ";\n";
            
            fwrite($f, $add_constraint);
        }
    } else if (!empty($foreign_keys) && $export_type == 'tables_only') {
        fwrite($f, "\n-- İLİŞKİ TANIMLARI DEVRE DIŞI: Bu yedekte yalnızca tablo yapıları bulunmaktadır.\n\n");
    }
    
    // Transaction'ı tamamla
    fwrite($f, "\nCOMMIT;\n");
    
    fclose($f);
    return $file_path;
}

function create_full_backup($with_drop = false) {
    global $backup_dir;
    $timestamp = date('Y-m-d_H-i-s');
    $backup_file = "$backup_dir/full_backup_$timestamp.zip";
    
    // Tüm dosyaları ZIP arşivine ekle
    $zip = new ZipArchive();
    if ($zip->open($backup_file, ZipArchive::CREATE) !== TRUE) {
        return false;
    }
    
    // Tüm tabloları al
    $tables = get_db_tables();
    
    // Geçici klasör oluştur
    $temp_dir = sys_get_temp_dir() . "/sikayetvar_full_export_" . time();
    if (!file_exists($temp_dir)) {
        mkdir($temp_dir, 0755, true);
    }
    
    // SQL, JSON ve CSV alt klasörleri oluştur
    $sql_dir = $temp_dir . "/sql";
    $json_dir = $temp_dir . "/json";
    $csv_dir = $temp_dir . "/csv";
    
    mkdir($sql_dir, 0755, true);
    mkdir($json_dir, 0755, true);
    mkdir($csv_dir, 0755, true);
    
    $tables_processed = 0;
    
    // Her tablo için SQL, JSON ve CSV çıktısı al ve klasörlere kaydet
    foreach ($tables as $table) {
        // SQL formatında
        $sql_content = generate_sql_export($table, $with_drop);
        $sql_file = "{$sql_dir}/{$table}.sql";
        file_put_contents($sql_file, $sql_content);
        
        // JSON formatında
        $json_content = generate_json_export($table);
        $json_file = "{$json_dir}/{$table}.json";
        file_put_contents($json_file, $json_content);
        
        // CSV formatında
        $csv_temp_file = generate_csv_export($table);
        if ($csv_temp_file) {
            $csv_file = "{$csv_dir}/{$table}.csv";
            copy($csv_temp_file, $csv_file);
            @unlink($csv_temp_file);
        }
        
        $tables_processed++;
    }
    
    // Tüm dosyaları ZIP'e ekle
    $this_backup_dir = basename($temp_dir);
    
    // SQL klasörünü ekle
    $zip->addEmptyDir("sql");
    $sql_files = glob($sql_dir . "/*.sql");
    foreach ($sql_files as $file) {
        $zip->addFile($file, "sql/" . basename($file));
    }
    
    // JSON klasörünü ekle
    $zip->addEmptyDir("json");
    $json_files = glob($json_dir . "/*.json");
    foreach ($json_files as $file) {
        $zip->addFile($file, "json/" . basename($file));
    }
    
    // CSV klasörünü ekle
    $zip->addEmptyDir("csv");
    $csv_files = glob($csv_dir . "/*.csv");
    foreach ($csv_files as $file) {
        $zip->addFile($file, "csv/" . basename($file));
    }
    
    // İçerik bilgisi ekle
    $readme = "# ŞikayetVar Veritabanı Tam Yedeği\n\n";
    $readme .= "Tarih: " . date('Y-m-d H:i:s') . "\n\n";
    $readme .= "Bu arşiv, veritabanının tam bir yedeğini içerir.\n";
    $readme .= "İçerik:\n";
    $readme .= "- Toplam tablo sayısı: " . count($tables) . "\n";
    $readme .= "- SQL dosyaları: " . count($sql_files) . "\n";
    $readme .= "- JSON dosyaları: " . count($json_files) . "\n";
    $readme .= "- CSV dosyaları: " . count($csv_files) . "\n\n";
    $readme .= "Klasörler:\n";
    $readme .= "- sql/: SQL formatında tablolar (DROP TABLE, CREATE TABLE ve INSERT komutları içerir)\n";
    $readme .= "- json/: JSON formatında tablolar (tablo verilerini içerir)\n";
    $readme .= "- csv/: CSV formatında tablolar (başlık satırı ve veri satırları içerir)\n";
    
    $zip->addFromString("README.txt", $readme);
    
    // Yükleme ve çıkarma işlemi tamamlandıktan sonra ZIP'i kapat
    $zip->close();
    
    // Geçici klasörü temizle
    if (file_exists($temp_dir)) {
        // SQL dosyalarını temizle
        $sql_files = glob($sql_dir . "/*.sql");
        foreach ($sql_files as $file) {
            @unlink($file);
        }
        @rmdir($sql_dir);
        
        // JSON dosyalarını temizle
        $json_files = glob($json_dir . "/*.json");
        foreach ($json_files as $file) {
            @unlink($file);
        }
        @rmdir($json_dir);
        
        // CSV dosyalarını temizle
        $csv_files = glob($csv_dir . "/*.csv");
        foreach ($csv_files as $file) {
            @unlink($file);
        }
        @rmdir($csv_dir);
        
        // Ana klasörü temizle
        @rmdir($temp_dir);
    }
    
    return $backup_file;
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

// Yedek dizinini temizle - belirli bir tarihten eski yedekleri sil
function cleanup_backups($days = 7, $keep_min = 3) {
    global $backup_dir;
    
    if (!file_exists($backup_dir)) {
        return [0, 0]; // Silinen dosya sayısı, toplam boyut
    }
    
    $backups = get_existing_backups();
    
    // En az keep_min sayıda yedek her zaman saklansın
    if (count($backups) <= $keep_min) {
        return [0, 0];
    }
    
    $threshold_time = time() - ($days * 24 * 60 * 60);
    $deleted_count = 0;
    $freed_space = 0;
    
    // keep_min sayıda yedek tutacak şekilde, belirlenen tarihten eski yedekleri sil
    $preserved_count = 0;
    
    foreach ($backups as $backup) {
        $file_time = strtotime($backup['date']);
        
        // Eğer dosya belirtilen günden eskiyse ve minimum korunan sayısını aşmışsa sil
        if ($file_time < $threshold_time && $preserved_count >= $keep_min) {
            if (unlink($backup['path'])) {
                $deleted_count++;
                $freed_space += $backup['size'];
            }
        } else {
            $preserved_count++;
        }
    }
    
    return [$deleted_count, $freed_space];
}

function format_file_size($size) {
    $units = ['B', 'KB', 'MB', 'GB', 'TB'];
    
    for ($i = 0; $size > 1024; $i++) {
        $size /= 1024;
    }
    
    return round($size, 2) . ' ' . $units[$i];
}

// İçe aktarma (import) fonksiyonu
function import_backup($file_path, $replace_data = false) {
    global $db;
    $file_ext = strtolower(pathinfo($file_path, PATHINFO_EXTENSION));
    
    // Uzantı boşsa ve dosya adında nokta yoksa, MIME tipi ile tespit etmeye çalış
    if (empty($file_ext)) {
        $finfo = finfo_open(FILEINFO_MIME_TYPE);
        $mime_type = finfo_file($finfo, $file_path);
        finfo_close($finfo);
        
        error_log("Dosya uzantısı bulunamadı, MIME tipi ile tespit ediliyor: " . $mime_type);
        
        // MIME tipine göre uzantı belirle
        if (strpos($mime_type, 'text/plain') !== false) {
            // İçeriği kontrol ederek SQL, JSON veya CSV olduğunu belirle
            $sample = file_get_contents($file_path, false, null, 0, 1000); // İlk 1000 byte
            
            if (preg_match('/(CREATE|INSERT|DROP)\s+TABLE/i', $sample)) {
                $file_ext = 'sql';
                error_log("İçerik analizi sonucu: SQL dosyası olarak belirlendi");
            } elseif (preg_match('/^\s*[\{\[]/', $sample) && preg_match('/[\}\]]\s*$/', $sample)) {
                $file_ext = 'json';
                error_log("İçerik analizi sonucu: JSON dosyası olarak belirlendi");
            } elseif (preg_match('/^[^,\n]*,[^,\n]*,[^,\n]*/', $sample)) {
                $file_ext = 'csv';
                error_log("İçerik analizi sonucu: CSV dosyası olarak belirlendi");
            }
        } elseif (strpos($mime_type, 'application/zip') !== false) {
            $file_ext = 'zip';
            error_log("MIME tipi analizi sonucu: ZIP dosyası olarak belirlendi");
        }
    }
    
    error_log("İçe aktarma başlatılıyor: $file_path ($file_ext)");
    
    // ZIP dosyasını işle
    if ($file_ext === 'zip') {
        $extract_dir = sys_get_temp_dir() . '/sikayetvar_import_' . time();
        if (!file_exists($extract_dir)) {
            mkdir($extract_dir, 0755, true);
        }
        
        error_log("Geçici dizin oluşturuldu: $extract_dir");
        
        $zip = new ZipArchive();
        $zip_result = $zip->open($file_path);
        
        if ($zip_result === TRUE) {
            // ZIP dosyasını açma ve içeriğini çıkarma başarılı
            error_log("ZIP dosyası başarıyla açıldı, dosya sayısı: " . $zip->numFiles);
            $zip->extractTo($extract_dir);
            $zip->close();
            
            error_log("ZIP içeriği $extract_dir klasörüne çıkarıldı");
            
            $results = [];
            $processed = 0;
            
            // Klasör yapısını logla
            $folder_content = scandir($extract_dir);
            error_log("Çıkarılan içerik: " . implode(", ", $folder_content));
            
            // Eğer sql, json, csv klasörleri varsa, yapılandırılmış tam yedek kabul et
            if (file_exists($extract_dir . '/sql') || 
                file_exists($extract_dir . '/json') || 
                file_exists($extract_dir . '/csv')) {
                
                error_log("Yapılandırılmış yedek formatı tespit edildi");
                
                // SQL klasörünü işle
                if (file_exists($extract_dir . '/sql')) {
                    $sql_files = glob($extract_dir . '/sql/*.sql');
                    error_log("SQL klasöründe " . count($sql_files) . " dosya bulundu");
                    foreach ($sql_files as $file) {
                        error_log("SQL dosyası işleniyor: " . basename($file));
                        $result = import_single_file($file, $replace_data);
                        $processed++;
                        $results[basename($file)] = $result;
                        error_log("SQL dosyası işleme sonucu: " . ($result[0] ? "Başarılı" : "Başarısız - " . $result[1]));
                    }
                }
                
                // JSON klasörünü işle
                if (file_exists($extract_dir . '/json')) {
                    $json_files = glob($extract_dir . '/json/*.json');
                    error_log("JSON klasöründe " . count($json_files) . " dosya bulundu");
                    foreach ($json_files as $file) {
                        error_log("JSON dosyası işleniyor: " . basename($file));
                        $result = import_single_file($file, $replace_data);
                        $processed++;
                        $results[basename($file)] = $result;
                        error_log("JSON dosyası işleme sonucu: " . ($result[0] ? "Başarılı" : "Başarısız - " . $result[1]));
                    }
                }
                
                // CSV klasörünü işle
                if (file_exists($extract_dir . '/csv')) {
                    $csv_files = glob($extract_dir . '/csv/*.csv');
                    error_log("CSV klasöründe " . count($csv_files) . " dosya bulundu");
                    foreach ($csv_files as $file) {
                        error_log("CSV dosyası işleniyor: " . basename($file));
                        $result = import_single_file($file, $replace_data);
                        $processed++;
                        $results[basename($file)] = $result;
                        error_log("CSV dosyası işleme sonucu: " . ($result[0] ? "Başarılı" : "Başarısız - " . $result[1]));
                    }
                }
            } 
            // Aksi halde yedek klasörün içindeki tüm dosyaları doğrudan tara
            else {
                error_log("Standart yedek formatı tespit edildi, tüm dosyalar taranıyor...");
                // Çıkarılan dosyaları işle
                $extracted_files = scan_dir_recursive($extract_dir);
                error_log("Toplam " . count($extracted_files) . " dosya bulundu");
                
                foreach ($extracted_files as $file) {
                    $ext = strtolower(pathinfo($file, PATHINFO_EXTENSION));
                    if (in_array($ext, ['sql', 'json', 'csv'])) {
                        error_log($ext . " dosyası işleniyor: " . basename($file));
                        $result = import_single_file($file, $replace_data);
                        $processed++;
                        $results[basename($file)] = $result;
                        error_log("Dosya işleme sonucu: " . ($result[0] ? "Başarılı" : "Başarısız - " . $result[1]));
                    }
                }
            }
            
            // Eğer hiç dosya işlenmediyse hata döndür
            if ($processed === 0) {
                // Geçici klasörü temizle
                clean_dir_recursive($extract_dir);
                
                return [false, "ZIP içerisinde desteklenen format (SQL, JSON, CSV) bulunamadı."];
            }
            
            // Geçici klasörü temizle
            clean_dir_recursive($extract_dir);
            
            // Sonuçları döndür
            $success_count = 0;
            foreach ($results as $res) {
                if ($res[0] === true) $success_count++;
            }
            $total_count = count($results);
            
            if ($success_count === $total_count) {
                return [true, "{$success_count} dosya başarıyla içe aktarıldı."];
            } else {
                return [false, "{$success_count}/{$total_count} dosya içe aktarıldı. Bazı dosyalar işlenemedi."];
            }
        } else {
            return [false, "ZIP dosyası açılamadı."];
        }
    } else {
        // Tek dosyayı işle
        error_log("Tek dosya içe aktarılıyor: $file_path");
        return import_single_file($file_path, $replace_data);
    }
}

// Klasörü ve alt klasörleri recursive olarak tara
function scan_dir_recursive($dir) {
    $result = [];
    $files = scandir($dir);
    
    foreach ($files as $file) {
        if (in_array($file, ['.', '..'])) continue;
        
        $path = $dir . '/' . $file;
        
        if (is_dir($path)) {
            $result = array_merge($result, scan_dir_recursive($path));
        } else {
            $result[] = $path;
        }
    }
    
    return $result;
}

// Klasörü ve içeriğini temizle
function clean_dir_recursive($dir) {
    if (!file_exists($dir)) return;
    
    $files = scandir($dir);
    
    foreach ($files as $file) {
        if (in_array($file, ['.', '..'])) continue;
        
        $path = $dir . '/' . $file;
        
        if (is_dir($path)) {
            clean_dir_recursive($path);
            @rmdir($path);
        } else {
            @unlink($path);
        }
    }
    
    @rmdir($dir);
}

function import_single_file($file_path, $replace_data = false) {
    global $db;
    $file_ext = strtolower(pathinfo($file_path, PATHINFO_EXTENSION));
    
    // Uzantı boşsa, MIME tipi ile tespit etmeye çalış
    if (empty($file_ext)) {
        $finfo = finfo_open(FILEINFO_MIME_TYPE);
        $mime_type = finfo_file($finfo, $file_path);
        finfo_close($finfo);
        
        error_log("Dosya uzantısı bulunamadı, MIME tipi ile tespit ediliyor: " . $mime_type);
        
        // MIME tipine göre uzantı belirle
        if (strpos($mime_type, 'text/plain') !== false) {
            // İçeriği kontrol ederek SQL, JSON veya CSV olduğunu belirle
            $sample = file_get_contents($file_path, false, null, 0, 1000); // İlk 1000 byte
            
            if (preg_match('/(CREATE|INSERT|DROP)\s+TABLE/i', $sample)) {
                $file_ext = 'sql';
                error_log("İçerik analizi sonucu: SQL dosyası olarak belirlendi");
            } elseif (preg_match('/^\s*[\{\[]/', $sample) && preg_match('/[\}\]]\s*$/', $sample)) {
                $file_ext = 'json';
                error_log("İçerik analizi sonucu: JSON dosyası olarak belirlendi");
            } elseif (preg_match('/^[^,\n]*,[^,\n]*,[^,\n]*/', $sample)) {
                $file_ext = 'csv';
                error_log("İçerik analizi sonucu: CSV dosyası olarak belirlendi");
            }
        } elseif (strpos($mime_type, 'application/zip') !== false) {
            $file_ext = 'zip';
            error_log("MIME tipi analizi sonucu: ZIP dosyası olarak belirlendi");
        }
    }
    
    error_log("import_single_file: Dosya işleniyor: $file_path (format: $file_ext)");
    
    try {
        // SQL dosyası
        if ($file_ext === 'sql') {
            $sql_content = file_get_contents($file_path);
            
            // SQL içeriğini çalıştır (transaction içinde)
            $db->begin_transaction();
            
            try {
                // SQL içeriğini önişle - sondan boşlukları temizle
                $sql_content = trim($sql_content);
                                
                // Yorum satırlarını temizle
                $sql_content = preg_replace('/--.*$/m', '', $sql_content);
                $sql_content = preg_replace('!/\*.*?\*/!s', '', $sql_content);
                
                error_log("SQL içeriği temizlendi, boyut: " . strlen($sql_content) . " bayt");
                
                // SQL dosyasını daha basit bir şekilde böl
                $raw_queries = explode(';', $sql_content);
                $queries = [];
                
                foreach ($raw_queries as $query) {
                    $query = trim($query);
                    if (!empty($query)) {
                        $queries[] = $query;
                    }
                }
                
                error_log("SQL dosyasında " . count($queries) . " sorgu bulundu.");
                
                foreach ($queries as $i => $query) {
                    $query = trim($query);
                    if (!empty($query)) {
                        try {
                            $log_query = substr($query, 0, 100);
                            error_log("SQL sorgusu çalıştırılıyor [" . ($i+1) . "/" . count($queries) . "]: " . $log_query . (strlen($query) > 100 ? "..." : ""));
                            
                            // DROP TABLE komutlarına CASCADE ekleyelim
                            if (stripos($query, 'DROP TABLE') !== false) {
                                error_log("DROP TABLE komutu tespit edildi");
                                // Eğer komutta CASCADE yoksa ekleyelim
                                if (stripos($query, 'CASCADE') === false) {
                                    // IF EXISTS varsa ondan sonra, yoksa DROP TABLE'dan sonra CASCADE ekle
                                    if (stripos($query, 'IF EXISTS') !== false) {
                                        $query = preg_replace('/IF EXISTS\s+([^\s;]+)/', 'IF EXISTS $1 CASCADE', $query);
                                    } else {
                                        $query = preg_replace('/DROP TABLE\s+([^\s;]+)/', 'DROP TABLE $1 CASCADE', $query);
                                    }
                                    error_log("DROP TABLE komutuna CASCADE eklendi: " . $query);
                                }
                            } else if (stripos($query, 'CREATE TABLE') !== false) {
                                error_log("CREATE TABLE komutu tespit edildi");
                                
                                // Tablo adını bul
                                if (preg_match('/CREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?["\']?([^\s"\']+)["\']?/i', $query, $matches)) {
                                    $table_name = $matches[1];
                                    error_log("Tablo adı: " . $table_name);
                                    
                                    // Tablo var mı kontrol et
                                    $check_query = "SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = '$table_name'";
                                    $check_result = $db->query($check_query);
                                    
                                    if ($check_result && $check_result->num_rows() > 0) {
                                        error_log("Tablo zaten var, CREATE TABLE atlanıyor: " . $table_name);
                                        // Bu sorguyu atla
                                        continue;
                                    }
                                }
                            }
                            
                            $result = $db->query($query);
                            
                            if ($result === false) {
                                $error_message = $db->error();
                                error_log("SQL sorgu hatası [" . ($i+1) . "]: " . $error_message);
                                if (!empty($error_message)) {
                                    throw new Exception($error_message);
                                } else {
                                    throw new Exception("SQL sorgusu hata verdi ama detay alınamadı");
                                }
                            }
                        } catch (Exception $e) {
                            error_log("SQL sorgu exception [" . ($i+1) . "]: " . $e->getMessage());
                            throw $e;
                        }
                    }
                }
                
                $db->commit();
                return [true, "SQL dosyası başarıyla içe aktarıldı."];
            } catch (Exception $e) {
                $db->rollback();
                return [false, "SQL hatası: " . $e->getMessage()];
            }
        } 
        // JSON dosyası
        else if ($file_ext === 'json') {
            $json_content = file_get_contents($file_path);
            $data = json_decode($json_content, true);
            
            if (is_null($data)) {
                return [false, "Geçersiz JSON formatı."];
            }
            
            // Tablonun adını dosya adından çıkar
            $table_name = pathinfo($file_path, PATHINFO_FILENAME);
            // Tarih bilgisini temizle
            $table_name = preg_replace('/_\d{4}-\d{2}-\d{2}.*$/', '', $table_name);
            error_log("JSON içe aktarma için tablo adı: $table_name");
            
            // Tablo zaten var mı kontrol et
            $check_query = "SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = '$table_name'";
            $check_result = $db->query($check_query);
            $table_exists = $check_result->num_rows() > 0;
            error_log("JSON tablo kontrolü: " . ($table_exists ? "Tablo var" : "Tablo yok"));
            
            if (!$table_exists) {
                // Tablo yoksa, tablo yapısını oluştur
                $table_columns = [];
                
                if (!empty($data)) {
                    $first_row = $data[0];
                    foreach ($first_row as $column => $value) {
                        $type = is_numeric($value) ? 
                            (is_int($value) ? "INT" : "DECIMAL(10,2)") : 
                            "VARCHAR(255)";
                        $table_columns[] = "\"$column\" $type";
                    }
                    
                    $create_table_sql = "CREATE TABLE \"$table_name\" (\n  " . 
                                        implode(",\n  ", $table_columns) . "\n)";
                    
                    $db->query($create_table_sql);
                }
            } else if ($replace_data) {
                // Tabloyu temizle
                $db->query("DELETE FROM \"$table_name\"");
            }
            
            // Veriyi ekle
            if (!empty($data)) {
                $db->begin_transaction();
                
                try {
                    foreach ($data as $row) {
                        $columns = array_keys($row);
                        $quoted_columns = array_map(function($col) {
                            return "\"$col\"";
                        }, $columns);
                        
                        $placeholders = array_fill(0, count($columns), '?');
                        $values = array_values($row);
                        
                        $insert_query = "INSERT INTO \"$table_name\" (" . 
                                        implode(", ", $quoted_columns) . 
                                        ") VALUES (" . implode(", ", $placeholders) . ")";
                        
                        $stmt = $db->prepare($insert_query);
                        
                        if ($stmt) {
                            $types = '';
                            foreach ($values as $val) {
                                if (is_int($val)) $types .= 'i';
                                else if (is_float($val)) $types .= 'd';
                                else if (is_null($val)) $types .= 's';
                                else $types .= 's';
                            }
                            
                            $stmt->bind_param($types, ...$values);
                            $stmt->execute();
                        }
                    }
                    
                    $db->commit();
                    return [true, "JSON verisi başarıyla içe aktarıldı."];
                } catch (Exception $e) {
                    $db->rollback();
                    return [false, "JSON içe aktarma hatası: " . $e->getMessage()];
                }
            }
            
            return [true, "JSON içe aktarma tamamlandı, ancak veri yok."];
        } 
        // CSV dosyası
        else if ($file_ext === 'csv') {
            $table_name = pathinfo($file_path, PATHINFO_FILENAME);
            // Tarih bilgisini temizle
            $table_name = preg_replace('/_\d{4}-\d{2}-\d{2}.*$/', '', $table_name);
            error_log("CSV içe aktarma için tablo adı: $table_name");
            
            // CSV dosyasını aç
            $f = fopen($file_path, 'r');
            if (!$f) {
                return [false, "CSV dosyası açılamadı."];
            }
            
            // Başlık satırını oku
            $headers = fgetcsv($f);
            if (!$headers) {
                fclose($f);
                return [false, "CSV başlıkları okunamadı."];
            }
            
            // Tablo zaten var mı kontrol et
            error_log("CSV için tablo varlığı kontrol ediliyor: $table_name");
            $check_query = "SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = '$table_name'";
            $check_result = $db->query($check_query);
            $table_exists = $check_result->num_rows() > 0;
            error_log("CSV tablo kontrolü: " . ($table_exists ? "Tablo var" : "Tablo yok"));
            
            if (!$table_exists) {
                // Tablo yoksa, tablo yapısını oluştur
                $table_columns = array_map(function($col) {
                    return "\"$col\" VARCHAR(255)";
                }, $headers);
                
                $create_table_sql = "CREATE TABLE \"$table_name\" (\n  " . 
                                    implode(",\n  ", $table_columns) . "\n)";
                
                $db->query($create_table_sql);
            } else if ($replace_data) {
                // Tabloyu temizle
                $db->query("DELETE FROM \"$table_name\"");
            }
            
            // Veriyi ekle
            $db->begin_transaction();
            
            try {
                $quoted_headers = array_map(function($col) {
                    return "\"$col\"";
                }, $headers);
                
                $placeholders = array_fill(0, count($headers), '?');
                
                $insert_query = "INSERT INTO \"$table_name\" (" . 
                                implode(", ", $quoted_headers) . 
                                ") VALUES (" . implode(", ", $placeholders) . ")";
                
                $stmt = $db->prepare($insert_query);
                
                // CSV'den satır satır oku ve ekle
                while (($row = fgetcsv($f)) !== FALSE) {
                    if (count($row) != count($headers)) {
                        continue; // Sütun sayısı uyuşmuyorsa atla
                    }
                    
                    if ($stmt) {
                        $types = str_repeat('s', count($row));
                        $stmt->bind_param($types, ...$row);
                        $stmt->execute();
                    }
                }
                
                $db->commit();
                fclose($f);
                return [true, "CSV verisi başarıyla içe aktarıldı."];
            } catch (Exception $e) {
                $db->rollback();
                fclose($f);
                return [false, "CSV içe aktarma hatası: " . $e->getMessage()];
            }
        } else {
            error_log("Desteklenmeyen dosya formatı: " . $file_ext . " - dosya: " . basename($file_path));
            return [false, "Desteklenmeyen dosya formatı: " . $file_ext . " (Kabul edilen formatlar: zip, sql, json, csv)"];
        }
    } catch (Exception $e) {
        return [false, "İçe aktarma hatası: " . $e->getMessage()];
    }
}

// SQL dosyasını ayrı komutlara ayır
function parse_sql_file($content) {
    // SQL yorum satırlarını temizle (-- ile başlayan)
    $content = preg_replace("/--.*(\r\n|\n|\r)/", "\n", $content);
    
    // Basit yaklaşım: SQL dosyasını noktalı virgül ile ayır
    // Not: Karmaşık sorgular için yeterli olmayabilir
    error_log("parse_sql_file: SQL içeriği ayrıştırılıyor, boyut: " . strlen($content) . " bayt");
    
    $raw_queries = explode(';', $content);
    $queries = [];
    
    foreach ($raw_queries as $raw_query) {
        $query = trim($raw_query);
        if (!empty($query)) {
            // Sorgunun sonuna noktalı virgül ekle (son sorgu dışında)
            $queries[] = $query . ';';
        }
    }
    
    error_log("parse_sql_file: " . count($queries) . " sorgu ayrıştırıldı");
    
    return $queries;
}

// İşlem yönetimi
$message = '';
$message_type = 'success';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_POST['cleanup_backups'])) {
        $days = isset($_POST['cleanup_days']) ? intval($_POST['cleanup_days']) : 7;
        $keep_min = isset($_POST['cleanup_keep']) ? intval($_POST['cleanup_keep']) : 3;
        
        list($deleted_count, $freed_space) = cleanup_backups($days, $keep_min);
        
        if ($deleted_count > 0) {
            $message = "{$deleted_count} adet yedek dosyası temizlendi. " . format_file_size($freed_space) . " alan boşaltıldı.";
        } else {
            $message = "Silinecek eski yedek bulunamadı.";
        }
    }
    else if (isset($_POST['import_backup']) && isset($_FILES['import_file'])) {
        $file = $_FILES['import_file'];
        $replace_data = isset($_POST['replace_data']);
        
        if ($file['error'] === UPLOAD_ERR_OK) {
            $temp_path = $file['tmp_name'];
            list($success, $msg) = import_backup($temp_path, $replace_data);
            
            $message = $msg;
            $message_type = $success ? 'success' : 'danger';
        } else {
            $message = "Dosya yükleme hatası: " . $file['error'];
            $message_type = 'danger';
        }
    }
    else if (isset($_POST['create_backup'])) {
        $format = $_POST['format'] ?? 'sql';
        $with_drop = isset($_POST['with_drop']) ? true : false;
        $compress = isset($_POST['compress']) ? true : false;
        
        if ($format === 'full') {
            $backup_file = create_full_backup($with_drop);
            if ($backup_file) {
                $message = "Tam yedekleme başarıyla tamamlandı: " . basename($backup_file);
            } else {
                $message = "Yedekleme oluşturulurken bir hata oluştu.";
                $message_type = 'danger';
            }
        } elseif ($format === 'unified_sql') {
            // Yedekleme tipini belirle (tam, sadece tablolar, vs.)
            $export_type = isset($_POST['export_type']) ? $_POST['export_type'] : 'full';
            
            // Birleştirilmiş SQL yedeği oluştur
            $backup_file = generate_unified_sql_export($with_drop, $export_type);
            
            // Sıkıştırma isteği varsa
            if ($compress && $backup_file) {
                $zip_path = $backup_file . ".zip";
                $zip = new ZipArchive();
                if ($zip->open($zip_path, ZipArchive::CREATE) === TRUE) {
                    $zip->addFile($backup_file, basename($backup_file));
                    $zip->close();
                    // Orijinal dosyayı sil
                    unlink($backup_file);
                    $backup_file = $zip_path;
                }
            }
            
            if ($backup_file) {
                $message = "Birleştirilmiş SQL yedekleme başarıyla tamamlandı: " . basename($backup_file);
            } else {
                $message = "Birleştirilmiş SQL yedekleme oluşturulurken bir hata oluştu.";
                $message_type = 'danger';
            }
        } else {
            $table = $_POST['table'] ?? '';
            
            if ($table === 'all') {
                $files = export_all_tables($format, $with_drop, $compress);
                if (count($files) > 0) {
                    $message = count($files) . " tablo başarıyla yedeklendi.";
                } else {
                    $message = "Tablolar yedeklenirken bir hata oluştu.";
                    $message_type = 'danger';
                }
            } else {
                $file = export_table_data($table, $format, $with_drop, $compress);
                if ($file) {
                    $message = "Tablo başarıyla yedeklendi: " . basename($file);
                } else {
                    $message = "Tablo yedeklenirken bir hata oluştu.";
                    $message_type = 'danger';
                }
            }
        }
    } elseif (isset($_POST['create_code_backup'])) {
        $backup_file = backup_code();
        if ($backup_file) {
            $message = "Kod yedekleme başarıyla tamamlandı: " . basename($backup_file);
        } else {
            $message = "Kod yedekleme oluşturulurken bir hata oluştu.";
            $message_type = 'danger';
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
        <i class="bi bi-cloud-arrow-down"></i> Sistem Yedekleme
    </h2>

    <div class="alert alert-info mb-4">
        <div class="d-flex">
            <div class="me-3">
                <i class="bi bi-info-circle-fill fs-3"></i>
            </div>
            <div>
                <h5 class="alert-heading">Yedekleme Hakkında</h5>
                <p class="mb-0">Bu sayfa, veritabanı ve kaynak kod yedeklemesi yapmanıza olanak tanır. Düzenli yedekleme yaparak veri kaybını önleyebilirsiniz. Yedekler <code>export_data</code> klasöründe saklanır.</p>
            </div>
        </div>
    </div>
    
    <ul class="nav nav-tabs mb-4">
        <li class="nav-item">
            <a class="nav-link active" id="db-tab" data-bs-toggle="tab" href="#db-backup" role="tab">
                <i class="bi bi-database-fill-check"></i> Veritabanı Yedekleme
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link" id="code-tab" data-bs-toggle="tab" href="#code-backup" role="tab">
                <i class="bi bi-file-earmark-code"></i> Kaynak Kod Yedekleme
            </a>
        </li>
    </ul>
    
    <div class="tab-content">
        <div class="tab-pane fade show active" id="db-backup" role="tabpanel">
    
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
                                <option value="unified_sql">Birleştirilmiş SQL (Tek Dosya)</option>
                            </select>
                        </div>
                        
                        <div class="mb-3 export-type-options" style="display:none;">
                            <label for="export_type" class="form-label">Yedekleme İçeriği</label>
                            <select class="form-select" id="export_type" name="export_type">
                                <option value="full">Tam Yedek (Tablolar + Veriler + İlişkiler)</option>
                                <option value="tables_only">Sadece Tablo Yapıları</option>
                                <option value="data_only">Sadece Veriler</option>
                                <option value="dependencies_only">Sadece İlişkiler</option>
                                <option value="tables_dependencies">Tablolar ve İlişkiler (Veri Olmadan)</option>
                            </select>
                            <div class="form-text text-muted small">Yedekleme işleminin hangi öğeleri içereceğini belirler</div>
                        </div>
                        
                        <div class="mb-3 form-check">
                            <input type="checkbox" class="form-check-input" id="with_drop" name="with_drop">
                            <label class="form-check-label" for="with_drop">DROP TABLE komutlarını dahil et</label>
                            <div class="form-text text-muted small">Geri yükleme işleminde tablolar önce silinip sonra oluşturulur</div>
                        </div>
                        
                        <div class="mb-3 form-check">
                            <input type="checkbox" class="form-check-input" id="compress" name="compress" checked>
                            <label class="form-check-label" for="compress">ZIP olarak sıkıştır</label>
                            <div class="form-text text-muted small">Yedekleme dosyası ZIP formatında sıkıştırılarak kaydedilir</div>
                        </div>
                        
                        <button type="submit" name="create_backup" class="btn btn-primary">
                            <i class="bi bi-download"></i> Yedeklemeyi Başlat
                        </button>
                    </form>
                </div>
            </div>
            
            <div class="card">
                <div class="card-header">
                    <h5 class="card-title mb-0">Yedekleme İçe Aktar</h5>
                </div>
                <div class="card-body mb-4">
                    <form method="post" enctype="multipart/form-data">
                        <div class="mb-3">
                            <label for="import_file" class="form-label">Yedek Dosyası</label>
                            <input type="file" class="form-control" id="import_file" name="import_file" accept=".sql,.json,.zip,.csv">
                            <div class="form-text text-muted">
                                SQL, JSON, CSV veya ZIP formatında bir yedek dosyası seçin
                            </div>
                        </div>
                        
                        <div class="mb-3 form-check">
                            <input type="checkbox" class="form-check-input" id="replace_data" name="replace_data">
                            <label class="form-check-label" for="replace_data">Mevcut verileri tamamen değiştir</label>
                            <div class="form-text text-muted small">Bu seçenek etkinleştirildiğinde, geri yükleme sırasında tablo içeriği silinir</div>
                        </div>
                        
                        <div class="alert alert-warning">
                            <i class="bi bi-exclamation-triangle-fill"></i> Uyarı: Bu işlem, veritabanınızı seçilen yedek dosyasından geri yükleyecektir.
                        </div>
                        
                        <button type="submit" name="import_backup" class="btn btn-warning">
                            <i class="bi bi-upload"></i> Yedeği İçe Aktar
                        </button>
                    </form>
                </div>
                
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
                <div class="card-header d-flex justify-content-between align-items-center">
                    <h5 class="card-title mb-0">Mevcut Yedeklemeler</h5>
                    <form method="post" class="d-inline">
                        <button type="button" class="btn btn-sm btn-outline-warning" data-bs-toggle="modal" data-bs-target="#cleanupModal">
                            <i class="bi bi-trash"></i> Eski Yedekleri Temizle
                        </button>
                    </form>
                </div>
                <div class="card-body">
                    <!-- Temizleme Modal -->
                    <div class="modal fade" id="cleanupModal" tabindex="-1" aria-labelledby="cleanupModalLabel" aria-hidden="true">
                        <div class="modal-dialog">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <h5 class="modal-title" id="cleanupModalLabel">Eski Yedekleri Temizle</h5>
                                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                </div>
                                <form method="post">
                                    <div class="modal-body">
                                        <div class="mb-3">
                                            <label for="cleanup_days" class="form-label">Kaç günden eski yedekler silinsin?</label>
                                            <input type="number" class="form-control" id="cleanup_days" name="cleanup_days" value="7" min="1" max="365">
                                            <div class="form-text">Belirtilen günden daha eski yedekleri otomatik temizler.</div>
                                        </div>
                                        <div class="mb-3">
                                            <label for="cleanup_keep" class="form-label">En az kaç yedek korunsun?</label>
                                            <input type="number" class="form-control" id="cleanup_keep" name="cleanup_keep" value="3" min="1" max="20">
                                            <div class="form-text">Belirtilen sayıda en yeni yedekler her zaman korunur.</div>
                                        </div>
                                        
                                        <div class="alert alert-warning">
                                            <i class="bi bi-exclamation-triangle-fill"></i> Uyarı: Bu işlem, eski yedekleme dosyalarını kalıcı olarak silecektir.
                                        </div>
                                    </div>
                                    <div class="modal-footer">
                                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">İptal</button>
                                        <button type="submit" name="cleanup_backups" class="btn btn-warning">
                                            <i class="bi bi-trash"></i> Eski Yedekleri Temizle
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                    
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
        
        <div class="tab-pane fade" id="code-backup" role="tabpanel">
            <div class="row">
                <div class="col-md-6">
                    <div class="card mb-4">
                        <div class="card-header">
                            <h5 class="card-title mb-0">Kaynak Kod Yedekleme</h5>
                        </div>
                        <div class="card-body">
                            <form method="post">
                                <p class="mb-4">
                                    Bu işlem tüm uygulama kaynak kodunu yedekleyerek bir ZIP dosyası olarak indirilmesini sağlar.
                                    <br><br>
                                    <strong>Not:</strong> 
                                    <ul>
                                        <li>Yedekleme işlemi, tüm projeyi ZIP dosyası olarak sıkıştırır</li>
                                        <li>node_modules, vendor, .git gibi büyük klasörler hariç tutulur</li>
                                        <li>Yedekleme işlemi büyüklüğüne bağlı olarak biraz zaman alabilir</li>
                                    </ul>
                                </p>
                                
                                <button type="submit" name="create_code_backup" class="btn btn-primary">
                                    <i class="bi bi-file-earmark-zip"></i> Kaynak Kodu Yedekle
                                </button>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    // Format seçimine göre tablo seçimini ve yedekleme içeriği seçimini etkinleştir/devre dışı bırak
    const formatSelect = document.getElementById('format');
    const tableSelect = document.getElementById('table');
    const exportTypeOptions = document.querySelector('.export-type-options');
    
    // Sayfa yüklendiğinde format değerine göre görünürlüğü ayarla
    function updateVisibility() {
        if (formatSelect.value === 'full' || formatSelect.value === 'unified_sql') {
            tableSelect.value = 'all';
            tableSelect.disabled = true;
            
            // Eğer seçilen format unified_sql ise, yedekleme içeriği seçeneğini göster
            if (formatSelect.value === 'unified_sql') {
                exportTypeOptions.style.display = 'block';
            } else {
                exportTypeOptions.style.display = 'none';
            }
        } else {
            tableSelect.disabled = false;
            exportTypeOptions.style.display = 'none';
        }
    }
    
    // Sayfa yüklendiğinde initial görünürlüğü ayarla
    updateVisibility();
    
    // Format seçimi değiştiğinde görünürlüğü güncelle
    formatSelect.addEventListener('change', updateVisibility);
});
</script>