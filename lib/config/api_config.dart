class ApiConfig {
  // Base URL for the Admin Panel API
  static const String baseUrl = 'http://localhost:3000';  // Admin panel URL

  // Default timeouts for API requests
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
}