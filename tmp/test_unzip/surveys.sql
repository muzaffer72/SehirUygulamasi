-- ŞikayetVar Veritabanı Yedeği
-- Tablo: surveys
-- Tarih: 2025-04-13 19:14:42

START TRANSACTION;

DROP TABLE IF EXISTS "surveys";

CREATE TABLE IF NOT EXISTS "surveys" (
  "id" integer NOT NULL DEFAULT nextval('surveys_id_seq'::regclass),
  "title" character varying(255) NOT NULL,
  "short_title" character varying(100) NOT NULL,
  "description" text NOT NULL,
  "category_id" integer NOT NULL,
  "scope_type" character varying(20) NOT NULL,
  "city_id" integer NULL,
  "district_id" integer NULL,
  "start_date" date NOT NULL,
  "end_date" date NOT NULL,
  "total_users" integer NOT NULL DEFAULT 1000,
  "is_active" boolean NOT NULL DEFAULT true,
  "created_at" timestamp without time zone NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id")
);

INSERT INTO "surveys" ("id", "title", "short_title", "description", "category_id", "scope_type", "city_id", "district_id", "start_date", "end_date", "total_users", "is_active", "created_at") VALUES ('1', 'Şehir İçi Ulaşım Memnuniyeti', 'Ulaşım Anketi', 'Bu anket, şehirdeki toplu taşıma ve ulaşım hizmetleri hakkında vatandaş memnuniyetini ölçmek için hazırlanmıştır.', '3', 'general', NULL, NULL, '2025-04-11', '2025-05-11', '5000', '1', '2025-04-11 16:50:41.99223') ON CONFLICT ("id") DO UPDATE SET "title" = EXCLUDED."title", "short_title" = EXCLUDED."short_title", "description" = EXCLUDED."description", "category_id" = EXCLUDED."category_id", "scope_type" = EXCLUDED."scope_type", "city_id" = EXCLUDED."city_id", "district_id" = EXCLUDED."district_id", "start_date" = EXCLUDED."start_date", "end_date" = EXCLUDED."end_date", "total_users" = EXCLUDED."total_users", "is_active" = EXCLUDED."is_active", "created_at" = EXCLUDED."created_at";
INSERT INTO "surveys" ("id", "title", "short_title", "description", "category_id", "scope_type", "city_id", "district_id", "start_date", "end_date", "total_users", "is_active", "created_at") VALUES ('2', 'Belediye Hizmetleri Değerlendirme', 'Belediye Hizmetleri', 'Belediyenin sunduğu hizmetlerden memnuniyet düzeyinizi belirtiniz.', '10', 'city', '34', NULL, '2025-04-11', '2025-05-11', '3000', '1', '2025-04-11 16:50:42.212246') ON CONFLICT ("id") DO UPDATE SET "title" = EXCLUDED."title", "short_title" = EXCLUDED."short_title", "description" = EXCLUDED."description", "category_id" = EXCLUDED."category_id", "scope_type" = EXCLUDED."scope_type", "city_id" = EXCLUDED."city_id", "district_id" = EXCLUDED."district_id", "start_date" = EXCLUDED."start_date", "end_date" = EXCLUDED."end_date", "total_users" = EXCLUDED."total_users", "is_active" = EXCLUDED."is_active", "created_at" = EXCLUDED."created_at";
INSERT INTO "surveys" ("id", "title", "short_title", "description", "category_id", "scope_type", "city_id", "district_id", "start_date", "end_date", "total_users", "is_active", "created_at") VALUES ('3', 'Çevre Temizliği ve Atık Yönetimi', 'Çevre Temizliği', 'Yaşadığınız bölgede çevre temizliği ve atık yönetimi hakkındaki düşünceleriniz nelerdir?', '2', 'district', '34', '1', '2025-04-11', '2025-05-11', '2000', '1', '2025-04-11 16:50:42.421007') ON CONFLICT ("id") DO UPDATE SET "title" = EXCLUDED."title", "short_title" = EXCLUDED."short_title", "description" = EXCLUDED."description", "category_id" = EXCLUDED."category_id", "scope_type" = EXCLUDED."scope_type", "city_id" = EXCLUDED."city_id", "district_id" = EXCLUDED."district_id", "start_date" = EXCLUDED."start_date", "end_date" = EXCLUDED."end_date", "total_users" = EXCLUDED."total_users", "is_active" = EXCLUDED."is_active", "created_at" = EXCLUDED."created_at";

COMMIT;
