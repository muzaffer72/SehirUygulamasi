#!/bin/bash

# Bu script, yeni oluşturulan Flutter projesini eski projenin yerine taşır
# Çalıştırma: bash replace_project.sh

echo "Proje Değiştirme Script'i"
echo "=========================="

if [ ! -d "new_project" ]; then
  echo "Hata: new_project klasörü bulunamadı!"
  exit 1
fi

if [ ! -d "lib" ]; then
  echo "Hata: Ana proje klasörü (lib) bulunamadı!"
  exit 1
fi

# Mevcut projeyi yedekle
echo "Mevcut proje yedekleniyor..."
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="old_project_backup_$TIMESTAMP"
mkdir -p $BACKUP_DIR

# Yedeklenecek önemli klasörler
cp -r lib $BACKUP_DIR/
cp -r android $BACKUP_DIR/ 2>/dev/null || echo "android klasörü kopyelanamadı"
cp -r ios $BACKUP_DIR/ 2>/dev/null || echo "ios klasörü kopyelanamadı"
cp -r web $BACKUP_DIR/ 2>/dev/null || echo "web klasörü kopyelanamadı"
cp -r assets $BACKUP_DIR/ 2>/dev/null || echo "assets klasörü kopyelanamadı"
cp pubspec.yaml $BACKUP_DIR/ 2>/dev/null || echo "pubspec.yaml kopyelanamadı"
cp pubspec.lock $BACKUP_DIR/ 2>/dev/null || echo "pubspec.lock kopyelanamadı"

echo "Yeni Flutter projesinden gerekli dosyalar taşınıyor..."

# Android klasörünü değiştir
if [ -d "android" ]; then
  rm -rf android
fi
cp -r new_project/android .

# Pubspec dosyalarını güncelle ve bağımlılıkları yükle
cp new_project/pubspec.yaml .
cp new_project/pubspec.lock . 2>/dev/null || echo "pubspec.lock bulunamadı"

# Tüm model dosyalarını taşı
echo "Model dosyaları taşınıyor..."
mkdir -p lib/models
cp -r new_project/lib/models/* lib/models/ 2>/dev/null || echo "Model dosyaları bulunamadı"

echo "Flutter bağımlılıkları yükleniyor..."
flutter clean
flutter pub get

echo "İşlem tamamlandı!"
echo "Yedeklenen dosyalar: $BACKUP_DIR"
echo "Artık 'flutter build apk' komutu ile APK oluşturabilirsiniz."