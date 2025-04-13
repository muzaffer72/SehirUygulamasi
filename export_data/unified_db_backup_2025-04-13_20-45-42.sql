-- ŞikayetVar Veritabanı Birleştirilmiş Yedeği
-- Tarih: 2025-04-13 20:45:42
-- Bu dosya, veritabanının doğru sırayla (önce tablolar, sonra veriler, son olarak ilişkiler) içe aktarılmasını sağlar

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

START TRANSACTION;

-- 1. ADIM: TABLO YAPILARINI OLUŞTUR
-- -----------------------------

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

DROP TABLE IF EXISTS "city_stats" CASCADE;
DROP SEQUENCE IF EXISTS "city_stats_id_seq" CASCADE;
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

DROP TABLE IF EXISTS "districts" CASCADE;
DROP SEQUENCE IF EXISTS "districts_id_seq" CASCADE;
CREATE SEQUENCE IF NOT EXISTS "districts_id_seq";

CREATE TABLE "districts" (
  "id" integer NOT NULL DEFAULT nextval('districts_id_seq'::regclass),
  "name" character varying(100) NOT NULL,
  "city_id" integer NOT NULL,
  "created_at" timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "problem_solving_rate" integer NULL DEFAULT 0,
  PRIMARY KEY ("id")
);

DROP TABLE IF EXISTS "survey_options" CASCADE;
DROP SEQUENCE IF EXISTS "survey_options_id_seq" CASCADE;
CREATE SEQUENCE IF NOT EXISTS "survey_options_id_seq";

CREATE TABLE "survey_options" (
  "id" integer NOT NULL DEFAULT nextval('survey_options_id_seq'::regclass),
  "survey_id" integer NOT NULL,
  "text" character varying(255) NOT NULL,
  "vote_count" integer NOT NULL DEFAULT 0,
  PRIMARY KEY ("id")
);

DROP TABLE IF EXISTS "survey_regional_results" CASCADE;
DROP SEQUENCE IF EXISTS "survey_regional_results_id_seq" CASCADE;
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

DROP TABLE IF EXISTS "users" CASCADE;
DROP SEQUENCE IF EXISTS "users_id_seq" CASCADE;
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

DROP TABLE IF EXISTS "city_awards" CASCADE;
DROP SEQUENCE IF EXISTS "city_awards_id_seq" CASCADE;
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

DROP TABLE IF EXISTS "notifications" CASCADE;
DROP SEQUENCE IF EXISTS "notifications_id_seq" CASCADE;
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

DROP TABLE IF EXISTS "posts" CASCADE;
DROP SEQUENCE IF EXISTS "posts_id_seq" CASCADE;
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

DROP TABLE IF EXISTS "media" CASCADE;
DROP SEQUENCE IF EXISTS "media_id_seq" CASCADE;
CREATE SEQUENCE IF NOT EXISTS "media_id_seq";

CREATE TABLE "media" (
  "id" integer NOT NULL DEFAULT nextval('media_id_seq'::regclass),
  "post_id" integer NOT NULL,
  "url" text NOT NULL,
  "type" character varying(20) NOT NULL,
  "created_at" timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id")
);

DROP TABLE IF EXISTS "comments" CASCADE;
DROP SEQUENCE IF EXISTS "comments_id_seq" CASCADE;
CREATE SEQUENCE IF NOT EXISTS "comments_id_seq";

CREATE TABLE "comments" (
  "id" integer NOT NULL DEFAULT nextval('comments_id_seq'::regclass),
  "post_id" integer NOT NULL,
  "user_id" integer NOT NULL,
  "content" text NOT NULL,
  "like_count" integer NOT NULL DEFAULT 0,
  "is_hidden" boolean NOT NULL DEFAULT false,
  "created_at" timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "parent_id" integer NULL,
  "is_anonymous" boolean NULL DEFAULT false,
  PRIMARY KEY ("id")
);

DROP TABLE IF EXISTS "user_likes" CASCADE;
DROP SEQUENCE IF EXISTS "user_likes_id_seq" CASCADE;
CREATE SEQUENCE IF NOT EXISTS "user_likes_id_seq";

CREATE TABLE "user_likes" (
  "id" integer NOT NULL DEFAULT nextval('user_likes_id_seq'::regclass),
  "user_id" integer NOT NULL,
  "post_id" integer NULL,
  "comment_id" integer NULL,
  "created_at" timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id")
);


-- 2. ADIM: VERİLERİ AKTAR
-- -----------------------------

-- Tablo: award_types için veri
INSERT INTO "award_types" ("id", "name", "description", "icon_url", "badge_url", "color", "points", "created_at", "is_system", "icon", "min_rate", "max_rate", "badge_color") VALUES ('11', 'Bronz Belediye Ödülü', 'Şikayet çözüm oranı %25 ile %50 arasında olan belediyeler', NULL, NULL, '#CD7F32', '100', '2025-04-11 20:30:18.184388', '', 'bronze_medal.png', '25.00', '49.99', '#CD7F32');
INSERT INTO "award_types" ("id", "name", "description", "icon_url", "badge_url", "color", "points", "created_at", "is_system", "icon", "min_rate", "max_rate", "badge_color") VALUES ('12', 'Gümüş Belediye Ödülü', 'Şikayet çözüm oranı %50 ile %75 arasında olan belediyeler', NULL, NULL, '#C0C0C0', '200', '2025-04-11 20:30:18.184388', '', 'silver_medal.png', '50.00', '74.99', '#C0C0C0');
INSERT INTO "award_types" ("id", "name", "description", "icon_url", "badge_url", "color", "points", "created_at", "is_system", "icon", "min_rate", "max_rate", "badge_color") VALUES ('13', 'Altın Belediye Ödülü', 'Şikayet çözüm oranı %75 ve üzerinde olan belediyeler', NULL, NULL, '#FFD700', '300', '2025-04-11 20:30:18.184388', '', 'gold_medal.png', '75.00', '100.00', '#FFD700');
INSERT INTO "award_types" ("id", "name", "description", "icon_url", "badge_url", "color", "points", "created_at", "is_system", "icon", "min_rate", "max_rate", "badge_color") VALUES ('14', 'Bronz Kupa', 'Sorun çözme oranı %25-49 arası olan belediyeler için verilen otomatik ödül.', NULL, NULL, '#CD7F32', '50', '2025-04-12 23:43:12.766874', '1', 'bi-trophy', '0.00', '100.00', NULL);
INSERT INTO "award_types" ("id", "name", "description", "icon_url", "badge_url", "color", "points", "created_at", "is_system", "icon", "min_rate", "max_rate", "badge_color") VALUES ('15', 'Gümüş Kupa', 'Sorun çözme oranı %50-74 arası olan belediyeler için verilen otomatik ödül.', NULL, NULL, '#C0C0C0', '100', '2025-04-12 23:43:12.922126', '1', 'bi-trophy-fill', '0.00', '100.00', NULL);
INSERT INTO "award_types" ("id", "name", "description", "icon_url", "badge_url", "color", "points", "created_at", "is_system", "icon", "min_rate", "max_rate", "badge_color") VALUES ('16', 'Altın Kupa', 'Sorun çözme oranı %75 ve üzeri olan belediyeler için verilen otomatik ödül.', NULL, NULL, '#FFD700', '200', '2025-04-12 23:43:13.07078', '1', 'bi-trophy-fill', '0.00', '100.00', NULL);

-- Tablo: banned_words için veri
INSERT INTO "banned_words" ("id", "word", "created_at") VALUES ('1', 'küfür', '2025-04-09 18:59:03.592217+00');
INSERT INTO "banned_words" ("id", "word", "created_at") VALUES ('2', 'hakaret', '2025-04-09 18:59:03.592217+00');
INSERT INTO "banned_words" ("id", "word", "created_at") VALUES ('3', 'argo', '2025-04-09 18:59:03.592217+00');

-- Tablo: categories için veri
INSERT INTO "categories" ("id", "name", "icon_name", "created_at") VALUES ('1', 'Altyapı', 'construction', '2025-04-09 18:59:03.290753+00');
INSERT INTO "categories" ("id", "name", "icon_name", "created_at") VALUES ('2', 'Ulaşım', 'directions_bus', '2025-04-09 18:59:03.290753+00');
INSERT INTO "categories" ("id", "name", "icon_name", "created_at") VALUES ('3', 'Çevre', 'nature', '2025-04-09 18:59:03.290753+00');
INSERT INTO "categories" ("id", "name", "icon_name", "created_at") VALUES ('4', 'Güvenlik', 'security', '2025-04-09 18:59:03.290753+00');
INSERT INTO "categories" ("id", "name", "icon_name", "created_at") VALUES ('5', 'Sağlık', 'local_hospital', '2025-04-09 18:59:03.290753+00');
INSERT INTO "categories" ("id", "name", "icon_name", "created_at") VALUES ('6', 'Eğitim', 'school', '2025-04-09 18:59:03.290753+00');
INSERT INTO "categories" ("id", "name", "icon_name", "created_at") VALUES ('7', 'Kültür & Sanat', 'theater_comedy', '2025-04-09 18:59:03.290753+00');
INSERT INTO "categories" ("id", "name", "icon_name", "created_at") VALUES ('8', 'Sosyal Hizmetler', 'people', '2025-04-09 18:59:03.290753+00');
INSERT INTO "categories" ("id", "name", "icon_name", "created_at") VALUES ('9', 'Diğer', 'more_horiz', '2025-04-09 18:59:03.290753+00');

-- Tablo: cities için veri
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('4', 'OSMANİYE', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('5', 'KOCAELİ', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('6', 'GAZİANTEP', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '33');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('7', 'HATAY', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('8', 'KAYSERİ', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '50');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('9', 'GÜMÜŞHANE', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('10', 'SAKARYA', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('11', 'BURSA', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('12', 'BAYBURT', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('13', 'ÇANAKKALE', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('14', 'SİNOP', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('15', 'BARTIN', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('16', 'MAĞUSA (KIBRIS)', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('17', 'MERSİN', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('18', 'NİĞDE', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '100');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('19', 'KONYA', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('20', 'TOKAT', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('21', 'ADIYAMAN', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('22', 'ANKARA', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('23', 'YOZGAT', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '100');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('24', 'ORDU', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('25', 'RİZE', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('26', 'ADANA', '2025-04-10 00:23:01.107079+00', 'Adana, Akdeniz bolgesinde yer alan, tarihi ve kulturel zenginlikleri olan bir ilimizdir.', '2201672', '14030', 'Zeydan Karalar', 'CHP', 'https://www.adana.bel.tr', '444 0 001', 'info@adana.bel.tr', '@adana', '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('85', 'test', '2025-04-11 13:00:09.483254+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('1', 'BURDUR', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('2', 'ESKİŞEHİR', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '33');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('3', 'ÇANKIRI', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('57', 'AFYONKARAHİSAR', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '100');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('58', 'ARTVİN', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('59', 'AĞRI', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('60', 'YALOVA', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('61', 'NEVŞEHİR', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('62', 'TRABZON', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('63', 'SİVAS', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('64', 'ANTALYA', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('65', 'KASTAMONU', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('66', 'MARDİN', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('67', 'KAHRAMANMARAŞ', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('68', 'ERZURUM', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('69', 'ARDAHAN', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('70', 'DÜZCE', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('27', 'KIRŞEHİR', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('28', 'IĞDIR', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('29', 'MANİSA', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('30', 'DİYARBAKIR', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('31', 'UŞAK', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('32', 'LEFKOŞE (KIBRIS)', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('33', 'AMASYA', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('34', 'ERZİNCAN', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '75');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('35', 'ISPARTA', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('36', 'GİRNE (KIBRIS)', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('37', 'ELAZIĞ', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('38', 'KARABÜK', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('39', 'HAKKARİ', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('40', 'KARS', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('41', 'ZONGULDAK', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('42', 'AKSARAY', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('43', 'MALATYA', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('44', 'BALIKESİR', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('45', 'DENİZLİ', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('46', 'MUŞ', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('47', 'ŞIRNAK', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('48', 'MUĞLA', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('49', 'TEKİRDAĞ', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('50', 'KIRKLARELİ', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('51', 'SİİRT', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('52', 'GİRESUN', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('53', 'ŞANLIURFA', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('54', 'AYDIN', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('55', 'BATMAN', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('56', 'BİTLİS', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('71', 'SAMSUN', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('72', 'ÇORUM', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('73', 'VAN', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('74', 'BOLU', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('75', 'KÜTAHYA', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('76', 'BİLECİK', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('77', 'İSTANBUL', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('78', 'KİLİS', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('79', 'TUNCELİ', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('80', 'BİNGÖL', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('81', 'EDİRNE', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('82', 'KIRIKKALE', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('83', 'KARAMAN', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');
INSERT INTO "cities" ("id", "name", "created_at", "description", "population", "area", "mayor_name", "mayor_party", "website", "phone", "email", "social_media", "problem_solving_rate") VALUES ('84', 'İZMİR', '2025-04-10 00:23:01.107079+00', NULL, '0', '0', NULL, NULL, NULL, NULL, NULL, NULL, '0');

-- Tablo: migrations için veri
-- Bu tablo boş, veri yok

-- Tablo: settings için veri
INSERT INTO "settings" ("id", "site_name", "site_description", "admin_email", "maintenance_mode", "email_notifications", "push_notifications", "new_post_notifications", "new_user_notifications", "api_key", "webhook_url", "created_at", "updated_at") VALUES ('1', 'ŞikayetVar Yönetim', 'Belediye ve Valilik\'e yönelik şikayet ve öneri paylaşım platformu', 'admin@sikayetvar.com', '', '1', '1', '1', '1', 'ca69cdad8162fe78357ffe4e568507db', 'https://sikayetvar.com/api/webhook', '2025-04-11 13:43:28.278784', '2025-04-11 13:43:28.278784');

-- Tablo: surveys için veri
INSERT INTO "surveys" ("id", "title", "short_title", "description", "category_id", "scope_type", "city_id", "district_id", "start_date", "end_date", "total_users", "is_active", "created_at") VALUES ('1', 'Şehir İçi Ulaşım Memnuniyeti', 'Ulaşım Anketi', 'Bu anket, şehirdeki toplu taşıma ve ulaşım hizmetleri hakkında vatandaş memnuniyetini ölçmek için hazırlanmıştır.', '3', 'general', NULL, NULL, '2025-04-11', '2025-05-11', '5000', '1', '2025-04-11 16:50:41.99223');
INSERT INTO "surveys" ("id", "title", "short_title", "description", "category_id", "scope_type", "city_id", "district_id", "start_date", "end_date", "total_users", "is_active", "created_at") VALUES ('2', 'Belediye Hizmetleri Değerlendirme', 'Belediye Hizmetleri', 'Belediyenin sunduğu hizmetlerden memnuniyet düzeyinizi belirtiniz.', '10', 'city', '34', NULL, '2025-04-11', '2025-05-11', '3000', '1', '2025-04-11 16:50:42.212246');
INSERT INTO "surveys" ("id", "title", "short_title", "description", "category_id", "scope_type", "city_id", "district_id", "start_date", "end_date", "total_users", "is_active", "created_at") VALUES ('3', 'Çevre Temizliği ve Atık Yönetimi', 'Çevre Temizliği', 'Yaşadığınız bölgede çevre temizliği ve atık yönetimi hakkındaki düşünceleriniz nelerdir?', '2', 'district', '34', '1', '2025-04-11', '2025-05-11', '2000', '1', '2025-04-11 16:50:42.421007');
INSERT INTO "surveys" ("id", "title", "short_title", "description", "category_id", "scope_type", "city_id", "district_id", "start_date", "end_date", "total_users", "is_active", "created_at") VALUES ('4', 'Şehir İçi Ulaşım Memnuniyeti', 'Ulaşım Anketi', 'Bu anket, şehirdeki toplu taşıma ve ulaşım hizmetleri hakkında vatandaş memnuniyetini ölçmek için hazırlanmıştır.', '3', 'general', NULL, NULL, '2025-04-13', '2025-05-13', '5000', '1', '2025-04-13 19:47:25.939174');
INSERT INTO "surveys" ("id", "title", "short_title", "description", "category_id", "scope_type", "city_id", "district_id", "start_date", "end_date", "total_users", "is_active", "created_at") VALUES ('5', 'Belediye Hizmetleri Değerlendirme', 'Belediye Hizmetleri', 'Belediyenin sunduğu hizmetlerden memnuniyet düzeyinizi belirtiniz.', '10', 'city', '34', NULL, '2025-04-13', '2025-05-13', '3000', '1', '2025-04-13 19:47:26.321271');
INSERT INTO "surveys" ("id", "title", "short_title", "description", "category_id", "scope_type", "city_id", "district_id", "start_date", "end_date", "total_users", "is_active", "created_at") VALUES ('6', 'Çevre Temizliği ve Atık Yönetimi', 'Çevre Temizliği', 'Yaşadığınız bölgede çevre temizliği ve atık yönetimi hakkındaki düşünceleriniz nelerdir?', '2', 'district', '34', '1', '2025-04-13', '2025-05-13', '2000', '1', '2025-04-13 19:47:26.518891');
INSERT INTO "surveys" ("id", "title", "short_title", "description", "category_id", "scope_type", "city_id", "district_id", "start_date", "end_date", "total_users", "is_active", "created_at") VALUES ('7', 'Sokak Hayvanları Politikası', 'Sokak Hayvanları', 'Sokak hayvanlarına yönelik belediye politikalarını nasıl değerlendiriyorsunuz?', '10', 'general', NULL, NULL, '2025-04-13', '2025-05-13', '4000', '1', '2025-04-13 19:47:26.722129');

-- Tablo: city_events için veri
-- Bu tablo boş, veri yok

-- Tablo: city_projects için veri
INSERT INTO "city_projects" ("id", "city_id", "name", "description", "status", "budget", "start_date", "end_date", "created_at", "updated_at") VALUES ('1', '26', 'TEST', 'Test proje', 'planned', '1500000.00', '2025-04-18', '2026-07-01', '2025-04-11 18:18:11.569448', '2025-04-11 18:18:11.569448');

-- Tablo: city_services için veri
-- Bu tablo boş, veri yok

-- Tablo: city_stats için veri
-- Bu tablo boş, veri yok

-- Tablo: districts için veri
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('1', 'ALADAĞ', '26', '2025-04-10 00:23:01.107079+00', '35');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('2', 'CEYHAN', '26', '2025-04-10 00:23:01.107079+00', '95');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('3', 'ÇUKUROVA', '26', '2025-04-10 00:23:01.107079+00', '8');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('4', 'FEKE', '26', '2025-04-10 00:23:01.107079+00', '90');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('5', 'İMAMOĞLU', '26', '2025-04-10 00:23:01.107079+00', '61');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('6', 'KARAİSALI', '26', '2025-04-10 00:23:01.107079+00', '45');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('7', 'KARATAŞ', '26', '2025-04-10 00:23:01.107079+00', '51');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('8', 'KOZAN', '26', '2025-04-10 00:23:01.107079+00', '9');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('9', 'POZANTI', '26', '2025-04-10 00:23:01.107079+00', '8');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('10', 'SAİMBEYLİ', '26', '2025-04-10 00:23:01.107079+00', '68');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('11', 'SARIÇAM', '26', '2025-04-10 00:23:01.107079+00', '54');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('12', 'SEYHAN', '26', '2025-04-10 00:23:01.107079+00', '21');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('13', 'TUFANBEYLİ', '26', '2025-04-10 00:23:01.107079+00', '82');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('14', 'YUMURTALIK', '26', '2025-04-10 00:23:01.107079+00', '51');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('15', 'YÜREĞİR', '26', '2025-04-10 00:23:01.107079+00', '57');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('16', 'BESNİ', '21', '2025-04-10 00:23:01.107079+00', '71');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('17', 'ÇELİKHAN', '21', '2025-04-10 00:23:01.107079+00', '57');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('18', 'GERGER', '21', '2025-04-10 00:23:01.107079+00', '5');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('19', 'GÖLBAŞI', '21', '2025-04-10 00:23:01.107079+00', '23');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('20', 'KAHTA', '21', '2025-04-10 00:23:01.107079+00', '26');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('21', 'MERKEZ', '21', '2025-04-10 00:23:01.107079+00', '50');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('22', 'SAMSAT', '21', '2025-04-10 00:23:01.107079+00', '39');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('23', 'SİNCİK', '21', '2025-04-10 00:23:01.107079+00', '12');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('24', 'TUT', '21', '2025-04-10 00:23:01.107079+00', '87');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('25', 'BAŞMAKÇI', '57', '2025-04-10 00:23:01.107079+00', '87');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('26', 'BAYAT', '57', '2025-04-10 00:23:01.107079+00', '62');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('27', 'BOLVADİN', '57', '2025-04-10 00:23:01.107079+00', '85');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('28', 'ÇAY', '57', '2025-04-10 00:23:01.107079+00', '2');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('29', 'ÇOBANLAR', '57', '2025-04-10 00:23:01.107079+00', '17');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('30', 'DAZKIRI', '57', '2025-04-10 00:23:01.107079+00', '72');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('31', 'DİNAR', '57', '2025-04-10 00:23:01.107079+00', '8');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('32', 'EMİRDAĞ', '57', '2025-04-10 00:23:01.107079+00', '92');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('33', 'EVCİLER', '57', '2025-04-10 00:23:01.107079+00', '43');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('34', 'HOCALAR', '57', '2025-04-10 00:23:01.107079+00', '7');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('35', 'İHSANİYE', '57', '2025-04-10 00:23:01.107079+00', '93');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('36', 'İSCEHİSAR', '57', '2025-04-10 00:23:01.107079+00', '65');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('37', 'KIZILÖREN', '57', '2025-04-10 00:23:01.107079+00', '86');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('38', 'MERKEZ', '57', '2025-04-10 00:23:01.107079+00', '91');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('39', 'SANDIKLI', '57', '2025-04-10 00:23:01.107079+00', '70');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('40', 'SİNANPAŞA', '57', '2025-04-10 00:23:01.107079+00', '4');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('41', 'SULTANDAĞI', '57', '2025-04-10 00:23:01.107079+00', '92');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('42', 'ŞUHUT', '57', '2025-04-10 00:23:01.107079+00', '94');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('43', 'DİYADİN', '59', '2025-04-10 00:23:01.107079+00', '53');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('44', 'DOĞUBAYAZIT', '59', '2025-04-10 00:23:01.107079+00', '64');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('45', 'ELEŞKİRT', '59', '2025-04-10 00:23:01.107079+00', '78');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('46', 'HAMUR', '59', '2025-04-10 00:23:01.107079+00', '78');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('47', 'MERKEZ', '59', '2025-04-10 00:23:01.107079+00', '72');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('48', 'PATNOS', '59', '2025-04-10 00:23:01.107079+00', '26');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('49', 'TAŞLIÇAY', '59', '2025-04-10 00:23:01.107079+00', '89');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('50', 'TUTAK', '59', '2025-04-10 00:23:01.107079+00', '12');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('51', 'GÖYNÜCEK', '33', '2025-04-10 00:23:01.107079+00', '63');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('52', 'GÜMÜŞHACIKÖY', '33', '2025-04-10 00:23:01.107079+00', '86');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('53', 'HAMAMÖZÜ', '33', '2025-04-10 00:23:01.107079+00', '71');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('54', 'MERKEZ', '33', '2025-04-10 00:23:01.107079+00', '44');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('55', 'MERZİFON', '33', '2025-04-10 00:23:01.107079+00', '52');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('56', 'SULUOVA', '33', '2025-04-10 00:23:01.107079+00', '10');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('57', 'TAŞOVA', '33', '2025-04-10 00:23:01.107079+00', '39');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('58', 'AKYURT', '22', '2025-04-10 00:23:01.107079+00', '55');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('59', 'ALTINDAĞ', '22', '2025-04-10 00:23:01.107079+00', '12');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('60', 'AYAŞ', '22', '2025-04-10 00:23:01.107079+00', '31');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('61', 'BALA', '22', '2025-04-10 00:23:01.107079+00', '47');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('62', 'BEYPAZARI', '22', '2025-04-10 00:23:01.107079+00', '62');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('63', 'ÇAMLIDERE', '22', '2025-04-10 00:23:01.107079+00', '24');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('64', 'ÇANKAYA', '22', '2025-04-10 00:23:01.107079+00', '6');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('65', 'ÇUBUK', '22', '2025-04-10 00:23:01.107079+00', '29');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('66', 'ELMADAĞ', '22', '2025-04-10 00:23:01.107079+00', '87');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('67', 'ETİMESGUT', '22', '2025-04-10 00:23:01.107079+00', '49');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('68', 'EVREN', '22', '2025-04-10 00:23:01.107079+00', '0');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('69', 'GÖLBAŞI', '22', '2025-04-10 00:23:01.107079+00', '47');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('70', 'GÜDÜL', '22', '2025-04-10 00:23:01.107079+00', '2');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('71', 'HAYMANA', '22', '2025-04-10 00:23:01.107079+00', '72');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('72', 'KAHRAMANKAZAN', '22', '2025-04-10 00:23:01.107079+00', '90');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('73', 'KALECİK', '22', '2025-04-10 00:23:01.107079+00', '80');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('74', 'KEÇİÖREN', '22', '2025-04-10 00:23:01.107079+00', '87');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('75', 'KIZILCAHAMAM', '22', '2025-04-10 00:23:01.107079+00', '24');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('76', 'MAMAK', '22', '2025-04-10 00:23:01.107079+00', '67');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('77', 'NALLIHAN', '22', '2025-04-10 00:23:01.107079+00', '37');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('78', 'POLATLI', '22', '2025-04-10 00:23:01.107079+00', '27');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('79', 'PURSAKLAR', '22', '2025-04-10 00:23:01.107079+00', '22');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('80', 'SİNCAN', '22', '2025-04-10 00:23:01.107079+00', '4');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('81', 'ŞEREFLİKOÇHİSAR', '22', '2025-04-10 00:23:01.107079+00', '89');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('82', 'YENİMAHALLE', '22', '2025-04-10 00:23:01.107079+00', '97');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('83', 'AKSEKİ', '64', '2025-04-10 00:23:01.107079+00', '86');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('84', 'AKSU', '64', '2025-04-10 00:23:01.107079+00', '98');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('85', 'ALANYA', '64', '2025-04-10 00:23:01.107079+00', '3');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('86', 'DEMRE', '64', '2025-04-10 00:23:01.107079+00', '23');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('87', 'DÖŞEMEALTI', '64', '2025-04-10 00:23:01.107079+00', '29');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('88', 'ELMALI', '64', '2025-04-10 00:23:01.107079+00', '25');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('89', 'FİNİKE', '64', '2025-04-10 00:23:01.107079+00', '49');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('90', 'GAZİPAŞA', '64', '2025-04-10 00:23:01.107079+00', '32');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('91', 'GÜNDOĞMUŞ', '64', '2025-04-10 00:23:01.107079+00', '35');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('92', 'İBRADI', '64', '2025-04-10 00:23:01.107079+00', '54');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('93', 'KAŞ', '64', '2025-04-10 00:23:01.107079+00', '46');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('94', 'KEMER', '64', '2025-04-10 00:23:01.107079+00', '43');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('95', 'KEPEZ', '64', '2025-04-10 00:23:01.107079+00', '67');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('96', 'KONYAALTI', '64', '2025-04-10 00:23:01.107079+00', '36');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('97', 'KORKUTELİ', '64', '2025-04-10 00:23:01.107079+00', '0');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('98', 'KUMLUCA', '64', '2025-04-10 00:23:01.107079+00', '54');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('99', 'MANAVGAT', '64', '2025-04-10 00:23:01.107079+00', '32');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('100', 'MURATPAŞA', '64', '2025-04-10 00:23:01.107079+00', '38');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('101', 'SERİK', '64', '2025-04-10 00:23:01.107079+00', '0');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('102', 'ARDANUÇ', '58', '2025-04-10 00:23:01.107079+00', '47');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('103', 'ARHAVİ', '58', '2025-04-10 00:23:01.107079+00', '92');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('104', 'BORÇKA', '58', '2025-04-10 00:23:01.107079+00', '84');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('105', 'HOPA', '58', '2025-04-10 00:23:01.107079+00', '9');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('106', 'KEMALPAŞA', '58', '2025-04-10 00:23:01.107079+00', '7');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('107', 'MERKEZ', '58', '2025-04-10 00:23:01.107079+00', '60');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('108', 'MURGUL', '58', '2025-04-10 00:23:01.107079+00', '20');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('109', 'ŞAVŞAT', '58', '2025-04-10 00:23:01.107079+00', '42');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('110', 'YUSUFELİ', '58', '2025-04-10 00:23:01.107079+00', '39');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('111', 'BOZDOĞAN', '54', '2025-04-10 00:23:01.107079+00', '24');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('112', 'BUHARKENT', '54', '2025-04-10 00:23:01.107079+00', '26');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('113', 'ÇİNE', '54', '2025-04-10 00:23:01.107079+00', '72');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('114', 'DİDİM', '54', '2025-04-10 00:23:01.107079+00', '13');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('115', 'EFELER', '54', '2025-04-10 00:23:01.107079+00', '34');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('116', 'GERMENCİK', '54', '2025-04-10 00:23:01.107079+00', '61');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('117', 'İNCİRLİOVA', '54', '2025-04-10 00:23:01.107079+00', '58');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('118', 'KARACASU', '54', '2025-04-10 00:23:01.107079+00', '20');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('119', 'KARPUZLU', '54', '2025-04-10 00:23:01.107079+00', '99');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('120', 'KOÇARLI', '54', '2025-04-10 00:23:01.107079+00', '18');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('121', 'KÖŞK', '54', '2025-04-10 00:23:01.107079+00', '1');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('122', 'KUŞADASI', '54', '2025-04-10 00:23:01.107079+00', '34');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('123', 'KUYUCAK', '54', '2025-04-10 00:23:01.107079+00', '77');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('124', 'NAZİLLİ', '54', '2025-04-10 00:23:01.107079+00', '64');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('125', 'SÖKE', '54', '2025-04-10 00:23:01.107079+00', '49');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('126', 'SULTANHİSAR', '54', '2025-04-10 00:23:01.107079+00', '36');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('127', 'YENİPAZAR', '54', '2025-04-10 00:23:01.107079+00', '10');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('128', 'ALTIEYLÜL', '44', '2025-04-10 00:23:01.107079+00', '97');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('129', 'AYVALIK', '44', '2025-04-10 00:23:01.107079+00', '49');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('130', 'BALYA', '44', '2025-04-10 00:23:01.107079+00', '50');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('131', 'BANDIRMA', '44', '2025-04-10 00:23:01.107079+00', '44');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('132', 'BİGADİÇ', '44', '2025-04-10 00:23:01.107079+00', '12');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('133', 'BURHANİYE', '44', '2025-04-10 00:23:01.107079+00', '3');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('134', 'DURSUNBEY', '44', '2025-04-10 00:23:01.107079+00', '77');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('135', 'EDREMİT', '44', '2025-04-10 00:23:01.107079+00', '55');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('136', 'ERDEK', '44', '2025-04-10 00:23:01.107079+00', '67');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('137', 'GÖMEÇ', '44', '2025-04-10 00:23:01.107079+00', '22');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('138', 'GÖNEN', '44', '2025-04-10 00:23:01.107079+00', '77');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('139', 'HAVRAN', '44', '2025-04-10 00:23:01.107079+00', '88');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('140', 'İVRİNDİ', '44', '2025-04-10 00:23:01.107079+00', '76');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('141', 'KARESİ', '44', '2025-04-10 00:23:01.107079+00', '29');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('142', 'KEPSUT', '44', '2025-04-10 00:23:01.107079+00', '30');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('143', 'MANYAS', '44', '2025-04-10 00:23:01.107079+00', '70');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('144', 'MARMARA', '44', '2025-04-10 00:23:01.107079+00', '71');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('145', 'SAVAŞTEPE', '44', '2025-04-10 00:23:01.107079+00', '39');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('146', 'SINDIRGI', '44', '2025-04-10 00:23:01.107079+00', '96');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('147', 'SUSURLUK', '44', '2025-04-10 00:23:01.107079+00', '22');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('148', 'BOZÜYÜK', '76', '2025-04-10 00:23:01.107079+00', '8');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('149', 'GÖLPAZARI', '76', '2025-04-10 00:23:01.107079+00', '93');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('150', 'İNHİSAR', '76', '2025-04-10 00:23:01.107079+00', '8');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('151', 'MERKEZ', '76', '2025-04-10 00:23:01.107079+00', '1');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('152', 'OSMANELİ', '76', '2025-04-10 00:23:01.107079+00', '81');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('153', 'PAZARYERİ', '76', '2025-04-10 00:23:01.107079+00', '20');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('154', 'SÖĞÜT', '76', '2025-04-10 00:23:01.107079+00', '17');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('155', 'YENİPAZAR', '76', '2025-04-10 00:23:01.107079+00', '95');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('156', 'ADAKLI', '80', '2025-04-10 00:23:01.107079+00', '16');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('157', 'GENÇ', '80', '2025-04-10 00:23:01.107079+00', '12');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('158', 'KARLIOVA', '80', '2025-04-10 00:23:01.107079+00', '12');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('159', 'KİĞI', '80', '2025-04-10 00:23:01.107079+00', '1');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('160', 'MERKEZ', '80', '2025-04-10 00:23:01.107079+00', '11');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('161', 'SOLHAN', '80', '2025-04-10 00:23:01.107079+00', '93');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('162', 'YAYLADERE', '80', '2025-04-10 00:23:01.107079+00', '63');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('163', 'YEDİSU', '80', '2025-04-10 00:23:01.107079+00', '63');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('164', 'ADİLCEVAZ', '56', '2025-04-10 00:23:01.107079+00', '89');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('165', 'AHLAT', '56', '2025-04-10 00:23:01.107079+00', '22');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('166', 'GÜROYMAK', '56', '2025-04-10 00:23:01.107079+00', '34');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('167', 'HİZAN', '56', '2025-04-10 00:23:01.107079+00', '36');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('168', 'MERKEZ', '56', '2025-04-10 00:23:01.107079+00', '51');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('169', 'MUTKİ', '56', '2025-04-10 00:23:01.107079+00', '42');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('170', 'TATVAN', '56', '2025-04-10 00:23:01.107079+00', '64');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('171', 'DÖRTDİVAN', '74', '2025-04-10 00:23:01.107079+00', '41');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('172', 'GEREDE', '74', '2025-04-10 00:23:01.107079+00', '83');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('173', 'GÖYNÜK', '74', '2025-04-10 00:23:01.107079+00', '21');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('174', 'KIBRISCIK', '74', '2025-04-10 00:23:01.107079+00', '95');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('175', 'MENGEN', '74', '2025-04-10 00:23:01.107079+00', '51');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('176', 'MERKEZ', '74', '2025-04-10 00:23:01.107079+00', '35');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('177', 'MUDURNU', '74', '2025-04-10 00:23:01.107079+00', '58');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('178', 'SEBEN', '74', '2025-04-10 00:23:01.107079+00', '83');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('179', 'YENİÇAĞA', '74', '2025-04-10 00:23:01.107079+00', '52');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('180', 'AĞLASUN', '1', '2025-04-10 00:23:01.107079+00', '11');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('181', 'ALTINYAYLA', '1', '2025-04-10 00:23:01.107079+00', '7');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('182', 'BUCAK', '1', '2025-04-10 00:23:01.107079+00', '7');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('183', 'ÇAVDIR', '1', '2025-04-10 00:23:01.107079+00', '1');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('184', 'ÇELTİKÇİ', '1', '2025-04-10 00:23:01.107079+00', '6');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('185', 'GÖLHİSAR', '1', '2025-04-10 00:23:01.107079+00', '84');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('186', 'KARAMANLI', '1', '2025-04-10 00:23:01.107079+00', '77');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('187', 'KEMER', '1', '2025-04-10 00:23:01.107079+00', '34');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('188', 'MERKEZ', '1', '2025-04-10 00:23:01.107079+00', '75');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('189', 'TEFENNİ', '1', '2025-04-10 00:23:01.107079+00', '51');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('190', 'YEŞİLOVA', '1', '2025-04-10 00:23:01.107079+00', '90');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('191', 'BÜYÜKORHAN', '11', '2025-04-10 00:23:01.107079+00', '79');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('192', 'GEMLİK', '11', '2025-04-10 00:23:01.107079+00', '73');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('193', 'GÜRSU', '11', '2025-04-10 00:23:01.107079+00', '38');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('194', 'HARMANCIK', '11', '2025-04-10 00:23:01.107079+00', '21');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('195', 'İNEGÖL', '11', '2025-04-10 00:23:01.107079+00', '14');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('196', 'İZNİK', '11', '2025-04-10 00:23:01.107079+00', '58');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('197', 'KARACABEY', '11', '2025-04-10 00:23:01.107079+00', '41');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('198', 'KELES', '11', '2025-04-10 00:23:01.107079+00', '44');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('199', 'KESTEL', '11', '2025-04-10 00:23:01.107079+00', '75');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('200', 'MUDANYA', '11', '2025-04-10 00:23:01.107079+00', '52');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('201', 'MUSTAFAKEMALPAŞA', '11', '2025-04-10 00:23:01.107079+00', '48');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('202', 'NİLÜFER', '11', '2025-04-10 00:23:01.107079+00', '4');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('203', 'ORHANELİ', '11', '2025-04-10 00:23:01.107079+00', '72');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('204', 'ORHANGAZİ', '11', '2025-04-10 00:23:01.107079+00', '37');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('205', 'OSMANGAZİ', '11', '2025-04-10 00:23:01.107079+00', '81');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('206', 'YENİŞEHİR', '11', '2025-04-10 00:23:01.107079+00', '79');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('207', 'YILDIRIM', '11', '2025-04-10 00:23:01.107079+00', '54');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('208', 'AYVACIK', '13', '2025-04-10 00:23:01.107079+00', '22');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('209', 'BAYRAMİÇ', '13', '2025-04-10 00:23:01.107079+00', '72');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('210', 'BİGA', '13', '2025-04-10 00:23:01.107079+00', '47');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('211', 'BOZCAADA', '13', '2025-04-10 00:23:01.107079+00', '86');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('212', 'ÇAN', '13', '2025-04-10 00:23:01.107079+00', '99');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('213', 'ECEABAT', '13', '2025-04-10 00:23:01.107079+00', '41');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('214', 'EZİNE', '13', '2025-04-10 00:23:01.107079+00', '49');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('215', 'GELİBOLU', '13', '2025-04-10 00:23:01.107079+00', '52');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('216', 'GÖKÇEADA', '13', '2025-04-10 00:23:01.107079+00', '93');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('217', 'LAPSEKİ', '13', '2025-04-10 00:23:01.107079+00', '54');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('218', 'MERKEZ', '13', '2025-04-10 00:23:01.107079+00', '55');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('219', 'YENİCE', '13', '2025-04-10 00:23:01.107079+00', '9');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('220', 'ATKARACALAR', '3', '2025-04-10 00:23:01.107079+00', '22');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('221', 'BAYRAMÖREN', '3', '2025-04-10 00:23:01.107079+00', '45');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('222', 'ÇERKEŞ', '3', '2025-04-10 00:23:01.107079+00', '88');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('223', 'ELDİVAN', '3', '2025-04-10 00:23:01.107079+00', '85');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('224', 'ILGAZ', '3', '2025-04-10 00:23:01.107079+00', '42');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('225', 'KIZILIRMAK', '3', '2025-04-10 00:23:01.107079+00', '80');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('226', 'KORGUN', '3', '2025-04-10 00:23:01.107079+00', '64');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('227', 'KURŞUNLU', '3', '2025-04-10 00:23:01.107079+00', '71');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('228', 'MERKEZ', '3', '2025-04-10 00:23:01.107079+00', '67');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('229', 'ORTA', '3', '2025-04-10 00:23:01.107079+00', '28');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('230', 'ŞABANÖZÜ', '3', '2025-04-10 00:23:01.107079+00', '42');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('231', 'YAPRAKLI', '3', '2025-04-10 00:23:01.107079+00', '1');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('232', 'ALACA', '72', '2025-04-10 00:23:01.107079+00', '55');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('233', 'BAYAT', '72', '2025-04-10 00:23:01.107079+00', '54');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('234', 'BOĞAZKALE', '72', '2025-04-10 00:23:01.107079+00', '22');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('235', 'DODURGA', '72', '2025-04-10 00:23:01.107079+00', '80');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('236', 'İSKİLİP', '72', '2025-04-10 00:23:01.107079+00', '8');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('237', 'KARGI', '72', '2025-04-10 00:23:01.107079+00', '24');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('238', 'LAÇİN', '72', '2025-04-10 00:23:01.107079+00', '63');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('239', 'MECİTÖZÜ', '72', '2025-04-10 00:23:01.107079+00', '36');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('240', 'MERKEZ', '72', '2025-04-10 00:23:01.107079+00', '71');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('241', 'OĞUZLAR', '72', '2025-04-10 00:23:01.107079+00', '34');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('242', 'ORTAKÖY', '72', '2025-04-10 00:23:01.107079+00', '85');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('243', 'OSMANCIK', '72', '2025-04-10 00:23:01.107079+00', '89');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('244', 'SUNGURLU', '72', '2025-04-10 00:23:01.107079+00', '78');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('245', 'UĞURLUDAĞ', '72', '2025-04-10 00:23:01.107079+00', '77');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('246', 'ACIPAYAM', '45', '2025-04-10 00:23:01.107079+00', '43');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('247', 'BABADAĞ', '45', '2025-04-10 00:23:01.107079+00', '43');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('248', 'BAKLAN', '45', '2025-04-10 00:23:01.107079+00', '98');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('249', 'BEKİLLİ', '45', '2025-04-10 00:23:01.107079+00', '50');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('250', 'BEYAĞAÇ', '45', '2025-04-10 00:23:01.107079+00', '52');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('251', 'BOZKURT', '45', '2025-04-10 00:23:01.107079+00', '76');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('252', 'BULDAN', '45', '2025-04-10 00:23:01.107079+00', '50');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('253', 'ÇAL', '45', '2025-04-10 00:23:01.107079+00', '6');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('254', 'ÇAMELİ', '45', '2025-04-10 00:23:01.107079+00', '32');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('255', 'ÇARDAK', '45', '2025-04-10 00:23:01.107079+00', '4');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('256', 'ÇİVRİL', '45', '2025-04-10 00:23:01.107079+00', '69');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('257', 'GÜNEY', '45', '2025-04-10 00:23:01.107079+00', '31');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('258', 'HONAZ', '45', '2025-04-10 00:23:01.107079+00', '60');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('259', 'KALE', '45', '2025-04-10 00:23:01.107079+00', '23');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('260', 'MERKEZEFENDİ', '45', '2025-04-10 00:23:01.107079+00', '70');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('261', 'PAMUKKALE', '45', '2025-04-10 00:23:01.107079+00', '41');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('262', 'SARAYKÖY', '45', '2025-04-10 00:23:01.107079+00', '93');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('263', 'SERİNHİSAR', '45', '2025-04-10 00:23:01.107079+00', '51');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('264', 'TAVAS', '45', '2025-04-10 00:23:01.107079+00', '34');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('265', 'BAĞLAR', '30', '2025-04-10 00:23:01.107079+00', '71');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('266', 'BİSMİL', '30', '2025-04-10 00:23:01.107079+00', '75');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('267', 'ÇERMİK', '30', '2025-04-10 00:23:01.107079+00', '47');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('268', 'ÇINAR', '30', '2025-04-10 00:23:01.107079+00', '9');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('269', 'ÇÜNGÜŞ', '30', '2025-04-10 00:23:01.107079+00', '5');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('270', 'DİCLE', '30', '2025-04-10 00:23:01.107079+00', '89');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('271', 'EĞİL', '30', '2025-04-10 00:23:01.107079+00', '92');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('272', 'ERGANİ', '30', '2025-04-10 00:23:01.107079+00', '6');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('273', 'HANİ', '30', '2025-04-10 00:23:01.107079+00', '47');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('274', 'HAZRO', '30', '2025-04-10 00:23:01.107079+00', '16');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('275', 'KAYAPINAR', '30', '2025-04-10 00:23:01.107079+00', '15');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('276', 'KOCAKÖY', '30', '2025-04-10 00:23:01.107079+00', '0');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('277', 'KULP', '30', '2025-04-10 00:23:01.107079+00', '50');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('278', 'LİCE', '30', '2025-04-10 00:23:01.107079+00', '97');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('279', 'SİLVAN', '30', '2025-04-10 00:23:01.107079+00', '85');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('280', 'SUR', '30', '2025-04-10 00:23:01.107079+00', '46');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('281', 'YENİŞEHİR', '30', '2025-04-10 00:23:01.107079+00', '36');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('282', 'ENEZ', '81', '2025-04-10 00:23:01.107079+00', '14');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('283', 'HAVSA', '81', '2025-04-10 00:23:01.107079+00', '11');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('284', 'İPSALA', '81', '2025-04-10 00:23:01.107079+00', '29');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('285', 'KEŞAN', '81', '2025-04-10 00:23:01.107079+00', '51');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('286', 'LALAPAŞA', '81', '2025-04-10 00:23:01.107079+00', '92');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('287', 'MERİÇ', '81', '2025-04-10 00:23:01.107079+00', '67');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('288', 'MERKEZ', '81', '2025-04-10 00:23:01.107079+00', '90');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('289', 'SÜLOĞLU', '81', '2025-04-10 00:23:01.107079+00', '25');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('290', 'UZUNKÖPRÜ', '81', '2025-04-10 00:23:01.107079+00', '27');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('291', 'AĞIN', '37', '2025-04-10 00:23:01.107079+00', '88');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('292', 'ALACAKAYA', '37', '2025-04-10 00:23:01.107079+00', '62');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('293', 'ARICAK', '37', '2025-04-10 00:23:01.107079+00', '35');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('294', 'BASKİL', '37', '2025-04-10 00:23:01.107079+00', '4');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('295', 'KARAKOÇAN', '37', '2025-04-10 00:23:01.107079+00', '14');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('296', 'KEBAN', '37', '2025-04-10 00:23:01.107079+00', '60');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('297', 'KOVANCILAR', '37', '2025-04-10 00:23:01.107079+00', '25');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('298', 'MADEN', '37', '2025-04-10 00:23:01.107079+00', '75');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('299', 'MERKEZ', '37', '2025-04-10 00:23:01.107079+00', '47');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('300', 'PALU', '37', '2025-04-10 00:23:01.107079+00', '37');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('301', 'SİVRİCE', '37', '2025-04-10 00:23:01.107079+00', '41');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('302', 'ÇAYIRLI', '34', '2025-04-10 00:23:01.107079+00', '77');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('303', 'İLİÇ', '34', '2025-04-10 00:23:01.107079+00', '99');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('304', 'KEMAH', '34', '2025-04-10 00:23:01.107079+00', '46');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('305', 'KEMALİYE', '34', '2025-04-10 00:23:01.107079+00', '26');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('306', 'MERKEZ', '34', '2025-04-10 00:23:01.107079+00', '32');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('307', 'OTLUKBELİ', '34', '2025-04-10 00:23:01.107079+00', '4');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('308', 'REFAHİYE', '34', '2025-04-10 00:23:01.107079+00', '88');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('309', 'TERCAN', '34', '2025-04-10 00:23:01.107079+00', '15');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('310', 'ÜZÜMLÜ', '34', '2025-04-10 00:23:01.107079+00', '19');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('311', 'AŞKALE', '68', '2025-04-10 00:23:01.107079+00', '65');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('312', 'AZİZİYE', '68', '2025-04-10 00:23:01.107079+00', '36');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('313', 'ÇAT', '68', '2025-04-10 00:23:01.107079+00', '59');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('314', 'HINIS', '68', '2025-04-10 00:23:01.107079+00', '18');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('315', 'HORASAN', '68', '2025-04-10 00:23:01.107079+00', '50');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('316', 'İSPİR', '68', '2025-04-10 00:23:01.107079+00', '86');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('317', 'KARAÇOBAN', '68', '2025-04-10 00:23:01.107079+00', '2');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('318', 'KARAYAZI', '68', '2025-04-10 00:23:01.107079+00', '71');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('319', 'KÖPRÜKÖY', '68', '2025-04-10 00:23:01.107079+00', '26');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('320', 'NARMAN', '68', '2025-04-10 00:23:01.107079+00', '79');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('321', 'OLTU', '68', '2025-04-10 00:23:01.107079+00', '3');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('322', 'OLUR', '68', '2025-04-10 00:23:01.107079+00', '45');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('323', 'PALANDÖKEN', '68', '2025-04-10 00:23:01.107079+00', '28');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('324', 'PASİNLER', '68', '2025-04-10 00:23:01.107079+00', '73');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('325', 'PAZARYOLU', '68', '2025-04-10 00:23:01.107079+00', '96');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('326', 'ŞENKAYA', '68', '2025-04-10 00:23:01.107079+00', '57');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('327', 'TEKMAN', '68', '2025-04-10 00:23:01.107079+00', '11');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('328', 'TORTUM', '68', '2025-04-10 00:23:01.107079+00', '98');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('329', 'UZUNDERE', '68', '2025-04-10 00:23:01.107079+00', '82');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('330', 'YAKUTİYE', '68', '2025-04-10 00:23:01.107079+00', '69');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('331', 'ALPU', '2', '2025-04-10 00:23:01.107079+00', '69');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('332', 'BEYLİKOVA', '2', '2025-04-10 00:23:01.107079+00', '24');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('333', 'ÇİFTELER', '2', '2025-04-10 00:23:01.107079+00', '87');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('334', 'GÜNYÜZÜ', '2', '2025-04-10 00:23:01.107079+00', '75');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('335', 'HAN', '2', '2025-04-10 00:23:01.107079+00', '55');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('336', 'İNÖNÜ', '2', '2025-04-10 00:23:01.107079+00', '37');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('337', 'MAHMUDİYE', '2', '2025-04-10 00:23:01.107079+00', '92');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('338', 'MİHALGAZİ', '2', '2025-04-10 00:23:01.107079+00', '29');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('339', 'MİHALIÇÇIK', '2', '2025-04-10 00:23:01.107079+00', '39');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('340', 'ODUNPAZARI', '2', '2025-04-10 00:23:01.107079+00', '52');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('341', 'SARICAKAYA', '2', '2025-04-10 00:23:01.107079+00', '76');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('342', 'SEYİTGAZİ', '2', '2025-04-10 00:23:01.107079+00', '51');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('343', 'SİVRİHİSAR', '2', '2025-04-10 00:23:01.107079+00', '31');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('344', 'TEPEBAŞI', '2', '2025-04-10 00:23:01.107079+00', '77');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('345', 'ARABAN', '6', '2025-04-10 00:23:01.107079+00', '75');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('346', 'İSLAHİYE', '6', '2025-04-10 00:23:01.107079+00', '77');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('347', 'KARKAMIŞ', '6', '2025-04-10 00:23:01.107079+00', '37');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('348', 'NİZİP', '6', '2025-04-10 00:23:01.107079+00', '86');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('349', 'NURDAĞI', '6', '2025-04-10 00:23:01.107079+00', '34');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('350', 'OĞUZELİ', '6', '2025-04-10 00:23:01.107079+00', '62');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('351', 'ŞAHİNBEY', '6', '2025-04-10 00:23:01.107079+00', '39');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('352', 'ŞEHİTKAMİL', '6', '2025-04-10 00:23:01.107079+00', '37');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('353', 'YAVUZELİ', '6', '2025-04-10 00:23:01.107079+00', '91');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('354', 'ALUCRA', '52', '2025-04-10 00:23:01.107079+00', '73');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('355', 'BULANCAK', '52', '2025-04-10 00:23:01.107079+00', '53');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('356', 'ÇAMOLUK', '52', '2025-04-10 00:23:01.107079+00', '39');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('357', 'ÇANAKÇI', '52', '2025-04-10 00:23:01.107079+00', '77');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('358', 'DERELİ', '52', '2025-04-10 00:23:01.107079+00', '78');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('359', 'DOĞANKENT', '52', '2025-04-10 00:23:01.107079+00', '59');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('360', 'ESPİYE', '52', '2025-04-10 00:23:01.107079+00', '82');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('361', 'EYNESİL', '52', '2025-04-10 00:23:01.107079+00', '14');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('362', 'GÖRELE', '52', '2025-04-10 00:23:01.107079+00', '76');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('363', 'GÜCE', '52', '2025-04-10 00:23:01.107079+00', '44');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('364', 'KEŞAP', '52', '2025-04-10 00:23:01.107079+00', '33');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('365', 'MERKEZ', '52', '2025-04-10 00:23:01.107079+00', '90');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('366', 'PİRAZİZ', '52', '2025-04-10 00:23:01.107079+00', '47');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('367', 'ŞEBİNKARAHİSAR', '52', '2025-04-10 00:23:01.107079+00', '14');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('368', 'TİREBOLU', '52', '2025-04-10 00:23:01.107079+00', '95');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('369', 'YAĞLIDERE', '52', '2025-04-10 00:23:01.107079+00', '66');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('370', 'KELKİT', '9', '2025-04-10 00:23:01.107079+00', '10');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('371', 'KÖSE', '9', '2025-04-10 00:23:01.107079+00', '20');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('372', 'KÜRTÜN', '9', '2025-04-10 00:23:01.107079+00', '98');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('373', 'MERKEZ', '9', '2025-04-10 00:23:01.107079+00', '52');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('374', 'ŞİRAN', '9', '2025-04-10 00:23:01.107079+00', '49');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('375', 'TORUL', '9', '2025-04-10 00:23:01.107079+00', '33');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('376', 'ÇUKURCA', '39', '2025-04-10 00:23:01.107079+00', '32');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('377', 'DERECİK', '39', '2025-04-10 00:23:01.107079+00', '86');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('378', 'MERKEZ', '39', '2025-04-10 00:23:01.107079+00', '46');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('379', 'ŞEMDİNLİ', '39', '2025-04-10 00:23:01.107079+00', '1');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('380', 'YÜKSEKOVA', '39', '2025-04-10 00:23:01.107079+00', '93');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('381', 'ALTINÖZÜ', '7', '2025-04-10 00:23:01.107079+00', '15');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('382', 'ANTAKYA', '7', '2025-04-10 00:23:01.107079+00', '11');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('383', 'ARSUZ', '7', '2025-04-10 00:23:01.107079+00', '84');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('384', 'BELEN', '7', '2025-04-10 00:23:01.107079+00', '23');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('385', 'DEFNE', '7', '2025-04-10 00:23:01.107079+00', '82');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('386', 'DÖRTYOL', '7', '2025-04-10 00:23:01.107079+00', '1');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('387', 'ERZİN', '7', '2025-04-10 00:23:01.107079+00', '51');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('388', 'HASSA', '7', '2025-04-10 00:23:01.107079+00', '37');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('389', 'İSKENDERUN', '7', '2025-04-10 00:23:01.107079+00', '58');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('390', 'KIRIKHAN', '7', '2025-04-10 00:23:01.107079+00', '3');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('391', 'KUMLU', '7', '2025-04-10 00:23:01.107079+00', '74');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('392', 'PAYAS', '7', '2025-04-10 00:23:01.107079+00', '2');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('393', 'REYHANLI', '7', '2025-04-10 00:23:01.107079+00', '36');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('394', 'SAMANDAĞ', '7', '2025-04-10 00:23:01.107079+00', '44');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('395', 'YAYLADAĞI', '7', '2025-04-10 00:23:01.107079+00', '20');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('396', 'AKSU', '35', '2025-04-10 00:23:01.107079+00', '5');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('397', 'ATABEY', '35', '2025-04-10 00:23:01.107079+00', '88');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('398', 'EĞİRDİR', '35', '2025-04-10 00:23:01.107079+00', '90');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('399', 'GELENDOST', '35', '2025-04-10 00:23:01.107079+00', '95');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('400', 'GÖNEN', '35', '2025-04-10 00:23:01.107079+00', '32');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('401', 'KEÇİBORLU', '35', '2025-04-10 00:23:01.107079+00', '9');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('402', 'MERKEZ', '35', '2025-04-10 00:23:01.107079+00', '27');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('403', 'SENİRKENT', '35', '2025-04-10 00:23:01.107079+00', '0');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('404', 'SÜTÇÜLER', '35', '2025-04-10 00:23:01.107079+00', '98');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('405', 'ŞARKİKARAAĞAÇ', '35', '2025-04-10 00:23:01.107079+00', '76');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('406', 'ULUBORLU', '35', '2025-04-10 00:23:01.107079+00', '95');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('407', 'YALVAÇ', '35', '2025-04-10 00:23:01.107079+00', '21');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('408', 'YENİŞARBADEMLİ', '35', '2025-04-10 00:23:01.107079+00', '42');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('409', 'AKDENİZ', '17', '2025-04-10 00:23:01.107079+00', '54');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('410', 'ANAMUR', '17', '2025-04-10 00:23:01.107079+00', '90');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('411', 'AYDINCIK', '17', '2025-04-10 00:23:01.107079+00', '66');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('412', 'BOZYAZI', '17', '2025-04-10 00:23:01.107079+00', '69');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('413', 'ÇAMLIYAYLA', '17', '2025-04-10 00:23:01.107079+00', '75');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('414', 'ERDEMLİ', '17', '2025-04-10 00:23:01.107079+00', '93');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('415', 'GÜLNAR', '17', '2025-04-10 00:23:01.107079+00', '34');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('416', 'MEZİTLİ', '17', '2025-04-10 00:23:01.107079+00', '4');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('417', 'MUT', '17', '2025-04-10 00:23:01.107079+00', '65');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('418', 'SİLİFKE', '17', '2025-04-10 00:23:01.107079+00', '83');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('419', 'TARSUS', '17', '2025-04-10 00:23:01.107079+00', '49');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('420', 'TOROSLAR', '17', '2025-04-10 00:23:01.107079+00', '2');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('421', 'YENİŞEHİR', '17', '2025-04-10 00:23:01.107079+00', '42');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('422', 'ADALAR', '77', '2025-04-10 00:23:01.107079+00', '75');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('423', 'ARNAVUTKÖY', '77', '2025-04-10 00:23:01.107079+00', '18');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('424', 'ATAŞEHİR', '77', '2025-04-10 00:23:01.107079+00', '77');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('425', 'AVCILAR', '77', '2025-04-10 00:23:01.107079+00', '22');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('426', 'BAĞCILAR', '77', '2025-04-10 00:23:01.107079+00', '8');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('427', 'BAHÇELİEVLER', '77', '2025-04-10 00:23:01.107079+00', '0');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('428', 'BAKIRKÖY', '77', '2025-04-10 00:23:01.107079+00', '20');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('429', 'BAŞAKŞEHİR', '77', '2025-04-10 00:23:01.107079+00', '12');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('430', 'BAYRAMPAŞA', '77', '2025-04-10 00:23:01.107079+00', '37');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('431', 'BEŞİKTAŞ', '77', '2025-04-10 00:23:01.107079+00', '25');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('432', 'BEYKOZ', '77', '2025-04-10 00:23:01.107079+00', '85');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('433', 'BEYLİKDÜZÜ', '77', '2025-04-10 00:23:01.107079+00', '70');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('434', 'BEYOĞLU', '77', '2025-04-10 00:23:01.107079+00', '52');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('435', 'BÜYÜKÇEKMECE', '77', '2025-04-10 00:23:01.107079+00', '11');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('436', 'ÇATALCA', '77', '2025-04-10 00:23:01.107079+00', '67');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('437', 'ÇEKMEKÖY', '77', '2025-04-10 00:23:01.107079+00', '84');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('438', 'ESENLER', '77', '2025-04-10 00:23:01.107079+00', '28');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('439', 'ESENYURT', '77', '2025-04-10 00:23:01.107079+00', '51');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('440', 'EYÜPSULTAN', '77', '2025-04-10 00:23:01.107079+00', '8');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('441', 'FATİH', '77', '2025-04-10 00:23:01.107079+00', '15');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('442', 'GAZİOSMANPAŞA', '77', '2025-04-10 00:23:01.107079+00', '3');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('443', 'GÜNGÖREN', '77', '2025-04-10 00:23:01.107079+00', '77');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('444', 'KADIKÖY', '77', '2025-04-10 00:23:01.107079+00', '5');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('445', 'KAĞITHANE', '77', '2025-04-10 00:23:01.107079+00', '39');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('446', 'KARTAL', '77', '2025-04-10 00:23:01.107079+00', '58');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('447', 'KÜÇÜKÇEKMECE', '77', '2025-04-10 00:23:01.107079+00', '13');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('448', 'MALTEPE', '77', '2025-04-10 00:23:01.107079+00', '44');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('449', 'PENDİK', '77', '2025-04-10 00:23:01.107079+00', '79');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('450', 'SANCAKTEPE', '77', '2025-04-10 00:23:01.107079+00', '62');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('451', 'SARIYER', '77', '2025-04-10 00:23:01.107079+00', '23');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('452', 'SİLİVRİ', '77', '2025-04-10 00:23:01.107079+00', '24');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('453', 'SULTANBEYLİ', '77', '2025-04-10 00:23:01.107079+00', '61');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('454', 'SULTANGAZİ', '77', '2025-04-10 00:23:01.107079+00', '89');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('455', 'ŞİLE', '77', '2025-04-10 00:23:01.107079+00', '96');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('456', 'ŞİŞLİ', '77', '2025-04-10 00:23:01.107079+00', '71');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('457', 'TUZLA', '77', '2025-04-10 00:23:01.107079+00', '64');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('458', 'ÜMRANİYE', '77', '2025-04-10 00:23:01.107079+00', '63');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('459', 'ÜSKÜDAR', '77', '2025-04-10 00:23:01.107079+00', '53');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('460', 'ZEYTİNBURNU', '77', '2025-04-10 00:23:01.107079+00', '21');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('461', 'ALİAĞA', '84', '2025-04-10 00:23:01.107079+00', '26');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('462', 'BALÇOVA', '84', '2025-04-10 00:23:01.107079+00', '74');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('463', 'BAYINDIR', '84', '2025-04-10 00:23:01.107079+00', '73');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('464', 'BAYRAKLI', '84', '2025-04-10 00:23:01.107079+00', '75');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('465', 'BERGAMA', '84', '2025-04-10 00:23:01.107079+00', '51');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('466', 'BEYDAĞ', '84', '2025-04-10 00:23:01.107079+00', '88');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('467', 'BORNOVA', '84', '2025-04-10 00:23:01.107079+00', '69');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('468', 'BUCA', '84', '2025-04-10 00:23:01.107079+00', '15');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('469', 'ÇEŞME', '84', '2025-04-10 00:23:01.107079+00', '44');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('470', 'ÇİĞLİ', '84', '2025-04-10 00:23:01.107079+00', '65');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('471', 'DİKİLİ', '84', '2025-04-10 00:23:01.107079+00', '23');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('472', 'FOÇA', '84', '2025-04-10 00:23:01.107079+00', '70');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('473', 'GAZİEMİR', '84', '2025-04-10 00:23:01.107079+00', '66');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('474', 'GÜZELBAHÇE', '84', '2025-04-10 00:23:01.107079+00', '96');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('475', 'KARABAĞLAR', '84', '2025-04-10 00:23:01.107079+00', '6');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('476', 'KARABURUN', '84', '2025-04-10 00:23:01.107079+00', '81');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('477', 'KARŞIYAKA', '84', '2025-04-10 00:23:01.107079+00', '76');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('478', 'KEMALPAŞA', '84', '2025-04-10 00:23:01.107079+00', '80');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('479', 'KINIK', '84', '2025-04-10 00:23:01.107079+00', '52');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('480', 'KİRAZ', '84', '2025-04-10 00:23:01.107079+00', '17');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('481', 'KONAK', '84', '2025-04-10 00:23:01.107079+00', '54');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('482', 'MENDERES', '84', '2025-04-10 00:23:01.107079+00', '81');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('483', 'MENEMEN', '84', '2025-04-10 00:23:01.107079+00', '43');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('484', 'NARLIDERE', '84', '2025-04-10 00:23:01.107079+00', '34');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('485', 'ÖDEMİŞ', '84', '2025-04-10 00:23:01.107079+00', '39');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('486', 'SEFERİHİSAR', '84', '2025-04-10 00:23:01.107079+00', '89');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('487', 'SELÇUK', '84', '2025-04-10 00:23:01.107079+00', '24');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('488', 'TİRE', '84', '2025-04-10 00:23:01.107079+00', '43');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('489', 'TORBALI', '84', '2025-04-10 00:23:01.107079+00', '49');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('490', 'URLA', '84', '2025-04-10 00:23:01.107079+00', '72');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('491', 'AKYAKA', '40', '2025-04-10 00:23:01.107079+00', '92');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('492', 'ARPAÇAY', '40', '2025-04-10 00:23:01.107079+00', '41');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('493', 'DİGOR', '40', '2025-04-10 00:23:01.107079+00', '68');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('494', 'KAĞIZMAN', '40', '2025-04-10 00:23:01.107079+00', '46');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('495', 'MERKEZ', '40', '2025-04-10 00:23:01.107079+00', '73');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('496', 'SARIKAMIŞ', '40', '2025-04-10 00:23:01.107079+00', '45');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('497', 'SELİM', '40', '2025-04-10 00:23:01.107079+00', '88');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('498', 'SUSUZ', '40', '2025-04-10 00:23:01.107079+00', '6');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('499', 'ABANA', '65', '2025-04-10 00:23:01.107079+00', '12');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('500', 'AĞLI', '65', '2025-04-10 00:23:01.107079+00', '89');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('501', 'ARAÇ', '65', '2025-04-10 00:23:01.107079+00', '3');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('502', 'AZDAVAY', '65', '2025-04-10 00:23:01.107079+00', '13');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('503', 'BOZKURT', '65', '2025-04-10 00:23:01.107079+00', '8');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('504', 'CİDE', '65', '2025-04-10 00:23:01.107079+00', '72');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('505', 'ÇATALZEYTİN', '65', '2025-04-10 00:23:01.107079+00', '99');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('506', 'DADAY', '65', '2025-04-10 00:23:01.107079+00', '75');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('507', 'DEVREKANİ', '65', '2025-04-10 00:23:01.107079+00', '26');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('508', 'DOĞANYURT', '65', '2025-04-10 00:23:01.107079+00', '42');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('509', 'HANÖNÜ', '65', '2025-04-10 00:23:01.107079+00', '58');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('510', 'İHSANGAZİ', '65', '2025-04-10 00:23:01.107079+00', '16');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('511', 'İNEBOLU', '65', '2025-04-10 00:23:01.107079+00', '97');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('512', 'KÜRE', '65', '2025-04-10 00:23:01.107079+00', '38');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('513', 'MERKEZ', '65', '2025-04-10 00:23:01.107079+00', '9');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('514', 'PINARBAŞI', '65', '2025-04-10 00:23:01.107079+00', '54');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('515', 'SEYDİLER', '65', '2025-04-10 00:23:01.107079+00', '34');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('516', 'ŞENPAZAR', '65', '2025-04-10 00:23:01.107079+00', '18');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('517', 'TAŞKÖPRÜ', '65', '2025-04-10 00:23:01.107079+00', '30');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('518', 'TOSYA', '65', '2025-04-10 00:23:01.107079+00', '7');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('519', 'AKKIŞLA', '8', '2025-04-10 00:23:01.107079+00', '86');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('520', 'BÜNYAN', '8', '2025-04-10 00:23:01.107079+00', '50');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('521', 'DEVELİ', '8', '2025-04-10 00:23:01.107079+00', '25');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('522', 'FELAHİYE', '8', '2025-04-10 00:23:01.107079+00', '69');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('523', 'HACILAR', '8', '2025-04-10 00:23:01.107079+00', '6');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('524', 'İNCESU', '8', '2025-04-10 00:23:01.107079+00', '72');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('525', 'KOCASİNAN', '8', '2025-04-10 00:23:01.107079+00', '68');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('526', 'MELİKGAZİ', '8', '2025-04-10 00:23:01.107079+00', '99');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('527', 'ÖZVATAN', '8', '2025-04-10 00:23:01.107079+00', '45');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('528', 'PINARBAŞI', '8', '2025-04-10 00:23:01.107079+00', '23');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('529', 'SARIOĞLAN', '8', '2025-04-10 00:23:01.107079+00', '87');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('530', 'SARIZ', '8', '2025-04-10 00:23:01.107079+00', '99');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('531', 'TALAS', '8', '2025-04-10 00:23:01.107079+00', '75');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('532', 'TOMARZA', '8', '2025-04-10 00:23:01.107079+00', '47');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('533', 'YAHYALI', '8', '2025-04-10 00:23:01.107079+00', '30');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('534', 'YEŞİLHİSAR', '8', '2025-04-10 00:23:01.107079+00', '55');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('535', 'BABAESKİ', '50', '2025-04-10 00:23:01.107079+00', '11');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('536', 'DEMİRKÖY', '50', '2025-04-10 00:23:01.107079+00', '53');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('537', 'KOFÇAZ', '50', '2025-04-10 00:23:01.107079+00', '4');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('538', 'LÜLEBURGAZ', '50', '2025-04-10 00:23:01.107079+00', '43');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('539', 'MERKEZ', '50', '2025-04-10 00:23:01.107079+00', '72');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('540', 'PEHLİVANKÖY', '50', '2025-04-10 00:23:01.107079+00', '48');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('541', 'PINARHİSAR', '50', '2025-04-10 00:23:01.107079+00', '66');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('542', 'VİZE', '50', '2025-04-10 00:23:01.107079+00', '70');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('543', 'AKÇAKENT', '27', '2025-04-10 00:23:01.107079+00', '80');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('544', 'AKPINAR', '27', '2025-04-10 00:23:01.107079+00', '59');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('545', 'BOZTEPE', '27', '2025-04-10 00:23:01.107079+00', '95');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('546', 'ÇİÇEKDAĞI', '27', '2025-04-10 00:23:01.107079+00', '19');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('547', 'KAMAN', '27', '2025-04-10 00:23:01.107079+00', '25');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('548', 'MERKEZ', '27', '2025-04-10 00:23:01.107079+00', '24');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('549', 'MUCUR', '27', '2025-04-10 00:23:01.107079+00', '94');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('550', 'BAŞİSKELE', '5', '2025-04-10 00:23:01.107079+00', '35');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('551', 'ÇAYIROVA', '5', '2025-04-10 00:23:01.107079+00', '50');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('552', 'DARICA', '5', '2025-04-10 00:23:01.107079+00', '29');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('553', 'DERİNCE', '5', '2025-04-10 00:23:01.107079+00', '33');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('554', 'DİLOVASI', '5', '2025-04-10 00:23:01.107079+00', '65');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('555', 'GEBZE', '5', '2025-04-10 00:23:01.107079+00', '59');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('556', 'GÖLCÜK', '5', '2025-04-10 00:23:01.107079+00', '89');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('557', 'İZMİT', '5', '2025-04-10 00:23:01.107079+00', '43');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('558', 'KANDIRA', '5', '2025-04-10 00:23:01.107079+00', '11');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('559', 'KARAMÜRSEL', '5', '2025-04-10 00:23:01.107079+00', '27');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('560', 'KARTEPE', '5', '2025-04-10 00:23:01.107079+00', '68');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('561', 'KÖRFEZ', '5', '2025-04-10 00:23:01.107079+00', '96');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('562', 'AHIRLI', '19', '2025-04-10 00:23:01.107079+00', '4');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('563', 'AKÖREN', '19', '2025-04-10 00:23:01.107079+00', '17');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('564', 'AKŞEHİR', '19', '2025-04-10 00:23:01.107079+00', '78');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('565', 'ALTINEKİN', '19', '2025-04-10 00:23:01.107079+00', '39');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('566', 'BEYŞEHİR', '19', '2025-04-10 00:23:01.107079+00', '93');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('567', 'BOZKIR', '19', '2025-04-10 00:23:01.107079+00', '92');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('568', 'CİHANBEYLİ', '19', '2025-04-10 00:23:01.107079+00', '84');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('569', 'ÇELTİK', '19', '2025-04-10 00:23:01.107079+00', '13');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('570', 'ÇUMRA', '19', '2025-04-10 00:23:01.107079+00', '52');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('571', 'DERBENT', '19', '2025-04-10 00:23:01.107079+00', '2');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('572', 'DEREBUCAK', '19', '2025-04-10 00:23:01.107079+00', '58');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('573', 'DOĞANHİSAR', '19', '2025-04-10 00:23:01.107079+00', '83');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('574', 'EMİRGAZİ', '19', '2025-04-10 00:23:01.107079+00', '17');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('575', 'EREĞLİ', '19', '2025-04-10 00:23:01.107079+00', '62');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('576', 'GÜNEYSINIR', '19', '2025-04-10 00:23:01.107079+00', '66');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('577', 'HADİM', '19', '2025-04-10 00:23:01.107079+00', '56');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('578', 'HALKAPINAR', '19', '2025-04-10 00:23:01.107079+00', '37');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('579', 'HÜYÜK', '19', '2025-04-10 00:23:01.107079+00', '65');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('580', 'ILGIN', '19', '2025-04-10 00:23:01.107079+00', '31');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('581', 'KADINHANI', '19', '2025-04-10 00:23:01.107079+00', '72');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('582', 'KARAPINAR', '19', '2025-04-10 00:23:01.107079+00', '48');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('583', 'KARATAY', '19', '2025-04-10 00:23:01.107079+00', '28');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('584', 'KULU', '19', '2025-04-10 00:23:01.107079+00', '60');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('585', 'MERAM', '19', '2025-04-10 00:23:01.107079+00', '0');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('586', 'SARAYÖNÜ', '19', '2025-04-10 00:23:01.107079+00', '63');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('587', 'SELÇUKLU', '19', '2025-04-10 00:23:01.107079+00', '38');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('588', 'SEYDİŞEHİR', '19', '2025-04-10 00:23:01.107079+00', '42');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('589', 'TAŞKENT', '19', '2025-04-10 00:23:01.107079+00', '32');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('590', 'TUZLUKÇU', '19', '2025-04-10 00:23:01.107079+00', '21');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('591', 'YALIHÜYÜK', '19', '2025-04-10 00:23:01.107079+00', '7');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('592', 'YUNAK', '19', '2025-04-10 00:23:01.107079+00', '52');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('593', 'ALTINTAŞ', '75', '2025-04-10 00:23:01.107079+00', '12');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('594', 'ASLANAPA', '75', '2025-04-10 00:23:01.107079+00', '78');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('595', 'ÇAVDARHİSAR', '75', '2025-04-10 00:23:01.107079+00', '82');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('596', 'DOMANİÇ', '75', '2025-04-10 00:23:01.107079+00', '91');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('597', 'DUMLUPINAR', '75', '2025-04-10 00:23:01.107079+00', '18');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('598', 'EMET', '75', '2025-04-10 00:23:01.107079+00', '69');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('599', 'GEDİZ', '75', '2025-04-10 00:23:01.107079+00', '87');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('600', 'HİSARCIK', '75', '2025-04-10 00:23:01.107079+00', '30');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('601', 'MERKEZ', '75', '2025-04-10 00:23:01.107079+00', '42');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('602', 'PAZARLAR', '75', '2025-04-10 00:23:01.107079+00', '66');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('603', 'SİMAV', '75', '2025-04-10 00:23:01.107079+00', '14');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('604', 'ŞAPHANE', '75', '2025-04-10 00:23:01.107079+00', '28');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('605', 'TAVŞANLI', '75', '2025-04-10 00:23:01.107079+00', '64');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('606', 'AKÇADAĞ', '43', '2025-04-10 00:23:01.107079+00', '14');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('607', 'ARAPGİR', '43', '2025-04-10 00:23:01.107079+00', '94');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('608', 'ARGUVAN', '43', '2025-04-10 00:23:01.107079+00', '42');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('609', 'BATTALGAZİ', '43', '2025-04-10 00:23:01.107079+00', '1');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('610', 'DARENDE', '43', '2025-04-10 00:23:01.107079+00', '97');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('611', 'DOĞANŞEHİR', '43', '2025-04-10 00:23:01.107079+00', '74');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('612', 'DOĞANYOL', '43', '2025-04-10 00:23:01.107079+00', '91');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('613', 'HEKİMHAN', '43', '2025-04-10 00:23:01.107079+00', '77');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('614', 'KALE', '43', '2025-04-10 00:23:01.107079+00', '73');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('615', 'KULUNCAK', '43', '2025-04-10 00:23:01.107079+00', '95');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('616', 'PÜTÜRGE', '43', '2025-04-10 00:23:01.107079+00', '53');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('617', 'YAZIHAN', '43', '2025-04-10 00:23:01.107079+00', '12');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('618', 'YEŞİLYURT', '43', '2025-04-10 00:23:01.107079+00', '7');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('619', 'AHMETLİ', '29', '2025-04-10 00:23:01.107079+00', '41');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('620', 'AKHİSAR', '29', '2025-04-10 00:23:01.107079+00', '67');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('621', 'ALAŞEHİR', '29', '2025-04-10 00:23:01.107079+00', '54');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('622', 'DEMİRCİ', '29', '2025-04-10 00:23:01.107079+00', '29');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('623', 'GÖLMARMARA', '29', '2025-04-10 00:23:01.107079+00', '89');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('624', 'GÖRDES', '29', '2025-04-10 00:23:01.107079+00', '10');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('625', 'KIRKAĞAÇ', '29', '2025-04-10 00:23:01.107079+00', '24');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('626', 'KÖPRÜBAŞI', '29', '2025-04-10 00:23:01.107079+00', '5');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('627', 'KULA', '29', '2025-04-10 00:23:01.107079+00', '50');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('628', 'SALİHLİ', '29', '2025-04-10 00:23:01.107079+00', '89');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('629', 'SARIGÖL', '29', '2025-04-10 00:23:01.107079+00', '6');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('630', 'SARUHANLI', '29', '2025-04-10 00:23:01.107079+00', '9');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('631', 'SELENDİ', '29', '2025-04-10 00:23:01.107079+00', '44');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('632', 'SOMA', '29', '2025-04-10 00:23:01.107079+00', '50');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('633', 'ŞEHZADELER', '29', '2025-04-10 00:23:01.107079+00', '65');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('634', 'TURGUTLU', '29', '2025-04-10 00:23:01.107079+00', '31');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('635', 'YUNUSEMRE', '29', '2025-04-10 00:23:01.107079+00', '76');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('636', 'AFŞİN', '67', '2025-04-10 00:23:01.107079+00', '26');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('637', 'ANDIRIN', '67', '2025-04-10 00:23:01.107079+00', '57');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('638', 'ÇAĞLAYANCERİT', '67', '2025-04-10 00:23:01.107079+00', '66');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('639', 'DULKADİROĞLU', '67', '2025-04-10 00:23:01.107079+00', '67');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('640', 'EKİNÖZÜ', '67', '2025-04-10 00:23:01.107079+00', '76');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('641', 'ELBİSTAN', '67', '2025-04-10 00:23:01.107079+00', '51');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('642', 'GÖKSUN', '67', '2025-04-10 00:23:01.107079+00', '47');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('643', 'NURHAK', '67', '2025-04-10 00:23:01.107079+00', '57');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('644', 'ONİKİŞUBAT', '67', '2025-04-10 00:23:01.107079+00', '88');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('645', 'PAZARCIK', '67', '2025-04-10 00:23:01.107079+00', '76');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('646', 'TÜRKOĞLU', '67', '2025-04-10 00:23:01.107079+00', '8');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('647', 'ARTUKLU', '66', '2025-04-10 00:23:01.107079+00', '55');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('648', 'DARGEÇİT', '66', '2025-04-10 00:23:01.107079+00', '97');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('649', 'DERİK', '66', '2025-04-10 00:23:01.107079+00', '41');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('650', 'KIZILTEPE', '66', '2025-04-10 00:23:01.107079+00', '90');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('651', 'MAZIDAĞI', '66', '2025-04-10 00:23:01.107079+00', '32');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('652', 'MİDYAT', '66', '2025-04-10 00:23:01.107079+00', '98');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('653', 'NUSAYBİN', '66', '2025-04-10 00:23:01.107079+00', '15');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('654', 'ÖMERLİ', '66', '2025-04-10 00:23:01.107079+00', '20');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('655', 'SAVUR', '66', '2025-04-10 00:23:01.107079+00', '94');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('656', 'YEŞİLLİ', '66', '2025-04-10 00:23:01.107079+00', '4');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('657', 'BODRUM', '48', '2025-04-10 00:23:01.107079+00', '64');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('658', 'DALAMAN', '48', '2025-04-10 00:23:01.107079+00', '62');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('659', 'DATÇA', '48', '2025-04-10 00:23:01.107079+00', '42');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('660', 'FETHİYE', '48', '2025-04-10 00:23:01.107079+00', '65');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('661', 'KAVAKLIDERE', '48', '2025-04-10 00:23:01.107079+00', '74');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('662', 'KÖYCEĞİZ', '48', '2025-04-10 00:23:01.107079+00', '81');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('663', 'MARMARİS', '48', '2025-04-10 00:23:01.107079+00', '2');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('664', 'MENTEŞE', '48', '2025-04-10 00:23:01.107079+00', '41');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('665', 'MİLAS', '48', '2025-04-10 00:23:01.107079+00', '30');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('666', 'ORTACA', '48', '2025-04-10 00:23:01.107079+00', '67');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('667', 'SEYDİKEMER', '48', '2025-04-10 00:23:01.107079+00', '1');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('668', 'ULA', '48', '2025-04-10 00:23:01.107079+00', '76');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('669', 'YATAĞAN', '48', '2025-04-10 00:23:01.107079+00', '47');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('670', 'BULANIK', '46', '2025-04-10 00:23:01.107079+00', '49');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('671', 'HASKÖY', '46', '2025-04-10 00:23:01.107079+00', '35');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('672', 'KORKUT', '46', '2025-04-10 00:23:01.107079+00', '31');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('673', 'MALAZGİRT', '46', '2025-04-10 00:23:01.107079+00', '98');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('674', 'MERKEZ', '46', '2025-04-10 00:23:01.107079+00', '67');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('675', 'VARTO', '46', '2025-04-10 00:23:01.107079+00', '50');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('676', 'ACIGÖL', '61', '2025-04-10 00:23:01.107079+00', '64');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('677', 'AVANOS', '61', '2025-04-10 00:23:01.107079+00', '85');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('678', 'DERİNKUYU', '61', '2025-04-10 00:23:01.107079+00', '10');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('679', 'GÜLŞEHİR', '61', '2025-04-10 00:23:01.107079+00', '47');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('680', 'HACIBEKTAŞ', '61', '2025-04-10 00:23:01.107079+00', '54');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('681', 'KOZAKLI', '61', '2025-04-10 00:23:01.107079+00', '5');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('682', 'MERKEZ', '61', '2025-04-10 00:23:01.107079+00', '38');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('683', 'ÜRGÜP', '61', '2025-04-10 00:23:01.107079+00', '91');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('684', 'ALTUNHİSAR', '18', '2025-04-10 00:23:01.107079+00', '53');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('685', 'BOR', '18', '2025-04-10 00:23:01.107079+00', '91');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('686', 'ÇAMARDI', '18', '2025-04-10 00:23:01.107079+00', '36');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('687', 'ÇİFTLİK', '18', '2025-04-10 00:23:01.107079+00', '77');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('688', 'MERKEZ', '18', '2025-04-10 00:23:01.107079+00', '35');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('689', 'ULUKIŞLA', '18', '2025-04-10 00:23:01.107079+00', '59');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('690', 'AKKUŞ', '24', '2025-04-10 00:23:01.107079+00', '48');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('691', 'ALTINORDU', '24', '2025-04-10 00:23:01.107079+00', '90');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('692', 'AYBASTI', '24', '2025-04-10 00:23:01.107079+00', '54');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('693', 'ÇAMAŞ', '24', '2025-04-10 00:23:01.107079+00', '13');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('694', 'ÇATALPINAR', '24', '2025-04-10 00:23:01.107079+00', '8');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('695', 'ÇAYBAŞI', '24', '2025-04-10 00:23:01.107079+00', '96');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('696', 'FATSA', '24', '2025-04-10 00:23:01.107079+00', '2');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('697', 'GÖLKÖY', '24', '2025-04-10 00:23:01.107079+00', '69');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('698', 'GÜLYALI', '24', '2025-04-10 00:23:01.107079+00', '80');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('699', 'GÜRGENTEPE', '24', '2025-04-10 00:23:01.107079+00', '23');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('700', 'İKİZCE', '24', '2025-04-10 00:23:01.107079+00', '56');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('701', 'KABADÜZ', '24', '2025-04-10 00:23:01.107079+00', '0');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('702', 'KABATAŞ', '24', '2025-04-10 00:23:01.107079+00', '38');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('703', 'KORGAN', '24', '2025-04-10 00:23:01.107079+00', '72');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('704', 'KUMRU', '24', '2025-04-10 00:23:01.107079+00', '55');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('705', 'MESUDİYE', '24', '2025-04-10 00:23:01.107079+00', '55');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('706', 'PERŞEMBE', '24', '2025-04-10 00:23:01.107079+00', '43');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('707', 'ULUBEY', '24', '2025-04-10 00:23:01.107079+00', '97');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('708', 'ÜNYE', '24', '2025-04-10 00:23:01.107079+00', '44');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('709', 'ARDEŞEN', '25', '2025-04-10 00:23:01.107079+00', '68');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('710', 'ÇAMLIHEMŞİN', '25', '2025-04-10 00:23:01.107079+00', '90');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('711', 'ÇAYELİ', '25', '2025-04-10 00:23:01.107079+00', '27');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('712', 'DEREPAZARI', '25', '2025-04-10 00:23:01.107079+00', '9');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('713', 'FINDIKLI', '25', '2025-04-10 00:23:01.107079+00', '24');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('714', 'GÜNEYSU', '25', '2025-04-10 00:23:01.107079+00', '5');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('715', 'HEMŞİN', '25', '2025-04-10 00:23:01.107079+00', '46');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('716', 'İKİZDERE', '25', '2025-04-10 00:23:01.107079+00', '91');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('717', 'İYİDERE', '25', '2025-04-10 00:23:01.107079+00', '73');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('718', 'KALKANDERE', '25', '2025-04-10 00:23:01.107079+00', '92');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('719', 'MERKEZ', '25', '2025-04-10 00:23:01.107079+00', '82');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('720', 'PAZAR', '25', '2025-04-10 00:23:01.107079+00', '39');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('721', 'ADAPAZARI', '10', '2025-04-10 00:23:01.107079+00', '34');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('722', 'AKYAZI', '10', '2025-04-10 00:23:01.107079+00', '76');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('723', 'ARİFİYE', '10', '2025-04-10 00:23:01.107079+00', '52');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('724', 'ERENLER', '10', '2025-04-10 00:23:01.107079+00', '16');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('725', 'FERİZLİ', '10', '2025-04-10 00:23:01.107079+00', '67');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('726', 'GEYVE', '10', '2025-04-10 00:23:01.107079+00', '83');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('727', 'HENDEK', '10', '2025-04-10 00:23:01.107079+00', '75');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('728', 'KARAPÜRÇEK', '10', '2025-04-10 00:23:01.107079+00', '24');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('729', 'KARASU', '10', '2025-04-10 00:23:01.107079+00', '27');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('730', 'KAYNARCA', '10', '2025-04-10 00:23:01.107079+00', '60');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('731', 'KOCAALİ', '10', '2025-04-10 00:23:01.107079+00', '26');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('732', 'PAMUKOVA', '10', '2025-04-10 00:23:01.107079+00', '65');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('733', 'SAPANCA', '10', '2025-04-10 00:23:01.107079+00', '50');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('734', 'SERDİVAN', '10', '2025-04-10 00:23:01.107079+00', '85');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('735', 'SÖĞÜTLÜ', '10', '2025-04-10 00:23:01.107079+00', '91');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('736', 'TARAKLI', '10', '2025-04-10 00:23:01.107079+00', '52');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('737', 'ALAÇAM', '71', '2025-04-10 00:23:01.107079+00', '29');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('738', 'ASARCIK', '71', '2025-04-10 00:23:01.107079+00', '78');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('739', 'ATAKUM', '71', '2025-04-10 00:23:01.107079+00', '93');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('740', 'AYVACIK', '71', '2025-04-10 00:23:01.107079+00', '84');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('741', 'BAFRA', '71', '2025-04-10 00:23:01.107079+00', '17');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('742', 'CANİK', '71', '2025-04-10 00:23:01.107079+00', '72');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('743', 'ÇARŞAMBA', '71', '2025-04-10 00:23:01.107079+00', '68');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('744', 'HAVZA', '71', '2025-04-10 00:23:01.107079+00', '31');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('745', 'İLKADIM', '71', '2025-04-10 00:23:01.107079+00', '26');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('746', 'KAVAK', '71', '2025-04-10 00:23:01.107079+00', '46');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('747', 'LADİK', '71', '2025-04-10 00:23:01.107079+00', '10');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('748', 'SALIPAZARI', '71', '2025-04-10 00:23:01.107079+00', '98');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('749', 'TEKKEKÖY', '71', '2025-04-10 00:23:01.107079+00', '6');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('750', 'TERME', '71', '2025-04-10 00:23:01.107079+00', '97');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('751', 'VEZİRKÖPRÜ', '71', '2025-04-10 00:23:01.107079+00', '15');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('752', 'YAKAKENT', '71', '2025-04-10 00:23:01.107079+00', '0');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('753', '19 MAYIS', '71', '2025-04-10 00:23:01.107079+00', '28');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('754', 'BAYKAN', '51', '2025-04-10 00:23:01.107079+00', '2');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('755', 'ERUH', '51', '2025-04-10 00:23:01.107079+00', '71');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('756', 'KURTALAN', '51', '2025-04-10 00:23:01.107079+00', '88');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('757', 'MERKEZ', '51', '2025-04-10 00:23:01.107079+00', '42');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('758', 'PERVARİ', '51', '2025-04-10 00:23:01.107079+00', '34');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('759', 'ŞİRVAN', '51', '2025-04-10 00:23:01.107079+00', '32');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('760', 'TİLLO', '51', '2025-04-10 00:23:01.107079+00', '38');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('761', 'AYANCIK', '14', '2025-04-10 00:23:01.107079+00', '75');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('762', 'BOYABAT', '14', '2025-04-10 00:23:01.107079+00', '15');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('763', 'DİKMEN', '14', '2025-04-10 00:23:01.107079+00', '57');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('764', 'DURAĞAN', '14', '2025-04-10 00:23:01.107079+00', '20');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('765', 'ERFELEK', '14', '2025-04-10 00:23:01.107079+00', '89');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('766', 'GERZE', '14', '2025-04-10 00:23:01.107079+00', '48');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('767', 'MERKEZ', '14', '2025-04-10 00:23:01.107079+00', '68');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('768', 'SARAYDÜZÜ', '14', '2025-04-10 00:23:01.107079+00', '8');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('769', 'TÜRKELİ', '14', '2025-04-10 00:23:01.107079+00', '37');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('770', 'AKINCILAR', '63', '2025-04-10 00:23:01.107079+00', '14');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('771', 'ALTINYAYLA', '63', '2025-04-10 00:23:01.107079+00', '74');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('772', 'DİVRİĞİ', '63', '2025-04-10 00:23:01.107079+00', '85');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('773', 'DOĞANŞAR', '63', '2025-04-10 00:23:01.107079+00', '54');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('774', 'GEMEREK', '63', '2025-04-10 00:23:01.107079+00', '1');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('775', 'GÖLOVA', '63', '2025-04-10 00:23:01.107079+00', '45');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('776', 'GÜRÜN', '63', '2025-04-10 00:23:01.107079+00', '79');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('777', 'HAFİK', '63', '2025-04-10 00:23:01.107079+00', '32');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('778', 'İMRANLI', '63', '2025-04-10 00:23:01.107079+00', '38');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('779', 'KANGAL', '63', '2025-04-10 00:23:01.107079+00', '31');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('780', 'KOYULHİSAR', '63', '2025-04-10 00:23:01.107079+00', '29');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('781', 'MERKEZ', '63', '2025-04-10 00:23:01.107079+00', '31');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('782', 'SUŞEHRİ', '63', '2025-04-10 00:23:01.107079+00', '18');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('783', 'ŞARKIŞLA', '63', '2025-04-10 00:23:01.107079+00', '88');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('784', 'ULAŞ', '63', '2025-04-10 00:23:01.107079+00', '29');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('785', 'YILDIZELİ', '63', '2025-04-10 00:23:01.107079+00', '37');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('786', 'ZARA', '63', '2025-04-10 00:23:01.107079+00', '9');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('787', 'ÇERKEZKÖY', '49', '2025-04-10 00:23:01.107079+00', '67');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('788', 'ÇORLU', '49', '2025-04-10 00:23:01.107079+00', '22');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('789', 'ERGENE', '49', '2025-04-10 00:23:01.107079+00', '5');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('790', 'HAYRABOLU', '49', '2025-04-10 00:23:01.107079+00', '44');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('791', 'KAPAKLI', '49', '2025-04-10 00:23:01.107079+00', '81');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('792', 'MALKARA', '49', '2025-04-10 00:23:01.107079+00', '35');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('793', 'MARMARAEREĞLİSİ', '49', '2025-04-10 00:23:01.107079+00', '73');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('794', 'MURATLI', '49', '2025-04-10 00:23:01.107079+00', '41');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('795', 'SARAY', '49', '2025-04-10 00:23:01.107079+00', '94');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('796', 'SÜLEYMANPAŞA', '49', '2025-04-10 00:23:01.107079+00', '89');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('797', 'ŞARKÖY', '49', '2025-04-10 00:23:01.107079+00', '40');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('798', 'ALMUS', '20', '2025-04-10 00:23:01.107079+00', '70');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('799', 'ARTOVA', '20', '2025-04-10 00:23:01.107079+00', '83');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('800', 'BAŞÇİFTLİK', '20', '2025-04-10 00:23:01.107079+00', '62');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('801', 'ERBAA', '20', '2025-04-10 00:23:01.107079+00', '29');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('802', 'MERKEZ', '20', '2025-04-10 00:23:01.107079+00', '54');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('803', 'NİKSAR', '20', '2025-04-10 00:23:01.107079+00', '74');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('804', 'PAZAR', '20', '2025-04-10 00:23:01.107079+00', '99');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('805', 'REŞADİYE', '20', '2025-04-10 00:23:01.107079+00', '93');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('806', 'SULUSARAY', '20', '2025-04-10 00:23:01.107079+00', '0');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('807', 'TURHAL', '20', '2025-04-10 00:23:01.107079+00', '3');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('808', 'YEŞİLYURT', '20', '2025-04-10 00:23:01.107079+00', '4');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('809', 'ZİLE', '20', '2025-04-10 00:23:01.107079+00', '64');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('810', 'AKÇAABAT', '62', '2025-04-10 00:23:01.107079+00', '51');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('811', 'ARAKLI', '62', '2025-04-10 00:23:01.107079+00', '48');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('812', 'ARSİN', '62', '2025-04-10 00:23:01.107079+00', '34');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('813', 'BEŞİKDÜZÜ', '62', '2025-04-10 00:23:01.107079+00', '37');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('814', 'ÇARŞIBAŞI', '62', '2025-04-10 00:23:01.107079+00', '33');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('815', 'ÇAYKARA', '62', '2025-04-10 00:23:01.107079+00', '57');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('816', 'DERNEKPAZARI', '62', '2025-04-10 00:23:01.107079+00', '88');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('817', 'DÜZKÖY', '62', '2025-04-10 00:23:01.107079+00', '78');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('818', 'HAYRAT', '62', '2025-04-10 00:23:01.107079+00', '36');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('819', 'KÖPRÜBAŞI', '62', '2025-04-10 00:23:01.107079+00', '45');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('820', 'MAÇKA', '62', '2025-04-10 00:23:01.107079+00', '99');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('821', 'OF', '62', '2025-04-10 00:23:01.107079+00', '59');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('822', 'ORTAHİSAR', '62', '2025-04-10 00:23:01.107079+00', '56');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('823', 'SÜRMENE', '62', '2025-04-10 00:23:01.107079+00', '58');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('824', 'ŞALPAZARI', '62', '2025-04-10 00:23:01.107079+00', '98');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('825', 'TONYA', '62', '2025-04-10 00:23:01.107079+00', '8');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('826', 'VAKFIKEBİR', '62', '2025-04-10 00:23:01.107079+00', '96');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('827', 'YOMRA', '62', '2025-04-10 00:23:01.107079+00', '25');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('828', 'ÇEMİŞGEZEK', '79', '2025-04-10 00:23:01.107079+00', '29');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('829', 'HOZAT', '79', '2025-04-10 00:23:01.107079+00', '96');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('830', 'MAZGİRT', '79', '2025-04-10 00:23:01.107079+00', '39');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('831', 'MERKEZ', '79', '2025-04-10 00:23:01.107079+00', '6');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('832', 'NAZIMİYE', '79', '2025-04-10 00:23:01.107079+00', '76');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('833', 'OVACIK', '79', '2025-04-10 00:23:01.107079+00', '4');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('834', 'PERTEK', '79', '2025-04-10 00:23:01.107079+00', '32');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('835', 'PÜLÜMÜR', '79', '2025-04-10 00:23:01.107079+00', '67');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('836', 'AKÇAKALE', '53', '2025-04-10 00:23:01.107079+00', '11');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('837', 'BİRECİK', '53', '2025-04-10 00:23:01.107079+00', '52');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('838', 'BOZOVA', '53', '2025-04-10 00:23:01.107079+00', '9');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('839', 'CEYLANPINAR', '53', '2025-04-10 00:23:01.107079+00', '12');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('840', 'EYYÜBİYE', '53', '2025-04-10 00:23:01.107079+00', '24');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('841', 'HALFETİ', '53', '2025-04-10 00:23:01.107079+00', '77');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('842', 'HALİLİYE', '53', '2025-04-10 00:23:01.107079+00', '0');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('843', 'HARRAN', '53', '2025-04-10 00:23:01.107079+00', '91');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('844', 'HİLVAN', '53', '2025-04-10 00:23:01.107079+00', '87');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('845', 'KARAKÖPRÜ', '53', '2025-04-10 00:23:01.107079+00', '17');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('846', 'SİVEREK', '53', '2025-04-10 00:23:01.107079+00', '7');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('847', 'SURUÇ', '53', '2025-04-10 00:23:01.107079+00', '65');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('848', 'VİRANŞEHİR', '53', '2025-04-10 00:23:01.107079+00', '41');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('849', 'BANAZ', '31', '2025-04-10 00:23:01.107079+00', '73');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('850', 'EŞME', '31', '2025-04-10 00:23:01.107079+00', '29');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('851', 'KARAHALLI', '31', '2025-04-10 00:23:01.107079+00', '63');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('852', 'MERKEZ', '31', '2025-04-10 00:23:01.107079+00', '39');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('853', 'SİVASLI', '31', '2025-04-10 00:23:01.107079+00', '77');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('854', 'ULUBEY', '31', '2025-04-10 00:23:01.107079+00', '60');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('855', 'BAHÇESARAY', '73', '2025-04-10 00:23:01.107079+00', '41');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('856', 'BAŞKALE', '73', '2025-04-10 00:23:01.107079+00', '45');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('857', 'ÇALDIRAN', '73', '2025-04-10 00:23:01.107079+00', '30');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('858', 'ÇATAK', '73', '2025-04-10 00:23:01.107079+00', '92');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('859', 'EDREMİT', '73', '2025-04-10 00:23:01.107079+00', '12');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('860', 'ERCİŞ', '73', '2025-04-10 00:23:01.107079+00', '23');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('861', 'GEVAŞ', '73', '2025-04-10 00:23:01.107079+00', '40');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('862', 'GÜRPINAR', '73', '2025-04-10 00:23:01.107079+00', '25');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('863', 'İPEKYOLU', '73', '2025-04-10 00:23:01.107079+00', '50');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('864', 'MURADİYE', '73', '2025-04-10 00:23:01.107079+00', '19');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('865', 'ÖZALP', '73', '2025-04-10 00:23:01.107079+00', '9');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('866', 'SARAY', '73', '2025-04-10 00:23:01.107079+00', '33');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('867', 'TUŞBA', '73', '2025-04-10 00:23:01.107079+00', '39');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('868', 'AKDAĞMADENİ', '23', '2025-04-10 00:23:01.107079+00', '91');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('869', 'AYDINCIK', '23', '2025-04-10 00:23:01.107079+00', '38');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('870', 'BOĞAZLIYAN', '23', '2025-04-10 00:23:01.107079+00', '86');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('871', 'ÇANDIR', '23', '2025-04-10 00:23:01.107079+00', '68');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('872', 'ÇAYIRALAN', '23', '2025-04-10 00:23:01.107079+00', '38');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('873', 'ÇEKEREK', '23', '2025-04-10 00:23:01.107079+00', '42');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('874', 'KADIŞEHRİ', '23', '2025-04-10 00:23:01.107079+00', '9');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('875', 'MERKEZ', '23', '2025-04-10 00:23:01.107079+00', '66');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('876', 'SARAYKENT', '23', '2025-04-10 00:23:01.107079+00', '36');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('877', 'SARIKAYA', '23', '2025-04-10 00:23:01.107079+00', '53');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('878', 'SORGUN', '23', '2025-04-10 00:23:01.107079+00', '85');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('879', 'ŞEFAATLİ', '23', '2025-04-10 00:23:01.107079+00', '41');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('880', 'YENİFAKILI', '23', '2025-04-10 00:23:01.107079+00', '18');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('881', 'YERKÖY', '23', '2025-04-10 00:23:01.107079+00', '9');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('882', 'ALAPLI', '41', '2025-04-10 00:23:01.107079+00', '16');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('883', 'ÇAYCUMA', '41', '2025-04-10 00:23:01.107079+00', '38');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('884', 'DEVREK', '41', '2025-04-10 00:23:01.107079+00', '55');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('885', 'EREĞLİ', '41', '2025-04-10 00:23:01.107079+00', '19');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('886', 'GÖKÇEBEY', '41', '2025-04-10 00:23:01.107079+00', '97');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('887', 'KİLİMLİ', '41', '2025-04-10 00:23:01.107079+00', '10');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('888', 'KOZLU', '41', '2025-04-10 00:23:01.107079+00', '34');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('889', 'MERKEZ', '41', '2025-04-10 00:23:01.107079+00', '97');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('890', 'AĞAÇÖREN', '42', '2025-04-10 00:23:01.107079+00', '54');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('891', 'ESKİL', '42', '2025-04-10 00:23:01.107079+00', '61');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('892', 'GÜLAĞAÇ', '42', '2025-04-10 00:23:01.107079+00', '67');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('893', 'GÜZELYURT', '42', '2025-04-10 00:23:01.107079+00', '52');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('894', 'MERKEZ', '42', '2025-04-10 00:23:01.107079+00', '99');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('895', 'ORTAKÖY', '42', '2025-04-10 00:23:01.107079+00', '93');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('896', 'SARIYAHŞİ', '42', '2025-04-10 00:23:01.107079+00', '61');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('897', 'SULTANHANI', '42', '2025-04-10 00:23:01.107079+00', '11');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('898', 'AYDINTEPE', '12', '2025-04-10 00:23:01.107079+00', '9');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('899', 'DEMİRÖZÜ', '12', '2025-04-10 00:23:01.107079+00', '1');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('900', 'MERKEZ', '12', '2025-04-10 00:23:01.107079+00', '2');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('901', 'AYRANCI', '83', '2025-04-10 00:23:01.107079+00', '31');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('902', 'BAŞYAYLA', '83', '2025-04-10 00:23:01.107079+00', '98');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('903', 'ERMENEK', '83', '2025-04-10 00:23:01.107079+00', '15');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('904', 'KAZIMKARABEKİR', '83', '2025-04-10 00:23:01.107079+00', '9');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('905', 'MERKEZ', '83', '2025-04-10 00:23:01.107079+00', '1');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('906', 'SARIVELİLER', '83', '2025-04-10 00:23:01.107079+00', '54');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('907', 'BAHŞİLİ', '82', '2025-04-10 00:23:01.107079+00', '66');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('908', 'BALIŞEYH', '82', '2025-04-10 00:23:01.107079+00', '42');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('909', 'ÇELEBİ', '82', '2025-04-10 00:23:01.107079+00', '96');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('910', 'DELİCE', '82', '2025-04-10 00:23:01.107079+00', '53');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('911', 'KARAKEÇİLİ', '82', '2025-04-10 00:23:01.107079+00', '2');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('912', 'KESKİN', '82', '2025-04-10 00:23:01.107079+00', '17');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('913', 'MERKEZ', '82', '2025-04-10 00:23:01.107079+00', '0');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('914', 'SULAKYURT', '82', '2025-04-10 00:23:01.107079+00', '43');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('915', 'YAHŞİHAN', '82', '2025-04-10 00:23:01.107079+00', '89');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('916', 'BEŞİRİ', '55', '2025-04-10 00:23:01.107079+00', '34');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('917', 'GERCÜŞ', '55', '2025-04-10 00:23:01.107079+00', '24');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('918', 'HASANKEYF', '55', '2025-04-10 00:23:01.107079+00', '65');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('919', 'KOZLUK', '55', '2025-04-10 00:23:01.107079+00', '14');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('920', 'MERKEZ', '55', '2025-04-10 00:23:01.107079+00', '11');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('921', 'SASON', '55', '2025-04-10 00:23:01.107079+00', '42');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('922', 'BEYTÜŞŞEBAP', '47', '2025-04-10 00:23:01.107079+00', '61');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('923', 'CİZRE', '47', '2025-04-10 00:23:01.107079+00', '38');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('924', 'GÜÇLÜKONAK', '47', '2025-04-10 00:23:01.107079+00', '86');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('925', 'İDİL', '47', '2025-04-10 00:23:01.107079+00', '15');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('926', 'MERKEZ', '47', '2025-04-10 00:23:01.107079+00', '7');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('927', 'SİLOPİ', '47', '2025-04-10 00:23:01.107079+00', '31');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('928', 'ULUDERE', '47', '2025-04-10 00:23:01.107079+00', '89');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('929', 'AMASRA', '15', '2025-04-10 00:23:01.107079+00', '37');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('930', 'KURUCAŞİLE', '15', '2025-04-10 00:23:01.107079+00', '45');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('931', 'MERKEZ', '15', '2025-04-10 00:23:01.107079+00', '80');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('932', 'ULUS', '15', '2025-04-10 00:23:01.107079+00', '42');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('933', 'ÇILDIR', '69', '2025-04-10 00:23:01.107079+00', '64');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('934', 'DAMAL', '69', '2025-04-10 00:23:01.107079+00', '11');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('935', 'GÖLE', '69', '2025-04-10 00:23:01.107079+00', '3');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('936', 'HANAK', '69', '2025-04-10 00:23:01.107079+00', '0');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('937', 'MERKEZ', '69', '2025-04-10 00:23:01.107079+00', '83');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('938', 'POSOF', '69', '2025-04-10 00:23:01.107079+00', '27');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('939', 'ARALIK', '28', '2025-04-10 00:23:01.107079+00', '33');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('940', 'KARAKOYUNLU', '28', '2025-04-10 00:23:01.107079+00', '30');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('941', 'MERKEZ', '28', '2025-04-10 00:23:01.107079+00', '2');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('942', 'TUZLUCA', '28', '2025-04-10 00:23:01.107079+00', '98');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('943', 'ALTINOVA', '60', '2025-04-10 00:23:01.107079+00', '43');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('944', 'ARMUTLU', '60', '2025-04-10 00:23:01.107079+00', '90');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('945', 'ÇINARCIK', '60', '2025-04-10 00:23:01.107079+00', '12');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('946', 'ÇİFTLİKKÖY', '60', '2025-04-10 00:23:01.107079+00', '34');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('947', 'MERKEZ', '60', '2025-04-10 00:23:01.107079+00', '28');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('948', 'TERMAL', '60', '2025-04-10 00:23:01.107079+00', '47');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('949', 'EFLANİ', '38', '2025-04-10 00:23:01.107079+00', '3');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('950', 'ESKİPAZAR', '38', '2025-04-10 00:23:01.107079+00', '20');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('951', 'MERKEZ', '38', '2025-04-10 00:23:01.107079+00', '64');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('952', 'OVACIK', '38', '2025-04-10 00:23:01.107079+00', '2');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('953', 'SAFRANBOLU', '38', '2025-04-10 00:23:01.107079+00', '11');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('954', 'YENİCE', '38', '2025-04-10 00:23:01.107079+00', '0');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('955', 'ELBEYLİ', '78', '2025-04-10 00:23:01.107079+00', '52');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('956', 'MERKEZ', '78', '2025-04-10 00:23:01.107079+00', '80');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('957', 'MUSABEYLİ', '78', '2025-04-10 00:23:01.107079+00', '68');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('958', 'POLATELİ', '78', '2025-04-10 00:23:01.107079+00', '19');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('959', 'BAHÇE', '4', '2025-04-10 00:23:01.107079+00', '50');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('960', 'DÜZİÇİ', '4', '2025-04-10 00:23:01.107079+00', '23');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('961', 'HASANBEYLİ', '4', '2025-04-10 00:23:01.107079+00', '65');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('962', 'KADİRLİ', '4', '2025-04-10 00:23:01.107079+00', '89');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('963', 'MERKEZ', '4', '2025-04-10 00:23:01.107079+00', '44');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('964', 'SUMBAS', '4', '2025-04-10 00:23:01.107079+00', '13');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('965', 'TOPRAKKALE', '4', '2025-04-10 00:23:01.107079+00', '34');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('966', 'AKÇAKOCA', '70', '2025-04-10 00:23:01.107079+00', '42');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('967', 'CUMAYERİ', '70', '2025-04-10 00:23:01.107079+00', '81');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('968', 'ÇİLİMLİ', '70', '2025-04-10 00:23:01.107079+00', '68');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('969', 'GÖLYAKA', '70', '2025-04-10 00:23:01.107079+00', '93');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('970', 'GÜMÜŞOVA', '70', '2025-04-10 00:23:01.107079+00', '18');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('971', 'KAYNAŞLI', '70', '2025-04-10 00:23:01.107079+00', '8');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('972', 'MERKEZ', '70', '2025-04-10 00:23:01.107079+00', '26');
INSERT INTO "districts" ("id", "name", "city_id", "created_at", "problem_solving_rate") VALUES ('973', 'YIĞILCA', '70', '2025-04-10 00:23:01.107079+00', '61');

-- Tablo: survey_options için veri
INSERT INTO "survey_options" ("id", "survey_id", "text", "vote_count") VALUES ('1', '1', 'Çok memnunum', '45');
INSERT INTO "survey_options" ("id", "survey_id", "text", "vote_count") VALUES ('2', '1', 'Memnunum', '82');
INSERT INTO "survey_options" ("id", "survey_id", "text", "vote_count") VALUES ('3', '1', 'Kararsızım', '22');
INSERT INTO "survey_options" ("id", "survey_id", "text", "vote_count") VALUES ('4', '1', 'Memnun değilim', '58');
INSERT INTO "survey_options" ("id", "survey_id", "text", "vote_count") VALUES ('5', '1', 'Hiç memnun değilim', '93');
INSERT INTO "survey_options" ("id", "survey_id", "text", "vote_count") VALUES ('6', '2', 'Çok iyi', '35');
INSERT INTO "survey_options" ("id", "survey_id", "text", "vote_count") VALUES ('7', '2', 'İyi', '46');
INSERT INTO "survey_options" ("id", "survey_id", "text", "vote_count") VALUES ('8', '2', 'Ortalama', '32');
INSERT INTO "survey_options" ("id", "survey_id", "text", "vote_count") VALUES ('9', '2', 'Kötü', '54');
INSERT INTO "survey_options" ("id", "survey_id", "text", "vote_count") VALUES ('10', '2', 'Çok kötü', '27');
INSERT INTO "survey_options" ("id", "survey_id", "text", "vote_count") VALUES ('11', '3', 'Çok temiz ve düzenli', '81');
INSERT INTO "survey_options" ("id", "survey_id", "text", "vote_count") VALUES ('12', '3', 'Yeterince temiz', '53');
INSERT INTO "survey_options" ("id", "survey_id", "text", "vote_count") VALUES ('13', '3', 'Bazen sorunlar yaşanıyor', '91');
INSERT INTO "survey_options" ("id", "survey_id", "text", "vote_count") VALUES ('14', '3', 'Genellikle kirli', '46');
INSERT INTO "survey_options" ("id", "survey_id", "text", "vote_count") VALUES ('15', '3', 'Çok kirli ve düzensiz', '78');

-- Tablo: survey_regional_results için veri
-- Bu tablo boş, veri yok

-- Tablo: users için veri
INSERT INTO "users" ("id", "name", "email", "password", "profile_image_url", "bio", "city_id", "district_id", "is_verified", "points", "post_count", "comment_count", "level", "created_at", "username") VALUES ('4', 'Test Kullanıcı', 'test@example.com', 'ecd71870d1963316a97e3ac3408c9835ad8cf0f3c1bc703527c30265534f75ae', 'https://i.pravatar.cc/150?img=3', 'Bu bir test kullanıcısı hesabıdır', '26', '1', '1', '100', '0', '0', 'master', '2025-04-10 09:40:47.801913+00', 'test');
INSERT INTO "users" ("id", "name", "email", "password", "profile_image_url", "bio", "city_id", "district_id", "is_verified", "points", "post_count", "comment_count", "level", "created_at", "username") VALUES ('1', 'Admin', 'admin@example.com', '$2b$10$k55g2qPRBM6SCcW8BM3l1OkTEQoiL.Vgab21jzv8x2ZHIV5uC1Pqe', NULL, NULL, NULL, NULL, '1', '15', '0', '2', 'master', '2025-04-09 18:59:03.2124+00', 'admin');
INSERT INTO "users" ("id", "name", "email", "password", "profile_image_url", "bio", "city_id", "district_id", "is_verified", "points", "post_count", "comment_count", "level", "created_at", "username") VALUES ('135', 'Hüseyin Kaplan', 'huseyin.kaplan449@example.com', '565c3761ee159b4eceb2b3349dd79f0906d3890d6c72c0e0a3ae06581098f912.dd6ddc491eb536dbda303815646a4452', 'https://randomuser.me/api/portraits/women/3.jpg', NULL, '35', NULL, '', '0', '0', '0', 'newUser', '2025-04-11 20:28:28.663529+00', 'huseyin.kaplan449');
INSERT INTO "users" ("id", "name", "email", "password", "profile_image_url", "bio", "city_id", "district_id", "is_verified", "points", "post_count", "comment_count", "level", "created_at", "username") VALUES ('136', 'Erkan Alp', 'erkan.alp755@example.com', 'f694278f0c4dc50eb2a32278fe413ec4aabed56f22ec431a182dec3407164442.6cda990659316978ce6f462e3cecef6f', 'https://randomuser.me/api/portraits/men/5.jpg', NULL, '6', NULL, '', '0', '0', '0', 'contributor', '2025-04-11 20:28:28.663529+00', 'erkan.alp755');
INSERT INTO "users" ("id", "name", "email", "password", "profile_image_url", "bio", "city_id", "district_id", "is_verified", "points", "post_count", "comment_count", "level", "created_at", "username") VALUES ('137', 'Hülya Avcı', 'hulya.avci433@example.com', '3c48f1c477aa0ea333386090bf67dbdca4fb408bbc3a23c03d551ce62df16d96.537cd73a7274deb2d0c801bf36302b2a', 'https://randomuser.me/api/portraits/women/5.jpg', NULL, '6', NULL, '', '0', '0', '0', 'expert', '2025-04-11 20:28:28.663529+00', 'hulya.avci433');
INSERT INTO "users" ("id", "name", "email", "password", "profile_image_url", "bio", "city_id", "district_id", "is_verified", "points", "post_count", "comment_count", "level", "created_at", "username") VALUES ('138', 'Esra Öztürk', 'esra.ozturk858@example.com', '2fa24e894b170af0ba74d42bbbd8c80ba218202cfeeb916f45bd9591c3e77108.21096160806c7e0f7393b4ca3313a23e', 'https://randomuser.me/api/portraits/women/2.jpg', NULL, '2', NULL, '', '0', '0', '0', 'newUser', '2025-04-11 20:28:28.663529+00', 'esra.ozturk858');
INSERT INTO "users" ("id", "name", "email", "password", "profile_image_url", "bio", "city_id", "district_id", "is_verified", "points", "post_count", "comment_count", "level", "created_at", "username") VALUES ('139', 'Tuğçe Yıldız', 'tugce.yildiz794@example.com', '668252075e309fb5b24dc0fec773862e56bbf7b8a35b132d9b180c6d0f8674cf.9decf2c11dc3e9e3b488fec0ced13abb', 'https://randomuser.me/api/portraits/women/5.jpg', NULL, '2', NULL, '', '0', '0', '0', 'newUser', '2025-04-11 20:28:28.663529+00', 'tugce.yildiz794');
INSERT INTO "users" ("id", "name", "email", "password", "profile_image_url", "bio", "city_id", "district_id", "is_verified", "points", "post_count", "comment_count", "level", "created_at", "username") VALUES ('140', 'Yusuf Aktaş', 'yusuf.aktas364@example.com', '537134a878b669d09696ef32337d8b1d8957988b011cbab18a04ed3c4ef28c99.27bb492ca5b77cd4688b12773d92e98f', 'https://randomuser.me/api/portraits/women/1.jpg', NULL, '6', NULL, '', '0', '0', '0', 'expert', '2025-04-11 20:28:28.663529+00', 'yusuf.aktas364');
INSERT INTO "users" ("id", "name", "email", "password", "profile_image_url", "bio", "city_id", "district_id", "is_verified", "points", "post_count", "comment_count", "level", "created_at", "username") VALUES ('141', 'Gamze Aktaş', 'gamze.aktas195@example.com', '250d03357214b84e5470e2ebaa53b7963b0451df14d499a111526950a3f84c1c.a3a9c5ae2d6e696e3e50a2179ec082e0', 'https://randomuser.me/api/portraits/men/1.jpg', NULL, '6', NULL, '', '0', '0', '0', 'contributor', '2025-04-11 20:28:28.663529+00', 'gamze.aktas195');
INSERT INTO "users" ("id", "name", "email", "password", "profile_image_url", "bio", "city_id", "district_id", "is_verified", "points", "post_count", "comment_count", "level", "created_at", "username") VALUES ('142', 'Elif Yıldırım', 'elif.yildirim80@example.com', '39bbd9cbd947b3534ba0df16734d72f2b28f554e0832b4d52cdef340e035307a.1541fcab77c3d31c9c5c33f390cdf8f8', 'https://randomuser.me/api/portraits/women/1.jpg', NULL, '34', NULL, '', '0', '0', '0', 'newUser', '2025-04-11 20:28:28.663529+00', 'elif.yildirim80');
INSERT INTO "users" ("id", "name", "email", "password", "profile_image_url", "bio", "city_id", "district_id", "is_verified", "points", "post_count", "comment_count", "level", "created_at", "username") VALUES ('143', 'Emine Duran', 'emine.duran590@example.com', '3c93395ee446c283cd8c1566d90da04b283dfd24729f5e2405a0e03a6e539617.cb9e786191866dd3742e916924e71d16', 'https://randomuser.me/api/portraits/women/1.jpg', NULL, '2', NULL, '', '0', '0', '0', 'newUser', '2025-04-11 20:28:28.663529+00', 'emine.duran590');
INSERT INTO "users" ("id", "name", "email", "password", "profile_image_url", "bio", "city_id", "district_id", "is_verified", "points", "post_count", "comment_count", "level", "created_at", "username") VALUES ('144', 'Ahmet Tekin', 'ahmet.tekin215@example.com', '7a8b584095292d4f43a3044ce22beb8b256944e8dc7fdd3899842537856bd1b7.980bb42e7775ec5adc2e502ef3e45c34', 'https://randomuser.me/api/portraits/women/2.jpg', NULL, '35', NULL, '', '0', '0', '0', 'newUser', '2025-04-11 20:28:28.663529+00', 'ahmet.tekin215');

-- Tablo: city_awards için veri
INSERT INTO "city_awards" ("id", "city_id", "award_type_id", "title", "description", "award_date", "issuer", "certificate_url", "featured", "project_id", "created_at", "expiry_date") VALUES ('4', '57', '13', 'Altın Belediye Ödülü Ödülü', 'AFYONKARAHİSAR Şikayet çözüm oranı %75 ve üzerinde olan belediyeler', '2025-04-12', NULL, NULL, '', NULL, '2025-04-12 08:11:33.770746', '2025-05-12');
INSERT INTO "city_awards" ("id", "city_id", "award_type_id", "title", "description", "award_date", "issuer", "certificate_url", "featured", "project_id", "created_at", "expiry_date") VALUES ('5', '57', '13', 'Altın Belediye Ödülü Ödülü', 'AFYONKARAHİSAR Şikayet çözüm oranı %75 ve üzerinde olan belediyeler', '2025-04-12', NULL, NULL, '', NULL, '2025-04-12 08:12:02.786476', '2025-05-12');

-- Tablo: notifications için veri
INSERT INTO "notifications" ("id", "user_id", "title", "content", "type", "is_read", "source_id", "source_type", "data", "created_at") VALUES ('1', '135', 'Yorumunuza yanıt geldi', '@admin yorumunuza yanıt verdi: \"Merhaba\"', 'reply', '', '34', 'comment', NULL, '2025-04-13 08:11:52.727841+00');
INSERT INTO "notifications" ("id", "user_id", "title", "content", "type", "is_read", "source_id", "source_type", "data", "created_at") VALUES ('2', '135', 'Yorumunuza yanıt geldi', '@admin yorumunuza yanıt verdi: \"anonim\"', 'reply', '', '34', 'comment', NULL, '2025-04-13 08:12:06.489968+00');

-- Tablo: posts için veri
INSERT INTO "posts" ("id", "title", "content", "user_id", "category_id", "city_id", "district_id", "status", "type", "likes", "highlights", "comment_count", "is_anonymous", "created_at") VALUES ('1', 'Park alanında çöp sorunu', 'Atatürk Parkı\'nda son zamanlarda çöp kutuları düzenli olarak boşaltılmıyor. Özellikle hafta sonları park çöplerle doluyor ve kötü koku oluşuyor. Bu sorunun en kısa zamanda çözülmesi gerekiyor. Çocukların oyun alanları da temiz değil.', '4', '8', '8', '532', 'awaitingSolution', 'problem', '11', '6', '0', '', '2025-03-20 14:08:03.942137+00');
INSERT INTO "posts" ("id", "title", "content", "user_id", "category_id", "city_id", "district_id", "status", "type", "likes", "highlights", "comment_count", "is_anonymous", "created_at") VALUES ('2', 'Park alanında çöp sorunu', 'Atatürk Parkı\'nda son zamanlarda çöp kutuları düzenli olarak boşaltılmıyor. Özellikle hafta sonları park çöplerle doluyor ve kötü koku oluşuyor. Bu sorunun en kısa zamanda çözülmesi gerekiyor. Çocukların oyun alanları da temiz değil.', '4', '8', '8', '532', 'awaitingSolution', 'problem', '11', '6', '0', '', '2025-03-20 14:08:03.974548+00');
INSERT INTO "posts" ("id", "title", "content", "user_id", "category_id", "city_id", "district_id", "status", "type", "likes", "highlights", "comment_count", "is_anonymous", "created_at") VALUES ('3', 'İlçemizde yeni bisiklet yolları yapılsın', 'Bisiklet kullanımını teşvik etmek ve daha sağlıklı bir toplum oluşturmak için ilçemize güvenli bisiklet yolları yapılmasını öneriyorum. Özellikle ana caddelerde ve sahil şeridinde bisiklet yolları yapılırsa hem trafik rahatlar hem de insanlar daha fazla spor yapar.', '1', '6', '77', '425', 'rejected', 'suggestion', '21', '8', '0', '', '2025-03-29 14:08:04.341581+00');
INSERT INTO "posts" ("id", "title", "content", "user_id", "category_id", "city_id", "district_id", "status", "type", "likes", "highlights", "comment_count", "is_anonymous", "created_at") VALUES ('4', 'İlçemizde yeni bisiklet yolları yapılsın', 'Bisiklet kullanımını teşvik etmek ve daha sağlıklı bir toplum oluşturmak için ilçemize güvenli bisiklet yolları yapılmasını öneriyorum. Özellikle ana caddelerde ve sahil şeridinde bisiklet yolları yapılırsa hem trafik rahatlar hem de insanlar daha fazla spor yapar.', '1', '6', '77', '425', 'rejected', 'suggestion', '21', '8', '0', '', '2025-03-29 14:08:04.363866+00');
INSERT INTO "posts" ("id", "title", "content", "user_id", "category_id", "city_id", "district_id", "status", "type", "likes", "highlights", "comment_count", "is_anonymous", "created_at") VALUES ('5', 'Kaldırımlarda engelli erişimi sorunu', 'Merkez mahallede kaldırımların birçoğunda engelli rampaları ya yok ya da standartlara uygun değil. Tekerlekli sandalye kullananlar ve görme engelliler için bu durum büyük sorun yaratıyor. Ayrıca bazı kaldırımlarda ağaç kökleri kaldırımları kaldırmış durumda.', '4', '6', '11', '194', 'rejected', 'problem', '115', '36', '0', '', '2025-03-17 14:08:04.704849+00');
INSERT INTO "posts" ("id", "title", "content", "user_id", "category_id", "city_id", "district_id", "status", "type", "likes", "highlights", "comment_count", "is_anonymous", "created_at") VALUES ('6', 'Kaldırımlarda engelli erişimi sorunu', 'Merkez mahallede kaldırımların birçoğunda engelli rampaları ya yok ya da standartlara uygun değil. Tekerlekli sandalye kullananlar ve görme engelliler için bu durum büyük sorun yaratıyor. Ayrıca bazı kaldırımlarda ağaç kökleri kaldırımları kaldırmış durumda.', '4', '6', '11', '194', 'rejected', 'problem', '115', '36', '0', '', '2025-03-17 14:08:04.728979+00');
INSERT INTO "posts" ("id", "title", "content", "user_id", "category_id", "city_id", "district_id", "status", "type", "likes", "highlights", "comment_count", "is_anonymous", "created_at") VALUES ('7', 'Mahalle sakinlerine ücretsiz sağlık taraması', 'Bu hafta sonu, 09:00-17:00 saatleri arasında Kültür Merkezi\'nde ücretsiz sağlık taraması yapılacaktır. Tansiyon, şeker, kolesterol ölçümleri ve genel sağlık kontrolü için tüm mahalle sakinlerimiz davetlidir. Lütfen kimlik kartınızı getirmeyi unutmayın.', '4', '8', '58', '102', 'inProgress', 'announcement', '114', '47', '0', '', '2025-04-07 14:08:05.077671+00');
INSERT INTO "posts" ("id", "title", "content", "user_id", "category_id", "city_id", "district_id", "status", "type", "likes", "highlights", "comment_count", "is_anonymous", "created_at") VALUES ('8', 'Mahalle sakinlerine ücretsiz sağlık taraması', 'Bu hafta sonu, 09:00-17:00 saatleri arasında Kültür Merkezi\'nde ücretsiz sağlık taraması yapılacaktır. Tansiyon, şeker, kolesterol ölçümleri ve genel sağlık kontrolü için tüm mahalle sakinlerimiz davetlidir. Lütfen kimlik kartınızı getirmeyi unutmayın.', '4', '8', '58', '102', 'inProgress', 'announcement', '114', '47', '0', '', '2025-04-07 14:08:05.098443+00');
INSERT INTO "posts" ("id", "title", "content", "user_id", "category_id", "city_id", "district_id", "status", "type", "likes", "highlights", "comment_count", "is_anonymous", "created_at") VALUES ('9', 'Sokak hayvanları için mama ve su kapları', 'İlçemizin çeşitli noktalarına sokak hayvanları için mama ve su kapları yerleştirilmesini öneriyorum. Özellikle yaz aylarında su bulma konusunda zorluk yaşayan sokak hayvanları için bu önemli bir ihtiyaç. Belediyenin bu konuya duyarlı davranacağını umuyorum.', '1', '3', '25', '712', 'inProgress', 'suggestion', '62', '54', '0', '', '2025-04-08 14:08:05.420273+00');
INSERT INTO "posts" ("id", "title", "content", "user_id", "category_id", "city_id", "district_id", "status", "type", "likes", "highlights", "comment_count", "is_anonymous", "created_at") VALUES ('13', 'Spor salonu ücretlerindeki artış', 'Belediyeye ait spor salonunda ücretlere yapılan son zamlar çok yüksek. Özellikle öğrenciler ve emekliler bu zamlardan sonra spor salonunu kullanamaz hale geldi. Belediyenin bu konuyu tekrar değerlendirmesini ve özellikle öğrenci ve emekliler için indirimli tarifeler uygulamasını rica ediyorum.', '4', '1', '26', '10', 'inProgress', 'general', '27', '16', '0', '', '2025-03-15 14:08:06.177425+00');
INSERT INTO "posts" ("id", "title", "content", "user_id", "category_id", "city_id", "district_id", "status", "type", "likes", "highlights", "comment_count", "is_anonymous", "created_at") VALUES ('14', 'Spor salonu ücretlerindeki artış', 'Belediyeye ait spor salonunda ücretlere yapılan son zamlar çok yüksek. Özellikle öğrenciler ve emekliler bu zamlardan sonra spor salonunu kullanamaz hale geldi. Belediyenin bu konuyu tekrar değerlendirmesini ve özellikle öğrenci ve emekliler için indirimli tarifeler uygulamasını rica ediyorum.', '4', '1', '26', '10', 'inProgress', 'general', '27', '16', '0', '', '2025-03-15 14:08:06.197987+00');
INSERT INTO "posts" ("id", "title", "content", "user_id", "category_id", "city_id", "district_id", "status", "type", "likes", "highlights", "comment_count", "is_anonymous", "created_at") VALUES ('15', 'Yeni açılan kültür merkezi', 'Geçen hafta açılan kültür merkezi gerçekten çok güzel olmuş. Özellikle kütüphane bölümü çok ferah ve kullanışlı. Belediyemizi bu güzel hizmet için tebrik ediyorum. Umarım benzer projelere devam edilir ve kültürel etkinlikler artırılır.', '1', '9', '17', '415', 'inProgress', 'general', '233', '69', '0', '', '2025-03-21 14:08:06.517767+00');
INSERT INTO "posts" ("id", "title", "content", "user_id", "category_id", "city_id", "district_id", "status", "type", "likes", "highlights", "comment_count", "is_anonymous", "created_at") VALUES ('16', 'Yeni açılan kültür merkezi', 'Geçen hafta açılan kültür merkezi gerçekten çok güzel olmuş. Özellikle kütüphane bölümü çok ferah ve kullanışlı. Belediyemizi bu güzel hizmet için tebrik ediyorum. Umarım benzer projelere devam edilir ve kültürel etkinlikler artırılır.', '1', '9', '17', '415', 'inProgress', 'general', '233', '69', '0', '', '2025-03-21 14:08:06.538704+00');
INSERT INTO "posts" ("id", "title", "content", "user_id", "category_id", "city_id", "district_id", "status", "type", "likes", "highlights", "comment_count", "is_anonymous", "created_at") VALUES ('17', 'Sel baskını sonrası altyapı sorunu', 'Geçen haftaki yağışlar sonrası Yeni Mahalle\'de ciddi sel baskınları yaşandı. Birçok ev ve iş yerinin alt katları su altında kaldı. Bu durum altyapının yetersiz olduğunu gösteriyor. Belediyenin özellikle yağmur suyu kanallarını temizlemesi ve genişletmesi gerekiyor.', '4', '8', '33', '52', 'inProgress', 'problem', '82', '51', '0', '', '2025-03-29 14:08:06.887196+00');
INSERT INTO "posts" ("id", "title", "content", "user_id", "category_id", "city_id", "district_id", "status", "type", "likes", "highlights", "comment_count", "is_anonymous", "created_at") VALUES ('18', 'Sel baskını sonrası altyapı sorunu', 'Geçen haftaki yağışlar sonrası Yeni Mahalle\'de ciddi sel baskınları yaşandı. Birçok ev ve iş yerinin alt katları su altında kaldı. Bu durum altyapının yetersiz olduğunu gösteriyor. Belediyenin özellikle yağmur suyu kanallarını temizlemesi ve genişletmesi gerekiyor.', '4', '8', '33', '52', 'inProgress', 'problem', '82', '51', '0', '', '2025-03-29 14:08:06.907948+00');
INSERT INTO "posts" ("id", "title", "content", "user_id", "category_id", "city_id", "district_id", "status", "type", "likes", "highlights", "comment_count", "is_anonymous", "created_at") VALUES ('19', 'Sokak aydınlatmalarının yetersizliği', 'Bahçelievler bölgesindeki sokak lambaları çok seyrek ve ışıkları yetersiz. Bu durum özellikle kış aylarında akşam saatlerinde güvenlik sorunu yaratıyor. Aydınlatmaların artırılması ve mevcut lambaların daha güçlü LED lambalarla değiştirilmesi faydalı olacaktır.', '1', '7', '83', '905', 'rejected', 'suggestion', '137', '28', '0', '', '2025-04-01 14:08:07.267951+00');
INSERT INTO "posts" ("id", "title", "content", "user_id", "category_id", "city_id", "district_id", "status", "type", "likes", "highlights", "comment_count", "is_anonymous", "created_at") VALUES ('11', 'Trafik ışıklarının çalışmaması', 'Ana bulvardaki trafik ışıkları üç gündür çalışmıyor. Bu durum özellikle sabah ve akşam saatlerinde trafik karmaşasına yol açıyor. Kaza riski yüksek, acilen tamir edilmesi gerekiyor.

', '1', '6', '54', '126', 'inProgress', 'problem', '19', '25', '0', '', '2025-04-10 14:08:05.80793+00');
INSERT INTO "posts" ("id", "title", "content", "user_id", "category_id", "city_id", "district_id", "status", "type", "likes", "highlights", "comment_count", "is_anonymous", "created_at") VALUES ('10', 'Sokak hayvanları için mama ve su kapları', 'İlçemizin çeşitli noktalarına sokak hayvanları için mama ve su kapları yerleştirilmesini öneriyorum. Özellikle yaz aylarında su bulma konusunda zorluk yaşayan sokak hayvanları için bu önemli bir ihtiyaç. Belediyenin bu konuya duyarlı davranacağını umuyorum.', '1', '3', '25', '712', 'inProgress', 'suggestion', '62', '54', '0', '', '2025-04-08 14:08:05.441721+00');
INSERT INTO "posts" ("id", "title", "content", "user_id", "category_id", "city_id", "district_id", "status", "type", "likes", "highlights", "comment_count", "is_anonymous", "created_at") VALUES ('20', 'Sokak aydınlatmalarının yetersizliği', 'Bahçelievler bölgesindeki sokak lambaları çok seyrek ve ışıkları yetersiz. Bu durum özellikle kış aylarında akşam saatlerinde güvenlik sorunu yaratıyor. Aydınlatmaların artırılması ve mevcut lambaların daha güçlü LED lambalarla değiştirilmesi faydalı olacaktır.', '1', '7', '83', '905', 'rejected', 'suggestion', '137', '28', '0', '', '2025-04-01 14:08:07.291686+00');
INSERT INTO "posts" ("id", "title", "content", "user_id", "category_id", "city_id", "district_id", "status", "type", "likes", "highlights", "comment_count", "is_anonymous", "created_at") VALUES ('21', 'Park alanında çöp sorunu', 'Atatürk Parkı\'nda son zamanlarda çöp kutuları düzenli olarak boşaltılmıyor. Özellikle hafta sonları park çöplerle doluyor ve kötü koku oluşuyor. Bu sorunun en kısa zamanda çözülmesi gerekiyor. Çocukların oyun alanları da temiz değil.', '4', '3', '77', '450', 'inProgress', 'problem', '70', '24', '0', '', '2025-03-15 14:08:49.587521+00');
INSERT INTO "posts" ("id", "title", "content", "user_id", "category_id", "city_id", "district_id", "status", "type", "likes", "highlights", "comment_count", "is_anonymous", "created_at") VALUES ('22', 'Park alanında çöp sorunu', 'Atatürk Parkı\'nda son zamanlarda çöp kutuları düzenli olarak boşaltılmıyor. Özellikle hafta sonları park çöplerle doluyor ve kötü koku oluşuyor. Bu sorunun en kısa zamanda çözülmesi gerekiyor. Çocukların oyun alanları da temiz değil.', '4', '3', '77', '450', 'inProgress', 'problem', '70', '24', '0', '', '2025-03-15 14:08:49.609522+00');
INSERT INTO "posts" ("id", "title", "content", "user_id", "category_id", "city_id", "district_id", "status", "type", "likes", "highlights", "comment_count", "is_anonymous", "created_at") VALUES ('23', 'İlçemizde yeni bisiklet yolları yapılsın', 'Bisiklet kullanımını teşvik etmek ve daha sağlıklı bir toplum oluşturmak için ilçemize güvenli bisiklet yolları yapılmasını öneriyorum. Özellikle ana caddelerde ve sahil şeridinde bisiklet yolları yapılırsa hem trafik rahatlar hem de insanlar daha fazla spor yapar.', '4', '2', '41', '888', 'awaitingSolution', 'suggestion', '119', '5', '0', '', '2025-03-31 14:08:50.037312+00');
INSERT INTO "posts" ("id", "title", "content", "user_id", "category_id", "city_id", "district_id", "status", "type", "likes", "highlights", "comment_count", "is_anonymous", "created_at") VALUES ('24', 'İlçemizde yeni bisiklet yolları yapılsın', 'Bisiklet kullanımını teşvik etmek ve daha sağlıklı bir toplum oluşturmak için ilçemize güvenli bisiklet yolları yapılmasını öneriyorum. Özellikle ana caddelerde ve sahil şeridinde bisiklet yolları yapılırsa hem trafik rahatlar hem de insanlar daha fazla spor yapar.', '4', '2', '41', '888', 'awaitingSolution', 'suggestion', '119', '5', '0', '', '2025-03-31 14:08:50.061293+00');
INSERT INTO "posts" ("id", "title", "content", "user_id", "category_id", "city_id", "district_id", "status", "type", "likes", "highlights", "comment_count", "is_anonymous", "created_at") VALUES ('25', 'Kaldırımlarda engelli erişimi sorunu', 'Merkez mahallede kaldırımların birçoğunda engelli rampaları ya yok ya da standartlara uygun değil. Tekerlekli sandalye kullananlar ve görme engelliler için bu durum büyük sorun yaratıyor. Ayrıca bazı kaldırımlarda ağaç kökleri kaldırımları kaldırmış durumda.', '4', '4', '10', '736', 'inProgress', 'problem', '30', '14', '0', '', '2025-04-04 14:08:50.484186+00');
INSERT INTO "posts" ("id", "title", "content", "user_id", "category_id", "city_id", "district_id", "status", "type", "likes", "highlights", "comment_count", "is_anonymous", "created_at") VALUES ('26', 'Kaldırımlarda engelli erişimi sorunu', 'Merkez mahallede kaldırımların birçoğunda engelli rampaları ya yok ya da standartlara uygun değil. Tekerlekli sandalye kullananlar ve görme engelliler için bu durum büyük sorun yaratıyor. Ayrıca bazı kaldırımlarda ağaç kökleri kaldırımları kaldırmış durumda.', '4', '4', '10', '736', 'inProgress', 'problem', '30', '14', '0', '', '2025-04-04 14:08:50.506168+00');
INSERT INTO "posts" ("id", "title", "content", "user_id", "category_id", "city_id", "district_id", "status", "type", "likes", "highlights", "comment_count", "is_anonymous", "created_at") VALUES ('27', 'Mahalle sakinlerine ücretsiz sağlık taraması', 'Bu hafta sonu, 09:00-17:00 saatleri arasında Kültür Merkezi\'nde ücretsiz sağlık taraması yapılacaktır. Tansiyon, şeker, kolesterol ölçümleri ve genel sağlık kontrolü için tüm mahalle sakinlerimiz davetlidir. Lütfen kimlik kartınızı getirmeyi unutmayın.', '4', '7', '57', '25', 'solved', 'announcement', '38', '46', '0', '', '2025-03-14 14:08:50.927702+00');
INSERT INTO "posts" ("id", "title", "content", "user_id", "category_id", "city_id", "district_id", "status", "type", "likes", "highlights", "comment_count", "is_anonymous", "created_at") VALUES ('28', 'Mahalle sakinlerine ücretsiz sağlık taraması', 'Bu hafta sonu, 09:00-17:00 saatleri arasında Kültür Merkezi\'nde ücretsiz sağlık taraması yapılacaktır. Tansiyon, şeker, kolesterol ölçümleri ve genel sağlık kontrolü için tüm mahalle sakinlerimiz davetlidir. Lütfen kimlik kartınızı getirmeyi unutmayın.', '4', '7', '57', '25', 'solved', 'announcement', '38', '46', '0', '', '2025-03-14 14:08:50.94976+00');
INSERT INTO "posts" ("id", "title", "content", "user_id", "category_id", "city_id", "district_id", "status", "type", "likes", "highlights", "comment_count", "is_anonymous", "created_at") VALUES ('29', 'Sokak hayvanları için mama ve su kapları', 'İlçemizin çeşitli noktalarına sokak hayvanları için mama ve su kapları yerleştirilmesini öneriyorum. Özellikle yaz aylarında su bulma konusunda zorluk yaşayan sokak hayvanları için bu önemli bir ihtiyaç. Belediyenin bu konuya duyarlı davranacağını umuyorum.', '4', '3', '3', '225', 'awaitingSolution', 'suggestion', '85', '57', '0', '', '2025-04-03 14:08:51.278189+00');
INSERT INTO "posts" ("id", "title", "content", "user_id", "category_id", "city_id", "district_id", "status", "type", "likes", "highlights", "comment_count", "is_anonymous", "created_at") VALUES ('30', 'Sokak hayvanları için mama ve su kapları', 'İlçemizin çeşitli noktalarına sokak hayvanları için mama ve su kapları yerleştirilmesini öneriyorum. Özellikle yaz aylarında su bulma konusunda zorluk yaşayan sokak hayvanları için bu önemli bir ihtiyaç. Belediyenin bu konuya duyarlı davranacağını umuyorum.', '4', '3', '3', '225', 'awaitingSolution', 'suggestion', '85', '57', '0', '', '2025-04-03 14:08:51.302173+00');
INSERT INTO "posts" ("id", "title", "content", "user_id", "category_id", "city_id", "district_id", "status", "type", "likes", "highlights", "comment_count", "is_anonymous", "created_at") VALUES ('31', 'Trafik ışıklarının çalışmaması', 'Ana bulvardaki trafik ışıkları üç gündür çalışmıyor. Bu durum özellikle sabah ve akşam saatlerinde trafik karmaşasına yol açıyor. Kaza riski yüksek, acilen tamir edilmesi gerekiyor.', '1', '4', '41', '887', 'inProgress', 'problem', '32', '15', '0', '', '2025-03-22 14:08:51.73624+00');
INSERT INTO "posts" ("id", "title", "content", "user_id", "category_id", "city_id", "district_id", "status", "type", "likes", "highlights", "comment_count", "is_anonymous", "created_at") VALUES ('32', 'Trafik ışıklarının çalışmaması', 'Ana bulvardaki trafik ışıkları üç gündür çalışmıyor. Bu durum özellikle sabah ve akşam saatlerinde trafik karmaşasına yol açıyor. Kaza riski yüksek, acilen tamir edilmesi gerekiyor.', '1', '4', '41', '887', 'inProgress', 'problem', '32', '15', '0', '', '2025-03-22 14:08:51.757249+00');
INSERT INTO "posts" ("id", "title", "content", "user_id", "category_id", "city_id", "district_id", "status", "type", "likes", "highlights", "comment_count", "is_anonymous", "created_at") VALUES ('33', 'Spor salonu ücretlerindeki artış', 'Belediyeye ait spor salonunda ücretlere yapılan son zamlar çok yüksek. Özellikle öğrenciler ve emekliler bu zamlardan sonra spor salonunu kullanamaz hale geldi. Belediyenin bu konuyu tekrar değerlendirmesini ve özellikle öğrenci ve emekliler için indirimli tarifeler uygulamasını rica ediyorum.', '4', '7', '18', '688', 'solved', 'general', '107', '10', '0', '', '2025-03-14 14:08:52.171528+00');
INSERT INTO "posts" ("id", "title", "content", "user_id", "category_id", "city_id", "district_id", "status", "type", "likes", "highlights", "comment_count", "is_anonymous", "created_at") VALUES ('34', 'Spor salonu ücretlerindeki artış', 'Belediyeye ait spor salonunda ücretlere yapılan son zamlar çok yüksek. Özellikle öğrenciler ve emekliler bu zamlardan sonra spor salonunu kullanamaz hale geldi. Belediyenin bu konuyu tekrar değerlendirmesini ve özellikle öğrenci ve emekliler için indirimli tarifeler uygulamasını rica ediyorum.', '4', '7', '18', '688', 'solved', 'general', '107', '10', '0', '', '2025-03-14 14:08:52.192371+00');
INSERT INTO "posts" ("id", "title", "content", "user_id", "category_id", "city_id", "district_id", "status", "type", "likes", "highlights", "comment_count", "is_anonymous", "created_at") VALUES ('35', 'Yeni açılan kültür merkezi', 'Geçen hafta açılan kültür merkezi gerçekten çok güzel olmuş. Özellikle kütüphane bölümü çok ferah ve kullanışlı. Belediyemizi bu güzel hizmet için tebrik ediyorum. Umarım benzer projelere devam edilir ve kültürel etkinlikler artırılır.', '1', '5', '8', '528', 'solved', 'general', '133', '72', '0', '', '2025-04-04 14:08:52.500697+00');
INSERT INTO "posts" ("id", "title", "content", "user_id", "category_id", "city_id", "district_id", "status", "type", "likes", "highlights", "comment_count", "is_anonymous", "created_at") VALUES ('36', 'Yeni açılan kültür merkezi', 'Geçen hafta açılan kültür merkezi gerçekten çok güzel olmuş. Özellikle kütüphane bölümü çok ferah ve kullanışlı. Belediyemizi bu güzel hizmet için tebrik ediyorum. Umarım benzer projelere devam edilir ve kültürel etkinlikler artırılır.', '1', '5', '8', '528', 'solved', 'general', '133', '72', '0', '', '2025-04-04 14:08:52.522468+00');
INSERT INTO "posts" ("id", "title", "content", "user_id", "category_id", "city_id", "district_id", "status", "type", "likes", "highlights", "comment_count", "is_anonymous", "created_at") VALUES ('37', 'Sel baskını sonrası altyapı sorunu', 'Geçen haftaki yağışlar sonrası Yeni Mahalle\'de ciddi sel baskınları yaşandı. Birçok ev ve iş yerinin alt katları su altında kaldı. Bu durum altyapının yetersiz olduğunu gösteriyor. Belediyenin özellikle yağmur suyu kanallarını temizlemesi ve genişletmesi gerekiyor.', '1', '9', '45', '258', 'rejected', 'problem', '181', '53', '0', '', '2025-03-23 14:08:52.963402+00');
INSERT INTO "posts" ("id", "title", "content", "user_id", "category_id", "city_id", "district_id", "status", "type", "likes", "highlights", "comment_count", "is_anonymous", "created_at") VALUES ('38', 'Sel baskını sonrası altyapı sorunu', 'Geçen haftaki yağışlar sonrası Yeni Mahalle\'de ciddi sel baskınları yaşandı. Birçok ev ve iş yerinin alt katları su altında kaldı. Bu durum altyapının yetersiz olduğunu gösteriyor. Belediyenin özellikle yağmur suyu kanallarını temizlemesi ve genişletmesi gerekiyor.', '1', '9', '45', '258', 'rejected', 'problem', '181', '53', '0', '', '2025-03-23 14:08:52.984757+00');
INSERT INTO "posts" ("id", "title", "content", "user_id", "category_id", "city_id", "district_id", "status", "type", "likes", "highlights", "comment_count", "is_anonymous", "created_at") VALUES ('39', 'Sokak aydınlatmalarının yetersizliği', 'Bahçelievler bölgesindeki sokak lambaları çok seyrek ve ışıkları yetersiz. Bu durum özellikle kış aylarında akşam saatlerinde güvenlik sorunu yaratıyor. Aydınlatmaların artırılması ve mevcut lambaların daha güçlü LED lambalarla değiştirilmesi faydalı olacaktır.', '1', '3', '23', '878', 'solved', 'suggestion', '182', '17', '0', '', '2025-03-27 14:08:53.440932+00');
INSERT INTO "posts" ("id", "title", "content", "user_id", "category_id", "city_id", "district_id", "status", "type", "likes", "highlights", "comment_count", "is_anonymous", "created_at") VALUES ('40', 'Sokak aydınlatmalarının yetersizliği', 'Bahçelievler bölgesindeki sokak lambaları çok seyrek ve ışıkları yetersiz. Bu durum özellikle kış aylarında akşam saatlerinde güvenlik sorunu yaratıyor. Aydınlatmaların artırılması ve mevcut lambaların daha güçlü LED lambalarla değiştirilmesi faydalı olacaktır.', '1', '3', '23', '878', 'solved', 'suggestion', '182', '17', '0', '', '2025-03-27 14:08:53.467063+00');
INSERT INTO "posts" ("id", "title", "content", "user_id", "category_id", "city_id", "district_id", "status", "type", "likes", "highlights", "comment_count", "is_anonymous", "created_at") VALUES ('12', 'Trafik ışıklarının çalışmaması Sorunu zafer', 'Zafer Ana bulvardaki trafik ışıkları üç gündür çalışmıyor. Bu durum özellikle sabah ve akşam saatlerinde trafik karmaşasına yol açıyor. Kaza riski yüksek, acilen tamir edilmesi gerekiyor. ', '1', '6', '54', '126', 'inProgress', 'problem', '19', '25', '0', '', '2025-04-10 14:08:05.829537+00');
INSERT INTO "posts" ("id", "title", "content", "user_id", "category_id", "city_id", "district_id", "status", "type", "likes", "highlights", "comment_count", "is_anonymous", "created_at") VALUES ('80', 'Otobüs hatlarının yetersizliği', 'Parklarımızda güvenlik kameraları ve daha fazla aydınlatma olması gerekiyor. Özellikle akşam saatlerinde parklar güvensiz hale geliyor.', '136', '4', '34', '302', 'solved', 'general', '0', '0', '1', '', '2025-04-11 20:28:28.663529+00');
INSERT INTO "posts" ("id", "title", "content", "user_id", "category_id", "city_id", "district_id", "status", "type", "likes", "highlights", "comment_count", "is_anonymous", "created_at") VALUES ('79', 'Parkların temizliği ve güvenliği', 'Sokağımızda günlerdir çöpler toplanmıyor ve kötü koku oluşmaya başladı. Belediyenin bu sorunu acilen çözmesini talep ediyoruz.', '138', '6', '6', '348', 'solved', 'problem', '2', '0', '3', '', '2025-04-11 20:28:28.663529+00');
INSERT INTO "posts" ("id", "title", "content", "user_id", "category_id", "city_id", "district_id", "status", "type", "likes", "highlights", "comment_count", "is_anonymous", "created_at") VALUES ('85', 'Otobüs hatlarının yetersizliği', 'Bazı sokaklar yeterince aydınlatılmıyor ve bu güvenlik sorunları yaratıyor. Aydınlatma sisteminin güçlendirilmesini istiyoruz.', '142', '8', '6', '352', 'inProgress', 'general', '1', '0', '3', '', '2025-04-11 20:28:28.663529+00');
INSERT INTO "posts" ("id", "title", "content", "user_id", "category_id", "city_id", "district_id", "status", "type", "likes", "highlights", "comment_count", "is_anonymous", "created_at") VALUES ('83', 'Park ve bahçelerin durumu kötü', 'Sabah ve akşam saatlerinde toplu taşıma yetersiz kalıyor. Daha sık sefer konulmasını talep ediyoruz.', '144', '9', '34', '309', 'inProgress', 'problem', '4', '0', '4', '', '2025-04-11 20:28:28.663529+00');
INSERT INTO "posts" ("id", "title", "content", "user_id", "category_id", "city_id", "district_id", "status", "type", "likes", "highlights", "comment_count", "is_anonymous", "created_at") VALUES ('81', 'Çevre düzenlemesi yapılması gereken bölgeler', 'Merkeze giden otobüs hatları çok az ve seyrek. Yeni güzergahlar eklenmesini talep ediyoruz.', '138', '5', '2', '343', 'solved', 'problem', '3', '0', '0', '', '2025-04-11 20:28:28.663529+00');
INSERT INTO "posts" ("id", "title", "content", "user_id", "category_id", "city_id", "district_id", "status", "type", "likes", "highlights", "comment_count", "is_anonymous", "created_at") VALUES ('88', 'Şehir aydınlatması sorunu', 'Bazı sokaklar yeterince aydınlatılmıyor ve bu güvenlik sorunları yaratıyor. Aydınlatma sisteminin güçlendirilmesini istiyoruz.', '136', '7', '2', '344', 'rejected', 'announcement', '4', '0', '3', '', '2025-04-11 20:28:28.663529+00');
INSERT INTO "posts" ("id", "title", "content", "user_id", "category_id", "city_id", "district_id", "status", "type", "likes", "highlights", "comment_count", "is_anonymous", "created_at") VALUES ('87', 'Yol çalışmaları ne zaman bitecek?', 'Sürekli yaşanan su kesintileri günlük hayatımızı olumsuz etkiliyor. Önceden bilgilendirme yapılmasını istiyoruz.', '142', '5', '34', '302', 'solved', 'problem', '2', '0', '0', '', '2025-04-11 20:28:28.663529+00');
INSERT INTO "posts" ("id", "title", "content", "user_id", "category_id", "city_id", "district_id", "status", "type", "likes", "highlights", "comment_count", "is_anonymous", "created_at") VALUES ('82', 'Otobüs hatlarının yetersizliği', 'Sokağımızda günlerdir çöpler toplanmıyor ve kötü koku oluşmaya başladı. Belediyenin bu sorunu acilen çözmesini talep ediyoruz.', '143', '5', '2', '338', 'rejected', 'general', '5', '0', '3', '', '2025-04-11 20:28:28.663529+00');
INSERT INTO "posts" ("id", "title", "content", "user_id", "category_id", "city_id", "district_id", "status", "type", "likes", "highlights", "comment_count", "is_anonymous", "created_at") VALUES ('84', 'Çevre düzenlemesi yapılması gereken bölgeler', 'Okul çıkış saatlerinde trafik çok yoğun oluyor ve bu durum tehlikeli durumlar yaratıyor. Trafik düzenlemesi yapılması gerekiyor.', '137', '9', '34', '304', 'solved', 'announcement', '3', '0', '1', '', '2025-04-11 20:28:28.663529+00');
INSERT INTO "posts" ("id", "title", "content", "user_id", "category_id", "city_id", "district_id", "status", "type", "likes", "highlights", "comment_count", "is_anonymous", "created_at") VALUES ('86', 'Otobüs hatlarının yetersizliği', 'Bazı sokaklar yeterince aydınlatılmıyor ve bu güvenlik sorunları yaratıyor. Aydınlatma sisteminin güçlendirilmesini istiyoruz.', '137', '7', '6', '353', 'awaitingSolution', 'suggestion', '2', '0', '4', '', '2025-04-11 20:28:28.663529+00');

-- Tablo: media için veri
INSERT INTO "media" ("id", "post_id", "url", "type", "created_at") VALUES ('1', '22', 'https://images.unsplash.com/photo-1605600659873-d808a13e4d2f?q=80&w=1000', 'image', '2025-04-11 14:08:49.67109+00');
INSERT INTO "media" ("id", "post_id", "url", "type", "created_at") VALUES ('2', '22', 'https://images.unsplash.com/photo-1605600659873-d808a13e4d2f?q=80&w=1000', 'image', '2025-04-11 14:08:49.701939+00');
INSERT INTO "media" ("id", "post_id", "url", "type", "created_at") VALUES ('3', '24', 'https://images.unsplash.com/photo-1528262502195-26dfb3c29f8f?q=80&w=1000', 'image', '2025-04-11 14:08:50.132075+00');
INSERT INTO "media" ("id", "post_id", "url", "type", "created_at") VALUES ('4', '24', 'https://images.unsplash.com/photo-1528262502195-26dfb3c29f8f?q=80&w=1000', 'image', '2025-04-11 14:08:50.152967+00');
INSERT INTO "media" ("id", "post_id", "url", "type", "created_at") VALUES ('5', '26', 'https://images.unsplash.com/photo-1628515334134-870832b6e76a?q=80&w=1000', 'image', '2025-04-11 14:08:50.574559+00');
INSERT INTO "media" ("id", "post_id", "url", "type", "created_at") VALUES ('6', '26', 'https://images.unsplash.com/photo-1628515334134-870832b6e76a?q=80&w=1000', 'image', '2025-04-11 14:08:50.595358+00');
INSERT INTO "media" ("id", "post_id", "url", "type", "created_at") VALUES ('7', '30', 'https://images.unsplash.com/photo-1549042261-24c2ddb5df68?q=80&w=1000', 'image', '2025-04-11 14:08:51.388693+00');
INSERT INTO "media" ("id", "post_id", "url", "type", "created_at") VALUES ('8', '30', 'https://images.unsplash.com/photo-1549042261-24c2ddb5df68?q=80&w=1000', 'image', '2025-04-11 14:08:51.410246+00');
INSERT INTO "media" ("id", "post_id", "url", "type", "created_at") VALUES ('9', '32', 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 'video', '2025-04-11 14:08:51.823019+00');
INSERT INTO "media" ("id", "post_id", "url", "type", "created_at") VALUES ('10', '32', 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 'video', '2025-04-11 14:08:51.844078+00');
INSERT INTO "media" ("id", "post_id", "url", "type", "created_at") VALUES ('12', '36', 'https://images.unsplash.com/photo-1526714719019-b3032b5b5aac?q=80&w=1000', 'image', '2025-04-11 14:08:52.626214+00');
INSERT INTO "media" ("id", "post_id", "url", "type", "created_at") VALUES ('13', '38', 'https://www.youtube.com/watch?v=a3ICNMQW7Ok', 'video', '2025-04-11 14:08:53.045959+00');
INSERT INTO "media" ("id", "post_id", "url", "type", "created_at") VALUES ('14', '38', 'https://www.youtube.com/watch?v=a3ICNMQW7Ok', 'video', '2025-04-11 14:08:53.066902+00');
INSERT INTO "media" ("id", "post_id", "url", "type", "created_at") VALUES ('15', '10', 'https://picsum.photos/800/600', 'image', '2025-04-11 14:44:48.276708+00');
INSERT INTO "media" ("id", "post_id", "url", "type", "created_at") VALUES ('17', '7', 'https://picsum.photos/800/500', 'image', '2025-04-11 14:44:58.653445+00');
INSERT INTO "media" ("id", "post_id", "url", "type", "created_at") VALUES ('18', '23', 'https://www.youtube.com/embed/C0DPdy98e4c', 'video', '2025-04-11 14:45:02.367141+00');
INSERT INTO "media" ("id", "post_id", "url", "type", "created_at") VALUES ('19', '5', 'https://picsum.photos/900/600', 'image', '2025-04-11 14:45:06.675292+00');
INSERT INTO "media" ("id", "post_id", "url", "type", "created_at") VALUES ('22', '11', 'uploads/1744383142_technology-image-globe_114588-838.jpg', 'image', '2025-04-11 14:52:22.89354+00');
INSERT INTO "media" ("id", "post_id", "url", "type", "created_at") VALUES ('24', '12', 'uploads/1744400518_1000146158.jpg', 'image', '2025-04-11 19:41:58.189622+00');

-- Tablo: comments için veri
INSERT INTO "comments" ("id", "post_id", "user_id", "content", "like_count", "is_hidden", "created_at", "parent_id", "is_anonymous") VALUES ('21', '83', '135', 'Farklı kanallardan da şikayet edelim, sosyal medyadan da duyuralım.', '0', '', '2025-04-11 20:28:28.663529+00', NULL, '');
INSERT INTO "comments" ("id", "post_id", "user_id", "content", "like_count", "is_hidden", "created_at", "parent_id", "is_anonymous") VALUES ('22', '86', '141', 'Geçen ay da aynı sorun yaşanmıştı, kısa sürede düzeltilmişti. Umarım yine çözülür.', '0', '', '2025-04-11 20:28:28.663529+00', NULL, '');
INSERT INTO "comments" ("id", "post_id", "user_id", "content", "like_count", "is_hidden", "created_at", "parent_id", "is_anonymous") VALUES ('23', '80', '142', 'Geçen ay da aynı sorun yaşanmıştı, kısa sürede düzeltilmişti. Umarım yine çözülür.', '0', '', '2025-04-11 20:28:28.663529+00', NULL, '');
INSERT INTO "comments" ("id", "post_id", "user_id", "content", "like_count", "is_hidden", "created_at", "parent_id", "is_anonymous") VALUES ('24', '83', '137', 'Bence bu sorun bir an önce çözülmeli. Çok uzun süredir devam ediyor.', '0', '', '2025-04-11 20:28:28.663529+00', NULL, '');
INSERT INTO "comments" ("id", "post_id", "user_id", "content", "like_count", "is_hidden", "created_at", "parent_id", "is_anonymous") VALUES ('25', '83', '141', 'Geçen ay da aynı sorun yaşanmıştı, kısa sürede düzeltilmişti. Umarım yine çözülür.', '0', '', '2025-04-11 20:28:28.663529+00', NULL, '');
INSERT INTO "comments" ("id", "post_id", "user_id", "content", "like_count", "is_hidden", "created_at", "parent_id", "is_anonymous") VALUES ('26', '86', '136', 'Geçen ay da aynı sorun yaşanmıştı, kısa sürede düzeltilmişti. Umarım yine çözülür.', '0', '', '2025-04-11 20:28:28.663529+00', NULL, '');
INSERT INTO "comments" ("id", "post_id", "user_id", "content", "like_count", "is_hidden", "created_at", "parent_id", "is_anonymous") VALUES ('27', '88', '143', 'Belediyenin çağrı merkezini denediniz mi? Bazen hızlı yanıt veriyorlar.', '0', '', '2025-04-11 20:28:28.663529+00', NULL, '');
INSERT INTO "comments" ("id", "post_id", "user_id", "content", "like_count", "is_hidden", "created_at", "parent_id", "is_anonymous") VALUES ('28', '86', '142', 'Bu şikayeti destekliyorum, aynı sorundan biz de muzdaripiz.', '0', '', '2025-04-11 20:28:28.663529+00', NULL, '');
INSERT INTO "comments" ("id", "post_id", "user_id", "content", "like_count", "is_hidden", "created_at", "parent_id", "is_anonymous") VALUES ('29', '82', '142', 'Bu şikayeti destekliyorum, aynı sorundan biz de muzdaripiz.', '0', '', '2025-04-11 20:28:28.663529+00', NULL, '');
INSERT INTO "comments" ("id", "post_id", "user_id", "content", "like_count", "is_hidden", "created_at", "parent_id", "is_anonymous") VALUES ('30', '86', '139', 'Mahalle muhtarına da bildirdiniz mi? Bazen araya girerek yardımcı olabiliyorlar.', '0', '', '2025-04-11 20:28:28.663529+00', NULL, '');
INSERT INTO "comments" ("id", "post_id", "user_id", "content", "like_count", "is_hidden", "created_at", "parent_id", "is_anonymous") VALUES ('31', '85', '139', 'Mahalle muhtarına da bildirdiniz mi? Bazen araya girerek yardımcı olabiliyorlar.', '0', '', '2025-04-11 20:28:28.663529+00', NULL, '');
INSERT INTO "comments" ("id", "post_id", "user_id", "content", "like_count", "is_hidden", "created_at", "parent_id", "is_anonymous") VALUES ('32', '83', '143', 'Bu konuda yapılan bir çalışma var mı? Bilgi sahibi olan var mı?', '0', '', '2025-04-11 20:28:28.663529+00', NULL, '');
INSERT INTO "comments" ("id", "post_id", "user_id", "content", "like_count", "is_hidden", "created_at", "parent_id", "is_anonymous") VALUES ('33', '88', '141', 'Bu sorunu ben de yaşıyorum. Belediye bu konuyla ilgilenmeli.', '0', '', '2025-04-11 20:28:28.663529+00', NULL, '');
INSERT INTO "comments" ("id", "post_id", "user_id", "content", "like_count", "is_hidden", "created_at", "parent_id", "is_anonymous") VALUES ('34', '79', '135', 'Mahalle muhtarına da bildirdiniz mi? Bazen araya girerek yardımcı olabiliyorlar.', '0', '', '2025-04-11 20:28:28.663529+00', NULL, '');
INSERT INTO "comments" ("id", "post_id", "user_id", "content", "like_count", "is_hidden", "created_at", "parent_id", "is_anonymous") VALUES ('35', '85', '136', 'Bence bu sorun bir an önce çözülmeli. Çok uzun süredir devam ediyor.', '0', '', '2025-04-11 20:28:28.663529+00', NULL, '');
INSERT INTO "comments" ("id", "post_id", "user_id", "content", "like_count", "is_hidden", "created_at", "parent_id", "is_anonymous") VALUES ('36', '85', '137', 'Sorununuzu anlıyorum, bence bir imza kampanyası başlatalım.', '0', '', '2025-04-11 20:28:28.663529+00', NULL, '');
INSERT INTO "comments" ("id", "post_id", "user_id", "content", "like_count", "is_hidden", "created_at", "parent_id", "is_anonymous") VALUES ('37', '82', '144', 'Bence bu sorun bir an önce çözülmeli. Çok uzun süredir devam ediyor.', '0', '', '2025-04-11 20:28:28.663529+00', NULL, '');
INSERT INTO "comments" ("id", "post_id", "user_id", "content", "like_count", "is_hidden", "created_at", "parent_id", "is_anonymous") VALUES ('38', '82', '139', 'Bu konuda bir gelişme oldu mu? Bizim bölgede de benzer sıkıntılar var.', '0', '', '2025-04-11 20:28:28.663529+00', NULL, '');
INSERT INTO "comments" ("id", "post_id", "user_id", "content", "like_count", "is_hidden", "created_at", "parent_id", "is_anonymous") VALUES ('39', '88', '136', 'Bu konuda bir gelişme oldu mu? Bizim bölgede de benzer sıkıntılar var.', '0', '', '2025-04-11 20:28:28.663529+00', NULL, '');
INSERT INTO "comments" ("id", "post_id", "user_id", "content", "like_count", "is_hidden", "created_at", "parent_id", "is_anonymous") VALUES ('40', '84', '143', 'Bu sorun gerçekten can sıkıcı, yetkililerin dikkate almasını umuyorum.', '0', '', '2025-04-11 20:28:28.663529+00', NULL, '');
INSERT INTO "comments" ("id", "post_id", "user_id", "content", "like_count", "is_hidden", "created_at", "parent_id", "is_anonymous") VALUES ('41', '79', '1', 'Merhaba', '0', '', '2025-04-13 08:11:52.462753+00', '34', '');
INSERT INTO "comments" ("id", "post_id", "user_id", "content", "like_count", "is_hidden", "created_at", "parent_id", "is_anonymous") VALUES ('42', '79', '1', 'anonim', '0', '', '2025-04-13 08:12:06.224401+00', '34', '1');

-- Tablo: user_likes için veri
INSERT INTO "user_likes" ("id", "user_id", "post_id", "comment_id", "created_at") VALUES ('52', '142', '81', NULL, '2025-04-11 20:28:28.663529+00');
INSERT INTO "user_likes" ("id", "user_id", "post_id", "comment_id", "created_at") VALUES ('53', '135', '83', NULL, '2025-04-11 20:28:28.663529+00');
INSERT INTO "user_likes" ("id", "user_id", "post_id", "comment_id", "created_at") VALUES ('54', '141', '83', NULL, '2025-04-11 20:28:28.663529+00');
INSERT INTO "user_likes" ("id", "user_id", "post_id", "comment_id", "created_at") VALUES ('55', '139', '82', NULL, '2025-04-11 20:28:28.663529+00');
INSERT INTO "user_likes" ("id", "user_id", "post_id", "comment_id", "created_at") VALUES ('57', '138', '82', NULL, '2025-04-11 20:28:28.663529+00');
INSERT INTO "user_likes" ("id", "user_id", "post_id", "comment_id", "created_at") VALUES ('58', '135', '86', NULL, '2025-04-11 20:28:28.663529+00');
INSERT INTO "user_likes" ("id", "user_id", "post_id", "comment_id", "created_at") VALUES ('59', '136', '88', NULL, '2025-04-11 20:28:28.663529+00');
INSERT INTO "user_likes" ("id", "user_id", "post_id", "comment_id", "created_at") VALUES ('60', '144', '84', NULL, '2025-04-11 20:28:28.663529+00');
INSERT INTO "user_likes" ("id", "user_id", "post_id", "comment_id", "created_at") VALUES ('61', '137', '84', NULL, '2025-04-11 20:28:28.663529+00');
INSERT INTO "user_likes" ("id", "user_id", "post_id", "comment_id", "created_at") VALUES ('62', '141', '87', NULL, '2025-04-11 20:28:28.663529+00');
INSERT INTO "user_likes" ("id", "user_id", "post_id", "comment_id", "created_at") VALUES ('63', '135', '88', NULL, '2025-04-11 20:28:28.663529+00');
INSERT INTO "user_likes" ("id", "user_id", "post_id", "comment_id", "created_at") VALUES ('64', '140', '88', NULL, '2025-04-11 20:28:28.663529+00');
INSERT INTO "user_likes" ("id", "user_id", "post_id", "comment_id", "created_at") VALUES ('65', '140', '81', NULL, '2025-04-11 20:28:28.663529+00');
INSERT INTO "user_likes" ("id", "user_id", "post_id", "comment_id", "created_at") VALUES ('66', '135', '79', NULL, '2025-04-11 20:28:28.663529+00');
INSERT INTO "user_likes" ("id", "user_id", "post_id", "comment_id", "created_at") VALUES ('67', '136', '82', NULL, '2025-04-11 20:28:28.663529+00');
INSERT INTO "user_likes" ("id", "user_id", "post_id", "comment_id", "created_at") VALUES ('68', '142', '83', NULL, '2025-04-11 20:28:28.663529+00');
INSERT INTO "user_likes" ("id", "user_id", "post_id", "comment_id", "created_at") VALUES ('69', '144', '82', NULL, '2025-04-11 20:28:28.663529+00');
INSERT INTO "user_likes" ("id", "user_id", "post_id", "comment_id", "created_at") VALUES ('70', '142', '85', NULL, '2025-04-11 20:28:28.663529+00');
INSERT INTO "user_likes" ("id", "user_id", "post_id", "comment_id", "created_at") VALUES ('71', '140', '83', NULL, '2025-04-11 20:28:28.663529+00');
INSERT INTO "user_likes" ("id", "user_id", "post_id", "comment_id", "created_at") VALUES ('73', '138', '79', NULL, '2025-04-11 20:28:28.663529+00');
INSERT INTO "user_likes" ("id", "user_id", "post_id", "comment_id", "created_at") VALUES ('74', '144', '81', NULL, '2025-04-11 20:28:28.663529+00');
INSERT INTO "user_likes" ("id", "user_id", "post_id", "comment_id", "created_at") VALUES ('75', '137', '88', NULL, '2025-04-11 20:28:28.663529+00');
INSERT INTO "user_likes" ("id", "user_id", "post_id", "comment_id", "created_at") VALUES ('77', '135', '87', NULL, '2025-04-11 20:28:28.663529+00');
INSERT INTO "user_likes" ("id", "user_id", "post_id", "comment_id", "created_at") VALUES ('78', '135', '82', NULL, '2025-04-11 20:28:28.663529+00');
INSERT INTO "user_likes" ("id", "user_id", "post_id", "comment_id", "created_at") VALUES ('79', '139', '84', NULL, '2025-04-11 20:28:28.663529+00');
INSERT INTO "user_likes" ("id", "user_id", "post_id", "comment_id", "created_at") VALUES ('80', '136', '86', NULL, '2025-04-11 20:28:28.663529+00');
INSERT INTO "user_likes" ("id", "user_id", "post_id", "comment_id", "created_at") VALUES ('81', '137', NULL, '40', '2025-04-11 20:28:28.663529+00');
INSERT INTO "user_likes" ("id", "user_id", "post_id", "comment_id", "created_at") VALUES ('82', '143', NULL, '30', '2025-04-11 20:28:28.663529+00');
INSERT INTO "user_likes" ("id", "user_id", "post_id", "comment_id", "created_at") VALUES ('83', '138', NULL, '36', '2025-04-11 20:28:28.663529+00');
INSERT INTO "user_likes" ("id", "user_id", "post_id", "comment_id", "created_at") VALUES ('84', '135', NULL, '39', '2025-04-11 20:28:28.663529+00');
INSERT INTO "user_likes" ("id", "user_id", "post_id", "comment_id", "created_at") VALUES ('85', '140', NULL, '40', '2025-04-11 20:28:28.663529+00');
INSERT INTO "user_likes" ("id", "user_id", "post_id", "comment_id", "created_at") VALUES ('86', '135', NULL, '25', '2025-04-11 20:28:28.663529+00');
INSERT INTO "user_likes" ("id", "user_id", "post_id", "comment_id", "created_at") VALUES ('87', '141', NULL, '22', '2025-04-11 20:28:28.663529+00');
INSERT INTO "user_likes" ("id", "user_id", "post_id", "comment_id", "created_at") VALUES ('88', '139', NULL, '27', '2025-04-11 20:28:28.663529+00');
INSERT INTO "user_likes" ("id", "user_id", "post_id", "comment_id", "created_at") VALUES ('89', '138', NULL, '32', '2025-04-11 20:28:28.663529+00');
INSERT INTO "user_likes" ("id", "user_id", "post_id", "comment_id", "created_at") VALUES ('90', '141', NULL, '34', '2025-04-11 20:28:28.663529+00');
INSERT INTO "user_likes" ("id", "user_id", "post_id", "comment_id", "created_at") VALUES ('91', '140', NULL, '29', '2025-04-11 20:28:28.663529+00');
INSERT INTO "user_likes" ("id", "user_id", "post_id", "comment_id", "created_at") VALUES ('92', '138', NULL, '37', '2025-04-11 20:28:28.663529+00');
INSERT INTO "user_likes" ("id", "user_id", "post_id", "comment_id", "created_at") VALUES ('93', '144', NULL, '27', '2025-04-11 20:28:28.663529+00');
INSERT INTO "user_likes" ("id", "user_id", "post_id", "comment_id", "created_at") VALUES ('94', '140', NULL, '26', '2025-04-11 20:28:28.663529+00');
INSERT INTO "user_likes" ("id", "user_id", "post_id", "comment_id", "created_at") VALUES ('95', '143', NULL, '35', '2025-04-11 20:28:28.663529+00');
INSERT INTO "user_likes" ("id", "user_id", "post_id", "comment_id", "created_at") VALUES ('96', '138', NULL, '33', '2025-04-11 20:28:28.663529+00');
INSERT INTO "user_likes" ("id", "user_id", "post_id", "comment_id", "created_at") VALUES ('97', '140', NULL, '37', '2025-04-11 20:28:28.663529+00');
INSERT INTO "user_likes" ("id", "user_id", "post_id", "comment_id", "created_at") VALUES ('98', '136', NULL, '39', '2025-04-11 20:28:28.663529+00');
INSERT INTO "user_likes" ("id", "user_id", "post_id", "comment_id", "created_at") VALUES ('99', '142', NULL, '24', '2025-04-11 20:28:28.663529+00');
INSERT INTO "user_likes" ("id", "user_id", "post_id", "comment_id", "created_at") VALUES ('100', '141', NULL, '27', '2025-04-11 20:28:28.663529+00');


-- 3. ADIM: İLİŞKİLERİ (FOREIGN KEY KISITLAMALARI) EKLE
-- -----------------------------

ALTER TABLE "city_events" ADD CONSTRAINT "city_events_city_id_fkey" FOREIGN KEY ("city_id") REFERENCES "cities" ("id") ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE "city_projects" ADD CONSTRAINT "city_projects_city_id_fkey" FOREIGN KEY ("city_id") REFERENCES "cities" ("id") ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE "city_services" ADD CONSTRAINT "city_services_city_id_fkey" FOREIGN KEY ("city_id") REFERENCES "cities" ("id") ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE "city_stats" ADD CONSTRAINT "city_stats_city_id_fkey" FOREIGN KEY ("city_id") REFERENCES "cities" ("id") ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE "districts" ADD CONSTRAINT "districts_city_id_fkey" FOREIGN KEY ("city_id") REFERENCES "cities" ("id") ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE "survey_options" ADD CONSTRAINT "survey_options_survey_id_fkey" FOREIGN KEY ("survey_id") REFERENCES "surveys" ("id") ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE "survey_regional_results" ADD CONSTRAINT "survey_regional_results_survey_id_fkey" FOREIGN KEY ("survey_id") REFERENCES "surveys" ("id") ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE "survey_regional_results" ADD CONSTRAINT "survey_regional_results_option_id_fkey" FOREIGN KEY ("option_id") REFERENCES "survey_options" ("id") ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE "users" ADD CONSTRAINT "users_city_id_fkey" FOREIGN KEY ("city_id") REFERENCES "cities" ("id") ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE "users" ADD CONSTRAINT "users_district_id_fkey" FOREIGN KEY ("district_id") REFERENCES "districts" ("id") ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE "city_awards" ADD CONSTRAINT "city_awards_city_id_fkey" FOREIGN KEY ("city_id") REFERENCES "cities" ("id") ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE "city_awards" ADD CONSTRAINT "city_awards_award_type_id_fkey" FOREIGN KEY ("award_type_id") REFERENCES "award_types" ("id") ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE "city_awards" ADD CONSTRAINT "city_awards_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "city_projects" ("id") ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE "notifications" ADD CONSTRAINT "notifications_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE "posts" ADD CONSTRAINT "posts_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE "posts" ADD CONSTRAINT "posts_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "categories" ("id") ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE "posts" ADD CONSTRAINT "posts_city_id_fkey" FOREIGN KEY ("city_id") REFERENCES "cities" ("id") ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE "posts" ADD CONSTRAINT "posts_district_id_fkey" FOREIGN KEY ("district_id") REFERENCES "districts" ("id") ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE "media" ADD CONSTRAINT "media_post_id_fkey" FOREIGN KEY ("post_id") REFERENCES "posts" ("id") ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE "comments" ADD CONSTRAINT "comments_post_id_fkey" FOREIGN KEY ("post_id") REFERENCES "posts" ("id") ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE "comments" ADD CONSTRAINT "comments_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE "comments" ADD CONSTRAINT "comments_parent_id_fkey" FOREIGN KEY ("parent_id") REFERENCES "comments" ("id") ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE "user_likes" ADD CONSTRAINT "user_likes_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE "user_likes" ADD CONSTRAINT "user_likes_post_id_fkey" FOREIGN KEY ("post_id") REFERENCES "posts" ("id") ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE "user_likes" ADD CONSTRAINT "user_likes_comment_id_fkey" FOREIGN KEY ("comment_id") REFERENCES "comments" ("id") ON UPDATE CASCADE ON DELETE CASCADE;

COMMIT;
