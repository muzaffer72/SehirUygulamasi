#!/bin/bash

# Flutter APK yapılandırma ve build script'i
echo "Flutter APK oluşturma başlatılıyor..."
echo "=====================================\n"

# Proje dizinine git
cd new_project

# Flutter paketlerini güncelle
echo "Flutter paketleri yükleniyor..."
flutter pub get

# Temiz build için önce eski build dosyalarını temizle
echo "Eski build dosyaları temizleniyor..."
flutter clean

# Debug APK oluştur
echo "Debug APK oluşturuluyor..."
flutter build apk --debug

# APK'nın oluşturulup oluşturulmadığını kontrol et
APK_PATH="./build/app/outputs/flutter-apk/app-debug.apk"
if [ -f "$APK_PATH" ]; then
    echo "\n✅ APK başarıyla oluşturuldu: $APK_PATH"
    echo "APK Dosya Boyutu: $(du -h $APK_PATH | cut -f1)"
    echo "\nUYGULAMA BİLGİLERİ:"
    echo "===================="
    echo "Paket adı: belediye.iletisim.merkezi"
    echo "Versiyon: $(grep "version:" pubspec.yaml | head -1 | awk '{print $2}')"
    echo "Min SDK: 21 (Android 5.0 Lollipop)"
    echo "Target SDK: 33 (Android 13)"
else
    echo "\n❌ APK oluşturulamadı. Hata mesajlarını kontrol edin."
fi

echo "\nİşlem tamamlandı."