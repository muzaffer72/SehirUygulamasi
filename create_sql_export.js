// PostgreSQL veritabanını tek bir SQL dosyasına export et
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
    rejectUnauthorized: false
  }
});

async function exportToSingleSql() {
  console.log('Veritabanı tek bir SQL dosyasına export ediliyor...');
  
  try {
    // Önce tablo listesini al
    const tablesResult = await pool.query(`
      SELECT tablename FROM pg_catalog.pg_tables 
      WHERE schemaname = 'public'
      ORDER BY tablename;
    `);
    
    const tables = tablesResult.rows.map(row => row.tablename);
    console.log(`Toplam ${tables.length} tablo bulundu.`);
    
    // Zaman damgası ile dosya adı oluştur
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
    const sqlFilePath = path.join(EXPORT_DIR, `sikayetvar_complete_${timestamp}.sql`);
    
    // SQL dosyasını oluştur
    let sqlContent = `-- ŞikayetVar Veritabanı Tam Dışa Aktarımı
-- Export Tarihi: ${new Date().toISOString()}
-- --------------------------------------------------\n\n`;
    
    // Veritabanını oluştur
    sqlContent += `-- Veritabanını oluştur (eğer yoksa)
CREATE DATABASE IF NOT EXISTS sikayetvar;
USE sikayetvar;\n\n`;
    
    // PostgreSQL'den MySQL'e uyumlu hale getir
    sqlContent += `-- PostgreSQL'den MySQL'e uyumluluk ayarları
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";\n\n`;
    
    // Her tablo için şema ve veri oluştur
    for (const table of tables) {
      console.log(`Tablo işleniyor: ${table}`);
      
      // 1. Tablo yapısını al
      const tableSchemaQuery = `
        SELECT column_name, data_type, 
               character_maximum_length, 
               is_nullable, 
               column_default
        FROM information_schema.columns
        WHERE table_name = $1
        ORDER BY ordinal_position;
      `;
      
      const schemaResult = await pool.query(tableSchemaQuery, [table]);
      
      // 2. Tablo oluşturma SQL'i oluştur (MySQL uyumlu)
      sqlContent += `-- Tablo yapısı: ${table}\n`;
      sqlContent += `DROP TABLE IF EXISTS \`${table}\`;\n`;
      sqlContent += `CREATE TABLE \`${table}\` (\n`;
      
      // Sütunlar
      const columns = schemaResult.rows.map(column => {
        let columnDef = `  \`${column.column_name}\``;
        
        // Veri tipi dönüşümü (PostgreSQL -> MySQL)
        let dataType = column.data_type.toUpperCase();
        
        // Veri tipi dönüşümleri
        if (dataType === 'TEXT') {
          dataType = 'TEXT';
        } else if (dataType === 'INTEGER') {
          dataType = 'INT';
        } else if (dataType === 'BOOLEAN') {
          dataType = 'TINYINT(1)';
        } else if (dataType === 'TIMESTAMP WITH TIME ZONE') {
          dataType = 'DATETIME';
        } else if (dataType === 'TIMESTAMP WITHOUT TIME ZONE') {
          dataType = 'TIMESTAMP';
        } else if (dataType === 'CHARACTER VARYING') {
          const length = column.character_maximum_length || 255;
          dataType = `VARCHAR(${length})`;
        } else if (dataType === 'DOUBLE PRECISION') {
          dataType = 'DOUBLE';
        } else if (dataType.includes('CHARACTER')) {
          const length = column.character_maximum_length || 255;
          dataType = `CHAR(${length})`;
        }
        
        columnDef += ` ${dataType}`;
        
        // NULL / NOT NULL
        if (column.is_nullable === 'NO') {
          columnDef += ' NOT NULL';
        }
        
        // DEFAULT değeri
        if (column.column_default !== null) {
          let defaultValue = column.column_default;
          
          // Sequence dönüşümlerini atla
          if (!defaultValue.includes('nextval')) {
            // Boolean değerleri uyumlu hale getir
            if (defaultValue === 'true') {
              defaultValue = '1';
            } else if (defaultValue === 'false') {
              defaultValue = '0';
            }
            
            // PostgreSQL özel fonksiyonlarını düzelt
            if (defaultValue.includes('now()')) {
              defaultValue = 'CURRENT_TIMESTAMP';
            }
            
            columnDef += ` DEFAULT ${defaultValue}`;
          }
        }
        
        return columnDef;
      });
      
      // Primary Key ve diğer kısıtlamaları bul
      const constraintsQuery = `
        SELECT
          c.conname as constraint_name,
          c.contype as constraint_type,
          array_to_string(array_agg(a.attname), ', ') as column_names,
          confrelid::regclass as referenced_table,
          array_to_string(array_agg(af.attname), ', ') as referenced_columns
        FROM
          pg_constraint c
          JOIN pg_attribute a ON a.attnum = ANY(c.conkey) AND a.attrelid = c.conrelid
          LEFT JOIN pg_attribute af ON af.attnum = ANY(c.confkey) AND af.attrelid = c.confrelid
        WHERE
          c.conrelid = $1::regclass
        GROUP BY
          c.conname,
          c.contype,
          confrelid
        ORDER BY
          c.contype;
      `;
      
      const constraintsResult = await pool.query(constraintsQuery, [table]);
      
      // Primary Key ve Foreign Key kısıtlamaları ekle
      constraintsResult.rows.forEach(constraint => {
        if (constraint.constraint_type === 'p') { // Primary Key
          columns.push(`  PRIMARY KEY (\`${constraint.column_names}\`)`);
        } else if (constraint.constraint_type === 'f') { // Foreign Key
          // Foreign key için kısıtlamayı MySQL uyumlu şekilde ekle
          columns.push(`  FOREIGN KEY (\`${constraint.column_names}\`) REFERENCES \`${constraint.referenced_table}\` (\`${constraint.referenced_columns}\`)`);
        }
      });
      
      sqlContent += columns.join(',\n');
      sqlContent += `\n) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;\n\n`;
      
      // 3. Tablo verilerini al ve INSERT ifadeleri oluştur
      const dataQuery = `SELECT * FROM "${table}";`;
      const dataResult = await pool.query(dataQuery);
      
      if (dataResult.rows.length > 0) {
        sqlContent += `-- Tablo verisi: ${table}\n`;
        
        // Her satır için INSERT oluştur, 100 satırlık gruplar halinde
        const rowCount = dataResult.rows.length;
        const batchSize = 100;
        
        for (let i = 0; i < rowCount; i += batchSize) {
          const batch = dataResult.rows.slice(i, i + batchSize);
          
          if (batch.length > 0) {
            sqlContent += `INSERT INTO \`${table}\` (`;
            
            // Sütun adlarını ekle
            const columnNames = Object.keys(batch[0])
              .map(col => `\`${col}\``)
              .join(', ');
            
            sqlContent += `${columnNames}) VALUES\n`;
            
            // Satır değerlerini ekle
            const rowValues = batch.map(row => {
              const values = Object.values(row).map(value => {
                if (value === null) {
                  return 'NULL';
                } else if (typeof value === 'boolean') {
                  return value ? '1' : '0';
                } else if (typeof value === 'number') {
                  return value;
                } else if (typeof value === 'object' && value instanceof Date) {
                  return `'${value.toISOString().slice(0, 19).replace('T', ' ')}'`;
                } else {
                  // String için özel karakterleri escape et
                  return `'${String(value).replace(/'/g, "''")}'`;
                }
              });
              
              return `(${values.join(', ')})`;
            }).join(',\n');
            
            sqlContent += `${rowValues};\n\n`;
          }
        }
      }
    }
    
    // SQL dosyasını kaydet
    fs.writeFileSync(sqlFilePath, sqlContent);
    console.log(`SQL dışa aktarımı tamamlandı: ${sqlFilePath}`);
    
    // Dosya boyutunu göster
    const stats = fs.statSync(sqlFilePath);
    const fileSizeInKB = Math.round(stats.size / 1024);
    console.log(`Dosya boyutu: ${fileSizeInKB} KB`);
    
    return sqlFilePath;
  } catch (err) {
    console.error('HATA:', err);
  } finally {
    pool.end();
  }
}

// Export işlemini başlat
exportToSingleSql();