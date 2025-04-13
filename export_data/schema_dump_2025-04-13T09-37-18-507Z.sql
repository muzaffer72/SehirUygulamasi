-- SikayetVar veritabanı şema dökümü

CREATE TABLE IF NOT EXISTS survey_options (vote_count integer NOT NULL DEFAULT 0, id integer NOT NULL DEFAULT nextval('survey_options_id_seq'::regclass), text character varying(255) NOT NULL, survey_id integer NOT NULL);

CREATE TABLE IF NOT EXISTS comments (like_count integer NOT NULL DEFAULT 0, post_id integer NOT NULL, is_anonymous boolean DEFAULT false, created_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP, user_id integer NOT NULL, id integer NOT NULL DEFAULT nextval('comments_id_seq'::regclass), content text NOT NULL, is_hidden boolean NOT NULL DEFAULT false, parent_id integer);

CREATE TABLE IF NOT EXISTS city_stats (created_at timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP, city_id integer NOT NULL, updated_at timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP, healthcare_access numeric DEFAULT 0.00, safety_index numeric DEFAULT 0.00, education_quality numeric DEFAULT 0.00, id integer NOT NULL DEFAULT nextval('city_stats_id_seq'::regclass), unemployment_rate numeric DEFAULT 0.00, cost_of_living numeric DEFAULT 0.00, infrastructure_quality numeric DEFAULT 0.00, year character varying(4) NOT NULL);

CREATE TABLE IF NOT EXISTS media (id integer NOT NULL DEFAULT nextval('media_id_seq'::regclass), type character varying(20) NOT NULL, url text NOT NULL, post_id integer NOT NULL, created_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP);

CREATE TABLE IF NOT EXISTS city_events (created_at timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP, event_time time without time zone, name character varying(255) NOT NULL, id integer NOT NULL DEFAULT nextval('city_events_id_seq'::regclass), description text, event_date date, type character varying(50), location character varying(255), updated_at timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP, city_id integer NOT NULL);

CREATE TABLE IF NOT EXISTS city_services (address character varying(255), city_id integer NOT NULL, updated_at timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP, website character varying(255), created_at timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP, name character varying(255) NOT NULL, id integer NOT NULL DEFAULT nextval('city_services_id_seq'::regclass), description text, phone character varying(50), type character varying(50));

CREATE TABLE IF NOT EXISTS settings (webhook_url character varying(255), created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP, api_key character varying(100), site_name character varying(100) NOT NULL DEFAULT 'ŞikayetVar'::character varying, updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP, maintenance_mode boolean DEFAULT false, new_post_notifications boolean DEFAULT true, email_notifications boolean DEFAULT true, admin_email character varying(255), id integer NOT NULL, site_description text, new_user_notifications boolean DEFAULT true, push_notifications boolean DEFAULT true);

CREATE TABLE IF NOT EXISTS districts (problem_solving_rate integer DEFAULT 0, name character varying(100) NOT NULL, city_id integer NOT NULL, created_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP, id integer NOT NULL DEFAULT nextval('districts_id_seq'::regclass));

CREATE TABLE IF NOT EXISTS city_projects (end_date date, budget numeric DEFAULT 0.00, id integer NOT NULL DEFAULT nextval('city_projects_id_seq'::regclass), description text, start_date date, created_at timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP, name character varying(255) NOT NULL, city_id integer NOT NULL, updated_at timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP, status character varying(20) NOT NULL DEFAULT 'planned'::character varying);

CREATE TABLE IF NOT EXISTS cities (mayor_name character varying(255), website character varying(255), created_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP, id integer NOT NULL DEFAULT nextval('cities_id_seq'::regclass), description text, area integer DEFAULT 0, mayor_party character varying(100), population integer DEFAULT 0, problem_solving_rate integer DEFAULT 0, name character varying(100) NOT NULL, phone character varying(50), social_media character varying(255), email character varying(255));

CREATE TABLE IF NOT EXISTS city_awards (featured boolean NOT NULL DEFAULT false, issuer character varying(100), award_type_id integer NOT NULL, id integer NOT NULL DEFAULT nextval('city_awards_id_seq'::regclass), title character varying(255) NOT NULL, award_date date NOT NULL, certificate_url text, description text, expiry_date date, project_id integer, city_id integer NOT NULL, created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP);

CREATE TABLE IF NOT EXISTS surveys (total_users integer NOT NULL DEFAULT 1000, title character varying(255) NOT NULL, end_date date NOT NULL, is_active boolean NOT NULL DEFAULT true, category_id integer NOT NULL, created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP, scope_type character varying(20) NOT NULL, district_id integer, short_title character varying(100) NOT NULL, city_id integer, start_date date NOT NULL, description text NOT NULL, id integer NOT NULL DEFAULT nextval('surveys_id_seq'::regclass));

CREATE TABLE IF NOT EXISTS migrations (batch integer NOT NULL, id integer NOT NULL DEFAULT nextval('migrations_id_seq'::regclass), migration character varying(255) NOT NULL);

CREATE TABLE IF NOT EXISTS award_types (color character varying(20), created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP, description text, is_system boolean NOT NULL DEFAULT false, points integer NOT NULL DEFAULT 0, icon_url text, id integer NOT NULL DEFAULT nextval('award_types_id_seq'::regclass), min_rate numeric DEFAULT 0, max_rate numeric DEFAULT 100, icon character varying(100), name character varying(100) NOT NULL, badge_color character varying(20), badge_url text);

CREATE TABLE IF NOT EXISTS users (username character varying(100), level character varying(20) NOT NULL DEFAULT 'newUser'::character varying, profile_image_url text, post_count integer NOT NULL DEFAULT 0, points integer NOT NULL DEFAULT 0, comment_count integer NOT NULL DEFAULT 0, name character varying(100) NOT NULL, password character varying(255) NOT NULL, id integer NOT NULL DEFAULT nextval('users_id_seq'::regclass), email character varying(255) NOT NULL, created_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP, is_verified boolean NOT NULL DEFAULT false, city_id integer, district_id integer, bio text);

CREATE TABLE IF NOT EXISTS categories (created_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP, id integer NOT NULL DEFAULT nextval('categories_id_seq'::regclass), icon_name character varying(50), name character varying(100) NOT NULL);

CREATE TABLE IF NOT EXISTS survey_regional_results (survey_id integer NOT NULL, region_id integer NOT NULL, vote_count integer NOT NULL DEFAULT 0, region_type character varying(20) NOT NULL, id integer NOT NULL DEFAULT nextval('survey_regional_results_id_seq'::regclass), option_id integer NOT NULL);

CREATE TABLE IF NOT EXISTS banned_words (word character varying(100) NOT NULL, id integer NOT NULL DEFAULT nextval('banned_words_id_seq'::regclass), created_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP);

CREATE TABLE IF NOT EXISTS posts (is_anonymous boolean NOT NULL DEFAULT false, category_id integer NOT NULL, likes integer NOT NULL DEFAULT 0, comment_count integer NOT NULL DEFAULT 0, title character varying(255) NOT NULL, highlights integer NOT NULL DEFAULT 0, type character varying(20) NOT NULL DEFAULT 'problem'::character varying, district_id integer, content text NOT NULL, created_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP, id integer NOT NULL DEFAULT nextval('posts_id_seq'::regclass), user_id integer NOT NULL, city_id integer, status character varying(20) NOT NULL DEFAULT 'awaitingSolution'::character varying);

CREATE TABLE IF NOT EXISTS notifications (type character varying(50) NOT NULL, user_id integer NOT NULL, created_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP, title character varying(255) NOT NULL, source_id integer, data text, content text NOT NULL, id integer NOT NULL DEFAULT nextval('notifications_id_seq'::regclass), is_read boolean NOT NULL DEFAULT false, source_type character varying(50));

CREATE TABLE IF NOT EXISTS user_likes (post_id integer, id integer NOT NULL DEFAULT nextval('user_likes_id_seq'::regclass), comment_id integer, created_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP, user_id integer NOT NULL);

