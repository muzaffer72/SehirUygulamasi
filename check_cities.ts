import { Pool } from 'pg';
import { drizzle } from 'drizzle-orm/node-postgres';
import { eq } from 'drizzle-orm';
import * as schema from './shared/schema';
import { cities, districts } from './shared/schema';
import * as dotenv from 'dotenv';

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

// Şehir ve ilçeleri kontrol et
async function checkCitiesAndDistricts() {
  try {
    // Şehirleri al
    const allCities = await db.select().from(cities).orderBy(cities.name);
    console.log(`Toplam ${allCities.length} şehir bulundu.`);
    
    // Tüm şehirleri göster
    console.log('Tüm şehirler:');
    console.table(allCities.map(city => ({
      id: city.id,
      name: city.name
    })));
    
    // Şehir ID'sini değiştirelim - bir kaç şehri deneyelim
    // İstanbul için ID olabilecek değerler
    const cityIds = [34, 77, 47]; // Plaka kodu ve muhtemel diğer ID'ler
    
    // Her ID için ilçeleri kontrol edelim
    for (const cityId of cityIds) {
      console.log(`\nSeçilen şehir ID: ${cityId}`);
      
      // Bu şehrin ilçelerini getir
      const selectedCityDistricts = await db.select().from(districts)
        .where(eq(districts.cityId, cityId))
        .orderBy(districts.name);
      
      console.log(`Şehir ID ${cityId} için toplam ${selectedCityDistricts.length} ilçe bulundu.`);
      
      if (selectedCityDistricts.length > 0) {
        // İlk 10 ilçeyi göster
        console.log('Bu şehrin ilçelerinden ilk 10 tanesi:');
        console.table(selectedCityDistricts.slice(0, 10).map(district => ({
          id: district.id,
          name: district.name
        })));
        
        // Bir ilçe seçelim
        console.log("\nBu şehrin ilk ilçesinin ID'si:", selectedCityDistricts[0]?.id);
      } else {
        console.log('Bu şehir için ilçe kaydı bulunamadı.');
      }
    }
      
    // Bu şehrin ilçelerini getir (son denenen şehir ID'si ile)
    const selectedCityDistricts = await db.select().from(districts)
      .where(eq(districts.cityId, cityIds[cityIds.length-1]))
      .orderBy(districts.name);
    
    // Bu kısmı çıkaralım
    
    // İlçelerin ilk 10 tanesini göster
    const allDistricts = await db.select().from(districts).orderBy(districts.id).limit(10);
    console.log(`\nVeritabanında toplam ${await db.select().from(districts).execute().then(res => res.length)} ilçe bulundu.`);
    console.log('İlk 10 ilçe:');
    console.table(allDistricts.map(district => ({
      id: district.id,
      name: district.name,
      cityId: district.cityId
    })));
    
  } catch (error) {
    console.error('Şehir ve ilçe kontrol hatası:', error);
  } finally {
    // Bağlantıyı kapat
    await pool.end();
  }
}

// Şehir ve ilçe kontrolünü başlat
checkCitiesAndDistricts();