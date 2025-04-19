const http = require('http');

const options = {
  hostname: 'localhost',
  port: 3001,
  path: '/api.php?endpoint=cities',
  method: 'GET',
  headers: {
    'X-API-KEY': '440bf0009c749943b440f7f5c6c2fd26',
    'Content-Type': 'application/json'
  }
};

const req = http.request(options, (res) => {
  console.log(`Status: ${res.statusCode}`);
  console.log('Headers:', JSON.stringify(res.headers, null, 2));
  
  let data = '';
  res.on('data', (chunk) => {
    data += chunk;
  });
  
  res.on('end', () => {
    console.log('Body:', data.substring(0, 200) + '...');
  });
});

req.on('error', (e) => {
  console.error(`Error: ${e.message}`);
});

req.end();
