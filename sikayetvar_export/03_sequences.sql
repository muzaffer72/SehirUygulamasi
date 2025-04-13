
-- Sequence değerlerini tablolardaki en yüksek ID değerine göre yeniden düzenle
SELECT setval('award_types_id_seq', COALESCE((SELECT MAX(id) FROM award_types), 1), true);
SELECT setval('banned_words_id_seq', COALESCE((SELECT MAX(id) FROM banned_words), 1), true);
SELECT setval('categories_id_seq', COALESCE((SELECT MAX(id) FROM categories), 1), true);
SELECT setval('cities_id_seq', COALESCE((SELECT MAX(id) FROM cities), 1), true);
SELECT setval('city_awards_id_seq', COALESCE((SELECT MAX(id) FROM city_awards), 1), true);
SELECT setval('city_events_id_seq', COALESCE((SELECT MAX(id) FROM city_events), 1), true);
SELECT setval('city_projects_id_seq', COALESCE((SELECT MAX(id) FROM city_projects), 1), true);
SELECT setval('city_services_id_seq', COALESCE((SELECT MAX(id) FROM city_services), 1), true);
SELECT setval('city_stats_id_seq', COALESCE((SELECT MAX(id) FROM city_stats), 1), true);
SELECT setval('comments_id_seq', COALESCE((SELECT MAX(id) FROM comments), 1), true);
SELECT setval('districts_id_seq', COALESCE((SELECT MAX(id) FROM districts), 1), true);
SELECT setval('media_id_seq', COALESCE((SELECT MAX(id) FROM media), 1), true);
SELECT setval('migrations_id_seq', COALESCE((SELECT MAX(id) FROM migrations), 1), true);
SELECT setval('notifications_id_seq', COALESCE((SELECT MAX(id) FROM notifications), 1), true);
SELECT setval('posts_id_seq', COALESCE((SELECT MAX(id) FROM posts), 1), true);
SELECT setval('settings_id_seq', COALESCE((SELECT MAX(id) FROM settings), 1), true);
SELECT setval('survey_options_id_seq', COALESCE((SELECT MAX(id) FROM survey_options), 1), true);
SELECT setval('survey_regional_results_id_seq', COALESCE((SELECT MAX(id) FROM survey_regional_results), 1), true);
SELECT setval('surveys_id_seq', COALESCE((SELECT MAX(id) FROM surveys), 1), true);
SELECT setval('user_likes_id_seq', COALESCE((SELECT MAX(id) FROM user_likes), 1), true);
SELECT setval('users_id_seq', COALESCE((SELECT MAX(id) FROM users), 1), true);
