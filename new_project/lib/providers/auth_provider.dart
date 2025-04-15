import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belediye_iletisim_merkezi/models/user.dart';
import 'package:belediye_iletisim_merkezi/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

// Kullanıcı kimlik bilgilerini tutan provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(apiServiceProvider));
});

// Auth durumu sınıfı
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isLoggedIn;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isLoggedIn = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isLoggedIn,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}

// Auth işlemlerini yöneten notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService;
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  AuthNotifier(this._apiService) : super(AuthState()) {
    // Oturumu kontrol et ve varsa kullanıcıyı yükle
    checkAuth();
  }

  // Oturum kontrolü
  Future<void> checkAuth() async {
    state = state.copyWith(isLoading: true);
    
    try {
      // SharedPreferences'tan token ve kullanıcı bilgilerini al
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      
      if (token != null) {
        // API'den kullanıcı bilgilerini al
        final user = await _apiService.getCurrentUser();
        if (user != null) {
          state = state.copyWith(
            user: user,
            isLoading: false,
            isLoggedIn: true,
          );
          return;
        }
      }
      
      // Token yoksa veya kullanıcı alınamazsa, çıkış yap
      state = state.copyWith(
        user: null,
        isLoading: false,
        isLoggedIn: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Oturum kontrolü sırasında bir hata oluştu: $e',
        isLoading: false,
        isLoggedIn: false,
      );
    }
  }

  // Giriş işlemi
  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final result = await _apiService.login(email, password);
      
      if (result['token'] != null && result['user'] != null) {
        // Token'ı kaydet
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, result['token']);
        
        // Kullanıcı bilgilerini state'e ekle
        final user = User.fromJson(result['user']);
        state = state.copyWith(
          user: user,
          isLoading: false,
          isLoggedIn: true,
        );
      } else {
        state = state.copyWith(
          error: 'Geçersiz kullanıcı bilgileri',
          isLoading: false,
          isLoggedIn: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Giriş yapılırken bir hata oluştu: $e',
        isLoading: false,
        isLoggedIn: false,
      );
    }
  }

  // Kayıt işlemi
  Future<void> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    required int cityId,
    String? districtId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final result = await _apiService.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        cityId: cityId.toString(),
        districtId: districtId,
      );
      
      if (result['token'] != null && result['user'] != null) {
        // Token'ı kaydet
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, result['token']);
        
        // Kullanıcı bilgilerini state'e ekle
        final user = User.fromJson(result['user']);
        state = state.copyWith(
          user: user,
          isLoading: false,
          isLoggedIn: true,
        );
      } else {
        state = state.copyWith(
          error: 'Kayıt olurken bir hata oluştu.',
          isLoading: false,
          isLoggedIn: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Kayıt olurken bir hata oluştu: $e',
        isLoading: false,
        isLoggedIn: false,
      );
    }
  }

  // Çıkış işlemi
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    
    try {
      await _apiService.logout();
      
      // Token ve kullanıcı bilgilerini temizle
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
      
      state = state.copyWith(
        user: null,
        isLoading: false,
        isLoggedIn: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Çıkış yapılırken bir hata oluştu: $e',
        isLoading: false,
      );
    }
  }

  // Kullanıcı bilgilerini güncelleme
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
    if (state.user == null) return;
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final updatedUser = await _apiService.updateProfile(
        userId: state.user!.id,
        name: name,
        username: username,
        bio: bio,
        email: email,
        phone: phone,
        profileImageUrl: profileImageUrl,
        coverImageUrl: coverImageUrl,
        cityId: cityId?.toString(),
        districtId: districtId,
      );
      
      state = state.copyWith(
        user: updatedUser,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Profil güncellenirken bir hata oluştu: $e',
        isLoading: false,
      );
    }
  }
}