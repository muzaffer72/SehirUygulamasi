-- ŞikayetVar Veritabanı Yedeği
-- Tablo: migrations
-- Tarih: 2025-04-13 19:14:41

START TRANSACTION;

DROP TABLE IF EXISTS "migrations";

CREATE TABLE IF NOT EXISTS "migrations" (
  "id" integer NOT NULL DEFAULT nextval('migrations_id_seq'::regclass),
  "migration" character varying(255) NOT NULL,
  "batch" integer NOT NULL,
  PRIMARY KEY ("id")
);


COMMIT;
