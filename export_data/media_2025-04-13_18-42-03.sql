CREATE TABLE IF NOT EXISTS media (
  id integer,
  post_id integer,
  url text,
  type character varying(20),
  created_at timestamp with time zone
);

INSERT INTO media (id, post_id, url, type, created_at) VALUES ('1', '22', 'https://images.unsplash.com/photo-1605600659873-d808a13e4d2f?q=80&w=1000', 'image', '2025-04-11 14:08:49.67109+00');
INSERT INTO media (id, post_id, url, type, created_at) VALUES ('2', '22', 'https://images.unsplash.com/photo-1605600659873-d808a13e4d2f?q=80&w=1000', 'image', '2025-04-11 14:08:49.701939+00');
INSERT INTO media (id, post_id, url, type, created_at) VALUES ('3', '24', 'https://images.unsplash.com/photo-1528262502195-26dfb3c29f8f?q=80&w=1000', 'image', '2025-04-11 14:08:50.132075+00');
INSERT INTO media (id, post_id, url, type, created_at) VALUES ('4', '24', 'https://images.unsplash.com/photo-1528262502195-26dfb3c29f8f?q=80&w=1000', 'image', '2025-04-11 14:08:50.152967+00');
INSERT INTO media (id, post_id, url, type, created_at) VALUES ('5', '26', 'https://images.unsplash.com/photo-1628515334134-870832b6e76a?q=80&w=1000', 'image', '2025-04-11 14:08:50.574559+00');
INSERT INTO media (id, post_id, url, type, created_at) VALUES ('6', '26', 'https://images.unsplash.com/photo-1628515334134-870832b6e76a?q=80&w=1000', 'image', '2025-04-11 14:08:50.595358+00');
INSERT INTO media (id, post_id, url, type, created_at) VALUES ('7', '30', 'https://images.unsplash.com/photo-1549042261-24c2ddb5df68?q=80&w=1000', 'image', '2025-04-11 14:08:51.388693+00');
INSERT INTO media (id, post_id, url, type, created_at) VALUES ('8', '30', 'https://images.unsplash.com/photo-1549042261-24c2ddb5df68?q=80&w=1000', 'image', '2025-04-11 14:08:51.410246+00');
INSERT INTO media (id, post_id, url, type, created_at) VALUES ('9', '32', 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 'video', '2025-04-11 14:08:51.823019+00');
INSERT INTO media (id, post_id, url, type, created_at) VALUES ('10', '32', 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 'video', '2025-04-11 14:08:51.844078+00');
INSERT INTO media (id, post_id, url, type, created_at) VALUES ('12', '36', 'https://images.unsplash.com/photo-1526714719019-b3032b5b5aac?q=80&w=1000', 'image', '2025-04-11 14:08:52.626214+00');
INSERT INTO media (id, post_id, url, type, created_at) VALUES ('13', '38', 'https://www.youtube.com/watch?v=a3ICNMQW7Ok', 'video', '2025-04-11 14:08:53.045959+00');
INSERT INTO media (id, post_id, url, type, created_at) VALUES ('14', '38', 'https://www.youtube.com/watch?v=a3ICNMQW7Ok', 'video', '2025-04-11 14:08:53.066902+00');
INSERT INTO media (id, post_id, url, type, created_at) VALUES ('15', '10', 'https://picsum.photos/800/600', 'image', '2025-04-11 14:44:48.276708+00');
INSERT INTO media (id, post_id, url, type, created_at) VALUES ('17', '7', 'https://picsum.photos/800/500', 'image', '2025-04-11 14:44:58.653445+00');
INSERT INTO media (id, post_id, url, type, created_at) VALUES ('18', '23', 'https://www.youtube.com/embed/C0DPdy98e4c', 'video', '2025-04-11 14:45:02.367141+00');
INSERT INTO media (id, post_id, url, type, created_at) VALUES ('19', '5', 'https://picsum.photos/900/600', 'image', '2025-04-11 14:45:06.675292+00');
INSERT INTO media (id, post_id, url, type, created_at) VALUES ('22', '11', 'uploads/1744383142_technology-image-globe_114588-838.jpg', 'image', '2025-04-11 14:52:22.89354+00');
INSERT INTO media (id, post_id, url, type, created_at) VALUES ('24', '12', 'uploads/1744400518_1000146158.jpg', 'image', '2025-04-11 19:41:58.189622+00');
