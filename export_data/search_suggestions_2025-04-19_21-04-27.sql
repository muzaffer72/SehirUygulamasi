-- ŞikayetVar Veritabanı Yedeği
-- Tablo: search_suggestions
-- Tarih: 2025-04-19 21:04:27

START TRANSACTION;

CREATE TABLE IF NOT EXISTS search_suggestions (
  "id" integer NOT NULL DEFAULT nextval('search_suggestions_id_seq'::regclass),
  "text" character varying(100) NOT NULL,
  "display_order" integer NULL DEFAULT 0,
  "is_active" boolean NULL DEFAULT true,
  "created_at" timestamp without time zone NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamp without time zone NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id")
);


COMMIT;
