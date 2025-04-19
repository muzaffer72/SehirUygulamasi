-- ŞikayetVar Veritabanı Yedeği
-- Tablo: before_after_records
-- Tarih: 2025-04-19 21:04:27

START TRANSACTION;

CREATE TABLE IF NOT EXISTS before_after_records (
  "id" integer NOT NULL DEFAULT nextval('before_after_records_id_seq'::regclass),
  "post_id" integer NOT NULL,
  "before_image_url" text NOT NULL,
  "after_image_url" text NOT NULL,
  "description" text NULL,
  "recorded_by" integer NULL,
  "record_date" timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "created_at" timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id")
);


COMMIT;
