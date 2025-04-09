# Flutter Android SDK 35 Uyumluluk Rehberi

Bu rehber, Flutter projemizin Android SDK 35 ile uyumlu olacak şekilde yapılandırılması için oluşturulmuştur. Flutter eklentilerinin artık daha yüksek SDK sürümleri gerektirmesi nedeniyle (özellikle flutter_plugin_android_lifecycle paketi SDK 35 gerektirir) bu güncellemeler gerekmektedir.

## Yapılan Değişiklikler

Projemizdeki Android yapılandırması şu şekilde güncellenmiştir:

### 1. compileSdk Güncellendi
- SDK 33'ten SDK 35'e yükseltildi
- targetSdk 33'ten 34'e yükseltildi
- Flutter eklentileri ile tam uyumluluk sağlandı

### 2. Gradle Sürümleri Güncellendi
- Gradle sürümü 8.0'dan 8.4'e yükseltildi
- Android Gradle Plugin sürümü 7.3.0'dan 8.1.3'e yükseltildi
- Kotlin sürümü 1.7.10'dan 1.9.10'a yükseltildi

### 3. AndroidX Kütüphaneleri Güncellendi
- Annotation, Core, AppCompat en son sürümlere yükseltildi
- Play Services Location 21.1.0'a güncellendi

### 4. Location Paketi Değiştirildi
- `location` paketi eski Kotlin sürümüne bağımlıydı ve sorun çıkarıyordu
- `flutter_localization` paketi ile değiştirildi

## Geliştirici Yapılandırması

Eğer bu projeyi yeni bir geliştirme ortamında yapılandırıyorsanız, aşağıdaki adımları izleyin:

### 1. JDK 17 Kullanın
Android Gradle Plugin 8.x, JDK 17 veya üzeri gerektirir.

```
# Android Studio ayarları
File > Settings > Build, Execution, Deployment > Build Tools > Gradle
# JDK Location: 17 veya üstü bir JDK sürümü seçin
```

### 2. Android SDK 35'i Yükleyin
Android Studio SDK Manager'dan SDK 35'i yükleyin.

```
# Android Studio ayarları
Tools > SDK Manager > SDK Platforms
# Android 15.0 (API 35) seçin ve yükleyin
```

### 3. SDK Build Tools Yükleyin
En son sürüm Build Tools'u yükleyin.

```
# Android Studio ayarları
Tools > SDK Manager > SDK Tools
# Android SDK Build-Tools 35.x.x seçin ve yükleyin
```

## Sorun Giderme

### 1. Eklenti Gradle Sorunları
Eklentiler için derlenme sorunları yaşarsanız, otomatik düzeltme scriptimizi çalıştırın:

```bash
cd android && ./update_plugin_gradle.sh
```

Bu script, eklentilerin build.gradle dosyalarını uygun SDK sürümleriyle otomatik olarak güncelleyecektir.

### 2. Kotlin Uyumluluk Sorunları
Kotlin uyumluluk sorunları için (The Android Gradle plugin supports only Kotlin Gradle plugin version 1.5.20 and higher):

1. Önce bağımlılıkları temizleyin:
   ```bash
   cd android 
   ./gradlew clean
   ./gradlew --refresh-dependencies
   ```

2. Pub cache'i temizleyin:
   ```bash
   flutter pub cache clean
   flutter pub get
   ```

### 3. Diğer Eklenti Sorunları
Eğer bazı eklentiler hala SDK uyumsuzluk hataları veriyorsa:

1. Flutter doktor çalıştırın:
   ```bash
   flutter doctor -v
   ```

2. Eklenti sürümlerini pubspec.yaml'da güncelleyin
   ```yaml
   # Eskimemiş sürümler kullanın
   google_maps_flutter: ^2.5.0
   flutter_localization: ^0.1.14
   geocoding: ^2.1.1
   ```

## Tüm Android Yapılandırması

Referans için ana Android yapılandırma dosyalarımızın güncel içeriği:

### android/app/build.gradle
```gradle
android {
    namespace = "com.sikayetvar.sikayet_var"
    compileSdk = 35 
    ndkVersion = "25.1.8937393"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    
    kotlinOptions {
        jvmTarget = '17'
    }

    defaultConfig {
        applicationId = "com.sikayetvar.sikayet_var"
        minSdk = 21
        targetSdk = 34
        // ...
    }
}
```

### android/build.gradle
```gradle
buildscript {
    ext.kotlin_version = '1.9.10'
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:8.1.3'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    }
}
```

### gradle-wrapper.properties
```
distributionUrl=https\://services.gradle.org/distributions/gradle-8.4-all.zip
```

---

**Not**: Bu yapılandırma güncel Android SDK gereksinimleriyle uyumlu olup, Flutter eklentilerinin en son sürümleriyle çalışmak için optimize edilmiştir. Android 15.0 resmi olarak yayınlandığında güncelleme gerekebilir.