// Kimlik Doğrulama API Endpointleri
const express = require('express');
const router = express.Router();
const { Pool } = require('pg');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

// PostgreSQL bağlantısı
const pool = new Pool({
  connectionString: process.env.DATABASE_URL
});

// JWT secret key - daha güvenli bir yöntemle saklanmalı
const JWT_SECRET = process.env.JWT_SECRET || 'sikayetvar_jwt_secret';
const TOKEN_EXPIRES_IN = '24h';

// Kullanıcı girişi
router.post('/login', async (req, res) => {
  try {
    const { username, password, email } = req.body;
    
    if ((!username && !email) || !password) {
      return res.status(400).json({
        status: 'error',
        message: 'Kullanıcı adı/e-posta ve şifre gereklidir'
      });
    }
    
    // Kullanıcı adı veya e-posta ile kullanıcıyı bul
    let query = 'SELECT * FROM users WHERE ';
    let params = [];
    
    if (username) {
      query += 'username = $1';
      params.push(username);
    } else {
      query += 'email = $1';
      params.push(email);
    }
    
    const result = await pool.query(query, params);
    
    if (result.rows.length === 0) {
      return res.status(401).json({
        status: 'error',
        message: 'Kullanıcı bulunamadı'
      });
    }
    
    const user = result.rows[0];
    
    // Şifre kontrolü
    const isPasswordValid = await bcrypt.compare(password, user.password);
    
    if (!isPasswordValid) {
      return res.status(401).json({
        status: 'error',
        message: 'Geçersiz şifre'
      });
    }
    
    // JWT token oluştur
    const token = jwt.sign(
      { id: user.id, username: user.username, email: user.email },
      JWT_SECRET,
      { expiresIn: TOKEN_EXPIRES_IN }
    );
    
    // Kullanıcı bilgilerini döndür (şifre hariç)
    const { password: _, ...userWithoutPassword } = user;
    
    // Son giriş zamanını güncelle
    await pool.query(
      'UPDATE users SET last_login = NOW() WHERE id = $1',
      [user.id]
    );
    
    res.json({
      status: 'success',
      message: 'Giriş başarılı',
      token: token,
      user: userWithoutPassword
    });
    
  } catch (error) {
    console.error('Login hatası:', error);
    res.status(500).json({
      status: 'error',
      message: 'Sunucu hatası oluştu',
      details: error.message
    });
  }
});

// Kullanıcı kaydı
router.post('/register', async (req, res) => {
  try {
    const { username, email, password, name, city_id, district_id } = req.body;
    
    // Zorunlu alanları kontrol et
    if (!username || !email || !password) {
      return res.status(400).json({
        status: 'error',
        message: 'Kullanıcı adı, e-posta ve şifre zorunludur'
      });
    }
    
    // Kullanıcı adı ve e-posta benzersiz olmalı
    const existingUser = await pool.query(
      'SELECT * FROM users WHERE username = $1 OR email = $2',
      [username, email]
    );
    
    if (existingUser.rows.length > 0) {
      return res.status(400).json({
        status: 'error',
        message: 'Bu kullanıcı adı veya e-posta zaten kullanılıyor'
      });
    }
    
    // Şifreyi hash'le
    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(password, saltRounds);
    
    // Kullanıcıyı oluştur
    const result = await pool.query(
      `INSERT INTO users 
       (username, email, password, name, city_id, district_id, created_at, is_verified, points, profile_image_url) 
       VALUES ($1, $2, $3, $4, $5, $6, NOW(), false, 0, '/assets/images/default_avatar.png') 
       RETURNING id, username, email, name, city_id, district_id, created_at`,
      [username, email, hashedPassword, name || username, city_id || null, district_id || null]
    );
    
    const newUser = result.rows[0];
    
    // JWT token oluştur
    const token = jwt.sign(
      { id: newUser.id, username: newUser.username, email: newUser.email },
      JWT_SECRET,
      { expiresIn: TOKEN_EXPIRES_IN }
    );
    
    res.status(201).json({
      status: 'success',
      message: 'Kullanıcı başarıyla oluşturuldu',
      token: token,
      user: newUser
    });
    
  } catch (error) {
    console.error('Kayıt hatası:', error);
    res.status(500).json({
      status: 'error',
      message: 'Sunucu hatası oluştu',
      details: error.message
    });
  }
});

// Profil bilgisi alma
router.get('/profile', verifyToken, async (req, res) => {
  try {
    const userId = req.user.id;
    
    const result = await pool.query(
      `SELECT id, username, email, name, city_id, district_id, bio, profile_image_url, 
              points, post_count, comment_count, created_at, is_verified 
       FROM users 
       WHERE id = $1`,
      [userId]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        status: 'error',
        message: 'Kullanıcı bulunamadı'
      });
    }
    
    // Şehir ve ilçe bilgilerini al
    let user = result.rows[0];
    
    if (user.city_id) {
      const cityResult = await pool.query(
        'SELECT id, name FROM cities WHERE id = $1',
        [user.city_id]
      );
      
      if (cityResult.rows.length > 0) {
        user.city = cityResult.rows[0];
      }
    }
    
    if (user.district_id) {
      const districtResult = await pool.query(
        'SELECT id, name, city_id FROM districts WHERE id = $1',
        [user.district_id]
      );
      
      if (districtResult.rows.length > 0) {
        user.district = districtResult.rows[0];
      }
    }
    
    res.json({
      status: 'success',
      user: user
    });
    
  } catch (error) {
    console.error('Profil hatası:', error);
    res.status(500).json({
      status: 'error',
      message: 'Sunucu hatası oluştu',
      details: error.message
    });
  }
});

// Profil güncelleme
router.put('/profile', verifyToken, async (req, res) => {
  try {
    const userId = req.user.id;
    const { name, email, bio, city_id, district_id, profile_image_url } = req.body;
    
    // Güncelleme verilerini hazırla
    const updates = [];
    const values = [];
    let paramCounter = 1;
    
    if (name !== undefined) {
      updates.push(`name = $${paramCounter++}`);
      values.push(name);
    }
    
    if (email !== undefined) {
      updates.push(`email = $${paramCounter++}`);
      values.push(email);
    }
    
    if (bio !== undefined) {
      updates.push(`bio = $${paramCounter++}`);
      values.push(bio);
    }
    
    if (city_id !== undefined) {
      updates.push(`city_id = $${paramCounter++}`);
      values.push(city_id);
    }
    
    if (district_id !== undefined) {
      updates.push(`district_id = $${paramCounter++}`);
      values.push(district_id);
    }
    
    if (profile_image_url !== undefined) {
      updates.push(`profile_image_url = $${paramCounter++}`);
      values.push(profile_image_url);
    }
    
    if (updates.length === 0) {
      return res.status(400).json({
        status: 'error',
        message: 'Güncellenecek bilgi sağlanmadı'
      });
    }
    
    // Güncelleme sorgusunu oluştur
    const updateQuery = `
      UPDATE users 
      SET ${updates.join(', ')}
      WHERE id = $${paramCounter}
      RETURNING id, username, email, name, city_id, district_id, bio, profile_image_url, points, created_at, is_verified
    `;
    
    values.push(userId);
    
    const result = await pool.query(updateQuery, values);
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        status: 'error',
        message: 'Kullanıcı bulunamadı'
      });
    }
    
    res.json({
      status: 'success',
      message: 'Profil başarıyla güncellendi',
      user: result.rows[0]
    });
    
  } catch (error) {
    console.error('Profil güncelleme hatası:', error);
    res.status(500).json({
      status: 'error',
      message: 'Sunucu hatası oluştu',
      details: error.message
    });
  }
});

// Şifre değiştirme
router.put('/change-password', verifyToken, async (req, res) => {
  try {
    const userId = req.user.id;
    const { current_password, new_password } = req.body;
    
    if (!current_password || !new_password) {
      return res.status(400).json({
        status: 'error',
        message: 'Mevcut şifre ve yeni şifre gereklidir'
      });
    }
    
    // Kullanıcının mevcut şifresini doğrula
    const userResult = await pool.query(
      'SELECT password FROM users WHERE id = $1',
      [userId]
    );
    
    if (userResult.rows.length === 0) {
      return res.status(404).json({
        status: 'error',
        message: 'Kullanıcı bulunamadı'
      });
    }
    
    const user = userResult.rows[0];
    const isPasswordValid = await bcrypt.compare(current_password, user.password);
    
    if (!isPasswordValid) {
      return res.status(401).json({
        status: 'error',
        message: 'Mevcut şifre geçersiz'
      });
    }
    
    // Yeni şifreyi hash'le
    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(new_password, saltRounds);
    
    // Şifreyi güncelle
    await pool.query(
      'UPDATE users SET password = $1 WHERE id = $2',
      [hashedPassword, userId]
    );
    
    res.json({
      status: 'success',
      message: 'Şifre başarıyla değiştirildi'
    });
    
  } catch (error) {
    console.error('Şifre değiştirme hatası:', error);
    res.status(500).json({
      status: 'error',
      message: 'Sunucu hatası oluştu',
      details: error.message
    });
  }
});

// JWT token doğrulama middleware'i
function verifyToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  
  if (!token) {
    return res.status(401).json({
      status: 'error',
      message: 'Yetkilendirme token\'ı gereklidir'
    });
  }
  
  jwt.verify(token, JWT_SECRET, (err, decoded) => {
    if (err) {
      return res.status(403).json({
        status: 'error',
        message: 'Geçersiz token',
        details: err.message
      });
    }
    
    req.user = decoded;
    next();
  });
}

module.exports = {
  router,
  verifyToken
};