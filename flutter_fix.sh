#!/bin/bash

# Yedekleme klasörü oluştur
echo "Mevcut projeyi yedekliyorum..."
mkdir -p temp_backup

# Gerekli dosyaları yedekle
cp -r lib temp_backup/
cp -r assets temp_backup/
cp pubspec.yaml temp_backup/
cp -r test temp_backup/ 2>/dev/null || true
cp README.md temp_backup/ 2>/dev/null || true
# Firebase dosyaları varsa yedekle
cp -r android/app/google-services.json temp_backup/ 2>/dev/null || true
cp -r ios/Runner/GoogleService-Info.plist temp_backup/ 2>/dev/null || true
cp -r web/firebase-config.js temp_backup/ 2>/dev/null || true

# Yeni proje oluştur
echo "Yeni Flutter projesi oluşturuyorum..."
flutter create --org belediye.iletisim.merkezi -t app --platforms=android,ios,web --project-name belediye_iletisim_merkezi ./new_project

# Yeni projeye eski dosyaları taşı
echo "Eski dosyaları yeni projeye taşıyorum..."
rm -rf new_project/lib/*
cp -r temp_backup/lib/* new_project/lib/

# Assets klasörünü taşı
rm -rf new_project/assets 2>/dev/null || true
cp -r temp_backup/assets new_project/

# pubspec.yaml'dan bağımlılıkları alıp yeni pubspec.yaml'a ekle
echo "pubspec.yaml dosyasını güncelliyorum..."
# İlk önce eski pubspec.yaml'dan bağımlılıkları çıkar
DEPENDENCIES=$(sed -n '/^dependencies:/,/^dev_dependencies:/p' temp_backup/pubspec.yaml | sed '1d;$d')
DEV_DEPENDENCIES=$(sed -n '/^dev_dependencies:/,/^flutter:/p' temp_backup/pubspec.yaml | sed '1d;$d')
FLUTTER_SECTION=$(sed -n '/^flutter:/,/^$/p' temp_backup/pubspec.yaml)

# Yeni pubspec.yaml'ı düzenle
cat > new_project/pubspec.yaml << EOL
name: belediye_iletisim_merkezi
description: Belediye ve Valiliğe yönelik iletişim platformu

# The following defines the version and build number for your application.
version: 1.0.0+1

environment:
  sdk: ">=3.0.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
${DEPENDENCIES}

dev_dependencies:
  flutter_test:
    sdk: flutter
${DEV_DEPENDENCIES}

${FLUTTER_SECTION}
EOL

# Google Services dosyalarını taşı
echo "Firebase yapılandırmalarını taşıyorum..."
cp -r temp_backup/google-services.json new_project/android/app/ 2>/dev/null || true
cp -r temp_backup/GoogleService-Info.plist new_project/ios/Runner/ 2>/dev/null || true
cp -r temp_backup/firebase-config.js new_project/web/ 2>/dev/null || true

echo "Paket adını güncel hale getiriyorum..."
# MainActivity.kt dosyasını düzenle
mkdir -p new_project/android/app/src/main/kotlin/belediye/iletisim/merkezi
cp temp_backup/../android/app/src/main/kotlin/belediye/iletisim/merkezi/MainActivity.kt new_project/android/app/src/main/kotlin/belediye/iletisim/merkezi/ 2>/dev/null || echo "package belediye.iletisim.merkezi

import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity()
" > new_project/android/app/src/main/kotlin/belediye/iletisim/merkezi/MainActivity.kt

# Renkler dosyasını taşı
echo "Android özel dosyalarını taşıyorum..."
mkdir -p new_project/android/app/src/main/res/values
cp temp_backup/../android/app/src/main/res/values/colors.xml new_project/android/app/src/main/res/values/ 2>/dev/null || echo '<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="primary">#2E7D32</color>
    <color name="accent">#4CAF50</color>
    <color name="notification_color">#2E7D32</color>
</resources>' > new_project/android/app/src/main/res/values/colors.xml

# AndroidManifest.xml'deki izinleri taşı
echo "Android izinlerini taşıyorum..."
PERMISSIONS=$(grep -E "<uses-permission" temp_backup/../android/app/src/main/AndroidManifest.xml || echo "")

# AndroidManifest.xml'i düzenle
if [ ! -z "$PERMISSIONS" ]; then
  MANIFEST_FILE="new_project/android/app/src/main/AndroidManifest.xml"
  TEMP_FILE="new_project/android/app/src/main/AndroidManifest.xml.temp"
  
  cp "$MANIFEST_FILE" "$TEMP_FILE"
  
  sed -i '/<manifest/a \
    <!-- İzinler -->\
    '"$PERMISSIONS" "$TEMP_FILE"
    
  mv "$TEMP_FILE" "$MANIFEST_FILE"
fi

# Android application attributes
sed -i 's/android:label="belediye_iletisim_merkezi"/android:label="Belediye İletişim"/g' new_project/android/app/src/main/AndroidManifest.xml

echo "Proje oluşturma işlemi tamamlandı."
echo "Yeni proje new_project klasöründe. Eski proje korunuyor."
echo "Kontrol ettikten sonra yeni projeyi kullanabilirsiniz."