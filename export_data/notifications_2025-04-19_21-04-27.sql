-- ŞikayetVar Veritabanı Yedeği
-- Tablo: notifications
-- Tarih: 2025-04-19 21:04:27

START TRANSACTION;

CREATE TABLE IF NOT EXISTS notifications (
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

INSERT INTO notifications ("id", "user_id", "title", "content", "type", "is_read", "source_id", "source_type", "data", "created_at") VALUES ('1', '135', 'Yorumunuza yanıt geldi', '@admin yorumunuza yanıt verdi: \"Merhaba\"', 'reply', 'f', '34', 'comment', NULL, '2025-04-13 08:11:52.727841+00') ON CONFLICT ("id") DO UPDATE SET "user_id" = EXCLUDED."user_id", "title" = EXCLUDED."title", "content" = EXCLUDED."content", "type" = EXCLUDED."type", "is_read" = EXCLUDED."is_read", "source_id" = EXCLUDED."source_id", "source_type" = EXCLUDED."source_type", "data" = EXCLUDED."data", "created_at" = EXCLUDED."created_at";
INSERT INTO notifications ("id", "user_id", "title", "content", "type", "is_read", "source_id", "source_type", "data", "created_at") VALUES ('2', '135', 'Yorumunuza yanıt geldi', '@admin yorumunuza yanıt verdi: \"anonim\"', 'reply', 'f', '34', 'comment', NULL, '2025-04-13 08:12:06.489968+00') ON CONFLICT ("id") DO UPDATE SET "user_id" = EXCLUDED."user_id", "title" = EXCLUDED."title", "content" = EXCLUDED."content", "type" = EXCLUDED."type", "is_read" = EXCLUDED."is_read", "source_id" = EXCLUDED."source_id", "source_type" = EXCLUDED."source_type", "data" = EXCLUDED."data", "created_at" = EXCLUDED."created_at";

COMMIT;
