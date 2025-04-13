// Tam veritabanı kopyası oluştur (hiçbir kayıt atlanmadan)
require('dotenv').config();
const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');

// Veritabanı bağlantısı
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: {
    rejectUnauthorized: false
  }
});

async function createFullDatabaseExport() {
  console.log('Tam veritabanı dökümü başlatılıyor...');
  
  try {
    // Tüm tabloları al
    const tablesResult = await pool.query(`
      SELECT tablename FROM pg_catalog.pg_tables 
      WHERE schemaname = 'public'
      ORDER BY tablename;
    `);
    
    const tables = tablesResult.rows.map(row => row.tablename);
    console.log(`Toplam ${tables.length} tablo bulundu.`);

    // Sonuç SQL dosyası
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
    const outputFile = `sikayetvar_tam_export_${timestamp}.sql`;
    
    // SQL başlık
    let sqlContent = `-- ŞikayetVar Veritabanı TAM KOPYA
-- Export Tarihi: ${new Date().toISOString()}
-- ----------------------------------------------------------------

BEGIN;

-- Mevcut tabloları temizleyelim
`;

    // Silme sıralaması için tabloları foreign key ilişkilerine göre sırala
    // Önce bağımlı tablolar silinmeli
    const dropOrder = [...tables].reverse();
    
    // Tüm tabloları sil (CASCADE ile)
    for (const table of dropOrder) {
      sqlContent += `DROP TABLE IF EXISTS "${table}" CASCADE;\n`;
    }
    
    sqlContent += `\n-- Şema oluşturma\n`;
    
    // Tabloları oluşturma sırası
    for (const table of tables) {
      console.log(`"${table}" tablosu şeması oluşturuluyor...`);
      
      // Tablo şemasını al
      const schemaQuery = await pool.query(`
        SELECT pg_get_tabledef('${table}'::regclass::oid);
      `);
      
      let tableSchema = schemaQuery.rows[0].pg_get_tabledef;
      
      // "IF NOT EXISTS" ekle
      tableSchema = tableSchema.replace(
        /CREATE TABLE ([a-z_"]+)/i, 
        'CREATE TABLE IF NOT EXISTS $1'
      );
      
      sqlContent += `${tableSchema}\n\n`;
    }
    
    // Foreign key kısıtlamalarını al
    console.log('Foreign key kısıtlamaları alınıyor...');
    const fkQuery = await pool.query(`
      SELECT
        tc.table_name,
        kcu.column_name,
        ccu.table_name AS foreign_table_name,
        ccu.column_name AS foreign_column_name,
        tc.constraint_name
      FROM
        information_schema.table_constraints tc
        JOIN information_schema.key_column_usage kcu
          ON tc.constraint_name = kcu.constraint_name
          AND tc.table_schema = kcu.table_schema
        JOIN information_schema.constraint_column_usage ccu
          ON ccu.constraint_name = tc.constraint_name
          AND ccu.table_schema = tc.table_schema
      WHERE tc.constraint_type = 'FOREIGN KEY';
    `);
    
    // Veri ekleme
    sqlContent += `-- Veri aktarımı\n`;
    
    for (const table of tables) {
      console.log(`"${table}" tablosu verileri alınıyor...`);
      
      // Tablodaki tüm verileri al
      const dataQuery = await pool.query(`SELECT * FROM "${table}";`);
      const rows = dataQuery.rows;
      
      if (rows.length > 0) {
        sqlContent += `-- ${table} tablosu verileri (${rows.length} kayıt)\n`;
        
        // Sütun listesi
        const columns = Object.keys(rows[0]);
        const columnList = columns.map(col => `"${col}"`).join(', ');
        
        // Her 100 kayıt için bir INSERT ifadesi
        const batchSize = 100;
        
        for (let i = 0; i < rows.length; i += batchSize) {
          const batch = rows.slice(i, i + batchSize);
          
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
              } else if (value instanceof Date) {
                return `'${value.toISOString()}'`;
              } else {
                // String değerler için özel karakterleri escape et
                return `'${value.toString().replace(/'/g, "''")}'`;
              }
            });
            
            return `(${rowValues.join(', ')})`;
          }).join(',\n');
          
          sqlContent += `${values};\n\n`;
        }
      } else {
        sqlContent += `-- ${table} tablosu boş\n\n`;
      }
    }
    
    // Sequence değerlerini ayarla
    sqlContent += `-- Sequence değerlerini ayarlama\n`;
    
    for (const table of tables) {
      // ID sütunu olan tablolar için sequence güncelle
      const idCheckQuery = await pool.query(`
        SELECT column_name 
        FROM information_schema.columns 
        WHERE table_name = $1 AND column_name = 'id';
      `, [table]);
      
      if (idCheckQuery.rows.length > 0) {
        sqlContent += `SELECT setval('${table}_id_seq', COALESCE((SELECT MAX(id) FROM "${table}"), 1), true);\n`;
      }
    }
    
    // Transactionı tamamla
    sqlContent += `\nCOMMIT;\n\n-- Export başarıyla tamamlandı`;
    
    // Dosyaya yaz
    fs.writeFileSync(outputFile, sqlContent);
    
    console.log(`Tam veritabanı dökümü tamamlandı: ${outputFile}`);
    console.log(`Dosya boyutu: ${Math.round(sqlContent.length / 1024)} KB`);
    
    return outputFile;
  } catch (err) {
    console.error('HATA:', err);
  } finally {
    await pool.end();
  }
}

// pg_get_tabledef fonksiyonunu oluştur - şema almak için
async function createHelperFunctions() {
  try {
    await pool.query(`
      CREATE OR REPLACE FUNCTION pg_get_tabledef(p_table_oid oid)
      RETURNS text AS
      $BODY$
      DECLARE
        v_table_name text;
        v_table_schema text;
        v_owner text;
        v_result text;
        v_columns text;
        v_constraints text;
        v_indexes text;
        v_comment text;
        v_sequence text;
        v_row record;
      BEGIN
        -- Tablo adı ve şema bilgisini al
        SELECT n.nspname, c.relname, u.rolname
        INTO v_table_schema, v_table_name, v_owner
        FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        JOIN pg_roles u ON u.oid = c.relowner
        WHERE c.oid = p_table_oid;
        
        -- Başlık
        v_result := 'CREATE TABLE ' || v_table_schema || '.' || v_table_name || ' (';
        
        -- Sütunlar
        v_columns := '';
        FOR v_row IN (
          SELECT
            a.attname AS column_name,
            pg_catalog.format_type(a.atttypid, a.atttypmod) AS data_type,
            CASE WHEN a.attnotnull THEN 'NOT NULL' ELSE 'NULL' END AS nullable,
            CASE 
              WHEN a.atthasdef THEN pg_get_expr(d.adbin, d.adrelid)
              ELSE NULL
            END AS default_expr,
            col_description(a.attrelid, a.attnum) AS comment
          FROM pg_attribute a
          LEFT JOIN pg_attrdef d ON a.attrelid = d.adrelid AND a.attnum = d.adnum
          WHERE a.attrelid = p_table_oid
          AND a.attnum > 0
          AND NOT a.attisdropped
          ORDER BY a.attnum
        ) LOOP
          IF v_columns <> '' THEN
            v_columns := v_columns || ',
  ';
          END IF;
          
          v_columns := v_columns || v_row.column_name || ' ' || v_row.data_type;
          
          IF v_row.nullable = 'NOT NULL' THEN
            v_columns := v_columns || ' NOT NULL';
          END IF;
          
          IF v_row.default_expr IS NOT NULL THEN
            v_columns := v_columns || ' DEFAULT ' || v_row.default_expr;
          END IF;
        END LOOP;
        
        -- Kısıtlamalar (constraints)
        v_constraints := '';
        FOR v_row IN (
          SELECT
            c.conname AS constraint_name,
            pg_get_constraintdef(c.oid) AS constraint_def
          FROM pg_constraint c
          WHERE c.conrelid = p_table_oid
          AND c.contype IN ('p', 'u', 'f', 'c')
          ORDER BY c.contype
        ) LOOP
          v_constraints := v_constraints || ',
  CONSTRAINT ' || v_row.constraint_name || ' ' || v_row.constraint_def;
        END LOOP;
        
        -- Tablo tanımını tamamla
        v_result := v_result || '
  ' || v_columns || v_constraints || '
);';
        
        RETURN v_result;
      END;
      $BODY$
      LANGUAGE plpgsql;
    `);
    
    console.log('Yardımcı fonksiyonlar oluşturuldu.');
  } catch (err) {
    console.error('HATA:', err);
  }
}

// Ana fonksiyon
async function main() {
  await createHelperFunctions();
  await createFullDatabaseExport();
}

main();