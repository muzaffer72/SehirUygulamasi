import { Pool } from 'pg';
import * as fs from 'fs';

// Replit PostgreSQL veritabanı bağlantısı
const sourcePgConfig = {
  host: process.env.PGHOST,
  port: parseInt(process.env.PGPORT || '5432'),
  user: process.env.PGUSER,
  password: process.env.PGPASSWORD,
  database: process.env.PGDATABASE,
  ssl: {
    rejectUnauthorized: false
  }
};

// Hedef veritabanı bağlantı bilgileri
const targetPgConfig = {
  host: '109.71.252.34',
  port: 5432,
  user: 'belediye',
  password: '005434677197',
  database: 'belediyesikayet'
};

async function exportData() {
  const sourcePool = new Pool(sourcePgConfig);
  // Not: Hedef veritabanı bağlantısını çıkardık çünkü Replit dış IP'lere erişimi engelliyor

  try {
    // Bağlantıyı test et
    console.log('Kaynak veritabanına bağlanılıyor...');
    await sourcePool.query('SELECT 1');
    console.log('Kaynak veritabanına bağlantı başarılı.');

    // Tabloları al
    const tables = ['cities', 'districts', 'categories', 'users', 'banned_words'];
    
    // SQL dosyası oluştur
    let allSql = '';
    
    console.log('Veri aktarımı başlıyor...');
    
    // Temizleme işlemi için SQL
    allSql += '-- Mevcut tabloları temizle\n';
    allSql += 'TRUNCATE banned_words, survey_regional_results, survey_options, surveys, comments, media, posts, users, districts, cities, categories RESTART IDENTITY CASCADE;\n\n';
    
    // Her tablo için veri çıkartma
    for (const table of tables) {
      console.log(`${table} tablosu verilerini alınıyor...`);
      
      const { rows } = await sourcePool.query(`SELECT * FROM ${table}`);
      
      if (rows.length > 0) {
        // Tablo için insert başlangıcı
        allSql += `-- ${table} tablosu için veriler\n`;
        
        // Sütun isimleri
        const columns = Object.keys(rows[0]);
        const columnNames = columns.join(', ');
        
        // Her satır için insert
        for (const row of rows) {
          const values = columns.map(col => {
            const val = row[col];
            if (val === null) return 'NULL';
            if (typeof val === 'string') return `'${val.replace(/'/g, "''")}'`;
            if (val instanceof Date) return `'${val.toISOString()}'`;
            return val;
          }).join(', ');
          
          allSql += `INSERT INTO ${table} (${columnNames}) VALUES (${values});\n`;
        }
        
        allSql += '\n';
        console.log(`${rows.length} satır ${table} tablosundan alındı.`);
      } else {
        console.log(`${table} tablosunda veri bulunamadı.`);
      }
    }
    
    // SQL dosyasını kaydet
    fs.writeFileSync('data_export.sql', allSql);
    console.log('Tüm veriler data_export.sql dosyasına kaydedildi.');
    
    console.log('SQL dosyası başarıyla oluşturuldu. Bu dosyayı indirip uzak veritabanınıza aktarabilirsiniz.');
    console.log('İndirmek için: Dosyalar panelinden data_export.sql üzerine sağ tıklayıp "Download" seçeneğini kullanabilirsiniz.');
    
  } catch (error: any) {
    console.error('Veri aktarımı sırasında bir hata oluştu:', error);
  } finally {
    sourcePool.end();
    console.log('Veritabanı bağlantısı kapatıldı.');
  }
}

// Veri aktarımını başlat
exportData().catch(console.error);