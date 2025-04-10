import { Pool } from 'pg';
import { drizzle } from 'drizzle-orm/node-postgres';
import * as schema from './shared/schema';
import dotenv from 'dotenv';

// Enviroment değişkenlerini yükle
dotenv.config();

// Replit PostgreSQL veritabanını kullan
console.log('Replit PostgreSQL veritabanını kontrol ediyorum...');
if (!process.env.DATABASE_URL) {
  throw new Error("DATABASE_URL must be set. Did you forget to provision a database?");
}

// Replit'in kendi veritabanını kullanalım
const connectionConfig = {
  host: process.env.PGHOST,
  port: parseInt(process.env.PGPORT || '5432'),
  user: process.env.PGUSER,
  password: process.env.PGPASSWORD,
  database: process.env.PGDATABASE,
  ssl: {
    rejectUnauthorized: false
  }
};

// PostgreSQL bağlantısı oluştur
const pool = new Pool(connectionConfig);

// Drizzle ile veritabanına bağlan
const db = drizzle(pool, { schema });

async function checkDatabase() {
  try {
    // Tablo adlarını al
    const tableQuery = `
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema='public'
    `;
    const tableResult = await pool.query(tableQuery);
    console.log('Mevcut tablolar:');
    console.table(tableResult.rows);

    // Kullanıcılar tablosundaki kayıtları al
    const users = await db.select().from(schema.users);
    console.log(`\nKullanıcılar (${users.length}):`);
    console.table(users.map(u => ({ 
      id: u.id, 
      name: u.name, 
      email: u.email,
      city: u.cityId,
      level: u.level
    })));

    // Kategoriler tablosundaki kayıtları al
    const categories = await db.select().from(schema.categories);
    console.log(`\nKategoriler (${categories.length}):`);
    console.table(categories);

    // Şehirler tablosundaki kayıtları al
    const cities = await db.select().from(schema.cities);
    console.log(`\nŞehirler (${cities.length}):`);
    console.table(cities.slice(0, 10)); // Sadece ilk 10 şehri göster

    // Yasaklı kelimeler tablosundaki kayıtları al
    const bannedWords = await db.select().from(schema.bannedWords);
    console.log(`\nYasaklı Kelimeler (${bannedWords.length}):`);
    console.table(bannedWords);

  } catch (error) {
    console.error('Veritabanı kontrol hatası:', error);
  } finally {
    // Bağlantıyı kapat
    await pool.end();
  }
}

// Veritabanını kontrol et
checkDatabase();