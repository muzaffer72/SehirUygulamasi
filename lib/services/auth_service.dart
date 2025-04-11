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
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.login}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': email,  // Laravel admin panel username olarak bekliyor
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        final user = User.fromJson(userData);

        // Save user data to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userKey, jsonEncode(user.toJson()));
        await prefs.setString(_tokenKey, response.headers['set-cookie'] ?? '');

        return user;
      } else {
        throw Exception('Giriş başarısız: ${response.body}');
      }
    } catch (e) {
      throw Exception('Giriş işlemi sırasında bir hata oluştu: $e');
    }
  }

  // Kayıt işlemi
  Future<User> register(
    String name,
    String email,
    String password,
    int? cityId,
    int? districtId,
  ) async {
    try {
      print('Registering with: $email, $password');
      
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.register}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'username': email,  // Laravel admin panelde username olarak bekliyor
          'email': email,
          'password': password,
          'city_id': cityId != null ? cityId.toString() : null, // String olarak gönder
          'district_id': districtId != null ? districtId.toString() : null, // String olarak gönder
        }),
      );

      print('Register response: ${response.statusCode}, ${response.body}');

      if (response.statusCode == 201) {
        final userData = jsonDecode(response.body);
        final user = User.fromJson(userData);

        // Save user data to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userKey, jsonEncode(user.toJson()));
        await prefs.setString(_tokenKey, response.headers['set-cookie'] ?? '');

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

      // API'den güncel kullanıcı bilgilerini alalım
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.currentUser}'),
        headers: {
          'Content-Type': 'application/json',
          'Cookie': token,
        },
      );

      if (response.statusCode == 200) {
        final updatedUserData = jsonDecode(response.body);
        final user = User.fromJson(updatedUserData);

        // Güncel kullanıcı bilgilerini kaydedelim
        await prefs.setString(_userKey, jsonEncode(user.toJson()));
        
        return user;
      } else {
        // API'den kullanıcı bilgisi alamazsak, yerel depolamadaki bilgileri kullanalım
        return User.fromJson(jsonDecode(userData));
      }
    } catch (e) {
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