class Constants {
  // API
  static const String apiBaseUrl = 'https://api.sikayetvar.example.com';
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  
  // Preferences
  static const String themeKey = 'app_theme';
  static const String notificationsKey = 'notifications_enabled';
  
  // Pagination
  static const int defaultPageSize = 10;
  
  // Content limits
  static const int maxTitleLength = 100;
  static const int maxContentLength = 1000;
  static const int maxImagesPerPost = 5;
  
  // Date formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  
  // Map
  static const double defaultZoom = 13.0;
  static const double defaultLatitude = 41.0082;  // Istanbul
  static const double defaultLongitude = 28.9784;
}