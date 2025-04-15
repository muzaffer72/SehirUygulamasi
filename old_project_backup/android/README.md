# ŞikayetVar Android APK Derleme Rehberi

Bu rehber, ŞikayetVar uygulamasının Android APK dosyasını nasıl derleyeceğinizi açıklar.

## Gereksinimler

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (en son sürüm)
- [Android Studio](https://developer.android.com/studio) ve Android SDK
- JDK 11 veya üzeri

## Derleme Adımları

1. Projeyi bilgisayarınıza klonlayın:
   ```
   git clone <repo-url>
   cd sikayetvar
   ```

2. Flutter bağımlılıklarını yükleyin:
   ```
   flutter pub get
   ```

3. Android APK'sını derleyin:
   ```
   flutter build apk --release
   ```

4. Alternatif olarak, farklı mimariler için ayrı APK'lar derlemek isterseniz:
   ```
   flutter build apk --release --split-per-abi
   ```

5. Derlenen APK dosyaları `build/app/outputs/flutter-apk/` klasöründe bulunacaktır.

## Sorun Giderme

### Gradle veya JDK Sorunları

Eğer Gradle sürümü veya JDK uyumsuzluğu yaşıyorsanız:

1. `android/gradle/wrapper/gradle-wrapper.properties` dosyasında Gradle sürümünü kontrol edin.
2. `android/gradle.properties` dosyasında Java Home ayarını güncelleyin:
   ```
   org.gradle.java.home=/path/to/your/jdk
   ```

### Bellek Sorunları

Derleme sırasında bellek yetmezliği (Out of Memory) hatası alırsanız:

1. `android/gradle.properties` dosyasında bellek ayarlarını artırın:
   ```
   org.gradle.jvmargs=-Xmx4G -XX:MaxPermSize=512m -XX:+HeapDumpOnOutOfMemoryError
   ```

## ŞikayetVar Play Store Hazırlık Süreci

1. APK/AAB imzalama için keystore oluşturun:
   ```
   keytool -genkey -v -keystore sikayetvar-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias sikayetvar
   ```

2. `android/key.properties` dosyası oluşturun:
   ```
   storePassword=<şifre>
   keyPassword=<şifre>
   keyAlias=sikayetvar
   storeFile=<keystore-dosya-yolu>
   ```

3. `android/app/build.gradle` dosyasını imzalama için güncelleyin (örnek kod dosyada mevcut).

4. İmzalı APK oluşturun:
   ```
   flutter build apk --release
   ```

5. İmzalı AAB (Android App Bundle) oluşturun:
   ```
   flutter build appbundle
   ```

6. Play Store'a yüklemek için AAB dosyasını kullanın: `build/app/outputs/bundle/release/app-release.aab`