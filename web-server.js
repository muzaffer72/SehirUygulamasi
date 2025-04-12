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

// Flutter web yüklenmesi için görsel durum sayfası
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
        <p><span class="error">✗</span> Flutter Web uygulaması çalışmıyor</p>
        
        <div class="panel">
          <h3>Web Uygulaması Sorun Bilgileri</h3>
          <p>Flutter web uygulaması şu anda MIME tipi sorunları nedeniyle doğru bir şekilde çalışmıyor:</p>
          <ul>
            <li>Web sunucusu, JavaScript dosyalarını doğru MIME türü ile sunmuyor</li>
            <li>Dart.js dosyası yükleme hataları oluşuyor</li>
            <li>Uygulama yükleme ekranında takılı kalıyor</li>
          </ul>
          
          <h3>Çözüm Bilgileri</h3>
          <p>Bu sorunları çözmek için:</p>
          <ul>
            <li>Flutter web uygulamasını <code>--release</code> modunda derleyerek statik dosyalar oluşturmak</li>
            <li>Doğru MIME türlerini içeren bir web sunucusu yapılandırmak (Apache veya Nginx)</li>
            <li>Alternatif olarak Firebase Hosting gibi statik hosting çözümleri kullanmak</li>
          </ul>
          
          <h3>Şu Anda Yapılabilecekler</h3>
          <p>Flutter mobil uygulaması sorunsuz çalışıyor. Web uygulaması için geliştirme ortamında sorunlarla karşılaşılıyor. Admin Panel kullanılarak platform yönetilebilir.</p>
          
          <a href="http://0.0.0.0:3000" target="_blank" class="btn">Admin Panel'e Git</a>
        </div>
      </div>
    </div>
  </body>
  </html>
  `;
  
  res.send(htmlContent);
});

// Diğer yollar için web klasörünü statik olarak servis et 
app.use(express.static('web'));

// Sunucuyu başlat
app.listen(PORT, '0.0.0.0', () => {
  console.log(`ŞikayetVar bilgi sayfası şu adreste çalışıyor: http://0.0.0.0:${PORT}`);
  console.log(`Admin Panel şu adreste çalışıyor: http://0.0.0.0:3000`);
});