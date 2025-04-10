import { Pool } from 'pg';
import { drizzle } from 'drizzle-orm/node-postgres';
import { eq } from 'drizzle-orm';
import * as schema from './shared/schema';
import { users } from './shared/schema';
import * as dotenv from 'dotenv';
import * as crypto from 'crypto';

// Enviroment değişkenlerini yükle
dotenv.config();

// Replit PostgreSQL bağlantı ayarları
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

// PostgreSQL bağlantı havuzu oluştur
const pool = new Pool(connectionConfig);

// Drizzle ORM ile bağlan
const db = drizzle(pool, { schema });

// Şifre hashleme fonksiyonu - şifreleme için
function hashPassword(password: string): string {
  return crypto.createHash('sha256').update(password).digest('hex');
}

// Test kullanıcısını ekle
async function addTestUser() {
  try {
    // Önce kullanıcının var olup olmadığını kontrol et
    const existingUsers = await db.select().from(users).where(eq(users.email, 'test@example.com'));
    
    if (existingUsers.length > 0) {
      console.log('Test kullanıcısı zaten mevcut (email: test@example.com)');
      return;
    }
    
    // Kullanıcıyı ekle
    const newUser = {
      name: 'Test Kullanıcı',
      email: 'test@example.com',
      password: hashPassword('test123'), // şifre: test123
      profileImageUrl: 'https://i.pravatar.cc/150?img=3', // Rasgele avatar
      bio: 'Bu bir test kullanıcısı hesabıdır',
      isVerified: true,
      points: 100,
      level: 'contributor' as schema.UserLevel, // başlangıç seviyesi
      postCount: 0,
      commentCount: 0,
      // Varsayılan olarak İstanbul ve Kadıköy
      cityId: 34, // İstanbul
      districtId: 1519 // Kadıköy - İstanbul'a bağlı
    };
    
    const result = await db.insert(users).values(newUser as any).returning();
    console.log('Test kullanıcısı başarıyla eklendi:');
    console.log(`ID: ${result[0].id}`);
    console.log(`Ad: ${result[0].name}`);
    console.log(`E-posta: ${result[0].email}`);
    console.log(`Şifre: test123 (hash: ${result[0].password})`);
    
  } catch (error) {
    console.error('Kullanıcı ekleme hatası:', error);
  } finally {
    // Bağlantıyı kapat
    await pool.end();
  }
}

// Kullanıcı ekleme işlemini başlat
addTestUser();