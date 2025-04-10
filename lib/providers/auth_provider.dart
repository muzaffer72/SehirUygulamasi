import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikayet_var/models/user.dart';
import 'package:sikayet_var/providers/api_service_provider.dart';
import 'package:sikayet_var/services/api_service.dart';

// Auth state representation
class AuthState {
  final bool isAuthenticated;
  final String? userId;
  final String? token;
  
  const AuthState({
    this.isAuthenticated = false,
    this.userId,
    this.token,
  });
  
  AuthState copyWith({
    bool? isAuthenticated,
    String? userId,
    String? token,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userId: userId ?? this.userId,
      token: token ?? this.token,
    );
  }
}

// Auth state provider
final authStateProvider = StateProvider<AuthState>((ref) => const AuthState());

// Auth notifier provider
final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, User?>(
  () => AuthNotifier(),
);

class AuthNotifier extends AsyncNotifier<User?> {
  late final ApiService _apiService;
  
  @override
  Future<User?> build() async {
    _apiService = ref.read(apiServiceProvider);
    
    try {
      final token = await _apiService.getToken();
      
      // If we have a token, try to get the current user
      if (token != null) {
        // Update auth state
        ref.read(authStateProvider.notifier).update((state) => 
          state.copyWith(isAuthenticated: true, token: token, userId: '1')
        );
        
        // Mock implementation - in the real app this would validate the token
        final demoUser = User(
          id: '1',
          name: 'Demo User',
          email: 'demo@example.com',
          isVerified: true,
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        );
        return demoUser;
      }
    } catch (e) {
      print('Error loading auth state: $e');
    }
    
    return null;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    
    try {
      // Test kullanıcısı için sabit bilgiler
      if (email == 'test@example.com' && password == 'test123') {
        print('TEST KULLANICISI GİRİŞİ BAŞARILI');
        // Test kullanıcısını manuel olarak oluştur
        final testUser = User(
          id: '999',
          name: 'Test Kullanıcı',
          email: 'test@example.com',
          isVerified: true,
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          cityId: '1', // Adana
          districtId: '2', // Aladağ
          bio: 'Bu bir test kullanıcısıdır',
          profileImageUrl: 'https://i.pravatar.cc/150?img=3',
          points: 100,
          level: UserLevel.contributor,
        );
        
        // Auth state'i güncelle
        ref.read(authStateProvider.notifier).update((state) => 
          state.copyWith(
            isAuthenticated: true, 
            token: 'test-token',
            userId: testUser.id
          )
        );
        
        // Durum güncelle
        state = AsyncValue.data(testUser);
        return;
      }
      
      // Normal API servisi çağrısı
      final user = await _apiService.login(email, password);
      
      // Update auth state
      if (user != null) {
        ref.read(authStateProvider.notifier).update((state) => 
          state.copyWith(
            isAuthenticated: true, 
            token: 'dummy-token', // Real token would come from API
            userId: user.id
          )
        );
      }
      
      // Update the state with the logged-in user
      state = AsyncValue.data(user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      throw e;
    }
  }
  
  Future<void> register(
    String name,
    String email,
    String password, {
    String? cityId,
    String? districtId,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      // Call the API service
      final user = await _apiService.register(
        name,
        email,
        password,
        cityId: cityId,
        districtId: districtId,
      );
      
      // Update the state with the newly registered user
      state = AsyncValue.data(user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      throw e;
    }
  }
  
  Future<void> logout() async {
    state = const AsyncValue.loading();
    
    try {
      // Call the API service
      await _apiService.logout();
      
      // Reset auth state
      ref.read(authStateProvider.notifier).update((_) => const AuthState());
      
      // Clear the user
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      throw e;
    }
  }
  
  // Kullanıcının konum bilgilerini güncelleme
  Future<void> updateUserLocation(String userId, String? cityId, String? districtId) async {
    state = const AsyncValue.loading();
    
    try {
      // Mevcut kullanıcı verisini al
      final currentUser = state.valueOrNull;
      if (currentUser == null) {
        throw Exception('Kullanıcı oturumu bulunamadı');
      }
      
      // API servisi ile kullanıcıyı güncelle
      final updatedUser = await _apiService.updateUser(userId, {
        'city_id': cityId,
        'district_id': districtId,
      });
      
      // Durum güncellemesi yap
      state = AsyncValue.data(updatedUser);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      throw e;
    }
  }
}