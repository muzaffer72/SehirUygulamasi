#!/bin/bash

# flutter_local_notifications paketini düzeltme script'i
echo "Flutter Local Notifications paketini düzeltme işlemi başlatılıyor..."

# Flutter cache klasörünü bul
HOME_DIR="$HOME"
FLUTTER_DIR="$HOME_DIR/.pub-cache/hosted/pub.dev/flutter_local_notifications-9.9.1"

# Eğer flutter klasörü bulunamazsa, farklı yolları dene
if [ ! -d "$FLUTTER_DIR" ]; then
    FLUTTER_DIR="$HOME_DIR/snap/flutter/common/flutter/.pub-cache/hosted/pub.dev/flutter_local_notifications-9.9.1"
fi

if [ ! -d "$FLUTTER_DIR" ]; then
    FLUTTER_DIR="/opt/hostedtoolcache/flutter/.pub-cache/hosted/pub.dev/flutter_local_notifications-9.9.1"
fi

# Android build.gradle dosyasının tam yolu
GRADLE_FILE="$FLUTTER_DIR/android/build.gradle"
MANIFEST_FILE="$FLUTTER_DIR/android/src/main/AndroidManifest.xml"

# Dosyaların varlığını kontrol et
if [ ! -f "$GRADLE_FILE" ]; then
    echo "Hata: build.gradle dosyası bulunamadı: $GRADLE_FILE"
    echo "Lütfen flutter_local_notifications paketinin kurulu olduğundan emin olun."
    exit 1
fi

echo "build.gradle dosyası bulundu: $GRADLE_FILE"

# build.gradle dosyasında namespace ekle
if grep -q "namespace" "$GRADLE_FILE"; then
    echo "Namespace zaten tanımlanmış. Değişiklik yapılmayacak."
else
    echo "Namespace ekleniyor..."
    # defaultConfig bloğunun içine namespace ekle
    sed -i '/defaultConfig {/a \        namespace "com.dexterous.flutterlocalnotifications"' "$GRADLE_FILE"
    
    if [ $? -eq 0 ]; then
        echo "Namespace başarıyla eklendi: com.dexterous.flutterlocalnotifications"
    else
        echo "Namespace eklenirken hata oluştu."
        exit 1
    fi
fi

echo "Flutter Local Notifications paketi düzeltildi."
echo "Şimdi proje klasörüne giderek şu komutları çalıştırın:"
echo "cd new_project"
echo "flutter clean"
echo "flutter pub get"
echo "flutter build apk --debug"