<?php
// Bu sayfa, eklenti yönetimini sağlar
requireAdmin();

// Eklenti işlemleri
$success_message = '';
$error_message = '';

// Eklenti aktivasyon/deaktivasyon işlemleri
if (isset($_GET['action']) && isset($_GET['plugin'])) {
    $action = $_GET['action'];
    $plugin = $_GET['plugin'];
    
    switch ($action) {
        case 'activate':
            $result = $plugin_manager->activate_plugin($plugin);
            if ($result === true) {
                $success_message = "$plugin eklentisi başarıyla etkinleştirildi.";
            } else {
                $error_message = $result;
            }
            break;
            
        case 'deactivate':
            $result = $plugin_manager->deactivate_plugin($plugin);
            if ($result === true) {
                $success_message = "$plugin eklentisi başarıyla devre dışı bırakıldı.";
            } else {
                $error_message = $result;
            }
            break;
            
        case 'uninstall':
            $result = $plugin_manager->uninstall_plugin($plugin);
            if ($result === true) {
                $success_message = "$plugin eklentisi başarıyla kaldırıldı.";
            } else {
                $error_message = $result;
            }
            break;
    }
}

// Yüklü eklentileri al
$plugins = $plugin_manager->get_all_plugins();
?>

<div class="container-fluid py-4">
    <h1 class="mb-4">Eklenti Yönetimi</h1>
    
    <?php if ($success_message): ?>
        <div class="alert alert-success alert-dismissible fade show">
            <?= $success_message ?>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    <?php endif; ?>
    
    <?php if ($error_message): ?>
        <div class="alert alert-danger alert-dismissible fade show">
            <?= $error_message ?>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    <?php endif; ?>
    
    <div class="card">
        <div class="card-header d-flex justify-content-between align-items-center">
            <strong>Yüklü Eklentiler</strong>
            <span class="badge bg-primary"><?= count($plugins) ?> eklenti bulundu</span>
        </div>
        <div class="card-body">
            <?php if (empty($plugins)): ?>
                <div class="alert alert-info">
                    <i class="bi bi-info-circle me-2"></i> Henüz yüklü eklenti bulunmuyor.
                </div>
            <?php else: ?>
                <div class="table-responsive">
                    <table class="table table-striped table-hover">
                        <thead>
                            <tr>
                                <th>Eklenti</th>
                                <th>Açıklama</th>
                                <th>Versiyon</th>
                                <th>Yazar</th>
                                <th>Durum</th>
                                <th>İşlemler</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($plugins as $slug => $plugin): ?>
                                <tr>
                                    <td>
                                        <strong><?= htmlspecialchars($plugin['name']) ?></strong>
                                        <div class="text-muted small"><?= htmlspecialchars($slug) ?></div>
                                    </td>
                                    <td><?= htmlspecialchars($plugin['description'] ?? 'Açıklama yok') ?></td>
                                    <td><?= htmlspecialchars($plugin['version'] ?? '1.0.0') ?></td>
                                    <td><?= htmlspecialchars($plugin['author'] ?? 'Bilinmiyor') ?></td>
                                    <td>
                                        <?php if ($plugin['is_active']): ?>
                                            <span class="badge bg-success">Aktif</span>
                                        <?php else: ?>
                                            <span class="badge bg-secondary">Pasif</span>
                                        <?php endif; ?>
                                    </td>
                                    <td>
                                        <?php if ($plugin['is_active']): ?>
                                            <?php if (isset($plugin['settings_page']) && $plugin['settings_page']): ?>
                                                <a href="?page=<?= htmlspecialchars($plugin['settings_page']) ?>" class="btn btn-sm btn-info">
                                                    <i class="bi bi-gear"></i> Ayarlar
                                                </a>
                                            <?php endif; ?>
                                            <a href="?page=plugins&action=deactivate&plugin=<?= htmlspecialchars($slug) ?>" class="btn btn-sm btn-warning">
                                                <i class="bi bi-power"></i> Devre Dışı Bırak
                                            </a>
                                        <?php else: ?>
                                            <a href="?page=plugins&action=activate&plugin=<?= htmlspecialchars($slug) ?>" class="btn btn-sm btn-success">
                                                <i class="bi bi-check-circle"></i> Etkinleştir
                                            </a>
                                            <a href="?page=plugins&action=uninstall&plugin=<?= htmlspecialchars($slug) ?>" class="btn btn-sm btn-danger" onclick="return confirm('Bu eklentiyi kaldırmak istediğinizden emin misiniz?');">
                                                <i class="bi bi-trash"></i> Kaldır
                                            </a>
                                        <?php endif; ?>
                                    </td>
                                </tr>
                            <?php endforeach; ?>
                        </tbody>
                    </table>
                </div>
            <?php endif; ?>
        </div>
    </div>
    
    <div class="card mt-4">
        <div class="card-header">
            <strong>Eklenti Bilgileri</strong>
        </div>
        <div class="card-body">
            <p>Eklenti sistemi, ŞikayetVar platformuna yeni özellikler eklemenizi sağlar. Her eklenti, belirli bir işlevi yerine getiren bağımsız bir modüldür.</p>
            
            <h5 class="mt-3">Eklenti Nasıl Eklenir?</h5>
            <p>Yeni bir eklenti eklemek için, eklenti dosyalarını <code>admin-panel/plugins/</code> klasörüne yüklemeniz yeterlidir. Eklenti klasörü, eklentinin "slug" adını taşımalıdır.</p>
            
            <h5 class="mt-3">Eklenti Yapısı</h5>
            <p>Her eklenti aşağıdaki temel dosyalardan oluşmalıdır:</p>
            <ul>
                <li><code>info.php</code>: Eklenti meta bilgilerini içerir (ad, açıklama, versiyon, vb.)</li>
                <li><code>main.php</code>: Eklentinin ana kodu</li>
                <li><code>activate.php</code> (opsiyonel): Eklenti etkinleştirildiğinde çalıştırılacak kod</li>
                <li><code>deactivate.php</code> (opsiyonel): Eklenti devre dışı bırakıldığında çalıştırılacak kod</li>
                <li><code>uninstall.php</code> (opsiyonel): Eklenti kaldırıldığında çalıştırılacak kod</li>
                <li><code>templates/</code> (opsiyonel): Eklentinin şablon dosyalarını içeren klasör</li>
            </ul>
            
            <h5 class="mt-3">Aktif Eklentiler</h5>
            <p>Aktif eklentiler otomatik olarak yüklenir ve tüm sayfalar için kullanılabilir olur. Bir eklentiyi devre dışı bırakmak, işlevselliğini geçici olarak durdurur ancak ayarlarını ve verilerini silmez.</p>
        </div>
    </div>
</div>