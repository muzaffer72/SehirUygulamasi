-- ŞikayetVar Veritabanı Yedeği
-- Tablo: city_events
-- Tarih: 2025-04-13 19:14:39

START TRANSACTION;

DROP TABLE IF EXISTS "city_events";

CREATE TABLE IF NOT EXISTS "city_events" (
  "id" integer NOT NULL DEFAULT nextval('city_events_id_seq'::regclass),
  "city_id" integer NOT NULL,
  "name" character varying(255) NOT NULL,
  "description" text NULL,
  "location" character varying(255) NULL,
  "event_date" date NULL,
  "event_time" time without time zone NULL,
  "type" character varying(50) NULL,
  "created_at" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id")
);


COMMIT;
