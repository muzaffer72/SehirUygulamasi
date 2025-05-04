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

// Gönderi detay sayfası - yorumlar ve beğeniler ile
app.get('/post/:id', async (req, res) => {
  const postId = req.params.id;
  let postData = null;
  let comments = [];
  let error = null;

  try {
    // Gönderi detaylarını çek
    const postResponse = await fetchApiData(`posts/${postId}`);
    postData = postResponse.data || postResponse;
    
    // Yorumları çek
    try {
      const commentsResponse = await fetchApiData(`comments/post/${postId}`);
      comments = commentsResponse.data?.comments || commentsResponse.comments || commentsResponse || [];
    } catch (error) {
      console.error('Yorumları çekerken hata:', error);
    }
  } catch (error) {
    console.error('Gönderi detaylarını çekerken hata:', error);
    error = error.message;
  }

  // Hata durumunda
  if (error || !postData) {
    res.send(`
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Gönderi Bulunamadı - ŞikayetVar</title>
      <style>
        body {
          font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
          margin: 0;
          padding: 0;
          background-color: #f8f9fa;
        }
        .error-container {
          padding: 2rem;
          text-align: center;
          max-width: 500px;
          margin: 3rem auto;
          background-color: white;
          border-radius: 8px;
          box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .error-icon {
          font-size: 4rem;
          margin-bottom: 1rem;
        }
        h1 {
          color: #e53935;
          margin-bottom: 1rem;
        }
        p {
          color: #555;
          margin-bottom: 2rem;
        }
        .btn {
          display: inline-block;
          background-color: #1976d2;
          color: white;
          padding: 0.8rem 1.5rem;
          text-decoration: none;
          border-radius: 4px;
          font-weight: 500;
        }
      </style>
    </head>
    <body>
      <div class="error-container">
        <div class="error-icon">📝</div>
        <h1>Gönderi Bulunamadı</h1>
        <p>${error || 'Aradığınız gönderi bulunamadı.'}</p>
        <a href="/mobile" class="btn">Ana Sayfaya Dön</a>
      </div>
    </body>
    </html>
    `);
    return;
  }

  // Gönderi bilgilerini hazırla
  const title = postData.title || 'Başlıksız Gönderi';
  const content = postData.content || '';
  const createdAt = formatDate(postData.created_at);
  const username = postData.username || 'İsimsiz';
  const displayName = postData.user_name || username;
  const profileImageUrl = postData.profile_image_url || `https://ui-avatars.com/api/?name=${encodeURIComponent(displayName)}&background=random`;
  const cityName = postData.city_name || 'Bilinmeyen Şehir';
  const districtName = postData.district_name || '';
  const locationText = districtName ? `${cityName}, ${districtName}` : cityName;
  const likes = postData.like_count || 0;
  const commentCount = comments.length;
  const status = postData.status || 'awaitingSolution';
  const categoryName = postData.category_name || 'Genel';
  
  // Medya dosyalarını hazırla
  let mediaHtml = '';
  if (postData.media && postData.media.length > 0) {
    mediaHtml = postData.media.map(media => {
      if (media.type === 'image' || media.url.match(/\\.(jpg|jpeg|png|gif)$/i)) {
        return `<div class="post-image-container">
          <img src="${media.url}" class="post-image" alt="Gönderi resmi" onclick="openImageModal(this.src)">
        </div>`;
      } else {
        return `<div class="post-file">
          <a href="${media.url}" target="_blank" class="file-link">
            <i class="file-icon">📁</i>
            <span>Ek Dosya</span>
          </a>
        </div>`;
      }
    }).join('');
  }
  
  // Yorumları HTML'e dönüştür
  let commentsHtml = '';
  if (comments.length > 0) {
    commentsHtml = comments.map(comment => {
      const commentUsername = comment.username || 'İsimsiz';
      const commentDisplayName = comment.user_name || commentUsername;
      const commentProfileImageUrl = comment.profile_image_url || `https://ui-avatars.com/api/?name=${encodeURIComponent(commentDisplayName)}&background=random`;
      const commentDate = formatDate(comment.created_at);
      const isEdited = comment.is_edited ? '<span class="edited-label">(düzenlendi)</span>' : '';
      
      // Alt yorumlar varsa onları ekle
      let repliesHtml = '';
      if (comment.replies && comment.replies.length > 0) {
        repliesHtml = comment.replies.map(reply => {
          const replyUsername = reply.username || 'İsimsiz';
          const replyDisplayName = reply.user_name || replyUsername;
          const replyProfileImageUrl = reply.profile_image_url || `https://ui-avatars.com/api/?name=${encodeURIComponent(replyDisplayName)}&background=random`;
          const replyDate = formatDate(reply.created_at);
          const replyIsEdited = reply.is_edited ? '<span class="edited-label">(düzenlendi)</span>' : '';
          
          return `
          <div class="comment reply">
            <div class="comment-avatar">
              <img src="${replyProfileImageUrl}" alt="${replyDisplayName}" onerror="this.src='https://ui-avatars.com/api/?name=${encodeURIComponent(replyDisplayName)}&background=random'">
            </div>
            <div class="comment-content">
              <div class="comment-header">
                <div class="comment-author">${replyDisplayName}</div>
                <div class="comment-date">${replyDate} ${replyIsEdited}</div>
              </div>
              <div class="comment-text">${reply.content}</div>
            </div>
          </div>
          `;
        }).join('');
        
        repliesHtml = `<div class="replies">${repliesHtml}</div>`;
      }
      
      return `
      <div class="comment">
        <div class="comment-avatar">
          <img src="${commentProfileImageUrl}" alt="${commentDisplayName}" onerror="this.src='https://ui-avatars.com/api/?name=${encodeURIComponent(commentDisplayName)}&background=random'">
        </div>
        <div class="comment-content">
          <div class="comment-header">
            <div class="comment-author">${commentDisplayName}</div>
            <div class="comment-date">${commentDate} ${isEdited}</div>
          </div>
          <div class="comment-text">${comment.content}</div>
          <div class="comment-actions">
            <button class="comment-reply-btn" onclick="toggleReplyForm('${comment.id}')">Yanıtla</button>
          </div>
          <div id="reply-form-${comment.id}" class="reply-form" style="display: none;">
            <textarea placeholder="Yanıtınızı yazın..." rows="3"></textarea>
            <button class="reply-submit" onclick="submitReply('${comment.id}', this.previousElementSibling.value)">Gönder</button>
          </div>
          ${repliesHtml}
        </div>
      </div>
      `;
    }).join('');
  } else {
    commentsHtml = `
    <div class="empty-state">
      <div class="empty-icon">💬</div>
      <h3>Henüz Yorum Yok</h3>
      <p>Bu gönderiye henüz yorum yapılmamış. İlk yorumu siz yapabilirsiniz.</p>
    </div>
    `;
  }

  // Gönderi detay sayfası HTML'i
  res.send(`
  <!DOCTYPE html>
  <html>
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${title} - ŞikayetVar</title>
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
        padding: 1rem;
        position: relative;
      }
      .back-button {
        position: absolute;
        left: 1rem;
        top: 1rem;
        background: none;
        border: none;
        color: white;
        font-size: 1.5rem;
        cursor: pointer;
      }
      .page-title {
        text-align: center;
        margin: 0;
        font-size: 1.2rem;
      }
      .container {
        padding: 1rem;
      }
      .post-card {
        background-color: white;
        border-radius: 8px;
        margin-bottom: 1rem;
        box-shadow: 0 2px 5px rgba(0,0,0,0.05);
        overflow: hidden;
      }
      .post-header {
        display: flex;
        align-items: center;
        padding: 1rem;
        border-bottom: 1px solid #eee;
      }
      .post-avatar {
        width: 48px;
        height: 48px;
        border-radius: 50%;
        overflow: hidden;
        margin-right: 1rem;
      }
      .post-avatar img {
        width: 100%;
        height: 100%;
        object-fit: cover;
      }
      .post-info {
        flex: 1;
      }
      .post-author {
        font-weight: 500;
        font-size: 1.1rem;
      }
      .post-date {
        color: #777;
        font-size: 0.8rem;
      }
      .post-location {
        display: flex;
        align-items: center;
        color: #1976d2;
        font-size: 0.9rem;
        margin-top: 0.3rem;
      }
      .location-icon {
        margin-right: 0.3rem;
      }
      .post-content {
        padding: 1rem;
      }
      .post-title {
        margin-top: 0;
        margin-bottom: 0.8rem;
        font-size: 1.3rem;
      }
      .post-text {
        margin-bottom: 1rem;
        white-space: pre-line;
      }
      .post-image-container {
        margin: 1rem 0;
        border-radius: 8px;
        overflow: hidden;
      }
      .post-image {
        width: 100%;
        max-height: 400px;
        object-fit: contain;
        cursor: pointer;
      }
      .post-footer {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 0.8rem 1rem;
        border-top: 1px solid #eee;
        background-color: #f9f9f9;
      }
      .post-category {
        display: inline-flex;
        align-items: center;
        padding: 0.4rem 0.8rem;
        background-color: #e3f2fd;
        border-radius: 4px;
        font-size: 0.9rem;
        color: #1976d2;
      }
      .category-icon {
        margin-right: 0.3rem;
      }
      .post-status {
        display: inline-flex;
        align-items: center;
        padding: 0.4rem 0.8rem;
        border-radius: 4px;
        font-size: 0.9rem;
      }
      .post-status.awaitingSolution {
        background-color: #fff8e1;
        color: #ff8f00;
      }
      .post-status.inProgress {
        background-color: #e1f5fe;
        color: #0288d1;
      }
      .post-status.solved {
        background-color: #e8f5e9;
        color: #388e3c;
      }
      .post-status.rejected {
        background-color: #ffebee;
        color: #d32f2f;
      }
      .post-actions {
        display: flex;
        justify-content: space-around;
        padding: 0.8rem 0;
        border-top: 1px solid #eee;
      }
      .action-button {
        display: flex;
        flex-direction: column;
        align-items: center;
        padding: 0.5rem;
        background: none;
        border: none;
        cursor: pointer;
        color: #757575;
        transition: color 0.2s;
        font-size: 1.2rem;
      }
      .action-button.active {
        color: #1976d2;
      }
      .action-button.like:active {
        animation: pulse 0.3s;
      }
      .action-count {
        font-size: 0.8rem;
        margin-top: 0.2rem;
      }
      .section-title {
        margin: 1.5rem 0 1rem;
        padding-bottom: 0.5rem;
        border-bottom: 1px solid #eee;
        font-size: 1.2rem;
      }
      .comments-container {
        margin-top: 1rem;
      }
      .comment {
        display: flex;
        margin-bottom: 1.5rem;
      }
      .comment.reply {
        margin-left: 2.5rem;
        margin-bottom: 1rem;
        margin-top: 1rem;
        padding-left: 1rem;
        border-left: 2px solid #e0e0e0;
      }
      .comment-avatar {
        width: 40px;
        height: 40px;
        border-radius: 50%;
        overflow: hidden;
        margin-right: 0.8rem;
        flex-shrink: 0;
      }
      .comment-avatar img {
        width: 100%;
        height: 100%;
        object-fit: cover;
      }
      .comment-content {
        flex: 1;
      }
      .comment-header {
        display: flex;
        justify-content: space-between;
        margin-bottom: 0.3rem;
      }
      .comment-author {
        font-weight: 500;
      }
      .comment-date {
        font-size: 0.8rem;
        color: #777;
      }
      .edited-label {
        font-size: 0.8rem;
        color: #777;
        font-style: italic;
      }
      .comment-text {
        background-color: #f5f5f5;
        padding: 0.8rem;
        border-radius: 8px;
        margin-bottom: 0.5rem;
      }
      .comment-actions {
        display: flex;
        justify-content: flex-end;
      }
      .comment-reply-btn {
        background: none;
        border: none;
        color: #1976d2;
        cursor: pointer;
        font-size: 0.9rem;
        padding: 0.3rem 0.5rem;
      }
      .reply-form {
        margin-top: 0.8rem;
        margin-bottom: 1rem;
      }
      .reply-form textarea {
        width: 100%;
        padding: 0.8rem;
        border: 1px solid #ddd;
        border-radius: 4px;
        resize: none;
        margin-bottom: 0.5rem;
        font-family: inherit;
      }
      .reply-submit {
        background-color: #1976d2;
        color: white;
        border: none;
        padding: 0.5rem 1rem;
        border-radius: 4px;
        cursor: pointer;
        float: right;
      }
      .add-comment {
        background-color: white;
        border-radius: 8px;
        padding: 1rem;
        box-shadow: 0 2px 5px rgba(0,0,0,0.05);
        margin-bottom: 1.5rem;
      }
      .add-comment textarea {
        width: 100%;
        padding: 0.8rem;
        border: 1px solid #ddd;
        border-radius: 4px;
        resize: none;
        margin-bottom: 0.8rem;
        font-family: inherit;
      }
      .add-comment button {
        background-color: #1976d2;
        color: white;
        border: none;
        padding: 0.8rem 1.5rem;
        border-radius: 4px;
        cursor: pointer;
        font-weight: 500;
        float: right;
      }
      .empty-state {
        text-align: center;
        padding: 2rem;
        background-color: white;
        border-radius: 8px;
        box-shadow: 0 2px 5px rgba(0,0,0,0.05);
      }
      .empty-icon {
        font-size: 3rem;
        margin-bottom: 1rem;
        color: #bdbdbd;
      }
      .modal {
        display: none;
        position: fixed;
        z-index: 100;
        left: 0;
        top: 0;
        width: 100%;
        height: 100%;
        background-color: rgba(0,0,0,0.9);
      }
      .modal-content {
        display: block;
        max-width: 90%;
        max-height: 90%;
        margin: auto;
        position: absolute;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
      }
      .close-modal {
        position: absolute;
        top: 15px;
        right: 15px;
        color: white;
        font-size: 30px;
        font-weight: bold;
        cursor: pointer;
      }
      @keyframes pulse {
        0% { transform: scale(1); }
        50% { transform: scale(1.2); }
        100% { transform: scale(1); }
      }
    </style>
  </head>
  <body>
    <div class="header">
      <button class="back-button" onclick="window.history.back()">←</button>
      <h1 class="page-title">Gönderi Detayı</h1>
    </div>
    
    <div class="container">
      <div class="post-card">
        <div class="post-header">
          <div class="post-avatar">
            <img src="${profileImageUrl}" alt="${displayName}" onerror="this.src='https://ui-avatars.com/api/?name=${encodeURIComponent(displayName)}&background=random'">
          </div>
          <div class="post-info">
            <div class="post-author">${displayName}</div>
            <div class="post-date">${createdAt}</div>
            <div class="post-location" onclick="window.location.href='/city/${postData.city_id}'">
              <i class="location-icon">📍</i>
              <span>${locationText}</span>
            </div>
          </div>
        </div>
        
        <div class="post-content">
          <h2 class="post-title">${title}</h2>
          <p class="post-text">${content}</p>
          ${mediaHtml}
        </div>
        
        <div class="post-footer">
          <div class="post-category">
            <i class="category-icon">📋</i>
            <span>${categoryName}</span>
          </div>
          <div class="post-status ${status}">
            <i class="status-icon">${getStatusIcon(status)}</i>
            <span>${getStatusText(status)}</span>
          </div>
        </div>
        
        <div class="post-actions">
          <button class="action-button like" id="like-button" onclick="toggleLike()">
            <span id="like-icon">👍</span>
            <span class="action-count" id="like-count">${likes}</span>
          </button>
          <button class="action-button">
            <span>💬</span>
            <span class="action-count">${commentCount}</span>
          </button>
          <button class="action-button" onclick="sharePost()">
            <span>🔗</span>
            <span class="action-count">Paylaş</span>
          </button>
        </div>
      </div>
      
      <div class="add-comment">
        <textarea id="comment-input" placeholder="Yorumunuzu yazın..." rows="3"></textarea>
        <button onclick="submitComment()">Yorum Ekle</button>
        <div style="clear: both;"></div>
      </div>
      
      <h2 class="section-title">Yorumlar (${commentCount})</h2>
      
      <div class="comments-container">
        ${commentsHtml}
      </div>
    </div>
    
    <!-- Resim İnceleme Modalı -->
    <div id="image-modal" class="modal">
      <span class="close-modal" onclick="closeImageModal()">&times;</span>
      <img class="modal-content" id="modal-image">
    </div>
    
    <script>
      // Beğeni durumunu yönet
      let isLiked = false;
      
      function toggleLike() {
        const likeButton = document.getElementById('like-button');
        const likeIcon = document.getElementById('like-icon');
        const likeCount = document.getElementById('like-count');
        const currentLikes = parseInt(likeCount.innerText);
        
        isLiked = !isLiked;
        
        if (isLiked) {
          likeButton.classList.add('active');
          likeCount.innerText = currentLikes + 1;
          // API isteği gönder - beğen
          sendLikeRequest(true);
        } else {
          likeButton.classList.remove('active');
          likeCount.innerText = Math.max(0, currentLikes - 1);
          // API isteği gönder - beğeniyi kaldır
          sendLikeRequest(false);
        }
      }
      
      function sendLikeRequest(isLike) {
        // API'ye beğeni durumunu gönder
        fetch('/api/posts/${postId}/like', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'X-API-Key': '440bf0009c749943b440f7f5c6c2fd26'
          }
        })
        .then(response => response.json())
        .then(data => {
          console.log('Beğeni işlemi başarılı:', data);
        })
        .catch(error => {
          console.error('Beğeni işlemi hatası:', error);
          // Hata durumunda beğeni durumunu geri al
          isLiked = !isLiked;
          toggleLike();
        });
      }
      
      // Yorum ekleme
      function submitComment() {
        const commentText = document.getElementById('comment-input').value.trim();
        
        if (!commentText) {
          alert('Lütfen bir yorum yazın.');
          return;
        }
        
        // API'ye yorum gönder
        fetch('/api/comments', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'X-API-Key': '440bf0009c749943b440f7f5c6c2fd26'
          },
          body: JSON.stringify({
            post_id: ${postId},
            content: commentText
          })
        })
        .then(response => response.json())
        .then(data => {
          console.log('Yorum eklendi:', data);
          // Sayfayı yenile (en güncel yorumları görmek için)
          location.reload();
        })
        .catch(error => {
          console.error('Yorum ekleme hatası:', error);
          alert('Yorum eklenirken bir hata oluştu. Lütfen daha sonra tekrar deneyin.');
        });
      }
      
      // Yanıt formunu göster/gizle
      function toggleReplyForm(commentId) {
        const replyForm = document.getElementById('reply-form-' + commentId);
        replyForm.style.display = replyForm.style.display === 'none' ? 'block' : 'none';
      }
      
      // Yoruma yanıt ekle
      function submitReply(commentId, content) {
        if (!content.trim()) {
          alert('Lütfen bir yanıt yazın.');
          return;
        }
        
        // API'ye yanıt gönder
        fetch('/api/comments', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'X-API-Key': '440bf0009c749943b440f7f5c6c2fd26'
          },
          body: JSON.stringify({
            post_id: ${postId},
            parent_comment_id: commentId,
            content: content
          })
        })
        .then(response => response.json())
        .then(data => {
          console.log('Yanıt eklendi:', data);
          // Sayfayı yenile
          location.reload();
        })
        .catch(error => {
          console.error('Yanıt ekleme hatası:', error);
          alert('Yanıt eklenirken bir hata oluştu. Lütfen daha sonra tekrar deneyin.');
        });
      }
      
      // Paylaşım fonksiyonu
      function sharePost() {
        if (navigator.share) {
          navigator.share({
            title: '${title.replace(/'/g, "\\'")}',
            text: '${content.substring(0, 100).replace(/'/g, "\\'")}...',
            url: window.location.href
          })
          .then(() => console.log('Paylaşım başarılı'))
          .catch((error) => console.error('Paylaşım hatası:', error));
        } else {
          // Paylaşım API'si yoksa URL'i panoya kopyala
          navigator.clipboard.writeText(window.location.href)
            .then(() => alert('Gönderi bağlantısı panoya kopyalandı'))
            .catch(err => console.error('Kopyalama hatası:', err));
        }
      }
      
      // Resim modalı
      function openImageModal(src) {
        const modal = document.getElementById('image-modal');
        const modalImg = document.getElementById('modal-image');
        modal.style.display = 'block';
        modalImg.src = src;
        document.body.style.overflow = 'hidden'; // Scroll'u engelle
      }
      
      function closeImageModal() {
        document.getElementById('image-modal').style.display = 'none';
        document.body.style.overflow = 'auto'; // Scroll'u geri getir
      }
    </script>
  </body>
  </html>
  `);
});

// Şehir/Belediye profil sayfası - sekmeli tasarım
app.get('/city/:id', async (req, res) => {
  const cityId = req.params.id;
  let cityData = null;
  let cityPosts = [];
  let cityProjects = [];
  let cityEvents = [];
  let cityError = null;

  try {
    // Şehir bilgilerini çek
    const cityResponse = await fetchApiData(`cities/${cityId}`);
    cityData = Array.isArray(cityResponse) ? cityResponse[0] : cityResponse;
    
    // Şehre ait gönderileri çek
    try {
      const postsResponse = await fetchApiData(`posts?city_id=${cityId}`);
      cityPosts = Array.isArray(postsResponse) ? postsResponse : (postsResponse.posts || postsResponse.data?.posts || []);
    } catch (error) {
      console.error('Şehir gönderilerini çekerken hata:', error);
    }
    
    // Şehir projelerini çek
    try {
      const projectsResponse = await fetchApiData(`city_projects?city_id=${cityId}`);
      cityProjects = Array.isArray(projectsResponse) ? projectsResponse : (projectsResponse.projects || projectsResponse.data?.projects || []);
    } catch (error) {
      console.error('Şehir projelerini çekerken hata:', error);
    }
    
    // Şehir etkinliklerini çek
    try {
      const eventsResponse = await fetchApiData(`city_events?city_id=${cityId}`);
      cityEvents = Array.isArray(eventsResponse) ? eventsResponse : (eventsResponse.events || eventsResponse.data?.events || []);
    } catch (error) {
      console.error('Şehir etkinliklerini çekerken hata:', error);
    }
  } catch (error) {
    console.error('Şehir bilgilerini çekerken hata:', error);
    cityError = error.message;
  }

  // Şehir adını ve verileri belirle
  const cityName = cityData?.name || 'Bilinmeyen Şehir';
  const districtCount = cityData?.district_count || 0;
  const population = cityData?.population || 'Bilinmiyor';
  const mayorName = cityData?.mayor_name || 'Bilinmiyor';
  const postCount = cityPosts.length;
  const projectCount = cityProjects.length;
  const eventCount = cityEvents.length;
  
  // Şehir gönderilerini HTML'e dönüştür
  let postsHtml = '';
  if (cityPosts.length > 0) {
    postsHtml = cityPosts.map(post => {
      const username = post.username || 'İsimsiz';
      const displayName = post.user_name || username;
      const profileImageUrl = post.profile_image_url || `https://ui-avatars.com/api/?name=${encodeURIComponent(displayName)}&background=random`;
      const postDate = formatDate(post.created_at);
      
      return `
      <div class="post-card" onclick="window.location.href='/post/${post.id}'">
        <div class="post-header">
          <div class="post-avatar">
            <img src="${profileImageUrl}" alt="${displayName}" onerror="this.src='https://ui-avatars.com/api/?name=${encodeURIComponent(displayName)}&background=random'">
          </div>
          <div class="post-info">
            <div class="post-author">${displayName}</div>
            <div class="post-date">${postDate}</div>
          </div>
        </div>
        <div class="post-content">
          <h3 class="post-title">${post.title}</h3>
          <p class="post-text">${post.content.substring(0, 150)}${post.content.length > 150 ? '...' : ''}</p>
        </div>
        <div class="post-actions">
          <div class="post-action">
            <i class="action-icon">👍</i>
            <span>${post.like_count || 0}</span>
          </div>
          <div class="post-action">
            <i class="action-icon">💬</i>
            <span>${post.comment_count || 0}</span>
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
      <h3>Henüz Şikayet Yok</h3>
      <p>Bu şehir için henüz bir şikayet paylaşılmamış. İlk şikayeti siz paylaşabilirsiniz.</p>
    </div>
    `;
  }
  
  // Şehir projelerini HTML'e dönüştür
  let projectsHtml = '';
  if (cityProjects.length > 0) {
    projectsHtml = cityProjects.map(project => {
      const progress = project.progress || 0;
      const startDate = formatDate(project.start_date);
      const endDate = formatDate(project.end_date);
      
      return `
      <div class="project-card">
        <h3 class="project-title">${project.title}</h3>
        <p class="project-description">${project.description}</p>
        <div class="project-dates">
          <span>Başlangıç: ${startDate}</span>
          <span>Bitiş: ${endDate}</span>
        </div>
        <div class="project-progress-container">
          <div class="project-progress-bar">
            <div class="project-progress-fill" style="width: ${progress}%"></div>
          </div>
          <span class="project-progress-text">%${progress}</span>
        </div>
        <div class="project-budget">
          <i class="budget-icon">💰</i>
          <span>Bütçe: ${project.budget || 'Belirtilmemiş'}</span>
        </div>
      </div>
      `;
    }).join('');
  } else {
    projectsHtml = `
    <div class="empty-state">
      <div class="empty-icon">🏗️</div>
      <h3>Henüz Proje Yok</h3>
      <p>Bu şehir için henüz bir proje paylaşılmamış.</p>
    </div>
    `;
  }
  
  // Şehir etkinliklerini HTML'e dönüştür
  let eventsHtml = '';
  if (cityEvents.length > 0) {
    eventsHtml = cityEvents.map(event => {
      const eventDate = formatDate(event.event_date);
      return `
      <div class="event-card">
        <div class="event-date">${eventDate}</div>
        <h3 class="event-title">${event.title}</h3>
        <p class="event-description">${event.description}</p>
        <div class="event-location">
          <i class="location-icon">📍</i>
          <span>${event.location}</span>
        </div>
      </div>
      `;
    }).join('');
  } else {
    eventsHtml = `
    <div class="empty-state">
      <div class="empty-icon">📅</div>
      <h3>Henüz Etkinlik Yok</h3>
      <p>Bu şehir için henüz bir etkinlik paylaşılmamış.</p>
    </div>
    `;
  }
  
  // Hata durumunda
  if (cityError) {
    res.send(`
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Şehir Bulunamadı - ŞikayetVar</title>
      <style>
        body {
          font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
          margin: 0;
          padding: 0;
          background-color: #f8f9fa;
        }
        .error-container {
          padding: 2rem;
          text-align: center;
          max-width: 500px;
          margin: 3rem auto;
          background-color: white;
          border-radius: 8px;
          box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .error-icon {
          font-size: 4rem;
          margin-bottom: 1rem;
        }
        h1 {
          color: #e53935;
          margin-bottom: 1rem;
        }
        p {
          color: #555;
          margin-bottom: 2rem;
        }
        .btn {
          display: inline-block;
          background-color: #1976d2;
          color: white;
          padding: 0.8rem 1.5rem;
          text-decoration: none;
          border-radius: 4px;
          font-weight: 500;
        }
      </style>
    </head>
    <body>
      <div class="error-container">
        <div class="error-icon">🏙️</div>
        <h1>Şehir Bulunamadı</h1>
        <p>${cityError}</p>
        <a href="/mobile" class="btn">Ana Sayfaya Dön</a>
      </div>
    </body>
    </html>
    `);
    return;
  }
  
  // Sekmeli şehir görünümü HTML'i
  res.send(`
  <!DOCTYPE html>
  <html>
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${cityName} - ŞikayetVar</title>
    <style>
      body {
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        line-height: 1.6;
        margin: 0;
        padding: 0;
        background-color: #f8f9fa;
        color: #333;
      }
      .city-header {
        background-color: #1976d2;
        color: white;
        padding: 1rem;
        position: relative;
      }
      .back-button {
        position: absolute;
        left: 1rem;
        top: 1rem;
        background: none;
        border: none;
        color: white;
        font-size: 1.5rem;
        cursor: pointer;
      }
      .city-title {
        text-align: center;
        margin: 0;
        padding: 0.5rem 0;
      }
      .city-stats {
        display: flex;
        justify-content: space-around;
        padding: 0.5rem;
        background-color: rgba(0,0,0,0.1);
        font-size: 0.9rem;
      }
      .city-stat {
        display: flex;
        flex-direction: column;
        align-items: center;
      }
      .stat-value {
        font-weight: bold;
      }
      .tabs {
        display: flex;
        background-color: white;
        border-bottom: 1px solid #ddd;
        position: sticky;
        top: 0;
        z-index: 10;
      }
      .tab {
        flex: 1;
        text-align: center;
        padding: 1rem 0.5rem;
        cursor: pointer;
        font-weight: 500;
        transition: all 0.3s;
      }
      .tab.active {
        color: #1976d2;
        border-bottom: 3px solid #1976d2;
      }
      .tab-content {
        display: none;
        padding: 1rem;
      }
      .tab-content.active {
        display: block;
      }
      .post-card, .project-card, .event-card {
        background-color: white;
        border-radius: 8px;
        padding: 1rem;
        margin-bottom: 1rem;
        box-shadow: 0 2px 5px rgba(0,0,0,0.05);
      }
      .post-header {
        display: flex;
        align-items: center;
        margin-bottom: 0.8rem;
      }
      .post-avatar {
        width: 40px;
        height: 40px;
        border-radius: 50%;
        overflow: hidden;
        margin-right: 0.8rem;
      }
      .post-avatar img {
        width: 100%;
        height: 100%;
        object-fit: cover;
      }
      .post-info {
        flex: 1;
      }
      .post-author {
        font-weight: 500;
      }
      .post-date {
        font-size: 0.8rem;
        color: #777;
      }
      .post-title {
        margin: 0.5rem 0;
        font-size: 1.1rem;
      }
      .post-text {
        margin-bottom: 1rem;
        color: #444;
      }
      .post-actions {
        display: flex;
        justify-content: space-between;
        border-top: 1px solid #eee;
        padding-top: 0.8rem;
      }
      .post-action {
        display: flex;
        align-items: center;
        color: #777;
        font-size: 0.9rem;
      }
      .action-icon {
        margin-right: 0.3rem;
      }
      .empty-state {
        text-align: center;
        padding: 2rem;
        color: #777;
      }
      .empty-icon {
        font-size: 3rem;
        margin-bottom: 1rem;
      }
      .project-dates {
        display: flex;
        justify-content: space-between;
        font-size: 0.8rem;
        color: #777;
        margin-bottom: 0.8rem;
      }
      .project-progress-container {
        display: flex;
        align-items: center;
        margin-bottom: 0.8rem;
      }
      .project-progress-bar {
        flex: 1;
        height: 8px;
        background-color: #eee;
        border-radius: 4px;
        overflow: hidden;
        margin-right: 0.8rem;
      }
      .project-progress-fill {
        height: 100%;
        background-color: #4caf50;
      }
      .project-budget {
        font-size: 0.9rem;
        color: #555;
      }
      .event-date {
        display: inline-block;
        background-color: #1976d2;
        color: white;
        padding: 0.3rem 0.8rem;
        border-radius: 4px;
        font-size: 0.8rem;
        margin-bottom: 0.5rem;
      }
      .event-location {
        display: flex;
        align-items: center;
        font-size: 0.9rem;
        color: #555;
        margin-top: 0.5rem;
      }
      .mayor-info {
        display: flex;
        align-items: center;
        padding: 1rem;
        background-color: white;
        border-radius: 8px;
        margin-bottom: 1rem;
        box-shadow: 0 2px 5px rgba(0,0,0,0.05);
      }
      .mayor-avatar {
        width: 60px;
        height: 60px;
        border-radius: 50%;
        overflow: hidden;
        margin-right: 1rem;
      }
      .mayor-avatar img {
        width: 100%;
        height: 100%;
        object-fit: cover;
      }
      .mayor-details {
        flex: 1;
      }
      .mayor-name {
        font-weight: 500;
        font-size: 1.1rem;
        margin-bottom: 0.3rem;
      }
      .mayor-party {
        color: #1976d2;
        font-size: 0.9rem;
      }
      .mayor-contact {
        margin-top: 0.5rem;
        font-size: 0.8rem;
        color: #555;
      }
      .status-indicator {
        padding: 0.3rem 0.6rem;
        border-radius: 4px;
        background-color: #f5f5f5;
      }
      .status-awaitingSolution {
        background-color: #fff8e1;
        color: #ff8f00;
      }
      .status-inProgress {
        background-color: #e1f5fe;
        color: #0288d1;
      }
      .status-solved {
        background-color: #e8f5e9;
        color: #388e3c;
      }
      .status-rejected {
        background-color: #ffebee;
        color: #d32f2f;
      }
    </style>
  </head>
  <body>
    <div class="city-header">
      <button class="back-button" onclick="window.history.back()">←</button>
      <h1 class="city-title">${cityName}</h1>
      <div class="city-stats">
        <div class="city-stat">
          <span>İlçe Sayısı</span>
          <span class="stat-value">${districtCount}</span>
        </div>
        <div class="city-stat">
          <span>Nüfus</span>
          <span class="stat-value">${population}</span>
        </div>
        <div class="city-stat">
          <span>Gönderi</span>
          <span class="stat-value">${postCount}</span>
        </div>
      </div>
    </div>
    
    <div class="tabs">
      <div class="tab active" onclick="switchTab('general')">Genel</div>
      <div class="tab" onclick="switchTab('posts')">Gönderiler</div>
      <div class="tab" onclick="switchTab('projects')">Projeler</div>
      <div class="tab" onclick="switchTab('events')">Etkinlikler</div>
    </div>
    
    <div id="general" class="tab-content active">
      <div class="mayor-info">
        <div class="mayor-avatar">
          <img src="https://ui-avatars.com/api/?name=${encodeURIComponent(mayorName)}&background=random" alt="${mayorName}">
        </div>
        <div class="mayor-details">
          <div class="mayor-name">${mayorName}</div>
          <div class="mayor-party">${cityData?.mayor_party || 'Belirtilmemiş'}</div>
          <div class="mayor-contact">
            <div>E-posta: ${cityData?.mayor_email || 'Belirtilmemiş'}</div>
            <div>Telefon: ${cityData?.mayor_phone || 'Belirtilmemiş'}</div>
          </div>
        </div>
      </div>
      
      <div class="section">
        <h2>Şehir Hakkında</h2>
        <p>${cityData?.description || 'Bu şehir hakkında henüz bir açıklama eklenmemiş.'}</p>
      </div>
      
      <div class="section">
        <h2>Son Gönderiler</h2>
        ${cityPosts.slice(0, 3).map(post => {
          const username = post.username || 'İsimsiz';
          const displayName = post.user_name || username;
          const profileImageUrl = post.profile_image_url || `https://ui-avatars.com/api/?name=${encodeURIComponent(displayName)}&background=random`;
          const postDate = formatDate(post.created_at);
          
          return `
          <div class="post-card" onclick="window.location.href='/post/${post.id}'">
            <div class="post-header">
              <div class="post-avatar">
                <img src="${profileImageUrl}" alt="${displayName}">
              </div>
              <div class="post-info">
                <div class="post-author">${displayName}</div>
                <div class="post-date">${postDate}</div>
              </div>
            </div>
            <div class="post-content">
              <h3 class="post-title">${post.title}</h3>
              <p class="post-text">${post.content.substring(0, 100)}${post.content.length > 100 ? '...' : ''}</p>
            </div>
          </div>
          `;
        }).join('') || `
        <div class="empty-state">
          <div class="empty-icon">📮</div>
          <h3>Henüz Gönderi Yok</h3>
          <p>Bu şehir için henüz bir gönderi paylaşılmamış.</p>
        </div>
        `}
      </div>
    </div>
    
    <div id="posts" class="tab-content">
      ${postsHtml}
    </div>
    
    <div id="projects" class="tab-content">
      ${projectsHtml}
    </div>
    
    <div id="events" class="tab-content">
      ${eventsHtml}
    </div>
    
    <script>
      function switchTab(tabId) {
        // Tüm sekmeleri deaktif yap
        document.querySelectorAll('.tab').forEach(tab => {
          tab.classList.remove('active');
        });
        document.querySelectorAll('.tab-content').forEach(content => {
          content.classList.remove('active');
        });
        
        // Seçilen sekmeyi aktif yap
        document.querySelector('.tab:nth-child(' + (tabId === 'general' ? 1 : tabId === 'posts' ? 2 : tabId === 'projects' ? 3 : 4) + ')').classList.add('active');
        document.getElementById(tabId).classList.add('active');
      }
    </script>
  </body>
  </html>
  `);
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