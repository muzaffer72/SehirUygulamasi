CREATE TABLE IF NOT EXISTS award_types (
  id integer,
  name character varying(100),
  description text,
  icon_url text,
  badge_url text,
  color character varying(20),
  points integer,
  created_at timestamp without time zone,
  is_system boolean,
  icon character varying(100),
  min_rate numeric,
  max_rate numeric,
  badge_color character varying(20)
);

INSERT INTO award_types (id, name, description, icon_url, badge_url, color, points, created_at, is_system, icon, min_rate, max_rate, badge_color) VALUES ('11', 'Bronz Belediye Ödülü', 'Şikayet çözüm oranı %25 ile %50 arasında olan belediyeler', NULL, NULL, '#CD7F32', '100', '2025-04-11 20:30:18.184388', '', 'bronze_medal.png', '25.00', '49.99', '#CD7F32');
INSERT INTO award_types (id, name, description, icon_url, badge_url, color, points, created_at, is_system, icon, min_rate, max_rate, badge_color) VALUES ('12', 'Gümüş Belediye Ödülü', 'Şikayet çözüm oranı %50 ile %75 arasında olan belediyeler', NULL, NULL, '#C0C0C0', '200', '2025-04-11 20:30:18.184388', '', 'silver_medal.png', '50.00', '74.99', '#C0C0C0');
INSERT INTO award_types (id, name, description, icon_url, badge_url, color, points, created_at, is_system, icon, min_rate, max_rate, badge_color) VALUES ('13', 'Altın Belediye Ödülü', 'Şikayet çözüm oranı %75 ve üzerinde olan belediyeler', NULL, NULL, '#FFD700', '300', '2025-04-11 20:30:18.184388', '', 'gold_medal.png', '75.00', '100.00', '#FFD700');
INSERT INTO award_types (id, name, description, icon_url, badge_url, color, points, created_at, is_system, icon, min_rate, max_rate, badge_color) VALUES ('14', 'Bronz Kupa', 'Sorun çözme oranı %25-49 arası olan belediyeler için verilen otomatik ödül.', NULL, NULL, '#CD7F32', '50', '2025-04-12 23:43:12.766874', '1', 'bi-trophy', '0.00', '100.00', NULL);
INSERT INTO award_types (id, name, description, icon_url, badge_url, color, points, created_at, is_system, icon, min_rate, max_rate, badge_color) VALUES ('15', 'Gümüş Kupa', 'Sorun çözme oranı %50-74 arası olan belediyeler için verilen otomatik ödül.', NULL, NULL, '#C0C0C0', '100', '2025-04-12 23:43:12.922126', '1', 'bi-trophy-fill', '0.00', '100.00', NULL);
INSERT INTO award_types (id, name, description, icon_url, badge_url, color, points, created_at, is_system, icon, min_rate, max_rate, badge_color) VALUES ('16', 'Altın Kupa', 'Sorun çözme oranı %75 ve üzeri olan belediyeler için verilen otomatik ödül.', NULL, NULL, '#FFD700', '200', '2025-04-12 23:43:13.07078', '1', 'bi-trophy-fill', '0.00', '100.00', NULL);
