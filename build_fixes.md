# Build Notları ve Çözümler

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