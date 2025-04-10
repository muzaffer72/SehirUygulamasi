import { pool as localPool, db as localDb } from './server/db';
import { Pool } from 'pg';
import { drizzle } from 'drizzle-orm/node-postgres';
import * as schema from './shared/schema';

// Hedef veritabanı bağlantısı
const targetConnectionString = 'postgresql://belediye:005434677197@109.71.252.34:5432/belediyesikayet?ssl=false';
const targetPool = new Pool({ 
  connectionString: targetConnectionString,
  ssl: false
});
const targetDb = drizzle(targetPool, { schema });

async function exportData() {
  try {
    console.log('Veri aktarımı başlatılıyor...');

    // Kaynak veritabanından verileri çekme
    console.log('Şehirler veritabanından alınıyor...');
    const cities = await localDb.query.cities.findMany();
    console.log(`${cities.length} şehir alındı.`);

    console.log('İlçeler veritabanından alınıyor...');
    const districts = await localDb.query.districts.findMany();
    console.log(`${districts.length} ilçe alındı.`);

    console.log('Kategoriler veritabanından alınıyor...');
    const categories = await localDb.query.categories.findMany();
    console.log(`${categories.length} kategori alındı.`);

    console.log('Kullanıcılar veritabanından alınıyor...');
    const users = await localDb.query.users.findMany();
    console.log(`${users.length} kullanıcı alındı.`);

    console.log('Yasaklı kelimeler veritabanından alınıyor...');
    const bannedWords = await localDb.query.bannedWords.findMany();
    console.log(`${bannedWords.length} yasaklı kelime alındı.`);

    // Hedef veritabanındaki mevcut verileri silme
    try {
      console.log('Hedef veritabanına bağlanılıyor...');
      await targetPool.query('SELECT 1');
      console.log('Hedef veritabanına bağlantı başarılı.');

      console.log('Hedef veritabanında tablolar temizleniyor...');
      
      // Verileri aktarma - İlişkili tabloları doğru sırada silme
      await targetDb.execute(sql`TRUNCATE TABLE banned_words RESTART IDENTITY CASCADE`);
      await targetDb.execute(sql`TRUNCATE TABLE survey_regional_results RESTART IDENTITY CASCADE`);
      await targetDb.execute(sql`TRUNCATE TABLE survey_options RESTART IDENTITY CASCADE`);
      await targetDb.execute(sql`TRUNCATE TABLE surveys RESTART IDENTITY CASCADE`);
      await targetDb.execute(sql`TRUNCATE TABLE comments RESTART IDENTITY CASCADE`);
      await targetDb.execute(sql`TRUNCATE TABLE media RESTART IDENTITY CASCADE`);
      await targetDb.execute(sql`TRUNCATE TABLE posts RESTART IDENTITY CASCADE`);
      await targetDb.execute(sql`TRUNCATE TABLE users RESTART IDENTITY CASCADE`);
      await targetDb.execute(sql`TRUNCATE TABLE districts RESTART IDENTITY CASCADE`);
      await targetDb.execute(sql`TRUNCATE TABLE cities RESTART IDENTITY CASCADE`);
      await targetDb.execute(sql`TRUNCATE TABLE categories RESTART IDENTITY CASCADE`);
      
      console.log('Hedef veritabanı başarıyla temizlendi.');
    } catch (error) {
      console.error('Hedef veritabanına bağlanırken veya temizlerken hata oluştu:', error);
      throw new Error('Hedef veritabanına bağlanılamadı veya tablolar temizlenemedi.');
    }

    // Verileri hedef veritabanına aktarma
    try {
      console.log('Veriler hedef veritabanına aktarılıyor...');
      
      // Şehirleri aktar
      console.log('Şehirler aktarılıyor...');
      for (const city of cities) {
        await targetDb.insert(schema.cities).values({
          id: city.id,
          name: city.name,
          createdAt: city.createdAt
        });
      }
      console.log(`${cities.length} şehir başarıyla aktarıldı.`);
      
      // İlçeleri aktar
      console.log('İlçeler aktarılıyor...');
      for (const district of districts) {
        await targetDb.insert(schema.districts).values({
          id: district.id,
          name: district.name,
          cityId: district.cityId,
          createdAt: district.createdAt
        });
      }
      console.log(`${districts.length} ilçe başarıyla aktarıldı.`);
      
      // Kategorileri aktar
      console.log('Kategoriler aktarılıyor...');
      for (const category of categories) {
        await targetDb.insert(schema.categories).values({
          id: category.id,
          name: category.name,
          iconName: category.iconName,
          createdAt: category.createdAt
        });
      }
      console.log(`${categories.length} kategori başarıyla aktarıldı.`);
      
      // Kullanıcıları aktar
      console.log('Kullanıcılar aktarılıyor...');
      for (const user of users) {
        await targetDb.insert(schema.users).values({
          id: user.id,
          name: user.name,
          email: user.email,
          password: user.password,
          profileImageUrl: user.profileImageUrl,
          bio: user.bio,
          cityId: user.cityId,
          districtId: user.districtId,
          isVerified: user.isVerified,
          points: user.points,
          postCount: user.postCount,
          commentCount: user.commentCount,
          level: user.level,
          createdAt: user.createdAt
        });
      }
      console.log(`${users.length} kullanıcı başarıyla aktarıldı.`);
      
      // Yasaklı kelimeleri aktar
      console.log('Yasaklı kelimeler aktarılıyor...');
      for (const word of bannedWords) {
        await targetDb.insert(schema.bannedWords).values({
          id: word.id,
          word: word.word,
          createdAt: word.createdAt
        });
      }
      console.log(`${bannedWords.length} yasaklı kelime başarıyla aktarıldı.`);
      
      console.log('Tüm veriler başarıyla aktarıldı!');
    } catch (error) {
      console.error('Veri aktarımı sırasında hata oluştu:', error);
      throw new Error('Veri aktarımı tamamlanamadı.');
    }
  } catch (error) {
    console.error('İşlem sırasında hata oluştu:', error);
  } finally {
    // Bağlantıları kapat
    await localPool.end();
    await targetPool.end();
    console.log('Veritabanı bağlantıları kapatıldı.');
  }
}

// Eksik import'u ekle
import { sql } from 'drizzle-orm';

// Veri aktarımını başlat
exportData().catch(console.error);