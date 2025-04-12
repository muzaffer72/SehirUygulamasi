import 'dart:convert';
import 'dart:io' if (dart.library.html) 'package:sikayet_var/utils/web_stub.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sikayet_var/config/api_config.dart';
import 'package:sikayet_var/models/post.dart';
import 'package:sikayet_var/models/user.dart';
import 'package:sikayet_var/models/comment.dart';
import 'package:sikayet_var/models/survey.dart';
import 'package:sikayet_var/models/city.dart';
import 'package:sikayet_var/models/district.dart';
import 'package:sikayet_var/models/city_profile.dart';
import 'package:sikayet_var/models/category.dart' as app_category;

class ApiService {
  final String baseUrl = ApiConfig.baseUrl;
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
  Future<List<Post>> getPosts({String? categoryId, String? cityId, String? districtId, String? status, String? userId, PostType? type, int page = 1, int limit = 20}) async {
    String url = '$baseUrl/posts';
    
    // Add query parameters if available
    final queryParams = <String, String>{};
    if (categoryId != null) queryParams['category_id'] = categoryId;
    if (cityId != null) queryParams['city_id'] = cityId;
    if (districtId != null) queryParams['district_id'] = districtId;
    if (status != null) queryParams['status'] = status;
    if (userId != null) queryParams['user_id'] = userId;
    if (type != null) queryParams['type'] = type.toString().split('.').last;
    queryParams['page'] = page.toString();
    queryParams['limit'] = limit.toString();
    
    if (queryParams.isNotEmpty) {
      url += '?' + Uri(queryParameters: queryParams).query;
    }
    
    try {
      final response = await _client.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Admin paneli formatına uyumlu yanıt yapısı kontrol edilir
        if (data is Map<String, dynamic> && data.containsKey('posts')) {
          final List<dynamic> postsData = data['posts'];
          return postsData.map((item) => Post.fromJson(item)).toList();
        } 
        // Düz liste formatında yanıt
        else if (data is List) {
          return data.map((item) => Post.fromJson(item)).toList();
        } 
        // Boş ya da geçersiz veri
        else {
          print('Unexpected data format: $data');
          return [];
        }
      } else {
        print('Failed to load posts: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching posts: $e');
      return [];
    }
  }
  
  Future<Post?> getPostById(String id) async {
    try {
      final response = await _client.get(Uri.parse('$baseUrl/posts/$id'));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Admin paneli API'si yanıt yapısı kontrol edilir
        if (data is Map<String, dynamic>) {
          // Admin panelinde post veya data altında veri olabilir
          if (data.containsKey('post')) {
            return Post.fromJson(data['post']);
          } else if (data.containsKey('data')) {
            return Post.fromJson(data['data']);
          } else {
            // Doğrudan post objesi
            return Post.fromJson(data);
          }
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        print('Failed to load post: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching post: $e');
      return null;
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
  
  Future<Post?> likePost(String id) async {
    try {
      final post = await getPostById(id);
      if (post == null) {
        print('Cannot like post: Post not found');
        return null;
      }
      
      // Admin panelde direk API endpointi var mı kontrol et
      try {
        final response = await _client.post(
          Uri.parse('$baseUrl/posts/$id/like'),
          headers: {'Content-Type': 'application/json'},
        );
        
        if (response.statusCode == 200) {
          return getPostById(id);
        }
      } catch (e) {
        // API endpointi yoksa manuel olarak beğeni sayısını artır
      }
      
      final likes = post.likes + 1;
      return updatePost(id, {'likes': likes});
    } catch (e) {
      print('Error liking post: $e');
      return null;
    }
  }
  
  Future<Post?> highlightPost(String id) async {
    try {
      final post = await getPostById(id);
      if (post == null) {
        print('Cannot highlight post: Post not found');
        return null;
      }
      
      // Admin panelde direk API endpointi var mı kontrol et
      try {
        final response = await _client.post(
          Uri.parse('$baseUrl/posts/$id/highlight'),
          headers: {'Content-Type': 'application/json'},
        );
        
        if (response.statusCode == 200) {
          return getPostById(id);
        }
      } catch (e) {
        // API endpointi yoksa manuel olarak öne çıkarma sayısını artır  
      }
      
      final highlights = post.highlights + 1;
      return updatePost(id, {'highlights': highlights});
    } catch (e) {
      print('Error highlighting post: $e');
      return null;
    }
  }
  
  // Comments
  Future<List<Comment>> getCommentsByPostId(String postId) async {
    try {
      print('Fetching comments for post ID: $postId');
      
      // Admin paneli API bağlantısı
      final response = await _client.get(
        Uri.parse('$baseUrl/api/comments?post_id=$postId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      print('Comments response status: ${response.statusCode}');
      print('Comments response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        
        // Admin paneli yanıt formatları kontrolü
        if (data is Map<String, dynamic>) {
          List<dynamic> commentsData;
          
          // Laravel formatı: {success: true, comments: [...]}
          if (data.containsKey('success') && data['success'] == true && data.containsKey('comments')) {
            commentsData = data['comments'];
          }
          // Laravel formatı: {data: [...]}
          else if (data.containsKey('data')) {
            commentsData = data['data'];
          }
          // Laravel formatı: {comments: [...]}
          else if (data.containsKey('comments')) {
            commentsData = data['comments'];
          }
          // Düz obje listesi
          else if (data.containsKey('results')) {
            commentsData = data['results'];
          }
          else {
            print('Unexpected comment data format. Using empty list.');
            return [];
          }
          
          // Yorumları parent_id'ye göre düzenle 
          final List<Comment> comments = commentsData.map((item) => Comment.fromJson(item)).toList();
          
          // Hiyerarşik yorum listesi oluştur
          print('Parsed ${comments.length} comments');
          return comments;
        } 
        else if (data is List) {
          // Düz liste formatında yanıt
          final List<Comment> comments = data.map((item) => Comment.fromJson(item)).toList();
          print('Parsed ${comments.length} comments from list');
          return comments;
        }
        else {
          print('Invalid comment data format');
          return [];
        }
      } else {
        print('Failed to load comments: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching comments: $e');
      // Hata durumunda boş liste döndürüyoruz
      return [];
    }
  }
  
  Future<Comment> addComment(String postId, String content, {bool isAnonymous = false, String? parentId}) async {
    // Get user ID from token
    final token = await _getToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }
    
    // Kullanıcı bilgisini al - Laravel admin paneli tarafında kullanılacak
    final user = await getCurrentUser();
    final userId = user?.id ?? "1"; 
    
    print('Adding comment to post ID: $postId, isAnonymous: $isAnonymous');
    
    final Map<String, dynamic> requestBody = {
      'post_id': postId,
      'user_id': userId,
      'content': content,
      'is_anonymous': isAnonymous ? 1 : 0, // Laravel'de boolean 1/0 olarak bekleniyor
    };
    
    // Eğer bir yoruma yanıt ise parent_id değerini ekle
    if (parentId != null && parentId.isNotEmpty) {
      requestBody['parent_id'] = parentId;
      print('This is a reply to comment ID: $parentId');
    }
    
    try {
      print('Sending comment request body: $requestBody');
      
      // Admin paneli API bağlantısı
      final response = await _client.post(
        Uri.parse('$baseUrl/api/comments'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': token.startsWith('Bearer ') ? token : 'Bearer $token',
          'Cookie': token,
        },
        body: jsonEncode(requestBody),
      );
      
      print('Add comment response status: ${response.statusCode}');
      print('Add comment response body: ${response.body}');
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        
        Comment comment;
        if (data is Map<String, dynamic>) {
          // Laravel formatı: {success: true, comment: {...}}
          if (data.containsKey('success') && data['success'] == true && data.containsKey('comment')) {
            comment = Comment.fromJson(data['comment']);
          }
          // Laravel formatı: {data: {...}}
          else if (data.containsKey('data')) {
            comment = Comment.fromJson(data['data']);
          }
          // Düz obje
          else {
            comment = Comment.fromJson(data);
          }
          
          print('Successfully added comment ID: ${comment.id}');
          return comment;
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to add comment: ${response.body}');
      }
    } catch (e) {
      print('Error adding comment: $e');
      
      // API bağlantısı olmadığında veya başarısız olduğunda
      // Admin panel tarafına elle yorum ekleriz
      try {
        print('Trying alternative comment endpoint as fallback');
        final response = await _client.post(
          Uri.parse('$baseUrl/comments'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestBody),
        );
        
        if (response.statusCode == 201 || response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return Comment.fromJson(data);
        }
      } catch (fallbackError) {
        print('Fallback comment endpoint also failed: $fallbackError');
      }
      
      // Son çare: Geçici bir yorum nesnesi döndür (sadece UI gösterimi için)
      print('Creating temporary comment object for UI');
      return Comment(
        id: "temp_${DateTime.now().millisecondsSinceEpoch}",
        postId: postId,
        userId: userId,
        content: content,
        likeCount: 0,
        isAnonymous: isAnonymous,
        createdAt: DateTime.now(),
        parentId: parentId,
      );
    }
  }
  
  // Bu fonksiyon kaldırıldı çünkü aşağıda zaten bir getCityById (String) fonksiyonu var
  
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
    
    try {
      // Token'ı kullanarak mevcut kullanıcıyı al
      final response = await _client.get(
        Uri.parse('$baseUrl/user'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data is Map<String, dynamic>) {
          return User.fromJson(data);
        } else {
          throw Exception('Invalid user data format');
        }
      } else if (response.statusCode == 401) {
        // Token geçersiz, null döndür ve uygulamada oturum açma sayfasına yönlendir
        return null;
      } else {
        throw Exception('Failed to get current user: ${response.body}');
      }
    } catch (e) {
      print('Error getting current user: $e');
      // Hata durumunda yine null döndür
      return null;
    }
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
  
  // Şehir profil bilgilerini getir
  Future<CityProfile> getCityProfile(int cityId) async {
    // cityId'yi string'e çeviriyoruz
    final response = await _client.get(Uri.parse('$baseUrl/cities/${cityId.toString()}/profile'));
    
    if (response.statusCode == 200) {
      return CityProfile.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load city profile: ${response.body}');
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