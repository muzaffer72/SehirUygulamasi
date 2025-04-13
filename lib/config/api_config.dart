import '../utils/api_helper.dart';

class ApiConfig {
  // Base URL for API endpoints
  static String get baseUrl {
    // Web'de çalışırken gerçek adresi kullanıyoruz
    try {
      return ApiHelper.getApiBaseUrl();
    } catch (e) {
      // ApiHelper çalışmazsa varsayılan olarak bu adresi kullan (api yolsuz)
      return 'https://workspace.replit.app';
    }
  }

  // Authentication endpoints
  static const String login = '/login';
  static const String register = '/register';
  static const String logout = '/logout';
  static const String currentUser = '/user';

  // City and district endpoints
  static const String cities = '/cities';
  static const String districts = '/districts';

  // Posts endpoints
  static const String posts = '/posts';
  static const String comments = '/comments';

  // Survey endpoints
  static const String surveys = '/surveys';

  // User endpoints
  static const String users = '/users';

  // Categories endpoints
  static const String categories = '/categories';
}