import 'package:shared_preferences/shared_preferences.dart';

class ApiKeyManager {
  static const String _apiKeyKey = 'api_key';
  static const String _defaultApiKey = '440bf0009c749943b440f7f5c6c2fd26';
  
  // API anahtarını SharedPreferences'a kaydet
  static Future<bool> saveApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_apiKeyKey, apiKey);
  }
  
  // Kaydedilmiş API anahtarını getir, yoksa varsayılan API anahtarını döndür
  static Future<String> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyKey) ?? _defaultApiKey;
  }
  
  // API anahtarını temizle
  static Future<bool> clearApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(_apiKeyKey);
  }
  
  // API anahtarının varsayılan anahtardan farklı bir değere sahip olup olmadığını kontrol et
  static Future<bool> hasCustomApiKey() async {
    final apiKey = await getApiKey();
    return apiKey != _defaultApiKey && apiKey.isNotEmpty;
  }
  
  // API anahtarının var olup olmadığını kontrol et
  static Future<bool> hasApiKey() async {
    final apiKey = await getApiKey();
    return apiKey.isNotEmpty;
  }
  
  // Varsayılan API anahtarını getir
  static String getDefaultApiKey() {
    return _defaultApiKey;
  }
  
  // URL'ye API anahtarını ekle
  static Future<String> appendApiKeyToUrl(String url) async {
    final apiKey = await getApiKey();
    final separator = url.contains('?') ? '&' : '?';
    return '$url${separator}api_key=$apiKey';
  }
  
  // API anahtarını HTTP başlıklarına ekle (geriye uyumluluk için)
  static Future<Map<String, String>> getApiKeyHeader() async {
    final apiKey = await getApiKey();
    return {'X-API-KEY': apiKey};
  }
}