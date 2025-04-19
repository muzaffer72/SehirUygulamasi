import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:belediye_iletisim_merkezi/models/post.dart';
import 'package:belediye_iletisim_merkezi/models/user.dart';
import 'package:belediye_iletisim_merkezi/models/survey.dart';
import 'package:belediye_iletisim_merkezi/models/notification_model.dart';
import 'package:belediye_iletisim_merkezi/models/city.dart';
import 'package:belediye_iletisim_merkezi/models/city_profile.dart';
import 'package:belediye_iletisim_merkezi/models/district.dart';
import 'package:belediye_iletisim_merkezi/models/category.dart';
import 'package:belediye_iletisim_merkezi/models/comment.dart';
import 'package:belediye_iletisim_merkezi/utils/api_helper.dart';
import 'package:belediye_iletisim_merkezi/utils/api_key_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl = ApiHelper.getBaseUrl();
  final String apiPath = '/api.php';
  
  // HTTP istek başlıklarını hazırla (token varsa ekleyerek)
  Future<Map<String, String>> _getHeaders() async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    // Kayıtlı token'ı al
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    // Token varsa, Authorization header'ına ekle
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    // NOT: Artık API anahtarı header yerine URL'de gönderilecek
    
    return headers;
  }
  
  // URL'ye API anahtarını ekle
  Future<String> _appendApiKeyToUrl(String url) async {
    return ApiKeyManager.appendApiKeyToUrl(url);
  }

  // API'den alınan hata mesajını işle
  String _handleErrorResponse(http.Response response) {
    try {
      // UTF-8 karakter kodlamasıyla decode et
      final decodedResponse = json.decode(utf8.decode(response.bodyBytes));
      return decodedResponse['message'] ?? 'Bilinmeyen hata: ${response.statusCode}';
    } catch (e) {
      return 'Bilinmeyen hata: ${response.statusCode}';
    }
  }
  
  // JSON yanıtını doğru şekilde decode et (Türkçe karakterler için)
  dynamic _decodeResponse(http.Response response) {
    try {
      // Türkçe karakterler için UTF-8 decode kullan
      return json.decode(utf8.decode(response.bodyBytes));
    } catch (e) {
      // Hata durumunda ham string döndür
      return response.body;
    }
  }

  // Giriş yap
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl$apiPath/login');
    final response = await http.post(
      url,
      headers: await _getHeaders(),
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );
    
    if (response.statusCode == 200) {
      return _decodeResponse(response);
    } else {
      throw Exception(_handleErrorResponse(response));
    }
  }
  
  // Kayıt ol
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    required int cityId,
    String? districtId,
  }) async {
    final url = Uri.parse('$baseUrl$apiPath/register');
    final response = await http.post(
      url,
      headers: await _getHeaders(),
      body: json.encode({
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'city_id': cityId,
        'district_id': districtId,
      }),
    );
    
    if (response.statusCode == 201) {
      return _decodeResponse(response);
    } else {
      throw Exception(_handleErrorResponse(response));
    }
  }
  
  // Çıkış yap
  Future<void> logout() async {
    final url = Uri.parse('$baseUrl$apiPath/logout');
    final response = await http.post(
      url,
      headers: await _getHeaders(),
    );
    
    if (response.statusCode != 200) {
      throw Exception(_handleErrorResponse(response));
    }
  }
  
  // Mevcut kullanıcı bilgilerini getir
  Future<User?> getCurrentUser() async {
    final url = Uri.parse('$baseUrl$apiPath/user');
    final response = await http.get(
      url,
      headers: await _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      final data = _decodeResponse(response);
      return User.fromJson(data);
    } else if (response.statusCode == 401) {
      return null; // Token geçersiz veya oturum süresi dolmuş
    } else {
      throw Exception(_handleErrorResponse(response));
    }
  }
  
  // Kullanıcı profili güncelleme
  Future<Map<String, dynamic>> updateProfile({
    required int userId,
    String? name,
    String? username,
    String? bio,
    String? email,
    String? phone,
    String? profileImageUrl,
    String? coverImageUrl,
    int? cityId,
    String? districtId,
  }) async {
    final url = Uri.parse('$baseUrl$apiPath/users/$userId');
    final response = await http.put(
      url,
      headers: await _getHeaders(),
      body: json.encode({
        'name': name,
        'username': username,
        'bio': bio,
        'email': email,
        'phone': phone,
        'profile_image_url': profileImageUrl,
        'cover_image_url': coverImageUrl,
        'city_id': cityId,
        'district_id': districtId,
      }),
    );
    
    if (response.statusCode == 200) {
      final data = _decodeResponse(response);
      return data;
    } else {
      throw Exception(_handleErrorResponse(response));
    }
  }
  
  // UserProvider için eski API uyumluluğu
  Future<Map<String, dynamic>> updateUserProfile({
    required int userId,
    String? name,
    String? username,
    String? bio,
    String? email, 
    String? phone,
    String? profileImageUrl,
    String? coverImageUrl,
  }) async {
    return updateProfile(
      userId: userId,
      name: name,
      username: username,
      bio: bio,
      email: email,
      phone: phone,
      profileImageUrl: profileImageUrl,
      coverImageUrl: coverImageUrl,
    );
  }
  
  // Kullanıcı konum bilgilerini güncelleme
  Future<Map<String, dynamic>> updateUserLocation({
    required int userId,
    required int cityId,
    String? districtId,
  }) async {
    return updateProfile(
      userId: userId,
      cityId: cityId,
      districtId: districtId,
    );
  }
  
  // Şehir listesini getir
  Future<List<City>> getCitiesAsObjects() async {
    // API anahtarını URL'ye ekleyen Uri.parse kullanımı
    final uriString = await _appendApiKeyToUrl('$baseUrl$apiPath?endpoint=cities');
    final uri = Uri.parse(uriString);
    
    final response = await http.get(
      uri,
      headers: await _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      final data = _decodeResponse(response);
      List<dynamic> citiesJson = [];
      
      if (data is Map && data.containsKey('data')) {
        citiesJson = data['data'] as List<dynamic>;
      } else if (data is List) {
        citiesJson = data;
      }
      
      return citiesJson.map((json) => City.fromJson(json)).toList();
    } else {
      throw Exception(_handleErrorResponse(response));
    }
  }
  
  // Belirli bir şehre ait ilçeleri getir
  Future<List<District>> getDistrictsByCityIdAsObjects(String cityId) async {
    // API anahtarını URL'ye ekleyen _appendApiKeyToUrl kullanımı
    final uriString = await _appendApiKeyToUrl('$baseUrl$apiPath?endpoint=districts&city_id=$cityId');
    final uri = Uri.parse(uriString);
    
    final response = await http.get(
      uri,
      headers: await _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      final data = _decodeResponse(response);
      List<dynamic> districtsJson = [];
      
      if (data is Map && data.containsKey('data')) {
        districtsJson = data['data'] as List<dynamic>;
      } else if (data is Map && data.containsKey('status') && data.containsKey('data')) {
        districtsJson = data['data'] as List<dynamic>;
      } else if (data is List) {
        districtsJson = data;
      }
      
      return districtsJson.map((json) => District.fromJson(json)).toList();
    } else {
      throw Exception(_handleErrorResponse(response));
    }
  }
  
  // Post listesini getir
  Future<List<Post>> getPosts({
    int page = 1,
    int limit = 10,
    String? cityId,
    String? districtId,
    String? categoryId,
    String? sortBy,
    String? userId,
    String? status,
    PostType? postType,
  }) async {
    try {
      // URL parametrelerini oluştur
      String url = '$baseUrl$apiPath?endpoint=posts';
      url += '&page=$page';
      url += '&per_page=$limit'; // limit yerine per_page parametresi kullanılıyor
      
      if (cityId != null) url += '&city_id=$cityId';
      if (districtId != null) url += '&district_id=$districtId';
      if (categoryId != null) url += '&category_id=$categoryId';
      if (sortBy != null) url += '&sort_by=$sortBy';
      if (userId != null) url += '&user_id=$userId';
      if (status != null) url += '&status=$status';
      if (postType != null) url += '&type=${postType == PostType.problem ? 'problem' : 'general'}';
      
      // API anahtarını URL'ye ekleyen _appendApiKeyToUrl kullanımı
      final uriString = await _appendApiKeyToUrl(url);
      final uri = Uri.parse(uriString);
      
      print('Fetching posts from: $uri');
      final response = await http.get(
        uri,
        headers: await _getHeaders(),
      );
      
      print('API response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final dynamic data = _decodeResponse(response);
        print('API response body: ${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}...');
        
        // Farklı API yanıt formatlarını kontrol et ve uygun şekilde işle
        if (data == null) {
          print('API returned null data');
          return [];
        }
        
        List<dynamic> postsJson = [];
        
        // API return format: { posts: [...], pagination: {...} }
        if (data is Map<String, dynamic> && data.containsKey('posts')) {
          postsJson = data['posts'] as List<dynamic>;
        } 
        // API return format: { data: [...] }
        else if (data is Map<String, dynamic> && data.containsKey('data')) {
          postsJson = data['data'] as List<dynamic>;
        }
        // API return format: { status: "success", data: [...] }
        else if (data is Map<String, dynamic> && data.containsKey('status') && data.containsKey('data')) {
          postsJson = data['data'] as List<dynamic>;
        }
        // API return format: [...]
        else if (data is List) {
          postsJson = data;
        }
        
        final posts = postsJson.map((json) => Post.fromJson(json)).toList();
        print('Parsed ${posts.length} posts successfully');
        return posts;
      } else {
        print('API error: ${response.body}');
        throw Exception(_handleErrorResponse(response));
      }
    } catch (e) {
      print('Exception in getPosts: $e');
      rethrow; // Hatayı tekrar fırlat (daha fazla bilgi için)
    }
  }
  
  // Post detayını getir
  Future<Post> getPostById(String postId) async {
    // API anahtarını URL'ye ekleyen _appendApiKeyToUrl kullanımı
    final uriString = await _appendApiKeyToUrl('$baseUrl$apiPath?endpoint=post_detail&post_id=$postId');
    final uri = Uri.parse(uriString);
    
    final response = await http.get(
      uri,
      headers: await _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      final data = _decodeResponse(response);
      if (data is Map && data.containsKey('data')) {
        return Post.fromJson(data['data']);
      } else if (data is Map && data.containsKey('status') && data.containsKey('data')) {
        return Post.fromJson(data['data']);
      } else {
        return Post.fromJson(data);
      }
    } else {
      throw Exception(_handleErrorResponse(response));
    }
  }
  
  // Kullanıcıya göre bildirimleri getir
  Future<List<NotificationModel>> getNotificationsByUserId(int userId) async {
    // API anahtarını URL'ye ekleyen _appendApiKeyToUrl kullanımı
    final uriString = await _appendApiKeyToUrl('$baseUrl$apiPath?endpoint=user_notifications&user_id=$userId');
    final uri = Uri.parse(uriString);
    
    final response = await http.get(
      uri,
      headers: await _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      final data = _decodeResponse(response);
      final List<dynamic> notificationsJson = data['data'] ?? [];
      return notificationsJson
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } else {
      throw Exception(_handleErrorResponse(response));
    }
  }
  
  // Bildirimi okundu olarak işaretle
  Future<void> markNotificationAsRead(String notificationId, int userId) async {
    // API anahtarını URL'ye ekle
    final uriString = await _appendApiKeyToUrl('$baseUrl$apiPath?endpoint=mark_notification_read&notification_id=$notificationId&user_id=$userId');
    final uri = Uri.parse(uriString);
    final response = await http.put(
      uri,
      headers: await _getHeaders(),
    );
    
    if (response.statusCode != 200) {
      throw Exception(_handleErrorResponse(response));
    }
  }
  
  // Tüm bildirimleri okundu olarak işaretle
  Future<void> markAllNotificationsAsRead(int userId) async {
    final url = Uri.parse('$baseUrl$apiPath/users/$userId/notifications/read-all');
    final response = await http.put(
      url,
      headers: await _getHeaders(),
    );
    
    if (response.statusCode != 200) {
      throw Exception(_handleErrorResponse(response));
    }
  }
  
  // Aktif anketleri getir
  Future<List<Survey>> getActiveSurveys() async {
    final url = Uri.parse('$baseUrl$apiPath/surveys?status=active');
    final response = await http.get(
      url,
      headers: await _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      final data = _decodeResponse(response);
      final List<dynamic> surveysJson = data['data'] ?? [];
      return surveysJson.map((json) => Survey.fromJson(json)).toList();
    } else {
      throw Exception(_handleErrorResponse(response));
    }
  }
  
  // Aktif anketleri tipine göre getir (city veya district)
  Future<List<Survey>> getActiveSurveysByType(String type) async {
    String param = '';
    
    if (type == 'city') {
      param = 'has_city=1&has_district=0';
    } else if (type == 'district') {
      param = 'has_district=1';
    }
    
    final url = Uri.parse('$baseUrl$apiPath/surveys?status=active&$param');
    final response = await http.get(
      url,
      headers: await _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> surveysJson = data['data'] ?? [];
      return surveysJson.map((json) => Survey.fromJson(json)).toList();
    } else {
      throw Exception(_handleErrorResponse(response));
    }
  }

  // Şehir anketlerini getir
  Future<List<Survey>> getCitySurveys(String cityId) async {
    final url = Uri.parse('$baseUrl$apiPath/surveys?city_id=$cityId');
    final response = await http.get(
      url,
      headers: await _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> surveysJson = data['data'] ?? [];
      return surveysJson.map((json) => Survey.fromJson(json)).toList();
    } else {
      throw Exception(_handleErrorResponse(response));
    }
  }
  
  // İlçe anketlerini getir
  Future<List<Survey>> getDistrictSurveys(String districtId) async {
    final url = Uri.parse('$baseUrl$apiPath/surveys?district_id=$districtId');
    final response = await http.get(
      url,
      headers: await _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> surveysJson = data['data'] ?? [];
      return surveysJson.map((json) => Survey.fromJson(json)).toList();
    } else {
      throw Exception(_handleErrorResponse(response));
    }
  }
  
  // Kategoriler listesini getir
  Future<List<Category>> getCategories() async {
    // API anahtarını URL'ye ekleyen _appendApiKeyToUrl kullanımı
    final uriString = await _appendApiKeyToUrl('$baseUrl$apiPath?endpoint=categories');
    final uri = Uri.parse(uriString);
    
    final response = await http.get(
      uri,
      headers: await _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> categoriesJson = [];
      
      if (data is Map && data.containsKey('data')) {
        categoriesJson = data['data'] as List<dynamic>;
      } else if (data is Map && data.containsKey('status') && data.containsKey('data')) {
        categoriesJson = data['data'] as List<dynamic>;
      } else if (data is List) {
        categoriesJson = data;
      }
      
      return categoriesJson.map((json) => Category.fromJson(json)).toList();
    } else {
      throw Exception(_handleErrorResponse(response));
    }
  }
  
  // Kategori detayını getir
  Future<Category?> getCategoryById(String categoryId) async {
    final url = Uri.parse('$baseUrl$apiPath/categories/$categoryId');
    final response = await http.get(
      url,
      headers: await _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['data'] == null) return null;
      return Category.fromJson(data['data']);
    } else {
      throw Exception(_handleErrorResponse(response));
    }
  }
  
  // Şehir ismi getir
  Future<String?> getCityNameById(String cityId) async {
    try {
      final city = await getCityById(cityId);
      return city?.name ?? 'Bilinmeyen Şehir';
    } catch (e) {
      print('Error in getCityNameById: $e');
      return 'Bilinmeyen Şehir';
    }
  }
  
  // Şehir detayını getir
  Future<City?> getCityById(String cityId) async {
    // API anahtarını URL'ye ekle
    final uriString = await _appendApiKeyToUrl('$baseUrl$apiPath?endpoint=cities&id=$cityId');
    final uri = Uri.parse(uriString);
    
    final response = await http.get(
      uri,
      headers: await _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['data'] == null) return null;
      return City.fromJson(data['data']);
    } else {
      throw Exception(_handleErrorResponse(response));
    }
  }
  
  // İlçe detayını getir
  Future<District?> getDistrictById(String districtId) async {
    try {
      // API anahtarını URL'ye ekle
      final uriString = await _appendApiKeyToUrl('$baseUrl$apiPath?endpoint=districts&id=$districtId');
      final uri = Uri.parse(uriString);
      
      final response = await http.get(
        uri,
        headers: await _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] == null) return null;
        return District.fromJson(data['data']);
      } else {
        print('Error in getDistrictById: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception in getDistrictById: $e');
      return null;
    }
  }
  
  // Filtrelenmiş gönderileri getir
  Future<List<Post>> getFilteredPosts(Map<String, dynamic> filterParams) async {
    // Query parametrelerini oluştur
    final queryParams = <String, String>{};
    
    filterParams.forEach((key, value) {
      if (value != null) {
        queryParams[key] = value.toString();
      }
    });
    
    final uri = Uri.parse('$baseUrl$apiPath/posts').replace(
      queryParameters: queryParams,
    );
    
    final response = await http.get(
      uri,
      headers: await _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> postsJson = data['data'] ?? [];
      return postsJson.map((json) => Post.fromJson(json)).toList();
    } else {
      throw Exception(_handleErrorResponse(response));
    }
  }
  
  // Yorumları getir
  Future<List<Comment>> getCommentsByPostId(String postId) async {
    final url = Uri.parse('$baseUrl$apiPath/posts/$postId/comments');
    final response = await http.get(
      url,
      headers: await _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> commentsJson = data['data'] ?? [];
      return commentsJson.map((json) => Comment.fromJson(json)).toList();
    } else {
      throw Exception(_handleErrorResponse(response));
    }
  }
  
  // Yorum ekle
  Future<Comment> addComment({
    required String postId, 
    required String content,
    String? parentId
  }) async {
    final url = Uri.parse('$baseUrl$apiPath/posts/$postId/comments');
    final response = await http.post(
      url,
      headers: await _getHeaders(),
      body: json.encode({
        'content': content,
        'parent_id': parentId,
      }),
    );
    
    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return Comment.fromJson(data['data']);
    } else {
      throw Exception(_handleErrorResponse(response));
    }
  }
  
  // Gönderiyi öne çıkar
  Future<void> highlightPost(String postId) async {
    try {
      final url = Uri.parse('$baseUrl$apiPath/posts/$postId/highlight');
      final response = await http.post(
        url,
        headers: await _getHeaders(),
      );
      
      if (response.statusCode != 200) {
        print('Öne çıkarma API hatası: ${response.statusCode} - ${response.body}');
        // Uygulamanın çalışmaya devam etmesi için hata fırlatmıyoruz
      }
    } catch (e) {
      // Hata için log tutuyoruz ama uygulamanın çalışmasını engellemiyoruz
      print('Post öne çıkarma hatası: $e');
    }
  }
  
  // Şehir profil bilgilerini getir
  Future<CityProfile?> getCityProfileById(String cityId) async {
    try {
      // API anahtarını URL'ye ekle
      final uriString = await _appendApiKeyToUrl('$baseUrl$apiPath?endpoint=city_profile&city_id=$cityId');
      final uri = Uri.parse(uriString);
      
      final response = await http.get(
        uri,
        headers: await _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] == null) return null;
        return CityProfile.fromJson(data['data']);
      } else {
        print('Error in getCityProfileById: ${response.statusCode} - ${response.body}');
        // Şehir bilgilerini getir, profil bulunamazsa
        final city = await getCityById(cityId);
        if (city != null) {
          // City'den CityProfile oluştur
          return CityProfile(
            id: city.id,
            cityId: city.id,
            name: city.name,
            description: city.description,
            logoUrl: city.logoUrl,
            contactPhone: city.contactPhone,
            contactEmail: city.contactEmail,
            totalComplaints: 0,
            solvedComplaints: 0, 
            activeComplaints: 0,
            satisfactionRate: 0,
            responseRate: 0,
            problemSolvingRate: 0,
            averageResponseTime: 0,
            solutionRate: -0.0
          );
        }
        return null;
      }
    } catch (e) {
      print('Exception in getCityProfileById: $e');
      return null;
    }
  }
  
  // Eski API ile uyumluluk için
  Future<CityProfile?> getCityProfile(dynamic cityId) async {
    // String'e dönüştür
    final cityIdStr = cityId.toString();
    return await getCityProfileById(cityIdStr);
  }
  
  // Eski API uyumluluğu için getCities metodu
  // getCitiesAsObjects metodunu kullanarak city objelerini alır
  Future<List<City>> getCities() async {
    try {
      // Obje listesini al
      final cities = await getCitiesAsObjects();
      return cities;
    } catch (e) {
      print('Error in getCities: $e');
      return [];
    }
  }
  
  // İlçeleri şehire göre filtreleme (eski API uyumluluğu)
  // getDistrictsByCityIdAsObjects metodunu kullanarak district objelerini alır
  Future<List<District>> getDistrictsByCityId(String cityId) async {
    try {
      // Obje listesini al 
      final districts = await getDistrictsByCityIdAsObjects(cityId);
      return districts;
    } catch (e) {
      print('Error in getDistrictsByCityId: $e');
      return [];
    }
  }
  
  // Kullanıcı bilgisini getir
  Future<User?> getUserById(int userId) async {
    try {
      // API anahtarını URL'ye ekle
      final uriString = await _appendApiKeyToUrl('$baseUrl$apiPath?endpoint=users&id=$userId');
      final uri = Uri.parse(uriString);
      
      final response = await http.get(
        uri,
        headers: await _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        try {
          // Türkçe karakter desteği için UTF-8 decode kullan
          final data = _decodeResponse(response);
          if (data == null) return null;
          
          // API yanıt formatlarına göre işlem yap
          if (data is Map<String, dynamic>) {
            if (data.containsKey('data')) {
              final userData = data['data'];
              if (userData is Map<String, dynamic>) {
                return User.fromJson(userData);
              }
            } else {
              return User.fromJson(data as Map<String, dynamic>);
            }
          } else if (data is List && data.isNotEmpty) {
            final firstItem = data[0];
            if (firstItem is Map<String, dynamic>) {
              return User.fromJson(firstItem);
            }
          }
          
          print('Unexpected data format in getUserById: $data');
          return null;
        } catch (formatError) {
          print('Data format error in getUserById: $formatError');
          return null;
        }
      } else {
        print('Error in getUserById: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception in getUserById: $e');
      return null;
    }
  }
  
  // Memnuniyet puanı ekle
  // Eski metod. Yeni projelerde submitSatisfaction kullanın.
  @Deprecated('Use submitSatisfaction instead')
  Future<bool> submitSatisfactionRating(String postId, int rating, {String? comment}) async {
    // Yeni metoda yönlendir
    return submitSatisfaction(
      postId: postId,
      rating: rating,
      comment: comment,
    );
  }
  
  // Kullanıcının anketteki oyunu getir
  Future<Map<String, dynamic>?> getUserSurveyVote(
    String surveyId,
    int userId,
  ) async {
    try {
      // API anahtarını URL'ye ekle
      final uriString = await _appendApiKeyToUrl('$baseUrl$apiPath?endpoint=get_survey_vote&survey_id=$surveyId&user_id=$userId');
      final uri = Uri.parse(uriString);
      
      final response = await http.get(
        uri,
        headers: await _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        try {
          // Türkçe karakter desteği için UTF-8 decode kullan
          final data = _decodeResponse(response);
          if (data == null) return null;
          
          // API yanıt formatlarına göre işlem yap
          if (data is Map<String, dynamic> && data.containsKey('data')) {
            final voteData = data['data'];
            if (voteData is Map<String, dynamic>) {
              return voteData;
            }
          } else if (data is Map<String, dynamic>) {
            return data;
          }
          
          // API yanıt formatından emin olamıyorsak tip dönüşümünü elle yapalım
          if (data is Map) {
            Map<String, dynamic> safeMap = {};
            data.forEach((key, value) {
              if (key is String) {
                safeMap[key] = value;
              }
            });
            
            if (safeMap.containsKey('data') && safeMap['data'] is Map) {
              final voteMap = safeMap['data'] as Map;
              Map<String, dynamic> safeVoteMap = {};
              voteMap.forEach((key, value) {
                if (key is String) {
                  safeVoteMap[key] = value;
                }
              });
              return safeVoteMap;
            }
            
            return safeMap;
          }
          
          print('Unexpected data format in getUserSurveyVote: $data');
          return null;
        } catch (formatError) {
          print('Data format error in getUserSurveyVote: $formatError');
          return null;
        }
      } else if (response.statusCode == 404) {
        return null; // Oy bulunamadı
      } else {
        throw Exception(_handleErrorResponse(response));
      }
    } catch (e) {
      print('Error in getUserSurveyVote: $e');
      return null;
    }
  }
  
  // Ankete oy ver
  Future<void> voteSurvey({
    required String surveyId,
    required String optionId,
    required int userId,
  }) async {
    try {
      // API anahtarını URL'ye ekle
      final uriString = await _appendApiKeyToUrl('$baseUrl$apiPath?endpoint=vote_survey&survey_id=$surveyId&option_id=$optionId&user_id=$userId');
      final uri = Uri.parse(uriString);
      
      final response = await http.post(
        uri,
        headers: await _getHeaders(),
      );
      
      if (response.statusCode != 200) {
        print('Anket oy verme API hatası: ${response.statusCode} - ${response.body}');
        throw Exception(_handleErrorResponse(response));
      }
    } catch (e) {
      print('Error in voteSurvey: $e');
      rethrow;
    }
  }
  
  // Post oluştur
  Future<Post> createPost({
    required String title,
    required String content,
    required String cityId,
    String? districtId,
    String? categoryId,
    List<String>? imageUrls,
    Map<String, double>? location,
    String? status,
    bool anonymous = false,
  }) async {
    try {
      // API anahtarını URL'ye ekle
      final uriString = await _appendApiKeyToUrl('$baseUrl$apiPath?endpoint=create_post');
      final uri = Uri.parse(uriString);
      
      final Map<String, dynamic> postData = {
        'title': title,
        'content': content,
        'city_id': cityId,
      };
      
      if (districtId != null) postData['district_id'] = districtId;
      if (categoryId != null) postData['category_id'] = categoryId;
      if (imageUrls != null) postData['image_urls'] = imageUrls;
      if (location != null) postData['location'] = location;
      if (status != null) postData['status'] = status;
      postData['anonymous'] = anonymous;
      
      final response = await http.post(
        uri,
        headers: await _getHeaders(),
        body: json.encode(postData),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = _decodeResponse(response);
        
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          final postData = data['data'];
          if (postData is Map<String, dynamic>) {
            return Post.fromJson(postData);
          }
        } else if (data is Map<String, dynamic>) {
          return Post.fromJson(data);
        }
        
        // Bu kısma ulaşırsa, API yanıt formatından emin olamıyoruz
        // Tip dönüşümünü elle yapalım
        if (data is Map) {
          Map<String, dynamic> safeMap = {};
          data.forEach((key, value) {
            if (key is String) {
              safeMap[key] = value;
            }
          });
          
          if (safeMap.containsKey('data') && safeMap['data'] is Map) {
            final postMap = safeMap['data'] as Map;
            Map<String, dynamic> safePostMap = {};
            postMap.forEach((key, value) {
              if (key is String) {
                safePostMap[key] = value;
              }
            });
            return Post.fromJson(safePostMap);
          }
          
          return Post.fromJson(safeMap);
        }
        
        throw Exception('Invalid API response format');
      } else {
        throw Exception(_handleErrorResponse(response));
      }
    } catch (e) {
      print('Error in createPost: $e');
      rethrow;
    }
  }
  
  // Post güncelle
  Future<Post> updatePost({
    required String postId,
    String? title,
    String? content,
    String? categoryId,
    List<String>? imageUrls,
    String? status,
  }) async {
    try {
      // API anahtarını URL'ye ekle
      final uriString = await _appendApiKeyToUrl('$baseUrl$apiPath?endpoint=update_post&post_id=$postId');
      final uri = Uri.parse(uriString);
      
      final Map<String, dynamic> postData = {};
      if (title != null) postData['title'] = title;
      if (content != null) postData['content'] = content;
      if (categoryId != null) postData['category_id'] = categoryId;
      if (imageUrls != null) postData['image_urls'] = imageUrls;
      if (status != null) postData['status'] = status;
      
      final response = await http.put(
        uri,
        headers: await _getHeaders(),
        body: json.encode(postData),
      );
      
      if (response.statusCode == 200) {
        final data = _decodeResponse(response);
        
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          final postData = data['data'];
          if (postData is Map<String, dynamic>) {
            return Post.fromJson(postData);
          }
        } else if (data is Map<String, dynamic>) {
          return Post.fromJson(data);
        }
        
        // API yanıt formatından emin olamıyorsak tip dönüşümünü elle yapalım
        if (data is Map) {
          Map<String, dynamic> safeMap = {};
          data.forEach((key, value) {
            if (key is String) {
              safeMap[key] = value;
            }
          });
          
          if (safeMap.containsKey('data') && safeMap['data'] is Map) {
            final postMap = safeMap['data'] as Map;
            Map<String, dynamic> safePostMap = {};
            postMap.forEach((key, value) {
              if (key is String) {
                safePostMap[key] = value;
              }
            });
            return Post.fromJson(safePostMap);
          }
          
          return Post.fromJson(safeMap);
        }
        
        throw Exception('Invalid API response format');
      } else {
        throw Exception(_handleErrorResponse(response));
      }
    } catch (e) {
      print('Error in updatePost: $e');
      rethrow;
    }
  }
  
  // Post'u beğen
  Future<void> likePost(String postId) async {
    try {
      // API anahtarını URL'ye ekle
      final uriString = await _appendApiKeyToUrl('$baseUrl$apiPath?endpoint=like_post&post_id=$postId');
      final uri = Uri.parse(uriString);
      
      final response = await http.post(
        uri,
        headers: await _getHeaders(),
      );
      
      if (response.statusCode != 200) {
        print('Beğeni API hatası: ${response.statusCode} - ${response.body}');
        // Uygulamanın çalışmaya devam etmesi için hata fırlatmıyoruz
      }
    } catch (e) {
      // Hata için log tutuyoruz ama uygulamanın çalışmasını engellemiyoruz
      print('Post beğenme hatası: $e');
    }
  }
  
  // Post beğeniyi kaldır
  Future<void> unlikePost(String postId) async {
    try {
      // API anahtarını URL'ye ekle
      final uriString = await _appendApiKeyToUrl('$baseUrl$apiPath?endpoint=unlike_post&post_id=$postId');
      final uri = Uri.parse(uriString);
      
      final response = await http.post(
        uri,
        headers: await _getHeaders(),
      );
      
      if (response.statusCode != 200) {
        print('Beğeni kaldırma API hatası: ${response.statusCode} - ${response.body}');
        // Uygulamanın çalışmaya devam etmesi için hata fırlatmıyoruz
      }
    } catch (e) {
      // Hata için log tutuyoruz ama uygulamanın çalışmasını engellemiyoruz
      print('Post beğeni kaldırma hatası: $e');
    }
  }
  
  // Post'a yorum ekle
  Future<Comment> commentPost({
    required String postId,
    required String content,
    String? parentId,
  }) async {
    try {
      // API anahtarını URL'ye ekle
      final uriString = await _appendApiKeyToUrl('$baseUrl$apiPath?endpoint=add_comment&post_id=$postId');
      final uri = Uri.parse(uriString);
      
      final Map<String, dynamic> commentData = {
        'content': content,
      };
      if (parentId != null) commentData['parent_id'] = parentId;
      
      final response = await http.post(
        uri,
        headers: await _getHeaders(),
        body: json.encode(commentData),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = _decodeResponse(response);
        
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          final commentData = data['data'];
          if (commentData is Map<String, dynamic>) {
            return Comment.fromJson(commentData);
          }
        } else if (data is Map<String, dynamic>) {
          return Comment.fromJson(data);
        }
        
        // API yanıt formatından emin olamıyorsak tip dönüşümünü elle yapalım
        if (data is Map) {
          Map<String, dynamic> safeMap = {};
          data.forEach((key, value) {
            if (key is String) {
              safeMap[key] = value;
            }
          });
          
          if (safeMap.containsKey('data') && safeMap['data'] is Map) {
            final commentMap = safeMap['data'] as Map;
            Map<String, dynamic> safeCommentMap = {};
            commentMap.forEach((key, value) {
              if (key is String) {
                safeCommentMap[key] = value;
              }
            });
            return Comment.fromJson(safeCommentMap);
          }
          
          return Comment.fromJson(safeMap);
        }
        
        throw Exception('Invalid API response format');
      } else {
        throw Exception(_handleErrorResponse(response));
      }
    } catch (e) {
      print('Error in commentPost: $e');
      rethrow;
    }
  }
  
  // Post memnuniyet puanı ekle
  Future<bool> submitSatisfaction({
    required String postId,
    required int rating,
    String? comment,
  }) async {
    try {
      // API anahtarını URL'ye ekle
      final uriString = await _appendApiKeyToUrl('$baseUrl$apiPath?endpoint=submit_satisfaction&post_id=$postId&rating=$rating');
      final uri = Uri.parse(uriString);
      
      final Map<String, dynamic> satisfactionData = {};
      if (comment != null) satisfactionData['comment'] = comment;
      
      final response = await http.post(
        uri,
        headers: await _getHeaders(),
        body: json.encode(satisfactionData),
      );
      
      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error in submitSatisfaction: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception in submitSatisfaction: $e');
      return false;
    }
  }
}