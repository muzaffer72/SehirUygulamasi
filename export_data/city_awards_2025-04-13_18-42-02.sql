CREATE TABLE IF NOT EXISTS city_awards (
  id integer,
  city_id integer,
  award_type_id integer,
  title character varying(255),
  description text,
  award_date date,
  issuer character varying(100),
  certificate_url text,
  featured boolean,
  project_id integer,
  created_at timestamp without time zone,
  expiry_date date
);

INSERT INTO city_awards (id, city_id, award_type_id, title, description, award_date, issuer, certificate_url, featured, project_id, created_at, expiry_date) VALUES ('4', '57', '13', 'Altın Belediye Ödülü Ödülü', 'AFYONKARAHİSAR Şikayet çözüm oranı %75 ve üzerinde olan belediyeler', '2025-04-12', NULL, NULL, '', NULL, '2025-04-12 08:11:33.770746', '2025-05-12');
INSERT INTO city_awards (id, city_id, award_type_id, title, description, award_date, issuer, certificate_url, featured, project_id, created_at, expiry_date) VALUES ('5', '57', '13', 'Altın Belediye Ödülü Ödülü', 'AFYONKARAHİSAR Şikayet çözüm oranı %75 ve üzerinde olan belediyeler', '2025-04-12', NULL, NULL, '', NULL, '2025-04-12 08:12:02.786476', '2025-05-12');
