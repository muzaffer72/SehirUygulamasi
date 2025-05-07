#!/bin/bash

# Flutter Local Notifications paketini buluyor
echo "Flutter Local Notifications paketini arıyorum..."
FLUTTER_LOCAL_PATH=$(find ~/.pub-cache -name "flutter_local_notifications" -type d | grep "/flutter_local_notifications\$" | head -n 1 || echo "")
ANDROID_PATH=""

if [[ -z "$FLUTTER_LOCAL_PATH" ]]; then
  echo "HATA: flutter_local_notifications paketi bulunamadı. Önce 'flutter pub get' komutunu çalıştırın."
  exit 1
fi

echo "Paket bulundu: $FLUTTER_LOCAL_PATH"

# Android klasörünü kontrol et
if [[ -d "$FLUTTER_LOCAL_PATH/android" ]]; then
  ANDROID_PATH="$FLUTTER_LOCAL_PATH/android"
  echo "Android klasörü bulundu: $ANDROID_PATH"
else
  echo "HATA: Android klasörü bulunamadı!"
  exit 1
fi

# Flutter Local Notifications paketi için build.gradle dosyasını buluyor
GRADLE_FILE="$ANDROID_PATH/build.gradle"
echo "Build.gradle dosyasını kontrol ediyorum: $GRADLE_FILE"

if [ ! -f "$GRADLE_FILE" ]; then
  echo "HATA: build.gradle dosyası bulunamadı!"
  exit 1
fi

# Yedek oluştur
echo "build.gradle dosyası yedekleniyor..."
cp "$GRADLE_FILE" "${GRADLE_FILE}.bak"

# Namespace ekle
if grep -q "namespace" "$GRADLE_FILE"; then
  echo "Namespace zaten tanımlanmış, ekleme yapılmayacak."
else
  echo "Namespace ekleniyor..."
  
  # defaultConfig bloğunun başlangıcını bul
  if grep -q "defaultConfig {" "$GRADLE_FILE"; then
    # Namespace satırını ekle
    sed -i '/defaultConfig {/a \        namespace "com.dexterous.flutterlocalnotifications"' "$GRADLE_FILE"
    echo "✅ Namespace eklendi: com.dexterous.flutterlocalnotifications"
  else
    # defaultConfig bloğu yoksa, android bloğuna namespace ekle
    if grep -q "android {" "$GRADLE_FILE"; then
      sed -i '/android {/a \    namespace "com.dexterous.flutterlocalnotifications"' "$GRADLE_FILE"
      echo "✅ Namespace eklendi: com.dexterous.flutterlocalnotifications"
    else
      echo "❌ Android veya defaultConfig bloğu bulunamadı, namespace eklenemedi."
      cp "${GRADLE_FILE}.bak" "$GRADLE_FILE"
      exit 1
    fi
  fi
fi

echo "İşlem tamamlandı."
echo "Şimdi 'flutter clean' ve 'flutter pub get' komutlarını çalıştırın, ardından projenizi yeniden derleyin."

exit 0
