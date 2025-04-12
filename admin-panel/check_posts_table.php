<?php
// PostgreSQL veritabanındaki posts tablosunun yapısını kontrol etme betiği
require_once 'db_config.php';
require_once 'db_connection.php';

echo "<h2>Posts Tablosu Yapısı Kontrol</h2>";

try {
    // Posts tablosunun yapısını kontrol et
    $query = "SELECT column_name, data_type, character_maximum_length, is_nullable 
              FROM information_schema.columns 
              WHERE table_name = 'posts' 
              ORDER BY ordinal_position";
              
    $result = $pdo->query($query);
    if ($result) {
        echo "<h3>Mevcut Sütunlar:</h3>";
        echo "<table border='1' cellpadding='5' cellspacing='0'>";
        echo "<tr><th>Sütun Adı</th><th>Veri Tipi</th><th>Uzunluk</th><th>Nullable</th></tr>";
        
        while ($row = $result->fetch(PDO::FETCH_ASSOC)) {
            echo "<tr>";
            echo "<td>" . htmlspecialchars($row['column_name']) . "</td>";
            echo "<td>" . htmlspecialchars($row['data_type']) . "</td>";
            echo "<td>" . htmlspecialchars($row['character_maximum_length'] ?? 'N/A') . "</td>";
            echo "<td>" . htmlspecialchars($row['is_nullable']) . "</td>";
            echo "</tr>";
        }
        
        echo "</table>";
        
        // post_type sütununun olup olmadığını kontrol et
        $query = "SELECT column_name FROM information_schema.columns 
                 WHERE table_name = 'posts' AND column_name = 'post_type'";
        $result = $pdo->query($query);
        $has_post_type = $result->rowCount() > 0;
        
        if (!$has_post_type) {
            echo "<h3>post_type sütunu yok. Eklenmesi gerekiyor.</h3>";
            echo "<p>Eklemek için aşağıdaki düğmeye tıklayın:</p>";
            echo "<form method='post'>";
            echo "<input type='submit' name='add_post_type' value='post_type Sütunu Ekle' style='padding: 10px; background-color: #4CAF50; color: white; border: none; cursor: pointer;'>";
            echo "</form>";
            
            // Sütun ekleme işlemi
            if (isset($_POST['add_post_type'])) {
                try {
                    $alter_query = "ALTER TABLE posts ADD COLUMN post_type VARCHAR(20) DEFAULT 'problem'";
                    $pdo->exec($alter_query);
                    echo "<p style='color: green; font-weight: bold;'>post_type sütunu başarıyla eklendi!</p>";
                    echo "<p>Sayfa 3 saniye içinde yenilenecek...</p>";
                    echo "<script>setTimeout(function(){ window.location.reload(); }, 3000);</script>";
                } catch (PDOException $e) {
                    echo "<p style='color: red;'>Sütun eklenirken hata: " . $e->getMessage() . "</p>";
                }
            }
        } else {
            echo "<h3>post_type sütunu mevcut. Eklemeye gerek yok.</h3>";
        }
        
    } else {
        echo "<p style='color: red;'>Sorguda hata oluştu.</p>";
    }
} catch (PDOException $e) {
    echo "<p style='color: red;'>Veritabanı hatası: " . $e->getMessage() . "</p>";
}

// Örnek içerik eklemeye git linki
echo "<p><a href='add_sample_content.php' style='padding: 10px; background-color: #2196F3; color: white; text-decoration: none; display: inline-block; margin-top: 20px;'>Örnek İçerik Ekleme Sayfasına Git</a></p>";

echo "<p><a href='index.php?page=posts' style='padding: 10px; background-color: #607D8B; color: white; text-decoration: none; display: inline-block; margin-top: 10px;'>Posts Sayfasına Dön</a></p>";
?>