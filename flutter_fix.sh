#!/bin/bash

# Bu script Flutter projesindeki Gradle ayarlarını düzenleyerek "unsupported gradle project" hatasını giderir.
# Çalıştırma: bash flutter_fix.sh

echo "Flutter Proje Düzeltme Script'i"
echo "================================="

# Önce eski Gradle sürümünü kontrol et
GRADLE_WRAPPER_PROPERTIES="android/gradle/wrapper/gradle-wrapper.properties"
CURRENT_GRADLE_VERSION=$(grep -oP 'distributionUrl=.*gradle-\K[0-9]+\.[0-9]+' $GRADLE_WRAPPER_PROPERTIES)

echo "Mevcut Gradle sürümü: $CURRENT_GRADLE_VERSION"

# build.gradle dosyalarını güncelle
echo "Android build.gradle dosyası güncelleniyor..."

# Ana build.gradle dosyasını güncelle
cat > android/build.gradle << EOF
buildscript {
    ext.kotlin_version = '1.9.22'
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:8.2.2'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:\$kotlin_version"
        classpath 'com.google.gms:google-services:4.4.0'
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.buildDir = '../build'
subprojects {
    project.buildDir = "\${rootProject.buildDir}/\${project.name}"
}

tasks.register("clean", Delete) {
    delete rootProject.buildDir
}
EOF

# app build.gradle dosyasını güncelle
cat > android/app/build.gradle << EOF
plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
    id "com.google.gms.google-services" apply false
}

def localProperties = new Properties()
def localPropertiesFile = rootProject.file('local.properties')
if (localPropertiesFile.exists()) {
    localPropertiesFile.withReader('UTF-8') { reader ->
        localProperties.load(reader)
    }
}

def flutterVersionCode = localProperties.getProperty('flutter.versionCode')
if (flutterVersionCode == null) {
    flutterVersionCode = '1'
}

def flutterVersionName = localProperties.getProperty('flutter.versionName')
if (flutterVersionName == null) {
    flutterVersionName = '1.0'
}

android {
    namespace "belediye.iletisim.merkezi"
    compileSdkVersion flutter.compileSdkVersion
    ndkVersion "25.1.8937393"

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = '17'
    }

    sourceSets {
        main.java.srcDirs += 'src/main/kotlin'
    }

    defaultConfig {
        applicationId "belediye.iletisim.merkezi"
        minSdkVersion flutter.minSdkVersion
        targetSdkVersion flutter.targetSdkVersion
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
        multiDexEnabled true
    }

    buildTypes {
        release {
            signingConfig signingConfigs.debug
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}

flutter {
    source '../..'
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk8:\$kotlin_version"
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-messaging")
    implementation 'androidx.multidex:multidex:2.0.1'
}

apply plugin: 'com.google.gms.google-services'
EOF

# settings.gradle dosyasını güncelle
cat > android/settings.gradle << EOF
pluginManagement {
    def flutterSdkPath = {
        def properties = new Properties()
        def propertiesFile = new File("local.properties")
        if (propertiesFile.exists()) {
            propertiesFile.withReader("UTF-8") { reader -> properties.load(reader) }
        }
        def flutterSdkPath = properties.getProperty("flutter.sdk")
        assert flutterSdkPath != null, "flutter.sdk not set in local.properties"
        return flutterSdkPath
    }()

    includeBuild("\${flutterSdkPath}/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id "dev.flutter.flutter-plugin-loader" version "1.0.0"
    id "com.android.application" version "8.2.2" apply false
    id "org.jetbrains.kotlin.android" version "1.9.22" apply false
}

include ":app"
EOF

# Gradle wrapper'ı 8.3'e yükselt (Java 21 için)
cat > android/gradle/wrapper/gradle-wrapper.properties << EOF
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.3-all.zip
EOF

echo "Flutter local.properties dosyası kontrol ediliyor..."
# local.properties dosyasının varlığını kontrol et ve yoksa oluştur
if [ ! -f "android/local.properties" ]; then
    echo "local.properties dosyası oluşturuluyor..."
    FLUTTER_SDK=$(which flutter)
    FLUTTER_SDK=$(dirname $(dirname $FLUTTER_SDK))
    echo "flutter.sdk=$FLUTTER_SDK" > android/local.properties
fi

echo "Flutter temizleniyor ve bağımlılıklar yeniden yükleniyor..."
flutter clean
flutter pub get

echo "İşlem tamamlandı!"
echo "Artık 'flutter build apk' komutu ile APK oluşturabilirsiniz."