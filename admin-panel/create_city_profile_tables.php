<?php
// Bu betik ŞikayetVar uygulamasının şehir profil sayfaları için gerekli ek tabloları oluşturur
require_once 'db_config.php';
require_once 'db_connection.php';

$db = $conn; // MySQLiCompatWrapper'i $db değişkenine ata

// Tabloların oluşturulması
$sqls = [];

// 1. Şehir Hizmetleri Tablosu
$sqls[] = "
CREATE TABLE IF NOT EXISTS city_services (
  id SERIAL PRIMARY KEY,
  city_id INTEGER NOT NULL,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  address VARCHAR(255),
  phone VARCHAR(50),
  website VARCHAR(255),
  type VARCHAR(50),
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (city_id) REFERENCES cities (id) ON DELETE CASCADE
);
";

// 2. Şehir Projeleri Tablosu
$sqls[] = "
CREATE TABLE IF NOT EXISTS city_projects (
  id SERIAL PRIMARY KEY,
  city_id INTEGER NOT NULL,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  status VARCHAR(20) NOT NULL DEFAULT 'planned',
  budget DECIMAL(20,2) DEFAULT 0.00,
  start_date DATE,
  end_date DATE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (city_id) REFERENCES cities (id) ON DELETE CASCADE
);
";

// Proje durumları için değerler kısıtlaması
$sqls[] = "
ALTER TABLE city_projects
  DROP CONSTRAINT IF EXISTS check_status;
";

$sqls[] = "
ALTER TABLE city_projects
  ADD CONSTRAINT check_status CHECK (status IN ('planned', 'in_progress', 'completed', 'cancelled'));
";

// 3. Şehir Etkinlikleri Tablosu
$sqls[] = "
CREATE TABLE IF NOT EXISTS city_events (
  id SERIAL PRIMARY KEY,
  city_id INTEGER NOT NULL,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  location VARCHAR(255),
  event_date DATE,
  event_time TIME,
  type VARCHAR(50),
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (city_id) REFERENCES cities (id) ON DELETE CASCADE
);
";

// 4. Şehir İstatistikleri Tablosu
$sqls[] = "
CREATE TABLE IF NOT EXISTS city_stats (
  id SERIAL PRIMARY KEY,
  city_id INTEGER NOT NULL,
  year VARCHAR(4) NOT NULL,
  unemployment_rate DECIMAL(5,2) DEFAULT 0.00,
  healthcare_access DECIMAL(5,2) DEFAULT 0.00,
  education_quality DECIMAL(5,2) DEFAULT 0.00,
  infrastructure_quality DECIMAL(5,2) DEFAULT 0.00,
  safety_index DECIMAL(5,2) DEFAULT 0.00,
  cost_of_living DECIMAL(5,2) DEFAULT 0.00,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (city_id) REFERENCES cities (id) ON DELETE CASCADE,
  CONSTRAINT city_year_unique UNIQUE (city_id, year)
);
";

// 5. Şehir Tablosu Sütunlarını Güncelleme
// PostgreSQL'de bir seferde birden fazla sütun ekleme yok, bu yüzden her sütun için ayrı sorgu yazdım
$sqls[] = "ALTER TABLE cities ADD COLUMN IF NOT EXISTS description TEXT;";
$sqls[] = "ALTER TABLE cities ADD COLUMN IF NOT EXISTS population INTEGER DEFAULT 0;";
$sqls[] = "ALTER TABLE cities ADD COLUMN IF NOT EXISTS area INTEGER DEFAULT 0;";
$sqls[] = "ALTER TABLE cities ADD COLUMN IF NOT EXISTS mayor_name VARCHAR(255);";
$sqls[] = "ALTER TABLE cities ADD COLUMN IF NOT EXISTS mayor_party VARCHAR(100);";
$sqls[] = "ALTER TABLE cities ADD COLUMN IF NOT EXISTS website VARCHAR(255);";
$sqls[] = "ALTER TABLE cities ADD COLUMN IF NOT EXISTS phone VARCHAR(50);";
$sqls[] = "ALTER TABLE cities ADD COLUMN IF NOT EXISTS email VARCHAR(255);";
$sqls[] = "ALTER TABLE cities ADD COLUMN IF NOT EXISTS social_media VARCHAR(255);";

// PostgreSQL'de otomatik güncelleme için tetikleyiciler oluştur
$sqls[] = "
CREATE OR REPLACE FUNCTION update_modified_column() 
RETURNS TRIGGER AS $$
BEGIN
   NEW.updated_at = CURRENT_TIMESTAMP;
   RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';
";

// city_services tablosu için tetikleyicileri kaldırma ve ekleme
$sqls[] = "DROP TRIGGER IF EXISTS update_city_services_modtime ON city_services;";
$sqls[] = "
CREATE TRIGGER update_city_services_modtime
BEFORE UPDATE ON city_services
FOR EACH ROW
EXECUTE FUNCTION update_modified_column();
";

// city_projects tablosu için tetikleyicileri kaldırma ve ekleme 
$sqls[] = "DROP TRIGGER IF EXISTS update_city_projects_modtime ON city_projects;";
$sqls[] = "
CREATE TRIGGER update_city_projects_modtime
BEFORE UPDATE ON city_projects
FOR EACH ROW
EXECUTE FUNCTION update_modified_column();
";

// city_events tablosu için tetikleyicileri kaldırma ve ekleme
$sqls[] = "DROP TRIGGER IF EXISTS update_city_events_modtime ON city_events;";
$sqls[] = "
CREATE TRIGGER update_city_events_modtime
BEFORE UPDATE ON city_events
FOR EACH ROW
EXECUTE FUNCTION update_modified_column();
";

// city_stats tablosu için tetikleyicileri kaldırma ve ekleme
$sqls[] = "DROP TRIGGER IF EXISTS update_city_stats_modtime ON city_stats;";
$sqls[] = "
CREATE TRIGGER update_city_stats_modtime
BEFORE UPDATE ON city_stats
FOR EACH ROW
EXECUTE FUNCTION update_modified_column();
";

// Sorguları çalıştır ve sonuçları yazdır
$error = false;
$messages = [];

foreach ($sqls as $sql) {
    try {
        if ($db->query($sql)) {
            $messages[] = "SQL sorgusu başarılı: " . substr($sql, 0, 60) . "...";
        } else {
            $error = true;
            $messages[] = "SQL hatası: " . $db->error . " Sorgu: " . substr($sql, 0, 60) . "...";
        }
    } catch (Exception $e) {
        $error = true;
        $messages[] = "İstisna: " . $e->getMessage() . " Sorgu: " . substr($sql, 0, 60) . "...";
    }
}

// Sonuçları yazdır
echo "<!DOCTYPE html>
<html lang='tr'>
<head>
    <meta charset='UTF-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <title>Şehir Profili Tabloları</title>
    <link href='https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css' rel='stylesheet'>
</head>
<body>
    <div class='container mt-5'>
        <h1>Şehir Profili Tabloları Kurulumu</h1>";

if ($error) {
    echo "<div class='alert alert-danger'>Bazı sorgular çalıştırılırken hatalar oluştu.</div>";
} else {
    echo "<div class='alert alert-success'>Tüm tablolar başarıyla oluşturuldu.</div>";
}

echo "<div class='mt-4'>";
foreach ($messages as $message) {
    if (strpos($message, "SQL hatası") !== false || strpos($message, "İstisna") !== false) {
        echo "<div class='alert alert-danger'>{$message}</div>";
    } else {
        echo "<div class='alert alert-info'>{$message}</div>";
    }
}
echo "</div>
    
    <div class='mt-4'>
        <a href='index.php?page=cities' class='btn btn-primary'>Şehirler Sayfasına Dön</a>
    </div>
    </div>
</body>
</html>";