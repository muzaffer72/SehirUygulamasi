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
