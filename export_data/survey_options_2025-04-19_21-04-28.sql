-- ŞikayetVar Veritabanı Yedeği
-- Tablo: survey_options
-- Tarih: 2025-04-19 21:04:28

START TRANSACTION;

CREATE TABLE IF NOT EXISTS survey_options (
  "id" integer NOT NULL DEFAULT nextval('survey_options_id_seq'::regclass),
  "survey_id" integer NOT NULL,
  "text" character varying(255) NOT NULL,
  "vote_count" integer NOT NULL DEFAULT 0,
  PRIMARY KEY ("id")
);

INSERT INTO survey_options ("id", "survey_id", "text", "vote_count") VALUES ('1', '1', 'Çok memnunum', '45') ON CONFLICT ("id") DO UPDATE SET "survey_id" = EXCLUDED."survey_id", "text" = EXCLUDED."text", "vote_count" = EXCLUDED."vote_count";
INSERT INTO survey_options ("id", "survey_id", "text", "vote_count") VALUES ('2', '1', 'Memnunum', '82') ON CONFLICT ("id") DO UPDATE SET "survey_id" = EXCLUDED."survey_id", "text" = EXCLUDED."text", "vote_count" = EXCLUDED."vote_count";
INSERT INTO survey_options ("id", "survey_id", "text", "vote_count") VALUES ('3', '1', 'Kararsızım', '22') ON CONFLICT ("id") DO UPDATE SET "survey_id" = EXCLUDED."survey_id", "text" = EXCLUDED."text", "vote_count" = EXCLUDED."vote_count";
INSERT INTO survey_options ("id", "survey_id", "text", "vote_count") VALUES ('4', '1', 'Memnun değilim', '58') ON CONFLICT ("id") DO UPDATE SET "survey_id" = EXCLUDED."survey_id", "text" = EXCLUDED."text", "vote_count" = EXCLUDED."vote_count";
INSERT INTO survey_options ("id", "survey_id", "text", "vote_count") VALUES ('5', '1', 'Hiç memnun değilim', '93') ON CONFLICT ("id") DO UPDATE SET "survey_id" = EXCLUDED."survey_id", "text" = EXCLUDED."text", "vote_count" = EXCLUDED."vote_count";
INSERT INTO survey_options ("id", "survey_id", "text", "vote_count") VALUES ('6', '2', 'Çok iyi', '35') ON CONFLICT ("id") DO UPDATE SET "survey_id" = EXCLUDED."survey_id", "text" = EXCLUDED."text", "vote_count" = EXCLUDED."vote_count";
INSERT INTO survey_options ("id", "survey_id", "text", "vote_count") VALUES ('7', '2', 'İyi', '46') ON CONFLICT ("id") DO UPDATE SET "survey_id" = EXCLUDED."survey_id", "text" = EXCLUDED."text", "vote_count" = EXCLUDED."vote_count";
INSERT INTO survey_options ("id", "survey_id", "text", "vote_count") VALUES ('8', '2', 'Ortalama', '32') ON CONFLICT ("id") DO UPDATE SET "survey_id" = EXCLUDED."survey_id", "text" = EXCLUDED."text", "vote_count" = EXCLUDED."vote_count";
INSERT INTO survey_options ("id", "survey_id", "text", "vote_count") VALUES ('9', '2', 'Kötü', '54') ON CONFLICT ("id") DO UPDATE SET "survey_id" = EXCLUDED."survey_id", "text" = EXCLUDED."text", "vote_count" = EXCLUDED."vote_count";
INSERT INTO survey_options ("id", "survey_id", "text", "vote_count") VALUES ('10', '2', 'Çok kötü', '27') ON CONFLICT ("id") DO UPDATE SET "survey_id" = EXCLUDED."survey_id", "text" = EXCLUDED."text", "vote_count" = EXCLUDED."vote_count";
INSERT INTO survey_options ("id", "survey_id", "text", "vote_count") VALUES ('11', '3', 'Çok temiz ve düzenli', '81') ON CONFLICT ("id") DO UPDATE SET "survey_id" = EXCLUDED."survey_id", "text" = EXCLUDED."text", "vote_count" = EXCLUDED."vote_count";
INSERT INTO survey_options ("id", "survey_id", "text", "vote_count") VALUES ('12', '3', 'Yeterince temiz', '53') ON CONFLICT ("id") DO UPDATE SET "survey_id" = EXCLUDED."survey_id", "text" = EXCLUDED."text", "vote_count" = EXCLUDED."vote_count";
INSERT INTO survey_options ("id", "survey_id", "text", "vote_count") VALUES ('13', '3', 'Bazen sorunlar yaşanıyor', '91') ON CONFLICT ("id") DO UPDATE SET "survey_id" = EXCLUDED."survey_id", "text" = EXCLUDED."text", "vote_count" = EXCLUDED."vote_count";
INSERT INTO survey_options ("id", "survey_id", "text", "vote_count") VALUES ('14', '3', 'Genellikle kirli', '46') ON CONFLICT ("id") DO UPDATE SET "survey_id" = EXCLUDED."survey_id", "text" = EXCLUDED."text", "vote_count" = EXCLUDED."vote_count";
INSERT INTO survey_options ("id", "survey_id", "text", "vote_count") VALUES ('15', '3', 'Çok kirli ve düzensiz', '78') ON CONFLICT ("id") DO UPDATE SET "survey_id" = EXCLUDED."survey_id", "text" = EXCLUDED."text", "vote_count" = EXCLUDED."vote_count";

COMMIT;
