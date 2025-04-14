# GitHub Deployment

## Proje Dosyalarını GitHub'a Aktarma

Projeyi GitHub'a aktarmak ve GitHub Actions ile otomatik derleme yapılandırmak için:

### 1. GitHub Repository Oluştur

1. GitHub hesabınızda yeni bir repository oluşturun: `sikayet-var-app`
2. Repository ayarlarından aşağıdaki gizli değişkenleri ekleyin:
   - `API_BASE_URL`: `https://workspace.guzelimbatmanli.repl.co/api`
   - Gerekli diğer API anahtarları

### 2. Replit'ten GitHub'a Push İşlemi

Aşağıdaki komutları Replit Shell'de çalıştırın:

```bash
# Git repo başlat
git init

# Tüm değişiklikleri ekle
git add .

# GitHub'a push öncesi commit
git commit -m "Initial commit - ŞikayetVar app"

# GitHub repository'sini remote olarak ekle (YOUR_USERNAME yerine GitHub kullanıcı adınızı yazın)
git remote add origin https://github.com/YOUR_USERNAME/sikayet-var-app.git

# GitHub'a push işlemi
git push -u origin main
```

### 3. GitHub Actions Workflow Tetikleme

Repository'de GitHub Actions sekmesine gidin ve "Flutter Build" workflow'unu manuel olarak tetikleyin. Bu işlem:

1. Projeyi derleyecek
2. APK oluşturacak
3. APK dosyasını indirilebilir artifact olarak saklayacak

### 4. Releases Oluşturma

Yeni bir sürüm yayınlamak için:

1. GitHub repository'de "Releases" bölümüne gidin
2. "Create a new release" butonuna tıklayın
3. Sürüm numarasını girin (örn. v1.0.0)
4. Release notlarını ekleyin
5. "Publish release" butonuna tıklayın

Bu işlem "Flutter Release" workflow'unu tetikleyecek ve otomatik olarak APK dosyasını release'e ekleyecektir.

### 5. APK Dosyasını İndirme

Oluşturulan APK dosyasını iki şekilde indirebilirsiniz:

1. GitHub Actions > Workflow > Artifacts bölümünden
2. Releases sayfasından

### 6. Test Etme

İndirdiğiniz APK dosyasını Android cihazınıza kurup tüm özellikleri test edebilirsiniz.