// API yapılandırması için kullanılacak bilgiler
// Bu dosyayı doğrudan kullanmayın, sadece bilgi amaçlıdır

// lib/config/api_config.dart dosyasında aşağıdaki değişiklikleri yapın:

/*
class ApiConfig {
  // API temel URL'i - Replit üzerindeki API'ye bağlanmak için
  static const String baseUrl = 'https://workspace.guzelimbatmanli.repl.co/api';
  
  // Alternatif URL - Yerel geliştirme için
  static const String localUrl = 'http://10.0.2.2:9000/api';
  
  // Kullanıcı doğrulama ve profil endpoint'leri
  static const String login = '/login';
  static const String register = '/register';
  static const String profile = '/profile';
  
  // İçerik endpoint'leri
  static const String posts = '/posts';
  static const String comments = '/comments';
  static const String categories = '/categories';
  static const String cities = '/cities';
  static const String districts = '/districts';
  
  // Anket endpoint'leri
  static const String surveys = '/surveys';
  static const String surveyVote = '/survey-vote';
  
  // Web/Mobil platformunu kontrol et ve doğru URL'i döndür
  static String getBaseUrl() {
    // Burada platforma göre doğru URL'i döndürün
    // Web için - Aynı host üzerindeki API
    // Mobil için - Replit URL veya yerel URL
    return baseUrl;
  }
}
*/

// Ayrıca, API istekleri için lib/services/api_service.dart dosyasında 
// header'ları güncellemeyi unutmayın:

/*
Map<String, String> headers = {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'X-Client-Type': 'flutter-mobile'  // API'de istemci tipini tanımlamak için
};
*/