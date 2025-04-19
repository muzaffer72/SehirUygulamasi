-- ŞikayetVar Veritabanı Yedeği
-- Tablo: migrations
-- Tarih: 2025-04-19 21:04:27

START TRANSACTION;

CREATE TABLE IF NOT EXISTS migrations (
  "id" integer NOT NULL DEFAULT nextval('migrations_id_seq'::regclass),
  "migration" character varying(255) NOT NULL,
  "batch" integer NOT NULL,
  PRIMARY KEY ("id")
);


COMMIT;
