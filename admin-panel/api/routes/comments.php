<?php
// Yorum API endpoint'leri

/**
 * Belirli bir gönderi için yorumları al
 */
function getCommentsByPostId($db, $post_id) {
    $query = "SELECT c.*, 
               u.username as user_username, 
               u.name as user_name, 
               u.avatar as user_avatar 
              FROM comments c
              LEFT JOIN users u ON c.user_id = u.id
              WHERE c.post_id = ?
              ORDER BY c.created_at DESC";
              
    $stmt = $db->prepare($query);
    $stmt->bind_param("i", $post_id);
    $stmt->execute();
    $result = $stmt->get_result();
    
    $comments = [];
    while ($row = $result->fetch_assoc()) {
        $comments[] = $row;
    }
    
    sendResponse(['comments' => $comments]);
}

/**
 * Yeni bir yorum ekle
 */
function addComment($db, $data) {
    if (!isset($data['post_id']) || !isset($data['user_id']) || !isset($data['text'])) {
        sendError('Missing required fields', 400);
    }
    
    // Profanity filter uygula
    $text = filterProfanity($db, $data['text']);
    
    $query = "INSERT INTO comments (post_id, user_id, text, created_at, updated_at)
              VALUES (?, ?, ?, NOW(), NOW())";
              
    $stmt = $db->prepare($query);
    $stmt->bind_param("iis", $data['post_id'], $data['user_id'], $text);
    
    if ($stmt->execute()) {
        $comment_id = $stmt->insert_id;
        
        // Yeni eklenen yorumu getir
        $query = "SELECT c.*, 
                 u.username as user_username, 
                 u.name as user_name, 
                 u.avatar as user_avatar 
                FROM comments c
                LEFT JOIN users u ON c.user_id = u.id
                WHERE c.id = ?";
                
        $stmt = $db->prepare($query);
        $stmt->bind_param("i", $comment_id);
        $stmt->execute();
        $result = $stmt->get_result();
        $comment = $result->fetch_assoc();
        
        sendResponse(['comment' => $comment, 'message' => 'Comment added successfully'], 201);
    } else {
        sendError('Error adding comment', 500);
    }
}

/**
 * Yasaklı kelime filtrelemesi
 */
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