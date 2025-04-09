import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sikayet_var/models/user.dart';
import 'package:sikayet_var/utils/constants.dart';

class AuthService {
  final String baseUrl = Constants.apiBaseUrl;
  final http.Client _client = http.Client();
  
  // Stream controller for auth state changes
  final StreamController<User?> _authStateController = StreamController<User?>.broadcast();
  Stream<User?> authStateChanges() => _authStateController.stream;
  
  // Login with email and password
  Future<User?> login(String email, String password) async {
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
      ).timeout(Constants.networkTimeout);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['token'];
        final userData = data['user'];
        
        // Save token to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(Constants.tokenKey, token);
        
        // Create user object from JSON
        final user = User.fromJson(userData);
        
        // Update auth state
        _authStateController.add(user);
        
        return user;
      } else {
        final error = json.decode(response.body)['message'] ?? 'Login failed';
        throw Exception(error);
      }
    } catch (e) {
      // For development/demo purposes - create a mock user
      if (e is SocketException || e is HttpException || e is TimeoutException) {
        await Future.delayed(const Duration(seconds: 1));
        final user = _getMockUser();
        
        // Save a mock token to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(Constants.tokenKey, 'mock_token');
        
        // Update auth state
        _authStateController.add(user);
        
        return user;
      }
      throw Exception('Login failed: $e');
    }
  }
  
  // Register a new user
  Future<User?> register(String name, String email, String password, String cityId, String districtId) async {
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
          'city_id': cityId,
          'district_id': districtId,
        }),
      ).timeout(Constants.networkTimeout);
      
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final token = data['token'];
        final userData = data['user'];
        
        // Save token to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(Constants.tokenKey, token);
        
        // Create user object from JSON
        final user = User.fromJson(userData);
        
        // Update auth state
        _authStateController.add(user);
        
        return user;
      } else {
        final error = json.decode(response.body)['message'] ?? 'Registration failed';
        throw Exception(error);
      }
    } catch (e) {
      // For development/demo purposes - create a mock user
      if (e is SocketException || e is HttpException || e is TimeoutException) {
        await Future.delayed(const Duration(seconds: 1));
        final user = User(
          id: 'user_${DateTime.now().millisecondsSinceEpoch}',
          name: name,
          email: email,
          cityId: cityId,
          districtId: districtId,
          roles: ['user'],
          createdAt: DateTime.now(),
          isVerified: false,
        );
        
        // Save a mock token to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(Constants.tokenKey, 'mock_token');
        
        // Update auth state
        _authStateController.add(user);
        
        return user;
      }
      throw Exception('Registration failed: $e');
    }
  }
  
  // Logout
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(Constants.tokenKey);
      
      if (token != null) {
        await _client.post(
          Uri.parse('$baseUrl/auth/logout'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(Constants.networkTimeout);
      }
      
      // Clear token from SharedPreferences
      await prefs.remove(Constants.tokenKey);
      
      // Update auth state
      _authStateController.add(null);
    } catch (e) {
      // Even if API call fails, we want to clear the local token
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(Constants.tokenKey);
      
      // Update auth state
      _authStateController.add(null);
      
      // Only throw if it's not a connectivity issue
      if (!(e is SocketException || e is HttpException || e is TimeoutException)) {
        throw Exception('Logout failed: $e');
      }
    }
  }
  
  // Get current user
  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(Constants.tokenKey);
      
      if (token == null) {
        _authStateController.add(null);
        return null;
      }
      
      final response = await _client.get(
        Uri.parse('$baseUrl/auth/user'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(Constants.networkTimeout);
      
      if (response.statusCode == 200) {
        final userData = json.decode(response.body)['data'];
        final user = User.fromJson(userData);
        
        // Update auth state
        _authStateController.add(user);
        
        return user;
      } else {
        // Token might be invalid
        await prefs.remove(Constants.tokenKey);
        _authStateController.add(null);
        return null;
      }
    } catch (e) {
      // For development/demo purposes
      if (e is SocketException || e is HttpException || e is TimeoutException) {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString(Constants.tokenKey);
        
        if (token != null) {
          await Future.delayed(const Duration(seconds: 1));
          final user = _getMockUser();
          
          // Update auth state
          _authStateController.add(user);
          
          return user;
        }
      }
      
      // If there's an error, we return null but don't throw
      _authStateController.add(null);
      return null;
    }
  }
  
  // Update user profile
  Future<User?> updateProfile(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(Constants.tokenKey);
      
      if (token == null) {
        throw Exception('Not authenticated');
      }
      
      final response = await _client.put(
        Uri.parse('$baseUrl/auth/user'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(user.toJson()),
      ).timeout(Constants.networkTimeout);
      
      if (response.statusCode == 200) {
        final userData = json.decode(response.body)['data'];
        final updatedUser = User.fromJson(userData);
        
        // Update auth state
        _authStateController.add(updatedUser);
        
        return updatedUser;
      } else {
        final error = json.decode(response.body)['message'] ?? 'Profile update failed';
        throw Exception(error);
      }
    } catch (e) {
      // For development/demo purposes
      if (e is SocketException || e is HttpException || e is TimeoutException) {
        await Future.delayed(const Duration(seconds: 1));
        
        // Update auth state
        _authStateController.add(user);
        
        return user;
      }
      throw Exception('Profile update failed: $e');
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
        body: json.encode({'email': email}),
      ).timeout(Constants.networkTimeout);
      
      if (response.statusCode != 200) {
        final error = json.decode(response.body)['message'] ?? 'Password reset failed';
        throw Exception(error);
      }
    } catch (e) {
      // For development/demo purposes
      if (e is SocketException || e is HttpException || e is TimeoutException) {
        await Future.delayed(const Duration(seconds: 1));
        return;
      }
      throw Exception('Password reset failed: $e');
    }
  }
  
  // Mock user for development/demo
  User _getMockUser() {
    return User(
      id: 'user_123',
      name: 'Test User',
      email: 'test@example.com',
      phone: '+90 555 123 4567',
      profilePhotoUrl: 'https://via.placeholder.com/150',
      cityId: 'city_1', // İstanbul
      districtId: 'district_1', // Kadıköy
      roles: ['user'],
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      isVerified: true,
    );
  }
  
  // Dispose
  void dispose() {
    _authStateController.close();
  }
}