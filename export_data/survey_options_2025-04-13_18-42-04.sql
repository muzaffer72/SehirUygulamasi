CREATE TABLE IF NOT EXISTS survey_options (
  id integer,
  survey_id integer,
  text character varying(255),
  vote_count integer
);

INSERT INTO survey_options (id, survey_id, text, vote_count) VALUES ('1', '1', 'Çok memnunum', '45');
INSERT INTO survey_options (id, survey_id, text, vote_count) VALUES ('2', '1', 'Memnunum', '82');
INSERT INTO survey_options (id, survey_id, text, vote_count) VALUES ('3', '1', 'Kararsızım', '22');
INSERT INTO survey_options (id, survey_id, text, vote_count) VALUES ('4', '1', 'Memnun değilim', '58');
INSERT INTO survey_options (id, survey_id, text, vote_count) VALUES ('5', '1', 'Hiç memnun değilim', '93');
INSERT INTO survey_options (id, survey_id, text, vote_count) VALUES ('6', '2', 'Çok iyi', '35');
INSERT INTO survey_options (id, survey_id, text, vote_count) VALUES ('7', '2', 'İyi', '46');
INSERT INTO survey_options (id, survey_id, text, vote_count) VALUES ('8', '2', 'Ortalama', '32');
INSERT INTO survey_options (id, survey_id, text, vote_count) VALUES ('9', '2', 'Kötü', '54');
INSERT INTO survey_options (id, survey_id, text, vote_count) VALUES ('10', '2', 'Çok kötü', '27');
INSERT INTO survey_options (id, survey_id, text, vote_count) VALUES ('11', '3', 'Çok temiz ve düzenli', '81');
INSERT INTO survey_options (id, survey_id, text, vote_count) VALUES ('12', '3', 'Yeterince temiz', '53');
INSERT INTO survey_options (id, survey_id, text, vote_count) VALUES ('13', '3', 'Bazen sorunlar yaşanıyor', '91');
INSERT INTO survey_options (id, survey_id, text, vote_count) VALUES ('14', '3', 'Genellikle kirli', '46');
INSERT INTO survey_options (id, survey_id, text, vote_count) VALUES ('15', '3', 'Çok kirli ve düzensiz', '78');
