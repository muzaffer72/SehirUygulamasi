<?php
// Categories routes

// Kategorileri getir
function getCategories($db) {
    $query = "SELECT * FROM categories ORDER BY name ASC";
    $result = $db->query($query);
    
    $categories = [];
    while ($row = $result->fetch_assoc()) {
        // API yanıtı için formatı düzenle
        $categories[] = [
            'id' => (string)$row['id'],
            'name' => $row['name'],
            'description' => $row['description'],
            'icon_name' => $row['icon_name'],
            'created_at' => $row['created_at'],
            'updated_at' => $row['updated_at'],
        ];
    }
    
    sendResponse($categories);
}

// Kategoriyi ID'ye göre getir
function getCategoryById($db, $id) {
    $query = "SELECT * FROM categories WHERE id = ?";
    $stmt = $db->prepare($query);
    $stmt->bind_param("i", $id);
    $result = $stmt->get_result();
    
    if ($result->num_rows === 0) {
        sendError("Category not found", 404);
    }
    
    $category = $result->fetch_assoc();
    
    // API yanıtı için formatı düzenle
    $formatted_category = [
        'id' => (string)$category['id'],
        'name' => $category['name'],
        'description' => $category['description'],
        'icon_name' => $category['icon_name'],
        'created_at' => $category['created_at'],
        'updated_at' => $category['updated_at'],
    ];
    
    sendResponse($formatted_category);
}