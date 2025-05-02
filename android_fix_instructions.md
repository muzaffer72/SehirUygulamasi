# Android Uygulama Sorunları ve Çözümleri

Bu belge, Android uygulamasının derlenmesi ve çalıştırılması sırasında karşılaşılan sorunlar ve bu sorunların çözümlerini anlatmaktadır.

## 1. Flutter Local Notifications Sorunu

**Sorun**: Flutter Local Notifications paketindeki `bigLargeIcon` metodu, null parametresiyle çağrıldığında hangi metodun kullanılacağı konusunda bir belirsizlik oluşturuyor. Bu, aşağıdaki hata mesajına yol açıyor:

```
error: reference to 'bigLargeIcon' is ambiguous
        bigPictureStyle.bigLargeIcon(null);
                       ^
```

**Çözüm 1: Paket Sürümünü Düşürmek**
- `flutter_local_notifications` paketinin sürümünü 9.9.1'e düşürdük. Bu sürüm Android API 33 ile tamamen uyumludur.
- Bu değişiklik `pubspec.yaml` dosyasında yapıldı:
  ```yaml
  flutter_local_notifications: 9.9.1
  ```

**Çözüm 2: Android Gradle Ayarlarını Güncellemek**
- Android uyumluluğu için `build.gradle` dosyasında aşağıdaki değişiklikler yapıldı:
  ```gradle
  compileSdkVersion 33  // Flutter değişkeni yerine sabit değer
  minSdkVersion 21      // En düşük Android 5.0 sürümü
  targetSdkVersion 33   // Hedef Android 13 sürümü
  ```
- Java ve Kotlin uyumluluğu için:
  ```gradle
  compileOptions {
    sourceCompatibility JavaVersion.VERSION_1_8
    targetCompatibility JavaVersion.VERSION_1_8
  }
  kotlinOptions {
    jvmTarget = '1.8'
  }
  ```

**Çözüm 3: Java Kodunu Doğrudan Düzeltmek**
Bu, lokal geliştirme ortamı için geçerlidir ve Replit üzerinde uygulanması gerekmez.

Flutter Local Notifications paketinin Java kodunda, Android API 33 için tip dönüşümü eklenmesi gerekmektedir:

**Orijinal Kod:**
```java
if (bigPictureStyleInformation.hideExpandedLargeIcon) {
    bigPictureStyle.bigLargeIcon(null);  // BURADA HATA VAR
}
```

**Düzeltilmiş Kod:**
```java
if (bigPictureStyleInformation.hideExpandedLargeIcon) {
    bigPictureStyle.bigLargeIcon((android.graphics.Bitmap) null);  // TİP DÖNÜŞÜMÜ EKLENDİ
}
```

## 2. APK Oluşturma

APK oluşturmak için `flutter_build_apk.sh` script'ini kullanabilirsiniz:

```bash
./flutter_build_apk.sh
```

Bu script aşağıdakileri gerçekleştirecektir:
1. Flutter paketlerini günceller (`flutter pub get`)
2. Eski build dosyalarını temizler (`flutter clean`)
3. Debug APK oluşturur (`flutter build apk --debug`)
4. APK'nın başarıyla oluşturulup oluşturulmadığını kontrol eder ve bilgi verir

## 3. Android API Sürümü Uyumluluğu

- **Minimum SDK**: 21 (Android 5.0 Lollipop)
- **Target SDK**: 33 (Android 13)
- **Compile SDK**: 33 (Android 13)

Bu ayarlar, uygulamanın Android 5.0 ve üstü sürümlerde çalışacağı ve Android 13 için optimize edildiği anlamına gelir.

## 4. Firebase Bildirimleri

Firebase bildirimlerinin Android'de çalışması için:

1. `build.gradle` dosyasında Firebase bağımlılıkları ekledik ve güncelledik.
2. `NotificationService` sınıfının doğru şekilde çalıştığından emin olduk.
3. Flutter Local Notifications paketinin uyumluluk sorunlarını çözdük.

## Önemli Notlar

- Android projenizi farklı bir ortamda (Android Studio gibi) açtığınızda, Gradle senkronizasyonunu yapmanız gerekir.
- APK oluşturma sırasında bir hata alırsanız, loglarda tam hata mesajını kontrol edin. Sorun genellikle paket uyumsuzluğu veya eksik bağımlılıklardan kaynaklanır.
- Üretim sürümü (release) APK için imzalama ayarlarını yapılandırmanız gerekir.