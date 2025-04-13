CREATE TABLE IF NOT EXISTS banned_words (
  id integer,
  word character varying(100),
  created_at timestamp with time zone
);

INSERT INTO banned_words (id, word, created_at) VALUES ('1', 'küfür', '2025-04-09 18:59:03.592217+00');
INSERT INTO banned_words (id, word, created_at) VALUES ('2', 'hakaret', '2025-04-09 18:59:03.592217+00');
INSERT INTO banned_words (id, word, created_at) VALUES ('3', 'argo', '2025-04-09 18:59:03.592217+00');
