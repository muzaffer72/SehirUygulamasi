# Java ve Gradle Uyumluluğu Sorunu Çözümü

## Sorun

Flutter projenizde aşağıdaki hatayı alıyorsanız:

```
FAILURE: Build failed with an exception.

* What went wrong:
Could not open cp_settings generic class cache for settings file 'android/settings.gradle'
> BUG! exception in phase 'semantic analysis' in source unit '_BuildScript_' Unsupported class file major version 65
```

Bu hata, kullandığınız Java sürümü ile Gradle sürümü arasında bir uyumsuzluk olduğu anlamına gelir. Java 21 gibi yeni bir sürüm kullanıyorsanız, Gradle sürümünüzün buna uyumlu olması gerekiyor.

## Çözüm

### 1. Gradle Wrapper Sürümünü Güncelleme

`android/gradle/wrapper/gradle-wrapper.properties` dosyasındaki Gradle sürümünü güncelleyin:

```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-8.3-all.zip
```

### 2. Android Gradle Plugin Sürümünü Güncelleme

`android/build.gradle` dosyasındaki Android Gradle Plugin sürümünü güncelleyin:

```gradle
dependencies {
    classpath 'com.android.tools.build:gradle:8.2.2'
    classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.22"
    // diğer bağımlılıklar
}
```

### 3. Kotlin Sürümünü Güncelleme

`android/build.gradle` dosyasındaki Kotlin sürümünü güncelleyin:

```gradle
buildscript {
    ext.kotlin_version = '1.9.22'
    // diğer ayarlar
}
```

### 4. Java Uyumluluğunu Ayarlama

`android/app/build.gradle` dosyasında Java uyumluluk ayarlarını güncelleyin:

```gradle
compileOptions {
    sourceCompatibility JavaVersion.VERSION_17
    targetCompatibility JavaVersion.VERSION_17
}

kotlinOptions {
    jvmTarget = '17'
}
```

### 5. Gradle Properties Dosyasını Güncelleme

`android/gradle.properties` dosyasına gerekli ayarları ekleyin:

```properties
org.gradle.jvmargs=-Xmx4G -XX:MaxMetaspaceSize=1g
android.useAndroidX=true
android.enableJetifier=true
android.defaults.buildfeatures.buildconfig=true
android.nonFinalResIds=false
```

### Java-Gradle Uyumluluk Matrisi

| Java Sürümü | Uyumlu Gradle Sürümü |
|-------------|----------------------|
| Java 8      | Gradle 2.0 - 7.6     |
| Java 11     | Gradle 5.0 - 7.6     |
| Java 17     | Gradle 7.3+          |
| Java 21     | Gradle 8.3+          |

### Projeyi Yeniden Derleme

Yapılandırma dosyalarını güncelledikten sonra:

```bash
flutter clean
flutter pub get
cd android && ./gradlew clean && cd ..
flutter build apk --debug
```

Bu adımlar, Flutter projenizdeki Java ve Gradle uyumsuzluğu sorununu çözmelidir.