#!/bin/bash

# Bu script, tüm Gradle ayarlarını düzenleyerek APK build eder
# Çalıştırma: bash flutter_build_apk.sh

echo "Flutter APK Build Script"
echo "======================="

# Önce Flutter projesini düzelt
bash flutter_fix.sh

# APK'yı build et
echo "APK derleniyor..."
cd new_project
flutter build apk --release

if [ $? -eq 0 ]; then
  echo "APK başarıyla derlendi!"
  echo "APK dosyası: new_project/build/app/outputs/flutter-apk/app-release.apk"
  
  # APK'yı ana dizine kopyala
  mkdir -p ../build/apk
  cp build/app/outputs/flutter-apk/app-release.apk ../build/apk/belediye_iletisim.apk
  
  echo "APK ana dizine kopyalandı: build/apk/belediye_iletisim.apk"
else
  echo "APK derlenirken hata oluştu!"
fi