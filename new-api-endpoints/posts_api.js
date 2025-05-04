// İçerik (Şikayet) API Endpointleri
const express = require('express');
const router = express.Router();
const { Pool } = require('pg');
const { verifyToken } = require('./auth_api');

// PostgreSQL bağlantısı
const pool = new Pool({
  connectionString: process.env.DATABASE_URL
});

// Tüm gönderileri listele (filtreleme destekli)
router.get('/', async (req, res) => {
  try {
    const { 
      category_id, 
      city_id, 
      district_id, 
      user_id, 
      page = 1, 
      limit = 10,
      sort_by = 'created_at',
      sort_order = 'desc'
    } = req.query;
    
    // Sayfalama için offset hesapla
    const offset = (page - 1) * limit;
    
    // SQL sorgusu ve parametreleri hazırla
    let query = `
      SELECT p.*, 
             u.username, u.name as user_name, u.profile_image_url,
             c.name as city_name, d.name as district_name,
             cat.name as category_name,
             COUNT(DISTINCT com.id) as comment_count,
             COUNT(DISTINCT ul.id) as like_count
      FROM posts p
      LEFT JOIN users u ON p.user_id = u.id
      LEFT JOIN cities c ON p.city_id = c.id
      LEFT JOIN districts d ON p.district_id = d.id
      LEFT JOIN categories cat ON p.category_id = cat.id
      LEFT JOIN comments com ON p.id = com.post_id
      LEFT JOIN user_likes ul ON p.id = ul.post_id
    `;
    
    const whereConditions = [];
    const params = [];
    let paramCounter = 1;
    
    if (category_id) {
      whereConditions.push(`p.category_id = $${paramCounter++}`);
      params.push(category_id);
    }
    
    if (city_id) {
      whereConditions.push(`p.city_id = $${paramCounter++}`);
      params.push(city_id);
    }
    
    if (district_id) {
      whereConditions.push(`p.district_id = $${paramCounter++}`);
      params.push(district_id);
    }
    
    if (user_id) {
      whereConditions.push(`p.user_id = $${paramCounter++}`);
      params.push(user_id);
    }
    
    if (whereConditions.length > 0) {
      query += ` WHERE ${whereConditions.join(' AND ')}`;
    }
    
    // Grup ve sıralama
    query += `
      GROUP BY p.id, u.username, u.name, u.profile_image_url, c.name, d.name, cat.name
      ORDER BY p.${sort_by} ${sort_order === 'asc' ? 'ASC' : 'DESC'}
      LIMIT $${paramCounter++} OFFSET $${paramCounter++}
    `;
    
    params.push(parseInt(limit), parseInt(offset));
    
    // Toplam sayı için sorgu
    let countQuery = `
      SELECT COUNT(*) FROM posts p
    `;
    
    if (whereConditions.length > 0) {
      countQuery += ` WHERE ${whereConditions.join(' AND ')}`;
    }
    
    // Sorguları çalıştır
    const [postsResult, countResult] = await Promise.all([
      pool.query(query, params),
      pool.query(countQuery, params.slice(0, paramCounter - 3)) // Limit ve offset parametrelerini çıkar
    ]);
    
    const posts = postsResult.rows;
    const totalCount = parseInt(countResult.rows[0].count);
    const totalPages = Math.ceil(totalCount / limit);
    
    res.json({
      status: 'success',
      data: {
        posts,
        pagination: {
          total: totalCount,
          page: parseInt(page),
          limit: parseInt(limit),
          total_pages: totalPages
        }
      }
    });
    
  } catch (error) {
    console.error('Gönderi listesi hatası:', error);
    res.status(500).json({
      status: 'error',
      message: 'Sunucu hatası oluştu',
      details: error.message
    });
  }
});

// Tek bir gönderiyi getir
router.get('/:id', async (req, res) => {
  try {
    const postId = req.params.id;
    
    // Gönderi detaylarını al
    const postQuery = `
      SELECT p.*, 
             u.username, u.name as user_name, u.profile_image_url,
             c.name as city_name, d.name as district_name,
             cat.name as category_name
      FROM posts p
      LEFT JOIN users u ON p.user_id = u.id
      LEFT JOIN cities c ON p.city_id = c.id
      LEFT JOIN districts d ON p.district_id = d.id
      LEFT JOIN categories cat ON p.category_id = cat.id
      WHERE p.id = $1
    `;
    
    const postResult = await pool.query(postQuery, [postId]);
    
    if (postResult.rows.length === 0) {
      return res.status(404).json({
        status: 'error',
        message: 'Gönderi bulunamadı'
      });
    }
    
    const post = postResult.rows[0];
    
    // Görselleri al
    const mediaQuery = `
      SELECT * FROM media WHERE post_id = $1
    `;
    
    const mediaResult = await pool.query(mediaQuery, [postId]);
    post.media = mediaResult.rows;
    
    // Yorumları al
    const commentsQuery = `
      SELECT c.*, u.username, u.name as user_name, u.profile_image_url
      FROM comments c
      JOIN users u ON c.user_id = u.id
      WHERE c.post_id = $1
      ORDER BY c.created_at DESC
    `;
    
    const commentsResult = await pool.query(commentsQuery, [postId]);
    post.comments = commentsResult.rows;
    
    // Beğeni sayısını al
    const likesQuery = `
      SELECT COUNT(*) as like_count FROM user_likes WHERE post_id = $1
    `;
    
    const likesResult = await pool.query(likesQuery, [postId]);
    post.like_count = parseInt(likesResult.rows[0].like_count);
    
    // Görüntülenme sayısını artır
    await pool.query(
      'UPDATE posts SET view_count = view_count + 1 WHERE id = $1',
      [postId]
    );
    
    res.json({
      status: 'success',
      data: post
    });
    
  } catch (error) {
    console.error('Gönderi detayı hatası:', error);
    res.status(500).json({
      status: 'error',
      message: 'Sunucu hatası oluştu',
      details: error.message
    });
  }
});

// Yeni gönderi oluştur
router.post('/', verifyToken, async (req, res) => {
  const client = await pool.connect();
  
  try {
    const { title, content, category_id, city_id, district_id, latitude, longitude, media_urls } = req.body;
    const userId = req.user.id;
    
    // Zorunlu alanları kontrol et
    if (!title || !content || !category_id || !city_id) {
      return res.status(400).json({
        status: 'error',
        message: 'Başlık, içerik, kategori ve şehir zorunludur'
      });
    }
    
    // Transaction başlat
    await client.query('BEGIN');
    
    // Gönderiyi oluştur
    const postResult = await client.query(
      `INSERT INTO posts 
       (title, content, user_id, category_id, city_id, district_id, latitude, longitude, created_at, updated_at, status, view_count) 
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, NOW(), NOW(), 'active', 0) 
       RETURNING *`,
      [title, content, userId, category_id, city_id, district_id, latitude || null, longitude || null]
    );
    
    const newPost = postResult.rows[0];
    
    // Medya dosyalarını ekle (eğer varsa)
    if (media_urls && Array.isArray(media_urls) && media_urls.length > 0) {
      const mediaPromises = media_urls.map(url => {
        return client.query(
          `INSERT INTO media 
           (post_id, user_id, url, type, created_at) 
           VALUES ($1, $2, $3, $4, NOW()) 
           RETURNING *`,
          [newPost.id, userId, url, url.match(/\.(jpg|jpeg|png|gif)$/i) ? 'image' : 'other']
        );
      });
      
      const mediaResults = await Promise.all(mediaPromises);
      newPost.media = mediaResults.map(result => result.rows[0]);
    }
    
    // Kullanıcının post_count alanını güncelle
    await client.query(
      'UPDATE users SET post_count = post_count + 1 WHERE id = $1',
      [userId]
    );
    
    // Transaction'ı tamamla
    await client.query('COMMIT');
    
    res.status(201).json({
      status: 'success',
      message: 'Gönderi başarıyla oluşturuldu',
      data: newPost
    });
    
  } catch (error) {
    // Hata durumunda rollback yap
    await client.query('ROLLBACK');
    
    console.error('Gönderi oluşturma hatası:', error);
    res.status(500).json({
      status: 'error',
      message: 'Sunucu hatası oluştu',
      details: error.message
    });
  } finally {
    client.release();
  }
});

// Gönderiyi güncelle
router.put('/:id', verifyToken, async (req, res) => {
  const client = await pool.connect();
  
  try {
    const postId = req.params.id;
    const userId = req.user.id;
    const { title, content, category_id, status } = req.body;
    
    // Gönderiyi kontrol et
    const checkResult = await client.query(
      'SELECT * FROM posts WHERE id = $1',
      [postId]
    );
    
    if (checkResult.rows.length === 0) {
      return res.status(404).json({
        status: 'error',
        message: 'Gönderi bulunamadı'
      });
    }
    
    const post = checkResult.rows[0];
    
    // Yetki kontrolü
    if (post.user_id !== userId) {
      return res.status(403).json({
        status: 'error',
        message: 'Bu gönderiyi düzenleme yetkiniz yok'
      });
    }
    
    // Güncelleme verilerini hazırla
    const updates = [];
    const values = [];
    let paramCounter = 1;
    
    if (title !== undefined) {
      updates.push(`title = $${paramCounter++}`);
      values.push(title);
    }
    
    if (content !== undefined) {
      updates.push(`content = $${paramCounter++}`);
      values.push(content);
    }
    
    if (category_id !== undefined) {
      updates.push(`category_id = $${paramCounter++}`);
      values.push(category_id);
    }
    
    if (status !== undefined) {
      updates.push(`status = $${paramCounter++}`);
      values.push(status);
    }
    
    updates.push(`updated_at = NOW()`);
    
    // Güncellenecek bir şey yoksa hata döndür
    if (updates.length === 1) { // Sadece updated_at varsa
      return res.status(400).json({
        status: 'error',
        message: 'Güncellenecek veri sağlanmadı'
      });
    }
    
    // Transaction başlat
    await client.query('BEGIN');
    
    // Gönderiyi güncelle
    values.push(postId); // son parametre olarak post ID'yi ekle
    const updateResult = await client.query(
      `UPDATE posts 
       SET ${updates.join(', ')}
       WHERE id = $${paramCounter}
       RETURNING *`,
      values
    );
    
    // Transaction'ı tamamla
    await client.query('COMMIT');
    
    res.json({
      status: 'success',
      message: 'Gönderi başarıyla güncellendi',
      data: updateResult.rows[0]
    });
    
  } catch (error) {
    // Hata durumunda rollback yap
    await client.query('ROLLBACK');
    
    console.error('Gönderi güncelleme hatası:', error);
    res.status(500).json({
      status: 'error',
      message: 'Sunucu hatası oluştu',
      details: error.message
    });
  } finally {
    client.release();
  }
});

// Gönderiyi sil
router.delete('/:id', verifyToken, async (req, res) => {
  const client = await pool.connect();
  
  try {
    const postId = req.params.id;
    const userId = req.user.id;
    
    // Gönderiyi kontrol et
    const checkResult = await client.query(
      'SELECT * FROM posts WHERE id = $1',
      [postId]
    );
    
    if (checkResult.rows.length === 0) {
      return res.status(404).json({
        status: 'error',
        message: 'Gönderi bulunamadı'
      });
    }
    
    const post = checkResult.rows[0];
    
    // Yetki kontrolü (kullanıcının kendi gönderisi mi?)
    if (post.user_id !== userId) {
      return res.status(403).json({
        status: 'error',
        message: 'Bu gönderiyi silme yetkiniz yok'
      });
    }
    
    // Transaction başlat
    await client.query('BEGIN');
    
    // İlişkili medya dosyalarını sil
    await client.query('DELETE FROM media WHERE post_id = $1', [postId]);
    
    // İlişkili yorumları sil
    await client.query('DELETE FROM comments WHERE post_id = $1', [postId]);
    
    // İlişkili beğenileri sil
    await client.query('DELETE FROM user_likes WHERE post_id = $1', [postId]);
    
    // Gönderiyi sil
    await client.query('DELETE FROM posts WHERE id = $1', [postId]);
    
    // Kullanıcının post_count alanını güncelle
    await client.query(
      'UPDATE users SET post_count = post_count - 1 WHERE id = $1',
      [userId]
    );
    
    // Transaction'ı tamamla
    await client.query('COMMIT');
    
    res.json({
      status: 'success',
      message: 'Gönderi ve ilişkili tüm veriler başarıyla silindi'
    });
    
  } catch (error) {
    // Hata durumunda rollback yap
    await client.query('ROLLBACK');
    
    console.error('Gönderi silme hatası:', error);
    res.status(500).json({
      status: 'error',
      message: 'Sunucu hatası oluştu',
      details: error.message
    });
  } finally {
    client.release();
  }
});

// Gönderiyi beğen/beğeniyi kaldır
router.post('/:id/like', verifyToken, async (req, res) => {
  try {
    const postId = req.params.id;
    const userId = req.user.id;
    
    // Gönderiyi kontrol et
    const postCheck = await pool.query(
      'SELECT * FROM posts WHERE id = $1',
      [postId]
    );
    
    if (postCheck.rows.length === 0) {
      return res.status(404).json({
        status: 'error',
        message: 'Gönderi bulunamadı'
      });
    }
    
    // Mevcut beğeniyi kontrol et
    const likeCheck = await pool.query(
      'SELECT * FROM user_likes WHERE post_id = $1 AND user_id = $2',
      [postId, userId]
    );
    
    // Eğer beğeni varsa kaldır, yoksa ekle
    if (likeCheck.rows.length > 0) {
      await pool.query(
        'DELETE FROM user_likes WHERE post_id = $1 AND user_id = $2',
        [postId, userId]
      );
      
      res.json({
        status: 'success',
        message: 'Beğeni kaldırıldı',
        liked: false
      });
    } else {
      await pool.query(
        'INSERT INTO user_likes (post_id, user_id, created_at) VALUES ($1, $2, NOW())',
        [postId, userId]
      );
      
      res.json({
        status: 'success',
        message: 'Gönderi beğenildi',
        liked: true
      });
    }
    
  } catch (error) {
    console.error('Beğeni hatası:', error);
    res.status(500).json({
      status: 'error',
      message: 'Sunucu hatası oluştu',
      details: error.message
    });
  }
});

module.exports = router;