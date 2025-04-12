#!/bin/bash

# Flutter Web sürümünü yeniden derle
echo "Flutter Web sürümünü derleniyor..."

# Flutter cache temizle
flutter clean

# Flutter web paketlerini güncelle
flutter pub get

# Web için derle
flutter build web --release

# Build klasörünü web-server için erişilebilir yap
if [ -d "build/web" ]; then
  echo "Web build klasörü 'build/web' başarıyla oluşturuldu."
  
  # Web build dosyalarını public_html klasörüne kopyala (web-server bunu kullanıyor)
  mkdir -p public_html
  cp -r build/web/* public_html/
  
  echo "Build dosyaları public_html klasörüne kopyalandı."
  echo "Web uygulaması http://0.0.0.0:5000 adresinde çalışıyor."
else
  echo "HATA: Web build klasörü oluşturulamadı!"
fi