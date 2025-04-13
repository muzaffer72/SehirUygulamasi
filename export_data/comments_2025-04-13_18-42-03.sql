CREATE TABLE IF NOT EXISTS comments (
  id integer,
  post_id integer,
  user_id integer,
  content text,
  like_count integer,
  is_hidden boolean,
  created_at timestamp with time zone,
  parent_id integer,
  is_anonymous boolean
);

INSERT INTO comments (id, post_id, user_id, content, like_count, is_hidden, created_at, parent_id, is_anonymous) VALUES ('21', '83', '135', 'Farklı kanallardan da şikayet edelim, sosyal medyadan da duyuralım.', '0', '', '2025-04-11 20:28:28.663529+00', NULL, '');
INSERT INTO comments (id, post_id, user_id, content, like_count, is_hidden, created_at, parent_id, is_anonymous) VALUES ('22', '86', '141', 'Geçen ay da aynı sorun yaşanmıştı, kısa sürede düzeltilmişti. Umarım yine çözülür.', '0', '', '2025-04-11 20:28:28.663529+00', NULL, '');
INSERT INTO comments (id, post_id, user_id, content, like_count, is_hidden, created_at, parent_id, is_anonymous) VALUES ('23', '80', '142', 'Geçen ay da aynı sorun yaşanmıştı, kısa sürede düzeltilmişti. Umarım yine çözülür.', '0', '', '2025-04-11 20:28:28.663529+00', NULL, '');
INSERT INTO comments (id, post_id, user_id, content, like_count, is_hidden, created_at, parent_id, is_anonymous) VALUES ('24', '83', '137', 'Bence bu sorun bir an önce çözülmeli. Çok uzun süredir devam ediyor.', '0', '', '2025-04-11 20:28:28.663529+00', NULL, '');
INSERT INTO comments (id, post_id, user_id, content, like_count, is_hidden, created_at, parent_id, is_anonymous) VALUES ('25', '83', '141', 'Geçen ay da aynı sorun yaşanmıştı, kısa sürede düzeltilmişti. Umarım yine çözülür.', '0', '', '2025-04-11 20:28:28.663529+00', NULL, '');
INSERT INTO comments (id, post_id, user_id, content, like_count, is_hidden, created_at, parent_id, is_anonymous) VALUES ('26', '86', '136', 'Geçen ay da aynı sorun yaşanmıştı, kısa sürede düzeltilmişti. Umarım yine çözülür.', '0', '', '2025-04-11 20:28:28.663529+00', NULL, '');
INSERT INTO comments (id, post_id, user_id, content, like_count, is_hidden, created_at, parent_id, is_anonymous) VALUES ('27', '88', '143', 'Belediyenin çağrı merkezini denediniz mi? Bazen hızlı yanıt veriyorlar.', '0', '', '2025-04-11 20:28:28.663529+00', NULL, '');
INSERT INTO comments (id, post_id, user_id, content, like_count, is_hidden, created_at, parent_id, is_anonymous) VALUES ('28', '86', '142', 'Bu şikayeti destekliyorum, aynı sorundan biz de muzdaripiz.', '0', '', '2025-04-11 20:28:28.663529+00', NULL, '');
INSERT INTO comments (id, post_id, user_id, content, like_count, is_hidden, created_at, parent_id, is_anonymous) VALUES ('29', '82', '142', 'Bu şikayeti destekliyorum, aynı sorundan biz de muzdaripiz.', '0', '', '2025-04-11 20:28:28.663529+00', NULL, '');
INSERT INTO comments (id, post_id, user_id, content, like_count, is_hidden, created_at, parent_id, is_anonymous) VALUES ('30', '86', '139', 'Mahalle muhtarına da bildirdiniz mi? Bazen araya girerek yardımcı olabiliyorlar.', '0', '', '2025-04-11 20:28:28.663529+00', NULL, '');
INSERT INTO comments (id, post_id, user_id, content, like_count, is_hidden, created_at, parent_id, is_anonymous) VALUES ('31', '85', '139', 'Mahalle muhtarına da bildirdiniz mi? Bazen araya girerek yardımcı olabiliyorlar.', '0', '', '2025-04-11 20:28:28.663529+00', NULL, '');
INSERT INTO comments (id, post_id, user_id, content, like_count, is_hidden, created_at, parent_id, is_anonymous) VALUES ('32', '83', '143', 'Bu konuda yapılan bir çalışma var mı? Bilgi sahibi olan var mı?', '0', '', '2025-04-11 20:28:28.663529+00', NULL, '');
INSERT INTO comments (id, post_id, user_id, content, like_count, is_hidden, created_at, parent_id, is_anonymous) VALUES ('33', '88', '141', 'Bu sorunu ben de yaşıyorum. Belediye bu konuyla ilgilenmeli.', '0', '', '2025-04-11 20:28:28.663529+00', NULL, '');
INSERT INTO comments (id, post_id, user_id, content, like_count, is_hidden, created_at, parent_id, is_anonymous) VALUES ('34', '79', '135', 'Mahalle muhtarına da bildirdiniz mi? Bazen araya girerek yardımcı olabiliyorlar.', '0', '', '2025-04-11 20:28:28.663529+00', NULL, '');
INSERT INTO comments (id, post_id, user_id, content, like_count, is_hidden, created_at, parent_id, is_anonymous) VALUES ('35', '85', '136', 'Bence bu sorun bir an önce çözülmeli. Çok uzun süredir devam ediyor.', '0', '', '2025-04-11 20:28:28.663529+00', NULL, '');
INSERT INTO comments (id, post_id, user_id, content, like_count, is_hidden, created_at, parent_id, is_anonymous) VALUES ('36', '85', '137', 'Sorununuzu anlıyorum, bence bir imza kampanyası başlatalım.', '0', '', '2025-04-11 20:28:28.663529+00', NULL, '');
INSERT INTO comments (id, post_id, user_id, content, like_count, is_hidden, created_at, parent_id, is_anonymous) VALUES ('37', '82', '144', 'Bence bu sorun bir an önce çözülmeli. Çok uzun süredir devam ediyor.', '0', '', '2025-04-11 20:28:28.663529+00', NULL, '');
INSERT INTO comments (id, post_id, user_id, content, like_count, is_hidden, created_at, parent_id, is_anonymous) VALUES ('38', '82', '139', 'Bu konuda bir gelişme oldu mu? Bizim bölgede de benzer sıkıntılar var.', '0', '', '2025-04-11 20:28:28.663529+00', NULL, '');
INSERT INTO comments (id, post_id, user_id, content, like_count, is_hidden, created_at, parent_id, is_anonymous) VALUES ('39', '88', '136', 'Bu konuda bir gelişme oldu mu? Bizim bölgede de benzer sıkıntılar var.', '0', '', '2025-04-11 20:28:28.663529+00', NULL, '');
INSERT INTO comments (id, post_id, user_id, content, like_count, is_hidden, created_at, parent_id, is_anonymous) VALUES ('40', '84', '143', 'Bu sorun gerçekten can sıkıcı, yetkililerin dikkate almasını umuyorum.', '0', '', '2025-04-11 20:28:28.663529+00', NULL, '');
INSERT INTO comments (id, post_id, user_id, content, like_count, is_hidden, created_at, parent_id, is_anonymous) VALUES ('41', '79', '1', 'Merhaba', '0', '', '2025-04-13 08:11:52.462753+00', '34', '');
INSERT INTO comments (id, post_id, user_id, content, like_count, is_hidden, created_at, parent_id, is_anonymous) VALUES ('42', '79', '1', 'anonim', '0', '', '2025-04-13 08:12:06.224401+00', '34', '1');
