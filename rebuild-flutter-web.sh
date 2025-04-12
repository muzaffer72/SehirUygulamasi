#!/bin/bash
# Flutter web uygulamasını yeniden inşa eden script

# Önbelleği temizle
flutter clean

# Bağımlılıkları güncelle
flutter pub get

# Web için derleme yap
flutter build web --web-renderer html --release

# Derlenen dosyaların listesini göster
ls -la build/web

# Derlenen dosyaları web klasörüne kopyala
cp -r build/web/* web/

echo "Flutter web derlemesi tamamlandı ve dosyalar web klasörüne kopyalandı"