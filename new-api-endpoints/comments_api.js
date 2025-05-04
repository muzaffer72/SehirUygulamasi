// Yorum API Endpointleri
const express = require('express');
const router = express.Router();
const { Pool } = require('pg');
const { verifyToken } = require('./auth_api');

// PostgreSQL bağlantısı
const pool = new Pool({
  connectionString: process.env.DATABASE_URL
});

// Bir gönderinin yorumlarını listele
router.get('/post/:postId', async (req, res) => {
  try {
    const postId = req.params.postId;
    const { page = 1, limit = 10 } = req.query;
    
    // Sayfalama için offset hesapla
    const offset = (page - 1) * limit;
    
    // Yorumları al
    const commentsQuery = `
      SELECT c.*, 
             u.username, u.name as user_name, u.profile_image_url
      FROM comments c
      JOIN users u ON c.user_id = u.id
      WHERE c.post_id = $1
      ORDER BY c.created_at DESC
      LIMIT $2 OFFSET $3
    `;
    
    const commentsResult = await pool.query(commentsQuery, [postId, limit, offset]);
    
    // Toplam yorum sayısını al
    const countQuery = `
      SELECT COUNT(*) as total FROM comments WHERE post_id = $1
    `;
    
    const countResult = await pool.query(countQuery, [postId]);
    const totalCount = parseInt(countResult.rows[0].total);
    const totalPages = Math.ceil(totalCount / limit);
    
    res.json({
      status: 'success',
      data: {
        comments: commentsResult.rows,
        pagination: {
          total: totalCount,
          page: parseInt(page),
          limit: parseInt(limit),
          total_pages: totalPages
        }
      }
    });
    
  } catch (error) {
    console.error('Yorum listesi hatası:', error);
    res.status(500).json({
      status: 'error',
      message: 'Sunucu hatası oluştu',
      details: error.message
    });
  }
});

// Yeni yorum ekle
router.post('/', verifyToken, async (req, res) => {
  const client = await pool.connect();
  
  try {
    const { post_id, content, parent_comment_id } = req.body;
    const userId = req.user.id;
    
    // Zorunlu alanları kontrol et
    if (!post_id || !content) {
      return res.status(400).json({
        status: 'error',
        message: 'Gönderi ID ve içerik zorunludur'
      });
    }
    
    // Gönderiyi kontrol et
    const postCheck = await client.query(
      'SELECT * FROM posts WHERE id = $1',
      [post_id]
    );
    
    if (postCheck.rows.length === 0) {
      return res.status(404).json({
        status: 'error',
        message: 'Gönderi bulunamadı'
      });
    }
    
    // Üst yorumu kontrol et (eğer belirtilmişse)
    if (parent_comment_id) {
      const parentCheck = await client.query(
        'SELECT * FROM comments WHERE id = $1 AND post_id = $2',
        [parent_comment_id, post_id]
      );
      
      if (parentCheck.rows.length === 0) {
        return res.status(404).json({
          status: 'error',
          message: 'Belirtilen üst yorum bulunamadı'
        });
      }
    }
    
    // Transaction başlat
    await client.query('BEGIN');
    
    // Yorumu ekle
    const commentResult = await client.query(
      `INSERT INTO comments 
       (post_id, user_id, content, parent_comment_id, created_at, status) 
       VALUES ($1, $2, $3, $4, NOW(), 'active') 
       RETURNING *`,
      [post_id, userId, content, parent_comment_id || null]
    );
    
    const newComment = commentResult.rows[0];
    
    // Kullanıcı bilgilerini ekle
    const userResult = await client.query(
      'SELECT username, name, profile_image_url FROM users WHERE id = $1',
      [userId]
    );
    
    if (userResult.rows.length > 0) {
      newComment.username = userResult.rows[0].username;
      newComment.user_name = userResult.rows[0].name;
      newComment.profile_image_url = userResult.rows[0].profile_image_url;
    }
    
    // Kullanıcının comment_count alanını güncelle
    await client.query(
      'UPDATE users SET comment_count = comment_count + 1 WHERE id = $1',
      [userId]
    );
    
    // Transaction'ı tamamla
    await client.query('COMMIT');
    
    res.status(201).json({
      status: 'success',
      message: 'Yorum başarıyla eklendi',
      data: newComment
    });
    
  } catch (error) {
    // Hata durumunda rollback yap
    await client.query('ROLLBACK');
    
    console.error('Yorum ekleme hatası:', error);
    res.status(500).json({
      status: 'error',
      message: 'Sunucu hatası oluştu',
      details: error.message
    });
  } finally {
    client.release();
  }
});

// Yorumu düzenle
router.put('/:id', verifyToken, async (req, res) => {
  try {
    const commentId = req.params.id;
    const { content } = req.body;
    const userId = req.user.id;
    
    // İçerik kontrolü
    if (!content) {
      return res.status(400).json({
        status: 'error',
        message: 'İçerik boş olamaz'
      });
    }
    
    // Yorumu kontrol et
    const commentCheck = await pool.query(
      'SELECT * FROM comments WHERE id = $1',
      [commentId]
    );
    
    if (commentCheck.rows.length === 0) {
      return res.status(404).json({
        status: 'error',
        message: 'Yorum bulunamadı'
      });
    }
    
    const comment = commentCheck.rows[0];
    
    // Yetki kontrolü
    if (comment.user_id !== userId) {
      return res.status(403).json({
        status: 'error',
        message: 'Bu yorumu düzenleme yetkiniz yok'
      });
    }
    
    // Yorumu güncelle
    const updateResult = await pool.query(
      `UPDATE comments 
       SET content = $1, updated_at = NOW(), is_edited = true
       WHERE id = $2 
       RETURNING *`,
      [content, commentId]
    );
    
    // Kullanıcı bilgilerini ekle
    const userResult = await pool.query(
      'SELECT username, name, profile_image_url FROM users WHERE id = $1',
      [userId]
    );
    
    const updatedComment = updateResult.rows[0];
    
    if (userResult.rows.length > 0) {
      updatedComment.username = userResult.rows[0].username;
      updatedComment.user_name = userResult.rows[0].name;
      updatedComment.profile_image_url = userResult.rows[0].profile_image_url;
    }
    
    res.json({
      status: 'success',
      message: 'Yorum başarıyla güncellendi',
      data: updatedComment
    });
    
  } catch (error) {
    console.error('Yorum güncelleme hatası:', error);
    res.status(500).json({
      status: 'error',
      message: 'Sunucu hatası oluştu',
      details: error.message
    });
  }
});

// Yorumu sil
router.delete('/:id', verifyToken, async (req, res) => {
  const client = await pool.connect();
  
  try {
    const commentId = req.params.id;
    const userId = req.user.id;
    
    // Yorumu kontrol et
    const commentCheck = await client.query(
      'SELECT * FROM comments WHERE id = $1',
      [commentId]
    );
    
    if (commentCheck.rows.length === 0) {
      return res.status(404).json({
        status: 'error',
        message: 'Yorum bulunamadı'
      });
    }
    
    const comment = commentCheck.rows[0];
    
    // Yetki kontrolü
    if (comment.user_id !== userId) {
      return res.status(403).json({
        status: 'error',
        message: 'Bu yorumu silme yetkiniz yok'
      });
    }
    
    // Transaction başlat
    await client.query('BEGIN');
    
    // Alt yorumları kontrol et
    const childCheck = await client.query(
      'SELECT COUNT(*) as count FROM comments WHERE parent_comment_id = $1',
      [commentId]
    );
    
    const hasChildren = parseInt(childCheck.rows[0].count) > 0;
    
    if (hasChildren) {
      // Alt yorumlar varsa içeriği anonymize et ve durumunu pasif yap
      await client.query(
        `UPDATE comments 
         SET content = '[Bu yorum silindi]', status = 'deleted', updated_at = NOW() 
         WHERE id = $1`,
        [commentId]
      );
    } else {
      // Alt yorum yoksa tamamen sil
      await client.query('DELETE FROM comments WHERE id = $1', [commentId]);
      
      // Kullanıcının comment_count alanını güncelle
      await client.query(
        'UPDATE users SET comment_count = comment_count - 1 WHERE id = $1',
        [userId]
      );
    }
    
    // Transaction'ı tamamla
    await client.query('COMMIT');
    
    res.json({
      status: 'success',
      message: hasChildren 
        ? 'Yorum içeriği silindi (alt yorumlar korundu)' 
        : 'Yorum tamamen silindi'
    });
    
  } catch (error) {
    // Hata durumunda rollback yap
    await client.query('ROLLBACK');
    
    console.error('Yorum silme hatası:', error);
    res.status(500).json({
      status: 'error',
      message: 'Sunucu hatası oluştu',
      details: error.message
    });
  } finally {
    client.release();
  }
});

module.exports = router;