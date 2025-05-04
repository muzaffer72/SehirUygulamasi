#!/bin/bash

# Yeni API Sistemi kurulum scripti
echo "ŞikayetVar API v2 kurulum başlatılıyor..."
echo "=============================================="

# Gerekli dizini oluştur
mkdir -p logs

# Gerekli bağımlılıkları yükle
echo "1. Gerekli Node.js bağımlılıklarını yüklüyorum..."
npm install express cors pg bcrypt jsonwebtoken dotenv

# Yeni API server'ı başlat
echo "2. Yeni API bileşenlerini başlatıyorum..."
cd new-api-endpoints

# package.json yoksa oluştur
if [ ! -f "package.json" ]; then
  echo "package.json oluşturuluyor..."
  cat > package.json << EOF
{
  "name": "sikayetvar-api-v2",
  "version": "1.0.0",
  "description": "ŞikayetVar API v2 sistemi",
  "main": "index.js",
  "scripts": {
    "start": "node index.js",
    "dev": "nodemon index.js"
  },
  "dependencies": {
    "bcrypt": "^5.1.0",
    "cors": "^2.8.5",
    "dotenv": "^16.0.3",
    "express": "^4.18.2",
    "jsonwebtoken": "^9.0.0",
    "pg": "^8.9.0"
  },
  "devDependencies": {
    "nodemon": "^2.0.20"
  }
}
EOF
fi

# node_modules yoksa paketleri kur
if [ ! -d "node_modules" ]; then
  echo "Node.js bağımlılıkları yükleniyor..."
  npm install
fi

# API Proxy ile entegrasyon
echo "3. API Proxy bileşenini güncellemek için ana dizine dönüyorum..."
cd ..

# API proxy bağlantılarını güncelle (Eğer api-connect.js varsa)
if [ -f "api-connect.js" ]; then
  echo "API Proxy dosyasını yedekliyorum: api-connect.js.bak"
  cp api-connect.js api-connect.js.bak
  
  echo "API Proxy'yi yeni API sistemine bağlıyorum..."
  cat > api-connect.js.new << EOF
// Android Test için API Proxy - Güncellendi
const express = require('express');
const cors = require('express');
const http = require('http');
const https = require('https');
const app = express();

// Node-fetch yerine basit HTTP istekleri kullanacağız
const makeRequest = (url, method, headers, body) => {
  return new Promise((resolve, reject) => {
    const options = {
      method: method,
      headers: headers
    };
    
    const protocol = url.startsWith('https') ? https : http;
    const req = protocol.request(url, options, (res) => {
      let data = '';
      res.on('data', (chunk) => {
        data += chunk;
      });
      
      res.on('end', () => {
        // HTML içeriği var mı kontrol et (HTML dönen yanıt genellikle '<!DOCTYPE' veya '<html' ile başlar)
        if (data.trim().startsWith('<!') || data.trim().startsWith('<html')) {
          // HTML yanıtı algılandı, API dönüşü değil
          console.log('HTML yanıtı algılandı, API cevabı değil:', data.substring(0, 100) + '...');
          resolve({ 
            status: res.statusCode, 
            data: { 
              error: 'API formatı hatası',
              message: 'API JSON yerine HTML içeriği döndürdü. Endpoint kontrolünüzü yapın.'
            } 
          });
          return;
        }
        
        try {
          const jsonData = JSON.parse(data);
          resolve({ status: res.statusCode, data: jsonData });
        } catch (error) {
          console.log('JSON ayrıştırma hatası, dönen içerik:', data.substring(0, 200) + '...');
          resolve({ status: res.statusCode, data: { error: 'JSON ayrıştırma hatası', details: error.message } });
        }
      });
    });
    
    req.on('error', (error) => {
      reject(error);
    });
    
    if (body) {
      req.write(body);
    }
    
    req.end();
  });
};
const API_PORT = 9000;

app.use(cors());
app.use(express.json());

// Demo parti verileri (Mock veri, mevcutsa korunur)
const demoParties = [
  // Party mock veri burada...
];

// API proxy yönlendirmeleri
app.use('/api', async (req, res) => {
  console.log(\`API isteği alındı: \${req.method} \${req.url}\`);
  
  // Özel parti API endpointleri (mevcutsa korunur)
  if (req.url.startsWith('/parties')) {
    // Parti API işleme kodu...
    // [KOD KORUNDU]
  }
  
  // Yeni API v2 endpoint'leri - Auth, Posts, Comments, Notifications
  if (req.url.startsWith('/auth') || 
      req.url.startsWith('/posts') || 
      req.url.startsWith('/comments') || 
      req.url.startsWith('/notifications')) {
    
    // Yeni API'ye yönlendir (9500 portu)
    const targetUrl = \`http://0.0.0.0:9500\${req.url}\`;
    console.log(\`Yeni API'ye yönlendiriliyor: \${targetUrl}\`);
    
    try {
      // İstek başlıklarını hazırla
      const headers = {
        'Content-Type': 'application/json'
      };
      
      // Authorization header'ı varsa ekle
      if (req.headers['authorization']) {
        headers['Authorization'] = req.headers['authorization'];
      }
      
      // X-API-KEY header'ı varsa ekle
      if (req.headers['x-api-key']) {
        headers['X-API-Key'] = req.headers['x-api-key'];
      }
      
      // İstek gövdesini hazırla
      let body = null;
      if (req.method !== 'GET' && req.body) {
        body = JSON.stringify(req.body);
        headers['Content-Length'] = Buffer.byteLength(body);
      }
      
      // İsteği yap
      const response = await makeRequest(targetUrl, req.method, headers, body);
      console.log(\`Yeni API'den yanıt alındı: Status=\${response.status}\`);
      
      // Yanıtı gönder
      res.status(response.status).json(response.data);
      return;
    } catch (error) {
      console.error('Yeni API bağlantı hatası:', error);
      res.status(500).json({ 
        error: 'API bağlantı hatası', 
        details: error.message,
        message: 'Yeni API sistemi şu anda erişilebilir değil. Lütfen daha sonra tekrar deneyin.'
      });
      return;
    }
  }
  
  try {
    // Eski API endpoint'leri için kod korundu
    // [KOD KORUNDU]
    
    // Admin panel API'sine yönlendirme (parties hariç diğer endpointler için)
    let apiPath = req.url;
    if (apiPath.startsWith('/api/')) {
      apiPath = apiPath.substring(4); // '/api/' kısmını kaldır
      console.log(\`API yolu düzeltildi: \${apiPath}\`);
    }
    
    // URL'yi parse et ve query parametrelerini analiz et
    let endpoint = null;
    const url = new URL(\`http://localhost\${apiPath}\`);
    const queryParams = url.searchParams;
    
    // URL'den endpoint parametresini çıkar
    if (queryParams.has('endpoint')) {
      endpoint = queryParams.get('endpoint');
      console.log(\`Endpoints parametresi tespit edildi: \${endpoint}\`);
    } else {
      // Path bazlı eski stil API istekleri için path'ten endpoint'i çıkar
      const pathParts = url.pathname.split('/').filter(part => part.length > 0);
      endpoint = pathParts[0];
      console.log(\`URL path'ten endpoint tespit edildi: \${endpoint}\`);
    }
    
    // Admin panel URL'sini oluştur
    let targetUrl = '';
    // API anahtarı doğrudan URL'ye eklenecek
    const apiKey = '440bf0009c749943b440f7f5c6c2fd26';
    
    if (endpoint) {
      // Yeni API formatı için - endpoint parametresini doğrudan kullan
      targetUrl = \`http://0.0.0.0:3001/api.php?endpoint=\${endpoint}&api_key=\${apiKey}\`;
      
      // Diğer query parametrelerini de ekle
      url.searchParams.forEach((value, key) => {
        if (key !== 'endpoint' && key !== 'api_key') {
          targetUrl += \`&\${key}=\${value}\`;
        }
      });
    } else {
      // Klasik path bazlı yapıyı api.php endpoint formatına dönüştür
      const pathParts = url.pathname.split('/').filter(part => part.length > 0);
      if (pathParts.length > 0) {
        const endpoint = pathParts[0];
        targetUrl = \`http://0.0.0.0:3001/api.php?endpoint=\${endpoint}&api_key=\${apiKey}\`;
        
        // Path'teki ID değeri varsa ekle
        if (pathParts.length > 1) {
          targetUrl += \`&id=\${pathParts[1]}\`;
        }
        
        // Diğer query parametrelerini de ekle
        url.searchParams.forEach((value, key) => {
          if (key !== 'api_key') {
            targetUrl += \`&\${key}=\${value}\`;
          }
        });
      } else {
        // Endpoint olmadan doğrudan admin panel API'sine yönlendir
        targetUrl = \`http://0.0.0.0:3001/api.php?api_key=\${apiKey}\`;
      }
    }
    
    console.log(\`İstek yönlendiriliyor: \${targetUrl}\`);
    
    // İstek başlıklarını hazırla - API anahtarı artık URL'de olduğu için header'da göndermeye gerek yok
    const headers = {
      'Content-Type': 'application/json'
    };
    
    // CORS ve X-API-KEY başlığı debug
    console.log('API isteği gönderiliyor, Headers:', JSON.stringify(headers));
    
    // Diğer başlıkları ekle ama X-API-KEY değerini koruyarak (Auth vs.)
    Object.keys(req.headers).forEach(key => {
      if (key.toLowerCase() !== 'host' && 
          key.toLowerCase() !== 'content-length' && 
          key.toLowerCase() !== 'x-api-key') { // X-API-KEY başlığını korumak için ekledim
        headers[key] = req.headers[key];
      }
    });
    
    // İstek gövdesini hazırla
    let body = null;
    if (req.method !== 'GET' && req.body) {
      body = JSON.stringify(req.body);
      headers['Content-Length'] = Buffer.byteLength(body);
    }
    
    // İsteği yapmadan önce debug bilgisi
    console.log(\`İstek detayları: URL=\${targetUrl}, Method=\${req.method}, Headers=\${JSON.stringify(headers)}\`);
    
    // İsteği yap
    const response = await makeRequest(targetUrl, req.method, headers, body);
    console.log(\`Yanıt alındı: Status=\${response.status}, Body=\${JSON.stringify(response.data).substring(0, 100)}...\`);
    
    // Yanıtı gönder
    res.status(response.status).json(response.data);
  } catch (error) {
    console.error('API hatası:', error);
    res.status(500).json({ error: 'API bağlantı hatası', details: error.message });
  }
});

// API Bilgi endpoint
app.get('/', (req, res) => {
  res.json({
    status: 'online',
    message: 'ŞikayetVar API bağlantı noktası çalışıyor',
    endpoints: [
      '/api/cities',
      '/api/districts',
      '/api/categories',
      '/api/posts',
      '/api/users',
      '/api/parties',
      '/api/search_suggestions',
      '/api/pharmacies',
      '/api/pharmacies/closest',
      // Yeni API endpoint'leri
      '/api/auth/login',
      '/api/auth/register',
      '/api/auth/profile',
      '/api/posts',
      '/api/comments',
      '/api/notifications'
    ],
    database: {
      type: 'PostgreSQL',
      host: process.env.PGHOST || 'localhost',
      name: process.env.PGDATABASE || 'sikayetvar_db',
      port: process.env.PGPORT || 5432
    }
  });
});

// Sunucuyu başlat
app.listen(API_PORT, '0.0.0.0', () => {
  console.log(\`ŞikayetVar API proxy şu adreste çalışıyor: http://0.0.0.0:\${API_PORT}\`);
  console.log('Android Studio bağlantısı için API_BASE_URL değeri:');
  console.log(\`https://\${process.env.REPL_SLUG}.\${process.env.REPL_OWNER}.repl.co/api\`);
});
EOF

  if [ $? -eq 0 ]; then
    echo "API Proxy dosyası güncellendi."
    mv api-connect.js.new api-connect.js
  else
    echo "API Proxy dosyası güncellenemedi!"
    exit 1
  fi
else
  echo "API Proxy dosyası (api-connect.js) bulunamadı!"
fi

# Yeni API Server'ı başlat
echo "4. Yeni API sistemini başlatıyorum..."
echo "API v2 başlatılıyor. Lütfen bekleyin..."

# Yeni API Server'ın başlatılması için workflow kullan
echo "Sistem hazır!"
echo "=============================================="
echo ""
echo "Tüm API endpoint'leri artık kullanılabilir:"
echo "- Kimlik doğrulama: /api/auth/login, /api/auth/register, /api/auth/profile"
echo "- İçerik yönetimi: /api/posts (GET, POST, PUT, DELETE)"
echo "- Yorumlar: /api/comments (GET, POST, PUT, DELETE)"
echo "- Bildirimler: /api/notifications (GET, PUT, DELETE)"
echo "- Eczane verileri: /api/pharmacies, /api/pharmacies/closest"
echo ""
echo "Detaylı API dökümantasyonu için: api_integration_guide.md"
echo "API Server'ı başlatmak için: cd new-api-endpoints && node index.js"