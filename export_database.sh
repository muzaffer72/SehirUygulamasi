#!/bin/bash

# PostgreSQL veritabanı export script'i
# Bu script sikayetvar_full_database_export.zip dosyasını 
# veritabanı şeması (tablolar) ve verilerini ayrı ayrı içeren 
# dosyalar halinde dışa aktarır

# Renk kodları
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Zaman damgası oluştur
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
EXPORT_DIR="sikayetvar_export"

# Export klasörü oluştur
mkdir -p $EXPORT_DIR

echo -e "${GREEN}========================================================${NC}"
echo -e "${BLUE}ŞikayetVar Veritabanı PostgreSQL Export${NC} ${YELLOW}$TIMESTAMP${NC}"
echo -e "${GREEN}========================================================${NC}"

# Veritabanı bağlantı bilgileri
DB_URL=$DATABASE_URL
DB_NAME=${PGDATABASE:-neondb}
DB_USER=${PGUSER:-belediye}
DB_HOST=${PGHOST:-109.71.252.34}
DB_PORT=${PGPORT:-5432}

echo -e "${CYAN}Bağlantı bilgileri kullanılıyor...${NC}"
echo -e "  Veritabanı: ${YELLOW}$DB_NAME${NC}"
echo -e "  Sunucu: ${YELLOW}$DB_HOST:$DB_PORT${NC}"

# Şema oluşturma SQL dosyasını kopyala
echo -e "${CYAN}Veritabanı şeması hazırlanıyor...${NC}"
cp schema_dump.sql $EXPORT_DIR/01_schema.sql
echo -e "${GREEN}✓${NC} Veritabanı şeması oluşturuldu: ${YELLOW}$EXPORT_DIR/01_schema.sql${NC}"

# En son export edilen JSON dosyalarını bul
echo -e "${CYAN}Tablo verileri hazırlanıyor...${NC}"
LATEST_EXPORT=$(ls -t export_data/full_export_*.json | head -1)

if [ -z "$LATEST_EXPORT" ]; then
  echo -e "${RED}HATA:${NC} Dışa aktarılmış veri bulunamadı! Önce veritabanı verilerini export edin."
  exit 1
fi

echo -e "${GREEN}✓${NC} En son export bulundu: ${YELLOW}$LATEST_EXPORT${NC}"
cp $LATEST_EXPORT $EXPORT_DIR/raw_data.json

# PostgreSQL için data import SQL dosyası oluştur
echo -e "${CYAN}Veri import SQL dosyası oluşturuluyor...${NC}"

# Table göre dışa aktarılmış JSON dosyalarını bul ve import SQL dosyaları oluştur
echo -e "-- ŞikayetVar Veri Import" > $EXPORT_DIR/02_data.sql
echo -e "-- Export Tarihi: $TIMESTAMP" >> $EXPORT_DIR/02_data.sql
echo -e "-- ---------------------------------------------------\n" >> $EXPORT_DIR/02_data.sql

# Tablo listesini belirle (her tabloya göre JSON dosyasını bul)
TABLE_LIST=(
  "award_types"
  "banned_words"
  "categories"
  "cities"
  "city_awards"
  "city_events"
  "city_projects"
  "city_services"
  "city_stats"
  "comments"
  "districts"
  "media"
  "migrations"
  "notifications"
  "posts"
  "settings"
  "survey_options"
  "survey_regional_results"
  "surveys"
  "user_likes"
  "users"
)

# Her tablo için son JSON dosyasını bul ve SQL insert ifadelerine dönüştür
for TABLE in "${TABLE_LIST[@]}"; do
  echo -e "  Tablo işleniyor: ${YELLOW}$TABLE${NC}"
  
  # Son JSON dosyasını bul
  LATEST_TABLE_JSON=$(ls -t export_data/${TABLE}_*.json | head -1)
  
  if [ -z "$LATEST_TABLE_JSON" ]; then
    echo -e "  ${YELLOW}Uyarı:${NC} $TABLE için veri bulunamadı, atlanıyor."
    continue
  fi
  
  # Tablo verilerini temizle
  echo -e "-- $TABLE verilerini temizle" >> $EXPORT_DIR/02_data.sql
  echo -e "DELETE FROM $TABLE;" >> $EXPORT_DIR/02_data.sql
  echo -e "-- $TABLE verilerini import et" >> $EXPORT_DIR/02_data.sql
  
  # Bu JSON dosyasından SQL insert ifadeleri oluştur
  # Basit bir Python script kullanarak JSON'dan SQL'e dönüştürme
  python -c "
import json
import sys
import os

try:
    with open('$LATEST_TABLE_JSON', 'r') as f:
        data = json.load(f)
    
    if not data or len(data) == 0:
        sys.exit(0)
    
    # Tablo adını belirle
    table_name = '$TABLE'
    
    # Her veri satırı için INSERT oluştur
    batch_size = 100  # Her seferde 100 satır ekle
    records = data
    record_count = len(records)
    
    for i in range(0, record_count, batch_size):
        batch = records[i:i+batch_size]
        if not batch:
            continue
            
        # İlk satırdan sütun adlarını al
        columns = batch[0].keys()
        column_list = ', '.join(columns)
        
        # VALUES kısmını oluştur
        values_list = []
        for record in batch:
            values = []
            for col in columns:
                val = record.get(col)
                if val is None:
                    values.append('NULL')
                elif isinstance(val, bool):
                    values.append('TRUE' if val else 'FALSE')
                elif isinstance(val, (int, float)):
                    values.append(str(val))
                else:
                    # String değerleri escape et
                    escaped = str(val).replace(\"'\", \"''\")
                    values.append(f\"'{escaped}'\")
            
            values_list.append('(' + ', '.join(values) + ')')
        
        # SQL ifadesini oluştur
        insert_sql = f\"INSERT INTO {table_name} ({column_list}) VALUES\\n\"
        insert_sql += ',\\n'.join(values_list) + ';\\n'
        
        # SQL dosyasına yaz
        with open('$EXPORT_DIR/02_data.sql', 'a') as sql_file:
            sql_file.write(insert_sql + '\\n')
    
    print(f'  {record_count} kayıt işlendi')
except Exception as e:
    print(f'Hata: {str(e)}')
    sys.exit(1)
" || {
    echo -e "  ${RED}HATA:${NC} $TABLE işlenirken hata oluştu."
    continue
  }
  
  echo -e "  ${GREEN}✓${NC} $TABLE işlendi."
done

# Sequence'leri sıfırla
echo -e "${CYAN}Sequence değerleri yeniden düzenleniyor...${NC}"
echo -e "\n-- Sequence değerlerini tablolardaki en yüksek ID değerine göre yeniden düzenle" >> $EXPORT_DIR/03_sequences.sql

for TABLE in "${TABLE_LIST[@]}"; do
  echo -e "SELECT setval('${TABLE}_id_seq', COALESCE((SELECT MAX(id) FROM ${TABLE}), 1), true);" >> $EXPORT_DIR/03_sequences.sql
done

echo -e "${GREEN}✓${NC} Sequence güncellemeleri hazırlandı: ${YELLOW}$EXPORT_DIR/03_sequences.sql${NC}"

# Tüm dosyaları birleştir
cat $EXPORT_DIR/01_schema.sql $EXPORT_DIR/02_data.sql $EXPORT_DIR/03_sequences.sql > $EXPORT_DIR/sikayetvar_postgres_full_${TIMESTAMP}.sql

# Sonuçları göster
echo -e "\n${GREEN}========================================================${NC}"
echo -e "${GREEN}Export işlemi tamamlandı!${NC}"
echo -e "${GREEN}========================================================${NC}"
echo -e "Şema dosyası: ${YELLOW}$EXPORT_DIR/01_schema.sql${NC}"
echo -e "Veri dosyası: ${YELLOW}$EXPORT_DIR/02_data.sql${NC}"
echo -e "Sequence dosyası: ${YELLOW}$EXPORT_DIR/03_sequences.sql${NC}"
echo -e "Tam veritabanı dump: ${YELLOW}$EXPORT_DIR/sikayetvar_postgres_full_${TIMESTAMP}.sql${NC}"

# Dosyaları zip'le
echo -e "\n${CYAN}Dosyalar arşivleniyor...${NC}"
cd $EXPORT_DIR
zip -r ../sikayetvar_postgres_export_${TIMESTAMP}.zip *
cd ..

echo -e "${GREEN}✓${NC} Arşiv oluşturuldu: ${YELLOW}sikayetvar_postgres_export_${TIMESTAMP}.zip${NC}"