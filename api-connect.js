// Android Test için API Proxy
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
        try {
          const jsonData = JSON.parse(data);
          resolve({ status: res.statusCode, data: jsonData });
        } catch (error) {
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

// API proxy yönlendirmeleri
app.use('/api', async (req, res) => {
  console.log(`API isteği alındı: ${req.method} ${req.url}`);
  try {
    // Admin panel API'sine yönlendirme
    const targetUrl = `http://0.0.0.0:3000${req.url}`;
    console.log(`İstek yönlendiriliyor: ${targetUrl}`);
    
    // İstek başlıklarını hazırla
    const headers = {
      'Content-Type': 'application/json'
    };
    
    // Diğer başlıkları ekle (Auth vs.)
    Object.keys(req.headers).forEach(key => {
      if (key.toLowerCase() !== 'host' && key.toLowerCase() !== 'content-length') {
        headers[key] = req.headers[key];
      }
    });
    
    // İstek gövdesini hazırla
    let body = null;
    if (req.method !== 'GET' && req.body) {
      body = JSON.stringify(req.body);
      headers['Content-Length'] = Buffer.byteLength(body);
    }
    
    // İsteği yap
    const response = await makeRequest(targetUrl, req.method, headers, body);
    console.log(`Yanıt alındı: ${response.status}`);
    
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
      '/api/users'
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
  console.log(`ŞikayetVar API proxy şu adreste çalışıyor: http://0.0.0.0:${API_PORT}`);
  console.log('Android Studio bağlantısı için API_BASE_URL değeri:');
  console.log(`https://${process.env.REPL_SLUG}.${process.env.REPL_OWNER}.repl.co/api`);
});