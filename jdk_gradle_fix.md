# Android Studio Gradle JDK Sorunu Çözümü

Bu rehber, Android Studio'da Flutter projesini açarken yaşanan "Unsupported class file major version 65" Gradle JDK hatalarını çözmek için hazırlanmıştır.

## Sorunu Çözmek İçin Adımlar

### 1. Java JDK 17 Yükleme

Eğer sisteminizde yüklü değilse, Java JDK 17'yi yükleyin:
- [Adoptium JDK 17](https://adoptium.net/temurin/releases/?version=17) adresinden Java JDK 17'yi indirin
- Kurulumu tamamlayın ve sistem değişkenlerine eklendiğinden emin olun

### 2. Gradle Wrapper'ı Güncelleme

Gradle wrapper sürümünü güncelledik:
- `android/gradle/wrapper/gradle-wrapper.properties` dosyasında Gradle sürümünü 8.0'a yükselttik
- Bu, daha yeni JDK sürümleriyle uyumlu çalışmasını sağlar

### 3. Gradle Ayarlarını JDK 17 İle Kullanacak Şekilde Ayarlama

Gradle'ın JDK 17'yi kullanmasını sağlamak için ayarlar:
- `android/gradle.properties` dosyasını aşağıdaki ayarlarla güncelledik:
  ```
  org.gradle.jvmargs=-Xmx4G -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8
  android.useAndroidX=true
  android.enableJetifier=true
  org.gradle.java.home=C:\\Program Files\\Java\\jdk-17
  android.defaults.buildfeatures.buildconfig=true
  android.nonTransitiveRClass=false
  android.nonFinalResIds=false
  ```

- `org.gradle.java.home` değişkenini **sizin JDK 17 kurulum yolunuza göre değiştiriniz**

### 4. Gradle Cache'i Temizleme

Android Studio'da yaşanan Gradle sorunlarını çözmek için:

1. Aşağıdaki klasörleri silin:
   - `C:\Users\[kullanıcı-adı]\.gradle\caches\`
   - `C:\Users\[kullanıcı-adı]\.android\.gradle\`

2. Android Studio'yu tamamen kapatıp yeniden açın

3. Proje klasöründe aşağıdaki komutları çalıştırın:
   ```
   gradlew clean
   gradlew --refresh-dependencies
   ```

### 5. Android Studio Gradle JDK Ayarlarını Güncelleme

Android Studio'da:
1. **File > Settings > Build, Execution, Deployment > Build Tools > Gradle** yolunu izleyin
2. **Gradle JDK** ayarını seçin ve "JDK 17" olarak belirleyin
3. **Apply** ve **OK** butonlarına tıklayın

### 6. Gradle Sync İşlemini Tekrarlama

1. Android Studio'nun sağ üst kısmındaki "Sync Project with Gradle Files" butonuna tıklayın
2. Sync işleminin tamamlanmasını bekleyin

## Alternatif Çözüm

Eğer yukarıdaki adımlar sorunu çözmezse:

1. Android Studio'yu tamamen kapatın
2. Projenin ana dizininde komut istemini açın
3. Aşağıdaki komutları sırasıyla çalıştırın:
   ```bash
   set JAVA_HOME=C:\Program Files\Java\jdk-17
   .\gradlew.bat clean
   .\gradlew.bat --stop
   rmdir /s /q .gradle
   rmdir /s /q build
   ```
4. Ardından Android Studio'yu yeniden açın ve projeyi yeniden açın

Bu rehber takip edildiğinde, Android Studio'da Flutter projesini açarken karşılaşılan Gradle JDK sürüm uyumsuzluğu sorunu çözülecektir.