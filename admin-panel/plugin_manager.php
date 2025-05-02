<?php
/**
 * ŞikayetVar Platform - Eklenti Yönetim Sistemi
 * 
 * Bu dosya, modüler eklenti sistemini yönetir.
 * Eklentiler admin panelden açılıp kapatılabilir.
 */

// Eklenti durumlarını saklayacak tablonun adı
define('PLUGINS_TABLE', 'plugins');

/**
 * Eklenti tablosunun varlığını kontrol eder ve gerekirse oluşturur
 * 
 * @param mysqli $db Veritabanı bağlantısı
 * @return bool İşlem başarılı mı
 */
function ensurePluginsTable($db) {
    // Eklenti tablosu için SQL
    $pluginsSQL = "CREATE TABLE " . PLUGINS_TABLE . " (
        id SERIAL PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        slug VARCHAR(50) NOT NULL UNIQUE,
        description TEXT,
        version VARCHAR(20) NOT NULL,
        author VARCHAR(100),
        is_active BOOLEAN DEFAULT FALSE,
        config TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )";
    
    // Tablo var mı diye kontrol et
    $checkTableSQL = "SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = ?
    )";
    
    try {
        $stmt = $db->prepare($checkTableSQL);
        $tableName = PLUGINS_TABLE;
        $stmt->bind_param('s', $tableName);
        $stmt->execute();
        $result = $stmt->get_result();
        $tableExists = $result->fetch_assoc()['exists'] ?? false;
        
        if (!$tableExists) {
            error_log("Eklenti tablosu bulunamadı, oluşturuluyor...");
            
            $success = $db->query($pluginsSQL);
            
            if (!$success) {
                error_log("HATA: Eklenti tablosu oluşturulamadı: " . $db->error);
                return false;
            }
            
            error_log("BAŞARILI: Eklenti tablosu oluşturuldu");
            return true;
        } else {
            error_log("Eklenti tablosu mevcut.");
            return true;
        }
    } catch (Exception $e) {
        error_log("HATA: Eklenti tablosu varlık kontrolünde hata: " . $e->getMessage());
        return false;
    }
}

/**
 * Sistemdeki tüm eklentileri tarar ve veritabanında kayıtlı olmayan yeni
 * eklentileri ekler
 * 
 * @param mysqli $db Veritabanı bağlantısı
 * @return array İşlem sonuçları
 */
function scanAndRegisterPlugins($db) {
    $results = [];
    $pluginsDir = __DIR__ . '/plugins';
    
    // Eklenti klasörü var mı kontrol et
    if (!is_dir($pluginsDir)) {
        mkdir($pluginsDir, 0755, true);
    }
    
    // Eklenti klasöründeki tüm alt klasörleri bul
    $pluginFolders = array_filter(glob($pluginsDir . '/*'), 'is_dir');
    
    // Veritabanındaki mevcut eklentileri al
    $existingPlugins = [];
    $query = "SELECT slug FROM " . PLUGINS_TABLE;
    $result = $db->query($query);
    
    if ($result) {
        while ($row = $result->fetch_assoc()) {
            $existingPlugins[] = $row['slug'];
        }
    }
    
    // Her eklenti klasörü için info.php dosyasını kontrol et
    foreach ($pluginFolders as $pluginFolder) {
        $pluginInfoFile = $pluginFolder . '/info.php';
        
        if (file_exists($pluginInfoFile)) {
            include $pluginInfoFile;
            
            if (isset($plugin_info) && is_array($plugin_info)) {
                // Eklenti bilgilerini al
                $name = $plugin_info['name'] ?? '';
                $slug = $plugin_info['slug'] ?? basename($pluginFolder);
                $description = $plugin_info['description'] ?? '';
                $version = $plugin_info['version'] ?? '1.0.0';
                $author = $plugin_info['author'] ?? '';
                
                // Eklenti veritabanında kayıtlı değilse ekle
                if (!in_array($slug, $existingPlugins)) {
                    $insertQuery = "INSERT INTO " . PLUGINS_TABLE . " 
                                  (name, slug, description, version, author, is_active) 
                                  VALUES (?, ?, ?, ?, ?, FALSE)";
                    
                    $stmt = $db->prepare($insertQuery);
                    $stmt->bind_param('sssss', $name, $slug, $description, $version, $author);
                    
                    if ($stmt->execute()) {
                        $results[$slug] = "Yeni eklenti kaydedildi: $name";
                        error_log("Eklenti sistemi: Yeni eklenti kaydedildi: $name ($slug)");
                    } else {
                        $results[$slug] = "Eklenti kayıt hatası: " . $db->error;
                        error_log("Eklenti sistemi: Kayıt hatası: $slug, " . $db->error);
                    }
                } else {
                    // Eklenti zaten kayıtlı, gerekirse versiyonu güncelle
                    $updateQuery = "UPDATE " . PLUGINS_TABLE . " SET version = ?, updated_at = NOW() WHERE slug = ?";
                    $stmt = $db->prepare($updateQuery);
                    $stmt->bind_param('ss', $version, $slug);
                    $stmt->execute();
                }
                
                // global $plugin_info değişkenini temizle
                unset($plugin_info);
            } else {
                $results[basename($pluginFolder)] = "Hatalı eklenti bilgi dosyası";
                error_log("Eklenti sistemi: Hatalı eklenti bilgi dosyası: $pluginInfoFile");
            }
        } else {
            $results[basename($pluginFolder)] = "Eklenti bilgi dosyası bulunamadı";
            error_log("Eklenti sistemi: Eklenti bilgi dosyası bulunamadı: $pluginInfoFile");
        }
    }
    
    // Veritabanında kayıtlı olup klasörde bulunmayan eklentileri işaretle
    $missingPlugins = array_diff($existingPlugins, array_map('basename', $pluginFolders));
    
    foreach ($missingPlugins as $missingSlug) {
        $updateQuery = "UPDATE " . PLUGINS_TABLE . " SET is_active = FALSE WHERE slug = ?";
        $stmt = $db->prepare($updateQuery);
        $stmt->bind_param('s', $missingSlug);
        $stmt->execute();
        
        $results[$missingSlug] = "Eklenti klasörü eksik, devre dışı bırakıldı";
        error_log("Eklenti sistemi: Eksik eklenti klasörü: $missingSlug, devre dışı bırakıldı");
    }
    
    return $results;
}

/**
 * Tüm aktif eklentileri yükler
 * 
 * @param mysqli $db Veritabanı bağlantısı
 * @return array Yüklenen eklentiler
 */
function loadActivePlugins($db) {
    $loadedPlugins = [];
    
    // Aktif eklentileri veritabanından al
    $query = "SELECT name, slug, version FROM " . PLUGINS_TABLE . " WHERE is_active = TRUE";
    $result = $db->query($query);
    
    if ($result) {
        while ($plugin = $result->fetch_assoc()) {
            $pluginMainFile = __DIR__ . '/plugins/' . $plugin['slug'] . '/main.php';
            
            if (file_exists($pluginMainFile)) {
                include_once $pluginMainFile;
                $loadedPlugins[] = $plugin;
                error_log("Eklenti yüklendi: " . $plugin['name'] . " (" . $plugin['version'] . ")");
            } else {
                error_log("HATA: Eklenti ana dosyası bulunamadı: " . $pluginMainFile);
            }
        }
    }
    
    return $loadedPlugins;
}

/**
 * Eklenti durumunu değiştirir (etkinleştir/devre dışı bırak)
 * 
 * @param mysqli $db Veritabanı bağlantısı
 * @param string $slug Eklenti slug'ı
 * @param bool $status Eklenti durumu
 * @return bool İşlem başarılı mı
 */
function updatePluginStatus($db, $slug, $status) {
    $query = "UPDATE " . PLUGINS_TABLE . " SET is_active = ?, updated_at = NOW() WHERE slug = ?";
    $stmt = $db->prepare($query);
    $isActive = $status ? 1 : 0;
    $stmt->bind_param('is', $isActive, $slug);
    
    if ($stmt->execute()) {
        $actionText = $status ? "etkinleştirildi" : "devre dışı bırakıldı";
        error_log("Eklenti $slug $actionText");
        return true;
    } else {
        error_log("Eklenti durum güncelleme hatası: " . $db->error);
        return false;
    }
}

/**
 * Tüm kayıtlı eklentileri döndürür
 * 
 * @param mysqli $db Veritabanı bağlantısı
 * @return array Eklenti listesi
 */
function getAllPlugins($db) {
    $plugins = [];
    
    $query = "SELECT * FROM " . PLUGINS_TABLE . " ORDER BY name ASC";
    $result = $db->query($query);
    
    if ($result) {
        while ($row = $result->fetch_assoc()) {
            $plugins[] = $row;
        }
    }
    
    return $plugins;
}

/**
 * Bir eklentinin aktif olup olmadığını kontrol eder
 * 
 * @param mysqli $db Veritabanı bağlantısı
 * @param string $slug Eklenti slug'ı
 * @return bool Eklenti aktif mi
 */
function isPluginActive($db, $slug) {
    $query = "SELECT is_active FROM " . PLUGINS_TABLE . " WHERE slug = ?";
    $stmt = $db->prepare($query);
    $stmt->bind_param('s', $slug);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result && $row = $result->fetch_assoc()) {
        return (bool)$row['is_active'];
    }
    
    return false;
}

/**
 * Bir eklentinin ayarlarını kaydeder
 * 
 * @param mysqli $db Veritabanı bağlantısı
 * @param string $slug Eklenti slug'ı
 * @param array $config Eklenti ayarları
 * @return bool İşlem başarılı mı
 */
function savePluginConfig($db, $slug, $config) {
    $configJson = json_encode($config);
    $query = "UPDATE " . PLUGINS_TABLE . " SET config = ?, updated_at = NOW() WHERE slug = ?";
    $stmt = $db->prepare($query);
    $stmt->bind_param('ss', $configJson, $slug);
    
    if ($stmt->execute()) {
        error_log("Eklenti $slug ayarları kaydedildi");
        return true;
    } else {
        error_log("Eklenti ayarları kaydedilirken hata: " . $db->error);
        return false;
    }
}

/**
 * Bir eklentinin ayarlarını döndürür
 * 
 * @param mysqli $db Veritabanı bağlantısı
 * @param string $slug Eklenti slug'ı
 * @return array Eklenti ayarları
 */
function getPluginConfig($db, $slug) {
    $query = "SELECT config FROM " . PLUGINS_TABLE . " WHERE slug = ?";
    $stmt = $db->prepare($query);
    $stmt->bind_param('s', $slug);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result && $row = $result->fetch_assoc()) {
        return json_decode($row['config'], true) ?? [];
    }
    
    return [];
}

// Eklenti sisteminin başlatılması
function initPluginSystem($db) {
    // Eklenti tablosunu kontrol et
    if (!ensurePluginsTable($db)) {
        error_log("Eklenti sistemi başlatılamadı: Tablo oluşturma hatası");
        return false;
    }
    
    // Eklentileri tara ve kaydet
    scanAndRegisterPlugins($db);
    
    // Aktif eklentileri yükle
    loadActivePlugins($db);
    
    return true;
}

// Admin menüsüne eklenti yönetim sayfası ekler
function addPluginManagementToMenu() {
    // Bu fonksiyon index.php'de sidebar menüsü oluşturulurken çağrılır
    return '
    <div class="menu-group">
        <div class="menu-title ps-3 pt-2">Eklentiler</div>
        <div><a href="index.php?page=plugins" class="' . ($_GET['page'] ?? '' === 'plugins' ? 'active' : '') . '"><i class="bi bi-puzzle me-2"></i> Eklenti Yönetimi</a></div>
    </div>';
}
?>