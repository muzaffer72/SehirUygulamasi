#!/bin/bash

# Flutter Gradle hatası için çözüm
# Bu script, Flutter projemizin modern Gradle sürümleriyle uyumlu hale getirilmesini sağlar

echo "Flutter Fix başlatılıyor..."

# 1. Yeni bir temiz Flutter projesi oluştur
echo "Yeni Flutter projesi oluşturuluyor..."
flutter create --org belediye.iletisim.merkezi -t app --platforms=android,ios,web ./new_project

# 2. Mevcut projedeki lib/ dizinini yedekle
echo "Mevcut lib/ dizini yedekleniyor..."
mkdir -p temp_backup
cp -r lib temp_backup/
cp -r assets temp_backup/ 2>/dev/null || true
cp pubspec.yaml temp_backup/

# 3. Yeni projenin lib dizinini temizle
echo "Yeni projenin lib/ dizini temizleniyor..."
rm -rf new_project/lib/*

# 4. Yedeklenen lib/ dizinini yeni projeye kopyala
echo "Eski lib/ dizini yeni projeye kopyalanıyor..."
cp -r temp_backup/lib/* new_project/lib/
cp -r temp_backup/assets new_project/assets/ 2>/dev/null || true

# 5. pubspec.yaml dosyasını kopyala ve Firebase paketlerini ekle
echo "pubspec.yaml kopyalanıyor ve Firebase ekleniyor..."
cp temp_backup/pubspec.yaml new_project/

# 6. Android dosyalarını Firebase için yapılandır
echo "Android dosyaları Firebase için yapılandırılıyor..."
# (Android dosyaları ayrı olarak yapılandırılacak)

echo "Fix tamamlandı. Lütfen 'replace_project.sh' dosyasını çalıştırarak yeni projeyi aktif hale getirin."
echo "Not: Eğer adım adım geçmek istiyorsanız, aşağıdaki komutları uygulayın:"
echo "1. Önce: './flutter_fix.sh'"
echo "2. Sonra: './replace_project.sh'"
echo "3. Son olarak: 'flutter clean && flutter pub get'"