<?php
// Şikayetler (Paylaşımlar) Sayfası

// Durum güncellemesi
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['update_post'])) {
    $postId = $_POST['post_id'];
    $status = $_POST['status'];
    $adminComment = $_POST['admin_comment'];
    
    try {
        $stmt = $db->prepare("UPDATE posts SET status = ?, admin_comment = ?, updated_at = NOW() WHERE id = ?");
        $stmt->bind_param("ssi", $status, $adminComment, $postId);
        $stmt->execute();
        
        if ($stmt->affected_rows > 0) {
            echo '<div class="alert alert-success">Paylaşım durumu başarıyla güncellendi.</div>';
        } else {
            echo '<div class="alert alert-info">Herhangi bir değişiklik yapılmadı.</div>';
        }
    } catch (Exception $e) {
        echo '<div class="alert alert-danger">Hata oluştu: ' . $e->getMessage() . '</div>';
    }
} elseif (isset($_GET['op']) && $_GET['op'] == 'delete' && isset($_GET['id'])) {
    $postId = $_GET['id'];
    
    try {
        $stmt = $db->prepare("DELETE FROM posts WHERE id = ?");
        $stmt->bind_param("i", $postId);
        $stmt->execute();
        
        if ($stmt->affected_rows > 0) {
            echo '<div class="alert alert-success">Paylaşım başarıyla silindi.</div>';
        } else {
            echo '<div class="alert alert-info">Paylaşım bulunamadı veya silinemedi.</div>';
        }
    } catch (Exception $e) {
        echo '<div class="alert alert-danger">Hata oluştu: ' . $e->getMessage() . '</div>';
    }
}

// Paylaşım Düzenleme Ekranı
if (isset($_GET['op']) && $_GET['op'] == 'edit' && isset($_GET['id'])) {
    $postId = $_GET['id'];
    
    try {
        $stmt = $db->prepare("
            SELECT p.*, u.username, c.name as category_name, 
                   ct.name as city_name, d.name as district_name 
            FROM posts p
            LEFT JOIN users u ON p.user_id = u.id
            LEFT JOIN categories c ON p.category_id = c.id
            LEFT JOIN cities ct ON p.city_id = ct.id
            LEFT JOIN districts d ON p.district_id = d.id
            WHERE p.id = ?
        ");
        $stmt->bind_param("i", $postId);
        $stmt->execute();
        $result = $stmt->get_result();
        
        if ($result->num_rows > 0) {
            $post = $result->fetch_assoc();
            ?>
            <div class="container-fluid mt-4">
                <div class="card shadow mb-4">
                    <div class="card-header py-3">
                        <h6 class="m-0 font-weight-bold text-primary">Paylaşım #<?php echo $post['id']; ?> Düzenle</h6>
                    </div>
                    <div class="card-body">
                        <div class="row mb-4">
                            <div class="col-md-6">
                                <h5><?php echo $post['title']; ?></h5>
                                <p><?php echo $post['content']; ?></p>
                                <?php if (!empty($post['image_url'])) { ?>
                                    <div class="mb-3">
                                        <img src="<?php echo $post['image_url']; ?>" alt="Paylaşım Görseli" class="img-fluid" style="max-height: 300px;">
                                    </div>
                                <?php } ?>
                            </div>
                            <div class="col-md-6">
                                <div class="card">
                                    <div class="card-header">
                                        <h6 class="mb-0">Paylaşım Bilgileri</h6>
                                    </div>
                                    <div class="card-body">
                                        <ul class="list-group list-group-flush">
                                            <li class="list-group-item d-flex justify-content-between align-items-center">
                                                <strong>Kullanıcı:</strong>
                                                <span><?php echo $post['username']; ?></span>
                                            </li>
                                            <li class="list-group-item d-flex justify-content-between align-items-center">
                                                <strong>Kategori:</strong>
                                                <span><?php echo $post['category_name']; ?></span>
                                            </li>
                                            <li class="list-group-item d-flex justify-content-between align-items-center">
                                                <strong>Şehir:</strong>
                                                <span><?php echo $post['city_name']; ?></span>
                                            </li>
                                            <li class="list-group-item d-flex justify-content-between align-items-center">
                                                <strong>İlçe:</strong>
                                                <span><?php echo $post['district_name']; ?></span>
                                            </li>
                                            <li class="list-group-item d-flex justify-content-between align-items-center">
                                                <strong>Durum:</strong>
                                                <span class="badge bg-<?php echo getStatusColor($post['status']); ?>">
                                                    <?php echo formatStatus($post['status']); ?>
                                                </span>
                                            </li>
                                            <li class="list-group-item d-flex justify-content-between align-items-center">
                                                <strong>Beğeni:</strong>
                                                <span><?php echo $post['likes']; ?></span>
                                            </li>
                                            <li class="list-group-item d-flex justify-content-between align-items-center">
                                                <strong>Görüntülenme:</strong>
                                                <span><?php echo $post['views']; ?></span>
                                            </li>
                                            <li class="list-group-item d-flex justify-content-between align-items-center">
                                                <strong>Tür:</strong>
                                                <span><?php echo formatPostType($post['type']); ?></span>
                                            </li>
                                            <li class="list-group-item d-flex justify-content-between align-items-center">
                                                <strong>Kapsam:</strong>
                                                <span><?php echo formatScope($post['scope']); ?></span>
                                            </li>
                                            <li class="list-group-item d-flex justify-content-between align-items-center">
                                                <strong>Oluşturma Tarihi:</strong>
                                                <span><?php echo date('d.m.Y H:i', strtotime($post['created_at'])); ?></span>
                                            </li>
                                        </ul>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <form method="post" action="?page=posts">
                            <input type="hidden" name="post_id" value="<?php echo $post['id']; ?>">
                            
                            <div class="mb-3">
                                <label for="status" class="form-label">Durum</label>
                                <select class="form-select" id="status" name="status" required>
                                    <option value="awaitingSolution" <?php echo ($post['status'] == 'awaitingSolution') ? 'selected' : ''; ?>>Çözüm Bekliyor</option>
                                    <option value="inProgress" <?php echo ($post['status'] == 'inProgress') ? 'selected' : ''; ?>>İşlemde</option>
                                    <option value="solved" <?php echo ($post['status'] == 'solved') ? 'selected' : ''; ?>>Çözüldü</option>
                                    <option value="rejected" <?php echo ($post['status'] == 'rejected') ? 'selected' : ''; ?>>Reddedildi</option>
                                </select>
                            </div>
                            
                            <div class="mb-3">
                                <label for="admin_comment" class="form-label">Yönetici Notu</label>
                                <textarea class="form-control" id="admin_comment" name="admin_comment" rows="3"><?php echo $post['admin_comment']; ?></textarea>
                                <div class="form-text">Bu not sadece yöneticiler tarafından görülecektir.</div>
                            </div>
                            
                            <div class="d-grid gap-2 d-md-flex justify-content-md-end">
                                <a href="?page=posts" class="btn btn-secondary me-md-2">İptal</a>
                                <button type="submit" name="update_post" class="btn btn-primary">Güncelle</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
            <?php
        } else {
            echo '<div class="alert alert-danger">Paylaşım bulunamadı.</div>';
        }
    } catch (Exception $e) {
        echo '<div class="alert alert-danger">Hata oluştu: ' . $e->getMessage() . '</div>';
    }
} else {
    // Paylaşımlar Listesi
    ?>
    <div class="container-fluid mt-4">
        <div class="card shadow mb-4">
            <div class="card-header py-3 d-flex justify-content-between align-items-center">
                <h6 class="m-0 font-weight-bold text-primary">Şikayetler & Öneriler</h6>
                <div>
                    <a href="?page=posts&filter=awaiting" class="btn btn-sm btn-warning me-1">Çözüm Bekleyenler</a>
                    <a href="?page=posts&filter=solved" class="btn btn-sm btn-success me-1">Çözülenler</a>
                    <a href="?page=posts&filter=rejected" class="btn btn-sm btn-danger me-1">Reddedilenler</a>
                    <a href="?page=posts" class="btn btn-sm btn-primary">Tümü</a>
                </div>
            </div>
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-bordered" id="dataTable" width="100%" cellspacing="0">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Başlık</th>
                                <th>Kullanıcı</th>
                                <th>Kategori</th>
                                <th>Şehir</th>
                                <th>Tür</th>
                                <th>Tarih</th>
                                <th>Durum</th>
                                <th>İşlemler</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php
                            try {
                                $filter = '';
                                $params = [];
                                $types = '';
                                
                                if (isset($_GET['filter'])) {
                                    switch ($_GET['filter']) {
                                        case 'awaiting':
                                            $filter = "WHERE p.status = 'awaitingSolution'";
                                            break;
                                        case 'solved':
                                            $filter = "WHERE p.status = 'solved'";
                                            break;
                                        case 'rejected':
                                            $filter = "WHERE p.status = 'rejected'";
                                            break;
                                    }
                                }
                                
                                $query = "
                                    SELECT p.*, u.username, c.name as category_name, 
                                           ct.name as city_name 
                                    FROM posts p
                                    LEFT JOIN users u ON p.user_id = u.id
                                    LEFT JOIN categories c ON p.category_id = c.id
                                    LEFT JOIN cities ct ON p.city_id = ct.id
                                    $filter
                                    ORDER BY p.id DESC
                                    LIMIT 50
                                ";
                                
                                $stmt = $db->prepare($query);
                                if (!empty($types) && !empty($params)) {
                                    $stmt->bind_param($types, ...$params);
                                }
                                $stmt->execute();
                                $result = $stmt->get_result();
                                
                                if ($result->num_rows > 0) {
                                    while ($row = $result->fetch_assoc()) {
                                        echo '<tr>';
                                        echo '<td>' . $row['id'] . '</td>';
                                        echo '<td>' . $row['title'] . '</td>';
                                        echo '<td>' . $row['username'] . '</td>';
                                        echo '<td>' . $row['category_name'] . '</td>';
                                        echo '<td>' . $row['city_name'] . '</td>';
                                        echo '<td>' . formatPostType($row['type']) . '</td>';
                                        echo '<td>' . date('d.m.Y', strtotime($row['created_at'])) . '</td>';
                                        echo '<td><span class="badge bg-' . getStatusColor($row['status']) . '">' . formatStatus($row['status']) . '</span></td>';
                                        echo '<td>';
                                        echo '<a href="?page=posts&op=edit&id=' . $row['id'] . '" class="btn btn-sm btn-primary me-1"><i class="bi bi-pencil"></i></a>';
                                        echo '<a href="?page=posts&op=delete&id=' . $row['id'] . '" class="btn btn-sm btn-danger" onclick="return confirm(\'Bu paylaşımı silmek istediğinizden emin misiniz?\');"><i class="bi bi-trash"></i></a>';
                                        echo '</td>';
                                        echo '</tr>';
                                    }
                                } else {
                                    echo '<tr><td colspan="9" class="text-center">Henüz paylaşım bulunmuyor.</td></tr>';
                                }
                            } catch (Exception $e) {
                                echo '<tr><td colspan="9" class="text-center text-danger">Hata oluştu: ' . $e->getMessage() . '</td></tr>';
                            }
                            ?>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
    <?php
}

// Durum formatla
function formatStatus($status) {
    switch ($status) {
        case 'awaitingSolution':
            return 'Çözüm Bekliyor';
        case 'inProgress':
            return 'İşlemde';
        case 'solved':
            return 'Çözüldü';
        case 'rejected':
            return 'Reddedildi';
        default:
            return 'Bilinmiyor';
    }
}

// Durum rengini belirle
function getStatusColor($status) {
    switch ($status) {
        case 'awaitingSolution':
            return 'warning';
        case 'inProgress':
            return 'info';
        case 'solved':
            return 'success';
        case 'rejected':
            return 'danger';
        default:
            return 'secondary';
    }
}

// Paylaşım türü formatla
function formatPostType($type) {
    switch ($type) {
        case 'problem':
            return 'Şikayet';
        case 'suggestion':
            return 'Öneri';
        case 'announcement':
            return 'Duyuru';
        case 'general':
            return 'Genel';
        default:
            return 'Bilinmiyor';
    }
}

// Kapsam formatla
function formatScope($scope) {
    switch ($scope) {
        case 'general':
            return 'Genel';
        case 'city':
            return 'Şehir';
        case 'district':
            return 'İlçe';
        default:
            return 'Bilinmiyor';
    }
}
?>