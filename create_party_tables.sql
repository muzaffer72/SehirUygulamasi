-- Siyasi partiler tablosu
CREATE TABLE IF NOT EXISTS political_parties (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  short_name VARCHAR(50) NOT NULL,
  color VARCHAR(20) NOT NULL DEFAULT '#333333',
  logo_url VARCHAR(255),
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Parti performans tablosu
CREATE TABLE IF NOT EXISTS party_performance (
  id SERIAL PRIMARY KEY,
  party_id INTEGER NOT NULL REFERENCES political_parties(id) ON DELETE CASCADE,
  city_count INTEGER NOT NULL DEFAULT 0,
  district_count INTEGER NOT NULL DEFAULT 0,
  complaint_count INTEGER NOT NULL DEFAULT 0,
  solved_count INTEGER NOT NULL DEFAULT 0,
  problem_solving_rate DECIMAL(5,2) NOT NULL DEFAULT 0,
  last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(party_id)
);

-- Şehir-parti ilişkisi tablosu
CREATE TABLE IF NOT EXISTS city_party_relations (
  id SERIAL PRIMARY KEY,
  city_id INTEGER NOT NULL REFERENCES cities(id) ON DELETE CASCADE,
  party_id INTEGER NOT NULL REFERENCES political_parties(id) ON DELETE CASCADE,
  start_date DATE NOT NULL,
  end_date DATE,
  is_current BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(city_id, party_id, is_current)
);

-- İlçe-parti ilişkisi tablosu
CREATE TABLE IF NOT EXISTS district_party_relations (
  id SERIAL PRIMARY KEY,
  district_id INTEGER NOT NULL REFERENCES districts(id) ON DELETE CASCADE,
  party_id INTEGER NOT NULL REFERENCES political_parties(id) ON DELETE CASCADE,
  start_date DATE NOT NULL,
  end_date DATE,
  is_current BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(district_id, party_id, is_current)
);

-- Örnek parti verileri ekle
INSERT INTO political_parties (name, short_name, color, logo_url) VALUES
('Adalet ve Kalkınma Partisi', 'AK Parti', '#FFA500', 'assets/images/parties/akp.png'),
('Cumhuriyet Halk Partisi', 'CHP', '#FF0000', 'assets/images/parties/chp.png'),
('Milliyetçi Hareket Partisi', 'MHP', '#FF4500', 'assets/images/parties/mhp.png'),
('İyi Parti', 'İYİ Parti', '#1E90FF', 'assets/images/parties/iyi.png'),
('Demokratik Sol Parti', 'DSP', '#FF69B4', 'assets/images/parties/dsp.png'),
('Yeniden Refah Partisi', 'YRP', '#006400', 'assets/images/parties/yrp.png'),
('Büyük Birlik Partisi', 'BBP', '#800080', 'assets/images/parties/bbp.png'),
('Demokrat Parti', 'DP', '#4B0082', 'assets/images/parties/dp.png')
ON CONFLICT (id) DO NOTHING;

-- Örnek performans verileri ekle
INSERT INTO party_performance (party_id, city_count, district_count, complaint_count, solved_count, problem_solving_rate) VALUES
(1, 45, 562, 12750, 8734, 68.5),
(2, 22, 234, 8540, 6080, 71.2),
(3, 8, 102, 3240, 1872, 57.8),
(4, 3, 25, 980, 621, 63.4),
(5, 1, 5, 320, 167, 52.1),
(6, 0, 3, 85, 38, 44.3)
ON CONFLICT (party_id) DO NOTHING;

-- Parti performansını hesaplayan fonksiyon
CREATE OR REPLACE FUNCTION calculate_party_performance()
RETURNS VOID AS $$
BEGIN
  -- Tüm şehirlerin şikayet ve çözüm sayılarını partilere göre grupla
  -- ve performans tablosunu güncelle
  WITH party_stats AS (
    SELECT
      cp.party_id,
      COUNT(DISTINCT cp.city_id) AS city_count,
      COUNT(DISTINCT dp.district_id) AS district_count,
      COUNT(p.id) AS complaint_count,
      COUNT(CASE WHEN p.status = 'resolved' THEN p.id END) AS solved_count,
      CASE
        WHEN COUNT(p.id) > 0 THEN
          (COUNT(CASE WHEN p.status = 'resolved' THEN p.id END)::DECIMAL / COUNT(p.id)::DECIMAL) * 100
        ELSE 0
      END AS problem_solving_rate
    FROM
      city_party_relations cp
      LEFT JOIN district_party_relations dp ON cp.party_id = dp.party_id
      LEFT JOIN posts p ON 
        (p.city_id = cp.city_id OR p.district_id = dp.district_id) AND 
        cp.is_current = TRUE AND
        dp.is_current = TRUE
    WHERE 
      cp.is_current = TRUE
    GROUP BY cp.party_id
  )
  
  -- Parti performans tablosunu güncelle
  INSERT INTO party_performance 
    (party_id, city_count, district_count, complaint_count, solved_count, problem_solving_rate, last_updated)
  SELECT
    ps.party_id,
    ps.city_count,
    ps.district_count,
    ps.complaint_count,
    ps.solved_count,
    ps.problem_solving_rate,
    NOW()
  FROM party_stats ps
  ON CONFLICT (party_id) DO UPDATE SET
    city_count = EXCLUDED.city_count,
    district_count = EXCLUDED.district_count,
    complaint_count = EXCLUDED.complaint_count,
    solved_count = EXCLUDED.solved_count,
    problem_solving_rate = EXCLUDED.problem_solving_rate,
    last_updated = NOW();
END;
$$ LANGUAGE plpgsql;

-- Performans hesaplama fonksiyonunu çalıştıracak trigger ekle
CREATE OR REPLACE FUNCTION update_party_performance_trigger()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM calculate_party_performance();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Posts tablosu üzerinde trigger oluştur
DROP TRIGGER IF EXISTS trigger_update_party_performance ON posts;
CREATE TRIGGER trigger_update_party_performance
AFTER INSERT OR UPDATE OF status ON posts
FOR EACH STATEMENT
EXECUTE FUNCTION update_party_performance_trigger();

-- İlişki tablolarında değişiklik olduğunda da performansı güncelle
DROP TRIGGER IF EXISTS trigger_update_party_performance_relations ON city_party_relations;
CREATE TRIGGER trigger_update_party_performance_relations
AFTER INSERT OR UPDATE OF is_current ON city_party_relations
FOR EACH STATEMENT
EXECUTE FUNCTION update_party_performance_trigger();

DROP TRIGGER IF EXISTS trigger_update_party_performance_district ON district_party_relations;
CREATE TRIGGER trigger_update_party_performance_district
AFTER INSERT OR UPDATE OF is_current ON district_party_relations
FOR EACH STATEMENT
EXECUTE FUNCTION update_party_performance_trigger();