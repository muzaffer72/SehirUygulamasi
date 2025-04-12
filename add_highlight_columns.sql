-- Öne Çıkar özelliği için gerekli sütunları ekleyelim
ALTER TABLE posts 
ADD COLUMN IF NOT EXISTS is_highlighted BOOLEAN DEFAULT FALSE NOT NULL,
ADD COLUMN IF NOT EXISTS highlighted_at TIMESTAMP,
ADD COLUMN IF NOT EXISTS highlight_expires_at TIMESTAMP;

-- Örnek veri: Birkaç gönderiyi öne çıkaralım
UPDATE posts
SET 
    is_highlighted = TRUE,
    highlighted_at = NOW(),
    highlight_expires_at = NOW() + INTERVAL '7 days'
WHERE
    id IN (1, 5, 10)  -- Örnek olarak bazı gönderileri seçiyoruz
    AND NOT EXISTS (SELECT 1 FROM posts WHERE is_highlighted = TRUE LIMIT 1);

-- İstatistikleri görelim
SELECT 
    COUNT(*) as total_posts,
    SUM(CASE WHEN is_highlighted THEN 1 ELSE 0 END) as highlighted_posts,
    SUM(CASE WHEN highlight_expires_at < NOW() THEN 1 ELSE 0 END) as expired_highlights
FROM posts;