#!/bin/bash

# Bu script, Flutter projesinin yaygın sorunlarını çözmek için kullanılır
# Özellikle Android derleme sorunları ve paket uyumsuzluklarını hedefler

echo "Flutter Sorun Giderme Aracı Başlatılıyor..."
echo "----------------------------------------"

# 1. Flutter'ı temizle
echo "1. Flutter önbelleğini temizleniyor..."
flutter clean
echo "✓ Flutter önbelleği temizlendi"

# 2. Paketleri güncelle
echo "2. Flutter paketleri güncelleniyor..."
flutter pub get
echo "✓ Flutter paketleri güncellendi"

# 3. Android ayarlarını kontrol et
echo "3. Android derleyici ayarları kontrol ediliyor..."
if [ -d "android" ]; then
    # local.properties oluşturulmuş mu kontrol et
    if [ ! -f "android/local.properties" ]; then
        echo "ⓘ android/local.properties dosyası bulunamadı, oluşturuluyor..."
        echo "flutter.sdk=$(flutter --version --machine | grep flutterRoot | cut -d'"' -f4)" > android/local.properties
        echo "✓ Flutter SDK yolu local.properties dosyasına eklendi"
    fi
    
    # build.gradle içinde compileSdkVersion kontrolü
    if [ -f "android/app/build.gradle" ]; then
        if grep -q "compileSdk = flutter.compileSdkVersion" "android/app/build.gradle"; then
            echo "⚠️ Eski compileSdkVersion ayarı tespit edildi, sabit değer tanımlanmalı"
            echo "ⓘ android/app/build.gradle dosyasında 'compileSdk = flutter.compileSdkVersion' ifadesini 'compileSdk = 33' ile değiştirin"
        else
            echo "✓ Android compileSdk ayarları doğru görünüyor"
        fi
    fi
    
    echo "✓ Android ayarları kontrol edildi"
else
    echo "⚠️ Android klasörü bulunamadı"
fi

# 4. Paket uyumsuzluklarını kontrol et
echo "4. Paket uyumsuzlukları kontrol ediliyor..."
flutter pub outdated
echo "✓ Paket kontrolü tamamlandı"

# 5. Uyumluluk sorunlarını kontrol et
echo "5. Flutter uyumluluk analizi yapılıyor..."
flutter analyze
echo "✓ Flutter analizi tamamlandı"

echo "----------------------------------------"
echo "Flutter sorun giderme tamamlandı!"
echo "Derleme sorunları devam ediyorsa android/jdk-fix.bat dosyasını çalıştırmayı (Windows için) veya jdk_gradle_fix.md dosyasındaki adımları izlemeyi deneyin."