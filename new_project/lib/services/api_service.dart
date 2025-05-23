import 'dart:convert';
import 'dart:io';
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
    try {
      // API anahtarını URL'ye ekleyen _appendApiKeyToUrl kullanımı
      final uriString = await _appendApiKeyToUrl('$baseUrl$apiPath?endpoint=login');
      final uri = Uri.parse(uriString);
      
      print('Giriş denemesi: $uri');
      
      final response = await http.post(
        uri,
        headers: await _getHeaders(),
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );
      
      print('Giriş API yanıtı: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = _decodeResponse(response);
        print('Giriş yanıtı: $data');
        return data;
      } else {
        // API error (geçici erişim sağlayalım)
        print('Giriş hatası: ${response.body}');
        
        // Test/Geliştirme amaçlı giriş izin vermek için geçici çözüm
        // API geliştirildikten sonra bu kısım kaldırılacak
        if (response.statusCode == 404 || response.statusCode == 501) {
          print('Test amaçlı geçici giriş izni sağlanıyor');
          return {
            'success': true,
            'message': 'Test amaçlı giriş başarılı',
            'user': {
              'id': 1,
              'name': email.split('@')[0],
              'email': email,
              'city_id': 34, // İstanbul
              'is_verified': true
            },
            'token': 'test_token'
          };
        }
        
        throw Exception(_handleErrorResponse(response));
      }
    } catch (e) {
      print('Giriş işlemi sırasında hata: $e');
      throw Exception('Giriş yapılamadı: $e');
    }
  }
  
  // Kayıt ol
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? username,
    String? phone,
    required dynamic cityId, // int yerine dynamic olarak güncellendi (String olabilir)
    String? districtId,
  }) async {
    // API anahtarını URL'ye ekleyen _appendApiKeyToUrl kullanımı
    final uriString = await _appendApiKeyToUrl('$baseUrl$apiPath?endpoint=register');
    final uri = Uri.parse(uriString);
    
    // cityId'yi string formatına dönüştür
    final cityIdStr = cityId.toString();
    
    print('Kayıt denemesi: $uri');
    print('Kayıt verileri: name=$name, username=$username, email=$email, cityId=$cityIdStr, districtId=$districtId');
    
    final response = await http.post(
      uri,
      headers: await _getHeaders(),
      body: json.encode({
        'name': name,
        'email': email,
        'username': username, // username eklendi
        'password': password,
        'phone': phone,
        'city_id': cityIdStr, // string olarak gönderildi
        'district_id': districtId,
      }),
    );
    
    print('Kayıt API yanıtı: ${response.statusCode}');
    
    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = _decodeResponse(response);
      print('Kayıt yanıtı: $data');
      return data;
    } else {
      print('Kayıt hatası: ${response.body}');
      throw Exception(_handleErrorResponse(response));
    }
  }
  
  // Çıkış yap
  Future<void> logout() async {
    // API anahtarını URL'ye ekleyen _appendApiKeyToUrl kullanımı
    final uriString = await _appendApiKeyToUrl('$baseUrl$apiPath?endpoint=logout');
    final uri = Uri.parse(uriString);
    
    print('Çıkış yapılıyor: $uri');
    
    final response = await http.post(
      uri,
      headers: await _getHeaders(),
    );
    
    print('Çıkış API yanıtı: ${response.statusCode}');
    
    if (response.statusCode != 200) {
      print('Çıkış hatası: ${response.body}');
      throw Exception(_handleErrorResponse(response));
    }
  }
  
  // Mevcut kullanıcı bilgilerini getir
  Future<User?> getCurrentUser() async {
    // API anahtarını URL'ye ekleyen _appendApiKeyToUrl kullanımı
    final uriString = await _appendApiKeyToUrl('$baseUrl$apiPath?endpoint=current_user');
    final uri = Uri.parse(uriString);
    
    print('Kullanıcı bilgileri alınıyor: $uri');
    
    final response = await http.get(
      uri,
      headers: await _getHeaders(),
    );
    
    print('Kullanıcı API yanıtı: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final data = _decodeResponse(response);
      print('Kullanıcı yanıtı: $data');
      if (data == null) return null;
      
      // API yanıt formatını kontrol et
      if (data is Map<String, dynamic> && data.containsKey('data')) {
        return User.fromJson(data['data']);
      } else if (data is Map<String, dynamic> && data.containsKey('status') && data.containsKey('data')) {
        return User.fromJson(data['data']);
      } else {
        return User.fromJson(data);
      }
    } else if (response.statusCode == 401) {
      print('Kullanıcı yetkilendirme hatası: ${response.body}');
      return null; // Token geçersiz veya oturum süresi dolmuş
    } else {
      print('Kullanıcı bilgi alma hatası: ${response.body}');
      throw Exception(_handleErrorResponse(response));
    }
  }
  
  // Kullanıcı profili güncelleme
  Future<Map<String, dynamic>> updateProfile({
    required dynamic userId,
    String? name,
    String? username,
    String? bio,
    String? email,
    String? phone,
    String? profileImageUrl,
    String? coverImageUrl,
    dynamic cityId,
    String? districtId,
  }) async {
    // ID'leri string formatına dönüştür
    final userIdStr = userId.toString();
    final cityIdStr = cityId != null ? cityId.toString() : null;
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
    required dynamic userId,
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
    required dynamic userId,
    required dynamic cityId,
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
  Future<List<District>> getDistrictsByCityIdAsObjects(dynamic cityId) async {
    // ID'yi string formatına dönüştür 
    final cityIdStr = cityId.toString();
    
    try {
      // API anahtarını URL'ye ekleyen _appendApiKeyToUrl kullanımı
      final uriString = await _appendApiKeyToUrl('$baseUrl$apiPath?endpoint=districts&city_id=$cityId');
      final uri = Uri.parse(uriString);
      
      print('İlçe bilgileri alınıyor: $uri, sehirId: $cityIdStr');
      
      final response = await http.get(
        uri,
        headers: await _getHeaders(),
      );
      
      print('İlçe API yanıtı: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        try {
          final data = _decodeResponse(response);
          print('İlçe yanıtı: $data');
          List<dynamic> districtsJson = [];
          
          // Yeni API yanıt yapısını destekle - tek obje olarak geldiyse listeye ekle
          if (data is Map) {
            if (data.containsKey('data')) {
              final districtData = data['data'];
              if (districtData is List) {
                districtsJson = districtData;
              } else if (districtData is Map) {
                // Tek bir district objesi
                districtsJson = [districtData];
              } else {
                // district değeri bir değer ise dönüştür
                districtsJson = [data]; // Kök objeyi kullan
              }
            } else {
              // data anahtarı yoksa, tüm objeyi kullan
              districtsJson = [data];
            }
          } else if (data is List) {
            // Zaten liste ise kullan
            districtsJson = data;
          }
          
          print('İlçe sayısı: ${districtsJson.length}');
          
          // Eğer hiç ilçe yoksa, varsayılan ilçe oluştur
          if (districtsJson.isEmpty) {
            print('API ilçe verisi döndürmedi, varsayılan ilçeler oluşturuluyor: $cityIdStr');
            // Şehir kimliğine bağlı olarak bazı varsayılan ilçeler döndür
            return [
              District(id: '1', name: 'Merkez', cityId: cityIdStr),
              District(id: '2', name: 'Diğer', cityId: cityIdStr),
            ];
          }
          
          // API'nin döndürdüğü ilçeleri işle
          List<District> districts = [];
          
          for (var json in districtsJson) {
            try {
              if (json is Map) {
                Map<String, dynamic> safeJson = {};
                json.forEach((key, value) {
                  if (key is String) {
                    safeJson[key] = value;
                  }
                });
                
                // Şehir ID'sini kontrol et ve gerekirse güncelle
                if (safeJson.containsKey('city_id')) {
                  var jsonCityId = safeJson['city_id'];
                  if (jsonCityId.toString() != cityIdStr) {
                    print('Ilce icin sehir ID uyumsuzlugu: Beklenen $cityIdStr, API gelen ${jsonCityId.toString()}');
                    // API'nin döndürdüğü şehir ID'sini kullanmak yerine bizim gönderdiğimiz ID'yi kullan
                    safeJson['city_id'] = cityIdStr;
                  }
                } else {
                  // city_id yoksa ekle
                  safeJson['city_id'] = cityIdStr;
                }
                
                // ID kontrolü
                if (!safeJson.containsKey('id') || safeJson['id'] == null) {
                  safeJson['id'] = '${districts.length + 1}'; // Benzersiz ID oluştur
                }
                
                // İlçe adı kontrolü
                if (!safeJson.containsKey('name') || safeJson['name'] == null) {
                  safeJson['name'] = 'İlçe ${districts.length + 1}';
                }
                
                print('District JSON içeriği: $safeJson');
                var district = District.fromJson(safeJson);
                print('District parsed - ID: ${district.id}, Name: ${district.name}, CityID: ${district.cityId}');
                districts.add(district);
              } else {
                print('Geçersiz ilçe verisi: $json');
                districts.add(District(id: '${districts.length + 1}', name: 'Bilinmeyen İlçe', cityId: cityIdStr));
              }
            } catch (e) {
              print('İlçe dönüştürme hatası: $e');
              districts.add(District(id: '${districts.length + 1}', name: 'Hata İlçe', cityId: cityIdStr));
            }
          }
          
          return districts;
        } catch (formatError) {
          print('İlçe verisi format hatası: $formatError');
          return [
            District(id: '1', name: 'Merkez', cityId: cityIdStr),
            District(id: '2', name: 'Format Hatası', cityId: cityIdStr),
          ];
        }
      } else {
        print('İlçe API Hatası: ${response.statusCode} - ${response.body}');
        return [
          District(id: '1', name: 'Merkez', cityId: cityIdStr),
          District(id: '2', name: 'API Hatası', cityId: cityIdStr),
        ];
      }
    } catch (e) {
      print('İlçe veri alma istisnası: $e');
      return [
        District(id: '1', name: 'Merkez', cityId: cityIdStr),
        District(id: '2', name: 'Bağlantı Hatası', cityId: cityIdStr),
      ];
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
    try {
      // API anahtarını URL'ye ekleyen _appendApiKeyToUrl kullanımı
      final uriString = await _appendApiKeyToUrl('$baseUrl$apiPath?endpoint=post_detail&post_id=$postId');
      final uri = Uri.parse(uriString);
      
      print('Fetching post detail from: $uri');
      final response = await http.get(
        uri,
        headers: await _getHeaders(),
      );
      
      print('Post detail API response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = _decodeResponse(response);
        print('Post detail API response: $data');
        
        if (data is Map && data.containsKey('data')) {
          return Post.fromJson(data['data']);
        } else if (data is Map && data.containsKey('status') && data.containsKey('data')) {
          return Post.fromJson(data['data']);
        } else {
          return Post.fromJson(data);
        }
      } else {
        print('Post detail API error: ${response.body}');
        
        // Eğer API post detayını bulamazsa, var olan postu döndür
        // Normalde bu getPosts'tan gelen post verisidir, tam bir detay değildir
        // Bu sadece geçici bir çözümdür
        if (response.statusCode == 404 || response.statusCode == 501) {
          print('Post detayı bulunamadı, mevcut post verisiyle devam ediliyor');
          
          // API'den post listesini alıp aralarından bu ID'ye sahip olanı bulmaya çalış
          final posts = await getPosts(limit: 50);
          final foundPost = posts.firstWhere(
            (post) => post.id == postId,
            orElse: () => Post(
              id: postId,
              title: 'Post detay bilgisi alınamadı',
              content: 'Bu post için detaylı bilgi alınamadı.',
              userId: '0',
              categoryId: '0',
              status: PostStatus.awaitingSolution,
              likes: 0,
              highlights: 0,
              createdAt: DateTime.now(),
            ),
          );
          
          return foundPost;
        }
        
        throw Exception(_handleErrorResponse(response));
      }
    } catch (e) {
      print('Post detayı alınırken hata: $e');
      // Hata durumunda en azından bir post nesnesi döndür
      return Post(
        id: postId,
        title: 'Hata: Post bilgisi yüklenemedi',
        content: 'Post detayı alınırken bir hata oluştu: $e',
        userId: '0',
        categoryId: '0',
        status: PostStatus.awaitingSolution,
        likes: 0,
        highlights: 0,
        createdAt: DateTime.now(),
      );
    }
  }
  
  // Kullanıcıya göre bildirimleri getir
  Future<List<NotificationModel>> getNotificationsByUserId(dynamic userId) async {
    // ID'yi int formatına dönüştürmeye çalış
    final userIdInt = userId is int ? userId : int.tryParse(userId.toString()) ?? 0;
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
  Future<void> markNotificationAsRead(dynamic notificationId, dynamic userId) async {
    // ID'leri string ve int formatına dönüştürmeye çalış
    final notificationIdStr = notificationId.toString();
    final userIdInt = userId is int ? userId : int.tryParse(userId.toString()) ?? 0;
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
  Future<void> markAllNotificationsAsRead(dynamic userId) async {
    // ID'yi int formatına dönüştürmeye çalış
    final userIdInt = userId is int ? userId : int.tryParse(userId.toString()) ?? 0;
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
  Future<List<Survey>> getCitySurveys(dynamic cityId) async {
    // ID'yi string formatına dönüştür
    final cityIdStr = cityId.toString();
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
  Future<List<Survey>> getDistrictSurveys(dynamic districtId) async {
    // ID'yi string formatına dönüştür
    final districtIdStr = districtId.toString();
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
  Future<Category?> getCategoryById(dynamic categoryId) async {
    // ID'yi string formatına dönüştür
    final categoryIdStr = categoryId.toString();
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
  Future<String?> getCityNameById(dynamic cityId) async {
    // ID'yi string formatına dönüştür
    final cityIdStr = cityId.toString();
    try {
      final city = await getCityById(cityId);
      return city?.name ?? 'Bilinmeyen Şehir';
    } catch (e) {
      print('Error in getCityNameById: $e');
      return 'Bilinmeyen Şehir';
    }
  }
  
  // Şehir detayını getir
  Future<City> getCityById(dynamic cityId) async {
    // ID'yi string formatına dönüştür
    final cityIdStr = cityId.toString();
    try {
      // API anahtarını URL'ye ekle
      final uriString = await _appendApiKeyToUrl('$baseUrl$apiPath?endpoint=cities&id=$cityId');
      final uri = Uri.parse(uriString);
      
      print('Fetching city from: $uri');
      final response = await http.get(
        uri,
        headers: await _getHeaders(),
      );
      
      print('City API response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('City API response data: $data');
        
        if (data['data'] != null) {
          return City.fromJson(data['data']);
        } else if (data is Map<String, dynamic>) {
          return City.fromJson(data);
        } else {
          // Geçici olarak varsayılan şehir nesnesi dön
          return City(
            id: cityIdStr,
            name: 'Bilinmeyen Şehir',
            description: '',
            contactPhone: '',
            contactEmail: '',
            logoUrl: '',
          );
        }
      } else {
        print('Error in getCityById: ${response.statusCode} - ${response.body}');
        // Varsayılan şehir nesnesi dön
        return City(
          id: cityIdStr,
          name: 'Şehir Bulunamadı',
          description: '',
          contactPhone: '',
          contactEmail: '',
          logoUrl: '',
        );
      }
    } catch (e) {
      print('Exception in getCityById: $e');
      // Hata durumunda varsayılan şehir nesnesi dön
      return City(
        id: cityIdStr,
        name: 'Hata',
        description: '',
        contactPhone: '',
        contactEmail: '',
        logoUrl: '',
      );
    }
  }
  
  // İlçe detayını getir
  Future<District> getDistrictById(dynamic districtId) async {
    // ID'yi string formatına dönüştür
    final districtIdStr = districtId.toString();
    try {
      // API anahtarını URL'ye ekle
      final uriString = await _appendApiKeyToUrl('$baseUrl$apiPath?endpoint=districts&id=$districtId');
      final uri = Uri.parse(uriString);
      
      print('Fetching district from: $uri');
      final response = await http.get(
        uri,
        headers: await _getHeaders(),
      );
      
      print('District API response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('District API response data: $data');
        
        if (data['data'] != null) {
          return District.fromJson(data['data']);
        } else if (data is Map<String, dynamic>) {
          return District.fromJson(data);
        } else {
          // Varsayılan ilçe nesnesi dön
          return District(
            id: districtIdStr,
            name: 'Bilinmeyen İlçe',
            cityId: '0',
          );
        }
      } else {
        print('Error in getDistrictById: ${response.statusCode} - ${response.body}');
        // Varsayılan ilçe nesnesi dön
        return District(
          id: districtIdStr,
          name: 'İlçe Bulunamadı',
          cityId: '0',
        );
      }
    } catch (e) {
      print('Exception in getDistrictById: $e');
      // Hata durumunda varsayılan ilçe nesnesi dön
      return District(
        id: districtIdStr,
        name: 'Hata',
        cityId: '0',
      );
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
  
  // Yorumları getir - API'ye uygun olarak iyileştirildi
  Future<List<Comment>> getCommentsByPostId(dynamic postId) async {
    // ID'yi string formatına dönüştür
    final postIdStr = postId.toString();
    
    try {
      // API yapısına uygun URL güncellendi
      final uriString = await _appendApiKeyToUrl('$baseUrl$apiPath?endpoint=comments&post_id=$postIdStr');
      final uri = Uri.parse(uriString);
      
      print('Fetching comments from: $uri');
      final response = await http.get(
        uri,
        headers: await _getHeaders(),
      );
      
      print('Comments API response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        try {
          // UTF-8 düzgün decodele
          final data = _decodeResponse(response);
          print('Comments API response data: $data');
          
          if (data == null) {
            print('API returned null data for comments');
            return [];
          }
          
          List<dynamic> commentsJson = [];
          
          if (data is Map<String, dynamic> && data.containsKey('data')) {
            final commentsData = data['data'];
            if (commentsData is List) {
              commentsJson = commentsData;
            } else if (commentsData is Map) {
              print('Received unexpected map for comments data, trying to convert');
              final List<dynamic> convertedList = [];
              commentsData.forEach((key, value) {
                if (value is Map) {
                  convertedList.add(value);
                }
              });
              commentsJson = convertedList;
            }
          } else if (data is List) {
            commentsJson = data;
          } else if (data is Map) {
            // Eğer data bir map ise, içerisindeki herbir value bir yorum olabilir
            final List<dynamic> convertedList = [];
            data.forEach((key, value) {
              if (value is Map) {
                convertedList.add(value);
              }
            });
            commentsJson = convertedList;
          }
          
          print('Parsed ${commentsJson.length} comments');
          final comments = commentsJson.map((json) {
            try {
              if (json is Map) {
                final Map<String, dynamic> safeMap = {};
                json.forEach((key, value) {
                  if (key is String) {
                    safeMap[key] = value;
                  }
                });
                print('Converting comment: $safeMap');
                return Comment.fromJson(safeMap);
              } else {
                print('Invalid comment data: $json');
                throw Exception('Invalid comment format');
              }
            } catch (e) {
              print('Failed to convert comment: $e');
              throw e;
            }
          }).toList();
          
          return comments;
        } catch (formatError) {
          print('Data format error in getCommentsByPostId: $formatError');
          return [];
        }
      } else {
        print('Error in getCommentsByPostId: ${response.statusCode} - ${response.body}');
        return []; // Hata durumunda boş liste döndür
      }
    } catch (e) {
      print('Exception in getCommentsByPostId: $e');
      return []; // Hata durumunda boş liste döndür
    }
  }
  
  // Yorum ekle - API'ye uygun olarak iyileştirildi
  Future<Comment> addComment({
    required dynamic postId, 
    required String content,
    dynamic parentId
  }) async {
    // ID'leri string formatına dönüştür
    final postIdStr = postId.toString();
    final parentIdStr = parentId != null ? parentId.toString() : null;
    
    try {
      // API yapısına uygun URL güncellendi
      final uriString = await _appendApiKeyToUrl('$baseUrl$apiPath?endpoint=comments&action=add&post_id=$postIdStr');
      final uri = Uri.parse(uriString);
      
      // Json içeriğini hazırla
      final Map<String, dynamic> commentData = {
        'content': content,
      };
      
      // Üst yorum varsa ekle
      if (parentId != null) {
        commentData['parent_id'] = parentIdStr;
      }
      
      print('Adding comment via: $uri');
      print('Comment data: $commentData');
      
      final response = await http.post(
        uri,
        headers: await _getHeaders(),
        body: json.encode(commentData),
      );
      
      print('Add comment response status: ${response.statusCode}');
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        try {
          final data = _decodeResponse(response);
          print('Add comment response data: $data');
          
          if (data == null) {
            print('API returned null data for add comment');
            throw Exception('Failed to add comment: Null response data');
          }
          
          Map<String, dynamic> commentJson = {};
          
          if (data is Map<String, dynamic> && data.containsKey('data')) {
            final commentData = data['data'];
            if (commentData is Map<String, dynamic>) {
              commentJson = commentData;
            }
          } else if (data is Map<String, dynamic>) {
            commentJson = data;
          }
          
          if (commentJson.isNotEmpty) {
            // API'den post_id ve user_id'yi alamamış olabiliriz, o durumda kenimiz ekleriz
            if (!commentJson.containsKey('post_id')) {
              commentJson['post_id'] = postIdStr;
            }
            
            if (!commentJson.containsKey('content')) {
              commentJson['content'] = content;
            }
            
            return Comment.fromJson(commentJson);
          }
          
          // Comment objesi oluşturamadıysan basit bir yorum objesi oluştur
          print('Creating basic comment object from API response');
          return Comment(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            postId: postIdStr,
            userId: "0",
            content: content,
            createdAt: DateTime.now(),
          );
        } catch (formatError) {
          print('Data format error in addComment: $formatError');
          throw Exception('Failed to parse comment data: $formatError');
        }
      } else {
        print('Error in addComment: ${response.statusCode} - ${response.body}');
        throw Exception(_handleErrorResponse(response));
      }
    } catch (e) {
      print('Exception in addComment: $e');
      throw Exception('Failed to add comment: $e');
    }
  }
  
  // Gönderiyi öne çıkar
  Future<void> highlightPost(dynamic postId) async {
    // ID'yi string formatına dönüştür
    final postIdStr = postId.toString();
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
  Future<CityProfile?> getCityProfileById(dynamic cityId) async {
    // ID'yi string formatına dönüştür
    final cityIdStr = cityId.toString();
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
          solutionRate: 0.0
        );
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
  Future<List<District>> getDistrictsByCityId(dynamic cityId) async {
    // ID'yi string formatına dönüştür
    final cityIdStr = cityId.toString();
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
  Future<User?> getUserById(dynamic userId) async {
    // ID'yi int formatına dönüştürmeye çalış
    final userIdInt = userId is int ? userId : int.tryParse(userId.toString()) ?? 0;
    try {
      // API anahtarını URL'ye ekle
      // Yeni API yapısına göre endpoint'i güncelleyelim
      final uriString = await _appendApiKeyToUrl('$baseUrl$apiPath?endpoint=users&action=getById&id=$userId');
      final uri = Uri.parse(uriString);
      
      print('Fetching user from: $uri');
      final response = await http.get(
        uri,
        headers: await _getHeaders(),
      );
      
      print('User API response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        try {
          // Türkçe karakter desteği için UTF-8 decode kullan
          final data = _decodeResponse(response);
          print('User API response data: $data');
          
          if (data == null) {
            print('API returned null data for user');
            return _createDefaultUser(userIdInt);
          }
          
          // API yanıt formatlarına göre işlem yap
          if (data is Map<String, dynamic>) {
            if (data.containsKey('data')) {
              final userData = data['data'];
              if (userData is Map<String, dynamic>) {
                return User.fromJson(userData);
              } else if (userData is List && userData.isNotEmpty) {
                final firstItem = userData[0];
                if (firstItem is Map<String, dynamic>) {
                  return User.fromJson(firstItem);
                }
              }
            } else {
              // Direkt map olarak döndüğünde
              return User.fromJson(data);
            }
          } else if (data is List && data.isNotEmpty) {
            final firstItem = data[0];
            if (firstItem is Map<String, dynamic>) {
              return User.fromJson(firstItem);
            }
          }
          
          print('Unexpected data format in getUserById: $data');
          return _createDefaultUser(userIdInt);
        } catch (formatError) {
          print('Data format error in getUserById: $formatError');
          return _createDefaultUser(userIdInt);
        }
      } else {
        print('Error in getUserById: ${response.statusCode} - ${response.body}');
        
        // API error (yapay kullanıcı gönderelim)
        if (response.statusCode == 404 || response.statusCode == 501) {
          print('User not found, creating default user');
          return _createDefaultUser(userIdInt);
        }
        
        return _createDefaultUser(userIdInt);
      }
    } catch (e) {
      print('Exception in getUserById: $e');
      return _createDefaultUser(userIdInt);
    }
  }
  
  // Varsayılan kullanıcı oluştur
  User _createDefaultUser(int userIdInt) {
    return User(
      id: userIdInt,
      name: 'Kullanıcı#$userIdInt',
      email: '',
      profileImageUrl: '',
      cityId: '0', // String olarak değiştirildi
      districtId: '0',
      isVerified: false,
      createdAt: DateTime.now().toString(),
    );
  }
  
  // Memnuniyet puanı ekle
  // Eski metod. Yeni projelerde submitSatisfaction kullanın.
  @Deprecated('Use submitSatisfaction instead')
  Future<bool> submitSatisfactionRating(dynamic postId, int rating, {String? comment}) async {
    // ID'yi string formatına dönüştür
    final postIdStr = postId.toString();
    // Yeni metoda yönlendir
    return submitSatisfaction(
      postId: postId,
      rating: rating,
      comment: comment,
    );
  }
  
  // Kullanıcının anketteki oyunu getir
  Future<Map<String, dynamic>?> getUserSurveyVote(
    dynamic surveyId,
    dynamic userId,
  ) async {
    // ID'leri string ve int formatına dönüştürmeye çalış
    final surveyIdStr = surveyId.toString();
    final userIdInt = userId is int ? userId : int.tryParse(userId.toString()) ?? 0;
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
    required dynamic surveyId,
    required dynamic optionId,
    required dynamic userId,
  }) async {
    // ID'leri string ve int formatına dönüştürmeye çalış
    final surveyIdStr = surveyId.toString();
    final optionIdStr = optionId.toString();
    final userIdInt = userId is int ? userId : int.tryParse(userId.toString()) ?? 0;
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
    required dynamic cityId,
    dynamic districtId,
    dynamic categoryId,
    List<String>? imageUrls,
    Map<String, double>? location,
    String? status,
    bool anonymous = false,
  }) async {
    // ID'leri string formatına dönüştür
    final cityIdStr = cityId.toString();
    final districtIdStr = districtId != null ? districtId.toString() : null;
    final categoryIdStr = categoryId != null ? categoryId.toString() : null;
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
    required dynamic postId,
    String? title,
    String? content,
    dynamic categoryId,
    List<String>? imageUrls,
    String? status,
  }) async {
    // ID'leri string formatına dönüştür
    final postIdStr = postId.toString();
    final categoryIdStr = categoryId != null ? categoryId.toString() : null;
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
  
  // Arama sonuçlarını getirme
  Future<List<Post>> searchPosts({
    required String query,
    String? filter,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      // URL parametrelerini oluştur
      String urlParams = 'endpoint=search&q=${Uri.encodeComponent(query)}&page=$page&limit=$limit';
      
      // Filtre varsa ekle
      if (filter != null && filter.isNotEmpty) {
        urlParams += '&filter=$filter';
      }
      
      // API anahtarını URL'ye ekle
      final uriString = await _appendApiKeyToUrl('$baseUrl$apiPath?$urlParams');
      final uri = Uri.parse(uriString);
      
      print('Arama yapılıyor: $uri');
      
      final response = await http.get(
        uri,
        headers: await _getHeaders(),
      );
      
      print('Arama API yanıtı: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = _decodeResponse(response);
        print('Arama sonuçları: $data');
        
        List<dynamic> postsJson = [];
        
        // API yanıt yapısını kontrol et
        if (data is Map) {
          if (data.containsKey('data')) {
            if (data['data'] is List) {
              postsJson = data['data'];
            } else if (data['data'] is Map && data['data'].containsKey('posts')) {
              postsJson = data['data']['posts'];
            } else {
              postsJson = [data['data']];
            }
          } else if (data.containsKey('posts')) {
            postsJson = data['posts'];
          } else if (data.containsKey('results')) {
            postsJson = data['results'];
          } else {
            postsJson = [data];
          }
        } else if (data is List) {
          postsJson = data;
        }
        
        // API sonuç yoksa boş liste döndür
        if (postsJson.isEmpty) {
          return [];
        }
        
        return postsJson.map((json) => Post.fromJson(json)).toList();
      } else {
        print('Arama hatası: ${response.body}');
        
        // Eğer API geçici olarak kullanılamıyorsa (test amaçlı), getPosts kullanarak bir alternatif sağla
        if (response.statusCode == 404 || response.statusCode == 501) {
          print('API arama desteği yok, getPosts ile arama yapılıyor');
          final allPosts = await getPosts(limit: 50);
          
          // Yerel filtreleme yap
          return allPosts.where((post) {
            return post.title.toLowerCase().contains(query.toLowerCase()) ||
                  post.content.toLowerCase().contains(query.toLowerCase());
          }).toList();
        }
        
        throw Exception(_handleErrorResponse(response));
      }
    } catch (e) {
      print('Arama işlemi sırasında hata: $e');
      
      // Hata durumunda boş liste döndür
      return [];
    }
  }

  // Post'u beğen
  Future<bool> likePost(dynamic postId) async {
    // ID'yi string formatına dönüştür
    final postIdStr = postId.toString();
    try {
      // API anahtarını URL'ye ekle
      final uriString = await _appendApiKeyToUrl('$baseUrl$apiPath?endpoint=like_post&post_id=$postId');
      final uri = Uri.parse(uriString);
      
      print('Gönderi beğeniliyor: $uri');
      
      final response = await http.post(
        uri,
        headers: await _getHeaders(),
      );
      
      print('Beğeni API yanıtı: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('Beğeni API hatası: ${response.statusCode} - ${response.body}');
        // Uygulamanın çalışmaya devam etmesi için hata fırlatmıyoruz
        return false;
      }
    } catch (e) {
      // Hata için log tutuyoruz ama uygulamanın çalışmasını engellemiyoruz
      print('Post beğenme hatası: $e');
      return false;
    }
  }
  
  // Post beğeniyi kaldır
  Future<bool> unlikePost(dynamic postId) async {
    // ID'yi string formatına dönüştür
    final postIdStr = postId.toString();
    try {
      // API anahtarını URL'ye ekle
      final uriString = await _appendApiKeyToUrl('$baseUrl$apiPath?endpoint=unlike_post&post_id=$postId');
      final uri = Uri.parse(uriString);
      
      print('Gönderi beğenisi kaldırılıyor: $uri');
      
      final response = await http.post(
        uri,
        headers: await _getHeaders(),
      );
      
      print('Beğeni kaldırma API yanıtı: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('Beğeni kaldırma API hatası: ${response.statusCode} - ${response.body}');
        // Uygulamanın çalışmaya devam etmesi için hata fırlatmıyoruz
        return false;
      }
    } catch (e) {
      // Hata için log tutuyoruz ama uygulamanın çalışmasını engellemiyoruz
      print('Post beğeni kaldırma hatası: $e');
      return false;
    }
  }
  
  // Post'a yorum ekle
  Future<Comment> commentPost({
    required dynamic postId,
    required String content,
    dynamic parentId,
  }) async {
    // ID'leri string formatına dönüştür
    final postIdStr = postId.toString();
    final parentIdStr = parentId != null ? parentId.toString() : null;
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
    required dynamic postId,
    required int rating,
    String? comment,
  }) async {
    // ID'yi string formatına dönüştür
    final postIdStr = postId.toString();
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