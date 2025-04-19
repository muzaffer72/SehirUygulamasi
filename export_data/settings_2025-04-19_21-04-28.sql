-- ŞikayetVar Veritabanı Yedeği
-- Tablo: settings
-- Tarih: 2025-04-19 21:04:28

START TRANSACTION;

CREATE TABLE IF NOT EXISTS settings (
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

INSERT INTO settings ("id", "site_name", "site_description", "admin_email", "maintenance_mode", "email_notifications", "push_notifications", "new_post_notifications", "new_user_notifications", "api_key", "webhook_url", "created_at", "updated_at") VALUES ('1', 'ŞikayetVar', 'Belediye ve Valilik\'e yönelik şikayet ve öneri paylaşım platformu', 'admin@sikayetvar.com', 'f', 't', 't', 't', 't', '2ca64f9afbc4160d15a1582fcb9df10c', 'https://sikayetvar.com/api/webhook', '2025-04-11 13:43:28.278784', '2025-04-11 13:43:28.278784') ON CONFLICT ("id") DO UPDATE SET "site_name" = EXCLUDED."site_name", "site_description" = EXCLUDED."site_description", "admin_email" = EXCLUDED."admin_email", "maintenance_mode" = EXCLUDED."maintenance_mode", "email_notifications" = EXCLUDED."email_notifications", "push_notifications" = EXCLUDED."push_notifications", "new_post_notifications" = EXCLUDED."new_post_notifications", "new_user_notifications" = EXCLUDED."new_user_notifications", "api_key" = EXCLUDED."api_key", "webhook_url" = EXCLUDED."webhook_url", "created_at" = EXCLUDED."created_at", "updated_at" = EXCLUDED."updated_at";

COMMIT;
