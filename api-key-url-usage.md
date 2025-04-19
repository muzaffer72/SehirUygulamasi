# API Anahtar Kullanımı (URL Parametresi ile)

Şikayet Var platformu API'sine erişmek için API anahtarı kullanımı iki farklı yöntemle mümkündür. Önerilen yöntem, API anahtarını URL parametresi olarak eklemektir.

## 1. URL Parametresi Olarak API Anahtarı (Önerilen)

API anahtarınızı URL parametresi olarak aşağıdaki şekilde ekleyebilirsiniz:

```
https://api-endpoint.com/api.php?endpoint=cities&api_key=YOUR_API_KEY
```

### Flutter Örneği

```dart
final String apiUrl = "${ApiHelper.getBaseUrl()}/cities?api_key=440bf0009c749943b440f7f5c6c2fd26";
final response = await http.get(Uri.parse(apiUrl));
```

### Javascript Örneği

```javascript
const apiUrl = `${API_BASE_URL}/cities?api_key=440bf0009c749943b440f7f5c6c2fd26`;
fetch(apiUrl)
  .then(response => response.json())
  .then(data => console.log(data));
```

## 2. Header Olarak API Anahtarı (Alternatif)

API anahtarınızı HTTP başlığı olarak da gönderebilirsiniz:

```
X-API-KEY: YOUR_API_KEY
```

### Flutter Örneği

```dart
final String apiUrl = "${ApiHelper.getBaseUrl()}/cities";
final response = await http.get(
  Uri.parse(apiUrl),
  headers: {'X-API-KEY': '440bf0009c749943b440f7f5c6c2fd26'},
);
```

### Javascript Örneği

```javascript
const apiUrl = `${API_BASE_URL}/cities`;
fetch(apiUrl, {
  headers: {
    'X-API-KEY': '440bf0009c749943b440f7f5c6c2fd26'
  }
})
  .then(response => response.json())
  .then(data => console.log(data));
```

## API Anahtarını Uygulamanızda Saklamak

API anahtarınızı uygulamanızda güvenli bir şekilde saklamak için önerilen yöntemler:

1. Flutter'da `SharedPreferences` kullanımı
2. Çevresel değişkenler (`env` dosyaları)
3. Güvenli depolama sistemleri (keychain, keystore vb.)

### ApiKeyManager Sınıfı

Flutter uygulamanız için önerilen ApiKeyManager örneği:

```dart
class ApiKeyManager {
  static const String _apiKeyKey = 'api_key';
  static const String defaultApiKey = '440bf0009c749943b440f7f5c6c2fd26';
  
  static Future<String> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyKey) ?? defaultApiKey;
  }
  
  static Future<void> setApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyKey, apiKey);
  }
  
  // API anahtarını URL parametresi olarak ekleyen yardımcı metod
  static Future<String> appendApiKeyToUrl(String url) async {
    final apiKey = await getApiKey();
    final separator = url.contains('?') ? '&' : '?';
    return '$url${separator}api_key=$apiKey';
  }
}
```

### Örnek Kullanım

```dart
// API URL'sine otomatik olarak API anahtarı ekleme
final String baseUrl = "${ApiHelper.getBaseUrl()}/cities";
final String urlWithApiKey = await ApiKeyManager.appendApiKeyToUrl(baseUrl);
final response = await http.get(Uri.parse(urlWithApiKey));
```

## Güvenlik Notları

- API anahtarınızı paylaşmayın ve açık kaynak kodlu projelerde açıkta bırakmayın
- Üretim uygulamalarında, API anahtarınızı bir backend proxy servisi üzerinden kullanmayı düşünün
- Dinamik API anahtarı yönetimi için bir yönetim sistemi oluşturmayı değerlendirin

Her iki yöntem de desteklenmektedir, ancak URL parametresi olarak API anahtarı kullanımı özellikle mobil uygulamalarda daha kolay entegrasyon sağlar.