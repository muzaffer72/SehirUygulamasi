-- ŞikayetVar Veritabanı Yedeği
-- Tablo: award_types
-- Tarih: 2025-04-13 19:14:38

START TRANSACTION;

DROP TABLE IF EXISTS "award_types";

CREATE TABLE IF NOT EXISTS "award_types" (
  "id" integer NOT NULL DEFAULT nextval('award_types_id_seq'::regclass),
  "name" character varying(100) NOT NULL,
  "description" text NULL,
  "icon_url" text NULL,
  "badge_url" text NULL,
  "color" character varying(20) NULL,
  "points" integer NOT NULL DEFAULT 0,
  "created_at" timestamp without time zone NULL DEFAULT CURRENT_TIMESTAMP,
  "is_system" boolean NOT NULL DEFAULT false,
  "icon" character varying(100) NULL,
  "min_rate" numeric NULL DEFAULT 0,
  "max_rate" numeric NULL DEFAULT 100,
  "badge_color" character varying(20) NULL,
  PRIMARY KEY ("id")
);

INSERT INTO "award_types" ("id", "name", "description", "icon_url", "badge_url", "color", "points", "created_at", "is_system", "icon", "min_rate", "max_rate", "badge_color") VALUES ('11', 'Bronz Belediye Ödülü', 'Şikayet çözüm oranı %25 ile %50 arasında olan belediyeler', NULL, NULL, '#CD7F32', '100', '2025-04-11 20:30:18.184388', '', 'bronze_medal.png', '25.00', '49.99', '#CD7F32') ON CONFLICT ("id") DO UPDATE SET "name" = EXCLUDED."name", "description" = EXCLUDED."description", "icon_url" = EXCLUDED."icon_url", "badge_url" = EXCLUDED."badge_url", "color" = EXCLUDED."color", "points" = EXCLUDED."points", "created_at" = EXCLUDED."created_at", "is_system" = EXCLUDED."is_system", "icon" = EXCLUDED."icon", "min_rate" = EXCLUDED."min_rate", "max_rate" = EXCLUDED."max_rate", "badge_color" = EXCLUDED."badge_color";
INSERT INTO "award_types" ("id", "name", "description", "icon_url", "badge_url", "color", "points", "created_at", "is_system", "icon", "min_rate", "max_rate", "badge_color") VALUES ('12', 'Gümüş Belediye Ödülü', 'Şikayet çözüm oranı %50 ile %75 arasında olan belediyeler', NULL, NULL, '#C0C0C0', '200', '2025-04-11 20:30:18.184388', '', 'silver_medal.png', '50.00', '74.99', '#C0C0C0') ON CONFLICT ("id") DO UPDATE SET "name" = EXCLUDED."name", "description" = EXCLUDED."description", "icon_url" = EXCLUDED."icon_url", "badge_url" = EXCLUDED."badge_url", "color" = EXCLUDED."color", "points" = EXCLUDED."points", "created_at" = EXCLUDED."created_at", "is_system" = EXCLUDED."is_system", "icon" = EXCLUDED."icon", "min_rate" = EXCLUDED."min_rate", "max_rate" = EXCLUDED."max_rate", "badge_color" = EXCLUDED."badge_color";
INSERT INTO "award_types" ("id", "name", "description", "icon_url", "badge_url", "color", "points", "created_at", "is_system", "icon", "min_rate", "max_rate", "badge_color") VALUES ('13', 'Altın Belediye Ödülü', 'Şikayet çözüm oranı %75 ve üzerinde olan belediyeler', NULL, NULL, '#FFD700', '300', '2025-04-11 20:30:18.184388', '', 'gold_medal.png', '75.00', '100.00', '#FFD700') ON CONFLICT ("id") DO UPDATE SET "name" = EXCLUDED."name", "description" = EXCLUDED."description", "icon_url" = EXCLUDED."icon_url", "badge_url" = EXCLUDED."badge_url", "color" = EXCLUDED."color", "points" = EXCLUDED."points", "created_at" = EXCLUDED."created_at", "is_system" = EXCLUDED."is_system", "icon" = EXCLUDED."icon", "min_rate" = EXCLUDED."min_rate", "max_rate" = EXCLUDED."max_rate", "badge_color" = EXCLUDED."badge_color";
INSERT INTO "award_types" ("id", "name", "description", "icon_url", "badge_url", "color", "points", "created_at", "is_system", "icon", "min_rate", "max_rate", "badge_color") VALUES ('14', 'Bronz Kupa', 'Sorun çözme oranı %25-49 arası olan belediyeler için verilen otomatik ödül.', NULL, NULL, '#CD7F32', '50', '2025-04-12 23:43:12.766874', '1', 'bi-trophy', '0.00', '100.00', NULL) ON CONFLICT ("id") DO UPDATE SET "name" = EXCLUDED."name", "description" = EXCLUDED."description", "icon_url" = EXCLUDED."icon_url", "badge_url" = EXCLUDED."badge_url", "color" = EXCLUDED."color", "points" = EXCLUDED."points", "created_at" = EXCLUDED."created_at", "is_system" = EXCLUDED."is_system", "icon" = EXCLUDED."icon", "min_rate" = EXCLUDED."min_rate", "max_rate" = EXCLUDED."max_rate", "badge_color" = EXCLUDED."badge_color";
INSERT INTO "award_types" ("id", "name", "description", "icon_url", "badge_url", "color", "points", "created_at", "is_system", "icon", "min_rate", "max_rate", "badge_color") VALUES ('15', 'Gümüş Kupa', 'Sorun çözme oranı %50-74 arası olan belediyeler için verilen otomatik ödül.', NULL, NULL, '#C0C0C0', '100', '2025-04-12 23:43:12.922126', '1', 'bi-trophy-fill', '0.00', '100.00', NULL) ON CONFLICT ("id") DO UPDATE SET "name" = EXCLUDED."name", "description" = EXCLUDED."description", "icon_url" = EXCLUDED."icon_url", "badge_url" = EXCLUDED."badge_url", "color" = EXCLUDED."color", "points" = EXCLUDED."points", "created_at" = EXCLUDED."created_at", "is_system" = EXCLUDED."is_system", "icon" = EXCLUDED."icon", "min_rate" = EXCLUDED."min_rate", "max_rate" = EXCLUDED."max_rate", "badge_color" = EXCLUDED."badge_color";
INSERT INTO "award_types" ("id", "name", "description", "icon_url", "badge_url", "color", "points", "created_at", "is_system", "icon", "min_rate", "max_rate", "badge_color") VALUES ('16', 'Altın Kupa', 'Sorun çözme oranı %75 ve üzeri olan belediyeler için verilen otomatik ödül.', NULL, NULL, '#FFD700', '200', '2025-04-12 23:43:13.07078', '1', 'bi-trophy-fill', '0.00', '100.00', NULL) ON CONFLICT ("id") DO UPDATE SET "name" = EXCLUDED."name", "description" = EXCLUDED."description", "icon_url" = EXCLUDED."icon_url", "badge_url" = EXCLUDED."badge_url", "color" = EXCLUDED."color", "points" = EXCLUDED."points", "created_at" = EXCLUDED."created_at", "is_system" = EXCLUDED."is_system", "icon" = EXCLUDED."icon", "min_rate" = EXCLUDED."min_rate", "max_rate" = EXCLUDED."max_rate", "badge_color" = EXCLUDED."badge_color";

COMMIT;
