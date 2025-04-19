import 'package:shared_preferences/shared_preferences.dart';

class ApiKeyManager {
  static const String _apiKeyKey = 'api_key';
  
  // API anahtarını SharedPreferences'a kaydet
  static Future<bool> saveApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_apiKeyKey, apiKey);
  }
  
  // Kaydedilmiş API anahtarını getir
  static Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyKey);
  }
  
  // API anahtarını temizle
  static Future<bool> clearApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(_apiKeyKey);
  }
  
  // API anahtarının var olup olmadığını kontrol et
  static Future<bool> hasApiKey() async {
    final apiKey = await getApiKey();
    return apiKey != null && apiKey.isNotEmpty;
  }
}