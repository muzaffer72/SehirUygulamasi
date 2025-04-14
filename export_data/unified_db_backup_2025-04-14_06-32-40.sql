-- ŞikayetVar Veritabanı Birleştirilmiş Yedeği
-- Tarih: 2025-04-14 06:32:40
-- Bu dosya, veritabanının doğru sırayla (önce tablolar, sonra veriler, son olarak ilişkiler) içe aktarılmasını sağlar

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

START TRANSACTION;

-- 1. ADIM: TABLO YAPILARINI OLUŞTUR
-- -----------------------------

CREATE SEQUENCE IF NOT EXISTS "award_types_id_seq";

CREATE TABLE "award_types" (
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

