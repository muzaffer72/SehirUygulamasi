// Tüm PostgreSQL tablolarını export etmek için Node.js script'i
require('dotenv').config();
const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');

// Export klasörü
const EXPORT_DIR = 'export_data';
if (!fs.existsSync(EXPORT_DIR)) {
  fs.mkdirSync(EXPORT_DIR);
}

// Veritabanı bağlantısı
const pool = new Pool({
  user: process.env.PGUSER,
  host: process.env.PGHOST,
  database: process.env.PGDATABASE,
  password: process.env.PGPASSWORD,
  port: process.env.PGPORT,
  ssl: {
    rejectUnauthorized: false // SSL sertifika doğrulamasını devre dışı bırak
  }
});

// Tüm tabloları bul ve export et
async function exportAllTables() {
  console.log('Veritabanındaki tüm tablolar export ediliyor...');
  
  try {
    // Önce tablo listesini al
    const tablesResult = await pool.query(`
      SELECT tablename FROM pg_catalog.pg_tables 
      WHERE schemaname = 'public'
      ORDER BY tablename;
    `);
    
    const tables = tablesResult.rows.map(row => row.tablename);
    console.log(`Toplam ${tables.length} tablo bulundu.`);
    
    // Her tabloyu export et
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
    const fullExportPath = path.join(EXPORT_DIR, `full_export_${timestamp}.json`);
    const exportData = {};
    
    for (const table of tables) {
      console.log(`Export ediliyor: ${table}`);
      const result = await pool.query(`SELECT * FROM "${table}"`);
      exportData[table] = result.rows;
      
      // Her tabloyu ayrı dosyaya da kaydet
      const tablePath = path.join(EXPORT_DIR, `${table}_${timestamp}.json`);
      fs.writeFileSync(tablePath, JSON.stringify(result.rows, null, 2));
      console.log(`Tablo kaydedildi: ${tablePath}`);
    }
    
    // Tüm verileri tek bir dosyaya kaydet
    fs.writeFileSync(fullExportPath, JSON.stringify(exportData, null, 2));
    console.log(`\nTüm tablolar tek dosyaya kaydedildi: ${fullExportPath}`);
    
    // Tablo şema bilgilerini de export et
    await exportSchemaInfo();
    
    console.log('\nVeri export işlemi tamamlandı!');
  } catch (err) {
    console.error('HATA:', err);
  } finally {
    pool.end();
  }
}

// Veritabanı şema bilgilerini export et
async function exportSchemaInfo() {
  try {
    console.log('\nVeritabanı şema bilgileri export ediliyor...');
    
    // Tabloların yapısını al
    const schemaQuery = `
      SELECT 
        t.table_name, 
        c.column_name, 
        c.data_type, 
        c.character_maximum_length,
        c.column_default,
        c.is_nullable,
        tc.constraint_type,
        ccu.table_name AS foreign_table_name,
        ccu.column_name AS foreign_column_name
      FROM 
        information_schema.tables t
      LEFT JOIN 
        information_schema.columns c ON t.table_name = c.table_name
      LEFT JOIN 
        information_schema.table_constraints tc ON tc.table_name = c.table_name
      LEFT JOIN 
        information_schema.constraint_column_usage AS ccu ON ccu.constraint_name = tc.constraint_name
      WHERE 
        t.table_schema = 'public'
      ORDER BY 
        t.table_name, c.ordinal_position;
    `;
    
    const schemaResult = await pool.query(schemaQuery);
    
    // Şema bilgilerini kaydet
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
    const schemaPath = path.join(EXPORT_DIR, `schema_info_${timestamp}.json`);
    fs.writeFileSync(schemaPath, JSON.stringify(schemaResult.rows, null, 2));
    console.log(`Şema bilgileri kaydedildi: ${schemaPath}`);
    
    // SQL oluşturmak için
    const sqlSchemaPath = path.join(EXPORT_DIR, `schema_dump_${timestamp}.sql`);
    const createTableQuery = `
      SELECT 
        'CREATE TABLE IF NOT EXISTS ' || table_name || ' (' ||
        string_agg(
          column_name || ' ' || data_type || 
          CASE WHEN character_maximum_length IS NOT NULL 
            THEN '(' || character_maximum_length || ')' 
            ELSE '' 
          END || 
          CASE WHEN is_nullable = 'NO' 
            THEN ' NOT NULL' 
            ELSE '' 
          END || 
          CASE WHEN column_default IS NOT NULL 
            THEN ' DEFAULT ' || column_default 
            ELSE '' 
          END,
          ', '
        ) || ');' as create_table_sql
      FROM 
        information_schema.columns
      WHERE 
        table_schema = 'public'
      GROUP BY 
        table_name;
    `;
    
    const tableQueries = await pool.query(createTableQuery);
    
    // CREATE TABLE ifadelerini dosyaya yaz
    let sqlSchema = '-- SikayetVar veritabanı şema dökümü\n\n';
    tableQueries.rows.forEach(row => {
      sqlSchema += row.create_table_sql + '\n\n';
    });
    
    fs.writeFileSync(sqlSchemaPath, sqlSchema);
    console.log(`SQL şema dökümü kaydedildi: ${sqlSchemaPath}`);
    
  } catch (err) {
    console.error('Şema bilgisi export edilirken hata:', err);
  }
}

// Export işlemini başlat
exportAllTables();