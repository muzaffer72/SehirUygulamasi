<?php
// Yorumlar Yönetim Sayfası
$page_title = 'Yorum Yönetimi';

// İşlem yönetimi
$operation = isset($_GET['op']) ? $_GET['op'] : '';
$message = '';
$error = '';

// Yorum silme işlemi
if ($operation === 'delete' && isset($_GET['id'])) {
    $commentId = (int)$_GET['id'];
    
    try {
        $query = "DELETE FROM comments WHERE id = ?";
        $stmt = $pdo->prepare($query);
        $result = $stmt->execute([$commentId]);
        
        if ($result) {
            $message = "Yorum başarıyla silindi.";
        } else {
            $error = "Yorum silinirken bir hata oluştu.";
        }
    } catch (Exception $e) {
        $error = "Veritabanı hatası: " . $e->getMessage();
    }
}

// Yorum gizleme/gösterme işlemi
if ($operation === 'toggle_visibility' && isset($_GET['id'])) {
    $commentId = (int)$_GET['id'];
    
    try {
        // Önce yorumun mevcut durumunu al
        $checkQuery = "SELECT is_hidden FROM comments WHERE id = ?";
        $checkStmt = $pdo->prepare($checkQuery);
        $checkStmt->execute([$commentId]);
        $comment = $checkStmt->fetch(PDO::FETCH_ASSOC);
        
        // Durumu tersine çevir
        $isHidden = !$comment['is_hidden'];
        
        // Durumu güncelle
        $updateQuery = "UPDATE comments SET is_hidden = ? WHERE id = ?";
        $updateStmt = $pdo->prepare($updateQuery);
        $result = $updateStmt->execute([$isHidden, $commentId]);
        
        if ($result) {
            $message = "Yorum " . ($isHidden ? "gizlendi" : "görünür hale getirildi") . ".";
        } else {
            $error = "Yorum durumu güncellenirken bir hata oluştu.";
        }
    } catch (Exception $e) {
        $error = "Veritabanı hatası: " . $e->getMessage();
    }
}

// Yanıt ekleme işlemi
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['add_reply'])) {
    $parentId = isset($_POST['parent_id']) ? (int)$_POST['parent_id'] : 0;
    $userId = isset($_POST['user_id']) ? (int)$_POST['user_id'] : 0;
    $postId = isset($_POST['post_id']) ? (int)$_POST['post_id'] : 0;
    $content = isset($_POST['content']) ? $_POST['content'] : '';
    $isAnonymous = isset($_POST['is_anonymous']) ? 1 : 0;
    
    if ($parentId > 0 && $userId > 0 && $postId > 0 && !empty($content)) {
        try {
            $query = "INSERT INTO comments (post_id, user_id, content, parent_id, is_anonymous) VALUES (?, ?, ?, ?, ?)";
            $stmt = $db->prepare($query);
            $stmt->bind_param("iisii", $postId, $userId, $content, $parentId, $isAnonymous);
            $result = $stmt->execute();
            
            if ($result) {
                // Paylaşımın yorum sayısını güncelle
                $updatePostQuery = "UPDATE posts SET comment_count = comment_count + 1 WHERE id = ?";
                $updatePostStmt = $db->prepare($updatePostQuery);
                $updatePostStmt->bind_param("i", $postId);
                $updatePostStmt->execute();
                
                // Kullanıcının yorum sayısını güncelle
                $updateUserQuery = "UPDATE users SET comment_count = comment_count + 1 WHERE id = ?";
                $updateUserStmt = $db->prepare($updateUserQuery);
                $updateUserStmt->bind_param("i", $userId);
                $updateUserStmt->execute();
                
                // Bildirim oluştur
                // Önce orijinal yorumun sahibini bul
                $parentCommentQuery = "SELECT user_id FROM comments WHERE id = ?";
                $parentCommentStmt = $db->prepare($parentCommentQuery);
                $parentCommentStmt->bind_param("i", $parentId);
                $parentCommentStmt->execute();
                $parentCommentResult = $parentCommentStmt->get_result();
                $parentComment = $parentCommentResult->fetch_assoc();
                
                if ($parentComment && $parentComment['user_id'] !== $userId) {
                    // Yorumu yapan kullanıcının adını al
                    $usernameQuery = "SELECT username FROM users WHERE id = ?";
                    $usernameStmt = $db->prepare($usernameQuery);
                    $usernameStmt->bind_param("i", $userId);
                    $usernameStmt->execute();
                    $usernameResult = $usernameStmt->get_result();
                    $usernameRow = $usernameResult->fetch_assoc();
                    $username = $usernameRow ? $usernameRow['username'] : 'Bir kullanıcı';
                    
                    // Paylaşım başlığını al
                    $postTitleQuery = "SELECT title FROM posts WHERE id = ?";
                    $postTitleStmt = $db->prepare($postTitleQuery);
                    $postTitleStmt->bind_param("i", $postId);
                    $postTitleStmt->execute();
                    $postTitleResult = $postTitleStmt->get_result();
                    $postTitleRow = $postTitleResult->fetch_assoc();
                    $postTitle = $postTitleRow ? $postTitleRow['title'] : 'bir paylaşım';
                    
                    // Bildirim ekle
                    $notificationTitle = "Yorumunuza yanıt geldi";
                    $notificationContent = "@$username yorumunuza yanıt verdi: \"" . substr($content, 0, 100) . (strlen($content) > 100 ? '...' : '') . "\"";
                    $notificationType = "reply";
                    $notificationSourceId = $parentId;
                    $notificationSourceType = "comment";
                    $recipientId = $parentComment['user_id'];
                    
                    $notificationQuery = "INSERT INTO notifications (user_id, title, content, type, source_id, source_type) VALUES (?, ?, ?, ?, ?, ?)";
                    $notificationStmt = $db->prepare($notificationQuery);
                    $notificationStmt->bind_param("isssss", $recipientId, $notificationTitle, $notificationContent, $notificationType, $notificationSourceId, $notificationSourceType);
                    $notificationStmt->execute();
                }
                
                $message = "Yanıt başarıyla eklendi.";
            } else {
                $error = "Yanıt eklenirken bir hata oluştu.";
            }
        } catch (Exception $e) {
            $error = "Veritabanı hatası: " . $e->getMessage();
        }
    } else {
        $error = "Lütfen tüm zorunlu alanları doldurun.";
    }
}

// Yorum düzenleme işlemi
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['edit_comment'])) {
    $commentId = isset($_POST['comment_id']) ? (int)$_POST['comment_id'] : 0;
    $content = isset($_POST['content']) ? $_POST['content'] : '';
    
    if ($commentId > 0 && !empty($content)) {
        try {
            $query = "UPDATE comments SET content = ? WHERE id = ?";
            $stmt = $db->prepare($query);
            $stmt->bind_param("si", $content, $commentId);
            $result = $stmt->execute();
            
            if ($result) {
                $message = "Yorum başarıyla güncellendi.";
            } else {
                $error = "Yorum güncellenirken bir hata oluştu.";
            }
        } catch (Exception $e) {
            $error = "Veritabanı hatası: " . $e->getMessage();
        }
    } else {
        $error = "Lütfen içerik alanını doldurun.";
    }
}

// Filtreler için değerleri al
$userId = isset($_GET['user_id']) ? (int)$_GET['user_id'] : 0;
$postId = isset($_GET['post_id']) ? (int)$_GET['post_id'] : 0;
$parentId = isset($_GET['parent_id']) ? $_GET['parent_id'] : '';

// Sayfalama
$page = isset($_GET['p']) ? (int)$_GET['p'] : 1;
$limit = 20;
$offset = ($page - 1) * $limit;

// Filtreleme koşulları oluştur
$conditions = [];
$params = [];
$types = "";

if ($userId > 0) {
    $conditions[] = "c.user_id = ?";
    $params[] = $userId;
    $types .= "i";
}

if ($postId > 0) {
    $conditions[] = "c.post_id = ?";
    $params[] = $postId;
    $types .= "i";
}

if ($parentId === '0') {
    $conditions[] = "c.parent_id IS NULL";
} elseif ($parentId === 'replies') {
    $conditions[] = "c.parent_id IS NOT NULL";
} elseif (is_numeric($parentId) && (int)$parentId > 0) {
    $conditions[] = "c.parent_id = ?";
    $params[] = (int)$parentId;
    $types .= "i";
}

$whereClause = !empty($conditions) ? " WHERE " . implode(" AND ", $conditions) : "";

// Yorumları getir
try {
    $query = "
        SELECT c.*, 
               u.username as user_username, u.name as user_name,
               p.title as post_title,
               parent.id as parent_comment_id, parent.content as parent_content,
               parent_user.username as parent_user_username
        FROM comments c
        LEFT JOIN users u ON c.user_id = u.id
        LEFT JOIN posts p ON c.post_id = p.id
        LEFT JOIN comments parent ON c.parent_id = parent.id
        LEFT JOIN users parent_user ON parent.user_id = parent_user.id
        $whereClause
        ORDER BY c.created_at DESC
        LIMIT ? OFFSET ?
    ";
    
    // Sorgu parametreleri
    $params[] = $limit;
    $params[] = $offset;
    
    $stmt = $pdo->prepare($query);
    $stmt->execute($params);
    $comments = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Toplam sayıyı getir
    $countQuery = "
        SELECT COUNT(*) as total
        FROM comments c
        $whereClause
    ";
    
    $countParams = $params;
    array_pop($countParams); // limit parametresini çıkar
    array_pop($countParams); // offset parametresini çıkar
    
    $countStmt = $pdo->prepare($countQuery);
    $countStmt->execute($countParams);
    $totalRows = $countStmt->fetchColumn();
    
    $totalPages = ceil($totalRows / $limit);
} catch (Exception $e) {
    $error = "Yorumlar alınırken bir hata oluştu: " . $e->getMessage();
    $comments = [];
    $totalRows = 0;
    $totalPages = 0;
}

// Kullanıcıları al (filtre için)
try {
    $usersQuery = "SELECT id, username, name FROM users ORDER BY name ASC LIMIT 200";
    $usersStmt = $pdo->prepare($usersQuery);
    $usersStmt->execute();
    $users = $usersStmt->fetchAll(PDO::FETCH_ASSOC);
} catch (Exception $e) {
    $error = "Kullanıcılar alınırken hata: " . $e->getMessage();
    $users = [];
}

// Paylaşımları al (filtre için)
try {
    $postsQuery = "SELECT id, title FROM posts ORDER BY created_at DESC LIMIT 100";
    $postsStmt = $pdo->prepare($postsQuery);
    $postsStmt->execute();
    $posts = $postsStmt->fetchAll(PDO::FETCH_ASSOC);
} catch (Exception $e) {
    $error = "Paylaşımlar alınırken hata: " . $e->getMessage();
    $posts = [];
}

// Yorum detayları
if ($operation === 'view' && isset($_GET['id'])) {
    $commentId = (int)$_GET['id'];
    
    try {
        $query = "
            SELECT c.*, 
                   u.username as user_username, u.name as user_name,
                   p.title as post_title,
                   parent.content as parent_content,
                   parent_user.username as parent_user_username
            FROM comments c
            LEFT JOIN users u ON c.user_id = u.id
            LEFT JOIN posts p ON c.post_id = p.id
            LEFT JOIN comments parent ON c.parent_id = parent.id
            LEFT JOIN users parent_user ON parent.user_id = parent_user.id
            WHERE c.id = ?
        ";
        
        $stmt = $pdo->prepare($query);
        $stmt->execute([$commentId]);
        $comment = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$comment) {
            $error = "Yorum bulunamadı.";
        } else {
            // Yanıtları getir
            $repliesQuery = "
                SELECT r.*, u.username as user_username, u.name as user_name
                FROM comments r
                LEFT JOIN users u ON r.user_id = u.id
                WHERE r.parent_id = ?
                ORDER BY r.created_at ASC
            ";
            
            $repliesStmt = $pdo->prepare($repliesQuery);
            $repliesStmt->execute([$commentId]);
            $replies = $repliesStmt->fetchAll(PDO::FETCH_ASSOC);
        }
    } catch (Exception $e) {
        $error = "Yorum detayları alınırken bir hata oluştu: " . $e->getMessage();
        $comment = null;
        $replies = [];
    }
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
    
    <?php if ($operation === 'view' && isset($comment)): ?>
        <!-- Yorum Detayları -->
        <div class="card shadow mb-4">
            <div class="card-header py-3 d-flex justify-content-between align-items-center">
                <h6 class="m-0 font-weight-bold text-primary">Yorum Detayları</h6>
                <a href="?page=comments" class="btn btn-sm btn-secondary">
                    <i class="bi bi-arrow-left"></i> Geri Dön
                </a>
            </div>
            <div class="card-body">
                <div class="card mb-4">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <div>
                            <strong>
                                <?php if (!empty($comment['user_name'])): ?>
                                    <?php echo htmlspecialchars($comment['user_name']); ?> 
                                    <small class="text-muted">(@<?php echo htmlspecialchars($comment['user_username']); ?>)</small>
                                <?php else: ?>
                                    <span class="text-muted">Bilinmeyen Kullanıcı</span>
                                <?php endif; ?>
                            </strong>
                            <br>
                            <small class="text-muted"><?php echo date('d.m.Y H:i', strtotime($comment['created_at'])); ?></small>
                        </div>
                        <div>
                            <?php if ($comment['is_hidden']): ?>
                                <span class="badge bg-danger">Gizli</span>
                            <?php endif; ?>
                            <?php if ($comment['is_anonymous']): ?>
                                <span class="badge bg-warning text-dark">Anonim</span>
                            <?php endif; ?>
                        </div>
                    </div>
                    <div class="card-body">
                        <?php if (!empty($comment['parent_content'])): ?>
                            <div class="mb-3 p-3 bg-light rounded">
                                <small class="text-muted">
                                    <strong>@<?php echo htmlspecialchars($comment['parent_user_username']); ?></strong> yazdı:
                                </small>
                                <div><?php echo htmlspecialchars(mb_substr($comment['parent_content'], 0, 100)) . (mb_strlen($comment['parent_content']) > 100 ? '...' : ''); ?></div>
                            </div>
                        <?php endif; ?>
                        
                        <p><?php echo nl2br(htmlspecialchars($comment['content'])); ?></p>
                        
                        <div class="mt-3">
                            <small class="text-muted">
                                Paylaşım: <a href="?page=posts&op=view&id=<?php echo $comment['post_id']; ?>">
                                    <?php echo htmlspecialchars($comment['post_title']); ?>
                                </a>
                            </small>
                        </div>
                    </div>
                    <div class="card-footer d-flex justify-content-between">
                        <div>
                            <a href="?page=comments&op=toggle_visibility&id=<?php echo $comment['id']; ?>" class="btn btn-sm <?php echo $comment['is_hidden'] ? 'btn-success' : 'btn-warning'; ?>">
                                <i class="bi <?php echo $comment['is_hidden'] ? 'bi-eye' : 'bi-eye-slash'; ?>"></i> 
                                <?php echo $comment['is_hidden'] ? 'Göster' : 'Gizle'; ?>
                            </a>
                        </div>
                        <div>
                            <button type="button" class="btn btn-sm btn-primary" data-bs-toggle="modal" data-bs-target="#editCommentModal">
                                <i class="bi bi-pencil"></i> Düzenle
                            </button>
                            <a href="?page=comments&op=delete&id=<?php echo $comment['id']; ?>" class="btn btn-sm btn-danger" onclick="return confirm('Bu yorumu silmek istediğinize emin misiniz?')">
                                <i class="bi bi-trash"></i> Sil
                            </a>
                        </div>
                    </div>
                </div>
                
                <!-- Yorum Düzenleme Modal -->
                <div class="modal fade" id="editCommentModal" tabindex="-1" aria-labelledby="editCommentModalLabel" aria-hidden="true">
                    <div class="modal-dialog">
                        <div class="modal-content">
                            <div class="modal-header">
                                <h5 class="modal-title" id="editCommentModalLabel">Yorumu Düzenle</h5>
                                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                            </div>
                            <form method="post" action="?page=comments&op=view&id=<?php echo $comment['id']; ?>">
                                <div class="modal-body">
                                    <input type="hidden" name="comment_id" value="<?php echo $comment['id']; ?>">
                                    <div class="mb-3">
                                        <label for="content" class="form-label">İçerik</label>
                                        <textarea class="form-control" id="content" name="content" rows="5" required><?php echo htmlspecialchars($comment['content']); ?></textarea>
                                    </div>
                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">İptal</button>
                                    <button type="submit" name="edit_comment" class="btn btn-primary">Kaydet</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
                
                <!-- Yanıtlar -->
                <h6 class="mt-4 mb-3">Yanıtlar (<?php echo count($replies); ?>)</h6>
                
                <div class="card shadow mb-4">
                    <div class="card-header py-3">
                        <h6 class="m-0 font-weight-bold">Yeni Yanıt Ekle</h6>
                    </div>
                    <div class="card-body">
                        <form method="post" action="?page=comments&op=view&id=<?php echo $comment['id']; ?>">
                            <input type="hidden" name="parent_id" value="<?php echo $comment['id']; ?>">
                            <input type="hidden" name="post_id" value="<?php echo $comment['post_id']; ?>">
                            
                            <div class="mb-3">
                                <label for="user_id" class="form-label">Yanıtlayan Kullanıcı <span class="text-danger">*</span></label>
                                <select class="form-select" id="user_id" name="user_id" required>
                                    <option value="">Kullanıcı Seçin</option>
                                    <?php foreach ($users as $user): ?>
                                        <option value="<?php echo $user['id']; ?>">
                                            <?php echo htmlspecialchars($user['name'] . ' (' . $user['username'] . ')'); ?>
                                        </option>
                                    <?php endforeach; ?>
                                </select>
                            </div>
                            
                            <div class="mb-3">
                                <label for="content" class="form-label">Yanıt İçeriği <span class="text-danger">*</span></label>
                                <textarea class="form-control" id="content" name="content" rows="3" required></textarea>
                            </div>
                            
                            <div class="mb-3 form-check">
                                <input type="checkbox" class="form-check-input" id="is_anonymous" name="is_anonymous">
                                <label class="form-check-label" for="is_anonymous">Anonim olarak paylaş</label>
                            </div>
                            
                            <div class="d-grid">
                                <button type="submit" name="add_reply" class="btn btn-primary">
                                    <i class="bi bi-reply"></i> Yanıtla
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
                
                <?php if (empty($replies)): ?>
                    <div class="alert alert-info">Henüz yanıt bulunmuyor.</div>
                <?php else: ?>
                    <?php foreach ($replies as $reply): ?>
                        <div class="card mb-3">
                            <div class="card-header d-flex justify-content-between align-items-center">
                                <div>
                                    <strong>
                                        <?php if (!empty($reply['user_name'])): ?>
                                            <?php echo htmlspecialchars($reply['user_name']); ?> 
                                            <small class="text-muted">(@<?php echo htmlspecialchars($reply['user_username']); ?>)</small>
                                        <?php else: ?>
                                            <span class="text-muted">Bilinmeyen Kullanıcı</span>
                                        <?php endif; ?>
                                    </strong>
                                    <br>
                                    <small class="text-muted"><?php echo date('d.m.Y H:i', strtotime($reply['created_at'])); ?></small>
                                </div>
                                <div>
                                    <?php if ($reply['is_hidden']): ?>
                                        <span class="badge bg-danger">Gizli</span>
                                    <?php endif; ?>
                                    <?php if ($reply['is_anonymous']): ?>
                                        <span class="badge bg-warning text-dark">Anonim</span>
                                    <?php endif; ?>
                                </div>
                            </div>
                            <div class="card-body">
                                <p><?php echo nl2br(htmlspecialchars($reply['content'])); ?></p>
                            </div>
                            <div class="card-footer d-flex justify-content-end">
                                <a href="?page=comments&op=toggle_visibility&id=<?php echo $reply['id']; ?>" class="btn btn-sm <?php echo $reply['is_hidden'] ? 'btn-success' : 'btn-warning'; ?> me-2">
                                    <i class="bi <?php echo $reply['is_hidden'] ? 'bi-eye' : 'bi-eye-slash'; ?>"></i> 
                                    <?php echo $reply['is_hidden'] ? 'Göster' : 'Gizle'; ?>
                                </a>
                                <a href="?page=comments&op=view&id=<?php echo $reply['id']; ?>" class="btn btn-sm btn-primary me-2">
                                    <i class="bi bi-eye"></i> Görüntüle
                                </a>
                                <a href="?page=comments&op=delete&id=<?php echo $reply['id']; ?>" class="btn btn-sm btn-danger" onclick="return confirm('Bu yanıtı silmek istediğinize emin misiniz?')">
                                    <i class="bi bi-trash"></i> Sil
                                </a>
                            </div>
                        </div>
                    <?php endforeach; ?>
                <?php endif; ?>
            </div>
        </div>
    <?php else: ?>
        <!-- Yorum Listesi -->
        <div class="card shadow mb-4">
            <div class="card-header py-3 d-flex justify-content-between align-items-center">
                <h6 class="m-0 font-weight-bold text-primary">Yorum Yönetimi</h6>
            </div>
            <div class="card-body">
                <!-- Filtreler -->
                <div class="row mb-4">
                    <div class="col-md-12">
                        <form method="get" action="" class="mb-3">
                            <input type="hidden" name="page" value="comments">
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
                                    <label for="parent_id" class="form-label">Yorum Tipi</label>
                                    <select class="form-select" id="parent_id" name="parent_id">
                                        <option value="">Tüm Yorumlar</option>
                                        <option value="0" <?php echo $parentId === '0' ? 'selected' : ''; ?>>Ana Yorumlar</option>
                                        <option value="replies" <?php echo $parentId === 'replies' ? 'selected' : ''; ?>>Yanıtlar</option>
                                    </select>
                                </div>
                                <div class="col-md-3">
                                    <button type="submit" class="btn btn-primary">Filtrele</button>
                                    <a href="?page=comments" class="btn btn-secondary">Sıfırla</a>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>
                
                <!-- Toplam Sayı -->
                <div class="row mb-3">
                    <div class="col-md-12">
                        <p class="text-muted">Toplam <?php echo $totalRows; ?> yorum bulundu.</p>
                    </div>
                </div>
                
                <!-- Tablo -->
                <div class="table-responsive">
                    <table class="table table-bordered table-striped">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Kullanıcı</th>
                                <th>İçerik</th>
                                <th>Paylaşım</th>
                                <th>Tür</th>
                                <th>Durum</th>
                                <th>Tarih</th>
                                <th>İşlemler</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php if (empty($comments)): ?>
                                <tr>
                                    <td colspan="8" class="text-center">Hiç yorum bulunamadı.</td>
                                </tr>
                            <?php else: ?>
                                <?php foreach ($comments as $comment): ?>
                                    <tr>
                                        <td><?php echo $comment['id']; ?></td>
                                        <td>
                                            <?php if (!empty($comment['user_name'])): ?>
                                                <a href="?page=comments&user_id=<?php echo $comment['user_id']; ?>">
                                                    <?php echo htmlspecialchars($comment['user_name']); ?> 
                                                    <small class="text-muted">(@<?php echo htmlspecialchars($comment['user_username']); ?>)</small>
                                                </a>
                                            <?php else: ?>
                                                <span class="text-muted">Bilinmeyen Kullanıcı</span>
                                            <?php endif; ?>
                                        </td>
                                        <td>
                                            <?php if (!empty($comment['parent_comment_id'])): ?>
                                                <div class="mb-2 small">
                                                    <span class="text-muted">@<?php echo htmlspecialchars($comment['parent_user_username']); ?> yorumuna yanıt:</span>
                                                </div>
                                            <?php endif; ?>
                                            
                                            <?php echo htmlspecialchars(mb_substr($comment['content'], 0, 100)) . (mb_strlen($comment['content']) > 100 ? '...' : ''); ?>
                                        </td>
                                        <td>
                                            <?php if (!empty($comment['post_title'])): ?>
                                                <a href="?page=posts&op=view&id=<?php echo $comment['post_id']; ?>">
                                                    <?php echo htmlspecialchars(mb_substr($comment['post_title'], 0, 30)) . (mb_strlen($comment['post_title']) > 30 ? '...' : ''); ?>
                                                </a>
                                            <?php else: ?>
                                                <span class="text-muted">Bilinmiyor</span>
                                            <?php endif; ?>
                                        </td>
                                        <td>
                                            <?php if (empty($comment['parent_id'])): ?>
                                                <span class="badge bg-primary">Ana Yorum</span>
                                            <?php else: ?>
                                                <span class="badge bg-info">Yanıt</span>
                                            <?php endif; ?>
                                            
                                            <?php if ($comment['is_anonymous']): ?>
                                                <span class="badge bg-warning text-dark">Anonim</span>
                                            <?php endif; ?>
                                        </td>
                                        <td>
                                            <?php if ($comment['is_hidden']): ?>
                                                <span class="badge bg-danger">Gizli</span>
                                            <?php else: ?>
                                                <span class="badge bg-success">Görünür</span>
                                            <?php endif; ?>
                                        </td>
                                        <td><?php echo date('d.m.Y H:i', strtotime($comment['created_at'])); ?></td>
                                        <td>
                                            <div class="btn-group btn-group-sm">
                                                <a href="?page=comments&op=view&id=<?php echo $comment['id']; ?>" class="btn btn-sm btn-info">
                                                    <i class="bi bi-eye"></i> Görüntüle
                                                </a>
                                                <a href="?page=comments&op=toggle_visibility&id=<?php echo $comment['id']; ?>" class="btn btn-sm <?php echo $comment['is_hidden'] ? 'btn-success' : 'btn-warning'; ?>">
                                                    <i class="bi <?php echo $comment['is_hidden'] ? 'bi-eye' : 'bi-eye-slash'; ?>"></i>
                                                </a>
                                                <a href="?page=comments&op=delete&id=<?php echo $comment['id']; ?>" class="btn btn-sm btn-danger" onclick="return confirm('Bu yorumu silmek istediğinize emin misiniz?')">
                                                    <i class="bi bi-trash"></i>
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
                                    <a class="page-link" href="?page=comments&p=1<?php echo (!empty($whereClause) ? "&user_id=$userId&post_id=$postId&parent_id=$parentId" : ''); ?>">
                                        İlk
                                    </a>
                                </li>
                                <li class="page-item">
                                    <a class="page-link" href="?page=comments&p=<?php echo $page - 1; ?><?php echo (!empty($whereClause) ? "&user_id=$userId&post_id=$postId&parent_id=$parentId" : ''); ?>">
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
                                    <a class="page-link" href="?page=comments&p=<?php echo $i; ?><?php echo (!empty($whereClause) ? "&user_id=$userId&post_id=$postId&parent_id=$parentId" : ''); ?>">
                                        <?php echo $i; ?>
                                    </a>
                                </li>
                            <?php endfor; ?>

                            <?php if ($page < $totalPages): ?>
                                <li class="page-item">
                                    <a class="page-link" href="?page=comments&p=<?php echo $page + 1; ?><?php echo (!empty($whereClause) ? "&user_id=$userId&post_id=$postId&parent_id=$parentId" : ''); ?>">
                                        Sonraki
                                    </a>
                                </li>
                                <li class="page-item">
                                    <a class="page-link" href="?page=comments&p=<?php echo $totalPages; ?><?php echo (!empty($whereClause) ? "&user_id=$userId&post_id=$postId&parent_id=$parentId" : ''); ?>">
                                        Son
                                    </a>
                                </li>
                            <?php endif; ?>
                        </ul>
                    </nav>
                <?php endif; ?>
            </div>
        </div>
    <?php endif; ?>
</div>