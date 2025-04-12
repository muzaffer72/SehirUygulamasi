import { Pool } from 'pg';
import dotenv from 'dotenv';

dotenv.config();

// PostgreSQL veritabanı bağlantısı
if (!process.env.DATABASE_URL) {
  throw new Error("DATABASE_URL must be set. Did you forget to provision a database?");
}

// Replit'ten gelen PostgreSQL bağlantı URL'si kullanılıyor
const pool = new Pool({
  host: process.env.PGHOST,
  port: parseInt(process.env.PGPORT || '5432'),
  user: process.env.PGUSER,
  password: process.env.PGPASSWORD,
  database: process.env.PGDATABASE,
  ssl: {
    rejectUnauthorized: false
  }
});

async function main() {
  console.log('Veritabanı tablolarına problem_solving_rate sütunu ekleniyor...');

  try {
    // Tabloda sütun var mı diye kontrol edelim ve yoksa ekleyelim
    const checkCitiesColumn = await pool.query(`
      SELECT column_name 
      FROM information_schema.columns 
      WHERE table_name = 'cities' AND column_name = 'problem_solving_rate';
    `);

    if (checkCitiesColumn.rows.length === 0) {
      console.log('cities tablosuna problem_solving_rate sütunu ekleniyor...');
      await pool.query(`
        ALTER TABLE cities 
        ADD COLUMN problem_solving_rate INTEGER DEFAULT 0;
      `);
      console.log('cities tablosuna problem_solving_rate sütunu eklendi.');
    } else {
      console.log('cities tablosunda problem_solving_rate sütunu zaten mevcut.');
    }

    const checkDistrictsColumn = await pool.query(`
      SELECT column_name 
      FROM information_schema.columns 
      WHERE table_name = 'districts' AND column_name = 'problem_solving_rate';
    `);

    if (checkDistrictsColumn.rows.length === 0) {
      console.log('districts tablosuna problem_solving_rate sütunu ekleniyor...');
      await pool.query(`
        ALTER TABLE districts 
        ADD COLUMN problem_solving_rate INTEGER DEFAULT 0;
      `);
      console.log('districts tablosuna problem_solving_rate sütunu eklendi.');
    } else {
      console.log('districts tablosunda problem_solving_rate sütunu zaten mevcut.');
    }

  } catch (error) {
    console.error('Veritabanı sütunları eklenirken hata:', error);
  } finally {
    console.log('İşlem tamamlandı');
    process.exit(0);
  }
}

main();