CREATE TABLE IF NOT EXISTS surveys (
  id integer,
  title character varying(255),
  short_title character varying(100),
  description text,
  category_id integer,
  scope_type character varying(20),
  city_id integer,
  district_id integer,
  start_date date,
  end_date date,
  total_users integer,
  is_active boolean,
  created_at timestamp without time zone
);

INSERT INTO surveys (id, title, short_title, description, category_id, scope_type, city_id, district_id, start_date, end_date, total_users, is_active, created_at) VALUES ('1', 'Şehir İçi Ulaşım Memnuniyeti', 'Ulaşım Anketi', 'Bu anket, şehirdeki toplu taşıma ve ulaşım hizmetleri hakkında vatandaş memnuniyetini ölçmek için hazırlanmıştır.', '3', 'general', NULL, NULL, '2025-04-11', '2025-05-11', '5000', '1', '2025-04-11 16:50:41.99223');
INSERT INTO surveys (id, title, short_title, description, category_id, scope_type, city_id, district_id, start_date, end_date, total_users, is_active, created_at) VALUES ('2', 'Belediye Hizmetleri Değerlendirme', 'Belediye Hizmetleri', 'Belediyenin sunduğu hizmetlerden memnuniyet düzeyinizi belirtiniz.', '10', 'city', '34', NULL, '2025-04-11', '2025-05-11', '3000', '1', '2025-04-11 16:50:42.212246');
INSERT INTO surveys (id, title, short_title, description, category_id, scope_type, city_id, district_id, start_date, end_date, total_users, is_active, created_at) VALUES ('3', 'Çevre Temizliği ve Atık Yönetimi', 'Çevre Temizliği', 'Yaşadığınız bölgede çevre temizliği ve atık yönetimi hakkındaki düşünceleriniz nelerdir?', '2', 'district', '34', '1', '2025-04-11', '2025-05-11', '2000', '1', '2025-04-11 16:50:42.421007');
