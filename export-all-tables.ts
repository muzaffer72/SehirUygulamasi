import { db } from './server/db';
import * as schema from './shared/schema';
import fs from 'fs';
import path from 'path';

async function exportTables() {
  try {
    console.log('Veritabanı dışa aktarım işlemi başlıyor...');
    
    // Veri aktarılacak dizin
    const exportDir = './export_data';
    if (!fs.existsSync(exportDir)) {
      fs.mkdirSync(exportDir);
    }
    
    // Timestamp ekle
    const timestamp = new Date().toISOString().replace(/[:T]/g, '-').split('.')[0];
    
    // Tablo listesini oluştur
    const tables = [
      { name: 'users', query: db.select().from(schema.users) },
      { name: 'cities', query: db.select().from(schema.cities) },
      { name: 'districts', query: db.select().from(schema.districts) },
      { name: 'categories', query: db.select().from(schema.categories) },
      { name: 'posts', query: db.select().from(schema.posts) },
      { name: 'comments', query: db.select().from(schema.comments) },
      { name: 'surveys', query: db.select().from(schema.surveys) },
      { name: 'survey_options', query: db.select().from(schema.surveyOptions) },
      { name: 'survey_regional_results', query: db.select().from(schema.surveyRegionalResults) },
      { name: 'banned_words', query: db.select().from(schema.bannedWords) },
      { name: 'city_services', query: db.select().from(schema.cityServices) },
      { name: 'cities_services', query: db.select().from(schema.citiesServices) },
      { name: 'city_projects', query: db.select().from(schema.cityProjects) },
      { name: 'user_likes', query: db.select().from(schema.userLikes) },
      { name: 'notifications', query: db.select().from(schema.notifications) },
      { name: 'city_events', query: db.select().from(schema.cityEvents) },
      { name: 'city_stats', query: db.select().from(schema.cityStats) },
      { name: 'award_types', query: db.select().from(schema.awardTypes) },
      { name: 'city_awards', query: db.select().from(schema.cityAwards) },
      { name: 'media', query: db.select().from(schema.media) }
    ];
    
    // Her tabloyu dışa aktar
    for (const table of tables) {
      console.log(`${table.name} tablosu dışa aktarılıyor...`);
      
      try {
        const data = await table.query;
        const filePath = path.join(exportDir, `${table.name}_${timestamp}.json`);
        
        fs.writeFileSync(filePath, JSON.stringify(data, null, 2));
        console.log(`✓ ${table.name} tablosu başarıyla dışa aktarıldı: ${filePath}`);
      } catch (err) {
        console.error(`× ${table.name} tablosu dışa aktarılırken hata oluştu:`, err);
      }
    }
    
    // Tek bir dosyada tüm veritabanını dışa aktar
    console.log('Tüm veritabanı tek bir dosyaya aktarılıyor...');
    const allData: Record<string, any> = {};
    
    for (const table of tables) {
      try {
        const data = await table.query;
        allData[table.name] = data;
      } catch (err) {
        console.error(`× ${table.name} tablosu işlenirken hata oluştu:`, err);
        allData[table.name] = [];
      }
    }
    
    const fullDbPath = path.join(exportDir, `sikayetvar_full_export_${timestamp}.json`);
    fs.writeFileSync(fullDbPath, JSON.stringify(allData, null, 2));
    console.log(`✓ Tüm veritabanı başarıyla dışa aktarıldı: ${fullDbPath}`);
    
    const summaryPath = path.join(exportDir, 'export_summary.txt');
    fs.writeFileSync(summaryPath, `Dışa aktarım tarihi: ${new Date().toLocaleString('tr-TR')}\n\n`);
    
    for (const tableName of Object.keys(allData)) {
      fs.appendFileSync(summaryPath, `${tableName}: ${allData[tableName].length} kayıt\n`);
    }
    
    console.log(`✓ Dışa aktarım özeti oluşturuldu: ${summaryPath}`);
    console.log('Veritabanı dışa aktarım işlemi tamamlandı!');
    
  } catch (error) {
    console.error('Dışa aktarma işlemi sırasında hata oluştu:', error);
  } finally {
    process.exit();
  }
}

exportTables();