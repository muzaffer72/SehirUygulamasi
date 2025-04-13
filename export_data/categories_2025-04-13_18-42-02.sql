CREATE TABLE IF NOT EXISTS categories (
  id integer,
  name character varying(100),
  icon_name character varying(50),
  created_at timestamp with time zone
);

INSERT INTO categories (id, name, icon_name, created_at) VALUES ('1', 'Altyapı', 'construction', '2025-04-09 18:59:03.290753+00');
INSERT INTO categories (id, name, icon_name, created_at) VALUES ('2', 'Ulaşım', 'directions_bus', '2025-04-09 18:59:03.290753+00');
INSERT INTO categories (id, name, icon_name, created_at) VALUES ('3', 'Çevre', 'nature', '2025-04-09 18:59:03.290753+00');
INSERT INTO categories (id, name, icon_name, created_at) VALUES ('4', 'Güvenlik', 'security', '2025-04-09 18:59:03.290753+00');
INSERT INTO categories (id, name, icon_name, created_at) VALUES ('5', 'Sağlık', 'local_hospital', '2025-04-09 18:59:03.290753+00');
INSERT INTO categories (id, name, icon_name, created_at) VALUES ('6', 'Eğitim', 'school', '2025-04-09 18:59:03.290753+00');
INSERT INTO categories (id, name, icon_name, created_at) VALUES ('7', 'Kültür & Sanat', 'theater_comedy', '2025-04-09 18:59:03.290753+00');
INSERT INTO categories (id, name, icon_name, created_at) VALUES ('8', 'Sosyal Hizmetler', 'people', '2025-04-09 18:59:03.290753+00');
INSERT INTO categories (id, name, icon_name, created_at) VALUES ('9', 'Diğer', 'more_horiz', '2025-04-09 18:59:03.290753+00');
