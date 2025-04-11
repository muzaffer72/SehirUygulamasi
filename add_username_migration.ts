import { drizzle } from 'drizzle-orm/neon-serverless';
import { Pool, neonConfig } from '@neondatabase/serverless';
import * as schema from './shared/schema';
import { sql } from 'drizzle-orm';
import 'dotenv/config';
import ws from 'ws';

// Websocket ayarla
neonConfig.webSocketConstructor = ws;

// Veritabanı bağlantısını kur
const pool = new Pool({ connectionString: process.env.DATABASE_URL! });
const db = drizzle(pool, { schema });

async function run() {
  console.log('Veritabanı şemasına username sütunu ekleniyor...');
  
  try {
    // Username sütunu ekle
    await db.execute(sql`
      ALTER TABLE "users" 
      ADD COLUMN IF NOT EXISTS "username" VARCHAR(100) UNIQUE
    `);
    
    console.log('Username sütunu başarıyla eklendi!');
    
    // Email değerlerini başlangıçta username olarak kullan
    await db.execute(sql`
      UPDATE "users" 
      SET "username" = "email" 
      WHERE "username" IS NULL
    `);
    
    console.log('Mevcut kullanıcıların username alanları email ile dolduruldu!');
    
    console.log('Migrasyon başarıyla tamamlandı!');
  } catch (error) {
    console.error('Migrasyon sırasında hata:', error);
  } finally {
    process.exit(0);
  }
}

run();