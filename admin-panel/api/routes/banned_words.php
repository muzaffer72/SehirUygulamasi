<?php
// Yasaklı Kelimeler API endpoint'leri

/**
 * Tüm yasaklı kelimeleri getir
 */
function getBannedWords($db) {
    $query = "SELECT id, word, created_at FROM banned_words ORDER BY word ASC";
    $result = $db->query($query);
    
    $banned_words = [];
    while ($row = $result->fetch_assoc()) {
        $banned_words[] = $row;
    }
    
    sendResponse(['banned_words' => $banned_words]);
}

/**
 * Yeni yasaklı kelime ekle
 */
function addBannedWord($db, $data) {
    if (!isset($data['word']) || trim($data['word']) === '') {
        sendError("Word is required", 400);
    }
    
    $word = trim($data['word']);
    
    // Önce kontrol et, varsa hata döndür
    $check_query = "SELECT id FROM banned_words WHERE word = ?";
    $check_stmt = $db->prepare($check_query);
    $check_stmt->bind_param("s", $word);
    $check_stmt->execute();
    $check_result = $check_stmt->get_result();
    
    if ($check_result->num_rows > 0) {
        sendError("This word is already banned", 400);
    }
    
    // Yeni kelime ekle
    $query = "INSERT INTO banned_words (word, created_at) VALUES (?, NOW())";
    $stmt = $db->prepare($query);
    $stmt->bind_param("s", $word);
    
    if ($stmt->execute()) {
        $id = $stmt->insert_id;
        
        // Eklenen kelimeyi getir
        $get_query = "SELECT id, word, created_at FROM banned_words WHERE id = ?";
        $get_stmt = $db->prepare($get_query);
        $get_stmt->bind_param("i", $id);
        $get_stmt->execute();
        $get_result = $get_stmt->get_result();
        
        sendResponse([
            'banned_word' => $get_result->fetch_assoc(),
            'message' => 'Word added to ban list successfully'
        ], 201);
    } else {
        sendError("Error adding banned word", 500);
    }
}

/**
 * Yasaklı kelimeyi kaldır
 */
function removeBannedWord($db, $data) {
    if (!isset($data['id']) || !is_numeric($data['id'])) {
        sendError("Valid ID is required", 400);
    }
    
    $id = (int)$data['id'];
    
    // Önce kontrol et
    $check_query = "SELECT id FROM banned_words WHERE id = ?";
    $check_stmt = $db->prepare($check_query);
    $check_stmt->bind_param("i", $id);
    $check_stmt->execute();
    $check_result = $check_stmt->get_result();
    
    if ($check_result->num_rows === 0) {
        sendError("Banned word not found", 404);
    }
    
    // Kelimeyi kaldır
    $query = "DELETE FROM banned_words WHERE id = ?";
    $stmt = $db->prepare($query);
    $stmt->bind_param("i", $id);
    
    if ($stmt->execute()) {
        sendResponse(['message' => 'Word removed from ban list successfully']);
    } else {
        sendError("Error removing banned word", 500);
    }
}