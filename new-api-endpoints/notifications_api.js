// Bildirim API Endpointleri
const express = require('express');
const router = express.Router();
const { Pool } = require('pg');
const { verifyToken } = require('./auth_api');

// PostgreSQL bağlantısı
const pool = new Pool({
  connectionString: process.env.DATABASE_URL
});

// Cihaz kayıt - FCM token kaydetme (bildirimler için)
router.post('/device/register', verifyToken, async (req, res) => {
  try {
    const userId = req.user.id;
    const { token, device_type, device_name } = req.body;
    
    // Token kontrolü
    if (!token) {
      return res.status(400).json({
        status: 'error',
        message: 'FCM token gereklidir'
      });
    }
    
    // Device_type kontrolü
    if (!device_type || !['android', 'ios', 'web'].includes(device_type)) {
      return res.status(400).json({
        status: 'error',
        message: 'Geçerli bir cihaz türü gereklidir (android, ios, web)'
      });
    }
    
    // Önceki kaydı kontrol et
    const checkResult = await pool.query(
      'SELECT * FROM device_tokens WHERE user_id = $1 AND token = $2',
      [userId, token]
    );
    
    if (checkResult.rows.length > 0) {
      // Mevcut kaydı güncelle
      await pool.query(
        `UPDATE device_tokens 
         SET last_login = NOW(), device_name = $1
         WHERE user_id = $2 AND token = $3`,
        [device_name || 'Unknown Device', userId, token]
      );
      
      return res.json({
        status: 'success',
        message: 'Cihaz kaydı güncellendi',
        token_id: checkResult.rows[0].id
      });
    }
    
    // Yeni kayıt ekle
    const insertResult = await pool.query(
      `INSERT INTO device_tokens 
       (user_id, token, device_type, device_name, created_at, last_login) 
       VALUES ($1, $2, $3, $4, NOW(), NOW()) 
       RETURNING id`,
      [userId, token, device_type, device_name || 'Unknown Device']
    );
    
    res.status(201).json({
      status: 'success',
      message: 'Cihaz başarıyla kaydedildi',
      token_id: insertResult.rows[0].id
    });
    
  } catch (error) {
    console.error('Cihaz kayıt hatası:', error);
    res.status(500).json({
      status: 'error',
      message: 'Sunucu hatası oluştu',
      details: error.message
    });
  }
});

// Bildirimleri listele
router.get('/', verifyToken, async (req, res) => {
  try {
    const userId = req.user.id;
    const { page = 1, limit = 20 } = req.query;
    
    // Sayfalama için offset hesapla
    const offset = (page - 1) * limit;
    
    // Bildirimleri al
    const notificationsQuery = `
      SELECT * FROM notifications 
      WHERE user_id = $1 
      ORDER BY created_at DESC
      LIMIT $2 OFFSET $3
    `;
    
    const notificationsResult = await pool.query(notificationsQuery, [userId, limit, offset]);
    
    // Toplam sayıyı al
    const countQuery = `
      SELECT COUNT(*) as total FROM notifications WHERE user_id = $1
    `;
    
    const countResult = await pool.query(countQuery, [userId]);
    const totalCount = parseInt(countResult.rows[0].total);
    const totalPages = Math.ceil(totalCount / limit);
    
    // Okunmamış bildirim sayısını al
    const unreadQuery = `
      SELECT COUNT(*) as count FROM notifications 
      WHERE user_id = $1 AND is_read = false
    `;
    
    const unreadResult = await pool.query(unreadQuery, [userId]);
    const unreadCount = parseInt(unreadResult.rows[0].count);
    
    res.json({
      status: 'success',
      data: {
        notifications: notificationsResult.rows,
        unread_count: unreadCount,
        pagination: {
          total: totalCount,
          page: parseInt(page),
          limit: parseInt(limit),
          total_pages: totalPages
        }
      }
    });
    
  } catch (error) {
    console.error('Bildirim listesi hatası:', error);
    res.status(500).json({
      status: 'error',
      message: 'Sunucu hatası oluştu',
      details: error.message
    });
  }
});

// Okunmamış bildirim sayısını al
router.get('/unread-count', verifyToken, async (req, res) => {
  try {
    const userId = req.user.id;
    
    const query = `
      SELECT COUNT(*) as count FROM notifications 
      WHERE user_id = $1 AND is_read = false
    `;
    
    const result = await pool.query(query, [userId]);
    const count = parseInt(result.rows[0].count);
    
    res.json({
      status: 'success',
      unread_count: count
    });
    
  } catch (error) {
    console.error('Bildirim sayısı hatası:', error);
    res.status(500).json({
      status: 'error',
      message: 'Sunucu hatası oluştu',
      details: error.message
    });
  }
});

// Bildirimi okundu olarak işaretle
router.put('/:id/mark-read', verifyToken, async (req, res) => {
  try {
    const notificationId = req.params.id;
    const userId = req.user.id;
    
    // Bildirimi kontrol et ve güncelle
    const result = await pool.query(
      `UPDATE notifications 
       SET is_read = true 
       WHERE id = $1 AND user_id = $2 
       RETURNING *`,
      [notificationId, userId]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        status: 'error',
        message: 'Bildirim bulunamadı veya erişim izniniz yok'
      });
    }
    
    res.json({
      status: 'success',
      message: 'Bildirim okundu olarak işaretlendi',
      notification: result.rows[0]
    });
    
  } catch (error) {
    console.error('Bildirim işaretleme hatası:', error);
    res.status(500).json({
      status: 'error',
      message: 'Sunucu hatası oluştu',
      details: error.message
    });
  }
});

// Tüm bildirimleri okundu olarak işaretle
router.put('/mark-all-read', verifyToken, async (req, res) => {
  try {
    const userId = req.user.id;
    
    const result = await pool.query(
      `UPDATE notifications 
       SET is_read = true 
       WHERE user_id = $1 AND is_read = false 
       RETURNING id`,
      [userId]
    );
    
    const updatedCount = result.rows.length;
    
    res.json({
      status: 'success',
      message: `${updatedCount} bildirim okundu olarak işaretlendi`,
      updated_count: updatedCount
    });
    
  } catch (error) {
    console.error('Toplu bildirim işaretleme hatası:', error);
    res.status(500).json({
      status: 'error',
      message: 'Sunucu hatası oluştu',
      details: error.message
    });
  }
});

// Bildirimi sil
router.delete('/:id', verifyToken, async (req, res) => {
  try {
    const notificationId = req.params.id;
    const userId = req.user.id;
    
    const result = await pool.query(
      'DELETE FROM notifications WHERE id = $1 AND user_id = $2 RETURNING id',
      [notificationId, userId]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        status: 'error',
        message: 'Bildirim bulunamadı veya erişim izniniz yok'
      });
    }
    
    res.json({
      status: 'success',
      message: 'Bildirim başarıyla silindi'
    });
    
  } catch (error) {
    console.error('Bildirim silme hatası:', error);
    res.status(500).json({
      status: 'error',
      message: 'Sunucu hatası oluştu',
      details: error.message
    });
  }
});

// Tüm bildirimleri sil
router.delete('/all', verifyToken, async (req, res) => {
  try {
    const userId = req.user.id;
    
    const result = await pool.query(
      'DELETE FROM notifications WHERE user_id = $1 RETURNING id',
      [userId]
    );
    
    const deletedCount = result.rows.length;
    
    res.json({
      status: 'success',
      message: `${deletedCount} bildirim başarıyla silindi`,
      deleted_count: deletedCount
    });
    
  } catch (error) {
    console.error('Toplu bildirim silme hatası:', error);
    res.status(500).json({
      status: 'error',
      message: 'Sunucu hatası oluştu',
      details: error.message
    });
  }
});

// Bildirim ayarlarını getir
router.get('/settings', verifyToken, async (req, res) => {
  try {
    const userId = req.user.id;
    
    const query = `
      SELECT * FROM notification_settings WHERE user_id = $1
    `;
    
    const result = await pool.query(query, [userId]);
    
    // Eğer ayarlar yoksa varsayılan oluştur
    if (result.rows.length === 0) {
      const defaultSettings = {
        user_id: userId,
        comments_enabled: true,
        likes_enabled: true,
        mentions_enabled: true,
        replies_enabled: true,
        system_notifications_enabled: true,
        marketing_notifications_enabled: false
      };
      
      const insertResult = await pool.query(
        `INSERT INTO notification_settings 
         (user_id, comments_enabled, likes_enabled, mentions_enabled, replies_enabled, 
          system_notifications_enabled, marketing_notifications_enabled, created_at, updated_at) 
         VALUES ($1, $2, $3, $4, $5, $6, $7, NOW(), NOW()) 
         RETURNING *`,
        [
          defaultSettings.user_id,
          defaultSettings.comments_enabled,
          defaultSettings.likes_enabled,
          defaultSettings.mentions_enabled,
          defaultSettings.replies_enabled,
          defaultSettings.system_notifications_enabled,
          defaultSettings.marketing_notifications_enabled
        ]
      );
      
      return res.json({
        status: 'success',
        settings: insertResult.rows[0]
      });
    }
    
    res.json({
      status: 'success',
      settings: result.rows[0]
    });
    
  } catch (error) {
    console.error('Bildirim ayarları hatası:', error);
    res.status(500).json({
      status: 'error',
      message: 'Sunucu hatası oluştu',
      details: error.message
    });
  }
});

// Bildirim ayarlarını güncelle
router.put('/settings', verifyToken, async (req, res) => {
  try {
    const userId = req.user.id;
    const { 
      comments_enabled, 
      likes_enabled, 
      mentions_enabled, 
      replies_enabled, 
      system_notifications_enabled, 
      marketing_notifications_enabled 
    } = req.body;
    
    // Ayarları kontrol et
    const checkResult = await pool.query(
      'SELECT * FROM notification_settings WHERE user_id = $1',
      [userId]
    );
    
    if (checkResult.rows.length === 0) {
      // Ayarlar yoksa yeni oluştur
      const insertResult = await pool.query(
        `INSERT INTO notification_settings 
         (user_id, comments_enabled, likes_enabled, mentions_enabled, replies_enabled, 
          system_notifications_enabled, marketing_notifications_enabled, created_at, updated_at) 
         VALUES ($1, $2, $3, $4, $5, $6, $7, NOW(), NOW()) 
         RETURNING *`,
        [
          userId,
          comments_enabled !== undefined ? comments_enabled : true,
          likes_enabled !== undefined ? likes_enabled : true,
          mentions_enabled !== undefined ? mentions_enabled : true,
          replies_enabled !== undefined ? replies_enabled : true,
          system_notifications_enabled !== undefined ? system_notifications_enabled : true,
          marketing_notifications_enabled !== undefined ? marketing_notifications_enabled : false
        ]
      );
      
      return res.json({
        status: 'success',
        message: 'Bildirim ayarları oluşturuldu',
        settings: insertResult.rows[0]
      });
    }
    
    // Güncelleme verilerini hazırla
    const updates = [];
    const values = [];
    let paramCounter = 1;
    
    if (comments_enabled !== undefined) {
      updates.push(`comments_enabled = $${paramCounter++}`);
      values.push(comments_enabled);
    }
    
    if (likes_enabled !== undefined) {
      updates.push(`likes_enabled = $${paramCounter++}`);
      values.push(likes_enabled);
    }
    
    if (mentions_enabled !== undefined) {
      updates.push(`mentions_enabled = $${paramCounter++}`);
      values.push(mentions_enabled);
    }
    
    if (replies_enabled !== undefined) {
      updates.push(`replies_enabled = $${paramCounter++}`);
      values.push(replies_enabled);
    }
    
    if (system_notifications_enabled !== undefined) {
      updates.push(`system_notifications_enabled = $${paramCounter++}`);
      values.push(system_notifications_enabled);
    }
    
    if (marketing_notifications_enabled !== undefined) {
      updates.push(`marketing_notifications_enabled = $${paramCounter++}`);
      values.push(marketing_notifications_enabled);
    }
    
    if (updates.length === 0) {
      return res.status(400).json({
        status: 'error',
        message: 'Güncellenecek ayar sağlanmadı'
      });
    }
    
    updates.push(`updated_at = NOW()`);
    
    // Ayarları güncelle
    values.push(userId);
    const updateResult = await pool.query(
      `UPDATE notification_settings 
       SET ${updates.join(', ')}
       WHERE user_id = $${paramCounter}
       RETURNING *`,
      values
    );
    
    res.json({
      status: 'success',
      message: 'Bildirim ayarları güncellendi',
      settings: updateResult.rows[0]
    });
    
  } catch (error) {
    console.error('Bildirim ayarları güncelleme hatası:', error);
    res.status(500).json({
      status: 'error',
      message: 'Sunucu hatası oluştu',
      details: error.message
    });
  }
});

module.exports = router;