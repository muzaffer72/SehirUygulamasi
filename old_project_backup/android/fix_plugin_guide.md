# Flutter Eklenti Sorunları Giderme Rehberi

Bu rehber, `geolocator_android`, `google_maps_flutter_android` ve diğer eklentilerde yaşanan "Could not get unknown property 'flutter' for extension 'android'" ve "compileSdkVersion is not specified" gibi derleme hatalarını çözmek için oluşturulmuştur.

## Sorun Nedir?

Flutter eklentileri, Android derleme sürecinde Flutter Gradle Plugin'in sağladığı bazı değişkenlere (flutter.compileSdkVersion gibi) bağımlıdır. Ancak bazı durumlarda bu değişkenler doğru şekilde aktarılmaz ve derleme hataları oluşur.

## Çözüm 1: Eklenti Sürümlerini Düşürme

En kolay çözüm yolu, sorunlu eklentilerin sürümlerini düşürmektir. `pubspec.yaml` dosyasında aşağıdaki değişiklikleri yapın:

```yaml
# Sorunlu ve yeni sürüm
google_maps_flutter: ^2.5.0
geolocator: ^10.0.1

# Daha uyumlu sürümler
google_maps_flutter: ^2.4.0
location: ^4.4.0  # geolocator yerine alternatif
geocoding: ^2.1.1
```

## Çözüm 2: Plugin Gradle Dosyalarını Düzenleme

Eğer sürüm düşürme çalışmadıysa veya eklentinin en son sürümüne ihtiyacınız varsa, eklentinin `build.gradle` dosyasını doğrudan düzenleyebilirsiniz.

### Manuel Düzenleme

1. Eklenti cache klasörünü bulun:
   - Windows: `C:\Users\<kullanıcı-adı>\AppData\Local\Pub\Cache\hosted\pub.dev\`
   - Linux/Mac: `~/.pub-cache/hosted/pub.dev/`

2. Sorunlu eklentinin klasörünü bulun (örn. `geolocator_android-4.6.2`)

3. `android/build.gradle` dosyasını açın ve şu değişiklikleri yapın:
   - `compileSdk flutter.compileSdkVersion` → `compileSdk 33`
   - `minSdk flutter.minSdkVersion` → `minSdk 21`
   - `targetSdk flutter.targetSdkVersion` → `targetSdk 33`
   - `ndkVersion flutter.ndkVersion` → `ndkVersion "25.1.8937393"`

### Otomatik Düzenleme

Projemizde bu işlemi otomatikleştiren bir script bulunmaktadır:

1. Terminal/cmd penceresini açın
2. Proje ana dizininde şu komutu çalıştırın:
   ```
   cd android && ./update_plugin_gradle.sh
   ```

Bu script, bilinen sorunlu eklentilerin Gradle dosyalarını otomatik olarak düzenleyecektir.

## Çözüm 3: local.properties Dosyasını Güncelleme

`android/local.properties` dosyasında aşağıdaki satırların doğru olduğundan emin olun:

```
flutter.sdk=C:\\src\\flutter
flutter.compileSdkVersion=33
flutter.minSdkVersion=21
flutter.targetSdkVersion=33
flutter.ndkVersion=25.1.8937393
```

Bu değerleri `C:\\src\\flutter` Flutter SDK'nızın gerçek konumuyla değiştirin.

## Çözüm 4: Gradle Clean ve Cache Temizleme

Tüm Gradle önbelleklerini temizleyin:

1. Proje klasöründe şu komutları çalıştırın:
   ```
   cd android
   ./gradlew clean
   ./gradlew --refresh-dependencies
   ```

2. Flutter önbelleğini temizleyin:
   ```
   flutter clean
   flutter pub get
   ```

## Çözüm 5: Android Studio Ayarlarını Güncelleme

Android Studio'da:
1. File > Settings > Build, Execution, Deployment > Build Tools > Gradle
2. Gradle JDK: 17 seçin
3. Apply > OK

## Sorun Devam Ederse

- Tüm düzeltmeleri tek seferde uygulamak için `android/jdk-fix.bat` scriptini çalıştırın (Windows için).
- Android Studio'yu tamamen kapatıp yeniden açın.
- Flutter ve Dart eklentilerinin güncel olduğundan emin olun.
- Projeden bağımsız bir Flutter projesi oluşturup aynı eklentileri test edin.

---

**Not**: Bu rehberdeki değişiklikler, Flutter veya Gradle'ın gelecek sürümlerinde gereksiz hale gelebilir. Her zaman en güncel Flutter ve dart rehberlerini takip edin.