class ApiConfig {
  // Base URL for API endpoints
  static const String baseUrl = 'http://localhost:3000';

  // Authentication endpoints
  static const String login = '/api/login';
  static const String register = '/api/register';
  static const String logout = '/api/logout';
  static const String currentUser = '/api/user';

  // City and district endpoints
  static const String cities = '/api/cities';
  static const String districts = '/api/districts';

  // Posts endpoints
  static const String posts = '/api/posts';
  static const String comments = '/api/comments';

  // Survey endpoints
  static const String surveys = '/api/surveys';

  // User endpoints
  static const String users = '/api/users';

  // Categories endpoints
  static const String categories = '/api/categories';
}