<?php
/**
 * ŞikayetVar Eklenti Yönetim Sistemi - PostgreSQL Sürümü
 * 
 * Bu sınıf, eklentilerin kurulumu, etkinleştirilmesi, devre dışı bırakılması
 * ve kaldırılmasından sorumludur. Ayrıca eklenti ayarlarını da yönetir.
 */

class PluginManager {
    private $db;
    private $plugins_dir;
    private $active_plugins = [];
    private $installed_plugins = [];
    
    /**
     * Eklenti yöneticisini başlatır
     * 
     * @param object $db Veritabanı bağlantısı
     */
    public function __construct($db) {
        $this->db = $db;
        $this->plugins_dir = __DIR__ . '/plugins';
        $this->load_active_plugins();
        $this->scan_plugins_directory();
    }
    
    /**
     * Aktif eklentileri veritabanından yükler
     */
    private function load_active_plugins() {
        try {
            $result = $this->db->query("SELECT slug FROM plugins WHERE is_active = TRUE");
            
            if ($result) {
                $rows = pg_fetch_all($result);
                if (is_array($rows)) {
                    foreach ($rows as $row) {
                        $this->active_plugins[] = $row['slug'];
                    }
                }
            }
        } catch (Exception $e) {
            // Muhtemelen tablo henüz oluşturulmadı
        }
    }
    
    /**
     * Eklenti dizinini tarar ve yüklü eklentileri bulur
     */
    private function scan_plugins_directory() {
        if (!file_exists($this->plugins_dir)) {
            mkdir($this->plugins_dir, 0755, true);
            return;
        }
        
        $plugin_folders = array_filter(glob($this->plugins_dir . '/*'), 'is_dir');
        
        foreach ($plugin_folders as $plugin_folder) {
            $plugin_slug = basename($plugin_folder);
            $plugin_file = $plugin_folder . '/info.php';
            
            if (file_exists($plugin_file)) {
                $plugin_data = include($plugin_file);
                if (is_array($plugin_data) && isset($plugin_data['name'])) {
                    $this->installed_plugins[$plugin_slug] = $plugin_data;
                }
            }
        }
    }
    
    /**
     * Eklenti var mı diye kontrol eder
     * 
     * @param string $slug Eklenti slug
     * @return bool Eklenti var mı?
     */
    public function plugin_exists($slug) {
        return isset($this->installed_plugins[$slug]);
    }
    
    /**
     * Eklenti aktif mi diye kontrol eder
     * 
     * @param string $slug Eklenti slug
     * @return bool Eklenti aktif mi?
     */
    public function is_plugin_active($slug) {
        return in_array($slug, $this->active_plugins);
    }
    
    /**
     * Tüm yüklü eklentileri döndürür
     * 
     * @return array Yüklü eklentiler
     */
    public function get_all_plugins() {
        $plugins = [];
        
        foreach ($this->installed_plugins as $slug => $data) {
            $plugins[$slug] = array_merge($data, [
                'slug' => $slug,
                'is_active' => $this->is_plugin_active($slug)
            ]);
        }
        
        return $plugins;
    }
    
    /**
     * Eklentiyi kurar
     * 
     * @param string $slug Eklenti slug
     * @return bool|string Başarılı mı? Hata durumunda hata mesajı döner
     */
    public function install_plugin($slug) {
        if (!$this->plugin_exists($slug)) {
            return "Eklenti bulunamadı: $slug";
        }
        
        // Eklenti zaten yüklü mü kontrol et
        $result = $this->db->query("SELECT * FROM plugins WHERE slug = '" . $this->db->escape_string($slug) . "'");
        
        if ($result && pg_num_rows($result) > 0) {
            return "Eklenti zaten kurulu: $slug";
        }
        
        // Eklenti bilgilerini al
        $plugin_data = $this->installed_plugins[$slug];
        
        // Eklenti tablosuna ekle
        $query = "INSERT INTO plugins (name, slug, description, version, author, is_active) VALUES ($1, $2, $3, $4, $5, FALSE)";
        $params = [
            $plugin_data['name'],
            $slug,
            $plugin_data['description'] ?? '',
            $plugin_data['version'] ?? '1.0.0',
            $plugin_data['author'] ?? 'ŞikayetVar'
        ];
        
        $result = pg_query_params($this->db->connection, $query, $params);
        
        if (!$result) {
            return "Yükleme hatası: " . pg_last_error($this->db->connection);
        }
        
        return true;
    }
    
    /**
     * Eklentiyi etkinleştirir
     * 
     * @param string $slug Eklenti slug
     * @return bool|string Başarılı mı? Hata durumunda hata mesajı döner
     */
    public function activate_plugin($slug) {
        if (!$this->plugin_exists($slug)) {
            return "Eklenti bulunamadı: $slug";
        }
        
        // Eklenti yüklü mü kontrol et
        $result = $this->db->query("SELECT * FROM plugins WHERE slug = '" . $this->db->escape_string($slug) . "'");
        
        if ($result && pg_num_rows($result) === 0) {
            // Yüklü değilse, önce yükle
            $install_result = $this->install_plugin($slug);
            if ($install_result !== true) {
                return $install_result;
            }
        }
        
        // Eklentiyi etkinleştir
        $query = "UPDATE plugins SET is_active = TRUE WHERE slug = $1";
        $params = [$slug];
        
        $result = pg_query_params($this->db->connection, $query, $params);
        
        if (!$result) {
            return "Etkinleştirme hatası: " . pg_last_error($this->db->connection);
        }
        
        $affected = pg_affected_rows($result);
        
        // Etkinleştirme işlemi başarılı mı kontrol et
        if ($affected > 0) {
            // Aktif eklentiler listesine ekle
            if (!in_array($slug, $this->active_plugins)) {
                $this->active_plugins[] = $slug;
            }
            
            // Eklentinin etkinleştirme fonksiyonunu çağır
            $activate_file = $this->plugins_dir . '/' . $slug . '/activate.php';
            if (file_exists($activate_file)) {
                include($activate_file);
                if (function_exists($slug . '_activate')) {
                    call_user_func($slug . '_activate', $this->db);
                }
            }
            
            return true;
        } else {
            return "Eklenti etkinleştirilemedi: $slug";
        }
    }
    
    /**
     * Eklentiyi devre dışı bırakır
     * 
     * @param string $slug Eklenti slug
     * @return bool|string Başarılı mı? Hata durumunda hata mesajı döner
     */
    public function deactivate_plugin($slug) {
        if (!$this->plugin_exists($slug)) {
            return "Eklenti bulunamadı: $slug";
        }
        
        // Eklentiyi devre dışı bırak
        $query = "UPDATE plugins SET is_active = FALSE WHERE slug = $1";
        $params = [$slug];
        
        $result = pg_query_params($this->db->connection, $query, $params);
        
        if (!$result) {
            return "Devre dışı bırakma hatası: " . pg_last_error($this->db->connection);
        }
        
        $affected = pg_affected_rows($result);
        
        // Devre dışı bırakma işlemi başarılı mı kontrol et
        if ($affected > 0) {
            // Aktif eklentiler listesinden çıkar
            $key = array_search($slug, $this->active_plugins);
            if ($key !== false) {
                unset($this->active_plugins[$key]);
            }
            
            // Eklentinin devre dışı bırakma fonksiyonunu çağır
            $deactivate_file = $this->plugins_dir . '/' . $slug . '/deactivate.php';
            if (file_exists($deactivate_file)) {
                include($deactivate_file);
                if (function_exists($slug . '_deactivate')) {
                    call_user_func($slug . '_deactivate', $this->db);
                }
            }
            
            return true;
        } else {
            return "Eklenti devre dışı bırakılamadı: $slug";
        }
    }
    
    /**
     * Eklentiyi kaldırır
     * 
     * @param string $slug Eklenti slug
     * @return bool|string Başarılı mı? Hata durumunda hata mesajı döner
     */
    public function uninstall_plugin($slug) {
        if (!$this->plugin_exists($slug)) {
            return "Eklenti bulunamadı: $slug";
        }
        
        // Eklenti aktifse, önce devre dışı bırak
        if ($this->is_plugin_active($slug)) {
            $deactivate_result = $this->deactivate_plugin($slug);
            if ($deactivate_result !== true) {
                return $deactivate_result;
            }
        }
        
        // Eklentiyi kaldır
        $query = "DELETE FROM plugins WHERE slug = $1";
        $params = [$slug];
        
        $result = pg_query_params($this->db->connection, $query, $params);
        
        if (!$result) {
            return "Kaldırma hatası: " . pg_last_error($this->db->connection);
        }
        
        $affected = pg_affected_rows($result);
        
        // Kaldırma işlemi başarılı mı kontrol et
        if ($affected > 0) {
            // Eklentinin kaldırma fonksiyonunu çağır
            $uninstall_file = $this->plugins_dir . '/' . $slug . '/uninstall.php';
            if (file_exists($uninstall_file)) {
                include($uninstall_file);
                if (function_exists($slug . '_uninstall')) {
                    call_user_func($slug . '_uninstall', $this->db);
                }
            }
            
            return true;
        } else {
            return "Eklenti kaldırılamadı: $slug";
        }
    }
    
    /**
     * Eklenti ayarlarını getirir
     * 
     * @param string $slug Eklenti slug
     * @return array|null Eklenti ayarları
     */
    public function get_plugin_settings($slug) {
        if (!$this->plugin_exists($slug)) {
            return null;
        }
        
        $query = "SELECT config FROM plugins WHERE slug = $1";
        $params = [$slug];
        
        $result = pg_query_params($this->db->connection, $query, $params);
        
        if ($result && pg_num_rows($result) > 0) {
            $row = pg_fetch_assoc($result);
            return json_decode($row['config'], true) ?? [];
        }
        
        return [];
    }
    
    /**
     * Eklenti ayarlarını kaydeder
     * 
     * @param string $slug Eklenti slug
     * @param array $settings Ayarlar
     * @return bool Başarılı mı?
     */
    public function save_plugin_settings($slug, $settings) {
        if (!$this->plugin_exists($slug)) {
            return false;
        }
        
        $json_settings = json_encode($settings);
        
        $query = "UPDATE plugins SET config = $1 WHERE slug = $2";
        $params = [$json_settings, $slug];
        
        $result = pg_query_params($this->db->connection, $query, $params);
        
        if (!$result) {
            return false;
        }
        
        return pg_affected_rows($result) > 0;
    }
    
    /**
     * Aktif eklentileri yükler
     */
    public function load_active_plugins_files() {
        foreach ($this->active_plugins as $slug) {
            $main_file = $this->plugins_dir . '/' . $slug . '/main.php';
            if (file_exists($main_file)) {
                include_once($main_file);
            }
        }
    }
}

// Yardımcı fonksiyonlar

/**
 * Eklentinin aktif olup olmadığını kontrol eder
 * 
 * @param object $db Veritabanı bağlantısı
 * @param string $slug Eklenti slug
 * @return bool Eklenti aktif mi?
 */
function isPluginActive($db, $slug) {
    $query = "SELECT name, slug, version FROM plugins WHERE is_active = TRUE AND slug = $1";
    $params = [$slug];
    
    $result = pg_query_params($db->connection, $query, $params);
    
    return ($result && pg_num_rows($result) > 0);
}

/**
 * Aktif eklenti listesini döndürür
 * 
 * @param object $db Veritabanı bağlantısı
 * @return array Aktif eklentiler
 */
function getActivePlugins($db) {
    $active_plugins = [];
    
    $query = "SELECT name, slug, version FROM plugins WHERE is_active = TRUE";
    $result = pg_query($db->connection, $query);
    
    if ($result && pg_num_rows($result) > 0) {
        while ($row = pg_fetch_assoc($result)) {
            $active_plugins[] = $row;
        }
    }
    
    return $active_plugins;
}

// Menü ve sayfa yönetimi için fonksiyonlar
$menu_items = [];
$page_routes = [];
$api_route_actions = [];

/**
 * Menüye öğe ekler
 * 
 * @param array $item Menü öğesi bilgileri (page, title, icon, order)
 */
function add_menu_item($item) {
    global $menu_items;
    $menu_items[] = $item;
}

/**
 * Menü öğelerini döndürür
 * 
 * @return array Menü öğeleri
 */
function get_menu_items() {
    global $menu_items;
    
    // Sıralama
    usort($menu_items, function($a, $b) {
        return ($a['order'] ?? 99) - ($b['order'] ?? 99);
    });
    
    return $menu_items;
}

/**
 * Sayfa rotası ekler
 * 
 * @param string $page Sayfa adı
 * @param callable $callback Çağrılacak fonksiyon
 */
function add_page_route($page, $callback) {
    global $page_routes;
    $page_routes[$page] = $callback;
}

/**
 * Sayfa rotasını döndürür
 * 
 * @param string $page Sayfa adı
 * @return callable|null Çağrılacak fonksiyon
 */
function get_page_route($page) {
    global $page_routes;
    return $page_routes[$page] ?? null;
}

/**
 * API rotası için eylem ekler
 * 
 * @param string $hook Kanca adı
 * @param callable $callback Çağrılacak fonksiyon
 */
function add_action($hook, $callback) {
    global $api_route_actions;
    if (!isset($api_route_actions[$hook])) {
        $api_route_actions[$hook] = [];
    }
    $api_route_actions[$hook][] = $callback;
}

/**
 * API rotası eylemlerini çalıştırır
 * 
 * @param string $hook Kanca adı
 */
function do_action($hook) {
    global $api_route_actions;
    if (isset($api_route_actions[$hook])) {
        foreach ($api_route_actions[$hook] as $callback) {
            call_user_func($callback);
        }
    }
}

// Eklenti dizinini oluştur
$plugins_dir = __DIR__ . '/plugins';
if (!file_exists($plugins_dir)) {
    mkdir($plugins_dir, 0755, true);
}

// Eklenti yöneticisini başlat
$plugin_manager = new PluginManager($db);