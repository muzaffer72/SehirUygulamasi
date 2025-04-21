import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/auth_state.dart';
import '../services/api_service.dart';
import '../providers/api_service_provider.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences provider has not been initialized');
});

// User provider, AuthNotifier durumunu yayınlar
final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return AuthNotifier(apiService, prefs);
});

// Kullanıcıyı sağlayan provider (eğer oturum açılmışsa)
final userProvider = Provider<User?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.user;
});

// Kullanıcı oturumunun durumunu kontrol eden provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.isLoggedIn;
});

// Auth işlemlerini yöneten StateNotifier
class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService;
  final SharedPreferences _prefs;

  AuthNotifier(this._apiService, this._prefs) : super(AuthState.initial()) {
    _init();
  }

  // Başlangıç durumunu kontrol et
  Future<void> _init() async {
    try {
      final token = _prefs.getString('token');
      final userData = _prefs.getString('user');

      if (token != null && userData != null) {
        // Token varsa mevcut kullanıcıyı al
        final userJson = jsonDecode(userData);
        final user = User.fromJson(userJson);
        state = AuthState.authenticated(user);
      } else {
        // Token yoksa null kullanıcı
        state = AuthState.unauthenticated();
      }
    } catch (e) {
      state = AuthState.unauthenticated();
    }
  }

  // Giriş işlemi
  Future<void> login(String email, String password) async {
    state = AuthState.authenticating();
    try {
      final response = await _apiService.login(email, password);
      
      if (response.containsKey('token') && response.containsKey('user')) {
        // Token ve kullanıcı bilgilerini kaydet
        final token = response['token'] as String;
        await _prefs.setString('token', token);
        
        // Kullanıcı modelini oluştur
        final userData = response['user'] as Map<String, dynamic>;
        final user = User.fromJson(userData);
        
        // Kullanıcı verilerini string olarak kaydet
        await _prefs.setString('user', jsonEncode(userData));
        
        // State'i güncelle
        state = AuthState.authenticated(user);
      } else {
        throw Exception('Geçersiz login yanıtı');
      }
    } catch (e) {
      state = AuthState.error(e.toString());
      rethrow;
    }
  }

  // Kaydolma işlemi
  Future<void> register({
    required String name,
    required String email,
    required String password,
    String? username,
    required String cityId, // int -> String olarak değiştirildi
    required String districtId,
    String? phone,
  }) async {
    state = AuthState.authenticating();
    try {
      final response = await _apiService.register(
        name: name,
        email: email,
        password: password,
        username: username,
        cityId: cityId,
        districtId: districtId,
        phone: phone,
      );
      
      if (response.containsKey('token') && response.containsKey('user')) {
        // Token ve kullanıcı bilgilerini kaydet
        final token = response['token'] as String;
        await _prefs.setString('token', token);
        
        // Kullanıcı modelini oluştur
        final userData = response['user'] as Map<String, dynamic>;
        final user = User.fromJson(userData);
        
        // Kullanıcı verilerini string olarak kaydet
        await _prefs.setString('user', jsonEncode(userData));
        
        // State'i güncelle
        state = AuthState.authenticated(user);
      } else {
        throw Exception('Geçersiz register yanıtı');
      }
    } catch (e) {
      state = AuthState.error(e.toString());
      rethrow;
    }
  }

  // Çıkış işlemi
  Future<void> logout() async {
    try {
      await _apiService.logout();
    } catch (e) {
      // API hatası olsa bile local olarak çıkış yapmaya devam et
    } finally {
      // Tüm kayıtlı verileri temizle
      await _prefs.remove('token');
      await _prefs.remove('user');
      state = AuthState.unauthenticated();
    }
  }

  // Profil güncelleme işlemi
  Future<void> updateProfile({
    String? name,
    String? username,
    String? bio,
    String? email,
    String? phone,
    String? profileImageUrl,
    String? coverImageUrl,
    String? cityId,  // int? -> String? olarak değiştirildi
    String? districtId,
  }) async {
    try {
      final currentUser = state.user;
      if (currentUser == null) {
        throw Exception('Kullanıcı oturum açmamış');
      }

      final response = await _apiService.updateProfile(
        userId: currentUser.id,
        name: name,
        username: username,
        bio: bio,
        email: email,
        phone: phone,
        profileImageUrl: profileImageUrl,
        coverImageUrl: coverImageUrl,
        cityId: cityId,
        districtId: districtId,
      );
      
      if (response.containsKey('user')) {
        // Kullanıcı modelini oluştur
        final userData = response['user'] as Map<String, dynamic>;
        final updatedUser = User.fromJson(userData);
        
        // Kullanıcı verilerini string olarak kaydet
        await _prefs.setString('user', jsonEncode(userData));
        
        // State'i güncelle
        state = AuthState.authenticated(updatedUser);
      } else {
        throw Exception('Geçersiz updateProfile yanıtı');
      }
    } catch (e) {
      state = AuthState.error(e.toString());
      rethrow;
    }
  }
}