#!/bin/bash

# PostgreSQL veritabanını tam olarak export et
echo "ŞikayetVar - PostgreSQL veritabanı full export işlemi başlatılıyor..."
echo "--------------------------------------------------------------------------------"

# Export dosyası için klasör oluştur
export_dir="export_data"
mkdir -p $export_dir

# Zaman damgası oluştur
timestamp=$(date +"%Y%m%d_%H%M%S")
export_file="${export_dir}/sikayetvar_full_backup_${timestamp}.sql"

# pg_dump ile tam export
echo "Veritabanı export ediliyor: $export_file"
PGPASSWORD=$PGPASSWORD pg_dump \
  --host=$PGHOST \
  --port=$PGPORT \
  --username=$PGUSER \
  --dbname=$PGDATABASE \
  --verbose \
  --format=p \
  --file=$export_file

# Export durumunu kontrol et
if [ $? -eq 0 ]; then
  echo "Veritabanı başarıyla export edildi: $export_file"
  # Boyutu göster
  size=$(du -h $export_file | cut -f1)
  echo "Dosya boyutu: $size"
  echo "Export işlemi tamamlandı!"
else
  echo "HATA: Veritabanı export edilemedi."
  exit 1
fi

# Tek tablo çekme örneği (isteğe bağlı kullanım için)
echo -e "\nTek tablo export etme (isteğe bağlı):"
echo "PGPASSWORD=\$PGPASSWORD pg_dump --host=\$PGHOST --port=\$PGPORT --username=\$PGUSER --dbname=\$PGDATABASE --table=cities --file=cities_export.sql"