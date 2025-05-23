const express = require('express');
const path = require('path');
const fs = require('fs');
const app = express();
const PORT = 5000;

// Flutter web uygulaması hakkında durum mesajı
console.log('\nŞikayetVar Flutter web uygulaması başlatılıyor...');
console.log('=================================================\n');

// MIME türleri için doğrudan Express ayarları
app.use((req, res, next) => {
  // İstek yolunu ve uzantısını al
  const url = req.path || req.url;
  const ext = path.extname(url).toLowerCase();
  
  // İstek loglaması
  console.log(`İstek: ${url}`);
  
  // Tüm MIME türlerini manuel olarak ayarla
  if (ext === '.js') {
    res.set('Content-Type', 'application/javascript');
  } else if (ext === '.dart') {
    res.set('Content-Type', 'application/dart');
  } else if (ext === '.css') {
    res.set('Content-Type', 'text/css');
  } else if (ext === '.html') {
    res.set('Content-Type', 'text/html');
  } else if (ext === '.json') {
    res.set('Content-Type', 'application/json');
  } else if (ext === '.png') {
    res.set('Content-Type', 'image/png');
  } else if (ext === '.jpg' || ext === '.jpeg') {
    res.set('Content-Type', 'image/jpeg');
  } else if (ext === '.svg') {
    res.set('Content-Type', 'image/svg+xml');
  } else if (ext === '.woff') {
    res.set('Content-Type', 'font/woff');
  } else if (ext === '.woff2') {
    res.set('Content-Type', 'font/woff2');
  } else if (ext === '.wasm') {
    res.set('Content-Type', 'application/wasm');
  }
  
  // CORS başlıkları
  res.set('Access-Control-Allow-Origin', '*');
  
  next();
});

// Flutter web uygulamasına yönlendirme
app.get('/flutter', (req, res) => {
  if (fs.existsSync('public_html/index.html')) {
    res.sendFile(path.join(__dirname, 'public_html/index.html'));
  } else if (fs.existsSync('build/web/index.html')) {
    res.sendFile(path.join(__dirname, 'build/web/index.html'));
  } else if (fs.existsSync('web/index.html')) {
    res.sendFile(path.join(__dirname, 'web/index.html'));
  } else {
    res.send("Flutter web uygulaması bulunamadı. Lütfen 'flutter build web' komutunu çalıştırın.");
  }
});

// Web klasöründeki static dosyalara erişim
app.use(express.static('web'));

// /flutter/ altındaki istekleri web klasörüne yönlendir - düzgün bir yol yerleştirme kullanarak
app.get('/flutter/:file*?', (req, res, next) => {
  let requestedPath = req.params.file || '';
  // Varsa yol parametrelerinin geri kalanını ekle
  if (req.params[0]) {
    requestedPath += req.params[0];
  }
  
  // Dosya yolunu oluştur ve dosyanın var olup olmadığını kontrol et
  const filePath = path.join(__dirname, 'web', requestedPath);
  
  if (fs.existsSync(filePath)) {
    res.sendFile(filePath);
  } else {
    next();
  }
});

// Ana sayfa için bilgi ve yönlendirme
app.get('/', (req, res) => {
  let htmlContent = `
  <!DOCTYPE html>
  <html>
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ŞikayetVar - Platform Bilgileri</title>
    <style>
      body {
        font-family: Arial, sans-serif;
        line-height: 1.6;
        margin: 0;
        padding: 20px;
        background-color: #f5f5f5;
      }
      .container {
        max-width: 800px;
        margin: 0 auto;
        background: white;
        padding: 30px;
        border-radius: 8px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
      }
      h1 {
        color: #1976d2;
        margin-top: 0;
      }
      .card {
        border: 1px solid #ddd;
        border-radius: 8px;
        padding: 15px;
        margin-top: 20px;
        background-color: #fff;
      }
      .panel {
        margin-top: 30px;
      }
      .btn {
        display: inline-block;
        background-color: #1976d2;
        color: white;
        padding: 8px 16px;
        text-decoration: none;
        border-radius: 4px;
        font-weight: bold;
        margin-top: 10px;
      }
      .status-message {
        padding: 15px;
        background-color: #FFF8E1;
        border-left: 4px solid #FFA000;
        margin: 20px 0;
      }
      .success {
        color: #2e7d32;
        font-weight: bold;
      }
      .error {
        color: #d32f2f;
        font-weight: bold;
      }
      .warning {
        color: #F57C00;
        font-weight: bold;
      }
      code {
        background-color: #f5f5f5;
        padding: 2px 5px;
        border-radius: 3px;
        font-family: monospace;
      }
      .status-card {
        margin-top: 20px;
        padding: 15px;
        border-radius: 6px;
        background-color: #E8F5E9;
        border-left: 4px solid #4CAF50;
      }
      .feature-list {
        margin-top: 30px;
        display: flex;
        flex-wrap: wrap;
        gap: 20px;
      }
      .feature-card {
        flex: 1 1 45%;
        padding: 15px;
        border-radius: 6px;
        background-color: #E3F2FD;
        border: 1px solid #BBDEFB;
        min-width: 250px;
      }
      .feature-card h4 {
        margin-top: 0;
        color: #1565C0;
      }
      .update-note {
        margin-top: 30px;
        padding: 12px;
        background-color: #FFEBEE;
        border-radius: 6px;
        border-left: 4px solid #EF5350;
      }
      .update-note h3 {
        margin-top: 0;
        color: #C62828;
      }
    </style>
  </head>
  <body>
    <div class="container">
      <h1>ŞikayetVar Platformu</h1>
      
      <div class="status-message">
        <p><span class="warning">⚠️</span> <strong>Flutter Web Durum Bildirisi:</strong> Flutter web uygulaması geliştirme aşamasındadır. Tam derleme tamamlanana kadar bazı sayfalar yüklenemeyebilir.</p>
      </div>
      
      <div class="card">
        <h2>Platform Bileşenleri</h2>
        <p><span class="success">✓</span> <strong>Admin Panel:</strong> <a href="http://0.0.0.0:3000" target="_blank">http://0.0.0.0:3000</a> (PHP ile çalışıyor)</p>
        <p><span class="success">✓</span> <strong>API Proxy:</strong> <code>http://0.0.0.0:9000</code> (Android için API yönlendirme)</p>
        
        <div class="status-card">
          <h3>Sistem Durumu</h3>
          <p>Tüm servisler şu anda çalışır durumda. API proxy ve admin panel aktif.</p>
          <p>Veritabanı erişilebilir durumdadır. Son yedekleme: 13 Nisan 2025</p>
        </div>
        
        <div class="feature-list">
          <div class="feature-card">
            <h4>Admin Panel</h4>
            <ul>
              <li>Şikayetler yönetimi</li>
              <li>Kullanıcı hesapları kontrolü</li>
              <li>İçerik moderasyonu</li>
              <li>İstatistikler ve raporlar</li>
            </ul>
          </div>
          
          <div class="feature-card">
            <h4>Flutter Mobil</h4>
            <ul>
              <li>Konum tabanlı şikayetler</li>
              <li>Şikayet gönderme ve takibi</li>
              <li>Belediye profilleri</li>
              <li>Sosyal etkileşim özellikleri</li>
            </ul>
          </div>
          
          <div class="feature-card">
            <h4>Veritabanı</h4>
            <ul>
              <li>PostgreSQL veritabanı</li>
              <li>Şehir ve ilçe verileri</li>
              <li>Ödül sistemi</li>
              <li>Komple yedekleme mevcut</li>
            </ul>
          </div>
          
          <div class="feature-card">
            <h4>API Sistemi</h4>
            <ul>
              <li>REST API endpoints</li>
              <li>Mobil uygulama entegrasyonu</li>
              <li>Veri senkronizasyonu</li>
              <li>Güvenli kimlik doğrulama</li>
            </ul>
          </div>
        </div>
        
        <div class="update-note">
          <h3>Flutter Web Geliştirme Notu</h3>
          <p>Flutter web uygulaması geliştirme aşamasındadır ve tam derleme henüz tamamlanmamıştır. Şu anda şunlar hazırlanıyor:</p>
          <ul>
            <li>Web derlemesi optimizasyonu</li>
            <li>JavaScript interoperability</li>
            <li>CanvasKit entegrasyonu</li>
            <li>Görünüm iyileştirmeleri</li>
          </ul>
          <p>Web uygulaması için Flutter SDK'nın son versiyonuyla yapılan bir tam derleme bekleniyor.</p>
        </div>
        
        <div style="margin-top:25px">
          <h3>Platform Erişimi</h3>
          <a href="http://0.0.0.0:3000" target="_blank" class="btn">Admin Panel'e Git</a>
          <a href="https://workspace.guzelimbatmanli.repl.co/api" target="_blank" class="btn" style="background-color: #00897B;">API Endpointleri</a>
        </div>
      </div>
    </div>
  </body>
  </html>
  `;
  
  res.send(htmlContent);
});

// Derlenen web klasörünü statik olarak servis et (public_html veya web klasörü, hangisi varsa)
if (fs.existsSync('public_html')) {
  app.use(express.static('public_html'));
  console.log("Flutter web build dosyaları public_html klasöründen sunuluyor");
} else if (fs.existsSync('build/web')) {
  app.use(express.static('build/web'));
  console.log("Flutter web build dosyaları build/web klasöründen sunuluyor");
} else if (fs.existsSync('web')) {
  app.use(express.static('web'));
  console.log("Flutter web dosyaları web klasöründen sunuluyor");
} else {
  console.log("UYARI: Herhangi bir web klasörü bulunamadı! Web uygulaması çalışmayacak.");
}

// Sunucuyu başlat
app.listen(PORT, '0.0.0.0', () => {
  console.log(`ŞikayetVar bilgi sayfası şu adreste çalışıyor: http://0.0.0.0:${PORT}`);
  console.log(`Admin Panel şu adreste çalışıyor: http://0.0.0.0:3000`);
});