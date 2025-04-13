// JSON dosyalarını kullanarak tam bir SQL export dosyası oluştur
const fs = require('fs');
const path = require('path');

const EXPORT_DIR = 'export_data';
const OUTPUT_FILE = 'sikayetvar_tam_export.sql';

async function main() {
  console.log('JSON dosyalarından tam SQL export dosyası oluşturuluyor...');

  // Şema bilgilerini içeren SQL dosyasını oku
  const schemaContent = fs.readFileSync('schema_dump.sql', 'utf8');

  // SQL içeriğini oluşturmaya başla
  let sqlContent = `-- ŞikayetVar Veritabanı TAM KOPYA (JSON verisinden oluşturuldu)
-- Export Tarihi: ${new Date().toISOString()}
-- ----------------------------------------------------------------

BEGIN;

-- Mevcut tabloları temizleyelim
DROP TABLE IF EXISTS award_types CASCADE;
DROP TABLE IF EXISTS banned_words CASCADE;
DROP TABLE IF EXISTS categories CASCADE;
DROP TABLE IF EXISTS cities CASCADE;
DROP TABLE IF EXISTS city_awards CASCADE;
DROP TABLE IF EXISTS city_events CASCADE;
DROP TABLE IF EXISTS city_projects CASCADE;
DROP TABLE IF EXISTS city_services CASCADE;
DROP TABLE IF EXISTS city_stats CASCADE;
DROP TABLE IF EXISTS comments CASCADE;
DROP TABLE IF EXISTS districts CASCADE;
DROP TABLE IF EXISTS media CASCADE;
DROP TABLE IF EXISTS migrations CASCADE;
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS posts CASCADE;
DROP TABLE IF EXISTS settings CASCADE;
DROP TABLE IF EXISTS survey_options CASCADE;
DROP TABLE IF EXISTS survey_regional_results CASCADE;
DROP TABLE IF EXISTS surveys CASCADE;
DROP TABLE IF EXISTS user_likes CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- Şema oluşturma
${schemaContent}

-- Veri aktarımı
`;

  // Tablo listesi
  const TABLE_LIST = [
    "award_types",
    "banned_words",
    "categories",
    "cities",
    "city_awards",
    "city_events",
    "city_projects",
    "city_services",
    "city_stats",
    "comments",
    "districts",
    "media",
    "migrations",
    "notifications",
    "posts",
    "settings",
    "survey_options",
    "survey_regional_results",
    "surveys",
    "user_likes",
    "users"
  ];
  
  // Her tablo için en son JSON dosyasını bul ve SQL insert ifadelerine dönüştür
  for (const table of TABLE_LIST) {
    console.log(`Tablo işleniyor: ${table}`);
    
    // Son JSON dosyasını bul
    const jsonFiles = fs.readdirSync(EXPORT_DIR)
      .filter(file => file.startsWith(`${table}_`) && file.endsWith('.json'))
      .sort((a, b) => {
        // Dosya adlarını alfabetik olarak sırala (tarih damgasıyla)
        return b.localeCompare(a);
      });
    
    if (jsonFiles.length === 0) {
      console.log(`  Uyarı: ${table} için veri bulunamadı, atlanıyor.`);
      continue;
    }
    
    const latestJsonFile = path.join(EXPORT_DIR, jsonFiles[0]);
    console.log(`  Dosya bulundu: ${latestJsonFile}`);
    
    // JSON verisini oku
    const jsonData = JSON.parse(fs.readFileSync(latestJsonFile, 'utf8'));
    
    if (!jsonData || jsonData.length === 0) {
      console.log(`  Uyarı: ${table} için veri boş, atlanıyor.`);
      continue;
    }
    
    const recordCount = jsonData.length;
    console.log(`  ${recordCount} kayıt okundu`);
    
    // SQL insert ifadelerini oluştur
    sqlContent += `-- ${table} tablosu verileri (${recordCount} kayıt)\n`;
    
    // Sütun listesi
    const columns = Object.keys(jsonData[0]);
    const columnList = columns.map(col => `"${col}"`).join(', ');
    
    // Her 100 kayıt için bir INSERT ifadesi
    const batchSize = 100;
    
    for (let i = 0; i < recordCount; i += batchSize) {
      const batch = jsonData.slice(i, i + batchSize);
      
      if (batch.length === 0) continue;
      
      sqlContent += `INSERT INTO "${table}" (${columnList}) VALUES\n`;
      
      // Satır değerleri
      const values = batch.map(row => {
        const rowValues = columns.map(col => {
          const value = row[col];
          if (value === null) {
            return 'NULL';
          } else if (typeof value === 'boolean') {
            return value ? 'TRUE' : 'FALSE';
          } else if (typeof value === 'number') {
            return value;
          } else {
            // String değerler için özel karakterleri escape et
            return `'${String(value).replace(/'/g, "''")}'`;
          }
        });
        
        return `(${rowValues.join(', ')})`;
      }).join(',\n');
      
      sqlContent += `${values};\n\n`;
    }
  }
  
  // Sequence değerlerini ayarla
  sqlContent += `-- Sequence değerlerini ayarlama\n`;
  
  for (const table of TABLE_LIST) {
    sqlContent += `SELECT setval('${table}_id_seq', COALESCE((SELECT MAX(id) FROM "${table}"), 1), true);\n`;
  }
  
  // Transactionı tamamla
  sqlContent += `\nCOMMIT;\n\n-- Export başarıyla tamamlandı`;
  
  // Dosyaya yaz
  fs.writeFileSync(OUTPUT_FILE, sqlContent);
  
  console.log(`Tam veritabanı dökümü tamamlandı: ${OUTPUT_FILE}`);
  console.log(`Dosya boyutu: ${Math.round(sqlContent.length / 1024)} KB`);
}

main();