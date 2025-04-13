CREATE TABLE IF NOT EXISTS notifications (
  id integer,
  user_id integer,
  title character varying(255),
  content text,
  type character varying(50),
  is_read boolean,
  source_id integer,
  source_type character varying(50),
  data text,
  created_at timestamp with time zone
);

INSERT INTO notifications (id, user_id, title, content, type, is_read, source_id, source_type, data, created_at) VALUES ('1', '135', 'Yorumunuza yanıt geldi', '@admin yorumunuza yanıt verdi: \"Merhaba\"', 'reply', '', '34', 'comment', NULL, '2025-04-13 08:11:52.727841+00');
INSERT INTO notifications (id, user_id, title, content, type, is_read, source_id, source_type, data, created_at) VALUES ('2', '135', 'Yorumunuza yanıt geldi', '@admin yorumunuza yanıt verdi: \"anonim\"', 'reply', '', '34', 'comment', NULL, '2025-04-13 08:12:06.489968+00');
