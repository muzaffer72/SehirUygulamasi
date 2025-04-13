-- Siyasi Partiler Tablosu
CREATE TABLE IF NOT EXISTS political_parties (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  short_name VARCHAR(10) NOT NULL UNIQUE,
  description TEXT,
  logo_url TEXT NOT NULL,
  color VARCHAR(7) NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  founded_year INTEGER,
  website VARCHAR(255),
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Parti Performans İstatistikleri Tablosu
CREATE TABLE IF NOT EXISTS party_performance_stats (
  id SERIAL PRIMARY KEY,
  party_id INTEGER NOT NULL REFERENCES political_parties(id) ON DELETE CASCADE,
  total_municipality_count INTEGER NOT NULL DEFAULT 0,
  problem_solving_rate DECIMAL(5,2) NOT NULL DEFAULT 0,
  average_satisfaction_rate DECIMAL(5,2) NOT NULL DEFAULT 0,
  total_awards INTEGER NOT NULL DEFAULT 0,
  gold_awards INTEGER NOT NULL DEFAULT 0,
  silver_awards INTEGER NOT NULL DEFAULT 0,
  bronze_awards INTEGER NOT NULL DEFAULT 0,
  last_calculated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Örnek Parti Verileri (Türkiye'deki ana partiler)
INSERT INTO political_parties (name, short_name, description, logo_url, color, founded_year, sort_order)
VALUES 
('Adalet ve Kalkınma Partisi', 'AKP', 'Adalet ve Kalkınma Partisi (AKP veya AK Parti), Türkiye''de merkez sağ bir siyasi partidir.', '/assets/party_logos/akp_logo.png', '#FFA500', 2001, 1),
('Cumhuriyet Halk Partisi', 'CHP', 'Cumhuriyet Halk Partisi (CHP), Türkiye''nin en eski siyasi partisidir.', '/assets/party_logos/chp_logo.png', '#FF0000', 1923, 2),
('Milliyetçi Hareket Partisi', 'MHP', 'Milliyetçi Hareket Partisi (MHP), Türkiye''de milliyetçi bir siyasi partidir.', '/assets/party_logos/mhp_logo.png', '#0000FF', 1969, 3),
('İyi Parti', 'İYİP', 'İyi Parti, Türkiye''de merkez sağ bir siyasi partidir.', '/assets/party_logos/iyip_logo.png', '#00BFFF', 2017, 4),
('Halkların Demokratik Partisi', 'HDP', 'Halkların Demokratik Partisi (HDP), Türkiye''de sol görüşlü bir siyasi partidir.', '/assets/party_logos/hdp_logo.png', '#800080', 2012, 5),
('Demokrat Parti', 'DP', 'Demokrat Parti (DP), Türkiye''de merkez sağ bir siyasi partidir.', '/assets/party_logos/dp_logo.png', '#FF4500', 2007, 6),
('Bağımsız', 'Bağımsız', 'Herhangi bir partiye bağlı olmayan belediye başkanları', '/assets/party_logos/independent_logo.png', '#808080', NULL, 99);

-- Parti Performans İstatistiklerini Hesaplama Fonksiyonu
CREATE OR REPLACE FUNCTION update_party_performance_stats()
RETURNS VOID AS $$
BEGIN
  -- Mevcut istatistikleri temizle
  DELETE FROM party_performance_stats;
  
  -- Her parti için istatistikleri yeniden hesapla ve ekle
  INSERT INTO party_performance_stats (
    party_id, 
    total_municipality_count,
    problem_solving_rate,
    average_satisfaction_rate,
    total_awards,
    gold_awards,
    silver_awards,
    bronze_awards,
    last_calculated_at
  )
  SELECT 
    p.id as party_id,
    COUNT(c.id) as total_municipality_count,
    COALESCE(AVG(c.problem_solving_rate), 0) as problem_solving_rate,
    COALESCE(AVG(c.mayor_satisfaction_rate), 0) as average_satisfaction_rate,
    COUNT(ca.id) as total_awards,
    COUNT(CASE WHEN at.name = 'Altın Ödül' THEN ca.id END) as gold_awards,
    COUNT(CASE WHEN at.name = 'Gümüş Ödül' THEN ca.id END) as silver_awards,
    COUNT(CASE WHEN at.name = 'Bronz Ödül' THEN ca.id END) as bronze_awards,
    NOW() as last_calculated_at
  FROM 
    political_parties p
    LEFT JOIN cities c ON LOWER(p.name) = LOWER(c.mayor_party) OR LOWER(p.short_name) = LOWER(c.mayor_party)
    LEFT JOIN city_awards ca ON c.id = ca.city_id
    LEFT JOIN award_types at ON ca.award_type_id = at.id
  GROUP BY 
    p.id;
END;
$$ LANGUAGE plpgsql;

-- İstatistikleri güncelle
SELECT update_party_performance_stats();

-- Sorgulama örneği
SELECT 
  p.name, 
  p.short_name, 
  ps.problem_solving_rate, 
  ps.total_municipality_count,
  ps.total_awards
FROM 
  political_parties p
  JOIN party_performance_stats ps ON p.id = ps.party_id
ORDER BY 
  ps.problem_solving_rate DESC, 
  p.sort_order;