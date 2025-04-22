-- ŞikayetVar Veritabanı Birleştirilmiş Yedeği
-- Tarih: 2025-04-21 21:50:33
-- Bu dosya, veritabanının doğru sırayla (önce tablolar, sonra veriler, son olarak ilişkiler) içe aktarılmasını sağlar

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

START TRANSACTION;

-- 1. ADIM: TABLO YAPILARINI OLUŞTUR
-- -----------------------------

DROP TABLE IF EXISTS "api_keys" CASCADE;
DROP SEQUENCE IF EXISTS "api_keys_id_seq" CASCADE;
CREATE SEQUENCE IF NOT EXISTS "api_keys_id_seq";

CREATE TABLE "api_keys" (
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

DROP TABLE IF EXISTS "award_types" CASCADE;
DROP SEQUENCE IF EXISTS "award_types_id_seq" CASCADE;
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

DROP TABLE IF EXISTS "banned_words" CASCADE;
DROP SEQUENCE IF EXISTS "banned_words_id_seq" CASCADE;
CREATE SEQUENCE IF NOT EXISTS "banned_words_id_seq";

CREATE TABLE "banned_words" (
  "id" integer NOT NULL DEFAULT nextval('banned_words_id_seq'::regclass),
  "word" character varying(100) NOT NULL,
  "created_at" timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id")
);

DROP TABLE IF EXISTS "categories" CASCADE;
DROP SEQUENCE IF EXISTS "categories_id_seq" CASCADE;
CREATE SEQUENCE IF NOT EXISTS "categories_id_seq";

CREATE TABLE "categories" (
  "id" integer NOT NULL DEFAULT nextval('categories_id_seq'::regclass),
  "name" character varying(100) NOT NULL,
  "icon_name" character varying(50) NULL,
  "created_at" timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id")
);

DROP TABLE IF EXISTS "cities" CASCADE;
DROP SEQUENCE IF EXISTS "cities_id_seq" CASCADE;
CREATE SEQUENCE IF NOT EXISTS "cities_id_seq";

CREATE TABLE "cities" (
  "id" integer NOT NULL DEFAULT nextval('cities_id_seq'::regclass),
  "name" character varying(100) NOT NULL,
  "created_at" timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "description" text NULL,
  "population" integer NULL DEFAULT 0,
  "area" integer NULL DEFAULT 0,
  "mayor_name" character varying(255) NULL,
  "mayor_party" character varying(100) NULL,
  "website" character varying(255) NULL,
  "phone" character varying(50) NULL,
  "email" character varying(255) NULL,
  "social_media" character varying(255) NULL,
  "problem_solving_rate" integer NULL DEFAULT 0,
  PRIMARY KEY ("id")
);

DROP TABLE IF EXISTS "migrations" CASCADE;
DROP SEQUENCE IF EXISTS "migrations_id_seq" CASCADE;
CREATE SEQUENCE IF NOT EXISTS "migrations_id_seq";

CREATE TABLE "migrations" (
  "id" integer NOT NULL DEFAULT nextval('migrations_id_seq'::regclass),
  "migration" character varying(255) NOT NULL,
  "batch" integer NOT NULL,
  PRIMARY KEY ("id")
);

DROP TABLE IF EXISTS "search_suggestions" CASCADE;
DROP SEQUENCE IF EXISTS "search_suggestions_id_seq" CASCADE;
CREATE SEQUENCE IF NOT EXISTS "search_suggestions_id_seq";

CREATE TABLE "search_suggestions" (
  "id" integer NOT NULL DEFAULT nextval('search_suggestions_id_seq'::regclass),
  "text" character varying(100) NOT NULL,
  "display_order" integer NULL DEFAULT 0,
  "is_active" boolean NULL DEFAULT true,
  "created_at" timestamp without time zone NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamp without time zone NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id")
);

DROP TABLE IF EXISTS "settings" CASCADE;
CREATE TABLE "settings" (
  "id" integer NOT NULL,
  "site_name" character varying(100) NOT NULL DEFAULT 'ŞikayetVar'::character varying,
  "site_description" text NULL,
  "admin_email" character varying(255) NULL,
  "maintenance_mode" boolean NULL DEFAULT false,
  "email_notifications" boolean NULL DEFAULT true,
  "push_notifications" boolean NULL DEFAULT true,
  "new_post_notifications" boolean NULL DEFAULT true,
  "new_user_notifications" boolean NULL DEFAULT true,
  "api_key" character varying(100) NULL,
  "webhook_url" character varying(255) NULL,
  "created_at" timestamp without time zone NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamp without time zone NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id")
);

DROP TABLE IF EXISTS "surveys" CASCADE;
DROP SEQUENCE IF EXISTS "surveys_id_seq" CASCADE;
CREATE SEQUENCE IF NOT EXISTS "surveys_id_seq";

CREATE TABLE "surveys" (
  "id" integer NOT NULL DEFAULT nextval('surveys_id_seq'::regclass),
  "title" character varying(255) NOT NULL,
  "short_title" character varying(100) NOT NULL,
  "description" text NOT NULL,
  "category_id" integer NOT NULL,
  "scope_type" character varying(20) NOT NULL,
  "city_id" integer NULL,
  "district_id" integer NULL,
  "start_date" date NOT NULL,
  "end_date" date NOT NULL,
  "total_users" integer NOT NULL DEFAULT 1000,
  "is_active" boolean NOT NULL DEFAULT true,
  "created_at" timestamp without time zone NULL DEFAULT CURRENT_TIMESTAMP,
  "is_pinned" boolean NULL DEFAULT false,
  PRIMARY KEY ("id")
);

DROP TABLE IF EXISTS "city_events" CASCADE;
DROP SEQUENCE IF EXISTS "city_events_id_seq" CASCADE;
CREATE SEQUENCE IF NOT EXISTS "city_events_id_seq";

CREATE TABLE "city_events" (
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

DROP TABLE IF EXISTS "city_projects" CASCADE;
DROP SEQUENCE IF EXISTS "city_projects_id_seq" CASCADE;
CREATE SEQUENCE IF NOT EXISTS "city_projects_id_seq";

CREATE TABLE "city_projects" (
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

DROP TABLE IF EXISTS "city_services" CASCADE;
DROP SEQUENCE IF EXISTS "city_services_id_seq" CASCADE;
CREATE SEQUENCE IF NOT EXISTS "city_services_id_seq";

