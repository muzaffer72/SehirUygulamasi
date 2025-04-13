-- ŞikayetVar Veritabanı Schema Dump
-- Export Tarihi: 2025-04-13
-- ---------------------------------------------------

-- Tablo award_types
CREATE TABLE IF NOT EXISTS award_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    icon_url TEXT,
    badge_url TEXT,
    color VARCHAR(20),
    points INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_system BOOLEAN NOT NULL DEFAULT FALSE,
    icon VARCHAR(100),
    min_rate NUMERIC DEFAULT 0,
    max_rate NUMERIC DEFAULT 100,
    badge_color VARCHAR(20)
);

-- Tablo banned_words
CREATE TABLE IF NOT EXISTS banned_words (
    id SERIAL PRIMARY KEY,
    word VARCHAR(100) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Tablo categories
CREATE TABLE IF NOT EXISTS categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    icon VARCHAR(100),
    color VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tablo cities
CREATE TABLE IF NOT EXISTS cities (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    region VARCHAR(100),
    province VARCHAR(100),
    population INTEGER,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    about TEXT,
    logo_url TEXT,
    cover_image_url TEXT,
    mayor_name VARCHAR(100),
    mayor_party VARCHAR(100),
    mayor_photo_url TEXT,
    website_url TEXT,
    phone VARCHAR(50),
    email VARCHAR(100),
    twitter_url TEXT,
    facebook_url TEXT,
    instagram_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    problem_solving_rate NUMERIC DEFAULT 0.00
);

-- Tablo city_awards
CREATE TABLE IF NOT EXISTS city_awards (
    id SERIAL PRIMARY KEY,
    city_id INTEGER REFERENCES cities(id),
    award_id INTEGER REFERENCES award_types(id),
    start_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expiry_date TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tablo city_events
CREATE TABLE IF NOT EXISTS city_events (
    id SERIAL PRIMARY KEY,
    city_id INTEGER REFERENCES cities(id),
    name VARCHAR(200) NOT NULL,
    description TEXT,
    start_date TIMESTAMP,
    end_date TIMESTAMP,
    location TEXT,
    image_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tablo city_projects
CREATE TABLE IF NOT EXISTS city_projects (
    id SERIAL PRIMARY KEY,
    city_id INTEGER REFERENCES cities(id),
    name VARCHAR(200) NOT NULL,
    description TEXT,
    start_date TIMESTAMP,
    end_date TIMESTAMP,
    status VARCHAR(50),
    budget NUMERIC,
    image_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tablo city_services
CREATE TABLE IF NOT EXISTS city_services (
    id SERIAL PRIMARY KEY,
    city_id INTEGER REFERENCES cities(id),
    name VARCHAR(200) NOT NULL,
    description TEXT,
    icon VARCHAR(100),
    contact_info TEXT,
    working_hours TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tablo city_stats
CREATE TABLE IF NOT EXISTS city_stats (
    id SERIAL PRIMARY KEY,
    city_id INTEGER REFERENCES cities(id),
    stat_name VARCHAR(100) NOT NULL,
    stat_value NUMERIC NOT NULL,
    unit VARCHAR(20),
    year INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tablo comments
CREATE TABLE IF NOT EXISTS comments (
    id SERIAL PRIMARY KEY,
    post_id INTEGER,
    user_id INTEGER,
    content TEXT NOT NULL,
    likes_count INTEGER DEFAULT 0,
    is_approved BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    parent_id INTEGER
);

-- Tablo districts
CREATE TABLE IF NOT EXISTS districts (
    id SERIAL PRIMARY KEY,
    city_id INTEGER REFERENCES cities(id),
    name VARCHAR(100) NOT NULL,
    population INTEGER,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tablo media
CREATE TABLE IF NOT EXISTS media (
    id SERIAL PRIMARY KEY,
    post_id INTEGER,
    user_id INTEGER,
    media_type VARCHAR(20) NOT NULL,
    url TEXT NOT NULL,
    thumbnail_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tablo migrations
CREATE TABLE IF NOT EXISTS migrations (
    id SERIAL PRIMARY KEY,
    migration VARCHAR(255) NOT NULL,
    batch INTEGER NOT NULL
);

-- Tablo notifications
CREATE TABLE IF NOT EXISTS notifications (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    type VARCHAR(50) NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    related_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tablo posts
CREATE TABLE IF NOT EXISTS posts (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    category_id INTEGER,
    city_id INTEGER,
    district_id INTEGER,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    status VARCHAR(50) DEFAULT 'open',
    is_resolved BOOLEAN DEFAULT FALSE,
    is_approved BOOLEAN DEFAULT TRUE,
    likes_count INTEGER DEFAULT 0,
    comments_count INTEGER DEFAULT 0,
    views_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_anonymous BOOLEAN DEFAULT FALSE,
    is_featured BOOLEAN DEFAULT FALSE,
    address TEXT
);

-- Tablo settings
CREATE TABLE IF NOT EXISTS settings (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    value TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tablo survey_options
CREATE TABLE IF NOT EXISTS survey_options (
    id SERIAL PRIMARY KEY,
    survey_id INTEGER NOT NULL,
    option_text TEXT NOT NULL,
    votes_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tablo survey_regional_results
CREATE TABLE IF NOT EXISTS survey_regional_results (
    id SERIAL PRIMARY KEY,
    survey_id INTEGER NOT NULL,
    option_id INTEGER NOT NULL,
    region_type VARCHAR(20) NOT NULL,
    region_id INTEGER NOT NULL,
    votes_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tablo surveys
CREATE TABLE IF NOT EXISTS surveys (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    start_date TIMESTAMP,
    end_date TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    scope_type VARCHAR(20) DEFAULT 'national',
    scope_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tablo user_likes
CREATE TABLE IF NOT EXISTS user_likes (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    post_id INTEGER,
    comment_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tablo users
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    avatar_url TEXT,
    bio TEXT,
    location VARCHAR(100),
    level INTEGER DEFAULT 1,
    points INTEGER DEFAULT 0,
    role VARCHAR(20) DEFAULT 'user',
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    city_id INTEGER,
    district_id INTEGER,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    email_verified_at TIMESTAMP,
    remember_token VARCHAR(100),
    username VARCHAR(100)
);