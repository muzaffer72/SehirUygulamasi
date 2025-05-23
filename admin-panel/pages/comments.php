<?php
// Yorumlar Yönetim Sayfası
$page_title = 'Yorum Yönetimi';

// İşlem yönetimi
$operation = isset($_GET['op']) ? $_GET['op'] : '';
$message = '';
$error = '';

// Veritabanı bağlantısını al
require_once __DIR__ . '/../includes/db_connection.php';
if (!$conn) {
    $error = "Veritabanı bağlantı hatası: " . pg_last_error();
}

// Yorum silme işlemi
if ($operation === 'delete' && isset($_GET['id'])) {
    $commentId = (int)$_GET['id'];
    
    try {
        $query = "DELETE FROM comments WHERE id = $1";
        $result = pg_query_params($conn, $query, [$commentId]);
        
        if ($result) {
            $message = "Yorum başarıyla silindi.";
        } else {
            $error = "Yorum silinirken bir hata oluştu.";
        }
    } catch (Exception $e) {
        $error = "Veritabanı hatası: " . $e->getMessage();
    }
}

// Yorum gizleme/gösterme işlemi - PostgreSQL uyumlu
if ($operation === 'toggle_visibility' && isset($_GET['id'])) {
    $commentId = (int)$_GET['id'];
    
    try {
        // Önce yorumun mevcut durumunu al
        $checkQuery = "SELECT is_hidden FROM comments WHERE id = $1";
        $checkResult = pg_query_params($conn, $checkQuery, [$commentId]);
        if (!$checkResult) {
            throw new Exception(pg_last_error($conn));
        }
        
        if (pg_num_rows($checkResult) == 0) {
            throw new Exception("Yorum bulunamadı");
        }
        
        $comment = pg_fetch_assoc($checkResult);
        
        // PostgreSQL'de boolean değerleri 't' veya 'f' olarak döner
        $isCurrentlyHidden = $comment['is_hidden'] === 't';
        
        // Durumu tersine çevir
        $isHidden = !$isCurrentlyHidden;
        
        // PostgreSQL'de boolean değerler direkt değer olarak gider
        $updateQuery = "UPDATE comments SET is_hidden = $1 WHERE id = $2";
        $result = pg_query_params($conn, $updateQuery, [$isHidden, $commentId]);
        
        if ($result) {
            $message = "Yorum " . ($isHidden ? "gizlendi" : "görünür hale getirildi") . ".";
        } else {
            $error = "Yorum durumu güncellenirken bir hata oluştu.";
        }
    } catch (Exception $e) {
        $error = "Veritabanı hatası: " . $e->getMessage();
    }
}

// Yanıt ekleme işlemi - PostgreSQL uyumlu
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['add_reply'])) {
    $parentId = isset($_POST['parent_id']) ? (int)$_POST['parent_id'] : 0;
    $userId = isset($_POST['user_id']) ? (int)$_POST['user_id'] : 0;
    $postId = isset($_POST['post_id']) ? (int)$_POST['post_id'] : 0;
    $content = isset($_POST['content']) ? $_POST['content'] : '';
    $isAnonymous = isset($_POST['is_anonymous']) ? true : false;
    
    if ($parentId > 0 && $userId > 0 && $postId > 0 && !empty($content)) {
        try {
            // PostgreSQL için boolean değer direkt parametre olarak geçilebilir
            $query = "INSERT INTO comments (post_id, user_id, content, parent_id, is_anonymous) VALUES ($1, $2, $3, $4, $5) RETURNING id";
            $result = pg_query_params($conn, $query, [$postId, $userId, $content, $parentId, $isAnonymous]);
            
            if ($result && pg_num_rows($result) > 0) {
                $newComment = pg_fetch_assoc($result);
                $newCommentId = $newComment['id'];
                
                // Paylaşımın yorum sayısını güncelle
                $updatePostQuery = "UPDATE posts SET comment_count = comment_count + 1 WHERE id = $1";
                $updatePostResult = pg_query_params($conn, $updatePostQuery, [$postId]);
                
                // Kullanıcının yorum sayısını güncelle
                $updateUserQuery = "UPDATE users SET comment_count = comment_count + 1 WHERE id = $1";
                $updateUserResult = pg_query_params($conn, $updateUserQuery, [$userId]);
                
                // Bildirim oluştur
                // Önce orijinal yorumun sahibini bul
                $parentCommentQuery = "SELECT user_id FROM comments WHERE id = $1";
                $parentCommentResult = pg_query_params($conn, $parentCommentQuery, [$parentId]);
                
                if ($parentCommentResult && pg_num_rows($parentCommentResult) > 0) {
                    $parentComment = pg_fetch_assoc($parentCommentResult);
                    
                    if ($parentComment && $parentComment['user_id'] != $userId) {
                        // Yorumu yapan kullanıcının adını al
                        $usernameQuery = "SELECT username FROM users WHERE id = $1";
                        $usernameResult = pg_query_params($conn, $usernameQuery, [$userId]);
                        $username = 'Bir kullanıcı';
                        
                        if ($usernameResult && pg_num_rows($usernameResult) > 0) {
                            $usernameRow = pg_fetch_assoc($usernameResult);
                            $username = $usernameRow['username'];
                        }
                        
                        // Paylaşım başlığını al
                        $postTitleQuery = "SELECT title FROM posts WHERE id = $1";
                        $postTitleResult = pg_query_params($conn, $postTitleQuery, [$postId]);
                        $postTitle = 'bir paylaşım';
                        
                        if ($postTitleResult && pg_num_rows($postTitleResult) > 0) {
                            $postTitleRow = pg_fetch_assoc($postTitleResult);
                            $postTitle = $postTitleRow['title'];
                        }
                        
                        // Bildirim ekle
                        $notificationTitle = "Yorumunuza yanıt geldi";
                        $notificationContent = "@$username yorumunuza yanıt verdi: \"" . substr($content, 0, 100) . (strlen($content) > 100 ? '...' : '') . "\"";
                        $notificationType = "reply";
                        $notificationSourceId = $parentId;
                        $notificationSourceType = "comment";
                        $recipientId = $parentComment['user_id'];
                        
                        $notificationQuery = "INSERT INTO notifications (user_id, title, content, type, source_id, source_type) VALUES ($1, $2, $3, $4, $5, $6)";
                        $notificationResult = pg_query_params(
                            $conn, 
                            $notificationQuery, 
                            [$recipientId, $notificationTitle, $notificationContent, $notificationType, $notificationSourceId, $notificationSourceType]
                        );
                    }
                }
                
                $message = "Yanıt başarıyla eklendi.";
            } else {
                $error = "Yanıt eklenirken bir hata oluştu: " . pg_last_error($conn);
            }
        } catch (Exception $e) {
            $error = "Veritabanı hatası: " . $e->getMessage();
        }
    } else {
        $error = "Lütfen tüm zorunlu alanları doldurun.";
    }
}

// Yorum düzenleme işlemi - PostgreSQL uyumlu
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['edit_comment'])) {
    $commentId = isset($_POST['comment_id']) ? (int)$_POST['comment_id'] : 0;
    $content = isset($_POST['content']) ? $_POST['content'] : '';
    
    if ($commentId > 0 && !empty($content)) {
        try {
            $query = "UPDATE comments SET content = $1, updated_at = NOW() WHERE id = $2";
            $result = pg_query_params($conn, $query, [$content, $commentId]);
            
            if ($result) {
                $message = "Yorum başarıyla güncellendi.";
            } else {
                $error = "Yorum güncellenirken bir hata oluştu: " . pg_last_error($conn);
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
    
    // PostgreSQL parametreleri güncelle
    $pg_params = $params;
    $pg_params[] = $limit;
    $pg_params[] = $offset;
    
    // PostgreSQL sorgusu için $1, $2, ... formatına dönüştür
    $i = 1;
    $pg_where = $whereClause;
    foreach ($conditions as &$condition) {
        $condition = str_replace('?', '$'.$i, $condition);
        $i++;
    }
    if (!empty($conditions)) {
        $pg_where = " WHERE " . implode(" AND ", $conditions);
    }
    
    $pg_query = "
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
        $pg_where
        ORDER BY c.created_at DESC
        LIMIT $" . ($i) . " OFFSET $" . ($i+1) . "
    ";
    
    $result = pg_query_params($conn, $pg_query, $pg_params);
    if (!$result) {
        $error = "Sorgu hatası: " . pg_last_error($conn);
        $comments = [];
    } else {
        $comments = [];
        while ($row = pg_fetch_assoc($result)) {
            $comments[] = $row;
        }
    }
    
    // Toplam sayıyı getir - PostgreSQL uyumlu
    $countQuery = "
        SELECT COUNT(*) as total
        FROM comments c
        $pg_where
    ";
    
    $countParams = $params;
    // limit ve offset parametrelerini çıkar
    
    $countResult = pg_query_params($conn, $countQuery, $countParams);
    if (!$countResult) {
        $error = "Toplam sayı sorgu hatası: " . pg_last_error($conn);
        $totalRows = 0;
    } else {
        $countRow = pg_fetch_assoc($countResult);
        $totalRows = $countRow['total'];
    }
    
    $totalPages = ceil($totalRows / $limit);
} catch (Exception $e) {
    $error = "Yorumlar alınırken bir hata oluştu: " . $e->getMessage();
    $comments = [];
    $totalRows = 0;
    $totalPages = 0;
}

// Kullanıcıları al (filtre için) - PostgreSQL uyumlu
try {
    $usersQuery = "SELECT id, username, name FROM users ORDER BY name ASC LIMIT 200";
    $usersResult = pg_query($conn, $usersQuery);
    if (!$usersResult) {
        throw new Exception(pg_last_error($conn));
    }
    
    $users = [];
    while ($row = pg_fetch_assoc($usersResult)) {
        $users[] = $row;
    }
} catch (Exception $e) {
    $error = "Kullanıcılar alınırken hata: " . $e->getMessage();
    $users = [];
}

// Paylaşımları al (filtre için) - PostgreSQL uyumlu
try {
    $postsQuery = "SELECT id, title FROM posts ORDER BY created_at DESC LIMIT 100";
    $postsResult = pg_query($conn, $postsQuery);
    if (!$postsResult) {
        throw new Exception(pg_last_error($conn));
    }
    
    $posts = [];
    while ($row = pg_fetch_assoc($postsResult)) {
        $posts[] = $row;
    }
} catch (Exception $e) {
    $error = "Paylaşımlar alınırken hata: " . $e->getMessage();
    $posts = [];
}

// Yorum detayları - PostgreSQL uyumlu
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
            WHERE c.id = $1
        ";
        
        $result = pg_query_params($conn, $query, [$commentId]);
        if (!$result) {
            throw new Exception(pg_last_error($conn));
        }
        
        $comment = pg_fetch_assoc($result);
        
        if (!$comment) {
            $error = "Yorum bulunamadı.";
        } else {
            // Yanıtları getir
            $repliesQuery = "
                SELECT r.*, u.username as user_username, u.name as user_name
                FROM comments r
                LEFT JOIN users u ON r.user_id = u.id
                WHERE r.parent_id = $1
                ORDER BY r.created_at ASC
            ";
            
            $repliesResult = pg_query_params($conn, $repliesQuery, [$commentId]);
            if (!$repliesResult) {
                throw new Exception(pg_last_error($conn));
            }
            
            $replies = [];
            while ($row = pg_fetch_assoc($repliesResult)) {
                $replies[] = $row;
            }
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
                            
                            <!-- Admin kullanıcı olduğu için direkt olarak sabit admin değerini kullanıyoruz -->
                            <input type="hidden" name="user_id" value="1">
                            <div class="alert alert-info">
                                <i class="bi bi-info-circle"></i> Admin kullanıcısı olarak yanıt veriyorsunuz.
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