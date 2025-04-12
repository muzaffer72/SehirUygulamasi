#!/bin/bash

# Veritabanı bağlantı detayları
DB_HOST=$PGHOST
DB_PORT=$PGPORT
DB_USER=$PGUSER
DB_PASSWORD=$PGPASSWORD
DB_NAME=$PGDATABASE

# Tarih bilgisi ekleyerek dosya adı oluştur
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="sikayetvar_export_${TIMESTAMP}.sql"

echo "Veritabanı yedekleme işlemi başlıyor..."
echo "Veritabanı: $DB_NAME"
echo "Dışa aktarım dosyası: $BACKUP_FILE"

# PostgreSQL pg_dump aracını kullanarak yedek al
PGPASSWORD=$DB_PASSWORD pg_dump -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -F p -f $BACKUP_FILE

# İşlem başarılı mı kontrol et
if [ $? -eq 0 ]; then
  echo "Yedekleme işlemi başarıyla tamamlandı."
  echo "Yedek dosyası: $BACKUP_FILE"
  echo "Dosya boyutu: $(du -h $BACKUP_FILE | cut -f1)"
else
  echo "Yedekleme işlemi sırasında bir hata oluştu."
fi