# Şikayet Var Uygulaması Android Kurulum Rehberi

Bu rehber, Şikayet Var uygulamasının Android platformuna kurulumu ve yaygın sorunların çözümü için hazırlanmıştır.

## Sistem Gereksinimleri

- **Android Studio**: En son sürüm
- **JDK**: 17 veya üzeri
- **Flutter**: 3.10.0 veya üzeri
- **Gradle**: 8.0 veya üzeri

## İlk Kurulum

1. Projeyi bilgisayarınıza klonlayın:
   ```
   git clone https://github.com/sikayetvar/app.git
   cd app
   ```

2. Flutter paketlerini yükleyin:
   ```
   flutter pub get
   ```

3. Android Studio'yu açın ve projeyi içe aktarın. Bunu yaparken Android Studio, Gradle senkronizasyonu otomatik olarak başlatacaktır.

## Yaygın Sorunlar ve Çözümleri

### 1. Gradle JDK Sürüm Uyumsuzluğu

**Sorun**: "Unsupported class file major version 65" veya benzer JDK uyumsuzluk hataları.

**Çözüm**:
- JDK 17'yi sistemine yükleyin
- Android Studio'da **File > Settings > Build, Execution, Deployment > Build Tools > Gradle** yolunu izleyerek Gradle JDK ayarını JDK 17 olarak güncelleyin
- `android/gradle.properties` dosyasında JDK yolunu doğru şekilde belirtin:
  ```
  org.gradle.java.home=C:\\Program Files\\Java\\jdk-17
  ```

### 2. Flutter Plugin Uyum Sorunları

**Sorun**: "The plugin flutter_plugin_requires Android SDK version 35 or higher" veya plugin derleme hataları.

**Çözüm**:
- `pubspec.yaml` dosyasında sorunlu eklentilerin sürümlerini düşürün
- Bizim projemizde şu eklentilerin daha eski sürümleri daha iyi çalışıyor:
  ```yaml
  google_maps_flutter: ^2.3.0
  geolocator: ^9.0.2
  ```

### 3. compileSdkVersion Hatası

**Sorun**: "compileSdkVersion is not specified" veya "Could not get unknown property 'flutter' for extension 'android'" hataları.

**Çözüm**:
- `android/app/build.gradle` dosyasında sabit compileSdkVersion değeri kullanın:
  ```gradle
  android {
      compileSdk = 33 // flutter.compileSdkVersion yerine sabit değer
      // ...
  }
  ```

- `android/local.properties` dosyasında Flutter SDK yolunu doğru şekilde belirtin
- Projemizdeki `android/jdk-fix.bat` script'ini çalıştırın (Windows için)

### 4. Gerekli İzinler

Uygulamaya konum erişimi için gerekli izinleri ekleyin. `android/app/src/main/AndroidManifest.xml` dosyasına şu izinleri ekleyin:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
```

## Geliştirme Önerileri

- Lokalde Android SDK'nın güncel olduğundan emin olun
- Uyumsuzluk sorunlarında öncelikle eski paket sürümlerini deneyin
- Proje genelinde aynı Gradle ve JDK sürümlerini kullanın
- Paket eklemeden önce Flutter ve Android uyumluluğunu kontrol edin

## Dağıtım (Release) Notları

Uygulama dağıtım versiyonu oluşturmak için:

1. Versiyonu `pubspec.yaml` dosyasında güncelleyin
2. Android bundle oluşturun:
   ```
   flutter build appbundle
   ```

3. APK oluşturun:
   ```
   flutter build apk --release
   ```

4. APK dosyası `build/app/outputs/flutter-apk/app-release.apk` konumunda oluşturulacaktır.

---

**Not**: Bu rehber geliştirme ekibi için hazırlanmıştır. Herhangi bir sorunla karşılaşırsanız, ilgili geliştirici ile iletişime geçiniz.