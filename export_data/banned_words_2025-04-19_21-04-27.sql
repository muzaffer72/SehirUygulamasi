-- ŞikayetVar Veritabanı Yedeği
-- Tablo: banned_words
-- Tarih: 2025-04-19 21:04:27

START TRANSACTION;

CREATE TABLE IF NOT EXISTS banned_words (
  "id" integer NOT NULL DEFAULT nextval('banned_words_id_seq'::regclass),
  "word" character varying(100) NOT NULL,
  "created_at" timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id")
);

INSERT INTO banned_words ("id", "word", "created_at") VALUES ('1', 'küfür', '2025-04-09 18:59:03.592217+00') ON CONFLICT ("id") DO UPDATE SET "word" = EXCLUDED."word", "created_at" = EXCLUDED."created_at";
INSERT INTO banned_words ("id", "word", "created_at") VALUES ('2', 'hakaret', '2025-04-09 18:59:03.592217+00') ON CONFLICT ("id") DO UPDATE SET "word" = EXCLUDED."word", "created_at" = EXCLUDED."created_at";
INSERT INTO banned_words ("id", "word", "created_at") VALUES ('3', 'argo', '2025-04-09 18:59:03.592217+00') ON CONFLICT ("id") DO UPDATE SET "word" = EXCLUDED."word", "created_at" = EXCLUDED."created_at";

COMMIT;
