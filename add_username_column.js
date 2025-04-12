require('dotenv').config();
const { Pool } = require('pg');

// Veritabanı bağlantısı
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: {
    rejectUnauthorized: false
  }
});

async function addUsernameColumn() {
  console.log('Veritabanı şemasına "username" sütunu ekleniyor...');
  
  try {
    // Bağlantıyı al
    const client = await pool.connect();
    
    try {
      // Önce users tablosunda username sütunu var mı kontrol et
      const checkResult = await client.query(`
        SELECT column_name 
        FROM information_schema.columns 
        WHERE table_name = 'users' AND column_name = 'username'
      `);
      
      // Sütun yoksa ekle
      if (checkResult.rows.length === 0) {
        await client.query(`
          ALTER TABLE users 
          ADD COLUMN username VARCHAR(100) UNIQUE
        `);
        console.log('Username sütunu başarıyla eklendi.');
        
        // Email değerlerini başlangıçta username olarak kullan
        await client.query(`
          UPDATE users 
          SET username = email 
          WHERE username IS NULL
        `);
        console.log('Mevcut kullanıcıların username alanları email ile dolduruldu.');
      } else {
        console.log('Username sütunu zaten mevcut, işlem atlanıyor.');
      }
      
      console.log('Migrasyon başarıyla tamamlandı!');
    } finally {
      // İşlem bitince client'ı serbest bırak
      client.release();
    }
  } catch (error) {
    console.error('Migrasyon sırasında hata:', error);
  } finally {
    // Bağlantı havuzunu kapat
    await pool.end();
  }
}

// Fonksiyonu çalıştır
addUsernameColumn();