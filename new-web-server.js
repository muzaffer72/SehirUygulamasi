// Geliştirilmiş web sunucusu - Mobil ve masaüstü görünümleri ile
const express = require('express');
const path = require('path');
const fs = require('fs');
const http = require('http');
const https = require('https');
const app = express();

// Assets klasörü için statik içerik sunumu
app.use('/assets', express.static(path.join(__dirname, 'assets')));
// Replit sadece 5000 portuna dışarıdan erişime izin veriyor
const PORT = 5000;

// API'den veri çekme fonksiyonu
function fetchApiData(endpoint) {
  return new Promise((resolve, reject) => {
    // API proxy üzerinden istek yap
    const apiUrl = `http://0.0.0.0:9000/api/${endpoint}`;
    console.log(`API isteği yapılıyor: ${apiUrl}`);
    
    http.get(apiUrl, (res) => {
      let data = '';
      
      // Veri parçalarını topla
      res.on('data', (chunk) => {
        data += chunk;
      });
      
      // Tüm veri alındığında
      res.on('end', () => {
        if (res.statusCode === 200) {
          try {
            const jsonData = JSON.parse(data);
            console.log('API yanıtı başarılı');
            resolve(jsonData);
          } catch (error) {
            console.error('JSON ayrıştırma hatası:', error);
            reject(error);
          }
        } else {
          console.error(`API hatası: ${res.statusCode}`);
          reject(new Error(`API hatası: ${res.statusCode}`));
        }
      });
    }).on('error', (error) => {
      console.error('API bağlantı hatası:', error);
      reject(error);
    });
  });
}

// Console logları için renkler
const colors = {
  reset: '\x1b[0m',
  bright: '\x1b[1m',
  dim: '\x1b[2m',
  fg: {
    cyan: '\x1b[36m',
    green: '\x1b[32m',
    yellow: '\x1b[33m',
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

// Flutter web linki yerine doğrudan statik içerik sunalım
console.log(colors.fg.green + 'Mobil görünüm için statik içerik hazırlandı' + colors.reset);

// Ana sayfa
app.get('/', (req, res) => {
  res.send(`
  <!DOCTYPE html>
  <html>
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ŞikayetVar - Platform</title>
    <style>
      body {
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        line-height: 1.6;
        margin: 0;
        padding: 0;
        background-color: #f8f9fa;
        color: #333;
      }
      .header {
        background-color: #1976d2;
        color: white;
        padding: 1.5rem;
        text-align: center;
        box-shadow: 0 2px 5px rgba(0,0,0,0.1);
      }
      .container {
        max-width: 1200px;
        margin: 0 auto;
        padding: 2rem;
      }
      .card {
        background-color: white;
        border-radius: 8px;
        padding: 1.5rem;
        margin-bottom: 1.5rem;
        box-shadow: 0 2px 10px rgba(0,0,0,0.05);
      }
      .section-title {
        border-bottom: 2px solid #e0e0e0;
        padding-bottom: 0.5rem;
        color: #1976d2;
      }
      .btn {
        display: inline-block;
        background-color: #1976d2;
        color: white;
        padding: 0.8rem 1.5rem;
        text-decoration: none;
        border-radius: 4px;
        font-weight: 500;
        margin-right: 0.5rem;
        margin-bottom: 0.5rem;
        transition: background-color 0.2s;
      }
      .btn:hover {
        background-color: #1565c0;
      }
      .btn.secondary {
        background-color: #f5f5f5;
        color: #333;
        border: 1px solid #ddd;
      }
      .btn.secondary:hover {
        background-color: #e0e0e0;
      }
      .view-options {
        display: flex;
        justify-content: center;
        margin-bottom: 2rem;
        flex-wrap: wrap;
      }
      .platform-status {
        display: flex;
        flex-wrap: wrap;
        gap: 1rem;
        margin-top: 1rem;
      }
      .status-item {
        flex: 1;
        min-width: 250px;
        background-color: #e8f5e9;
        padding: 1rem;
        border-radius: 4px;
        border-left: 4px solid #4caf50;
      }
      .feature-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
        gap: 1.5rem;
        margin-top: 1.5rem;
      }
      .feature-card {
        background-color: white;
        border-radius: 8px;
        padding: 1.5rem;
        box-shadow: 0 2px 8px rgba(0,0,0,0.08);
        transition: transform 0.2s;
      }
      .feature-card:hover {
        transform: translateY(-3px);
      }
      .feature-icon {
        width: 48px;
        height: 48px;
        background-color: #e3f2fd;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        margin-bottom: 1rem;
        color: #1976d2;
        font-size: 1.5rem;
      }
      .device-wrapper {
        display: flex;
        justify-content: center;
        margin: 3rem 0;
      }
      /* Mobil cihaz görünümü */
      .mobile-device {
        width: 320px;
        height: 650px;
        background-color: #111;
        border-radius: 36px;
        padding: 10px;
        box-shadow: 0 15px 30px rgba(0,0,0,0.3);
        position: relative;
        overflow: hidden;
      }
      .device-screen {
        background-color: white;
        width: 100%;
        height: 100%;
        border-radius: 30px;
        overflow: hidden;
      }
      .device-notch {
        position: absolute;
        width: 150px;
        height: 24px;
        background-color: #111;
        top: 0;
        left: 50%;
        transform: translateX(-50%);
        border-bottom-left-radius: 16px;
        border-bottom-right-radius: 16px;
        z-index: 10;
      }
      .device-home {
        position: absolute;
        width: 120px;
        height: 5px;
        background-color: #333;
        bottom: 15px;
        left: 50%;
        transform: translateX(-50%);
        border-radius: 3px;
        z-index: 10;
      }
      .mobile-header {
        height: 60px;
        background-color: #1976d2;
        display: flex;
        align-items: center;
        padding: 0 16px;
        color: white;
        font-weight: 500;
      }
      .mobile-content {
        padding: 16px;
        height: calc(100% - 60px - 56px);
        overflow-y: auto;
      }
      .mobile-bottom-nav {
        height: 56px;
        background-color: white;
        position: absolute;
        bottom: 0;
        width: 100%;
        display: flex;
        justify-content: space-around;
        align-items: center;
        box-shadow: 0 -2px 10px rgba(0,0,0,0.05);
      }
      .nav-item {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        color: #757575;
        font-size: 10px;
      }
      .nav-item.active {
        color: #1976d2;
      }
      .notification-item {
        padding: 16px;
        border-bottom: 1px solid #f0f0f0;
        display: flex;
        align-items: flex-start;
      }
      .notification-icon {
        width: 40px;
        height: 40px;
        border-radius: 50%;
        background-color: #e3f2fd;
        display: flex;
        align-items: center;
        justify-content: center;
        margin-right: 12px;
        flex-shrink: 0;
        color: #1976d2;
      }
      .notification-content {
        flex-grow: 1;
      }
      .notification-title {
        font-weight: 500;
        margin-bottom: 4px;
      }
      .notification-text {
        color: #757575;
        font-size: 14px;
        margin-bottom: 8px;
      }
      .notification-time {
        font-size: 12px;
        color: #9e9e9e;
      }
      .unread {
        background-color: #e3f2fd;
      }
      .view-tabs {
        display: flex;
        margin-bottom: 1rem;
      }
      .view-tab {
        padding: 8px 16px;
        cursor: pointer;
        border-bottom: 2px solid transparent;
      }
      .view-tab.active {
        border-bottom-color: #1976d2;
        color: #1976d2;
        font-weight: 500;
      }
      .section-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 1rem;
      }
      .section-header h3 {
        margin: 0;
      }
      
      /* Responsive layout */
      @media (max-width: 768px) {
        .container {
          padding: 1rem;
        }
        .platform-status {
          flex-direction: column;
        }
      }
    </style>
  </head>
  <body>
    <div class="header">
      <h1>ŞikayetVar Platform</h1>
    </div>
    
    <div class="container">
      <div class="view-options">
        <a href="/" class="btn">Platform Bilgileri</a>
        <a href="/mobile" class="btn secondary">Mobil Görünüm</a>
        <a href="/pharmacies" class="btn secondary">Nöbetçi Eczaneler</a>
      </div>
      
      <div class="card">
        <h2 class="section-title">Platform Bileşenleri</h2>
        
        <div class="platform-status">
          <div class="status-item">
            <h3>Web Sunucusu</h3>
            <p>Durum: <strong style="color: #4caf50;">✓ Çalışıyor</strong></p>
            <p>Port: 5000</p>
          </div>
          
          <div class="status-item">
            <h3>Admin Panel</h3>
            <p>Durum: <strong style="color: #4caf50;">✓ Çalışıyor</strong></p>
            <p>URL: <a href="http://0.0.0.0:3001" target="_blank">http://0.0.0.0:3001</a></p>
          </div>
          
          <div class="status-item">
            <h3>API Proxy</h3>
            <p>Durum: <strong style="color: #4caf50;">✓ Çalışıyor</strong></p>
            <p>Port: 9000</p>
          </div>
        </div>
      </div>
      
      <div class="card">
        <div class="section-header">
          <h2 class="section-title">Platform Özellikleri</h2>
        </div>
        
        <div class="feature-grid">
          <div class="feature-card">
            <div class="feature-icon">📱</div>
            <h3>Mobil Uygulama</h3>
            <p>Android ve iOS için Flutter tabanlı, yerel kullanım deneyimi sunan uygulama.</p>
          </div>
          
          <div class="feature-card">
            <div class="feature-icon">🌐</div>
            <h3>Web Arayüzü</h3>
            <p>Duyarlı tasarım ile her cihaza uyumlu web arayüzü.</p>
          </div>
          
          <div class="feature-card">
            <div class="feature-icon">⚙️</div>
            <h3>Admin Panel</h3>
            <p>Kapsamlı yönetim paneli ile tüm içerik ve kullanıcıları yönetme.</p>
          </div>
          
          <div class="feature-card">
            <div class="feature-icon">🔔</div>
            <h3>Bildirim Sistemi</h3>
            <p>Firebase entegrasyonu ile gerçek zamanlı bildirimler.</p>
          </div>
          
          <div class="feature-card">
            <div class="feature-icon">📊</div>
            <h3>İstatistikler</h3>
            <p>Detaylı analitik ve raporlama özellikleri.</p>
          </div>
          
          <div class="feature-card">
            <div class="feature-icon">🗺️</div>
            <h3>Konum Tabanlı</h3>
            <p>Şehir ve ilçeye özel içerik ve bildirimler.</p>
          </div>
        </div>
      </div>
    </div>
  </body>
  </html>
  `);
});

// Mobil görünüm - Admin panel API entegrasyonlu
// Statik sayfalar için klasör tanımla
app.use('/web/pages', express.static(path.join(__dirname, 'web/pages')));

// Nöbetçi eczane sayfası
app.get('/pharmacies', (req, res) => {
  // Statik HTML sayfasını gönder
  res.sendFile(path.join(__dirname, 'web/pages/pharmacies.html'));
});

app.get('/mobile', async (req, res) => {
  let postsHtml = '';
  
  try {
    // API'den gönderileri çek
    const postsData = await fetchApiData('posts');
    console.log('Gönderiler API\'den başarıyla çekildi');
    
    // API yanıtından gönderileri al
    const posts = Array.isArray(postsData) ? postsData : (postsData.posts || []);
    
    if (posts.length > 0) {
      // Her bir gönderi için HTML oluştur
      postsHtml = posts.map(post => {
        // Gönderinin kullanıcı bilgilerini al
        const user = post.user || {};
        const username = user.username || post.username || 'İsimsiz';
        const displayName = user.name || post.user_name || username;
        const profileImageUrl = user.profile_image_url || post.profile_image_url || `https://ui-avatars.com/api/?name=${encodeURIComponent(displayName)}&background=random`;
        
        // Şehir ve ilçe bilgilerini al
        const cityName = post.city_name || 'Bilinmeyen Şehir';
        const districtName = post.district_name || '';
        const locationText = districtName ? `${cityName}, ${districtName}` : cityName;
        
        // Gönderi içeriği ve etkileşim bilgileri
        const likes = post.likes || post.like_count || 0;
        const commentCount = post.comment_count || 0;
        const postDate = formatDate(post.created_at);
        
        return `
        <div class="post-card">
          <div class="post-header">
            <div class="post-avatar">
              <img src="${profileImageUrl}" alt="${displayName}" onerror="this.src='https://ui-avatars.com/api/?name=${encodeURIComponent(displayName)}&background=random'">
            </div>
            <div class="post-info">
              <div class="post-author-container">
                <div class="post-author">${displayName}</div>
                <div class="post-username">@${username}</div>
              </div>
              <div class="post-location-container" onclick="window.location.href='/city/${post.city_id}'">
                <i class="location-icon">📍</i>
                <div class="post-location-text">${locationText}</div>
              </div>
              <div class="post-date">${postDate}</div>
            </div>
          </div>
          <div class="post-content">
            <h3 class="post-title">${post.title}</h3>
            <p class="post-text">${post.content}</p>
            ${post.media && post.media.length > 0 ? 
              `<div class="post-image-container">
                <img src="${post.media[0].url}" class="post-image" alt="Gönderi resmi">
              </div>` : ''}
          </div>
          <div class="post-category">
            <i class="category-icon">${post.category_icon || '📋'}</i>
            <span>${post.category_name || 'Genel'}</span>
          </div>
          <div class="post-actions">
            <div class="post-action">
              <i class="action-icon">👍</i>
              <span>${likes}</span>
            </div>
            <div class="post-action">
              <i class="action-icon">💬</i>
              <span>${commentCount}</span>
            </div>
            <div class="post-action status-indicator status-${post.status}">
              <i class="action-icon">${getStatusIcon(post.status)}</i>
              <span>${getStatusText(post.status)}</span>
            </div>
          </div>
        </div>
        `;
      }).join('');
    } else {
      postsHtml = `
        <div class="empty-state">
          <div class="empty-icon">📭</div>
          <h3>Henüz Gönderi Yok</h3>
          <p>Şu anda gösterilecek gönderi bulunmuyor</p>
        </div>
      `;
    }
  } catch (error) {
    console.error('Gönderileri çekerken hata oluştu:', error);
    postsHtml = `
      <div class="error-state">
        <div class="error-icon">❌</div>
        <h3>Gönderileri Yüklerken Hata Oluştu</h3>
        <p>Lütfen daha sonra tekrar deneyin: ${error.message}</p>
      </div>
    `;
  }
  
  // Gönderi durum metni ve ikonları için yardımcı fonksiyonlar
  function getStatusText(status) {
    switch (status) {
      case 'awaitingSolution': return 'Çözüm Bekliyor';
      case 'inProgress': return 'İşlemde';
      case 'solved': return 'Çözüldü';
      case 'rejected': return 'Reddedildi';
      default: return 'Bilinmiyor';
    }
  }
  
  function getStatusIcon(status) {
    switch (status) {
      case 'awaitingSolution': return '⏳';
      case 'inProgress': return '🔄';
      case 'solved': return '✅';
      case 'rejected': return '❌';
      default: return '❓';
    }
  }
  
  // Tarih formatı için yardımcı fonksiyon
  function formatDate(dateString) {
    if (!dateString) return '';
    const date = new Date(dateString);
    return date.toLocaleDateString('tr-TR', {
      year: 'numeric',
      month: 'short',
      day: 'numeric'
    });
  }
  
  res.send(`
  <!DOCTYPE html>
  <html>
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ŞikayetVar - Mobil Görünüm</title>
    <style>
      body {
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        line-height: 1.6;
        margin: 0;
        padding: 0;
        background-color: #f8f9fa;
        color: #333;
      }
      
      /* Gönderi kartları için stiller */
      .post-card {
        background-color: white;
        border-radius: 12px;
        margin-bottom: 16px;
        box-shadow: 0 1px 5px rgba(0,0,0,0.08);
        overflow: hidden;
        transition: transform 0.2s ease, box-shadow 0.2s ease;
      }
      .post-card:active {
        transform: scale(0.98);
        box-shadow: 0 1px 2px rgba(0,0,0,0.12);
      }
      .post-header {
        display: flex;
        padding: 12px 16px;
        align-items: flex-start;
        border-bottom: 1px solid #f0f0f0;
      }
      .post-avatar {
        width: 48px;
        height: 48px;
        border-radius: 50%;
        background-color: #f5f5f5;
        overflow: hidden;
        margin-right: 12px;
        flex-shrink: 0;
      }
      .post-avatar img {
        width: 100%;
        height: 100%;
        object-fit: cover;
      }
      .post-info {
        flex-grow: 1;
      }
      .post-author-container {
        display: flex;
        align-items: baseline;
        margin-bottom: 4px;
        flex-wrap: wrap;
      }
      .post-author {
        font-weight: 600;
        margin-right: 6px;
        font-size: 15px;
        color: #212121;
      }
      .post-username {
        font-size: 14px;
        color: #757575;
        margin-right: 6px;
      }
      .post-date {
        font-size: 12px;
        color: #9e9e9e;
        margin-top: 4px;
      }
      .post-location-container {
        display: flex;
        align-items: center;
        margin-top: 4px;
        font-size: 13px;
        color: #1976d2;
        cursor: pointer;
      }
      .location-icon {
        margin-right: 4px;
        font-style: normal;
        font-size: 14px;
      }
      .post-location-text {
        text-decoration: none;
        color: #1976d2;
      }
      .post-location-container:hover .post-location-text {
        text-decoration: underline;
      }
      .post-content {
        padding: 16px;
      }
      .post-title {
        margin-top: 0;
        margin-bottom: 8px;
        font-size: 18px;
      }
      .post-text {
        margin-bottom: 16px;
        color: #333;
      }
      .post-image-container {
        margin: 0 -16px;
        margin-bottom: -16px;
      }
      .post-image {
        width: 100%;
        display: block;
      }
      .post-actions {
        display: flex;
        border-top: 1px solid #f0f0f0;
        padding: 8px 0;
      }
      .post-action {
        display: flex;
        align-items: center;
        justify-content: center;
        flex: 1;
        padding: 8px 0;
        color: #757575;
        font-size: 14px;
      }
      .action-icon {
        margin-right: 6px;
        font-style: normal;
      }
      
      /* Kategori stili */
      .post-category {
        display: flex;
        align-items: center;
        padding: 8px 16px;
        font-size: 13px;
        background-color: #f9f9f9;
        color: #555;
        border-top: 1px solid #f0f0f0;
      }
      .category-icon {
        margin-right: 8px;
        font-style: normal;
        color: #1976d2;
      }
      
      /* Durum göstergeleri */
      .status-indicator {
        font-weight: 500;
      }
      .status-awaitingSolution {
        color: #ff9800;
      }
      .status-inProgress {
        color: #2196f3;
      }
      .status-solved {
        color: #4caf50;
      }
      .status-rejected {
        color: #f44336;
      }
      
      /* Boş durum ve hata durumu için stiller */
      .empty-state, .error-state {
        padding: 32px 16px;
        text-align: center;
        background-color: white;
        border-radius: 8px;
        margin-bottom: 16px;
      }
      .empty-icon, .error-icon {
        font-size: 48px;
        margin-bottom: 16px;
      }
      .error-state {
        background-color: #ffebee;
      }
      .header {
        background-color: #1976d2;
        color: white;
        padding: 1rem;
        text-align: center;
      }
      .container {
        max-width: 1200px;
        margin: 0 auto;
        padding: 1rem;
      }
      .btn {
        display: inline-block;
        background-color: #1976d2;
        color: white;
        padding: 0.5rem 1rem;
        text-decoration: none;
        border-radius: 4px;
        font-weight: 500;
        margin-right: 0.5rem;
        margin-bottom: 0.5rem;
      }
      .btn.secondary {
        background-color: #f5f5f5;
        color: #333;
        border: 1px solid #ddd;
      }
      .view-options {
        display: flex;
        justify-content: center;
        margin-bottom: 1rem;
        flex-wrap: wrap;
      }
      .device-wrapper {
        display: flex;
        justify-content: center;
        margin: 2rem 0;
      }
      /* Mobil cihaz görünümü */
      .mobile-device {
        width: 320px;
        height: 650px;
        background-color: #111;
        border-radius: 36px;
        padding: 10px;
        box-shadow: 0 15px 30px rgba(0,0,0,0.3);
        position: relative;
        overflow: hidden;
      }
      .device-screen {
        background-color: white;
        width: 100%;
        height: 100%;
        border-radius: 30px;
        overflow: hidden;
      }
      .device-notch {
        position: absolute;
        width: 150px;
        height: 24px;
        background-color: #111;
        top: 0;
        left: 50%;
        transform: translateX(-50%);
        border-bottom-left-radius: 16px;
        border-bottom-right-radius: 16px;
        z-index: 10;
      }
      .device-home {
        position: absolute;
        width: 120px;
        height: 5px;
        background-color: #333;
        bottom: 15px;
        left: 50%;
        transform: translateX(-50%);
        border-radius: 3px;
        z-index: 10;
      }
      .mobile-header {
        height: 60px;
        background-color: #1976d2;
        display: flex;
        align-items: center;
        padding: 0 16px;
        color: white;
        font-weight: 500;
        justify-content: space-between;
      }
      .mobile-content {
        padding: 16px;
        height: calc(100% - 60px - 56px);
        overflow-y: auto;
      }
      .mobile-bottom-nav {
        height: 56px;
        background-color: white;
        position: absolute;
        bottom: 0;
        width: 100%;
        display: flex;
        justify-content: space-around;
        align-items: center;
        box-shadow: 0 -2px 10px rgba(0,0,0,0.05);
      }
      .nav-item {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        color: #757575;
        font-size: 10px;
      }
      .nav-item.active {
        color: #1976d2;
      }
      .notification-item {
        padding: 16px;
        border-bottom: 1px solid #f0f0f0;
        display: flex;
        align-items: flex-start;
      }
      .notification-icon {
        width: 40px;
        height: 40px;
        border-radius: 50%;
        background-color: #e3f2fd;
        display: flex;
        align-items: center;
        justify-content: center;
        margin-right: 12px;
        flex-shrink: 0;
        color: #1976d2;
      }
      .notification-content {
        flex-grow: 1;
      }
      .notification-title {
        font-weight: 500;
        margin-bottom: 4px;
      }
      .notification-text {
        color: #757575;
        font-size: 14px;
        margin-bottom: 8px;
      }
      .notification-time {
        font-size: 12px;
        color: #9e9e9e;
      }
      .unread {
        background-color: #e3f2fd;
      }
      .screen-selector {
        display: flex;
        justify-content: center;
        margin-bottom: 1rem;
      }
      .screen-button {
        padding: 0.5rem 1rem;
        margin: 0 0.5rem;
        border: 1px solid #ddd;
        border-radius: 4px;
        background-color: #f5f5f5;
        cursor: pointer;
      }
      .screen-button.active {
        background-color: #e0e0e0;
        font-weight: bold;
      }
      .screen {
        display: none;
      }
      .screen.active {
        display: block;
      }
      .settings-item {
        padding: 16px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        border-bottom: 1px solid #f0f0f0;
      }
      .settings-icon {
        width: 40px;
        height: 40px;
        border-radius: 50%;
        background-color: #f5f5f5;
        display: flex;
        align-items: center;
        justify-content: center;
        margin-right: 12px;
      }
      .settings-content {
        flex-grow: 1;
      }
      .settings-title {
        font-weight: 500;
      }
      .settings-description {
        font-size: 12px;
        color: #757575;
      }
      .switch {
        position: relative;
        display: inline-block;
        width: 40px;
        height: 24px;
      }
      .switch input {
        opacity: 0;
        width: 0;
        height: 0;
      }
      .slider {
        position: absolute;
        cursor: pointer;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background-color: #ccc;
        transition: .4s;
        border-radius: 24px;
      }
      .slider:before {
        position: absolute;
        content: "";
        height: 16px;
        width: 16px;
        left: 4px;
        bottom: 4px;
        background-color: white;
        transition: .4s;
        border-radius: 50%;
      }
      input:checked + .slider {
        background-color: #1976d2;
      }
      input:checked + .slider:before {
        transform: translateX(16px);
      }
      .section-title {
        padding: 16px;
        background-color: #f5f5f5;
        font-weight: 500;
        color: #555;
        margin: 0;
      }
    </style>
    <script>
      function showScreen(screenId) {
        // Tüm ekranları gizle
        const screens = document.querySelectorAll('.screen');
        screens.forEach(screen => screen.classList.remove('active'));
        
        // Tüm butonları pasif yap
        const buttons = document.querySelectorAll('.screen-button');
        buttons.forEach(button => button.classList.remove('active'));
        
        // Seçilen ekranı ve butonu aktif yap
        document.getElementById(screenId).classList.add('active');
        document.querySelector('.screen-button[data-screen="' + screenId + '"]').classList.add('active');
        
        // Alt navigasyondaki aktif öğeyi değiştir
        const navItems = document.querySelectorAll('.nav-item');
        navItems.forEach(item => item.classList.remove('active'));
        
        // Hangi navigasyon öğesini aktif yapacağımızı belirle
        let activeNav;
        if (screenId === 'notifications-screen') {
          activeNav = 'nav-notifications';
        } else if (screenId === 'settings-screen') {
          activeNav = 'nav-settings';
        } else {
          activeNav = 'nav-home';
        }
        
        document.getElementById(activeNav).classList.add('active');
      }
    </script>
  </head>
  <body>
    <div class="header">
      <h1>ŞikayetVar - Mobil Görünüm</h1>
    </div>
    
    <div class="container">
      <div class="view-options">
        <a href="/" class="btn secondary">Platform Bilgileri</a>
        <a href="/mobile" class="btn">Mobil Görünüm</a>
      </div>
      
      <div class="screen-selector">
        <button class="screen-button" data-screen="home-screen" onclick="showScreen('home-screen')">Ana Sayfa</button>
        <button class="screen-button active" data-screen="notifications-screen" onclick="showScreen('notifications-screen')">Bildirimler</button>
        <button class="screen-button" data-screen="settings-screen" onclick="showScreen('settings-screen')">Ayarlar</button>
      </div>
      
      <div class="device-wrapper">
        <div class="mobile-device">
          <div class="device-notch"></div>
          <div class="device-screen">
            <div class="mobile-header">
              <div>ŞikayetVar</div>
              <div style="font-size: 20px;">⚙️</div>
            </div>
            
            <div class="mobile-content">
              <!-- Ana Sayfa Ekranı - Gönderiler -->
              <div id="home-screen" class="screen">
                ${postsHtml}
              </div>
            
              <!-- Bildirimler Ekranı -->
              <div id="notifications-screen" class="screen active">
                <div class="notification-item unread">
                  <div class="notification-icon">👍</div>
                  <div class="notification-content">
                    <div class="notification-title">Gönderiniz beğenildi</div>
                    <div class="notification-text">Ayşe Yılmaz, "Çöp konteynerlerinin yetersizliği" başlıklı gönderinizi beğendi.</div>
                    <div class="notification-time">5 dakika önce</div>
                  </div>
                </div>
                
                <div class="notification-item unread">
                  <div class="notification-icon">💬</div>
                  <div class="notification-content">
                    <div class="notification-title">Yeni yorum</div>
                    <div class="notification-text">Mehmet Kaya, "Yol çalışması tamamlanmadı" başlıklı gönderinize yorum yaptı: "Aynı sorun bizim bölgede de var, 3 haftadır bekliyor!"</div>
                    <div class="notification-time">30 dakika önce</div>
                  </div>
                </div>
                
                <div class="notification-item">
                  <div class="notification-icon">🔄</div>
                  <div class="notification-content">
                    <div class="notification-title">Şikayet durumu güncellendi</div>
                    <div class="notification-text">"Otobüs saatleri düzensiz" başlıklı şikayetinizin durumu "İnceleniyor" olarak güncellendi.</div>
                    <div class="notification-time">2 saat önce</div>
                  </div>
                </div>
                
                <div class="notification-item">
                  <div class="notification-icon">📢</div>
                  <div class="notification-content">
                    <div class="notification-title">Yeni duyuru</div>
                    <div class="notification-text">Kadıköy Belediyesi: "Rıhtım Caddesi'ndeki yol çalışmaları 15 Nisan'da tamamlanacaktır. Anlayışınız için teşekkür ederiz."</div>
                    <div class="notification-time">5 saat önce</div>
                  </div>
                </div>
              </div>
              
              <!-- Bildirim Ayarları Ekranı -->
              <div id="settings-screen" class="screen">
                <div class="settings-item">
                  <div style="display: flex; align-items: center;">
                    <div class="settings-icon">🔔</div>
                    <div class="settings-content">
                      <div class="settings-title">Tüm Bildirimleri Aç/Kapat</div>
                      <div class="settings-description">Bu ayar kapalıyken hiçbir bildirim almayacaksınız</div>
                    </div>
                  </div>
                  <label class="switch">
                    <input type="checkbox" checked>
                    <span class="slider"></span>
                  </label>
                </div>
                
                <h3 class="section-title">Etkileşim Bildirimleri</h3>
                
                <div class="settings-item">
                  <div style="display: flex; align-items: center;">
                    <div class="settings-icon">👍</div>
                    <div class="settings-content">
                      <div class="settings-title">Beğeni Bildirimleri</div>
                      <div class="settings-description">Birileri gönderinizi beğendiğinde bildirim alın</div>
                    </div>
                  </div>
                  <label class="switch">
                    <input type="checkbox" checked>
                    <span class="slider"></span>
                  </label>
                </div>
                
                <div class="settings-item">
                  <div style="display: flex; align-items: center;">
                    <div class="settings-icon">💬</div>
                    <div class="settings-content">
                      <div class="settings-title">Yorum Bildirimleri</div>
                      <div class="settings-description">Gönderinize yorum yapıldığında bildirim alın</div>
                    </div>
                  </div>
                  <label class="switch">
                    <input type="checkbox" checked>
                    <span class="slider"></span>
                  </label>
                </div>
                
                <div class="settings-item">
                  <div style="display: flex; align-items: center;">
                    <div class="settings-icon">↩️</div>
                    <div class="settings-content">
                      <div class="settings-title">Yanıt Bildirimleri</div>
                      <div class="settings-description">Yorumunuza yanıt verildiğinde bildirim alın</div>
                    </div>
                  </div>
                  <label class="switch">
                    <input type="checkbox" checked>
                    <span class="slider"></span>
                  </label>
                </div>
                
                <h3 class="section-title">Sistem Bildirimleri</h3>
                
                <div class="settings-item">
                  <div style="display: flex; align-items: center;">
                    <div class="settings-icon">🔄</div>
                    <div class="settings-content">
                      <div class="settings-title">Durum Güncellemeleri</div>
                      <div class="settings-description">Şikayetinizin durumu değiştiğinde bildirim alın</div>
                    </div>
                  </div>
                  <label class="switch">
                    <input type="checkbox" checked>
                    <span class="slider"></span>
                  </label>
                </div>
                
                <div class="settings-item">
                  <div style="display: flex; align-items: center;">
                    <div class="settings-icon">📢</div>
                    <div class="settings-content">
                      <div class="settings-title">Duyurular</div>
                      <div class="settings-description">Önemli platform duyurularını alın</div>
                    </div>
                  </div>
                  <label class="switch">
                    <input type="checkbox" checked>
                    <span class="slider"></span>
                  </label>
                </div>
                
                <h3 class="section-title">Konum Tabanlı Bildirimler</h3>
                
                <div class="settings-item">
                  <div style="display: flex; align-items: center;">
                    <div class="settings-icon">📍</div>
                    <div class="settings-content">
                      <div class="settings-title">Yerel Bildirimleri</div>
                      <div class="settings-description">Yaşadığınız şehir veya ilçe ile ilgili bildirimleri alın</div>
                    </div>
                  </div>
                  <label class="switch">
                    <input type="checkbox" checked>
                    <span class="slider"></span>
                  </label>
                </div>
              </div>
            </div>
            
            <div class="mobile-bottom-nav">
              <div id="nav-home" class="nav-item">
                <div style="font-size: 18px;">🏠</div>
                <div>Ana Sayfa</div>
              </div>
              <div id="nav-map" class="nav-item">
                <div style="font-size: 18px;">🗺️</div>
                <div>Harita</div>
              </div>
              <div id="nav-add" class="nav-item">
                <div style="font-size: 18px;">➕</div>
                <div>Yeni Ekle</div>
              </div>
              <div id="nav-notifications" class="nav-item active">
                <div style="font-size: 18px;">🔔</div>
                <div>Bildirimler</div>
              </div>
              <div id="nav-settings" class="nav-item">
                <div style="font-size: 18px;">⚙️</div>
                <div>Ayarlar</div>
              </div>
            </div>
          </div>
          <div class="device-home"></div>
        </div>
      </div>
    </div>
  </body>
  </html>
  `);
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(colors.fg.cyan + `ŞikayetVar bilgi sayfası şu adreste çalışıyor: http://0.0.0.0:${PORT}` + colors.reset);
  console.log(colors.fg.cyan + `Mobil görünüm şu adreste çalışıyor: http://0.0.0.0:${PORT}/mobile` + colors.reset);
  console.log(colors.fg.cyan + `Admin Panel şu adreste çalışıyor: http://0.0.0.0:3001` + colors.reset);
  console.log(colors.fg.cyan + `API Proxy şu adreste çalışıyor: http://0.0.0.0:9000` + colors.reset);
});