<?php
// PostgreSQL veritabanındaki media tablosunun yapısını kontrol etme betiği
require_once 'db_config.php';
require_once 'db_connection.php';

echo "<h2>Media Tablosu Yapısı Kontrol</h2>";

try {
    // Media tablosunun varlığını kontrol et
    $query = "SELECT to_regclass('public.media') IS NOT NULL AS table_exists";
    $result = $pdo->query($query);
    $media_table_exists = $result->fetch(PDO::FETCH_ASSOC)['table_exists'] ?? false;

    if (!$media_table_exists) {
        echo "<h3>Media tablosu bulunamadı. Oluşturmak ister misiniz?</h3>";
        echo "<form method='post'>";
        echo "<input type='submit' name='create_media_table' value='Media Tablosu Oluştur' style='padding: 10px; background-color: #4CAF50; color: white; border: none; cursor: pointer;'>";
        echo "</form>";
        
        if (isset($_POST['create_media_table'])) {
            try {
                $create_query = "CREATE TABLE media (
                    id SERIAL PRIMARY KEY,
                    post_id INTEGER NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
                    type VARCHAR(20) NOT NULL,
                    url VARCHAR(255) NOT NULL,
                    thumbnail_url VARCHAR(255),
                    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
                )";
                $pdo->exec($create_query);
                echo "<p style='color: green; font-weight: bold;'>Media tablosu başarıyla oluşturuldu!</p>";
                echo "<p>Sayfa 3 saniye içinde yenilenecek...</p>";
                echo "<script>setTimeout(function(){ window.location.reload(); }, 3000);</script>";
            } catch (PDOException $e) {
                echo "<p style='color: red;'>Tablo oluşturulurken hata: " . $e->getMessage() . "</p>";
            }
        }
    } else {
        // Media tablosunun yapısını kontrol et
        $query = "SELECT column_name, data_type, character_maximum_length, is_nullable 
                  FROM information_schema.columns 
                  WHERE table_name = 'media' 
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
        } else {
            echo "<p style='color: red;'>Sorguda hata oluştu.</p>";
        }
    }
} catch (PDOException $e) {
    echo "<p style='color: red;'>Veritabanı hatası: " . $e->getMessage() . "</p>";
}

// Örnek içerik eklemeye git linki
echo "<p><a href='add_sample_content.php' style='padding: 10px; background-color: #2196F3; color: white; text-decoration: none; display: inline-block; margin-top: 20px;'>Örnek İçerik Ekleme Sayfasına Git</a></p>";

echo "<p><a href='index.php?page=posts' style='padding: 10px; background-color: #607D8B; color: white; text-decoration: none; display: inline-block; margin-top: 10px;'>Posts Sayfasına Dön</a></p>";
?>