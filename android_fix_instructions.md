# Android Bildirim Hatası Çözümü

Flutter uygulamasında yaşanan `flutter_local_notifications` paketi ile ilgili hata aşağıdaki adımlarla çözülebilir:

## Hatanın Kaynağı

```
C:\Users\guzel\AppData\Local\Pub\Cache\hosted\pub.dev\flutter_local_notifications-14.1.5\android\src\main\java\com\dexterous\flutterlocalnotifications\FlutterLocalNotificationsPlugin.java:1019: error: reference to bigLargeIcon is ambiguous
      bigPictureStyle.bigLargeIcon(null);
                     ^
  both method bigLargeIcon(Bitmap) in BigPictureStyle and method bigLargeIcon(Icon) in BigPictureStyle match
```

Bu hata Android API seviyesi uyumsuzluğundan kaynaklanıyor. `BigPictureStyle.bigLargeIcon()` metodunun iki farklı versiyonu var ve derleme zamanında hangisinin kullanılacağı belirlenemiyor.

## Çözüm 1: Flutter Local Notifications Paketini Düzeltme

1. Flutter projenizin ana klasöründe terminali açın
2. Aşağıdaki komutları çalıştırın:

```bash
cd .pub-cache/hosted/pub.dev/flutter_local_notifications-14.1.5/android/src/main/java/com/dexterous/flutterlocalnotifications/
```

3. `FlutterLocalNotificationsPlugin.java` dosyasını bir metin editörüyle açın
4. 1019. satırı bulun (veya hatada belirtilen satırı):

```java
bigPictureStyle.bigLargeIcon(null);
```

5. Bu satırı aşağıdaki gibi değiştirin:

```java
bigPictureStyle.bigLargeIcon((Bitmap) null);
```

6. Dosyayı kaydedin ve projeyi yeniden derleyin.

## Çözüm 2: Android Gradle Yapılandırmasını Güncelleme

1. `android/app/build.gradle` dosyasını açın
2. Aşağıdaki değişiklikleri yapın:

```gradle
android {
    compileSdkVersion 33    // Flutter'ın değerini 33 ile değiştirin
    ndkVersion "25.1.8937393"  // İsteğe bağlı

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }

    defaultConfig {
        // Diğer ayarlar aynı kalacak
        minSdkVersion 21    // Minimum SDK sürümünü 21 yapın (veya daha yüksek)
        // targetSdkVersion aynı kalabilir
    }
}

// Dosyanın sonuna ekleyin:
subprojects {
    afterEvaluate {project ->
        project.tasks.withType(JavaCompile).configureEach { 
            javaCompile -> javaCompile.options.compilerArgs << "-Xlint:unchecked" << "-Xlint:deprecation" 
        }
    }
}
```

3. `android/build.gradle` dosyasında Gradle sürümünü kontrol edin ve güncelleyin:

```gradle
buildscript {
    // ...
    dependencies {
        classpath 'com.android.tools.build:gradle:7.3.0'  // Gradle sürümünü güncelleyin
    }
}
```

4. Flutter projesini temizleyin ve yeniden derleyin:

```bash
flutter clean
flutter pub get
flutter build apk --debug   # veya başka bir derleme komutu
```

## Çözüm 3: flutter_local_notifications Paketini Sürüm Düşürme

Eğer yukarıdaki çözümler işe yaramazsa, paketi daha eski ve uyumlu bir sürüme düşürebilirsiniz:

1. `pubspec.yaml` dosyasını açın
2. flutter_local_notifications bağımlılığını bulun ve sürümünü değiştirin:

```yaml
dependencies:
  flutter_local_notifications: ^13.0.0  # Daha eski bir sürüm kullanın
```

3. Değişiklikleri kaydedin ve paketleri güncelleyin:

```bash
flutter pub get
```

## Bildirim Kodunu Sadeleştirme

Sorunu tamamen önlemek için bildirim kodunu sadeleştirerek alternatif bir çözüm de uygulayabilirsiniz. Projeye eklediğimiz `local_notification_fix.dart` dosyasını kullanarak bildirim kodunuzu güncelleyin. Bu dosya BigPictureStyle kullanmadan temel bildirim işlevselliğini sağlar.