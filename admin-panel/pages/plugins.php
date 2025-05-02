<?php
// Yetki kontrolü
requireAdmin();

// Eklenti yöneticisini dahil et
require_once 'plugin_manager.php';

// Eklenti sistemi başlat
initPluginSystem($db);

// Eklenti etkinleştirme/devre dışı bırakma işlemi
if (isset($_POST['toggle_plugin'])) {
    $plugin_slug = $_POST['plugin_slug'] ?? '';
    $new_status = ($_POST['action'] == 'activate');
    
    if ($plugin_slug) {
        if (updatePluginStatus($db, $plugin_slug, $new_status)) {
            $action_text = $new_status ? 'etkinleştirildi' : 'devre dışı bırakıldı';
            $success_message = "Eklenti başarıyla $action_text.";
        } else {
            $error_message = "Eklenti durumu değiştirilirken bir hata oluştu.";
        }
    }
}

// Eklenti ayarlarını kaydet
if (isset($_POST['save_plugin_config'])) {
    $plugin_slug = $_POST['plugin_slug'] ?? '';
    
    if ($plugin_slug) {
        // Form verilerini al ve sadece ilgili eklentinin ayarlarını filtrele
        $config = [];
        foreach ($_POST as $key => $value) {
            if (strpos($key, 'plugin_' . $plugin_slug . '_') === 0) {
                $config_key = str_replace('plugin_' . $plugin_slug . '_', '', $key);
                $config[$config_key] = $value;
            }
        }
        
        if (savePluginConfig($db, $plugin_slug, $config)) {
            $success_message = "Eklenti ayarları kaydedildi.";
        } else {
            $error_message = "Eklenti ayarları kaydedilirken bir hata oluştu.";
        }
    }
}

// Tüm eklentileri yeniden tara
if (isset($_POST['rescan_plugins'])) {
    $results = scanAndRegisterPlugins($db);
    $success_message = "Eklentiler yeniden tarandı.";
}

// Tüm eklentileri al
$plugins = getAllPlugins($db);
?>

<div class="container-fluid py-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="mb-0">Eklenti Yönetimi</h1>
        <form method="post" action="">
            <button type="submit" name="rescan_plugins" class="btn btn-outline-primary">
                <i class="bi bi-arrow-repeat me-2"></i> Eklentileri Yeniden Tara
            </button>
        </form>
    </div>
    
    <?php if (isset($success_message)): ?>
        <div class="alert alert-success">
            <?php echo $success_message; ?>
        </div>
    <?php endif; ?>
    
    <?php if (isset($error_message)): ?>
        <div class="alert alert-danger">
            <?php echo $error_message; ?>
        </div>
    <?php endif; ?>
    
    <div class="row">
        <div class="col-12">
            <div class="card mb-4">
                <div class="card-header bg-light">
                    <strong>Yüklü Eklentiler</strong>
                </div>
                <div class="card-body">
                    <?php if (empty($plugins)): ?>
                        <div class="alert alert-info">
                            Henüz hiç eklenti bulunamadı. Sistem klasöründeki eklentileri tarayın veya yeni bir eklenti ekleyin.
                        </div>
                    <?php else: ?>
                        <div class="table-responsive">
                            <table class="table table-striped table-hover">
                                <thead>
                                    <tr>
                                        <th>Eklenti Adı</th>
                                        <th>Açıklama</th>
                                        <th>Versiyon</th>
                                        <th>Yazar</th>
                                        <th>Durum</th>
                                        <th>İşlemler</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <?php foreach ($plugins as $plugin): ?>
                                        <tr>
                                            <td><strong><?php echo htmlspecialchars($plugin['name']); ?></strong></td>
                                            <td><?php echo htmlspecialchars($plugin['description']); ?></td>
                                            <td><?php echo htmlspecialchars($plugin['version']); ?></td>
                                            <td><?php echo htmlspecialchars($plugin['author']); ?></td>
                                            <td>
                                                <?php if ($plugin['is_active']): ?>
                                                    <span class="badge bg-success">Aktif</span>
                                                <?php else: ?>
                                                    <span class="badge bg-secondary">Devre Dışı</span>
                                                <?php endif; ?>
                                            </td>
                                            <td>
                                                <form method="post" action="" class="d-inline">
                                                    <input type="hidden" name="plugin_slug" value="<?php echo htmlspecialchars($plugin['slug']); ?>">
                                                    
                                                    <?php if ($plugin['is_active']): ?>
                                                        <input type="hidden" name="action" value="deactivate">
                                                        <button type="submit" name="toggle_plugin" class="btn btn-sm btn-warning">
                                                            <i class="bi bi-power me-1"></i> Devre Dışı Bırak
                                                        </button>
                                                    <?php else: ?>
                                                        <input type="hidden" name="action" value="activate">
                                                        <button type="submit" name="toggle_plugin" class="btn btn-sm btn-success">
                                                            <i class="bi bi-power me-1"></i> Etkinleştir
                                                        </button>
                                                    <?php endif; ?>
                                                </form>
                                                
                                                <button type="button" class="btn btn-sm btn-primary" data-bs-toggle="modal" data-bs-target="#configModal<?php echo $plugin['id']; ?>">
                                                    <i class="bi bi-gear me-1"></i> Ayarlar
                                                </button>
                                            </td>
                                        </tr>
                                    <?php endforeach; ?>
                                </tbody>
                            </table>
                        </div>
                    <?php endif; ?>
                </div>
            </div>
            
            <div class="card">
                <div class="card-header bg-light">
                    <strong>Yeni Eklenti Yükleme</strong>
                </div>
                <div class="card-body">
                    <p>Yeni bir eklenti yüklemek için:</p>
                    <ol>
                        <li><code>/admin-panel/plugins/</code> klasörüne yeni bir klasör oluşturun (eklenti adı olacak şekilde)</li>
                        <li>Eklentinizin <code>info.php</code> dosyasını oluşturun (eklenti bilgileri)</li>
                        <li>Eklentinizin <code>main.php</code> dosyasını oluşturun (ana fonksiyonlar)</li>
                        <li>"Eklentileri Yeniden Tara" butonuna tıklayın</li>
                    </ol>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Eklenti Ayarları Modalları -->
<?php foreach ($plugins as $plugin): ?>
    <?php
    // Eklenti ayarlarını alma
    $plugin_config = getPluginConfig($db, $plugin['slug']);
    
    // Eklenti ayar şemasını alma
    $plugin_settings_file = __DIR__ . '/../plugins/' . $plugin['slug'] . '/settings.php';
    $plugin_settings = [];
    
    if (file_exists($plugin_settings_file)) {
        include $plugin_settings_file;
    }
    ?>
    <div class="modal fade" id="configModal<?php echo $plugin['id']; ?>" tabindex="-1" aria-labelledby="configModalLabel<?php echo $plugin['id']; ?>" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="configModalLabel<?php echo $plugin['id']; ?>"><?php echo htmlspecialchars($plugin['name']); ?> Ayarları</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Kapat"></button>
                </div>
                <form method="post" action="">
                    <div class="modal-body">
                        <input type="hidden" name="plugin_slug" value="<?php echo htmlspecialchars($plugin['slug']); ?>">
                        
                        <?php if (empty($plugin_settings)): ?>
                            <div class="alert alert-info">
                                Bu eklenti için ayarlanabilir parametre bulunamadı.
                            </div>
                        <?php else: ?>
                            <?php foreach ($plugin_settings as $setting_key => $setting): ?>
                                <div class="mb-3">
                                    <label for="plugin_<?php echo $plugin['slug']; ?>_<?php echo $setting_key; ?>" class="form-label"><?php echo htmlspecialchars($setting['label']); ?></label>
                                    
                                    <?php if ($setting['type'] == 'text' || $setting['type'] == 'number' || $setting['type'] == 'email'): ?>
                                        <input type="<?php echo $setting['type']; ?>" 
                                               class="form-control" 
                                               id="plugin_<?php echo $plugin['slug']; ?>_<?php echo $setting_key; ?>" 
                                               name="plugin_<?php echo $plugin['slug']; ?>_<?php echo $setting_key; ?>" 
                                               value="<?php echo htmlspecialchars($plugin_config[$setting_key] ?? $setting['default'] ?? ''); ?>"
                                               <?php echo isset($setting['required']) && $setting['required'] ? 'required' : ''; ?>>
                                    
                                    <?php elseif ($setting['type'] == 'textarea'): ?>
                                        <textarea class="form-control" 
                                                  id="plugin_<?php echo $plugin['slug']; ?>_<?php echo $setting_key; ?>" 
                                                  name="plugin_<?php echo $plugin['slug']; ?>_<?php echo $setting_key; ?>" 
                                                  rows="3"
                                                  <?php echo isset($setting['required']) && $setting['required'] ? 'required' : ''; ?>><?php echo htmlspecialchars($plugin_config[$setting_key] ?? $setting['default'] ?? ''); ?></textarea>
                                    
                                    <?php elseif ($setting['type'] == 'select'): ?>
                                        <select class="form-select" 
                                                id="plugin_<?php echo $plugin['slug']; ?>_<?php echo $setting_key; ?>" 
                                                name="plugin_<?php echo $plugin['slug']; ?>_<?php echo $setting_key; ?>"
                                                <?php echo isset($setting['required']) && $setting['required'] ? 'required' : ''; ?>>
                                            <?php foreach ($setting['options'] as $option_value => $option_label): ?>
                                                <option value="<?php echo htmlspecialchars($option_value); ?>" 
                                                        <?php echo (isset($plugin_config[$setting_key]) && $plugin_config[$setting_key] == $option_value) || 
                                                                  (!isset($plugin_config[$setting_key]) && isset($setting['default']) && $setting['default'] == $option_value) ? 'selected' : ''; ?>>
                                                    <?php echo htmlspecialchars($option_label); ?>
                                                </option>
                                            <?php endforeach; ?>
                                        </select>
                                    
                                    <?php elseif ($setting['type'] == 'checkbox'): ?>
                                        <div class="form-check">
                                            <input type="checkbox" 
                                                   class="form-check-input" 
                                                   id="plugin_<?php echo $plugin['slug']; ?>_<?php echo $setting_key; ?>" 
                                                   name="plugin_<?php echo $plugin['slug']; ?>_<?php echo $setting_key; ?>" 
                                                   value="1"
                                                   <?php echo (isset($plugin_config[$setting_key]) && $plugin_config[$setting_key]) || 
                                                             (!isset($plugin_config[$setting_key]) && isset($setting['default']) && $setting['default']) ? 'checked' : ''; ?>>
                                            <label class="form-check-label" for="plugin_<?php echo $plugin['slug']; ?>_<?php echo $setting_key; ?>">
                                                <?php echo htmlspecialchars($setting['label']); ?>
                                            </label>
                                        </div>
                                    <?php endif; ?>
                                    
                                    <?php if (isset($setting['description'])): ?>
                                        <div class="form-text"><?php echo htmlspecialchars($setting['description']); ?></div>
                                    <?php endif; ?>
                                </div>
                            <?php endforeach; ?>
                        <?php endif; ?>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Kapat</button>
                        <button type="submit" name="save_plugin_config" class="btn btn-primary">Ayarları Kaydet</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
<?php endforeach; ?>