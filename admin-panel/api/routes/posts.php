<?php
// Gönderi API endpoint'leri

/**
 * Tüm gönderileri al (filtreleme ve sayfalama ile)
 */
function getPosts($db) {
    $page = isset($_GET['page']) ? (int)$_GET['page'] : 1;
    $per_page = isset($_GET['per_page']) ? (int)$_GET['per_page'] : 10;
    $offset = ($page - 1) * $per_page;
    
    // Filtreleme parametreleri
    $city_id = isset($_GET['city_id']) ? (int)$_GET['city_id'] : null;
    $district_id = isset($_GET['district_id']) ? (int)$_GET['district_id'] : null;
    $category_id = isset($_GET['category_id']) ? (int)$_GET['category_id'] : null;
    $user_id = isset($_GET['user_id']) ? (int)$_GET['user_id'] : null;
    $status = isset($_GET['status']) ? $_GET['status'] : null;
    $solved = isset($_GET['solved']) ? (bool)$_GET['solved'] : null;
    
    // Temel sorgu
    $query = "
        SELECT p.*, c.name as city_name, d.name as district_name, cat.name as category_name, 
               u.email as user_email, u.name as user_name, u.username as user_username
        FROM posts p
        LEFT JOIN cities c ON p.city_id = c.id
        LEFT JOIN districts d ON p.district_id = d.id
        LEFT JOIN categories cat ON p.category_id = cat.id
        LEFT JOIN users u ON p.user_id = u.id
        WHERE 1=1";
    
    $count_query = "
        SELECT COUNT(*) as total 
        FROM posts p
        WHERE 1=1";
    
    $params = [];
    $types = "";
    
    // Filtreleme koşullarını ekle
    if ($city_id) {
        $query .= " AND p.city_id = ?";
        $count_query .= " AND p.city_id = ?";
        $params[] = $city_id;
        $types .= "i";
    }
    
    if ($district_id) {
        $query .= " AND p.district_id = ?";
        $count_query .= " AND p.district_id = ?";
        $params[] = $district_id;
        $types .= "i";
    }
    
    if ($category_id) {
        $query .= " AND p.category_id = ?";
        $count_query .= " AND p.category_id = ?";
        $params[] = $category_id;
        $types .= "i";
    }
    
    if ($user_id) {
        $query .= " AND p.user_id = ?";
        $count_query .= " AND p.user_id = ?";
        $params[] = $user_id;
        $types .= "i";
    }
    
    if ($status) {
        $query .= " AND p.status = ?";
        $count_query .= " AND p.status = ?";
        $params[] = $status;
        $types .= "s";
    }
    
    if ($solved !== null) {
        $query .= " AND p.is_solved = ?";
        $count_query .= " AND p.is_solved = ?";
        $params[] = $solved ? 1 : 0;
        $types .= "i";
    }
    
    // Sıralama ve sayfalama
    $query .= " ORDER BY p.created_at DESC LIMIT ? OFFSET ?";
    $params[] = $per_page;
    $params[] = $offset;
    $types .= "ii";
    
    // Toplam kayıt sayısını al
    $count_stmt = $db->prepare($count_query);
    if (!empty($params) && !empty($types)) {
        $count_types = substr($types, 0, -2); // Son iki karakteri (ii) kaldır
        $count_params = array_slice($params, 0, -2); // Son iki parametreyi kaldır
        
        if (!empty($count_params)) {
            $count_stmt->bind_param($count_types, ...$count_params);
        }
    }
    $count_stmt->execute();
    $count_result = $count_stmt->get_result();
    $total = $count_result->fetch_assoc()['total'];
    
    // Gönderileri al
    $stmt = $db->prepare($query);
    if (!empty($params) && !empty($types)) {
        $stmt->bind_param($types, ...$params);
    }
    $stmt->execute();
    $result = $stmt->get_result();
    
    $posts = [];
    while ($row = $result->fetch_assoc()) {
        // Her gönderi için yorum sayısını al
        $comment_query = "SELECT COUNT(*) as count FROM comments WHERE post_id = ?";
        $comment_stmt = $db->prepare($comment_query);
        $comment_stmt->bind_param("i", $row['id']);
        $comment_stmt->execute();
        $comment_result = $comment_stmt->get_result();
        $comment_count = $comment_result->fetch_assoc()['count'];
        
        // Her gönderi için beğeni sayısını al
        $like_query = "SELECT COUNT(*) as count FROM user_likes WHERE post_id = ?";
        $like_stmt = $db->prepare($like_query);
        $like_stmt->bind_param("i", $row['id']);
        $like_stmt->execute();
        $like_result = $like_stmt->get_result();
        $like_count = $like_result->fetch_assoc()['count'];
        
        // Medya dosyalarını al
        $media_query = "SELECT * FROM media WHERE post_id = ?";
        $media_stmt = $db->prepare($media_query);
        $media_stmt->bind_param("i", $row['id']);
        $media_stmt->execute();
        $media_result = $media_stmt->get_result();
        
        $media = [];
        while ($media_row = $media_result->fetch_assoc()) {
            $media[] = $media_row;
        }
        
        $row['comment_count'] = $comment_count;
        $row['like_count'] = $like_count;
        $row['media'] = $media;
        
        $posts[] = $row;
    }
    
    // Sonuçları döndür
    sendResponse([
        'posts' => $posts,
        'pagination' => [
            'total' => (int)$total,
            'per_page' => $per_page,
            'current_page' => $page,
            'last_page' => ceil($total / $per_page),
            'from' => $offset + 1,
            'to' => min($offset + $per_page, $total)
        ]
    ]);
}

/**
 * Belirli bir gönderiyi ID'ye göre al
 */
function getPostById($db, $id) {
    $query = "
        SELECT p.*, c.name as city_name, d.name as district_name, cat.name as category_name, 
               u.email as user_email, u.name as user_name, u.username as user_username
        FROM posts p
        LEFT JOIN cities c ON p.city_id = c.id
        LEFT JOIN districts d ON p.district_id = d.id
        LEFT JOIN categories cat ON p.category_id = cat.id
        LEFT JOIN users u ON p.user_id = u.id
        WHERE p.id = ?";
        
    $stmt = $db->prepare($query);
    $stmt->bind_param("i", $id);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows === 0) {
        sendError("Post not found", 404);
    }
    
    $post = $result->fetch_assoc();
    
    // Yorum sayısını al
    $comment_query = "SELECT COUNT(*) as count FROM comments WHERE post_id = ?";
    $comment_stmt = $db->prepare($comment_query);
    $comment_stmt->bind_param("i", $id);
    $comment_stmt->execute();
    $comment_result = $comment_stmt->get_result();
    $comment_count = $comment_result->fetch_assoc()['count'];
    
    // Beğeni sayısını al
    $like_query = "SELECT COUNT(*) as count FROM user_likes WHERE post_id = ?";
    $like_stmt = $db->prepare($like_query);
    $like_stmt->bind_param("i", $id);
    $like_stmt->execute();
    $like_result = $like_stmt->get_result();
    $like_count = $like_result->fetch_assoc()['count'];
    
    // Medya dosyalarını al
    $media_query = "SELECT * FROM media WHERE post_id = ?";
    $media_stmt = $db->prepare($media_query);
    $media_stmt->bind_param("i", $id);
    $media_stmt->execute();
    $media_result = $media_stmt->get_result();
    
    $media = [];
    while ($media_row = $media_result->fetch_assoc()) {
        $media[] = $media_row;
    }
    
    // Yorumları al
    $comments_query = "
        SELECT c.*, u.username as user_username, u.name as user_name, u.avatar as user_avatar
        FROM comments c
        LEFT JOIN users u ON c.user_id = u.id
        WHERE c.post_id = ?
        ORDER BY c.created_at DESC
        LIMIT 10";
        
    $comments_stmt = $db->prepare($comments_query);
    $comments_stmt->bind_param("i", $id);
    $comments_stmt->execute();
    $comments_result = $comments_stmt->get_result();
    
    $comments = [];
    while ($comment_row = $comments_result->fetch_assoc()) {
        $comments[] = $comment_row;
    }
    
    $post['comment_count'] = $comment_count;
    $post['like_count'] = $like_count;
    $post['media'] = $media;
    $post['comments'] = $comments;
    
    sendResponse(['post' => $post]);
}

/**
 * Yeni gönderi oluştur
 */
function createPost($db, $data) {
    // Gerekli alanları kontrol et
    $required_fields = ['title', 'content', 'user_id', 'city_id', 'district_id', 'category_id'];
    foreach ($required_fields as $field) {
        if (!isset($data[$field])) {
            sendError("Missing required field: $field", 400);
        }
    }
    
    // Yasaklı kelime filtrelemesi
    $data['title'] = filterProfanity($db, $data['title']);
    $data['content'] = filterProfanity($db, $data['content']);
    
    // Gönderi oluştur
    $query = "INSERT INTO posts (title, content, user_id, city_id, district_id, category_id, 
              latitude, longitude, address, status, is_anonymous, is_solved, created_at, updated_at)
              VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())";
              
    $stmt = $db->prepare($query);
    
    $title = $data['title'];
    $content = $data['content'];
    $user_id = $data['user_id'];
    $city_id = $data['city_id'];
    $district_id = $data['district_id'];
    $category_id = $data['category_id'];
    $latitude = $data['latitude'] ?? null;
    $longitude = $data['longitude'] ?? null;
    $address = $data['address'] ?? null;
    $status = $data['status'] ?? 'pending';
    $is_anonymous = $data['is_anonymous'] ?? 0;
    $is_solved = $data['is_solved'] ?? 0;
    
    $stmt->bind_param("ssiiiiddssii", 
        $title, $content, $user_id, $city_id, $district_id, $category_id,
        $latitude, $longitude, $address, $status, $is_anonymous, $is_solved
    );
    
    if ($stmt->execute()) {
        $post_id = $stmt->insert_id;
        
        // Medya dosyalarını işle
        $media_urls = $data['media'] ?? [];
        if (!empty($media_urls)) {
            $media_query = "INSERT INTO media (post_id, url, type, created_at) VALUES (?, ?, ?, NOW())";
            $media_stmt = $db->prepare($media_query);
            
            foreach ($media_urls as $media) {
                $url = $media['url'];
                $type = $media['type'];
                $media_stmt->bind_param("iss", $post_id, $url, $type);
                $media_stmt->execute();
            }
        }
        
        // Oluşturulan gönderiyi getir
        getPostById($db, $post_id);
    } else {
        sendError("Error creating post", 500);
    }
}

/**
 * Gönderiyi güncelle
 */
function updatePost($db, $id, $data) {
    // Önce gönderiyi kontrol et
    $check_query = "SELECT * FROM posts WHERE id = ?";
    $check_stmt = $db->prepare($check_query);
    $check_stmt->bind_param("i", $id);
    $check_stmt->execute();
    
    if ($check_stmt->get_result()->num_rows === 0) {
        sendError("Post not found", 404);
    }
    
    // Güncellenecek alanları oluştur
    $fields = [];
    $params = [];
    $types = "";
    
    $updateable_fields = [
        'title' => 's',
        'content' => 's',
        'city_id' => 'i',
        'district_id' => 'i',
        'category_id' => 'i',
        'latitude' => 'd',
        'longitude' => 'd',
        'address' => 's',
        'status' => 's',
        'is_anonymous' => 'i',
        'is_solved' => 'i'
    ];
    
    foreach ($updateable_fields as $field => $type) {
        if (isset($data[$field])) {
            // Yasaklı kelime filtresi uygula
            if ($field === 'title' || $field === 'content') {
                $data[$field] = filterProfanity($db, $data[$field]);
            }
            
            $fields[] = "$field = ?";
            $params[] = $data[$field];
            $types .= $type;
        }
    }
    
    // Güncelleme zamanını ekle
    $fields[] = "updated_at = NOW()";
    
    if (empty($fields)) {
        sendError("No fields to update", 400);
    }
    
    // Güncelleme sorgusunu oluştur
    $query = "UPDATE posts SET " . implode(", ", $fields) . " WHERE id = ?";
    $params[] = $id;
    $types .= "i";
    
    $stmt = $db->prepare($query);
    $stmt->bind_param($types, ...$params);
    
    if ($stmt->execute()) {
        // Güncellenmiş gönderiyi getir
        getPostById($db, $id);
    } else {
        sendError("Error updating post", 500);
    }
}

/**
 * Gönderiyi sil
 */
function deletePost($db, $id) {
    // Önce gönderiyi kontrol et
    $check_query = "SELECT * FROM posts WHERE id = ?";
    $check_stmt = $db->prepare($check_query);
    $check_stmt->bind_param("i", $id);
    $check_stmt->execute();
    
    if ($check_stmt->get_result()->num_rows === 0) {
        sendError("Post not found", 404);
    }
    
    // İlişkili yorumları ve beğenileri sil
    $db->begin_transaction();
    
    try {
        // Yorumları sil
        $delete_comments = "DELETE FROM comments WHERE post_id = ?";
        $comment_stmt = $db->prepare($delete_comments);
        $comment_stmt->bind_param("i", $id);
        $comment_stmt->execute();
        
        // Beğenileri sil
        $delete_likes = "DELETE FROM user_likes WHERE post_id = ?";
        $like_stmt = $db->prepare($delete_likes);
        $like_stmt->bind_param("i", $id);
        $like_stmt->execute();
        
        // Medya dosyalarını sil
        $delete_media = "DELETE FROM media WHERE post_id = ?";
        $media_stmt = $db->prepare($delete_media);
        $media_stmt->bind_param("i", $id);
        $media_stmt->execute();
        
        // Gönderiyi sil
        $delete_post = "DELETE FROM posts WHERE id = ?";
        $post_stmt = $db->prepare($delete_post);
        $post_stmt->bind_param("i", $id);
        $post_stmt->execute();
        
        $db->commit();
        sendResponse(['message' => 'Post deleted successfully']);
    } catch (Exception $e) {
        $db->rollback();
        sendError("Error deleting post: " . $e->getMessage(), 500);
    }
}

/**
 * Yasaklı kelime filtrelemesi
 * (comments.php ile aynı işlev paylaşılıyor)
 */
if (!function_exists('filterProfanity')) {
    function filterProfanity($db, $text) {
        // Yasaklı kelimeleri veritabanından al
        $query = "SELECT word FROM banned_words";
        $result = $db->query($query);
        
        $banned_words = [];
        while ($row = $result->fetch_assoc()) {
            $banned_words[] = $row['word'];
        }
        
        // Yasaklı kelimeleri "*" ile değiştir
        foreach ($banned_words as $word) {
            $replacement = str_repeat('*', mb_strlen($word));
            $text = str_ireplace($word, $replacement, $text);
        }
        
        return $text;
    }
}