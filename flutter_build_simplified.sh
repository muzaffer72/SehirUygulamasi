#!/bin/bash

# Flutter APK basitleştirilmiş build script

# Proje dizinine git
cd new_project

# Flutter paketleri ve Android Gradle düzenlemeleri
echo "============================================================"
echo "ŞikayetVar Android Uygulaması Derleyici"
echo "============================================================"
echo ""
echo "1. Flutter paketlerini temizliyorum..."
flutter clean

echo ""
echo "2. Flutter paketlerini güncelliyorum..."
flutter pub get

echo ""
echo "3. Debug APK oluşturuyorum..."
flutter build apk --debug

echo ""
echo "4. İşlemin sonucu kontrol ediliyor..."
APK_PATH="./build/app/outputs/flutter-apk/app-debug.apk"

if [ -f "$APK_PATH" ]; then
    echo "✅ Debug APK başarıyla oluşturuldu!"
    echo "APK konumu: $APK_PATH"
    echo "APK boyutu: $(du -h $APK_PATH | cut -f1)"
    echo ""
    echo "Bu APK dosyası emülatör veya gerçek cihaza yüklenebilir."
    echo "ADB ile yüklemek için: adb install -r $APK_PATH"
else
    echo "❌ APK oluşturulamadı!"
    echo "Hata detayları için yukarıdaki log mesajlarını kontrol edin."
fi