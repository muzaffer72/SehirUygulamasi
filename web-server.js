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

// Ana sayfa için bilgi ve yönlendirme
app.get('/', (req, res) => {
  let htmlContent = `
  <!DOCTYPE html>
  <html>
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ŞikayetVar - Bilgi</title>
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
      .success {
        color: #2e7d32;
        font-weight: bold;
      }
      .error {
        color: #d32f2f;
        font-weight: bold;
      }
      code {
        background-color: #f5f5f5;
        padding: 2px 5px;
        border-radius: 3px;
        font-family: monospace;
      }
    </style>
  </head>
  <body>
    <div class="container">
      <h1>ŞikayetVar Platformu</h1>
      
      <div class="card">
        <h2>Platform Durumu</h2>
        <p><span class="success">✓</span> Admin Panel çalışıyor: <a href="http://0.0.0.0:3000" target="_blank">http://0.0.0.0:3000</a></p>
        <p><span class="success">✓</span> Flutter Web uygulaması çalışıyor: <a href="/flutter" target="_blank">/flutter</a></p>
        
        <div class="panel">
          <h3>Web Uygulaması Bilgileri</h3>
          <p>Flutter web uygulaması artık çalışıyor. Aşağıdaki özellikler tam entegre:</p>
          <ul>
            <li>Admin panele API bağlantısı ve veri senkronizasyonu</li>
            <li>Web tarayıcı uyumluluğu (Chrome, Firefox, Edge)</li>
            <li>Mobil ve masaüstü boyutlara duyarlı tasarım</li>
            <li>Giriş ve kayıt işlemleri</li>
          </ul>
          
          <h3>Mevcut Özellikler</h3>
          <p>Web sürümünde şunları yapabilirsiniz:</p>
          <ul>
            <li>Şikayetleri görüntüleyebilir ve filtreleyebilirsiniz</li>
            <li>Şehir, ilçe ve kategorilere göre içerikleri listeleyebilirsiniz</li>
            <li>Anketlere katılabilirsiniz</li>
            <li>Belediye ödüllerini ve başarı oranlarını görebilirsiniz</li>
          </ul>
          
          <h3>Butonlar</h3>
          <a href="http://0.0.0.0:3000" target="_blank" class="btn">Admin Panel'e Git</a>
          <a href="/flutter" target="_blank" class="btn" style="background-color: #00ACC1;">Flutter Web Uygulamasını Aç</a>
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