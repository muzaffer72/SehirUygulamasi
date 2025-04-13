-- ŞikayetVar Veritabanı Birleştirilmiş Yedeği
-- Tarih: 2025-04-13 21:47:53
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

CREATE SEQUENCE IF NOT EXISTS "banned_words_id_seq";

CREATE TABLE "banned_words" (
  "id" integer NOT NULL DEFAULT nextval('banned_words_id_seq'::regclass),
  "word" character varying(100) NOT NULL,
  "created_at" timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id")
);

CREATE SEQUENCE IF NOT EXISTS "categories_id_seq";

CREATE TABLE "categories" (
  "id" integer NOT NULL DEFAULT nextval('categories_id_seq'::regclass),
  "name" character varying(100) NOT NULL,
  "icon_name" character varying(50) NULL,
  "created_at" timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id")
);

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

CREATE SEQUENCE IF NOT EXISTS "migrations_id_seq";

CREATE TABLE "migrations" (
  "id" integer NOT NULL DEFAULT nextval('migrations_id_seq'::regclass),
  "migration" character varying(255) NOT NULL,
  "batch" integer NOT NULL,
  PRIMARY KEY ("id")
);

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
  PRIMARY KEY ("id")
);

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

CREATE SEQUENCE IF NOT EXISTS "city_services_id_seq";

CREATE TABLE "city_services" (
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

CREATE SEQUENCE IF NOT EXISTS "city_stats_id_seq";

CREATE TABLE "city_stats" (
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

CREATE SEQUENCE IF NOT EXISTS "districts_id_seq";

CREATE TABLE "districts" (
  "id" integer NOT NULL DEFAULT nextval('districts_id_seq'::regclass),
  "name" character varying(100) NOT NULL,
  "city_id" integer NOT NULL,
  "created_at" timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "problem_solving_rate" integer NULL DEFAULT 0,
  PRIMARY KEY ("id")
);

CREATE SEQUENCE IF NOT EXISTS "survey_options_id_seq";

CREATE TABLE "survey_options" (
  "id" integer NOT NULL DEFAULT nextval('survey_options_id_seq'::regclass),
  "survey_id" integer NOT NULL,
  "text" character varying(255) NOT NULL,
  "vote_count" integer NOT NULL DEFAULT 0,
  PRIMARY KEY ("id")
);

CREATE SEQUENCE IF NOT EXISTS "survey_regional_results_id_seq";

CREATE TABLE "survey_regional_results" (
  "id" integer NOT NULL DEFAULT nextval('survey_regional_results_id_seq'::regclass),
  "survey_id" integer NOT NULL,
  "option_id" integer NOT NULL,
  "region_type" character varying(20) NOT NULL,
  "region_id" integer NOT NULL,
  "vote_count" integer NOT NULL DEFAULT 0,
  PRIMARY KEY ("id")
);

CREATE SEQUENCE IF NOT EXISTS "users_id_seq";

CREATE TABLE "users" (
  "id" integer NOT NULL DEFAULT nextval('users_id_seq'::regclass),
  "name" character varying(100) NOT NULL,
  "email" character varying(255) NOT NULL,
  "password" character varying(255) NOT NULL,
  "profile_image_url" text NULL,
  "bio" text NULL,
  "city_id" integer NULL,
  "district_id" integer NULL,
  "is_verified" boolean NOT NULL DEFAULT false,
  "points" integer NOT NULL DEFAULT 0,
  "post_count" integer NOT NULL DEFAULT 0,
  "comment_count" integer NOT NULL DEFAULT 0,
  "level" character varying(20) NOT NULL DEFAULT 'newUser'::character varying,
  "created_at" timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "username" character varying(100) NULL,
  PRIMARY KEY ("id")
);

CREATE SEQUENCE IF NOT EXISTS "city_awards_id_seq";

CREATE TABLE "city_awards" (
  "id" integer NOT NULL DEFAULT nextval('city_awards_id_seq'::regclass),
  "city_id" integer NOT NULL,
  "award_type_id" integer NOT NULL,
  "title" character varying(255) NOT NULL,
  "description" text NULL,
  "award_date" date NOT NULL,
  "issuer" character varying(100) NULL,
  "certificate_url" text NULL,
  "featured" boolean NOT NULL DEFAULT false,
  "project_id" integer NULL,
  "created_at" timestamp without time zone NULL DEFAULT CURRENT_TIMESTAMP,
  "expiry_date" date NULL,
  PRIMARY KEY ("id")
);

CREATE SEQUENCE IF NOT EXISTS "notifications_id_seq";

CREATE TABLE "notifications" (
  "id" integer NOT NULL DEFAULT nextval('notifications_id_seq'::regclass),
  "user_id" integer NOT NULL,
  "title" character varying(255) NOT NULL,
  "content" text NOT NULL,
  "type" character varying(50) NOT NULL,
  "is_read" boolean NOT NULL DEFAULT false,
  "source_id" integer NULL,
  "source_type" character varying(50) NULL,
  "data" text NULL,
  "created_at" timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id")
);

CREATE SEQUENCE IF NOT EXISTS "posts_id_seq";

CREATE TABLE "posts" (
  "id" integer NOT NULL DEFAULT nextval('posts_id_seq'::regclass),
  "title" character varying(255) NOT NULL,
  "content" text NOT NULL,
  "user_id" integer NOT NULL,
  "category_id" integer NOT NULL,
  "city_id" integer NULL,
  "district_id" integer NULL,
  "status" character varying(20) NOT NULL DEFAULT 'awaitingSolution'::character varying,
  "type" character varying(20) NOT NULL DEFAULT 'problem'::character varying,
  "likes" integer NOT NULL DEFAULT 0,
  "highlights" integer NOT NULL DEFAULT 0,
  "comment_count" integer NOT NULL DEFAULT 0,
  "is_anonymous" boolean NOT NULL DEFAULT false,
  "created_at" timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id")
);

CREATE SEQUENCE IF NOT EXISTS "media_id_seq";

CREATE TABLE "media" (
  "id" integer NOT NULL DEFAULT nextval('media_id_seq'::regclass),
  "post_id" integer NOT NULL,
  "url" text NOT NULL,
  "type" character varying(20) NOT NULL,
  "created_at" timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id")
);

