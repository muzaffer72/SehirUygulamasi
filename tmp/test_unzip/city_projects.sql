-- ŞikayetVar Veritabanı Yedeği
-- Tablo: city_projects
-- Tarih: 2025-04-13 19:14:39

START TRANSACTION;

DROP TABLE IF EXISTS "city_projects";

CREATE TABLE IF NOT EXISTS "city_projects" (
  "id" integer NOT NULL DEFAULT nextval('city_projects_id_seq'::regclass),
  "city_id" integer NOT NULL,
  "name" character varying(255) NOT NULL,
  "description" text NULL,
  "status" character varying(20) NOT NULL DEFAULT 'planned'::character varying,
  "budget" numeric NULL DEFAULT 0.00,
  "start_date" date NULL,
  "end_date" date NULL,
  "created_at" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id")
);

INSERT INTO "city_projects" ("id", "city_id", "name", "description", "status", "budget", "start_date", "end_date", "created_at", "updated_at") VALUES ('1', '26', 'TEST', 'Test proje', 'planned', '1500000.00', '2025-04-18', '2026-07-01', '2025-04-11 18:18:11.569448', '2025-04-11 18:18:11.569448') ON CONFLICT ("id") DO UPDATE SET "city_id" = EXCLUDED."city_id", "name" = EXCLUDED."name", "description" = EXCLUDED."description", "status" = EXCLUDED."status", "budget" = EXCLUDED."budget", "start_date" = EXCLUDED."start_date", "end_date" = EXCLUDED."end_date", "created_at" = EXCLUDED."created_at", "updated_at" = EXCLUDED."updated_at";

COMMIT;
