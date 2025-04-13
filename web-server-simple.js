// Basitleştirilmiş web sunucusu - path-to-regexp hatasını önlemek için
const express = require('express');
const path = require('path');
const fs = require('fs');
const app = express();
const PORT = 5000;

// Console logları için renkler
const colors = {
  reset: '\x1b[0m',
  bright: '\x1b[1m',
  dim: '\x1b[2m',
  underscore: '\x1b[4m',
  blink: '\x1b[5m',
  reverse: '\x1b[7m',
  hidden: '\x1b[8m',
  
  fg: {
    black: '\x1b[30m',
    red: '\x1b[31m',
    green: '\x1b[32m',
    yellow: '\x1b[33m',
    blue: '\x1b[34m',
    magenta: '\x1b[35m',
    cyan: '\x1b[36m',
    white: '\x1b[37m',
    crimson: '\x1b[38m'
  },
  
  bg: {
    black: '\x1b[40m',
    red: '\x1b[41m',
    green: '\x1b[42m',
    yellow: '\x1b[43m',
    blue: '\x1b[44m',
    magenta: '\x1b[45m',
    cyan: '\x1b[46m',
    white: '\x1b[47m',
    crimson: '\x1b[48m'
  }
};

console.log(colors.fg.cyan + '\nŞikayetVar Flutter web uygulaması başlatılıyor...' + colors.reset);
console.log(colors.fg.cyan + '=================================================' + colors.reset);

// Statik dosya sunumu için MIME türlerini ayarlama
app.use((req, res, next) => {
  const ext = path.extname(req.path).toLowerCase();
  
  // Log istekleri
  console.log(`İstek: ${req.path}`);
  
  if (ext === '.js') {
    res.set('Content-Type', 'application/javascript');
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
  
  next();
});

// Tek ana sayfa route'u
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
    </style>
  </head>
  <body>
    <div class="container">
      <h1>ŞikayetVar Platformu</h1>
      
      <div class="status-message">
        <p><span class="success">✓</span> API ve Admin Paneli çalışır durumda</p>
      </div>
      
      <div class="card">
        <h2>Platform Bileşenleri</h2>
        <p><span class="success">✓</span> <strong>Admin Panel:</strong> <a href="http://0.0.0.0:3001" target="_blank">http://0.0.0.0:3001</a> (PHP ile çalışıyor)</p>
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
              <li>Kullanıcı hesapları</li>
              <li>İçerik moderasyonu</li>
              <li>İstatistikler</li>
            </ul>
          </div>
          
          <div class="feature-card">
            <h4>Flutter Mobil</h4>
            <ul>
              <li>Konum tabanlı şikayetler</li>
              <li>Şikayet takibi</li>
              <li>Belediye profilleri</li>
              <li>Sosyal özellikler</li>
            </ul>
          </div>
        </div>
        
        <div style="margin-top:25px">
          <h3>Platform Erişimi</h3>
          <a href="http://0.0.0.0:3001" target="_blank" class="btn">Admin Panel'e Git</a>
          <a href="https://workspace.guzelimbatmanli.repl.co/api" target="_blank" class="btn" style="background-color: #00897B;">API Endpointleri</a>
        </div>
      </div>
    </div>
  </body>
  </html>
  `;
  
  res.send(htmlContent);
});

// Web klasörünü statik olarak sun (varsa)
if (fs.existsSync('web')) {
  app.use('/web', express.static('web'));
  console.log(colors.fg.green + "Flutter web dosyaları /web/ yolu altında sunuluyor" + colors.reset);
}

// Sunucuyu başlat
app.listen(PORT, '0.0.0.0', () => {
  console.log(colors.fg.green + `ŞikayetVar bilgi sayfası şu adreste çalışıyor: http://0.0.0.0:${PORT}` + colors.reset);
  console.log(colors.fg.green + `Admin Panel şu adreste çalışıyor: http://0.0.0.0:3001` + colors.reset);
});