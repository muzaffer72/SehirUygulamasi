-- Anket (Survey) tabloları için SQL script
-- SikayetVar uygulaması için gerekli tablolar

-- Anketler tablosu
CREATE TABLE IF NOT EXISTS surveys (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    short_title VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    category_id INT NOT NULL,
    scope_type VARCHAR(20) NOT NULL, -- general, city, district
    city_id VARCHAR(50) NULL,
    district_id INT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_users INT NOT NULL DEFAULT 1000,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id)
);

-- Anket seçenekleri tablosu
CREATE TABLE IF NOT EXISTS survey_options (
    id SERIAL PRIMARY KEY,
    survey_id INT NOT NULL,
    text VARCHAR(255) NOT NULL,
    vote_count INT NOT NULL DEFAULT 0,
    FOREIGN KEY (survey_id) REFERENCES surveys(id) ON DELETE CASCADE
);

-- Bölgesel anket sonuçları tablosu
CREATE TABLE IF NOT EXISTS survey_regional_results (
    id SERIAL PRIMARY KEY,
    survey_id INT NOT NULL,
    option_id INT NOT NULL,
    region_type VARCHAR(20) NOT NULL, -- city, district
    region_id INT NOT NULL,
    vote_count INT NOT NULL DEFAULT 0,
    FOREIGN KEY (survey_id) REFERENCES surveys(id) ON DELETE CASCADE,
    FOREIGN KEY (option_id) REFERENCES survey_options(id) ON DELETE CASCADE
);