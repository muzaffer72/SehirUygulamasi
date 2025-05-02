#!/bin/bash

echo "Flutter Local Notifications hatasını düzeltme başlıyor..."

# Paketi kaldırma
flutter pub remove flutter_local_notifications

# Dosyaları temizleme
echo "Önbellek temizleniyor..."
flutter clean

# Alt dizini temizleme
rm -rf ~/.pub-cache/hosted/pub.dev/flutter_local_notifications-14.1.5

# Eski sürümü yükleme
echo "Eski stabil sürüm (9.9.1) yükleniyor..."
flutter pub add flutter_local_notifications:9.9.1

# Bağımlılıkları yenileme
echo "Bağımlılıklar yenileniyor..."
flutter pub get

echo "İşlem tamamlandı! Şimdi uygulamayı tekrar derlemeyi deneyin."