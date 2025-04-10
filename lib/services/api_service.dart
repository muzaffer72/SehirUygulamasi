import 'dart:convert';
import 'dart:io' if (dart.library.html) 'package:sikayet_var/utils/web_stub.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sikayet_var/models/post.dart';
import 'package:sikayet_var/models/user.dart';
import 'package:sikayet_var/models/comment.dart';
import 'package:sikayet_var/models/survey.dart';
import 'package:sikayet_var/models/city.dart';
import 'package:sikayet_var/models/district.dart';
import 'package:sikayet_var/models/category.dart' as app_category;

class ApiService {
  static const String baseUrl = 'https://sehir.muzaffersanli.com/api.php';
  static const String apiToken = 'api_token';
  
  // HTTP client
  final http.Client _client = http.Client();
  
  // Get auth token from shared preferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(apiToken);
  }
  
  // Authentication
  Future<User> login(String email, String password) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/login'),
      body: {
        'email': email,
        'password': password,
      },
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      // Save token to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(apiToken, data['token']);
      
      return User.fromJson(data['user']);
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }
  
  Future<User> register(String name, String email, String password, {String? cityId, String? districtId}) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'city_id': cityId,
        'district_id': districtId,
      }),
    );
    
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return User.fromJson(data);
    } else {
      throw Exception('Failed to register: ${response.body}');
    }
  }
  
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(apiToken);
  }
  
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(apiToken);
  }
  
  // Posts
  Future<List<Post>> getPosts({String? categoryId, String? cityId, String? districtId, String? status, String? userId, PostType? type}) async {
    String url = '$baseUrl/posts';
    
    // Add query parameters if available
    final queryParams = <String, String>{};
    if (categoryId != null) queryParams['category_id'] = categoryId;
    if (cityId != null) queryParams['city_id'] = cityId;
    if (districtId != null) queryParams['district_id'] = districtId;
    if (status != null) queryParams['status'] = status;
    if (userId != null) queryParams['user_id'] = userId;
    if (type != null) queryParams['type'] = type.toString().split('.').last;
    
    if (queryParams.isNotEmpty) {
      url += '?' + Uri(queryParameters: queryParams).query;
    }
    
    final response = await _client.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Post.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load posts: ${response.body}');
    }
  }
  
  Future<Post> getPostById(String id) async {
    final response = await _client.get(Uri.parse('$baseUrl/posts/$id'));
    
    if (response.statusCode == 200) {
      return Post.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load post: ${response.body}');
    }
  }
  
  Future<Post> createPost(String title, String content, PostType type, {String? categoryId, String? cityId, String? districtId, List<File>? images, bool isAnonymous = false}) async {
    // Get user ID from token
    final token = await _getToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }
    
    // In a real app, this would be extracted from the token or provided by the API
    const userId = "1";
    final response = await _client.post(
      Uri.parse('$baseUrl/posts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'content': content,
        'user_id': userId,
        'category_id': categoryId,
        'city_id': cityId,
        'district_id': districtId,
        'type': type.toString().split('.').last,
        'is_anonymous': isAnonymous,
      }),
    );
    
    if (response.statusCode == 201) {
      return Post.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create post: ${response.body}');
    }
  }
  
  Future<Post> updatePost(String id, Map<String, dynamic> data) async {
    final response = await _client.put(
      Uri.parse('$baseUrl/posts/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    
    if (response.statusCode == 200) {
      return Post.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update post: ${response.body}');
    }
  }
  
  Future<void> deletePost(String id) async {
    final response = await _client.delete(Uri.parse('$baseUrl/posts/$id'));
    
    if (response.statusCode != 200) {
      throw Exception('Failed to delete post: ${response.body}');
    }
  }
  
  Future<Post> likePost(String id) async {
    final post = await getPostById(id);
    final likes = post.likes + 1;
    
    return updatePost(id, {'likes': likes});
  }
  
  Future<Post> highlightPost(String id) async {
    final post = await getPostById(id);
    final highlights = post.highlights + 1;
    
    return updatePost(id, {'highlights': highlights});
  }
  
  // Comments
  Future<List<Comment>> getCommentsByPostId(String postId) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));
    
    return [
      Comment(
        id: '1',
        postId: postId,
        userId: '2',
        content: 'Bu sorun bizim mahallemizde de var.',
        likeCount: 3,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Comment(
        id: '2',
        postId: postId,
        userId: '3',
        content: 'Geçen hafta şikayet ettim ama hala düzeltilmedi.',
        likeCount: 1,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }
  
  Future<Comment> addComment(String postId, String content, {bool isAnonymous = false}) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Get user ID from token
    final token = await _getToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }
    
    // In a real app, this would be extracted from the token or provided by the API
    const userId = "1"; 
    
    return Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      postId: postId,
      userId: userId,
      content: content,
      likeCount: 0,
      isAnonymous: isAnonymous,
      createdAt: DateTime.now(),
    );
  }
  
  // Surveys
  Future<List<Survey>> getSurveys() async {
    final response = await _client.get(Uri.parse('$baseUrl/surveys'));
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Survey.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load surveys: ${response.body}');
    }
  }
  
  Future<List<Survey>> getActiveSurveys() async {
    final response = await _client.get(Uri.parse('$baseUrl/surveys?active=true'));
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Survey.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load active surveys: ${response.body}');
    }
  }
  
  // Belirli bir türdeki anketleri getir (şehir/ilçe/genel)
  Future<List<Survey>> getActiveSurveysByType(String type) async {
    final response = await _client.get(Uri.parse('$baseUrl/surveys?active=true&type=$type'));
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Survey.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load active surveys by type: ${response.body}');
    }
  }
  
  Future<Survey> getSurveyById(String id) async {
    final response = await _client.get(Uri.parse('$baseUrl/surveys/$id'));
    
    if (response.statusCode == 200) {
      return Survey.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load survey: ${response.body}');
    }
  }
  
  // Vote on a survey option
  Future<bool> voteOnSurvey(String surveyId, String optionId) async {
    final token = await _getToken();
    
    if (token == null) {
      throw Exception('User not authenticated');
    }
    
    final response = await _client.post(
      Uri.parse('$baseUrl/surveys/$surveyId/vote'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'option_id': optionId,
      }),
    );
    
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to vote on survey: ${response.body}');
    }
  }
  
  Future<Survey> voteInSurvey(String surveyId, String optionId) async {
    // In a real app, this would make an API call
    // For now, just get the survey and simulate voting
    final survey = await getSurveyById(surveyId);
    
    // Find the option and increment its vote count
    for (var i = 0; i < survey.options.length; i++) {
      if (survey.options[i].id == optionId) {
        survey.options[i].voteCount++;
        survey.totalVotes++;
        break;
      }
    }
    
    return survey;
  }
  
  // Get current user using stored token
  Future<User?> getCurrentUser() async {
    final token = await _getToken();
    
    if (token == null) {
      return null;
    }
    
    // In a real app, this would validate the token with the server
    // For now, we'll return a mock user
    return User(
      id: '1',
      name: 'Demo Kullanıcı',
      email: 'demo@example.com',
      isVerified: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    );
  }
  
  // Users
  Future<List<User>> getUsers() async {
    final response = await _client.get(Uri.parse('$baseUrl/users'));
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => User.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load users: ${response.body}');
    }
  }
  
  Future<User> getUserById(String id) async {
    final response = await _client.get(Uri.parse('$baseUrl/users/$id'));
    
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load user: ${response.body}');
    }
  }
  
  Future<User> updateUser(String id, Map<String, dynamic> data) async {
    final response = await _client.put(
      Uri.parse('$baseUrl/users/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update user: ${response.body}');
    }
  }
  
  // Cities
  Future<List<City>> getCities() async {
    final response = await _client.get(Uri.parse('$baseUrl/cities'));
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => City.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load cities: ${response.body}');
    }
  }
  
  Future<City> getCityById(String id) async {
    final response = await _client.get(Uri.parse('$baseUrl/cities/$id'));
    
    if (response.statusCode == 200) {
      return City.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load city: ${response.body}');
    }
  }
  
  // Districts
  Future<List<District>> getDistricts() async {
    final response = await _client.get(Uri.parse('$baseUrl/districts'));
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => District.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load districts: ${response.body}');
    }
  }
  
  Future<List<District>> getDistrictsByCityId(String cityId) async {
    final response = await _client.get(Uri.parse('$baseUrl/districts?city_id=$cityId'));
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => District.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load districts: ${response.body}');
    }
  }
  
  Future<District> getDistrictById(String id) async {
    final response = await _client.get(Uri.parse('$baseUrl/districts/$id'));
    
    if (response.statusCode == 200) {
      return District.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load district: ${response.body}');
    }
  }
  
  // Categories
  Future<List<app_category.Category>> getCategories() async {
    final response = await _client.get(Uri.parse('$baseUrl/categories'));
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => app_category.Category.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load categories: ${response.body}');
    }
  }
  
  Future<app_category.Category> getCategoryById(String id) async {
    final response = await _client.get(Uri.parse('$baseUrl/categories/$id'));
    
    if (response.statusCode == 200) {
      return app_category.Category.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load category: ${response.body}');
    }
  }
  
  // User profile updates
  Future<User> updateUserProfile(
    String userId, 
    {String? name, 
    String? email, 
    String? profileImageUrl}
  ) async {
    final token = await _getToken();
    
    if (token == null) {
      throw Exception('User not authenticated');
    }
    
    // Create request body with only the fields that are provided
    final Map<String, dynamic> requestBody = {};
    if (name != null) requestBody['name'] = name;
    if (email != null) requestBody['email'] = email;
    if (profileImageUrl != null) requestBody['profile_image_url'] = profileImageUrl;
    
    final response = await _client.put(
      Uri.parse('$baseUrl/users/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestBody),
    );
    
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update user profile: ${response.body}');
    }
  }
  
  // User location updates
  Future<User> updateUserLocation(
    String userId,
    {String? cityId,
    String? districtId}
  ) async {
    final token = await _getToken();
    
    if (token == null) {
      throw Exception('User not authenticated');
    }
    
    // Create request body with only the fields that are provided
    final Map<String, dynamic> requestBody = {};
    if (cityId != null) requestBody['city_id'] = cityId;
    if (districtId != null) requestBody['district_id'] = districtId;
    
    final response = await _client.put(
      Uri.parse('$baseUrl/users/$userId/location'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestBody),
    );
    
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update user location: ${response.body}');
    }
  }
  
  // Banned words management
  Future<List<String>> getBannedWords() async {
    final response = await _client.get(Uri.parse('$baseUrl/banned-words'));
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map<String>((item) => item.toString()).toList();
    } else {
      throw Exception('Failed to load banned words: ${response.body}');
    }
  }
}