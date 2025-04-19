-- ŞikayetVar Veritabanı Yedeği
-- Tablo: survey_regional_results
-- Tarih: 2025-04-19 21:04:28

START TRANSACTION;

CREATE TABLE IF NOT EXISTS survey_regional_results (
  "id" integer NOT NULL DEFAULT nextval('survey_regional_results_id_seq'::regclass),
  "survey_id" integer NOT NULL,
  "option_id" integer NOT NULL,
  "region_type" character varying(20) NOT NULL,
  "region_id" integer NOT NULL,
  "vote_count" integer NOT NULL DEFAULT 0,
  PRIMARY KEY ("id")
);


COMMIT;
