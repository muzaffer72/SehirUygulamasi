import { Pool } from 'pg';
import { drizzle } from 'drizzle-orm/node-postgres';
import * as schema from '../shared/schema';

// Bu dosya sadece Replit PostgreSQL veritabanını kullanıyor
// Uzak veritabanına erişim sınırlamalar nedeniyle mümkün değil
console.log('Replit PostgreSQL veritabanı kullanılıyor...');

if (!process.env.DATABASE_URL) {
  throw new Error("DATABASE_URL must be set. Did you forget to provision a database?");
}

// Replit PostgreSQL bağlantı ayarları
const connectionConfig = {
  host: process.env.PGHOST,
  port: parseInt(process.env.PGPORT || '5432'),
  user: process.env.PGUSER,
  password: process.env.PGPASSWORD,
  database: process.env.PGDATABASE
};

// PostgreSQL bağlantı havuzu oluştur
export const pool = new Pool(connectionConfig);

// Drizzle ORM ile bağlan
export const db = drizzle(pool, { schema });