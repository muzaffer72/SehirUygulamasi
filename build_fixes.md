# Build Notları ve Çözümler

## Flutter Gradle Projesi Hatası Çözümü

"Your app is using an unsupported Gradle project" hatası için aşağıdaki adımlar izlenmelidir:

1. Önceki projeyi yedekleyin:
```bash
mkdir -p temp_backup
cp -r lib temp_backup/
cp -r assets temp_backup/
cp pubspec.yaml temp_backup/
```

2. Yeni bir Flutter projesi oluşturun:
```bash
flutter create --org belediye.iletisim.merkezi -t app --platforms=android,ios,web ./new_project
```

3. Eski projedeki dosyaları yeni projeye taşıyın:
```bash
rm -rf new_project/lib/*
cp -r temp_backup/lib/* new_project/lib/
cp -r temp_backup/assets new_project/assets/
```

4. Android yapılandırmasını düzenleyin:
   - `new_project/android/app/build.gradle` dosyasını güncelleyin:
     - Paket adını `belediye.iletisim.merkezi` olarak ayarlayın
     - Firebase bağımlılıkları ekleyin
     - Java sürümünü 11 olarak ayarlayın
   - `new_project/android/settings.gradle` dosyasını güncelleyin:
     - Kotlin sürümünü 1.8.20 olarak ayarlayın

5. Firebase ve bildirim yapılandırmasını tamamlayın:
   - `FirebaseMessagingService.java` dosyasını oluşturun
   - Bildirim kanallarını ayarlayın

6. Eski projeyi değiştirin:
```bash
./replace_project.sh
```

## GitHub Actions APK Derlemesi

GitHub Actions ile APK derlemek için aşağıdaki adımlar takip edilmelidir:

### 1. GitHub Repository Ayarları

Repository'nin "Settings > Secrets and variables > Actions" bölümünde aşağıdaki gizli değişkenleri ekleyin:

- `API_BASE_URL`: API sunucusunun URL'si (örn: `https://workspace.guzelimbatmanli.repl.co/api`)
- `FIREBASE_API_KEY`: Firebase API anahtarı (gerekirse)

### 2. APK Derleme Sorunları

#### Android SDK Sorunları

Eğer `flutter build apk` sırasında Android SDK bulunamadı hatası alırsanız:

```
flutter config --android-sdk /path/to/android/sdk
```

#### Gradle Sorunları

Android gradle plugin sorunu için gradle.properties dosyasını güncelleyin:

```
android.useAndroidX=true
android.enableJetifier=true
```

#### Firebase Sorunları

Firebase sorunu için android/app/build.gradle dosyasına aşağıdaki satırı ekleyin:

```gradle
dependencies {
    // Diğer bağımlılıklar
    implementation platform('com.google.firebase:firebase-bom:32.3.1')
    implementation 'com.google.firebase:firebase-analytics'
}
```

### 3. APK Dosyasını Bulma

Derleme işlemi tamamlandıktan sonra, APK dosyasını GitHub Actions sayfasından Artifacts bölümünden indirebilirsiniz.

### 4. APK Versiyonlama

Flutter versiyonlama için pubspec.yaml dosyasını güncelleyin:

```yaml
version: 1.0.0+1  # format: Major.Minor.Patch+BuildNumber
```

Her yeni versiyonda BuildNumber değerini artırın.