#!/bin/bash

# Flutter Local Notifications paketi için geçici çözüm

echo "Flutter Local Notifications sorunu için geçici çözüm uygulanıyor..."

# Flutter Local Notifications sınıfında düzeltme yapılacak dosyanın yolunu bulma
NOTIFICATION_FILE=$(find ~/.pub-cache -name "FlutterLocalNotificationsPlugin.java" | grep "flutter_local_notifications")

if [ -z "$NOTIFICATION_FILE" ]; then
  echo "Flutter Local Notifications paketi bulunamadı."
  exit 1
fi

echo "Dosya bulundu: $NOTIFICATION_FILE"

# Dosyanın yedeğini alma
cp "$NOTIFICATION_FILE" "${NOTIFICATION_FILE}.backup"

# Sorunlu satırı düzeltme
sed -i 's/bigPictureStyle.bigLargeIcon(null);/bigPictureStyle.bigLargeIcon((Bitmap) null);/g' "$NOTIFICATION_FILE"

echo "Flutter Local Notifications sorunu için geçici çözüm uygulandı."
echo "Orijinal dosya yedeklendi: ${NOTIFICATION_FILE}.backup"

# Android Studio'da Gradle sürümüyle ilgili parametreler 
echo "Android Gradle ayarlarında uyumluluk düzeltmeleri yapılıyor..."

# android/build.gradle dosyasındaki Gradle versiyonunu güncelleme
if [ -f "android/build.gradle" ]; then
  sed -i 's/gradle:.*"/gradle:7.3.0"/g' android/build.gradle
  sed -i 's/distributionUrl=.*/distributionUrl=https:\\\/\\\/services.gradle.org\\\/distributions\\\/gradle-7.5-all.zip/g' android/gradle/wrapper/gradle.properties
  echo "Gradle versiyonu güncellendi."
fi

echo "Düzeltmeler tamamlandı. Şimdi 'flutter clean' ve 'flutter pub get' komutlarını çalıştırıp yeniden derlemeyi deneyin."