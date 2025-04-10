import { Pool } from 'pg';
import { drizzle } from 'drizzle-orm/node-postgres';
import * as schema from '../shared/schema';

// Ortam değişkenine bağlı olarak veritabanı bağlantısını belirle
// Varsayılan olarak Replit veritabanı
// Uzak veritabanı kullanmak için REMOTE_DB=true .env'ye ekleyin
const useRemoteDb = process.env.REMOTE_DB === 'true';

let connectionConfig;

if (useRemoteDb) {
  // Uzak veritabanı 
  console.log('Uzak PostgreSQL veritabanı kullanılıyor...');
  connectionConfig = {
    host: '109.71.252.34',
    port: 5432,
    user: 'belediye',
    password: '005434677197',
    database: 'belediyesikayet',
    ssl: false
  };
} else {
  // Replit PostgreSQL
  console.log('Replit PostgreSQL veritabanı kullanılıyor...');
  if (!process.env.DATABASE_URL) {
    throw new Error("DATABASE_URL must be set. Did you forget to provision a database?");
  }
  
  connectionConfig = {
    host: process.env.PGHOST,
    port: parseInt(process.env.PGPORT || '5432'),
    user: process.env.PGUSER,
    password: process.env.PGPASSWORD,
    database: process.env.PGDATABASE,
    ssl: {
      rejectUnauthorized: false
    }
  };
}

// Create a PostgreSQL pool connection
export const pool = new Pool(connectionConfig);

// Initialize Drizzle with the pool connection and schema
export const db = drizzle(pool, { schema });