-- ŞikayetVar Veritabanı Yedeği
-- Tablo: api_keys
-- Tarih: 2025-04-19 21:04:26

START TRANSACTION;

CREATE TABLE IF NOT EXISTS api_keys (
  "id" integer NOT NULL DEFAULT nextval('api_keys_id_seq'::regclass),
  "api_key" character varying(255) NOT NULL,
  "name" character varying(100) NOT NULL,
  "description" text NULL,
  "active" boolean NULL DEFAULT true,
  "usage_count" integer NULL DEFAULT 0,
  "last_used" timestamp without time zone NULL,
  "created_at" timestamp without time zone NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id")
);

INSERT INTO api_keys ("id", "api_key", "name", "description", "active", "usage_count", "last_used", "created_at") VALUES ('1', '440bf0009c749943b440f7f5c6c2fd26', 'Flutter API Key', 'API Anahtarı - Mobil Uygulama (Flutter)', 't', '17', '2025-04-19 18:22:35.579393', '2025-04-19 16:46:55.259993') ON CONFLICT ("id") DO UPDATE SET "api_key" = EXCLUDED."api_key", "name" = EXCLUDED."name", "description" = EXCLUDED."description", "active" = EXCLUDED."active", "usage_count" = EXCLUDED."usage_count", "last_used" = EXCLUDED."last_used", "created_at" = EXCLUDED."created_at";

COMMIT;
