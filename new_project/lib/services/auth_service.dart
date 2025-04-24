import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/user.dart';

class AuthService {
  final String _tokenKey = 'auth_token';
  final String _userKey = 'user_data';

  // Giriş işlemi
  Future<User> login(String email, String password) async {
    try {
      print('Logging in with: $email');
      
      // Admin panel ile uyumlu giriş isteği yapıyoruz
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.login}'),
        headers: {
          'Content-Type': 'application/json',
          'X-API-KEY': '440bf0009c749943b440f7f5c6c2fd26'
        },
        body: jsonEncode({
          'username': email,  // Email veya kullanıcı adı olarak kullanılabilir
          'password': password,
        }),
      );

      print('Login response: ${response.statusCode}, ${response.body}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        
        // Admin panel yanıt formatı kontrol
        if (responseData.containsKey('success') && responseData['success'] == true) {
          // Admin panel success: true formatı
          final userData = responseData['user'] ?? responseData;
          final user = User.fromJson(userData);
          
          // Save user data to local storage
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_userKey, jsonEncode(user.toJson()));
          
          // Set-Cookie header'ı kullanarak token'ı kaydedin
          // Veya token doğrudan yanıtta geliyorsa onu kullanın
          String token = '';
          if (response.headers.containsKey('set-cookie')) {
            token = response.headers['set-cookie'] ?? '';
          } else if (responseData.containsKey('token')) {
            token = responseData['token'];
          }
          
          await prefs.setString(_tokenKey, token);
          
          return user;
        } else {
          // Doğrudan yanıtın kendisi kullanıcı verisi olabilir
          final user = User.fromJson(responseData);
          
          // Save user data to local storage
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_userKey, jsonEncode(user.toJson()));
          
          // Set-Cookie header'ı kullanarak token'ı kaydedin
          final token = response.headers['set-cookie'] ?? '';
          await prefs.setString(_tokenKey, token);
          
          return user;
        }
      } else {
        throw Exception('Giriş başarısız: ${response.body}');
      }
    } catch (e) {
      print('Login error: $e');
      throw Exception('Giriş işlemi sırasında bir hata oluştu: $e');
    }
  }

  // Kayıt işlemi
  Future<User> register(
    String name,
    String email,
    String password,
    String? cityId,
    String? districtId,
  ) async {
    try {
      print('Registering with: $email, $password');
      
      // Admin panel ile uyumlu kayıt isteği yapıyoruz
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.register}'),
        headers: {
          'Content-Type': 'application/json',
          'X-API-KEY': '440bf0009c749943b440f7f5c6c2fd26'
        },
        body: jsonEncode({
          'name': name,
          'username': email.split('@')[0],  // Email'in @ işaretinden önceki kısmını username olarak kullan
          'email': email,
          'password': password,
          'city_id': cityId, // Zaten string
          'district_id': districtId, // Zaten string
        }),
      );

      print('Register response: ${response.statusCode}, ${response.body}');

      // Başarılı kayıt kodu 201 veya 200 olabilir
      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        
        // Admin panel yanıt formatı kontrol
        User user;
        if (responseData.containsKey('success') && responseData['success'] == true) {
          // Admin panel success: true formatı
          final userData = responseData['user'] ?? responseData;
          user = User.fromJson(userData);
        } else {
          // Doğrudan yanıtın kendisi kullanıcı verisi olabilir
          user = User.fromJson(responseData);
        }

        // Save user data to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userKey, jsonEncode(user.toJson()));
        
        // Token'ı kaydediyoruz
        String token = '';
        if (response.headers.containsKey('set-cookie')) {
          token = response.headers['set-cookie'] ?? '';
        } else if (responseData.containsKey('token')) {
          token = responseData['token'];
        }
        
        await prefs.setString(_tokenKey, token);

        return user;
      } else {
        throw Exception('Kayıt başarısız: ${response.body}');
      }
    } catch (e) {
      print('Registration error: $e');
      throw Exception('Kayıt işlemi sırasında bir hata oluştu: $e');
    }
  }

  // Çıkış işlemi
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);

      await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.logout}'),
        headers: {
          'Content-Type': 'application/json',
          'X-API-KEY': '440bf0009c749943b440f7f5c6c2fd26',
          'Cookie': token ?? '',
        },
      );

      // Yerel depolamadan kullanıcı verilerini temizleme
      await prefs.remove(_userKey);
      await prefs.remove(_tokenKey);
    } catch (e) {
      throw Exception('Çıkış işlemi sırasında bir hata oluştu: $e');
    }
  }

  // Kullanıcının giriş durumunu kontrol etme
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    final token = prefs.getString(_tokenKey);

    return userData != null && token != null;
  }

  // Mevcut kullanıcıyı alma
  Future<User> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_userKey);
      final token = prefs.getString(_tokenKey);

      if (userData == null || token == null) {
        throw Exception('Kullanıcı oturumu bulunamadı');
      }
      
      print('Getting current user with token: ${token.length > 20 ? token.substring(0, 20) : token}...');

      // API'den güncel kullanıcı bilgilerini alalım
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.currentUser}'),
        headers: {
          'Content-Type': 'application/json',
          'X-API-KEY': '440bf0009c749943b440f7f5c6c2fd26',
          'Cookie': token,
          'Authorization': token.startsWith('Bearer ') ? token : 'Bearer $token',
        },
      );
      
      print('Current user response: ${response.statusCode}, ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        // Admin panel yanıt formatı kontrol
        User user;
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('success') && responseData['success'] == true) {
            // Admin panel success: true formatı
            final userData = responseData['user'] ?? responseData;
            user = User.fromJson(userData);
          } else {
            // Doğrudan yanıtın kendisi kullanıcı verisi olabilir
            user = User.fromJson(responseData);
          }
          
          // Güncel kullanıcı bilgilerini kaydedelim
          await prefs.setString(_userKey, jsonEncode(user.toJson()));
          
          return user;
        } else {
          throw Exception('Geçersiz API yanıt formatı');
        }
      } else if (response.statusCode == 401) {
        // Oturum geçersiz, kullanıcıyı çıkış yapmış olarak işaretleyelim
        await logout();
        throw Exception('Oturum süresi dolmuş, lütfen tekrar giriş yapın');
      } else {
        // API'den kullanıcı bilgisi alamazsak, yerel depolamadaki bilgileri kullanalım
        print('Fallback to local user data');
        return User.fromJson(jsonDecode(userData));
      }
    } catch (e) {
      print('Error getting current user: $e');
      throw Exception('Kullanıcı bilgilerini alırken bir hata oluştu: $e');
    }
  }

  // Kullanıcı profil güncelleme
  Future<User> updateProfile(String userId, Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);

      if (token == null) {
        throw Exception('Oturum bulunamadı');
      }

      // String olarak aldığımız userId'yi burada string olarak kullanıyoruz
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.users}/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'X-API-KEY': '440bf0009c749943b440f7f5c6c2fd26',
          'Cookie': token,
        },
        body: jsonEncode(userData),
      );

      print('Update profile response: ${response.statusCode}, ${response.body}');

      if (response.statusCode == 200) {
        final updatedUserData = jsonDecode(response.body);
        final user = User.fromJson(updatedUserData);

        // Güncel kullanıcı bilgilerini kaydedelim
        await prefs.setString(_userKey, jsonEncode(user.toJson()));
        
        return user;
      } else {
        throw Exception('Profil güncelleme başarısız: ${response.body}');
      }
    } catch (e) {
      print('Update profile error: $e');
      throw Exception('Profil güncelleme işlemi sırasında bir hata oluştu: $e');
    }
  }
}