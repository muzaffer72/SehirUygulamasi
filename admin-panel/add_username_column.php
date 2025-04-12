<?php
// Bu script, users tablosuna username sütunu ekler

// Database bağlantısı
require_once 'db_config.php';
require_once 'db_connection.php';
$db = $conn;

// Kullanıcılar tablosunun kontrolü
try {
    $checkTableSQL = "SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'users'
    )";
    $result = $db->query($checkTableSQL);
    $tableExists = $result->fetch_assoc()['exists'] ?? false;
    
    if (!$tableExists) {
        echo "HATA: users tablosu bulunamadı. Lütfen önce veritabanı şemasını oluşturun.<br>";
        exit;
    }
    
    echo "Users tablosu kontrol edildi.<br>";
} catch (Exception $e) {
    echo "HATA: Veritabanı kontrolü sırasında bir hata oluştu: " . $e->getMessage() . "<br>";
    exit;
}

// Users tablosunda username sütununun varlığını kontrol edelim
try {
    $checkColumnSQL = "SELECT column_name 
                       FROM information_schema.columns 
                       WHERE table_schema = 'public' 
                       AND table_name = 'users' 
                       AND column_name = 'username'";
    $result = $db->query($checkColumnSQL);
    $columnExists = $result->num_rows > 0;
    
    if ($columnExists) {
        echo "Users tablosunda username sütunu zaten var.<br>";
    } else {
        // Username sütunu ekleyelim
        $alterTableSQL = "ALTER TABLE users ADD COLUMN username VARCHAR(100) UNIQUE";
        if ($db->query($alterTableSQL)) {
            echo "Username sütunu başarıyla eklendi.<br>";
            
            // Mevcut kullanıcılar için email değerlerini username olarak atayalım
            $updateUsersSQL = "UPDATE users SET username = email WHERE username IS NULL";
            if ($db->query($updateUsersSQL)) {
                echo "Mevcut kullanıcılar için email değerleri username olarak atandı.<br>";
            } else {
                echo "HATA: Kullanıcı bilgileri güncellenirken bir hata oluştu.<br>";
            }
        } else {
            echo "HATA: Username sütunu eklenirken bir hata oluştu.<br>";
        }
    }
} catch (Exception $e) {
    echo "HATA: Username sütunu işlemleri sırasında bir hata oluştu: " . $e->getMessage() . "<br>";
}

// Users tablosundaki kullanıcıları listeleyelim
try {
    $listUsersSQL = "SELECT id, name, email, username, is_verified FROM users LIMIT 10";
    $result = $db->query($listUsersSQL);
    
    if ($result && $result->num_rows > 0) {
        echo "<h3>Kullanıcı Listesi:</h3>";
        echo "<table border='1' cellpadding='5' style='border-collapse: collapse;'>";
        echo "<tr><th>ID</th><th>Name</th><th>Email</th><th>Username</th><th>Is Verified</th></tr>";
        
        while ($user = $result->fetch_assoc()) {
            echo "<tr>";
            echo "<td>" . $user['id'] . "</td>";
            echo "<td>" . $user['name'] . "</td>";
            echo "<td>" . $user['email'] . "</td>";
            echo "<td>" . $user['username'] . "</td>";
            echo "<td>" . ($user['is_verified'] ? 'Yes' : 'No') . "</td>";
            echo "</tr>";
        }
        
        echo "</table>";
    } else {
        echo "Kullanıcı tablosunda kayıt bulunamadı.<br>";
    }
} catch (Exception $e) {
    echo "HATA: Kullanıcı listesi alınırken bir hata oluştu: " . $e->getMessage() . "<br>";
}
?>