-- Notifications table
CREATE TABLE IF NOT EXISTS notifications (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    target_type VARCHAR(50) NOT NULL DEFAULT 'all',  -- 'all', 'user', 'city', 'category'
    target_id VARCHAR(50),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    status VARCHAR(20) DEFAULT 'pending' -- pending, sent, error
);

-- Device tokens table
CREATE TABLE IF NOT EXISTS device_tokens (
    id SERIAL PRIMARY KEY,
    user_id INTEGER, -- NULL if not authenticated
    device_token VARCHAR(255) NOT NULL,
    device_type VARCHAR(50), -- android, ios, web
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    last_active TIMESTAMP,
    UNIQUE(device_token)
);

-- Add device_token column to users table if not exists
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name='users' AND column_name='device_token'
    ) THEN
        ALTER TABLE users ADD COLUMN device_token VARCHAR(255);
    END IF;
END$$;

-- Add notification_settings to users table if not exists
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name='users' AND column_name='notification_settings'
    ) THEN
        ALTER TABLE users ADD COLUMN notification_settings JSONB DEFAULT '{"all": true, "comments": true, "solutions": true, "mentions": true, "surveys": true, "city_updates": true}';
    END IF;
END$$;

-- Add notification_read table to track read status
CREATE TABLE IF NOT EXISTS notification_read (
    id SERIAL PRIMARY KEY,
    notification_id INTEGER NOT NULL REFERENCES notifications(id) ON DELETE CASCADE,
    user_id INTEGER NOT NULL,
    read_at TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE(notification_id, user_id)
);

-- Add topic subscriptions table
CREATE TABLE IF NOT EXISTS topic_subscriptions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    topic_type VARCHAR(50) NOT NULL, -- 'city', 'category'
    topic_id INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, topic_type, topic_id)
);

-- Add indices for better query performance
CREATE INDEX IF NOT EXISTS idx_notifications_target ON notifications(target_type, target_id);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at);
CREATE INDEX IF NOT EXISTS idx_device_tokens_user ON device_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_notification_read_user ON notification_read(user_id);
CREATE INDEX IF NOT EXISTS idx_topic_subscriptions_user ON topic_subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_topic_subscriptions_topic ON topic_subscriptions(topic_type, topic_id);