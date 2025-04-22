
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
  "satisfaction_rating" integer NULL,
  PRIMARY KEY ("id")
);

DROP TABLE IF EXISTS "before_after_records" CASCADE;
DROP SEQUENCE IF EXISTS "before_after_records_id_seq" CASCADE;
CREATE SEQUENCE IF NOT EXISTS "before_after_records_id_seq";

CREATE TABLE "before_after_records" (
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
