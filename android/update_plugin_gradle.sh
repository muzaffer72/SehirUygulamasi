#!/bin/bash

# Flutter eklentilerindeki Gradle sorunlarını gidermek için yardımcı script
# Bu dosya, eklentilerin build.gradle dosyalarını geçici olarak düzenler

# Ana dizin
FLUTTER_PROJECT_ROOT=$(pwd)/..

# Pub cache dizini - Windows ve Linux için farklı yollar
if [ -d "$HOME/.pub-cache" ]; then
  PUB_CACHE="$HOME/.pub-cache"
elif [ -d "$HOME/AppData/Local/Pub/Cache" ]; then
  PUB_CACHE="$HOME/AppData/Local/Pub/Cache"
fi

echo "Pub Cache dizini: $PUB_CACHE"
echo "Proje dizini: $FLUTTER_PROJECT_ROOT"

# Eklenti listesi - sorun bildirilen eklentiler
PLUGINS=(
  "geolocator_android"
  "google_maps_flutter_android"
  "location"
  "image_picker_android"
  "connectivity_plus"
)

# Eklentilerin build.gradle dosyalarında yapılacak düzeltmeler için bir işlev
fix_plugin_gradle() {
  local plugin_path="$1"
  local build_gradle_path="$plugin_path/android/build.gradle"
  
  if [ -f "$build_gradle_path" ]; then
    echo "Düzenleniyor: $build_gradle_path"
    
    # Yedekleme dosyası oluştur
    cp "$build_gradle_path" "$build_gradle_path.bak"
    
    # flutter.compileSdkVersion yerine sabit değer kullan
    sed -i 's/compileSdk flutter.compileSdkVersion/compileSdk 35/g' "$build_gradle_path"
    
    # flutter.minSdkVersion yerine sabit değer kullan
    sed -i 's/minSdk flutter.minSdkVersion/minSdk 21/g' "$build_gradle_path"
    
    # flutter.targetSdkVersion yerine sabit değer kullan
    sed -i 's/targetSdk flutter.targetSdkVersion/targetSdk 34/g' "$build_gradle_path"
    
    # ndkVersion sorununu çöz
    sed -i 's/ndkVersion flutter.ndkVersion/ndkVersion "25.1.8937393"/g' "$build_gradle_path"
    
    echo "✓ Düzenleme tamamlandı"
  else
    echo "⚠️ build.gradle dosyası bulunamadı: $build_gradle_path"
  fi
}

echo "Flutter eklentileri Gradle düzeltme işlemi başlatılıyor..."
echo "----------------------------------------"

# Her eklenti için düzeltme işlemini çağır
for plugin in "${PLUGINS[@]}"; do
  echo "Eklenti işleniyor: $plugin"
  
  # Hosted eklentiler için
  if [ -d "$PUB_CACHE/hosted/pub.dev/$plugin" ]; then
    for version_dir in "$PUB_CACHE/hosted/pub.dev/$plugin-"*; do
      if [ -d "$version_dir" ]; then
        echo "Versiyon bulundu: $version_dir"
        fix_plugin_gradle "$version_dir"
      fi
    done
  fi
  
  # Direkt eklenti adıyla bulunanlar için
  if [ -d "$PUB_CACHE/hosted/pub.dev/$plugin" ]; then
    echo "Eklenti bulundu: $plugin"
    fix_plugin_gradle "$PUB_CACHE/hosted/pub.dev/$plugin"
  fi
done

echo "----------------------------------------"
echo "Flutter eklentileri Gradle düzeltme işlemi tamamlandı!"
echo "Not: Bu geçici bir çözümdür ve tüm eklentiler için çalışmayabilir."
echo "Flutter ve eklentilerin sürümlerini uyumlu hale getirmek en iyi yöntemdir."