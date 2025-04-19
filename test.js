// Test API key
import fetch from 'node-fetch';

const run = async () => {
  const res = await fetch('http://localhost:3001/api.php?endpoint=cities', {
    headers: { 'X-API-KEY': '440bf0009c749943b440f7f5c6c2fd26' }
  });
  console.log(await res.text());
};
run().catch(err => console.error('Error:', err));
