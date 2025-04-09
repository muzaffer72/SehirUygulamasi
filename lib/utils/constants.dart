import 'dart:io';

class Constants {
  // API Base URL
  static const String apiBaseUrl = 'https://api.sikayetvar.com/api';
  
  // Network timeout duration
  static const Duration networkTimeout = Duration(seconds: 10);
  
  // Shared Preferences keys
  static const String tokenKey = 'token';
  static const String userIdKey = 'user_id';
  static const String darkModeKey = 'dark_mode';
  
  // App info
  static const String appName = 'ŞikayetVar';
  static const String appVersion = '1.0.0';
  
  // Pagination defaults
  static const int defaultPageSize = 10;
  
  // Image upload limits
  static const int maxImageCount = 3;
  static const int maxImageSizeInMB = 5;
  
  // Device info
  static bool get isAndroid => Platform.isAndroid;
  static bool get isIOS => Platform.isIOS;
}