-- ŞikayetVar Veritabanı Yedeği
-- Tablo: city_stats
-- Tarih: 2025-04-13 19:14:40

START TRANSACTION;

DROP TABLE IF EXISTS "city_stats";

CREATE TABLE IF NOT EXISTS "city_stats" (
  "id" integer NOT NULL DEFAULT nextval('city_stats_id_seq'::regclass),
  "city_id" integer NOT NULL,
  "year" character varying(4) NOT NULL,
  "unemployment_rate" numeric NULL DEFAULT 0.00,
  "healthcare_access" numeric NULL DEFAULT 0.00,
  "education_quality" numeric NULL DEFAULT 0.00,
  "infrastructure_quality" numeric NULL DEFAULT 0.00,
  "safety_index" numeric NULL DEFAULT 0.00,
  "cost_of_living" numeric NULL DEFAULT 0.00,
  "created_at" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id")
);


COMMIT;
