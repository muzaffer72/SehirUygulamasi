import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences provider has not been initialized');
});

// User provider, AuthNotifier durumunu yayınlar
final authProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return AuthNotifier(apiService, prefs);
});

// Kullanıcıyı sağlayan provider (eğer oturum açılmışsa)
final userProvider = Provider<User?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.when(
    data: (user) => user,
    error: (_, __) => null,
    loading: () => null,
  );
});

// Kullanıcı oturumunun durumunu kontrol eden provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(userProvider);
  return user != null;
});

// Auth işlemlerini yöneten StateNotifier
class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final ApiService _apiService;
  final SharedPreferences _prefs;

  AuthNotifier(this._apiService, this._prefs) : super(const AsyncValue.loading()) {
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
        state = AsyncValue.data(User.fromJson(userJson));
      } else {
        // Token yoksa null kullanıcı
        state = const AsyncValue.data(null);
      }
    } catch (e) {
      state = const AsyncValue.data(null);
    }
  }

  // Giriş işlemi
  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
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
        state = AsyncValue.data(user);
      } else {
        throw Exception('Geçersiz login yanıtı');
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  // Kaydolma işlemi
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required int cityId,
    required String districtId,
    String? phone,
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await _apiService.register(
        name: name,
        email: email,
        password: password,
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
        state = AsyncValue.data(user);
      } else {
        throw Exception('Geçersiz register yanıtı');
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
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
      state = const AsyncValue.data(null);
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
    int? cityId,
    String? districtId,
  }) async {
    try {
      final currentUser = state.value;
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
        cityId: cityId != null ? cityId.toString() : null,
        districtId: districtId,
      );
      
      if (response.containsKey('user')) {
        // Kullanıcı modelini oluştur
        final userData = response['user'] as Map<String, dynamic>;
        final updatedUser = User.fromJson(userData);
        
        // Kullanıcı verilerini string olarak kaydet
        await _prefs.setString('user', jsonEncode(userData));
        
        // State'i güncelle
        state = AsyncValue.data(updatedUser);
      } else {
        throw Exception('Geçersiz updateProfile yanıtı');
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }
}