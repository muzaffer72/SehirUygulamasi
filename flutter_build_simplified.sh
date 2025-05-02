#!/bin/bash

# Flutter Local Notifications sorunu için düzeltme uygulandıktan sonra
# uygulamayı derleyen script

echo "🔍 Flutter versiyonu kontrol ediliyor..."
flutter --version

echo "🧹 Eski derleme dosyaları temizleniyor..."
flutter clean

echo "📦 Bağımlılıklar güncelleniyor..."
flutter pub get

echo "✅ Düzeltme kontrol ediliyor..."

# Eğer flutter_notification_fix.patch uygulanmadıysa
if [ -f "flutter_notification_fix.patch" ]; then
  echo "🔧 Bildirim sorunu için düzeltme uygulanıyor..."
  git apply flutter_notification_fix.patch
  
  if [ $? -eq 0 ]; then
    echo "✅ Düzeltme başarıyla uygulandı."
  else
    echo "❌ Düzeltme uygulanamadı, manuel kontrol gerekiyor."
  fi
fi

# Eğer direct_fix yöntemini kullandıysanız, kontrol et
NOTIFICATION_PATH=$(find ~/.pub-cache -name "FlutterLocalNotificationsPlugin.java" | grep -m 1 "flutter_local_notifications")

if [ -n "$NOTIFICATION_PATH" ]; then
  echo "📄 Bildirim dosyası bulundu: $NOTIFICATION_PATH"
  
  # İlgili satırı kontrol et
  if grep -q "bigPictureStyle.bigLargeIcon((Bitmap) null)" "$NOTIFICATION_PATH"; then
    echo "✅ Bildirim düzeltmesi zaten uygulanmış."
  else
    echo "🔧 Bildirim dosyası düzeltiliyor..."
    # Yedek al
    cp "$NOTIFICATION_PATH" "${NOTIFICATION_PATH}.backup"
    # Düzeltmeyi uygula
    sed -i 's/bigPictureStyle.bigLargeIcon(null);/bigPictureStyle.bigLargeIcon((Bitmap) null);/g' "$NOTIFICATION_PATH"
    
    if [ $? -eq 0 ]; then
      echo "✅ Dosya düzeltmesi başarıyla uygulandı."
    else
      echo "❌ Dosya düzeltmesi uygulanamadı."
    fi
  fi
else
  echo "⚠️ Bildirim dosyası bulunamadı, düzeltme uygulanamıyor."
fi

echo "📱 Android uygulaması derleniyor..."
flutter build apk --debug

if [ $? -eq 0 ]; then
  echo "✅ Uygulama başarıyla derlendi."
  APK_PATH=$(find build/app/outputs -name "*.apk" | head -1)
  
  if [ -n "$APK_PATH" ]; then
    echo "📲 APK dosyası şurada bulunabilir: $APK_PATH"
    
    # APK dosyasının boyutunu ve hash değerini göster
    echo "📊 APK bilgileri:"
    ls -lh "$APK_PATH"
    echo "🔒 SHA-256: $(sha256sum "$APK_PATH" | cut -d' ' -f1)"
  else
    echo "⚠️ APK dosyası bulunamadı."
  fi
else
  echo "❌ Derleme başarısız oldu."
  echo "📋 Sorun giderme önerileri:"
  echo "  - Flutter ve Dart sürümlerinizin güncel olduğundan emin olun"
  echo "  - Çözüm işe yaramazsa, 'flutter_local_notifications' paketini sürüm 13.0.0'a indirin"
  echo "  - Android Studio'da projeyi açıp Gradle sync işlemi yapın"
  echo "  - Detaylı log için: flutter build apk --debug --verbose"
fi