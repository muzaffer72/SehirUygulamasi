import { Pool } from 'pg';
import { drizzle } from 'drizzle-orm/node-postgres';
import { eq } from 'drizzle-orm';
import * as schema from './shared/schema';

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

const db = drizzle(pool, { schema });

async function main() {
  console.log('Veritabanı tabloları oluşturuluyor...');

  try {
    // Önceki/Sonrası Görseller tablosu oluştur
    await pool.query(`
      CREATE TABLE IF NOT EXISTS before_after_records (
        id SERIAL PRIMARY KEY,
        post_id INTEGER NOT NULL,
        before_image_url TEXT NOT NULL,
        after_image_url TEXT NOT NULL,
        description TEXT,
        recorded_by INTEGER,
        record_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
        FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
        FOREIGN KEY (recorded_by) REFERENCES users(id)
      );
    `);
    
    // Ardışık tablo oluşturmalar
    await pool.query(`
      CREATE TABLE IF NOT EXISTS categories (
        id SERIAL PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        icon_name VARCHAR(50),
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
      );
    `);

    await pool.query(`
      CREATE TABLE IF NOT EXISTS cities (
        id SERIAL PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        description TEXT,
        population BIGINT,
        latitude TEXT,
        longitude TEXT,
        image_url TEXT,
        header_image_url TEXT,
        mayor_name VARCHAR(255),
        mayor_party VARCHAR(255),
        mayor_satisfaction_rate INTEGER,
        mayor_image_url TEXT,
        mayor_party_logo TEXT,
        problem_solving_rate INTEGER DEFAULT 0,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
      );
    `);

    await pool.query(`
      CREATE TABLE IF NOT EXISTS districts (
        id SERIAL PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        city_id INTEGER NOT NULL,
        problem_solving_rate INTEGER DEFAULT 0,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
        FOREIGN KEY (city_id) REFERENCES cities(id) ON DELETE CASCADE
      );
    `);

    await pool.query(`
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
    `);

    await pool.query(`
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
        satisfaction_rating INTEGER, 
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (category_id) REFERENCES categories(id),
        FOREIGN KEY (city_id) REFERENCES cities(id),
        FOREIGN KEY (district_id) REFERENCES districts(id)
      );
    `);

    await pool.query(`
      CREATE TABLE IF NOT EXISTS media (
        id SERIAL PRIMARY KEY,
        post_id INTEGER NOT NULL,
        url TEXT NOT NULL,
        type VARCHAR(20) NOT NULL,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
        FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE
      );
    `);

    await pool.query(`
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
    `);

    await pool.query(`
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
    `);

    await pool.query(`
      CREATE TABLE IF NOT EXISTS survey_options (
        id SERIAL PRIMARY KEY,
        survey_id INTEGER NOT NULL,
        text TEXT NOT NULL,
        vote_count INTEGER DEFAULT 0 NOT NULL,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
        FOREIGN KEY (survey_id) REFERENCES surveys(id) ON DELETE CASCADE
      );
    `);
    
    await pool.query(`
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
    `);

    await pool.query(`
      CREATE TABLE IF NOT EXISTS banned_words (
        id SERIAL PRIMARY KEY,
        word VARCHAR(100) NOT NULL UNIQUE,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
      );
    `);

    // Sosyal özellikler için tablolar
    await pool.query(`
      CREATE TABLE IF NOT EXISTS user_likes (
        id SERIAL PRIMARY KEY,
        user_id INTEGER NOT NULL,
        post_id INTEGER,
        comment_id INTEGER,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
        FOREIGN KEY (comment_id) REFERENCES comments(id) ON DELETE CASCADE
      );
    `);

    await pool.query(`
      CREATE INDEX IF NOT EXISTS user_likes_user_id_idx ON user_likes(user_id);
      CREATE INDEX IF NOT EXISTS user_likes_post_id_idx ON user_likes(post_id);
      CREATE INDEX IF NOT EXISTS user_likes_comment_id_idx ON user_likes(comment_id);
    `);

    await pool.query(`
      CREATE TABLE IF NOT EXISTS notifications (
        id SERIAL PRIMARY KEY,
        user_id INTEGER NOT NULL,
        title VARCHAR(255) NOT NULL,
        content TEXT NOT NULL,
        type VARCHAR(50) NOT NULL,
        is_read BOOLEAN NOT NULL DEFAULT FALSE,
        source_id INTEGER,
        source_type VARCHAR(50),
        data TEXT,
        is_archived BOOLEAN NOT NULL DEFAULT FALSE,
        group_id VARCHAR(100),
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      );
    `);

    await pool.query(`
      CREATE INDEX IF NOT EXISTS notifications_user_id_idx ON notifications(user_id);
      CREATE INDEX IF NOT EXISTS notifications_is_read_idx ON notifications(is_read);
    `);

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
        { 
          name: 'İstanbul', 
          description: 'Türkiye\'nin en kalabalık ve en önemli ticaret merkezidir. Boğaziçi ile ikiye ayrılmış, Asya ve Avrupa kıtalarını birleştiren eşsiz bir konuma sahiptir.',
          population: 16000000,
          latitude: '41.0082',
          longitude: '28.9784',
          imageUrl: '/uploads/cities/istanbul_logo.png',
          headerImageUrl: '/uploads/cities/istanbul_header.jpg',
          mayorName: 'Ekrem İmamoğlu',
          mayorParty: 'CHP',
          mayorSatisfactionRate: 78,
          mayorImageUrl: '/uploads/mayors/istanbul_mayor.jpg',
          mayorPartyLogo: '/uploads/parties/chp_logo.png'
        },
        { 
          name: 'Ankara', 
          description: 'Türkiye Cumhuriyeti\'nin başkenti ve İstanbul\'dan sonra en kalabalık ikinci şehridir. Türkiye\'nin merkezinde yer alan önemli bir idari merkezdir.',
          population: 5700000,
          latitude: '39.9334',
          longitude: '32.8597',
          imageUrl: '/uploads/cities/ankara_logo.png',
          headerImageUrl: '/uploads/cities/ankara_header.jpg',
          mayorName: 'Mansur Yavaş',
          mayorParty: 'CHP',
          mayorSatisfactionRate: 85,
          mayorImageUrl: '/uploads/mayors/ankara_mayor.jpg',
          mayorPartyLogo: '/uploads/parties/chp_logo.png'
        },
        { 
          name: 'İzmir', 
          description: 'Türkiye\'nin batı kıyısında yer alan en büyük üçüncü şehridir. Ege Denizi kıyısında yer alan canlı bir liman şehridir.',
          population: 4350000,
          latitude: '38.4237',
          longitude: '27.1428',
          imageUrl: '/uploads/cities/izmir_logo.png',
          headerImageUrl: '/uploads/cities/izmir_header.jpg',
          mayorName: 'Cemil Tugay',
          mayorParty: 'CHP',
          mayorSatisfactionRate: 72,
          mayorImageUrl: '/uploads/mayors/izmir_mayor.jpg',
          mayorPartyLogo: '/uploads/parties/chp_logo.png'
        },
        { 
          name: 'Bursa', 
          description: 'Marmara Bölgesi\'nin Güney Marmara bölümünde yer alan sanayi ve tarih şehridir. Osmanlı İmparatorluğu\'nun ilk başkentidir.',
          population: 3100000,
          latitude: '40.1885',
          longitude: '29.0610',
          imageUrl: '/uploads/cities/bursa_logo.png',
          headerImageUrl: '/uploads/cities/bursa_header.jpg',
          mayorName: 'Mustafa Bozbey',
          mayorParty: 'CHP',
          mayorSatisfactionRate: 75,
          mayorImageUrl: '/uploads/mayors/bursa_mayor.jpg',
          mayorPartyLogo: '/uploads/parties/chp_logo.png'
        },
        { 
          name: 'Antalya', 
          description: 'Türkiye\'nin güneyinde, Akdeniz\'in kıyısında bulunan turizm ve tarım merkezi olan şehirdir. "Türk Rivierası" olarak da bilinir.',
          population: 2500000,
          latitude: '36.8969',
          longitude: '30.7133',
          imageUrl: '/uploads/cities/antalya_logo.png',
          headerImageUrl: '/uploads/cities/antalya_header.jpg',
          mayorName: 'Muhittin Böcek',
          mayorParty: 'CHP',
          mayorSatisfactionRate: 76,
          mayorImageUrl: '/uploads/mayors/antalya_mayor.jpg',
          mayorPartyLogo: '/uploads/parties/chp_logo.png'
        }
      ]);
      console.log('Örnek şehirler oluşturuldu');
      
      // İlçeler için şehir ID'leri alalım
      const cities = await db.select().from(schema.cities);
      const istanbulId = cities.find((c: any) => c.name === 'İstanbul')?.id;
      const ankaraId = cities.find((c: any) => c.name === 'Ankara')?.id;
      const izmirId = cities.find((c: any) => c.name === 'İzmir')?.id;
      
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