# Android Projenin Modern Gradle Sürümüne Geçişi

## Sorun

Projemizde, "Your app is using an unsupported Gradle project" hatası alıyorduk. Bu hatanın temel nedeni, kullanılan Java sürümüyle Gradle sürümü arasındaki uyumsuzluktu. Ayrıca, Firebase eklentilerinde de uyumsuzluklar vardı.

## Çözümler

### Gradle & Java Uyumluluğu

Java 21 kullanıyorsanız, Gradle'ın en az 8.3 sürümü gereklidir. Aşağıdaki değişiklikleri yaptık:

1. `gradle-wrapper.properties` dosyasında Gradle sürümünü 8.3'e yükselttik:
   ```properties
   distributionUrl=https\://services.gradle.org/distributions/gradle-8.3-all.zip
   ```

2. Android Gradle Plugin ve Kotlin sürümlerini güncelledik:
   ```gradle
   // build.gradle
   buildscript {
       ext.kotlin_version = '1.9.22'
       dependencies {
           classpath 'com.android.tools.build:gradle:8.2.2'
           classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
       }
   }
   ```

3. Java uyumluluğunu Java 17'ye ayarladık:
   ```gradle
   // app/build.gradle
   compileOptions {
       sourceCompatibility JavaVersion.VERSION_17
       targetCompatibility JavaVersion.VERSION_17
   }
   kotlinOptions {
       jvmTarget = '17'
   }
   ```

### Firebase Eklentileri Sorunları

Firebase eklentilerinde yaşanan sorunları çözmek için:

1. Firebase bağımlılıklarını daha stabil sürümlere düşürdük:
   ```yaml
   # pubspec.yaml
   firebase_core: ^2.13.1
   firebase_auth: ^4.6.2
   firebase_storage: ^11.2.2
   firebase_messaging: ^14.6.2
   flutter_local_notifications: ^14.1.1
   ```

2. `app/build.gradle` dosyasını daha basit bir yapıyla yeniden düzenledik:
   ```gradle
   dependencies {
       implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk8:$kotlin_version"
       implementation(platform("com.google.firebase:firebase-bom:32.7.0"))
       implementation("com.google.firebase:firebase-analytics")
       implementation("com.google.firebase:firebase-messaging")
       implementation 'androidx.multidex:multidex:2.0.1'
   }
   
   apply plugin: 'com.google.gms.google-services'
   ```

3. `settings.gradle` dosyasındaki fazla plugin kodlarını kaldırdık.

## Java-Gradle Sürüm Uyumluluğu Tablosu

| Java Sürümü | Uyumlu Gradle Sürümleri |
|-------------|-------------------------|
| Java 8      | 2.0 - 7.6              |
| Java 11     | 5.0 - 7.6              |
| Java 17     | 7.3+                   |
| Java 21     | 8.3+                   |

## Sonuç

Bu değişikliklerden sonra, proje başarıyla modern Gradle ve Java sürümleriyle uyumlu hale geldi. Artık "unsupported Gradle project" hatası almıyoruz ve Firebase eklentileri düzgün çalışıyor.