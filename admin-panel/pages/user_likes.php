<?php
// Beğeniler Yönetim Sayfası
$page_title = 'Beğeni Yönetimi';

// İşlem yönetimi
$operation = isset($_GET['op']) ? $_GET['op'] : '';
$message = '';
$error = '';

// Beğeni silme işlemi
if ($operation === 'delete' && isset($_GET['id'])) {
    $likeId = (int)$_GET['id'];
    
    try {
        $query = "DELETE FROM user_likes WHERE id = ?";
        $stmt = $db->prepare($query);
        $stmt->bind_param("i", $likeId);
        $result = $stmt->execute();
        
        if ($result) {
            $message = "Beğeni başarıyla silindi.";
        } else {
            $error = "Beğeni silinirken bir hata oluştu.";
        }
    } catch (Exception $e) {
        $error = "Veritabanı hatası: " . $e->getMessage();
    }
}

// Filtreler için değerleri al
$userId = isset($_GET['user_id']) ? (int)$_GET['user_id'] : 0;
$postId = isset($_GET['post_id']) ? (int)$_GET['post_id'] : 0;
$commentId = isset($_GET['comment_id']) ? (int)$_GET['comment_id'] : 0;

// Sayfalama
$page = isset($_GET['p']) ? (int)$_GET['p'] : 1;
$limit = 20;
$offset = ($page - 1) * $limit;

// Filtreleme koşulları oluştur
$conditions = [];
$params = [];
$types = "";

if ($userId > 0) {
    $conditions[] = "ul.user_id = ?";
    $params[] = $userId;
    $types .= "i";
}

if ($postId > 0) {
    $conditions[] = "ul.post_id = ?";
    $params[] = $postId;
    $types .= "i";
}

if ($commentId > 0) {
    $conditions[] = "ul.comment_id = ?";
    $params[] = $commentId;
    $types .= "i";
}

$whereClause = !empty($conditions) ? " WHERE " . implode(" AND ", $conditions) : "";

// Beğenileri getir
try {
    $query = "
        SELECT ul.*, 
               u.username as user_username, u.name as user_name,
               p.title as post_title,
               c.content as comment_content
        FROM user_likes ul
        LEFT JOIN users u ON ul.user_id = u.id
        LEFT JOIN posts p ON ul.post_id = p.id
        LEFT JOIN comments c ON ul.comment_id = c.id
        $whereClause
        ORDER BY ul.created_at DESC
        LIMIT ? OFFSET ?
    ";
    
    // Sorgu parametreleri
    $params[] = $limit;
    $params[] = $offset;
    $types .= "ii";
    
    $stmt = $db->prepare($query);
    
    if (!empty($params)) {
        $stmt->bind_param($types, ...$params);
    }
    
    $stmt->execute();
    $result = $stmt->get_result();
    $likes = $result->fetch_all(MYSQLI_ASSOC);
    
    // Toplam sayıyı getir
    $countQuery = "
        SELECT COUNT(*) as total
        FROM user_likes ul
        $whereClause
    ";
    
    $countParams = $params;
    array_pop($countParams); // limit parametresini çıkar
    array_pop($countParams); // offset parametresini çıkar
    $countTypes = substr($types, 0, -2); // son iki karakteri çıkar (ii)
    
    $countStmt = $db->prepare($countQuery);
    
    if (!empty($countParams)) {
        $countStmt->bind_param($countTypes, ...$countParams);
    }
    
    $countStmt->execute();
    $countResult = $countStmt->get_result();
    $totalRows = $countResult->fetch_assoc()['total'];
    
    $totalPages = ceil($totalRows / $limit);
} catch (Exception $e) {
    $error = "Beğeniler alınırken bir hata oluştu: " . $e->getMessage();
    $likes = [];
    $totalRows = 0;
    $totalPages = 0;
}

// Kullanıcıları al (filtre için)
try {
    $usersQuery = "SELECT id, username, name FROM users ORDER BY name ASC LIMIT 200";
    $usersResult = $db->query($usersQuery);
    $users = $usersResult->fetch_all(MYSQLI_ASSOC);
} catch (Exception $e) {
    $error = "Kullanıcılar alınırken hata: " . $e->getMessage();
    $users = [];
}

// Paylaşımları al (filtre için)
try {
    $postsQuery = "SELECT id, title FROM posts ORDER BY created_at DESC LIMIT 100";
    $postsResult = $db->query($postsQuery);
    $posts = $postsResult->fetch_all(MYSQLI_ASSOC);
} catch (Exception $e) {
    $error = "Paylaşımlar alınırken hata: " . $e->getMessage();
    $posts = [];
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
            <h6 class="m-0 font-weight-bold text-primary">Beğeni Yönetimi</h6>
        </div>
        <div class="card-body">
            <!-- Filtreler -->
            <div class="row mb-4">
                <div class="col-md-12">
                    <form method="get" action="" class="mb-3">
                        <input type="hidden" name="page" value="user_likes">
                        <div class="row g-3 align-items-end">
                            <div class="col-md-3">
                                <label for="user_id" class="form-label">Kullanıcı</label>
                                <select class="form-select" id="user_id" name="user_id">
                                    <option value="0">Tüm Kullanıcılar</option>
                                    <?php foreach ($users as $user): ?>
                                        <option value="<?php echo $user['id']; ?>" <?php echo $userId == $user['id'] ? 'selected' : ''; ?>>
                                            <?php echo htmlspecialchars($user['name'] . ' (' . $user['username'] . ')'); ?>
                                        </option>
                                    <?php endforeach; ?>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <label for="post_id" class="form-label">Paylaşım</label>
                                <select class="form-select" id="post_id" name="post_id">
                                    <option value="0">Tüm Paylaşımlar</option>
                                    <?php foreach ($posts as $post): ?>
                                        <option value="<?php echo $post['id']; ?>" <?php echo $postId == $post['id'] ? 'selected' : ''; ?>>
                                            <?php echo htmlspecialchars(mb_substr($post['title'], 0, 50) . (mb_strlen($post['title']) > 50 ? '...' : '')); ?>
                                        </option>
                                    <?php endforeach; ?>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <label for="comment_id" class="form-label">Yorum ID</label>
                                <input type="number" class="form-control" id="comment_id" name="comment_id" value="<?php echo $commentId; ?>" min="0">
                            </div>
                            <div class="col-md-3">
                                <button type="submit" class="btn btn-primary">Filtrele</button>
                                <a href="?page=user_likes" class="btn btn-secondary">Sıfırla</a>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
            
            <!-- Toplam Sayı -->
            <div class="row mb-3">
                <div class="col-md-12">
                    <p class="text-muted">Toplam <?php echo $totalRows; ?> beğeni bulundu.</p>
                </div>
            </div>
            
            <!-- Tablo -->
            <div class="table-responsive">
                <table class="table table-bordered table-striped">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Kullanıcı</th>
                            <th>Beğeni Türü</th>
                            <th>İçerik</th>
                            <th>Tarih</th>
                            <th>İşlemler</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php if (empty($likes)): ?>
                            <tr>
                                <td colspan="6" class="text-center">Hiç beğeni bulunamadı.</td>
                            </tr>
                        <?php else: ?>
                            <?php foreach ($likes as $like): ?>
                                <tr>
                                    <td><?php echo $like['id']; ?></td>
                                    <td>
                                        <?php if (!empty($like['user_name'])): ?>
                                            <a href="?page=user_likes&user_id=<?php echo $like['user_id']; ?>">
                                                <?php echo htmlspecialchars($like['user_name']); ?> 
                                                <small class="text-muted">(@<?php echo htmlspecialchars($like['user_username']); ?>)</small>
                                            </a>
                                        <?php else: ?>
                                            <span class="text-muted">Bilinmeyen Kullanıcı</span>
                                        <?php endif; ?>
                                    </td>
                                    <td>
                                        <?php if (!empty($like['post_id'])): ?>
                                            <span class="badge bg-info">Paylaşım</span>
                                        <?php elseif (!empty($like['comment_id'])): ?>
                                            <span class="badge bg-secondary">Yorum</span>
                                        <?php else: ?>
                                            <span class="badge bg-warning">Bilinmiyor</span>
                                        <?php endif; ?>
                                    </td>
                                    <td>
                                        <?php if (!empty($like['post_id']) && !empty($like['post_title'])): ?>
                                            <a href="?page=posts&op=view&id=<?php echo $like['post_id']; ?>">
                                                <?php echo htmlspecialchars(mb_substr($like['post_title'], 0, 60)) . (mb_strlen($like['post_title']) > 60 ? '...' : ''); ?>
                                            </a>
                                        <?php elseif (!empty($like['comment_id']) && !empty($like['comment_content'])): ?>
                                            <small class="text-muted"><?php echo htmlspecialchars(mb_substr($like['comment_content'], 0, 60)) . (mb_strlen($like['comment_content']) > 60 ? '...' : ''); ?></small>
                                        <?php else: ?>
                                            <span class="text-muted">İçerik bulunamadı</span>
                                        <?php endif; ?>
                                    </td>
                                    <td><?php echo date('d.m.Y H:i', strtotime($like['created_at'])); ?></td>
                                    <td>
                                        <div class="btn-group btn-group-sm">
                                            <a href="?page=user_likes&op=delete&id=<?php echo $like['id']; ?>" 
                                               class="btn btn-danger btn-sm"
                                               onclick="return confirm('Bu beğeniyi silmek istediğinize emin misiniz?')">
                                                <i class="bi bi-trash"></i> Sil
                                            </a>
                                        </div>
                                    </td>
                                </tr>
                            <?php endforeach; ?>
                        <?php endif; ?>
                    </tbody>
                </table>
            </div>
            
            <!-- Sayfalama -->
            <?php if ($totalPages > 1): ?>
                <nav>
                    <ul class="pagination justify-content-center">
                        <?php if ($page > 1): ?>
                            <li class="page-item">
                                <a class="page-link" href="?page=user_likes&p=1<?php echo (!empty($whereClause) ? "&user_id=$userId&post_id=$postId&comment_id=$commentId" : ''); ?>">
                                    İlk
                                </a>
                            </li>
                            <li class="page-item">
                                <a class="page-link" href="?page=user_likes&p=<?php echo $page - 1; ?><?php echo (!empty($whereClause) ? "&user_id=$userId&post_id=$postId&comment_id=$commentId" : ''); ?>">
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
                                <a class="page-link" href="?page=user_likes&p=<?php echo $i; ?><?php echo (!empty($whereClause) ? "&user_id=$userId&post_id=$postId&comment_id=$commentId" : ''); ?>">
                                    <?php echo $i; ?>
                                </a>
                            </li>
                        <?php endfor; ?>

                        <?php if ($page < $totalPages): ?>
                            <li class="page-item">
                                <a class="page-link" href="?page=user_likes&p=<?php echo $page + 1; ?><?php echo (!empty($whereClause) ? "&user_id=$userId&post_id=$postId&comment_id=$commentId" : ''); ?>">
                                    Sonraki
                                </a>
                            </li>
                            <li class="page-item">
                                <a class="page-link" href="?page=user_likes&p=<?php echo $totalPages; ?><?php echo (!empty($whereClause) ? "&user_id=$userId&post_id=$postId&comment_id=$commentId" : ''); ?>">
                                    Son
                                </a>
                            </li>
                        <?php endif; ?>
                    </ul>
                </nav>
            <?php endif; ?>
        </div>
    </div>
</div>