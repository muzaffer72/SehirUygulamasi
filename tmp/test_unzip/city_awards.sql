-- ŞikayetVar Veritabanı Yedeği
-- Tablo: city_awards
-- Tarih: 2025-04-13 19:14:39

START TRANSACTION;

DROP TABLE IF EXISTS "city_awards";

CREATE TABLE IF NOT EXISTS "city_awards" (
  "id" integer NOT NULL DEFAULT nextval('city_awards_id_seq'::regclass),
  "city_id" integer NOT NULL,
  "award_type_id" integer NOT NULL,
  "title" character varying(255) NOT NULL,
  "description" text NULL,
  "award_date" date NOT NULL,
  "issuer" character varying(100) NULL,
  "certificate_url" text NULL,
  "featured" boolean NOT NULL DEFAULT false,
  "project_id" integer NULL,
  "created_at" timestamp without time zone NULL DEFAULT CURRENT_TIMESTAMP,
  "expiry_date" date NULL,
  PRIMARY KEY ("id")
);

INSERT INTO "city_awards" ("id", "city_id", "award_type_id", "title", "description", "award_date", "issuer", "certificate_url", "featured", "project_id", "created_at", "expiry_date") VALUES ('4', '57', '13', 'Altın Belediye Ödülü Ödülü', 'AFYONKARAHİSAR Şikayet çözüm oranı %75 ve üzerinde olan belediyeler', '2025-04-12', NULL, NULL, '', NULL, '2025-04-12 08:11:33.770746', '2025-05-12') ON CONFLICT ("id") DO UPDATE SET "city_id" = EXCLUDED."city_id", "award_type_id" = EXCLUDED."award_type_id", "title" = EXCLUDED."title", "description" = EXCLUDED."description", "award_date" = EXCLUDED."award_date", "issuer" = EXCLUDED."issuer", "certificate_url" = EXCLUDED."certificate_url", "featured" = EXCLUDED."featured", "project_id" = EXCLUDED."project_id", "created_at" = EXCLUDED."created_at", "expiry_date" = EXCLUDED."expiry_date";
INSERT INTO "city_awards" ("id", "city_id", "award_type_id", "title", "description", "award_date", "issuer", "certificate_url", "featured", "project_id", "created_at", "expiry_date") VALUES ('5', '57', '13', 'Altın Belediye Ödülü Ödülü', 'AFYONKARAHİSAR Şikayet çözüm oranı %75 ve üzerinde olan belediyeler', '2025-04-12', NULL, NULL, '', NULL, '2025-04-12 08:12:02.786476', '2025-05-12') ON CONFLICT ("id") DO UPDATE SET "city_id" = EXCLUDED."city_id", "award_type_id" = EXCLUDED."award_type_id", "title" = EXCLUDED."title", "description" = EXCLUDED."description", "award_date" = EXCLUDED."award_date", "issuer" = EXCLUDED."issuer", "certificate_url" = EXCLUDED."certificate_url", "featured" = EXCLUDED."featured", "project_id" = EXCLUDED."project_id", "created_at" = EXCLUDED."created_at", "expiry_date" = EXCLUDED."expiry_date";

COMMIT;
