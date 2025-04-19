-- ŞikayetVar Veritabanı Yedeği
-- Tablo: city_services
-- Tarih: 2025-04-19 21:04:27

START TRANSACTION;

CREATE TABLE IF NOT EXISTS city_services (
  "id" integer NOT NULL DEFAULT nextval('city_services_id_seq'::regclass),
  "city_id" integer NOT NULL,
  "name" character varying(255) NOT NULL,
  "description" text NULL,
  "address" character varying(255) NULL,
  "phone" character varying(50) NULL,
  "website" character varying(255) NULL,
  "type" character varying(50) NULL,
  "created_at" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id")
);


COMMIT;
