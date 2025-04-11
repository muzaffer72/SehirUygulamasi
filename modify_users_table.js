const { Pool } = require('pg');
require('dotenv').config();

// PostgreSQL veritabanı bağlantısı
if (!process.env.DATABASE_URL) {
  throw new Error("DATABASE_URL must be set. Did you forget to provision a database?");
}

// Replit'ten gelen PostgreSQL bağlantı bilgileri kullanılıyor
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: {
    rejectUnauthorized: false
  }
});

async function addUsernameColumn() {
  try {
    console.log('Veritabanında users tablosuna username sütunu ekleniyor...');

    // Username sütunu ekle
    await pool.query(`
      ALTER TABLE users 
      ADD COLUMN IF NOT EXISTS username VARCHAR(100)
    `);
    
    console.log('Username sütunu başarıyla eklendi!');
    
    // Email değerlerini username olarak ayarla
    await pool.query(`
      UPDATE users 
      SET username = email 
      WHERE username IS NULL
    `);
    
    console.log('Mevcut kullanıcıların username alanları email ile dolduruldu!');
    
    // Tablo bilgilerini görüntüle
    const result = await pool.query(`
      SELECT column_name, data_type 
      FROM information_schema.columns 
      WHERE table_name = 'users'
    `);
    
    console.log('Users tablosu sütunları:');
    result.rows.forEach(row => {
      console.log(`${row.column_name}: ${row.data_type}`);
    });
    
    // Bağlantıyı kapat
    await pool.end();
    
    console.log('İşlem başarıyla tamamlandı!');
  } catch (error) {
    console.error('Hata:', error);
    // Hata olsa da bağlantıyı kapatalım
    try {
      await pool.end();
    } catch (e) {
      console.error('Bağlantı kapatılırken hata:', e);
    }
  }
}

// Fonksiyonu çağır
addUsernameColumn();