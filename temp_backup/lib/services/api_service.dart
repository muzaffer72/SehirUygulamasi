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
import 'package:sikayet_var/models/notification.dart' as app_notification;
import 'package:sikayet_var/models/before_after_record.dart';

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
  
  // Genel HTTP GET isteği için yardımcı metot
  Future<http.Response> get(String endpoint) async {
    final token = await _getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = token.startsWith('Bearer ') ? token : 'Bearer $token';
    }
    
    final url = Uri.parse('$baseUrl/$endpoint');
    print('ApiService GET: $url');
    return await _client.get(url, headers: headers);
  }
  
  // Genel HTTP POST isteği için yardımcı metot
  Future<http.Response> post(String endpoint, dynamic data) async {
    final token = await _getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = token.startsWith('Bearer ') ? token : 'Bearer $token';
    }
    
    final url = Uri.parse('$baseUrl/$endpoint');
    print('ApiService POST: $url');
    return await _client.post(
      url, 
      headers: headers,
      body: data != null ? jsonEncode(data) : null,
    );
  }
  
  // Genel HTTP PUT isteği için yardımcı metot
  Future<http.Response> put(String endpoint, dynamic data) async {
    final token = await _getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = token.startsWith('Bearer ') ? token : 'Bearer $token';
    }
    
    final url = Uri.parse('$baseUrl/$endpoint');
    print('ApiService PUT: $url');
    return await _client.put(
      url, 
      headers: headers,
      body: data != null ? jsonEncode(data) : null,
    );
  }
  
  // Genel HTTP DELETE isteği için yardımcı metot
  Future<http.Response> delete(String endpoint) async {
    final token = await _getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = token.startsWith('Bearer ') ? token : 'Bearer $token';
    }
    
    final url = Uri.parse('$baseUrl/$endpoint');
    print('ApiService DELETE: $url');
    return await _client.delete(url, headers: headers);
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
  Future<List<Post>> getPosts({
    String? categoryId, 
    String? cityId, 
    String? districtId, 
    String? status, 
    String? userId, 
    PostType? type,
    String? sortBy,
    int page = 1, 
    int limit = 20
  }) async {
    // Laravel admin paneli ile uyumlu endpoint kullan
    String url = '$baseUrl/api/posts';
    
    // Admin panel API'sına sorgu parametreleri
    final queryParams = <String, String>{};
    if (categoryId != null) queryParams['category_id'] = categoryId;
    if (cityId != null) queryParams['city_id'] = cityId;
    if (districtId != null) queryParams['district_id'] = districtId;
    if (status != null) queryParams['status'] = status;
    if (userId != null) queryParams['user_id'] = userId;
    if (type != null) queryParams['type'] = type.toString().split('.').last;
    if (sortBy != null) queryParams['sort'] = sortBy;
    queryParams['page'] = page.toString();
    queryParams['per_page'] = limit.toString();
    
    // URL'yi oluştur
    if (queryParams.isNotEmpty) {
      url += '?' + Uri(queryParameters: queryParams).query;
    }
    
    print('Calling API: $url');
    
    try {
      // API isteği yap
      final response = await _client.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      print('Posts response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        print('Posts data type: ${data.runtimeType}');
        
        List<Post> results = [];
        
        // Admin paneli formatında yanıt kontrol
        if (data is Map<String, dynamic>) {
          // Laravel API formatları
          if (data.containsKey('data') && data['data'] is List) {
            // Laravel resource collection formatı
            final List<dynamic> postsData = data['data'];
            results = postsData.map((item) => Post.fromJson(item)).toList();
            print('Parsed ${results.length} posts from data field');
          } 
          else if (data.containsKey('posts') && data['posts'] is List) {
            // Özel Laravel admin formatı 
            final List<dynamic> postsData = data['posts'];
            results = postsData.map((item) => Post.fromJson(item)).toList();
            print('Parsed ${results.length} posts from posts field');
          }
          else if (data.containsKey('results') && data['results'] is List) {
            // Alternatif format
            final List<dynamic> postsData = data['results'];
            results = postsData.map((item) => Post.fromJson(item)).toList();
            print('Parsed ${results.length} posts from results field');
          }
          else {
            print('Unexpected API response format: $data');
            
            // Alternatif endpoint dene
            return await _getFallbackPosts(
              categoryId: categoryId,
              cityId: cityId,
              districtId: districtId,
              status: status,
              userId: userId,
              type: type,
              sortBy: sortBy,
              page: page,
              limit: limit
            );
          }
        } 
        // Düz liste formatında yanıt (nadiren olur)
        else if (data is List) {
          results = data.map((item) => Post.fromJson(item)).toList();
          print('Parsed ${results.length} posts from direct list');
        }
        // Fallback mekanizması
        else {
          print('Unexpected API response type. Trying fallback endpoint.');
          return await _getFallbackPosts(
            categoryId: categoryId,
            cityId: cityId,
            districtId: districtId,
            status: status,
            userId: userId,
            type: type,
            sortBy: sortBy,
            page: page,
            limit: limit
          );
        }
        
        return results;
      } else {
        print('Failed to load posts: ${response.body}');
        // Hata durumunda alternatif endpoint dene
        return await _getFallbackPosts(
          categoryId: categoryId,
          cityId: cityId,
          districtId: districtId,
          status: status,
          userId: userId,
          type: type,
          sortBy: sortBy,
          page: page,
          limit: limit
        );
      }
    } catch (e) {
      print('Error fetching posts: $e');
      // Hata durumunda alternatif endpoint dene
      return await _getFallbackPosts(
        categoryId: categoryId,
        cityId: cityId,
        districtId: districtId,
        status: status,
        userId: userId,
        type: type,
        sortBy: sortBy,
        page: page,
        limit: limit
      );
    }
  }
  
  // Alternatif endpoint - eski API formatına uyumlu
  Future<List<Post>> _getFallbackPosts({
    String? categoryId, 
    String? cityId, 
    String? districtId, 
    String? status, 
    String? userId, 
    PostType? type,
    String? sortBy,
    int page = 1, 
    int limit = 20
  }) async {
    print('Trying fallback posts endpoint');
    String url = '$baseUrl/posts';
    
    // Add query parameters if available
    final queryParams = <String, String>{};
    if (categoryId != null) queryParams['category_id'] = categoryId;
    if (cityId != null) queryParams['city_id'] = cityId;
    if (districtId != null) queryParams['district_id'] = districtId;
    if (status != null) queryParams['status'] = status;
    if (userId != null) queryParams['user_id'] = userId;
    if (type != null) queryParams['type'] = type.toString().split('.').last;
    if (sortBy != null) queryParams['sort'] = sortBy;
    queryParams['page'] = page.toString();
    queryParams['limit'] = limit.toString();
    
    if (queryParams.isNotEmpty) {
      url += '?' + Uri(queryParameters: queryParams).query;
    }
    
    try {
      final response = await _client.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Eski formatlara uyumlu kontroller
        if (data is Map<String, dynamic> && data.containsKey('posts')) {
          final List<dynamic> postsData = data['posts'];
          return postsData.map((item) => Post.fromJson(item)).toList();
        } 
        else if (data is List) {
          return data.map((item) => Post.fromJson(item)).toList();
        } 
        else {
          print('Unexpected data format in fallback: $data');
          return [];
        }
      } else {
        print('Failed to load posts from fallback: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching posts from fallback: $e');
      return [];
    }
  }
  
  Future<Post> getPostById(String id) async {
    print('Getting post details for ID: $id');
    try {
      // Laravel admin paneli API entegrasyonu
      final response = await _client.get(
        Uri.parse('$baseUrl/api/posts/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      print('Get post by ID response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Post data format: ${data.runtimeType}');
        
        // Admin paneli API'si yanıt yapısı kontrol
        if (data is Map<String, dynamic>) {
          // Laravel API yapıları
          if (data.containsKey('post')) {
            // {post: {...}} formatı
            print('Post found in post field');
            return Post.fromJson(data['post']);
          } else if (data.containsKey('data')) {
            // Laravel resource formatı: {data: {...}}
            print('Post found in data field');
            return Post.fromJson(data['data']);
          } else {
            // Doğrudan post objesi
            print('Post found as direct object');
            return Post.fromJson(data);
          }
        } else {
          print('Invalid post response format, trying fallback');
          final post = await _getFallbackPostById(id);
          if (post == null) {
            throw Exception('Post not found with ID: $id');
          }
          return post;
        }
      } else {
        print('Failed to load post: ${response.body}');
        // Ana endpoint çalışmadığında yedek endpoint dene
        final post = await _getFallbackPostById(id);
        if (post == null) {
          throw Exception('Post not found with ID: $id');
        }
        return post;
      }
    } catch (e) {
      print('Error fetching post: $e');
      // Hata oluştuğunda yedek endpoint dene
      final post = await _getFallbackPostById(id);
      if (post == null) {
        throw Exception('Post not found with ID: $id or error: $e');
      }
      return post;
    }
  }
  
  // Yedek gönderi detay endpoint'i - eski API formatları için
  Future<Post?> _getFallbackPostById(String id) async {
    print('Trying fallback endpoint for post ID: $id');
    try {
      final response = await _client.get(Uri.parse('$baseUrl/posts/$id'));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data is Map<String, dynamic>) {
          // Olası formatlar
          if (data.containsKey('post')) {
            return Post.fromJson(data['post']);
          } else if (data.containsKey('data')) {
            return Post.fromJson(data['data']);
          } else {
            return Post.fromJson(data);
          }
        } else {
          print('Invalid fallback post response format');
          return null;
        }
      } else {
        print('Failed to load post from fallback: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching post from fallback: $e');
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
    print('Liking post ID: $id');
    final token = await _getToken();
    final user = await getCurrentUser();
    final userId = user?.id;
    
    try {
      // Önce mevcut gönderiyi kontrol et
      final post = await getPostById(id);
      
      // Laravel admin paneli API entegrasyonu
      try {
        print('Trying admin panel API for liking post');
        final response = await _client.post(
          Uri.parse('$baseUrl/api/posts/$id/like'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': token != null ? (token.startsWith('Bearer ') ? token : 'Bearer $token') : '',
          },
          body: jsonEncode({
            'user_id': userId,
          }),
        );
        
        print('Like response status: ${response.statusCode}');
        
        if (response.statusCode == 200 || response.statusCode == 201) {
          print('Successfully liked post via API');
          // Beğeni işlemi başarılı, güncel gönderiyi getir
          return await getPostById(id);
        } else {
          print('API like request failed, trying alternative');
        }
      } catch (e) {
        print('API like request error: $e');
      }
      
      // API yöntemi başarısız olursa alternatif yöntem
      try {
        print('Trying fallback method for liking post');
        final fallbackResponse = await _client.post(
          Uri.parse('$baseUrl/posts/$id/like'),
          headers: {'Content-Type': 'application/json'},
          body: token != null ? jsonEncode({'token': token}) : null,
        );
        
        if (fallbackResponse.statusCode == 200) {
          print('Successfully liked post via fallback endpoint');
          return await getPostById(id);
        }
      } catch (e) {
        print('Fallback like request error: $e');
      }
      
      // Son çare - istemci tarafında beğeni sayısını artır
      print('Using client-side fallback for liking post');
      final likes = post.likes + 1;
      
      // Önce dinamik state güncellemesi için güncellenmiş gönderi objesi
      final updatedPost = post.copyWith(likes: likes);
      
      // Paralelinde async olarak sunucuya güncelleme isteği gönderme
      updatePost(id, {'likes': likes})
        .then((_) => print('Updated post likes on server'))
        .catchError((e) => print('Failed to update post likes on server: $e'));
      
      return updatedPost;
    } catch (e) {
      print('Error in likePost: $e');
      return null;
    }
  }
  
  Future<Post?> highlightPost(String id) async {
    print('Highlighting post ID: $id');
    final token = await _getToken();
    final user = await getCurrentUser();
    final userId = user?.id;
    
    try {
      // Önce mevcut gönderiyi kontrol et
      final post = await getPostById(id);
      
      // Laravel admin paneli API entegrasyonu
      try {
        print('Trying admin panel API for highlighting post');
        final response = await _client.post(
          Uri.parse('$baseUrl/api/posts/$id/highlight'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': token != null ? (token.startsWith('Bearer ') ? token : 'Bearer $token') : '',
          },
          body: jsonEncode({
            'user_id': userId,
          }),
        );
        
        print('Highlight response status: ${response.statusCode}');
        
        if (response.statusCode == 200 || response.statusCode == 201) {
          print('Successfully highlighted post via API');
          // Öne çıkarma işlemi başarılı, güncel gönderiyi getir
          return await getPostById(id);
        } else {
          print('API highlight request failed, trying alternative');
        }
      } catch (e) {
        print('API highlight request error: $e');
      }
      
      // API yöntemi başarısız olursa alternatif yöntem
      try {
        print('Trying fallback method for highlighting post');
        final fallbackResponse = await _client.post(
          Uri.parse('$baseUrl/posts/$id/highlight'),
          headers: {'Content-Type': 'application/json'},
          body: token != null ? jsonEncode({'token': token}) : null,
        );
        
        if (fallbackResponse.statusCode == 200) {
          print('Successfully highlighted post via fallback endpoint');
          return await getPostById(id);
        }
      } catch (e) {
        print('Fallback highlight request error: $e');
      }
      
      // Son çare - istemci tarafında öne çıkarma sayısını artır
      print('Using client-side fallback for highlighting post');
      final highlights = post.highlights + 1;
      
      // Önce dinamik state güncellemesi için güncellenmiş gönderi objesi
      final updatedPost = post.copyWith(highlights: highlights);
      
      // Paralelinde async olarak sunucuya güncelleme isteği gönderme
      updatePost(id, {'highlights': highlights})
        .then((_) => print('Updated post highlights on server'))
        .catchError((e) => print('Failed to update post highlights on server: $e'));
      
      return updatedPost;
    } catch (e) {
      print('Error in highlightPost: $e');
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
        userId: userId.toString(),
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
  
  // Categories
  // Memnuniyet derecelendirme sistemi için metotlar
  Future<int?> getSatisfactionRating(String postId) async {
    try {
      final response = await get('api/satisfaction_rating.php?post_id=$postId');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          if (data['data']['satisfaction_rating'] != null) {
            return int.tryParse(data['data']['satisfaction_rating'].toString());
          }
        }
      }
      return null;
    } catch (e) {
      print('Error fetching satisfaction rating: $e');
      return null;
    }
  }
  
  Future<bool> submitSatisfactionRating(String postId, int rating) async {
    try {
      final response = await post('api/satisfaction_rating.php', {
        'post_id': postId,
        'rating': rating
      });
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error submitting satisfaction rating: $e');
      return false;
    }
  }
  
  // Öncesi/Sonrası kayıtları için metotlar
  Future<List<BeforeAfterRecord>> getBeforeAfterRecords(String postId) async {
    try {
      final response = await get('api/before_after.php?post_id=$postId');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          if (data['data'] is List) {
            return (data['data'] as List)
                .map((item) => BeforeAfterRecord.fromJson(item))
                .toList();
          }
        }
      }
      return [];
    } catch (e) {
      print('Error fetching before/after records: $e');
      return [];
    }
  }
  
  Future<BeforeAfterRecord?> createBeforeAfterRecord(
      String postId,
      String beforeImageUrl,
      String afterImageUrl,
      {String? description}) async {
    try {
      final response = await post('api/before_after.php', {
        'post_id': postId,
        'before_image_url': beforeImageUrl,
        'after_image_url': afterImageUrl,
        'description': description
      });
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return BeforeAfterRecord.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error creating before/after record: $e');
      return null;
    }
  }
  
  // Bildirim sistemi için metotlar
  Future<List<Notification>> getNotifications({
    String? userId,
    bool? isRead,
    bool? isArchived,
    String? groupId,
    int page = 1,
    int limit = 20
  }) async {
    try {
      String url = 'api/notifications.php';
      
      // Sorgu parametreleri
      final queryParams = <String, String>{};
      if (userId != null) queryParams['user_id'] = userId;
      if (isRead != null) queryParams['is_read'] = isRead ? '1' : '0';
      if (isArchived != null) queryParams['is_archived'] = isArchived ? '1' : '0';
      if (groupId != null) queryParams['group_id'] = groupId;
      queryParams['page'] = page.toString();
      queryParams['limit'] = limit.toString();
      
      if (queryParams.isNotEmpty) {
        url += '?' + Uri(queryParameters: queryParams).query;
      }
      
      final response = await get(url);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          if (data['data'] is List) {
            return (data['data'] as List)
                .map((item) => Notification.fromJson(item))
                .toList();
          }
        }
      }
      return [];
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }
  
  Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      final response = await post('api/notifications.php', {
        'action': 'mark_read',
        'notification_id': notificationId
      });
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }
  
  Future<bool> markAllNotificationsAsRead({String? userId}) async {
    try {
      final Map<String, dynamic> requestBody = {'action': 'mark_all_read'};
      if (userId != null) requestBody['user_id'] = userId;
      
      final response = await post('api/notifications.php', requestBody);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error marking all notifications as read: $e');
      return false;
    }
  }
  
  Future<bool> archiveNotification(String notificationId) async {
    try {
      final response = await post('api/notifications.php', {
        'action': 'archive',
        'notification_id': notificationId
      });
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error archiving notification: $e');
      return false;
    }
  }
  
  Future<List<app_category.Category>> getCategories() async {
    print('Fetching categories from API');
    try {
      // Laravel admin paneli ile uyumlu endpoint kullan
      final response = await _client.get(
        Uri.parse('$baseUrl/api/categories'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      print('Categories response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        List<app_category.Category> results = [];
        
        // API yanıt formatını kontrol et
        if (data is Map<String, dynamic>) {
          List<dynamic> categoriesData;
          
          if (data.containsKey('data') && data['data'] is List) {
            // Laravel resource collection formatı
            categoriesData = data['data'];
          } 
          else if (data.containsKey('categories') && data['categories'] is List) {
            // Özel format
            categoriesData = data['categories'];
          }
          else if (data.containsKey('results') && data['results'] is List) {
            // Alternatif format
            categoriesData = data['results'];
          }
          else {
            print('Unexpected API response format for categories');
            return await _getFallbackCategories();
          }
          
          results = categoriesData
              .map((item) => app_category.Category.fromJson(item))
              .toList();
          print('Parsed ${results.length} categories');
          return results;
        } 
        else if (data is List) {
          // Düz liste formatı
          results = data
              .map((item) => app_category.Category.fromJson(item))
              .toList();
          print('Parsed ${results.length} categories from list');
          return results;
        }
        else {
          print('Unexpected categories data type');
          return await _getFallbackCategories();
        }
      } else {
        print('Failed to load categories: ${response.body}');
        return await _getFallbackCategories();
      }
    } catch (e) {
      print('Error fetching categories: $e');
      return await _getFallbackCategories();
    }
  }
  
  // Yedek kategori yükleme
  Future<List<app_category.Category>> _getFallbackCategories() async {
    print('Using fallback endpoint for categories');
    try {
      final response = await _client.get(Uri.parse('$baseUrl/categories'));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data is List) {
          return data.map((item) => app_category.Category.fromJson(item)).toList();
        } else if (data is Map<String, dynamic> && data.containsKey('categories')) {
          final List<dynamic> categoriesData = data['categories'];
          return categoriesData.map((item) => app_category.Category.fromJson(item)).toList();
        } else {
          print('Invalid fallback categories format');
          return [];
        }
      } else {
        print('Failed to load fallback categories: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching fallback categories: $e');
      return [];
    }
  }
  
  Future<app_category.Category?> getCategoryById(String id) async {
    print('Fetching category details for ID: $id');
    try {
      // Laravel admin paneli API entegrasyonu
      final response = await _client.get(
        Uri.parse('$baseUrl/api/categories/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data is Map<String, dynamic>) {
          if (data.containsKey('data')) {
            return app_category.Category.fromJson(data['data']);
          } else if (data.containsKey('category')) {
            return app_category.Category.fromJson(data['category']);
          } else {
            return app_category.Category.fromJson(data);
          }
        } else {
          print('Invalid category response format');
          return null;
        }
      } else {
        print('Failed to load category: ${response.body}');
        // Alternatif endpoint dene
        return await _getFallbackCategoryById(id);
      }
    } catch (e) {
      print('Error fetching category: $e');
      return await _getFallbackCategoryById(id);
    }
  }
  
  // Yedek kategori detay yükleme
  Future<app_category.Category?> _getFallbackCategoryById(String id) async {
    try {
      final response = await _client.get(Uri.parse('$baseUrl/categories/$id'));
      
      if (response.statusCode == 200) {
        return app_category.Category.fromJson(jsonDecode(response.body));
      } else {
        print('Failed to load fallback category: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching fallback category: $e');
      return null;
    }
  }
  
  // Cities
  Future<List<City>> getCities() async {
    print('Fetching cities from API');
    try {
      // Laravel admin paneli ile uyumlu endpoint kullan
      final response = await _client.get(
        Uri.parse('$baseUrl/api/cities'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      print('Cities response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        List<City> results = [];
        
        // API yanıt formatını kontrol et
        if (data is Map<String, dynamic>) {
          List<dynamic> citiesData;
          
          if (data.containsKey('data') && data['data'] is List) {
            // Laravel resource collection formatı
            citiesData = data['data'];
          } 
          else if (data.containsKey('cities') && data['cities'] is List) {
            // Özel format
            citiesData = data['cities'];
          }
          else if (data.containsKey('results') && data['results'] is List) {
            // Alternatif format
            citiesData = data['results'];
          }
          else {
            print('Unexpected API response format for cities');
            return await _getFallbackCities();
          }
          
          results = citiesData
              .map((item) => City.fromJson(item))
              .toList();
          print('Parsed ${results.length} cities');
          return results;
        } 
        else if (data is List) {
          // Düz liste formatı
          results = data
              .map((item) => City.fromJson(item))
              .toList();
          print('Parsed ${results.length} cities from list');
          return results;
        }
        else {
          print('Unexpected cities data type');
          return await _getFallbackCities();
        }
      } else {
        print('Failed to load cities: ${response.body}');
        return await _getFallbackCities();
      }
    } catch (e) {
      print('Error fetching cities: $e');
      return await _getFallbackCities();
    }
  }
  
  // Yedek şehir listesi yükleme
  Future<List<City>> _getFallbackCities() async {
    print('Using fallback endpoint for cities');
    try {
      final response = await _client.get(Uri.parse('$baseUrl/cities'));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data is List) {
          return data.map((item) => City.fromJson(item)).toList();
        } else if (data is Map<String, dynamic> && data.containsKey('cities')) {
          final List<dynamic> citiesData = data['cities'];
          return citiesData.map((item) => City.fromJson(item)).toList();
        } else {
          print('Invalid fallback cities format');
          return [];
        }
      } else {
        print('Failed to load fallback cities: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching fallback cities: $e');
      return [];
    }
  }
  
  Future<City?> getCityById(String id) async {
    print('Fetching city details for ID: $id');
    try {
      // Laravel admin paneli API entegrasyonu
      final response = await _client.get(
        Uri.parse('$baseUrl/api/cities/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data is Map<String, dynamic>) {
          if (data.containsKey('data')) {
            return City.fromJson(data['data']);
          } else if (data.containsKey('city')) {
            return City.fromJson(data['city']);
          } else {
            return City.fromJson(data);
          }
        } else {
          print('Invalid city response format');
          return await _getFallbackCityById(id);
        }
      } else {
        print('Failed to load city: ${response.body}');
        // Alternatif endpoint dene
        return await _getFallbackCityById(id);
      }
    } catch (e) {
      print('Error fetching city: $e');
      return await _getFallbackCityById(id);
    }
  }
  
  // Yedek şehir detay yükleme
  Future<City?> _getFallbackCityById(String id) async {
    try {
      final response = await _client.get(Uri.parse('$baseUrl/cities/$id'));
      
      if (response.statusCode == 200) {
        return City.fromJson(jsonDecode(response.body));
      } else {
        print('Failed to load fallback city: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching fallback city: $e');
      return null;
    }
  }
  
  // Şehir profil bilgilerini getir
  Future<CityProfile?> getCityProfile(int cityId) async {
    print('Fetching city profile for ID: $cityId');
    
    try {
      // Laravel admin panel API entegrasyonu
      final response = await _client.get(
        Uri.parse('$baseUrl/api/cities/${cityId.toString()}/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      print('City profile response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data is Map<String, dynamic>) {
          if (data.containsKey('data')) {
            return CityProfile.fromJson(data['data']);
          } else if (data.containsKey('profile')) {
            return CityProfile.fromJson(data['profile']);
          } else if (data.containsKey('city_profile')) {
            return CityProfile.fromJson(data['city_profile']);
          } else {
            return CityProfile.fromJson(data);
          }
        } else {
          print('Invalid city profile response format');
          return await _getFallbackCityProfile(cityId);
        }
      } else {
        print('Failed to load city profile: ${response.body}');
        return await _getFallbackCityProfile(cityId);
      }
    } catch (e) {
      print('Error fetching city profile: $e');
      return await _getFallbackCityProfile(cityId);
    }
  }
  
  // Yedek şehir profil bilgilerini getir
  Future<CityProfile?> _getFallbackCityProfile(int cityId) async {
    print('Using fallback endpoint for city profile ID: $cityId');
    try {
      final response = await _client.get(Uri.parse('$baseUrl/cities/${cityId.toString()}/profile'));
      
      if (response.statusCode == 200) {
        return CityProfile.fromJson(jsonDecode(response.body));
      } else {
        print('Failed to load fallback city profile: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching fallback city profile: $e');
      return null;
    }
  }
  
  // Districts
  Future<List<District>> getDistricts() async {
    print('Fetching districts from API');
    try {
      // Laravel admin panel ile uyumlu endpoint kullan
      final response = await _client.get(
        Uri.parse('$baseUrl/api/districts'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      print('Districts response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        List<District> results = [];
        
        // API yanıt formatını kontrol et
        if (data is Map<String, dynamic>) {
          List<dynamic> districtsData;
          
          if (data.containsKey('data') && data['data'] is List) {
            // Laravel resource collection formatı
            districtsData = data['data'];
          } 
          else if (data.containsKey('districts') && data['districts'] is List) {
            // Özel format
            districtsData = data['districts'];
          }
          else if (data.containsKey('results') && data['results'] is List) {
            // Alternatif format
            districtsData = data['results'];
          }
          else {
            print('Unexpected API response format for districts');
            return await _getFallbackDistricts();
          }
          
          results = districtsData
              .map((item) => District.fromJson(item))
              .toList();
          print('Parsed ${results.length} districts');
          return results;
        } 
        else if (data is List) {
          // Düz liste formatı
          results = data
              .map((item) => District.fromJson(item))
              .toList();
          print('Parsed ${results.length} districts from list');
          return results;
        }
        else {
          print('Unexpected districts data type');
          return await _getFallbackDistricts();
        }
      } else {
        print('Failed to load districts: ${response.body}');
        return await _getFallbackDistricts();
      }
    } catch (e) {
      print('Error fetching districts: $e');
      return await _getFallbackDistricts();
    }
  }
  
  // Yedek ilçe listesi yükleme
  Future<List<District>> _getFallbackDistricts() async {
    print('Using fallback endpoint for districts');
    try {
      final response = await _client.get(Uri.parse('$baseUrl/districts'));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data is List) {
          return data.map((item) => District.fromJson(item)).toList();
        } else if (data is Map<String, dynamic> && data.containsKey('districts')) {
          final List<dynamic> districtsData = data['districts'];
          return districtsData.map((item) => District.fromJson(item)).toList();
        } else {
          print('Invalid fallback districts format');
          return [];
        }
      } else {
        print('Failed to load fallback districts: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching fallback districts: $e');
      return [];
    }
  }
  
  Future<List<District>> getDistrictsByCityId(String cityId) async {
    print('Fetching districts for city ID: $cityId');
    try {
      // Laravel admin panel ile uyumlu endpoint kullan
      final response = await _client.get(
        Uri.parse('$baseUrl/api/districts?city_id=$cityId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      print('Districts by city response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        List<District> results = [];
        
        // API yanıt formatını kontrol et
        if (data is Map<String, dynamic>) {
          List<dynamic> districtsData;
          
          if (data.containsKey('data') && data['data'] is List) {
            districtsData = data['data'];
          } 
          else if (data.containsKey('districts') && data['districts'] is List) {
            districtsData = data['districts'];
          }
          else if (data.containsKey('results') && data['results'] is List) {
            districtsData = data['results'];
          }
          else {
            print('Unexpected API response format for districts by city');
            return await _getFallbackDistrictsByCityId(cityId);
          }
          
          results = districtsData
              .map((item) => District.fromJson(item))
              .toList();
          print('Parsed ${results.length} districts for city ID: $cityId');
          return results;
        } 
        else if (data is List) {
          results = data
              .map((item) => District.fromJson(item))
              .toList();
          print('Parsed ${results.length} districts for city ID from list: $cityId');
          return results;
        }
        else {
          print('Unexpected districts by city data type');
          return await _getFallbackDistrictsByCityId(cityId);
        }
      } else {
        print('Failed to load districts by city: ${response.body}');
        return await _getFallbackDistrictsByCityId(cityId);
      }
    } catch (e) {
      print('Error fetching districts by city: $e');
      return await _getFallbackDistrictsByCityId(cityId);
    }
  }
  
  // Yedek ilçe listesi yükleme (şehir ID'sine göre)
  Future<List<District>> _getFallbackDistrictsByCityId(String cityId) async {
    print('Using fallback endpoint for districts by city ID: $cityId');
    try {
      final response = await _client.get(Uri.parse('$baseUrl/districts?city_id=$cityId'));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data is List) {
          return data.map((item) => District.fromJson(item)).toList();
        } else if (data is Map<String, dynamic> && data.containsKey('districts')) {
          final List<dynamic> districtsData = data['districts'];
          return districtsData.map((item) => District.fromJson(item)).toList();
        } else {
          print('Invalid fallback districts by city format');
          return [];
        }
      } else {
        print('Failed to load fallback districts by city: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching fallback districts by city: $e');
      return [];
    }
  }
  
  Future<District?> getDistrictById(String id) async {
    print('Fetching district details for ID: $id');
    try {
      // Laravel admin panel API entegrasyonu
      final response = await _client.get(
        Uri.parse('$baseUrl/api/districts/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      print('District details response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data is Map<String, dynamic>) {
          if (data.containsKey('data')) {
            return District.fromJson(data['data']);
          } else if (data.containsKey('district')) {
            return District.fromJson(data['district']);
          } else {
            return District.fromJson(data);
          }
        } else {
          print('Invalid district response format');
          return await _getFallbackDistrictById(id);
        }
      } else {
        print('Failed to load district: ${response.body}');
        return await _getFallbackDistrictById(id);
      }
    } catch (e) {
      print('Error fetching district: $e');
      return await _getFallbackDistrictById(id);
    }
  }
  
  // Yedek ilçe detay yükleme
  Future<District?> _getFallbackDistrictById(String id) async {
    try {
      final response = await _client.get(Uri.parse('$baseUrl/districts/$id'));
      
      if (response.statusCode == 200) {
        return District.fromJson(jsonDecode(response.body));
      } else {
        print('Failed to load fallback district: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching fallback district: $e');
      return null;
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
  
  // Notifications
  Future<List<app_notification.AppNotification>> getNotifications({int? userId, bool unreadOnly = false, int page = 1, int limit = 20}) async {
    // Kullanıcı kimliği
    String url;
    if (userId != null) {
      url = '$baseUrl/api/notifications?user_id=$userId';
    } else {
      url = '$baseUrl/api/notifications';
    }
    
    // Okunmayan bildirimleri filtreleme
    if (unreadOnly) {
      url += '&is_read=0';
    }
    
    // Sayfalama parametreleri
    url += '&page=$page&per_page=$limit';
    
    print('Getting notifications from: $url');
    
    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        
        if (data is Map<String, dynamic> && data.containsKey('data') && data['data'] is List) {
          final List<dynamic> notificationsData = data['data'];
          return notificationsData.map((item) => app_notification.AppNotification.fromJson(item)).toList();
        } 
        else if (data is Map<String, dynamic> && data.containsKey('notifications') && data['notifications'] is List) {
          final List<dynamic> notificationsData = data['notifications'];
          return notificationsData.map((item) => app_notification.AppNotification.fromJson(item)).toList();
        }
        else if (data is List) {
          return data.map((item) => app_notification.AppNotification.fromJson(item)).toList();
        } 
        else {
          print('Unexpected notifications response format: $data');
          return [];
        }
      } else {
        print('Failed to load notifications: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }
  
  Future<bool> markNotificationAsRead(int notificationId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }
    
    final response = await _client.put(
      Uri.parse('$baseUrl/api/notifications/$notificationId/read'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    
    return response.statusCode == 200;
  }
  
  Future<bool> markAllNotificationsAsRead(int userId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }
    
    final response = await _client.put(
      Uri.parse('$baseUrl/api/notifications/mark-all-read'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'user_id': userId}),
    );
    
    return response.statusCode == 200;
  }
  
  // Before-After Records
  Future<List<BeforeAfterRecord>> getBeforeAfterRecords({String? postId, int page = 1, int limit = 20}) async {
    String url = '$baseUrl/api/before_after';
    
    if (postId != null) {
      url += '?post_id=$postId';
    }
    
    // Sayfalama parametreleri
    url += (postId != null ? '&' : '?') + 'page=$page&per_page=$limit';
    
    print('Getting before-after records from: $url');
    
    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        
        if (data is Map<String, dynamic> && data.containsKey('data') && data['data'] is List) {
          final List<dynamic> recordsData = data['data'];
          return recordsData.map((item) => BeforeAfterRecord.fromJson(item)).toList();
        } 
        else if (data is Map<String, dynamic> && data.containsKey('records') && data['records'] is List) {
          final List<dynamic> recordsData = data['records'];
          return recordsData.map((item) => BeforeAfterRecord.fromJson(item)).toList();
        }
        else if (data is List) {
          return data.map((item) => BeforeAfterRecord.fromJson(item)).toList();
        } 
        else {
          print('Unexpected before-after records response format: $data');
          return [];
        }
      } else {
        print('Failed to load before-after records: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching before-after records: $e');
      return [];
    }
  }
  
  // Satisfaction Rating
  Future<int?> getSatisfactionRating(int postId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/api/satisfaction_rating?post_id=$postId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        
        if (data is Map<String, dynamic> && data.containsKey('success') && data['success'] == true) {
          if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
            final postData = data['data'];
            return postData['satisfaction_rating'] as int?;
          }
        }
        return null;
      } else {
        print('Failed to load satisfaction rating: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching satisfaction rating: $e');
      return null;
    }
  }
  
  Future<bool> submitSatisfactionRating(int postId, int rating) async {
    final token = await _getToken();
    
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/satisfaction_rating'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'post_id': postId,
          'rating': rating,
        }),
      );
      
      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        
        if (data is Map<String, dynamic> && data.containsKey('success')) {
          return data['success'] == true;
        }
        return false;
      } else {
        print('Failed to submit satisfaction rating: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error submitting satisfaction rating: $e');
      return false;
    }
  }
}