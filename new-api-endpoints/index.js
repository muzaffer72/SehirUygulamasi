// API Entegrasyon Noktası
const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');
const dotenv = require('dotenv');

// Çevre değişkenlerini yükle
dotenv.config();

// PostgreSQL bağlantısı
const pool = new Pool({
  connectionString: process.env.DATABASE_URL
});

// Express uygulaması oluştur
const app = express();
const PORT = process.env.PORT || 9000;

// Middleware'ler
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// API Anahtarı kontrolü middleware
const apiKeyMiddleware = async (req, res, next) => {
  const apiKey = req.headers['x-api-key'] || req.query.api_key;
  
  if (!apiKey) {
    return res.status(401).json({
      status: 'error',
      message: 'API anahtarı gereklidir'
    });
  }
  
  try {
    // API anahtarını veritabanından kontrol et
    const result = await pool.query(
      'SELECT * FROM settings WHERE key = $1',
      ['api_key']
    );
    
    if (result.rows.length === 0 || result.rows[0].value !== apiKey) {
      return res.status(401).json({
        status: 'error',
        message: 'Geçersiz API anahtarı'
      });
    }
    
    next();
  } catch (error) {
    console.error('API anahtarı kontrolü hatası:', error);
    res.status(500).json({
      status: 'error',
      message: 'Sunucu hatası oluştu',
      details: error.message
    });
  }
};

// API Route'ları
const { router: authRouter } = require('./auth_api');
const postsRouter = require('./posts_api');
const commentsRouter = require('./comments_api');
const notificationsRouter = require('./notifications_api');

// Auth API endpoint'leri (auth router public)
app.use('/api/auth', authRouter);

// Diğer API endpointler için API anahtarı kontrolü
app.use(apiKeyMiddleware);

// Diğer API endpoint'leri
app.use('/api/posts', postsRouter);
app.use('/api/comments', commentsRouter);
app.use('/api/notifications', notificationsRouter);

// Ana endpoint
app.get('/', (req, res) => {
  res.json({
    status: 'success',
    message: 'ŞikayetVar API v2 çalışıyor',
    environment: process.env.NODE_ENV || 'development',
    timestamp: new Date().toISOString(),
    endpoints: [
      {
        path: '/api/auth',
        methods: ['POST', 'GET', 'PUT'],
        description: 'Kimlik doğrulama ve kullanıcı işlemleri'
      },
      {
        path: '/api/posts',
        methods: ['GET', 'POST', 'PUT', 'DELETE'],
        description: 'İçerik/şikayet yönetimi'
      },
      {
        path: '/api/comments',
        methods: ['GET', 'POST', 'PUT', 'DELETE'],
        description: 'Yorum yönetimi'
      },
      {
        path: '/api/notifications',
        methods: ['GET', 'PUT', 'DELETE'],
        description: 'Bildirim yönetimi'
      }
    ]
  });
});

// Database tabloları oluşturma/kontrol fonksiyonu
async function checkDatabaseTables() {
  const client = await pool.connect();
  
  try {
    // Transaction başlat
    await client.query('BEGIN');
    
    // Gerekli tabloları kontrol et ve yoksa oluştur
    
    // 1. Bildirim Ayarları Tablosu
    await client.query(`
      CREATE TABLE IF NOT EXISTS notification_settings (
        id SERIAL PRIMARY KEY,
        user_id INTEGER NOT NULL,
        comments_enabled BOOLEAN DEFAULT true,
        likes_enabled BOOLEAN DEFAULT true,
        mentions_enabled BOOLEAN DEFAULT true,
        replies_enabled BOOLEAN DEFAULT true,
        system_notifications_enabled BOOLEAN DEFAULT true,
        marketing_notifications_enabled BOOLEAN DEFAULT false,
        created_at TIMESTAMP DEFAULT NOW(),
        updated_at TIMESTAMP DEFAULT NOW(),
        UNIQUE(user_id)
      )
    `);
    
    // 2. Cihaz Token Tablosu
    await client.query(`
      CREATE TABLE IF NOT EXISTS device_tokens (
        id SERIAL PRIMARY KEY,
        user_id INTEGER NOT NULL,
        token TEXT NOT NULL,
        device_type VARCHAR(10) NOT NULL,
        device_name VARCHAR(100),
        created_at TIMESTAMP DEFAULT NOW(),
        last_login TIMESTAMP DEFAULT NOW(),
        UNIQUE(user_id, token)
      )
    `);
    
    // Transaction'ı tamamla
    await client.query('COMMIT');
    
    console.log('Veritabanı tabloları kontrol edildi/oluşturuldu');
  } catch (error) {
    // Hata durumunda rollback yap
    await client.query('ROLLBACK');
    console.error('Veritabanı tabloları oluşturma hatası:', error);
    throw error;
  } finally {
    client.release();
  }
}

// Sunucuyu başlat
app.listen(PORT, '0.0.0.0', async () => {
  console.log(`ŞikayetVar API v2 şu adreste çalışıyor: http://0.0.0.0:${PORT}`);
  
  try {
    // Veritabanı bağlantısını test et
    const dbResult = await pool.query('SELECT NOW()');
    console.log('PostgreSQL bağlantısı başarılı:', dbResult.rows[0].now);
    
    // Tabloları kontrol et
    await checkDatabaseTables();
  } catch (error) {
    console.error('Veritabanı bağlantı hatası:', error);
  }
});

// Hata yakalama
process.on('unhandledRejection', (reason, promise) => {
  console.error('İşlenmemiş Promise reddi:', reason);
});

process.on('uncaughtException', (error) => {
  console.error('Yakalanmamış istisna:', error);
});

module.exports = app;