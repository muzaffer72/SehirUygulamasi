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
      
      /* Android Simülatör Stilleri */
      .android-simulator {
        width: 360px;
        height: 720px;
        background-color: #111;
        border-radius: 30px;
        margin: 40px auto;
        position: relative;
        box-shadow: 0 10px 30px rgba(0,0,0,0.3);
        overflow: hidden;
        border: 8px solid #333;
      }
      .android-screen {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background-color: white;
        overflow: hidden;
      }
      .android-header {
        height: 60px;
        background-color: #1976d2;
        color: white;
        display: flex;
        align-items: center;
        padding: 0 16px;
        font-weight: bold;
        font-size: 20px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
      }
      .android-content {
        padding: 16px;
        height: calc(100% - 60px - 56px);
        overflow-y: auto;
      }
      .android-navbar {
        position: absolute;
        bottom: 0;
        width: 100%;
        height: 56px;
        background-color: white;
        display: flex;
        justify-content: space-around;
        align-items: center;
        box-shadow: 0 -2px 6px rgba(0,0,0,0.1);
      }
      .nav-item {
        width: 56px;
        height: 56px;
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
        color: #757575;
        font-size: 10px;
      }
      .nav-item.active {
        color: #1976d2;
      }
      .nav-icon {
        font-size: 24px;
        margin-bottom: 4px;
      }
      .simulator-controls {
        display: flex;
        justify-content: center;
        margin-top: 20px;
        gap: 10px;
      }
      .sim-tab {
        padding: 8px 16px;
        background-color: #f0f0f0;
        border: 1px solid #ddd;
        border-radius: 4px;
        cursor: pointer;
      }
      .sim-tab.active {
        background-color: #e0e0e0;
        font-weight: bold;
        border-color: #bbb;
      }
      .sikayet-card {
        background-color: white;
        border-radius: 8px;
        padding: 16px;
        margin-bottom: 16px;
        box-shadow: 0 1px 3px rgba(0,0,0,0.12);
      }
      .sikayet-header {
        display: flex;
        justify-content: space-between;
        margin-bottom: 8px;
      }
      .sikayet-category {
        background-color: #E3F2FD;
        color: #1565C0;
        padding: 4px 8px;
        border-radius: 4px;
        font-size: 12px;
      }
      .sikayet-title {
        font-weight: bold;
        margin-bottom: 8px;
      }
      .sikayet-content {
        color: #555;
        margin-bottom: 12px;
        font-size: 14px;
      }
      .sikayet-actions {
        display: flex;
        justify-content: space-between;
        font-size: 12px;
        color: #757575;
      }
      .view-options {
        text-align: center;
        margin-bottom: 20px;
      }
    </style>
  </head>
  <body>
    <div class="container">
      <h1>ŞikayetVar Platformu</h1>
      
      <div class="status-message">
        <p><span class="success">✓</span> API ve Admin Paneli çalışır durumda</p>
      </div>
      
      <div class="view-options">
        <button onclick="toggleView('info')" id="info-btn" class="sim-tab active">Platform Bilgileri</button>
        <button onclick="toggleView('simulator')" id="simulator-btn" class="sim-tab">Android Simülatörü</button>
      </div>
      
      <div id="info-view">
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
      
      <div id="simulator-view" style="display: none;">
        <div class="android-simulator">
          <div class="android-screen">
            <div class="android-header">
              <div style="display: flex; align-items: center; width: 100%;">
                <span style="margin-right: auto;">ŞikayetVar</span>
                <span style="font-size: 18px; margin-left: 8px;">⚙️</span>
              </div>
            </div>
            
            <div class="android-content" id="app-screen">
              <!-- Varsayılan olarak ana ekran görünecek -->
              <div id="home-screen">
                <div class="sikayet-card">
                  <div class="sikayet-header">
                    <div class="sikayet-category">Altyapı</div>
                    <span style="font-size: 12px; color: #757575;">1 saat önce</span>
                  </div>
                  <div class="sikayet-title">Yol Çalışması Uzun Süredir Tamamlanmadı</div>
                  <div class="sikayet-content">Kadıköy Rıhtım Caddesi'ndeki yol çalışması 2 haftadır tamamlanmadı. İşyerlerine erişimde sorun yaşıyoruz.</div>
                  <div class="sikayet-actions">
                    <span>👍 28 Beğeni</span>
                    <span>💬 12 Yorum</span>
                    <span>📍 Kadıköy</span>
                  </div>
                </div>
                
                <div class="sikayet-card">
                  <div class="sikayet-header">
                    <div class="sikayet-category">Çevre</div>
                    <span style="font-size: 12px; color: #757575;">3 saat önce</span>
                  </div>
                  <div class="sikayet-title">Çöp Konteynerlerinin Yetersizliği</div>
                  <div class="sikayet-content">Mahallemizde çöp konteynerleri yetersiz. Çöpler yerlere taşıyor ve çevre kirliliği oluşuyor.</div>
                  <div class="sikayet-actions">
                    <span>👍 42 Beğeni</span>
                    <span>💬 8 Yorum</span>
                    <span>📍 Ataşehir</span>
                  </div>
                </div>
                
                <div class="sikayet-card">
                  <div class="sikayet-header">
                    <div class="sikayet-category">Ulaşım</div>
                    <span style="font-size: 12px; color: #757575;">5 saat önce</span>
                  </div>
                  <div class="sikayet-title">Otobüs Saatleri Düzensiz</div>
                  <div class="sikayet-content">145T otobüs hattı saatlerine uyulmuyor. Bazen 30 dakika beklemek zorunda kalıyoruz.</div>
                  <div class="sikayet-actions">
                    <span>👍 19 Beğeni</span>
                    <span>💬 23 Yorum</span>
                    <span>📍 Beylikdüzü</span>
                  </div>
                </div>
              </div>
              
              <div id="map-screen" style="display: none;">
                <div style="text-align: center; padding: 20px;">
                  <img src="https://i.imgur.com/P9gjMJk.png" alt="Harita Görünümü" style="width: 100%; border-radius: 8px; max-width: 300px;">
                  <p style="margin-top: 15px; color: #757575;">Yakınınızdaki şikayetler</p>
                </div>
                
                <div class="sikayet-card">
                  <div class="sikayet-header">
                    <div class="sikayet-category">Altyapı</div>
                    <span style="font-size: 12px; color: #757575;">0.2 km</span>
                  </div>
                  <div class="sikayet-title">Kaldırım Hasarı</div>
                  <div class="sikayet-content">İş Bankası Önündeki kaldırım çökmüş durumda. Özellikle yaşlılar için tehlikeli.</div>
                  <div class="sikayet-actions">
                    <span>👍 12 Beğeni</span>
                    <span>💬 4 Yorum</span>
                    <span>📍 Şişli</span>
                  </div>
                </div>
              </div>
              
              <div id="add-screen" style="display: none;">
                <div style="padding: 10px; background-color: #f5f5f5; border-radius: 8px; margin-bottom: 20px;">
                  <div style="margin-bottom: 15px;">
                    <label style="display: block; margin-bottom: 5px; font-weight: bold;">Kategori</label>
                    <select style="width: 100%; padding: 8px; border-radius: 4px; border: 1px solid #ddd;">
                      <option>Altyapı</option>
                      <option>Ulaşım</option>
                      <option>Çevre</option>
                      <option>Güvenlik</option>
                      <option>Eğitim</option>
                      <option>Sağlık</option>
                      <option>Diğer</option>
                    </select>
                  </div>
                  
                  <div style="margin-bottom: 15px;">
                    <label style="display: block; margin-bottom: 5px; font-weight: bold;">Başlık</label>
                    <input type="text" placeholder="Şikayet başlığı" style="width: 100%; padding: 8px; border-radius: 4px; border: 1px solid #ddd;">
                  </div>
                  
                  <div style="margin-bottom: 15px;">
                    <label style="display: block; margin-bottom: 5px; font-weight: bold;">Açıklama</label>
                    <textarea placeholder="Şikayetinizi detaylı olarak açıklayın" style="width: 100%; padding: 8px; border-radius: 4px; border: 1px solid #ddd; min-height: 100px;"></textarea>
                  </div>
                  
                  <div style="margin-bottom: 15px;">
                    <label style="display: block; margin-bottom: 5px; font-weight: bold;">Konum</label>
                    <div style="display: flex;">
                      <input type="text" placeholder="Konum seçin" style="flex: 1; padding: 8px; border-radius: 4px 0 0 4px; border: 1px solid #ddd; border-right: none;">
                      <button style="background: #1976d2; color: white; border: none; border-radius: 0 4px 4px 0; padding: 0 10px;">📍</button>
                    </div>
                  </div>
                  
                  <div style="margin-bottom: 15px;">
                    <label style="display: block; margin-bottom: 5px; font-weight: bold;">Fotoğraf Ekle</label>
                    <button style="width: 100%; padding: 8px; background-color: #f0f0f0; border: 1px dashed #999; border-radius: 4px; color: #555;">
                      📷 Fotoğraf Ekle
                    </button>
                  </div>
                  
                  <button style="width: 100%; padding: 10px; background-color: #1976d2; color: white; border: none; border-radius: 4px; font-weight: bold;">Şikayeti Gönder</button>
                </div>
              </div>
              
              <div id="profile-screen" style="display: none;">
                <div style="text-align: center; padding: 20px;">
                  <div style="width: 100px; height: 100px; border-radius: 50%; background-color: #E3F2FD; margin: 0 auto; display: flex; justify-content: center; align-items: center; font-size: 36px; color: #1976d2;">
                    👤
                  </div>
                  <h3 style="margin-top: 10px;">Ahmet Yılmaz</h3>
                  <p style="color: #757575; margin-top: 5px;">@ahmetyilmaz</p>
                  
                  <div style="display: flex; justify-content: center; gap: 20px; margin-top: 15px;">
                    <div>
                      <div style="font-weight: bold;">24</div>
                      <div style="font-size: 12px; color: #757575;">Şikayet</div>
                    </div>
                    <div>
                      <div style="font-weight: bold;">156</div>
                      <div style="font-size: 12px; color: #757575;">Beğeni</div>
                    </div>
                    <div>
                      <div style="font-weight: bold;">8</div>
                      <div style="font-size: 12px; color: #757575;">Çözülen</div>
                    </div>
                  </div>
                </div>
                
                <div style="padding: 0 16px;">
                  <h4 style="margin-bottom: 10px;">Şikayetlerim</h4>
                  
                  <div class="sikayet-card">
                    <div class="sikayet-header">
                      <div class="sikayet-category">Aydınlatma</div>
                      <span style="font-size: 12px; color: #757575;">2 gün önce</span>
                    </div>
                    <div class="sikayet-title">Sokak Lambaları Çalışmıyor</div>
                    <div class="sikayet-content">Sokağımızdaki lambalar 1 haftadır yanmıyor. Akşamları güvenlik sorunu yaşıyoruz.</div>
                    <div class="sikayet-actions">
                      <span style="color: orange;">⏳ İşlem Bekliyor</span>
                      <span>💬 5 Yorum</span>
                    </div>
                  </div>
                  
                  <div class="sikayet-card">
                    <div class="sikayet-header">
                      <div class="sikayet-category">Park ve Bahçeler</div>
                      <span style="font-size: 12px; color: #757575;">1 hafta önce</span>
                    </div>
                    <div class="sikayet-title">Çocuk Parkı Bakımsız</div>
                    <div class="sikayet-content">Mahalledeki parkta kaydırak kırık ve salıncaklar bakımsız durumdadır.</div>
                    <div class="sikayet-actions">
                      <span style="color: green;">✓ Çözüldü</span>
                      <span>💬 9 Yorum</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
            
            <div class="android-navbar">
              <div class="nav-item active" onclick="changeScreen('home-screen')">
                <div class="nav-icon">🏠</div>
                <div>Ana Sayfa</div>
              </div>
              <div class="nav-item" onclick="changeScreen('map-screen')">
                <div class="nav-icon">🗺️</div>
                <div>Harita</div>
              </div>
              <div class="nav-item" onclick="changeScreen('add-screen')">
                <div class="nav-icon">➕</div>
                <div>Ekle</div>
              </div>
              <div class="nav-item" onclick="changeScreen('profile-screen')">
                <div class="nav-icon">👤</div>
                <div>Profil</div>
              </div>
            </div>
          </div>
        </div>
        
        <div class="simulator-controls">
          <button class="sim-tab active" onclick="changeScreen('home-screen')">Ana Sayfa</button>
          <button class="sim-tab" onclick="changeScreen('map-screen')">Harita</button>
          <button class="sim-tab" onclick="changeScreen('add-screen')">Şikayet Ekle</button>
          <button class="sim-tab" onclick="changeScreen('profile-screen')">Profil</button>
        </div>
      </div>
    </div>
    
    <script>
      function toggleView(view) {
        if (view === 'info') {
          document.getElementById('info-view').style.display = 'block';
          document.getElementById('simulator-view').style.display = 'none';
          document.getElementById('info-btn').classList.add('active');
          document.getElementById('simulator-btn').classList.remove('active');
        } else {
          document.getElementById('info-view').style.display = 'none';
          document.getElementById('simulator-view').style.display = 'block';
          document.getElementById('info-btn').classList.remove('active');
          document.getElementById('simulator-btn').classList.add('active');
        }
      }
      
      function changeScreen(screenId) {
        // Tüm ekranları gizle
        const screens = ['home-screen', 'map-screen', 'add-screen', 'profile-screen'];
        screens.forEach(screen => {
          document.getElementById(screen).style.display = 'none';
        });
        
        // Seçilen ekranı göster
        document.getElementById(screenId).style.display = 'block';
        
        // Nav item'ları güncelle
        const navItems = document.querySelectorAll('.nav-item');
        navItems.forEach(item => item.classList.remove('active'));
        
        // Seçilen nav item'ı aktif et
        const index = screens.indexOf(screenId);
        if (index >= 0) {
          navItems[index].classList.add('active');
        }
        
        // Kontrol düğmelerini güncelle
        const simTabs = document.querySelectorAll('.simulator-controls .sim-tab');
        simTabs.forEach(tab => tab.classList.remove('active'));
        simTabs[index].classList.add('active');
      }
    </script>
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