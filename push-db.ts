import { drizzle } from 'drizzle-orm/neon-http';
import { neon } from '@neondatabase/serverless';
import { eq } from 'drizzle-orm';
import * as schema from './shared/schema';

// PostgreSQL veritabanı bağlantısı
if (!process.env.DATABASE_URL) {
  throw new Error("DATABASE_URL must be set. Did you forget to provision a database?");
}

const sql = neon(process.env.DATABASE_URL);
const db = drizzle(sql, { schema });

async function main() {
  console.log('Veritabanı tabloları oluşturuluyor...');

  try {
    // Ardışık tablo oluşturmalar
    await sql`
      CREATE TABLE IF NOT EXISTS categories (
        id SERIAL PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        icon_name VARCHAR(50),
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
      );
    `;

    await sql`
      CREATE TABLE IF NOT EXISTS cities (
        id SERIAL PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
      );
    `;

    await sql`
      CREATE TABLE IF NOT EXISTS districts (
        id SERIAL PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        city_id INTEGER NOT NULL,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
        FOREIGN KEY (city_id) REFERENCES cities(id) ON DELETE CASCADE
      );
    `;

    await sql`
      CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        email VARCHAR(255) NOT NULL UNIQUE,
        password VARCHAR(255) NOT NULL,
        profile_image_url TEXT,
        bio TEXT,
        city_id INTEGER,
        district_id INTEGER,
        is_verified BOOLEAN DEFAULT FALSE NOT NULL,
        points INTEGER DEFAULT 0 NOT NULL,
        post_count INTEGER DEFAULT 0 NOT NULL,
        comment_count INTEGER DEFAULT 0 NOT NULL,
        level VARCHAR(20) DEFAULT 'newUser' NOT NULL,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
        FOREIGN KEY (city_id) REFERENCES cities(id),
        FOREIGN KEY (district_id) REFERENCES districts(id)
      );
    `;

    await sql`
      CREATE TABLE IF NOT EXISTS posts (
        id SERIAL PRIMARY KEY,
        title VARCHAR(255) NOT NULL,
        content TEXT NOT NULL,
        user_id INTEGER NOT NULL,
        category_id INTEGER NOT NULL,
        city_id INTEGER,
        district_id INTEGER,
        status VARCHAR(20) DEFAULT 'awaitingSolution' NOT NULL,
        type VARCHAR(20) DEFAULT 'problem' NOT NULL,
        likes INTEGER DEFAULT 0 NOT NULL,
        highlights INTEGER DEFAULT 0 NOT NULL,
        comment_count INTEGER DEFAULT 0 NOT NULL,
        is_anonymous BOOLEAN DEFAULT FALSE NOT NULL,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (category_id) REFERENCES categories(id),
        FOREIGN KEY (city_id) REFERENCES cities(id),
        FOREIGN KEY (district_id) REFERENCES districts(id)
      );
    `;

    await sql`
      CREATE TABLE IF NOT EXISTS media (
        id SERIAL PRIMARY KEY,
        post_id INTEGER NOT NULL,
        url TEXT NOT NULL,
        type VARCHAR(20) NOT NULL,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
        FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE
      );
    `;

    await sql`
      CREATE TABLE IF NOT EXISTS comments (
        id SERIAL PRIMARY KEY,
        post_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        content TEXT NOT NULL,
        like_count INTEGER DEFAULT 0 NOT NULL,
        is_hidden BOOLEAN DEFAULT FALSE NOT NULL,
        is_anonymous BOOLEAN DEFAULT FALSE NOT NULL,
        parent_id INTEGER,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
        FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (parent_id) REFERENCES comments(id) ON DELETE CASCADE
      );
    `;

    await sql`
      CREATE TABLE IF NOT EXISTS surveys (
        id SERIAL PRIMARY KEY,
        title VARCHAR(255) NOT NULL,
        description TEXT NOT NULL,
        scope_type VARCHAR(20) DEFAULT 'general' NOT NULL,
        city_id INTEGER,
        district_id INTEGER,
        category_id INTEGER NOT NULL,
        is_active BOOLEAN DEFAULT TRUE NOT NULL,
        start_date TIMESTAMP WITH TIME ZONE NOT NULL,
        end_date TIMESTAMP WITH TIME ZONE NOT NULL,
        total_votes INTEGER DEFAULT 0 NOT NULL,
        sort_order INTEGER DEFAULT 0 NOT NULL,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
        FOREIGN KEY (city_id) REFERENCES cities(id),
        FOREIGN KEY (district_id) REFERENCES districts(id),
        FOREIGN KEY (category_id) REFERENCES categories(id)
      );
    `;

    await sql`
      CREATE TABLE IF NOT EXISTS survey_options (
        id SERIAL PRIMARY KEY,
        survey_id INTEGER NOT NULL,
        text TEXT NOT NULL,
        vote_count INTEGER DEFAULT 0 NOT NULL,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
        FOREIGN KEY (survey_id) REFERENCES surveys(id) ON DELETE CASCADE
      );
    `;
    
    await sql`
      CREATE TABLE IF NOT EXISTS survey_regional_results (
        id SERIAL PRIMARY KEY,
        survey_id INTEGER NOT NULL,
        option_id INTEGER NOT NULL,
        city_id INTEGER,
        district_id INTEGER,
        vote_count INTEGER DEFAULT 0 NOT NULL,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
        FOREIGN KEY (survey_id) REFERENCES surveys(id) ON DELETE CASCADE,
        FOREIGN KEY (option_id) REFERENCES survey_options(id) ON DELETE CASCADE,
        FOREIGN KEY (city_id) REFERENCES cities(id),
        FOREIGN KEY (district_id) REFERENCES districts(id)
      );
    `;

    await sql`
      CREATE TABLE IF NOT EXISTS banned_words (
        id SERIAL PRIMARY KEY,
        word VARCHAR(100) NOT NULL UNIQUE,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
      );
    `;

    console.log('Veritabanı tabloları başarıyla oluşturuldu!');
    
    // Admin kullanıcısı oluşturalım
    const adminUsers = await db.select().from(schema.users).where(eq(schema.users.email, 'admin@example.com'));
    
    if (adminUsers.length === 0) {
      await db.insert(schema.users).values({
        name: 'Admin',
        email: 'admin@example.com',
        password: '$2b$10$k55g2qPRBM6SCcW8BM3l1OkTEQoiL.Vgab21jzv8x2ZHIV5uC1Pqe', // admin123
        bio: 'Sistem Yöneticisi',
        isVerified: true,
        level: 'master'
      });
      console.log('Admin kullanıcısı oluşturuldu (admin@example.com / admin123)');
    } else {
      console.log('Admin kullanıcısı zaten mevcut');
    }
    
    // Temel kategoriler
    const existingCategories = await db.select().from(schema.categories);
    
    if (existingCategories.length === 0) {
      await db.insert(schema.categories).values([
        { name: 'Altyapı', iconName: 'construction' },
        { name: 'Ulaşım', iconName: 'directions_bus' },
        { name: 'Çevre', iconName: 'nature' },
        { name: 'Güvenlik', iconName: 'security' },
        { name: 'Sağlık', iconName: 'local_hospital' },
        { name: 'Eğitim', iconName: 'school' },
        { name: 'Kültür & Sanat', iconName: 'theater_comedy' },
        { name: 'Sosyal Hizmetler', iconName: 'people' },
        { name: 'Diğer', iconName: 'more_horiz' }
      ]);
      console.log('Temel kategoriler oluşturuldu');
    } else {
      console.log('Kategoriler zaten mevcut');
    }
    
    // Örnek şehirler
    const existingCities = await db.select().from(schema.cities);
    
    if (existingCities.length === 0) {
      await db.insert(schema.cities).values([
        { name: 'İstanbul' },
        { name: 'Ankara' },
        { name: 'İzmir' },
        { name: 'Bursa' },
        { name: 'Antalya' }
      ]);
      console.log('Örnek şehirler oluşturuldu');
      
      // İlçeler için şehir ID'leri alalım
      const cities = await db.select().from(schema.cities);
      const istanbulId = cities.find(c => c.name === 'İstanbul')?.id;
      const ankaraId = cities.find(c => c.name === 'Ankara')?.id;
      const izmirId = cities.find(c => c.name === 'İzmir')?.id;
      
      if (istanbulId) {
        await db.insert(schema.districts).values([
          { name: 'Kadıköy', cityId: istanbulId },
          { name: 'Beşiktaş', cityId: istanbulId },
          { name: 'Üsküdar', cityId: istanbulId },
          { name: 'Bakırköy', cityId: istanbulId },
          { name: 'Fatih', cityId: istanbulId }
        ]);
      }
      
      if (ankaraId) {
        await db.insert(schema.districts).values([
          { name: 'Çankaya', cityId: ankaraId },
          { name: 'Keçiören', cityId: ankaraId },
          { name: 'Yenimahalle', cityId: ankaraId }
        ]);
      }
      
      if (izmirId) {
        await db.insert(schema.districts).values([
          { name: 'Konak', cityId: izmirId },
          { name: 'Karşıyaka', cityId: izmirId },
          { name: 'Bornova', cityId: izmirId }
        ]);
      }
      
      console.log('Örnek ilçeler oluşturuldu');
    } else {
      console.log('Şehirler zaten mevcut');
    }
    
    // Yasak kelimeler
    const existingBannedWords = await db.select().from(schema.bannedWords);
    
    if (existingBannedWords.length === 0) {
      await db.insert(schema.bannedWords).values([
        { word: 'küfür' },
        { word: 'hakaret' },
        { word: 'argo' }
      ]);
      console.log('Örnek yasaklı kelimeler oluşturuldu');
    } else {
      console.log('Yasaklı kelimeler zaten mevcut');
    }
    
  } catch (error) {
    console.error('Veritabanı tabloları oluşturulurken hata:', error);
  } finally {
    console.log('İşlem tamamlandı');
    process.exit(0);
  }
}

main();