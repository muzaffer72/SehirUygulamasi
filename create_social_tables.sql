-- Kullanıcı beğenileri tablosunu oluştur
CREATE TABLE IF NOT EXISTS user_likes (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  post_id INTEGER REFERENCES posts(id) ON DELETE CASCADE,
  comment_id INTEGER REFERENCES comments(id) ON DELETE CASCADE,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Bildirimler tablosunu oluştur
CREATE TABLE IF NOT EXISTS notifications (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  content TEXT NOT NULL,
  type VARCHAR(50) NOT NULL,
  is_read BOOLEAN NOT NULL DEFAULT FALSE,
  source_id INTEGER,
  source_type VARCHAR(50),
  data TEXT,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Dizin ekleyelim
CREATE INDEX IF NOT EXISTS user_likes_user_id_idx ON user_likes(user_id);
CREATE INDEX IF NOT EXISTS user_likes_post_id_idx ON user_likes(post_id);
CREATE INDEX IF NOT EXISTS user_likes_comment_id_idx ON user_likes(comment_id);

CREATE INDEX IF NOT EXISTS notifications_user_id_idx ON notifications(user_id);
CREATE INDEX IF NOT EXISTS notifications_is_read_idx ON notifications(is_read);