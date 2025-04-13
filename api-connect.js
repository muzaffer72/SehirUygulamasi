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

// Demo parti verileri
const demoParties = [
  {
    id: 1,
    name: 'Adalet ve Kalkınma Partisi',
    short_name: 'AK Parti',
    color: '#FFA500',
    logo_url: 'assets/images/parties/akp.png',
    problem_solving_rate: 68.5,
    city_count: 45,
    district_count: 562,
    complaint_count: 12750,
    solved_count: 8734,
    last_updated: new Date().toISOString()
  },
  {
    id: 2,
    name: 'Cumhuriyet Halk Partisi',
    short_name: 'CHP',
    color: '#FF0000',
    logo_url: 'assets/images/parties/chp.png',
    problem_solving_rate: 71.2,
    city_count: 22,
    district_count: 234,
    complaint_count: 8540,
    solved_count: 6080,
    last_updated: new Date().toISOString()
  },
  {
    id: 3,
    name: 'Milliyetçi Hareket Partisi',
    short_name: 'MHP',
    color: '#FF4500',
    logo_url: 'assets/images/parties/mhp.png',
    problem_solving_rate: 57.8,
    city_count: 8,
    district_count: 102,
    complaint_count: 3240,
    solved_count: 1872,
    last_updated: new Date().toISOString()
  },
  {
    id: 4,
    name: 'İyi Parti',
    short_name: 'İYİ Parti',
    color: '#1E90FF',
    logo_url: 'assets/images/parties/iyi.png',
    problem_solving_rate: 63.4,
    city_count: 3,
    district_count: 25,
    complaint_count: 980,
    solved_count: 621,
    last_updated: new Date().toISOString()
  },
  {
    id: 5,
    name: 'Demokratik Sol Parti',
    short_name: 'DSP',
    color: '#FF69B4',
    logo_url: 'assets/images/parties/dsp.png',
    problem_solving_rate: 52.1,
    city_count: 1,
    district_count: 5,
    complaint_count: 320,
    solved_count: 167,
    last_updated: new Date().toISOString()
  },
  {
    id: 6,
    name: 'Yeniden Refah Partisi',
    short_name: 'YRP',
    color: '#006400',
    logo_url: 'assets/images/parties/yrp.png',
    problem_solving_rate: 44.3,
    city_count: 0,
    district_count: 3,
    complaint_count: 85,
    solved_count: 38,
    last_updated: new Date().toISOString()
  }
];

// API proxy yönlendirmeleri
app.use('/api', async (req, res) => {
  console.log(`API isteği alındı: ${req.method} ${req.url}`);
  
  // Özel parti API endpointleri
  if (req.url.startsWith('/parties')) {
    const partyId = req.url.split('/')[2];
    
    if (req.method === 'GET') {
      // Specific party request
      if (partyId && !isNaN(partyId)) {
        const party = demoParties.find(p => p.id === parseInt(partyId));
        if (party) {
          return res.json(party);
        } else {
          return res.status(404).json({ error: 'Parti bulunamadı' });
        }
      }
      
      // All parties request
      return res.json(demoParties);
    } 
    else if (req.method === 'POST' && req.url.includes('recalculate-stats')) {
      // Simulate recalculation with a slight change in values
      const updatedParties = demoParties.map(party => {
        const change = (Math.random() * 6) - 3; // -3 to +3
        let newRate = party.problem_solving_rate + change;
        newRate = Math.max(0, Math.min(100, newRate)); // Keep between 0-100
        return {
          ...party,
          problem_solving_rate: parseFloat(newRate.toFixed(1)),
          last_updated: new Date().toISOString()
        };
      });
      
      // Update demo data
      demoParties.splice(0, demoParties.length, ...updatedParties);
      
      return res.json({
        success: true,
        message: 'Parti performans istatistikleri yeniden hesaplandı',
        updated_at: new Date().toISOString(),
        parties: demoParties
      });
    }
  }
  
  try {
    // Admin panel API'sine yönlendirme (parties hariç diğer endpointler için)
    // API endpoint'in doğru olduğundan emin ol - eğer url /api ile başlıyorsa kaldır
    // çünkü zaten route içindeyiz ve admin panel tarafında /api prefix'i var
    let apiPath = req.url;
    if (apiPath.startsWith('/api/')) {
      apiPath = apiPath.substring(4); // '/api/' kısmını kaldır
      console.log(`API yolu düzeltildi: ${apiPath}`);
    }
    
    const targetUrl = `http://0.0.0.0:3001/api${apiPath}`;
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
      '/api/users',
      '/api/parties'
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