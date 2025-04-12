<?php
require_once '../db_connection.php';

header('Content-Type: application/json');

try {
    global $pdo;
    
    // parent_id sütunu var mı kontrol et
    $checkQuery = "
        SELECT column_name 
        FROM information_schema.columns 
        WHERE table_name = 'comments' 
        AND column_name = 'parent_id'
    ";
    $checkStmt = $pdo->prepare($checkQuery);
    $checkStmt->execute();
    
    if ($checkStmt->rowCount() == 0) {
        // Sütun yoksa ekle
        $alterQuery = "
            ALTER TABLE comments 
            ADD COLUMN parent_id INTEGER NULL,
            ADD COLUMN is_anonymous BOOLEAN DEFAULT FALSE
        ";
        $alterStmt = $pdo->prepare($alterQuery);
        $alterStmt->execute();
        
        // Foreign key ekle (parent_id -> comments.id)
        $fkQuery = "
            ALTER TABLE comments 
            ADD CONSTRAINT comments_parent_id_fkey 
            FOREIGN KEY (parent_id) 
            REFERENCES comments(id) 
            ON DELETE CASCADE
        ";
        $fkStmt = $pdo->prepare($fkQuery);
        $fkStmt->execute();
        
        echo json_encode([
            'success' => true,
            'message' => 'parent_id ve is_anonymous sütunları başarıyla eklendi'
        ]);
    } else {
        echo json_encode([
            'success' => true,
            'message' => 'parent_id sütunu zaten mevcut'
        ]);
    }
    
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'error' => 'Sütun eklenirken bir hata oluştu: ' . $e->getMessage()
    ]);
}
?>