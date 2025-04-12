#!/bin/bash

# ŞikayetVar - Proje Dışa Aktarma ve APK Derleme Scripti
# Bu script, projeyi arşivleyip başka bir ortamda derlemeniz için hazırlar

echo "ŞikayetVar Proje Dışa Aktarma ve APK Derleme Hazırlığı"
echo "===================================================="

EXPORT_DIR="sikayetvar_export"
EXPORT_ZIP="sikayetvar_flutter_project.zip"

# Dışa aktarma klasörü oluştur
mkdir -p $EXPORT_DIR

# Önemli dosyaları kopyala
echo "Proje dosyaları kopyalanıyor..."

# Ana Flutter projesi
cp -r lib $EXPORT_DIR/
cp -r assets $EXPORT_DIR/
cp -r android $EXPORT_DIR/
cp -r ios $EXPORT_DIR/ 2>/dev/null || echo "iOS klasörü bulunamadı, atlanıyor..."
cp -r web $EXPORT_DIR/
cp pubspec.yaml $EXPORT_DIR/
cp pubspec.lock $EXPORT_DIR/
cp .metadata $EXPORT_DIR/ 2>/dev/null || true
cp README.md $EXPORT_DIR/ 2>/dev/null || true
cp analysis_options.yaml $EXPORT_DIR/ 2>/dev/null || true

# APK derleme bilgilerini ekle
cp android/README.md $EXPORT_DIR/APK_DERLEME_REHBERI.md

# Örnek .env dosyası
cat > $EXPORT_DIR/.env.example << 'EOF'
# ŞikayetVar Çevre Değişkenleri
API_URL=https://api.example.com
MAPS_API_KEY=YOUR_GOOGLE_MAPS_API_KEY
EOF

# Derleme kılavuzu oluştur
cat > $EXPORT_DIR/KURULUM.md << 'EOF'
# ŞikayetVar Kurulum ve Derleme Kılavuzu

Bu kılavuz, ŞikayetVar uygulamasını yerel ortamınızda nasıl çalıştıracağınızı ve derleyeceğinizi açıklar.

## Gereksinimler

- Flutter SDK (en az sürüm 3.0.0)
- Android Studio veya VS Code
- Android SDK (APK derlemek için)
- JDK 11 veya üzeri

## Kurulum Adımları

1. Flutter SDK'yı kurun (https://flutter.dev/docs/get-started/install)

2. Bu projeyi bir klasöre çıkarın

3. Terminal'de proje klasörüne gidin ve bağımlılıkları yükleyin:
   ```
   flutter pub get
   ```

4. Uygulamayı çalıştırın:
   ```
   flutter run
   ```

## APK Derleme

APK derleme ile ilgili detaylı bilgi için `APK_DERLEME_REHBERI.md` dosyasını okuyun.

## Çevre Değişkenleri

1. `.env.example` dosyasını `.env` olarak kopyalayın
2. Gerekli API anahtarlarını ve yapılandırma değerlerini doldurun

## Sorun Giderme

- Flutter sürüm sorunları için: `flutter upgrade`
- Dart/Flutter paket sorunları için: `flutter clean && flutter pub get`
- Gradle sorunları için Android klasöründeki README.md dosyasına bakın
EOF

# Projeyi ZIP olarak arşivle
echo "Proje arşivleniyor..."
cd $EXPORT_DIR
zip -r ../$EXPORT_ZIP .
cd ..

echo "İşlem tamamlandı!"
echo "Proje şu dosyada arşivlendi: $EXPORT_ZIP"
echo "Bu ZIP dosyasını başka bir Flutter ortamına aktarıp APK derleyebilirsiniz."
echo ""
echo "APK derleme talimatları için arşiv içindeki APK_DERLEME_REHBERI.md dosyasına bakın."