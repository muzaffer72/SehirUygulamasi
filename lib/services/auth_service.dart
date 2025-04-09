import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:sikayet_var/models/user.dart';
import 'package:sikayet_var/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
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
        return Exception('Unauthorized: Geçersiz kimlik bilgileri');
      case 403:
        return Exception('Forbidden: Bu işlem için yetkiniz yok');
      case 404:
        return Exception('Not found: İstek yapılan kaynak bulunamadı');
      case 409:
        return Exception('Conflict: Bu e-posta adresi zaten kullanılıyor');
      case 500:
        return Exception('Server error: Sunucu hatası oluştu');
      default:
        return Exception('Unknown error: ${response.statusCode}');
    }
  }
  
  // Login
  Future<User> login(String email, String password) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        // Save token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(Constants.tokenKey, jsonData['token']);
        
        return User.fromJson(jsonData['user']);
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      // For development/demo purposes
      if (e is SocketException || e is HttpException || e is TimeoutException) {
        await Future.delayed(const Duration(seconds: 1));
        
        // Mock successful login
        final user = User(
          id: 'user_123',
          name: 'Ahmet Yılmaz',
          email: email,
          phone: '05551234567',
          profilePhotoUrl: null,
          cityId: 'city_1', // İstanbul
          districtId: 'district_1', // Kadıköy
          isAdmin: false,
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        );
        
        // Save mock token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(Constants.tokenKey, 'mock_token_${DateTime.now().millisecondsSinceEpoch}');
        
        return user;
      }
      
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Giriş yapılırken bir hata oluştu: $e');
    }
  }
  
  // Register
  Future<User> register(String name, String email, String password, {
    String? phone,
    String? cityId,
    String? districtId,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
          'city_id': cityId,
          'district_id': districtId,
        }),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        
        // Save token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(Constants.tokenKey, jsonData['token']);
        
        return User.fromJson(jsonData['user']);
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      // For development/demo purposes
      if (e is SocketException || e is HttpException || e is TimeoutException) {
        await Future.delayed(const Duration(seconds: 1));
        
        // Mock successful registration
        final user = User(
          id: 'user_${DateTime.now().millisecondsSinceEpoch}',
          name: name,
          email: email,
          phone: phone,
          profilePhotoUrl: null,
          cityId: cityId,
          districtId: districtId,
          isAdmin: false,
          createdAt: DateTime.now(),
        );
        
        // Save mock token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(Constants.tokenKey, 'mock_token_${DateTime.now().millisecondsSinceEpoch}');
        
        return user;
      }
      
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Kayıt olurken bir hata oluştu: $e');
    }
  }
  
  // Logout
  Future<void> logout() async {
    try {
      final headers = await _getHeaders();
      await _client.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      // Remove token
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(Constants.tokenKey);
    } catch (e) {
      // Even if the API call fails, we still want to remove the token
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(Constants.tokenKey);
      
      if (e is Exception && e is! SocketException && e is! HttpException && e is! TimeoutException) {
        throw Exception('Çıkış yapılırken bir hata oluştu: $e');
      }
    }
  }
  
  // Get current user
  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(Constants.tokenKey);
      
      if (token == null) {
        return null;
      }
      
      final headers = await _getHeaders();
      final response = await _client.get(
        Uri.parse('$baseUrl/auth/user'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return User.fromJson(jsonData['user']);
      } else if (response.statusCode == 401) {
        // Token is invalid or expired
        await prefs.remove(Constants.tokenKey);
        return null;
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      // For development/demo purposes
      if (e is SocketException || e is HttpException || e is TimeoutException) {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString(Constants.tokenKey);
        
        if (token != null && token.startsWith('mock_token_')) {
          await Future.delayed(const Duration(seconds: 1));
          
          // Return mock user
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
        
        return null;
      }
      
      return null;
    }
  }
  
  // Update profile
  Future<User> updateProfile(User user) async {
    try {
      final headers = await _getHeaders();
      final response = await _client.put(
        Uri.parse('$baseUrl/auth/profile'),
        headers: headers,
        body: json.encode({
          'name': user.name,
          'phone': user.phone,
          'city_id': user.cityId,
          'district_id': user.districtId,
        }),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return User.fromJson(jsonData['user']);
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      // For development/demo purposes
      if (e is SocketException || e is HttpException || e is TimeoutException) {
        await Future.delayed(const Duration(seconds: 1));
        
        // Return updated user
        return user;
      }
      
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Profil güncellenirken bir hata oluştu: $e');
    }
  }
  
  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/auth/reset-password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email,
        }),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode != 200) {
        throw _handleError(response);
      }
    } catch (e) {
      // For development/demo purposes
      if (e is SocketException || e is HttpException || e is TimeoutException) {
        await Future.delayed(const Duration(seconds: 1));
        return;
      }
      
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Şifre sıfırlama işlemi sırasında bir hata oluştu: $e');
    }
  }
  
  // Update password
  Future<void> updatePassword(String currentPassword, String newPassword) async {
    try {
      final headers = await _getHeaders();
      final response = await _client.post(
        Uri.parse('$baseUrl/auth/update-password'),
        headers: headers,
        body: json.encode({
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode != 200) {
        throw _handleError(response);
      }
    } catch (e) {
      // For development/demo purposes
      if (e is SocketException || e is HttpException || e is TimeoutException) {
        await Future.delayed(const Duration(seconds: 1));
        return;
      }
      
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Şifre güncellenirken bir hata oluştu: $e');
    }
  }
}