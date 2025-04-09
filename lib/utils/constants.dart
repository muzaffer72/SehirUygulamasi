class Constants {
  // App general information
  static const String appName = 'ŞikayetVar';
  static const String appVersion = '1.0.0';
  
  // API endpoints
  static const String apiBaseUrl = 'https://api.sikayetvar.example.com/v1';
  
  // Local storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'app_theme';
  static const String languageKey = 'app_language';
  
  // API timeout durations
  static const int apiTimeoutSeconds = 10;
  
  // Image upload limits
  static const int maxImageUploadSize = 5 * 1024 * 1024; // 5 MB
  static const int maxImagesPerPost = 5;
  
  // Text input limits
  static const int maxTitleLength = 100;
  static const int maxContentLength = 2000;
  static const int maxCommentLength = 500;
  
  // Pagination
  static const int defaultPageSize = 10;
  
  // Animation durations
  static const int shortAnimationDuration = 200; // ms
  static const int mediumAnimationDuration = 300; // ms
  static const int longAnimationDuration = 500; // ms
  
  // Theme constants
  static const double smallRadius = 4.0;
  static const double mediumRadius = 8.0;
  static const double largeRadius = 12.0;
  
  // Spacing constants
  static const double smallSpace = 8.0;
  static const double mediumSpace = 16.0;
  static const double largeSpace = 24.0;
  
  // Validation patterns
  static const String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  static const String phonePattern = r'^\+?[0-9]{10,15}$';
  
  // Supported languages
  static const List<String> supportedLanguages = ['tr', 'en'];
  
  // Cache durations
  static const int categoryCacheDuration = 24 * 60 * 60; // 24 hours in seconds
  static const int cityCacheDuration = 24 * 60 * 60; // 24 hours in seconds
}