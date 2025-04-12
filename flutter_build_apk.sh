#!/bin/bash

# Environment değişkenlerini ayarla
export ANDROID_HOME=$HOME/Android/Sdk
export JAVA_OPTS="-Xmx1536M -XX:MaxHeapSize=1536M"
export GRADLE_OPTS="-Xmx1536M -XX:MaxHeapSize=1536M"

# APK derlemesini daha az bellek kullanarak çalıştır
echo "Minimal APK derlemesi başlatılıyor..."
flutter clean
flutter build apk --debug --split-per-abi --dart-define=Dart.vm.product=false

echo "APK derleme tamamlandı. APK dosyaları:"
find build/app/outputs/flutter-apk -name "*.apk"
