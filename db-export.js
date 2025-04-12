// CommonJS ile veritabanını export etme
const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');

// Veritabanı bağlantı bilgileri
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

async function exportAllData() {
  console.log('Veritabanı dışa aktarım işlemi başlıyor...');
  
  // Export dizini
  const exportDir = './export_data';
  if (!fs.existsSync(exportDir)) {
    fs.mkdirSync(exportDir);
  }
  
  // Timestamp
  const timestamp = new Date().toISOString().replace(/[:T]/g, '-').split('.')[0];
  
  try {
    // Veritabanındaki tabloları listele
    const tablesResult = await pool.query(`
      SELECT table_name
      FROM information_schema.tables
      WHERE table_schema = 'public'
      ORDER BY table_name
    `);
    
    const tables = tablesResult.rows.map(row => row.table_name);
    console.log(`Veritabanında ${tables.length} tablo bulundu.`);
    
    // Her tabloyu dışa aktar
    const allData = {};
    
    for (const tableName of tables) {
      try {
        console.log(`${tableName} tablosu dışa aktarılıyor...`);
        
        // Tablonun yapısını kontrol et
        const columnsResult = await pool.query(`
          SELECT column_name
          FROM information_schema.columns
          WHERE table_schema = 'public' AND table_name = $1
          ORDER BY ordinal_position
        `, [tableName]);
        
        const columns = columnsResult.rows.map(row => row.column_name);
        console.log(`  ${columns.length} sütun bulundu: ${columns.join(', ')}`);
        
        // Verileri çek
        const dataResult = await pool.query(`SELECT * FROM "${tableName}"`);
        console.log(`  ${dataResult.rows.length} satır veri bulundu.`);
        
        // JSON dosyasına kaydet
        const filePath = path.join(exportDir, `${tableName}_${timestamp}.json`);
        fs.writeFileSync(filePath, JSON.stringify(dataResult.rows, null, 2));
        
        console.log(`  ✓ ${tableName} tablosu dışa aktarıldı: ${filePath}`);
        
        // Tüm veritabanı için veri toplama
        allData[tableName] = dataResult.rows;
      } catch (err) {
        console.error(`  × ${tableName} tablosu dışa aktarılamadı:`, err.message);
        allData[tableName] = []; // Hata durumunda boş dizi ekle
      }
    }
    
    // Tüm veritabanını tek dosyada dışa aktar
    console.log('\nTüm veritabanı tek bir dosyada dışa aktarılıyor...');
    const fullDbPath = path.join(exportDir, `sikayetvar_full_export_${timestamp}.json`);
    fs.writeFileSync(fullDbPath, JSON.stringify(allData, null, 2));
    console.log(`✓ Tüm veritabanı başarıyla dışa aktarıldı: ${fullDbPath}`);
    
    // Özet oluştur
    const summaryPath = path.join(exportDir, 'export_summary.txt');
    let summaryContent = `Dışa aktarım tarihi: ${new Date().toLocaleString('tr-TR')}\n\n`;
    
    for (const tableName of Object.keys(allData)) {
      summaryContent += `${tableName}: ${allData[tableName].length} kayıt\n`;
    }
    
    fs.writeFileSync(summaryPath, summaryContent);
    console.log(`✓ Dışa aktarım özeti oluşturuldu: ${summaryPath}`);
    
  } catch (err) {
    console.error('Dışa aktarma işlemi sırasında hata:', err);
  } finally {
    await pool.end();
    console.log('Veritabanı bağlantısı kapatıldı.');
  }
}

// İşlemi başlat
exportAllData();