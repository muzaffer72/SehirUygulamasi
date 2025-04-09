import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:sikayet_var/models/category.dart';
import 'package:sikayet_var/models/city.dart';
import 'package:sikayet_var/models/comment.dart';
import 'package:sikayet_var/models/district.dart';
import 'package:sikayet_var/models/post.dart';
import 'package:sikayet_var/models/survey.dart';
import 'package:sikayet_var/models/user.dart';
import 'package:sikayet_var/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl = Constants.apiBaseUrl;
  final http.Client _client = http.Client();
  
  // Helper method to get authorization header
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(Constants.tokenKey);
    
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }
  
  // Error handling
  Exception _handleError(http.Response response) {
    switch (response.statusCode) {
      case 401:
        return Exception('Unauthorized');
      case 403:
        return Exception('Forbidden');
      case 404:
        return Exception('Not found');
      case 500:
        return Exception('Server error');
      default:
        return Exception('Unknown error: ${response.statusCode}');
    }
  }
  
  // GET: Get all posts
  Future<List<Post>> getPosts() async {
    try {
      final headers = await _getHeaders();
      final response = await _client.get(
        Uri.parse('$baseUrl/posts'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body)['data'];
        return jsonData.map((json) => Post.fromJson(json)).toList();
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      // For development/demo purposes
      if (e is SocketException || e is HttpException || e is TimeoutException) {
        await Future.delayed(const Duration(seconds: 1));
        return getMockPosts();
      }
      throw Exception('Failed to load posts: $e');
    }
  }
  
  // GET: Get post by ID
  Future<Post> getPostById(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await _client.get(
        Uri.parse('$baseUrl/posts/$id'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body)['data'];
        return Post.fromJson(jsonData);
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      // For development/demo purposes
      if (e is SocketException || e is HttpException || e is TimeoutException) {
        await Future.delayed(const Duration(seconds: 1));
        
        // Return a mock post based on the requested ID
        return getMockPosts().firstWhere(
          (post) => post.id == id,
          orElse: () => getMockPosts().first.copyWith(id: id),
        );
      }
      throw Exception('Failed to load post: $e');
    }
  }
  
  // POST: Create new post
  Future<Post> createPost(Post post) async {
    try {
      final headers = await _getHeaders();
      final response = await _client.post(
        Uri.parse('$baseUrl/posts'),
        headers: headers,
        body: json.encode(post.toJson()),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 201) {
        final jsonData = json.decode(response.body)['data'];
        return Post.fromJson(jsonData);
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      // For development/demo purposes
      if (e is SocketException || e is HttpException || e is TimeoutException) {
        await Future.delayed(const Duration(seconds: 1));
        
        // Return the post with a generated ID
        return post.copyWith(
          id: 'post_${DateTime.now().millisecondsSinceEpoch}',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
      throw Exception('Failed to create post: $e');
    }
  }
  
  // GET: Filter posts
  Future<List<Post>> filterPosts({
    String? cityId,
    String? districtId,
    String? categoryId,
    String? sortBy,
    PostType? type,
    PostStatus? status,
  }) async {
    try {
      final headers = await _getHeaders();
      
      // Build query parameters
      final queryParams = <String, String>{};
      if (cityId != null) queryParams['city_id'] = cityId;
      if (districtId != null) queryParams['district_id'] = districtId;
      if (categoryId != null) queryParams['category_id'] = categoryId;
      if (sortBy != null) queryParams['sort_by'] = sortBy;
      if (type != null) queryParams['type'] = type.toString().split('.').last;
      if (status != null) queryParams['status'] = status.toString().split('.').last;
      
      final uri = Uri.parse('$baseUrl/posts').replace(queryParameters: queryParams);
      final response = await _client.get(
        uri,
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body)['data'];
        return jsonData.map((json) => Post.fromJson(json)).toList();
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      // For development/demo purposes
      if (e is SocketException || e is HttpException || e is TimeoutException) {
        await Future.delayed(const Duration(seconds: 1));
        
        // Return filtered mock posts
        final allPosts = getMockPosts();
        return allPosts.where((post) {
          bool match = true;
          
          if (cityId != null) match = match && post.cityId == cityId;
          if (districtId != null) match = match && post.districtId == districtId;
          if (categoryId != null) match = match && post.categoryId == categoryId;
          if (type != null) match = match && post.type == type;
          if (status != null) match = match && post.status == status;
          
          return match;
        }).toList();
      }
      throw Exception('Failed to filter posts: $e');
    }
  }
  
  // POST: Like a post
  Future<void> likePost(String postId) async {
    try {
      final headers = await _getHeaders();
      final response = await _client.post(
        Uri.parse('$baseUrl/posts/$postId/like'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw _handleError(response);
      }
    } catch (e) {
      // For development/demo purposes
      if (e is SocketException || e is HttpException || e is TimeoutException) {
        await Future.delayed(const Duration(milliseconds: 500));
        return; // Simulate successful like
      }
      throw Exception('Failed to like post: $e');
    }
  }
  
  // POST: Highlight a post
  Future<void> highlightPost(String postId) async {
    try {
      final headers = await _getHeaders();
      final response = await _client.post(
        Uri.parse('$baseUrl/posts/$postId/highlight'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw _handleError(response);
      }
    } catch (e) {
      // For development/demo purposes
      if (e is SocketException || e is HttpException || e is TimeoutException) {
        await Future.delayed(const Duration(milliseconds: 500));
        return; // Simulate successful highlight
      }
      throw Exception('Failed to highlight post: $e');
    }
  }
  
  // PATCH: Update post status
  Future<void> updatePostStatus(String postId, PostStatus status) async {
    try {
      final headers = await _getHeaders();
      final response = await _client.patch(
        Uri.parse('$baseUrl/posts/$postId/status'),
        headers: headers,
        body: json.encode({
          'status': status.toString().split('.').last,
        }),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode != 200) {
        throw _handleError(response);
      }
    } catch (e) {
      // For development/demo purposes
      if (e is SocketException || e is HttpException || e is TimeoutException) {
        await Future.delayed(const Duration(milliseconds: 500));
        return; // Simulate successful status update
      }
      throw Exception('Failed to update post status: $e');
    }
  }
  
  // GET: Get comments for a post
  Future<List<Comment>> getCommentsByPostId(String postId) async {
    try {
      final headers = await _getHeaders();
      final response = await _client.get(
        Uri.parse('$baseUrl/posts/$postId/comments'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body)['data'];
        return jsonData.map((json) => Comment.fromJson(json)).toList();
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      // For development/demo purposes
      if (e is SocketException || e is HttpException || e is TimeoutException) {
        await Future.delayed(const Duration(seconds: 1));
        return getMockComments(postId);
      }
      throw Exception('Failed to load comments: $e');
    }
  }
  
  // POST: Add a comment to a post
  Future<Comment> addComment(String postId, String content) async {
    try {
      final headers = await _getHeaders();
      final response = await _client.post(
        Uri.parse('$baseUrl/posts/$postId/comments'),
        headers: headers,
        body: json.encode({
          'content': content,
        }),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 201) {
        final jsonData = json.decode(response.body)['data'];
        return Comment.fromJson(jsonData);
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      // For development/demo purposes
      if (e is SocketException || e is HttpException || e is TimeoutException) {
        await Future.delayed(const Duration(seconds: 1));
        
        // Create a mock comment
        final mockUser = getMockUser();
        return Comment(
          id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
          postId: postId,
          userId: mockUser.id,
          content: content,
          likeCount: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
      throw Exception('Failed to add comment: $e');
    }
  }
  
  // GET: Get active surveys
  Future<List<Survey>> getActiveSurveys() async {
    try {
      final headers = await _getHeaders();
      final response = await _client.get(
        Uri.parse('$baseUrl/surveys/active'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body)['data'];
        return jsonData.map((json) => Survey.fromJson(json)).toList();
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      // For development/demo purposes
      if (e is SocketException || e is HttpException || e is TimeoutException) {
        await Future.delayed(const Duration(seconds: 1));
        return getMockSurveys();
      }
      throw Exception('Failed to load surveys: $e');
    }
  }
  
  // GET: Get survey by ID
  Future<Survey> getSurveyById(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await _client.get(
        Uri.parse('$baseUrl/surveys/$id'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body)['data'];
        return Survey.fromJson(jsonData);
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      // For development/demo purposes
      if (e is SocketException || e is HttpException || e is TimeoutException) {
        await Future.delayed(const Duration(seconds: 1));
        
        // Return a mock survey based on the requested ID
        return getMockSurveys().firstWhere(
          (survey) => survey.id == id,
          orElse: () => getMockSurveys().first.copyWith(id: id),
        );
      }
      throw Exception('Failed to load survey: $e');
    }
  }
  
  // POST: Vote on a survey
  Future<SurveyVote> voteSurvey(String surveyId, String optionId) async {
    try {
      final headers = await _getHeaders();
      final response = await _client.post(
        Uri.parse('$baseUrl/surveys/$surveyId/vote'),
        headers: headers,
        body: json.encode({
          'option_id': optionId,
        }),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 201) {
        final jsonData = json.decode(response.body)['data'];
        return SurveyVote.fromJson(jsonData);
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      // For development/demo purposes
      if (e is SocketException || e is HttpException || e is TimeoutException) {
        await Future.delayed(const Duration(seconds: 1));
        
        // Create a mock vote
        final mockUser = getMockUser();
        return SurveyVote(
          id: 'vote_${DateTime.now().millisecondsSinceEpoch}',
          surveyId: surveyId,
          optionId: optionId,
          userId: mockUser.id,
          votedAt: DateTime.now(),
        );
      }
      throw Exception('Failed to vote on survey: $e');
    }
  }
  
  // GET: Get all categories
  Future<List<Category>> getCategories() async {
    try {
      final headers = await _getHeaders();
      final response = await _client.get(
        Uri.parse('$baseUrl/categories'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body)['data'];
        return jsonData.map((json) => Category.fromJson(json)).toList();
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      // For development/demo purposes
      if (e is SocketException || e is HttpException || e is TimeoutException) {
        await Future.delayed(const Duration(seconds: 1));
        return getMockCategories();
      }
      throw Exception('Failed to load categories: $e');
    }
  }
  
  // GET: Get category by ID
  Future<Category> getCategoryById(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await _client.get(
        Uri.parse('$baseUrl/categories/$id'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body)['data'];
        return Category.fromJson(jsonData);
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      // For development/demo purposes
      if (e is SocketException || e is HttpException || e is TimeoutException) {
        await Future.delayed(const Duration(seconds: 1));
        
        // Return a mock category based on the requested ID
        return getMockCategories().firstWhere(
          (category) => category.id == id,
          orElse: () => Category(id: id, name: 'Kategori $id'),
        );
      }
      throw Exception('Failed to load category: $e');
    }
  }
  
  // GET: Get all cities
  Future<List<City>> getCities() async {
    try {
      final headers = await _getHeaders();
      final response = await _client.get(
        Uri.parse('$baseUrl/cities'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body)['data'];
        return jsonData.map((json) => City.fromJson(json)).toList();
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      // For development/demo purposes
      if (e is SocketException || e is HttpException || e is TimeoutException) {
        await Future.delayed(const Duration(seconds: 1));
        return getMockCities();
      }
      throw Exception('Failed to load cities: $e');
    }
  }
  
  // GET: Get city by ID
  Future<City> getCityById(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await _client.get(
        Uri.parse('$baseUrl/cities/$id'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body)['data'];
        return City.fromJson(jsonData);
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      // For development/demo purposes
      if (e is SocketException || e is HttpException || e is TimeoutException) {
        await Future.delayed(const Duration(seconds: 1));
        
        // Return a mock city based on the requested ID
        return getMockCities().firstWhere(
          (city) => city.id == id,
          orElse: () => City(id: id, name: 'Şehir $id'),
        );
      }
      throw Exception('Failed to load city: $e');
    }
  }
  
  // GET: Get districts by city ID
  Future<List<District>> getDistrictsByCityId(String cityId) async {
    try {
      final headers = await _getHeaders();
      final response = await _client.get(
        Uri.parse('$baseUrl/cities/$cityId/districts'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body)['data'];
        return jsonData.map((json) => District.fromJson(json)).toList();
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      // For development/demo purposes
      if (e is SocketException || e is HttpException || e is TimeoutException) {
        await Future.delayed(const Duration(seconds: 1));
        
        // Return mock districts for the requested city
        return getMockDistricts(cityId);
      }
      throw Exception('Failed to load districts: $e');
    }
  }
  
  // GET: Get district by ID
  Future<District> getDistrictById(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await _client.get(
        Uri.parse('$baseUrl/districts/$id'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body)['data'];
        return District.fromJson(jsonData);
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      // For development/demo purposes
      if (e is SocketException || e is HttpException || e is TimeoutException) {
        await Future.delayed(const Duration(seconds: 1));
        
        // Return a mock district based on the requested ID
        final allDistricts = getMockCities()
            .expand((city) => city.districts ?? [])
            .toList();
        
        return allDistricts.firstWhere(
          (district) => district.id == id,
          orElse: () => District(
            id: id,
            name: 'İlçe $id',
            cityId: 'city_1',
          ),
        );
      }
      throw Exception('Failed to load district: $e');
    }
  }
  
  // GET: Get user by ID
  Future<User> getUserById(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await _client.get(
        Uri.parse('$baseUrl/users/$id'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body)['data'];
        return User.fromJson(jsonData);
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      // For development/demo purposes
      if (e is SocketException || e is HttpException || e is TimeoutException) {
        await Future.delayed(const Duration(seconds: 1));
        
        // Return a mock user based on the requested ID
        if (id == 'user_123') {
          return getMockUser();
        }
        
        return User(
          id: id,
          name: 'Kullanıcı $id',
          email: 'user$id@example.com',
          isAdmin: false,
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        );
      }
      throw Exception('Failed to load user: $e');
    }
  }
  
  // MOCK DATA METHODS
  // These methods provide mock data for development and testing
  
  // Mock Posts
  List<Post> getMockPosts() {
    return [
      Post(
        id: 'post_1',
        userId: 'user_123',
        title: 'Caddeye çöp kutusu konulması',
        content: 'Mahallemizdeki ana caddeye daha fazla çöp kutusu konulması gerekiyor. Çöpler her yere atılıyor ve çevre kirliliği oluşuyor.',
        categoryId: 'category_1',
        type: PostType.general,
        imageUrls: [],
        likeCount: 15,
        commentCount: 3,
        highlightCount: 5,
        isAnonymous: false,
        cityId: 'city_1',
        districtId: 'district_1',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Post(
        id: 'post_2',
        userId: 'user_124',
        title: 'Park alanında bozuk banklar',
        content: 'Merkez Parkı\'ndaki bankların çoğu kırık ve oturulamaz durumda. Ailemle gittiğimde oturacak yer bulamıyoruz. Lütfen yenilenmesini talep ediyorum.',
        categoryId: 'category_2',
        type: PostType.problem,
        status: PostStatus.awaitingSolution,
        imageUrls: [],
        likeCount: 24,
        commentCount: 7,
        highlightCount: 12,
        isAnonymous: false,
        cityId: 'city_1',
        districtId: 'district_2',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Post(
        id: 'post_3',
        userId: 'user_125',
        title: 'Sokak lambaları çalışmıyor',
        content: 'Gül Sokak\'taki sokak lambaları 2 haftadır çalışmıyor. Akşamları çok karanlık oluyor ve güvenlik sorunu yaşıyoruz. Acilen tamir edilmesi gerekiyor.',
        categoryId: 'category_3',
        type: PostType.problem,
        status: PostStatus.inProgress,
        imageUrls: [],
        likeCount: 36,
        commentCount: 9,
        highlightCount: 18,
        isAnonymous: true,
        cityId: 'city_1',
        districtId: 'district_1',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(days: 6)),
      ),
    ];
  }
  
  // Mock Comments
  List<Comment> getMockComments(String postId) {
    return [
      Comment(
        id: 'comment_1',
        postId: postId,
        userId: 'user_124',
        content: 'Aynı sorunu ben de yaşıyorum. Belediyeyi aradığımda ilgileneceklerini söylediler ama henüz bir gelişme yok.',
        likeCount: 5,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Comment(
        id: 'comment_2',
        postId: postId,
        userId: 'user_125',
        content: 'Çözüm için imza toplayabiliriz.',
        likeCount: 3,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }
  
  // Mock Surveys
  List<Survey> getMockSurveys() {
    return [
      Survey(
        id: 'survey_1',
        title: 'Belediye Hizmetleri Memnuniyeti',
        description: 'Son 6 ayda belediye hizmetlerinden memnuniyet düzeyiniz nedir?',
        options: [
          SurveyOption(id: 'option_1', text: 'Çok Memnunum', voteCount: 127),
          SurveyOption(id: 'option_2', text: 'Memnunum', voteCount: 243),
          SurveyOption(id: 'option_3', text: 'Kararsızım', voteCount: 89),
          SurveyOption(id: 'option_4', text: 'Memnun Değilim', voteCount: 156),
          SurveyOption(id: 'option_5', text: 'Hiç Memnun Değilim', voteCount: 94),
        ],
        startDate: DateTime.now().subtract(const Duration(days: 10)),
        endDate: DateTime.now().add(const Duration(days: 20)),
        cityId: 'city_1',
        totalVotes: 709,
        isActive: true,
      ),
      Survey(
        id: 'survey_2',
        title: 'Yeni Park Projesi',
        description: 'Mahallenizdeki boş alana nasıl bir park yapılmasını istersiniz?',
        options: [
          SurveyOption(id: 'option_1', text: 'Çocuk Parkı', voteCount: 315),
          SurveyOption(id: 'option_2', text: 'Spor Parkı', voteCount: 278),
          SurveyOption(id: 'option_3', text: 'Dinlenme Alanı', voteCount: 192),
          SurveyOption(id: 'option_4', text: 'Karma Alan', voteCount: 327),
        ],
        startDate: DateTime.now().subtract(const Duration(days: 5)),
        endDate: DateTime.now().add(const Duration(days: 25)),
        cityId: 'city_1',
        districtId: 'district_1',
        totalVotes: 1112,
        isActive: true,
      ),
    ];
  }
  
  // Mock Categories
  List<Category> getMockCategories() {
    return [
      Category(
        id: 'category_1',
        name: 'Çevre Temizliği',
        description: 'Çevre temizliği, çöp toplama ve geri dönüşüm ile ilgili konular',
        iconName: 'cleaning',
        subCategories: [
          Category(
            id: 'subcategory_1',
            name: 'Çöp Toplama',
            description: 'Çöp toplama hizmetleri',
            iconName: 'trash',
          ),
          Category(
            id: 'subcategory_2',
            name: 'Geri Dönüşüm',
            description: 'Geri dönüşüm kutuları ve hizmetleri',
            iconName: 'recycle',
          ),
        ],
      ),
      Category(
        id: 'category_2',
        name: 'Park ve Bahçeler',
        description: 'Parklar, bahçeler, yeşil alanlar',
        iconName: 'park',
        subCategories: [
          Category(
            id: 'subcategory_3',
            name: 'Çocuk Parkları',
            description: 'Çocuk oyun alanları',
            iconName: 'child_friendly',
          ),
          Category(
            id: 'subcategory_4',
            name: 'Spor Alanları',
            description: 'Açık hava spor alanları',
            iconName: 'sports',
          ),
        ],
      ),
      Category(
        id: 'category_3',
        name: 'Altyapı',
        description: 'Su, elektrik, yol, kaldırım gibi altyapı hizmetleri',
        iconName: 'build',
        subCategories: [
          Category(
            id: 'subcategory_5',
            name: 'Yol ve Kaldırımlar',
            description: 'Yol ve kaldırım bakımı',
            iconName: 'road',
          ),
          Category(
            id: 'subcategory_6',
            name: 'Sokak Aydınlatması',
            description: 'Sokak lambaları ve aydınlatma',
            iconName: 'light',
          ),
        ],
      ),
    ];
  }
  
  // Mock Cities
  List<City> getMockCities() {
    return [
      City(
        id: 'city_1',
        name: 'İstanbul',
        code: '34',
        districts: [
          District(id: 'district_1', name: 'Kadıköy', cityId: 'city_1'),
          District(id: 'district_2', name: 'Beşiktaş', cityId: 'city_1'),
          District(id: 'district_3', name: 'Üsküdar', cityId: 'city_1'),
        ],
      ),
      City(
        id: 'city_2',
        name: 'Ankara',
        code: '06',
        districts: [
          District(id: 'district_4', name: 'Çankaya', cityId: 'city_2'),
          District(id: 'district_5', name: 'Keçiören', cityId: 'city_2'),
          District(id: 'district_6', name: 'Mamak', cityId: 'city_2'),
        ],
      ),
      City(
        id: 'city_3',
        name: 'İzmir',
        code: '35',
        districts: [
          District(id: 'district_7', name: 'Konak', cityId: 'city_3'),
          District(id: 'district_8', name: 'Karşıyaka', cityId: 'city_3'),
          District(id: 'district_9', name: 'Bornova', cityId: 'city_3'),
        ],
      ),
    ];
  }
  
  // Mock Districts
  List<District> getMockDistricts(String cityId) {
    final allCities = getMockCities();
    final city = allCities.firstWhere(
      (city) => city.id == cityId,
      orElse: () => City(id: cityId, name: 'Şehir $cityId'),
    );
    
    return city.districts ?? [];
  }
  
  // Mock User
  User getMockUser() {
    return User(
      id: 'user_123',
      name: 'Ahmet Yılmaz',
      email: 'ahmet@example.com',
      phone: '05551234567',
      profilePhotoUrl: null,
      cityId: 'city_1', // İstanbul
      districtId: 'district_1', // Kadıköy
      isAdmin: false,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    );
  }
}