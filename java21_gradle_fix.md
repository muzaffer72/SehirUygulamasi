# Java 21.0.3 için Gradle Yapılandırması

`flutter doctor --verbose` çıktısına göre Flutter ve Android Studio yapılandırmanız aşağıdaki şekildedir:

- Flutter: 3.24.0 (Stable)
- Dart: 3.5.0
- Android Studio: 2024.2
- Java: OpenJDK Runtime Environment (build 21.0.3+-12282718-b509.11)

## Yapılan Değişiklikler

Android Studio'nun Java 21.0.3 sürümü ile uyumlu çalışması için aşağıdaki güncellemeler yapılmıştır:

### 1. Gradle Sürümü (8.6)

`new_project/android/gradle/wrapper/gradle-wrapper.properties` dosyasında:

```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-8.6-all.zip
```

Gradle 8.6, Java 21 ile tam uyumlu çalışan en yeni sürümdür.

### 2. Android Gradle Plugin (8.3.0)

`new_project/android/build.gradle` dosyasında:

```gradle
dependencies {
    classpath 'com.android.tools.build:gradle:8.3.0'  // Java 21 için optimize edilmiş
    classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    classpath 'com.google.gms:google-services:4.4.0'  // Uyumlu sürüm
}
```

### 3. Java ve Kotlin Uyumluluk Ayarları

`new_project/android/app/build.gradle` dosyasında:

```gradle
compileOptions {
    coreLibraryDesugaringEnabled true
    sourceCompatibility JavaVersion.VERSION_21
    targetCompatibility JavaVersion.VERSION_21
}

kotlinOptions {
    jvmTarget = '21'
}
```

## Namespace Sorunu Çözümü

Flutter Local Notifications paketi için namespace hatası alınıyorsa, `fix_flutter_local_notifications_java21.sh` script'ini çalıştırabilirsiniz:

```bash
./fix_flutter_local_notifications_java21.sh
```

Bu script, paketin `build.gradle` dosyasına gerekli namespace ayarını ekler:

```gradle
namespace "com.dexterous.flutterlocalnotifications"
```

## Android Studio Ayarları

1. Güncelleme sonrası Android Studio'yu tamamen kapatıp yeniden açın
2. File > Settings > Build, Execution, Deployment > Build Tools > Gradle
3. Gradle JDK kısmında Java 21 seçili olduğundan emin olun
4. Android Studio'da "Invalidate Caches and Restart" yaparak, ön belleği temizleyin

## Temizleme ve Yeniden Derleme

Tüm değişiklikleri uyguladıktan sonra aşağıdaki adımları izleyin:

```bash
cd new_project
flutter clean
flutter pub get
flutter pub run flutter_native_splash:create
flutter build apk --debug
```

Bu adımları izledikten sonra Android Studio'da projeyi yeniden açıp derlemeyi deneyin. Java 21.0.3 sürümü ile tam uyumlu çalışması gerekiyor.
