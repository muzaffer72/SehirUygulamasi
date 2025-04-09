import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikayet_var/models/user.dart';
import 'package:sikayet_var/services/auth_service.dart';

// AuthService provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Stream provider for authentication state
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges();
});

// Provider for current user
final currentUserProvider = StateProvider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
});

// Auth loading state
final authLoadingProvider = StateProvider<bool>((ref) => false);

// Auth error state
final authErrorProvider = StateProvider<String?>((ref) => null);

// Auth class with notifier
class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthService _authService;
  final Ref _ref;
  
  AuthNotifier(this._authService, this._ref) : super(const AsyncValue.loading()) {
    // Initialize state from auth service
    _init();
  }
  
  Future<void> _init() async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.getCurrentUser();
      state = AsyncValue.data(user);
      _ref.read(currentUserProvider.notifier).state = user;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
  
  // Login with email and password
  Future<User?> login(String email, String password) async {
    state = const AsyncValue.loading();
    _ref.read(authLoadingProvider.notifier).state = true;
    _ref.read(authErrorProvider.notifier).state = null;
    
    try {
      final user = await _authService.login(email, password);
      state = AsyncValue.data(user);
      _ref.read(currentUserProvider.notifier).state = user;
      _ref.read(authLoadingProvider.notifier).state = false;
      return user;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      _ref.read(authLoadingProvider.notifier).state = false;
      _ref.read(authErrorProvider.notifier).state = e.toString();
      return null;
    }
  }
  
  // Register a new user
  Future<User?> register(String name, String email, String password, String cityId, String districtId) async {
    state = const AsyncValue.loading();
    _ref.read(authLoadingProvider.notifier).state = true;
    _ref.read(authErrorProvider.notifier).state = null;
    
    try {
      final user = await _authService.register(name, email, password, cityId, districtId);
      state = AsyncValue.data(user);
      _ref.read(currentUserProvider.notifier).state = user;
      _ref.read(authLoadingProvider.notifier).state = false;
      return user;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      _ref.read(authLoadingProvider.notifier).state = false;
      _ref.read(authErrorProvider.notifier).state = e.toString();
      return null;
    }
  }
  
  // Logout
  Future<void> logout() async {
    state = const AsyncValue.loading();
    
    try {
      await _authService.logout();
      state = const AsyncValue.data(null);
      _ref.read(currentUserProvider.notifier).state = null;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      _ref.read(authErrorProvider.notifier).state = e.toString();
    }
  }
  
  // Update user profile
  Future<User?> updateProfile(User user) async {
    state = const AsyncValue.loading();
    
    try {
      final updatedUser = await _authService.updateProfile(user);
      state = AsyncValue.data(updatedUser);
      _ref.read(currentUserProvider.notifier).state = updatedUser;
      return updatedUser;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      _ref.read(authErrorProvider.notifier).state = e.toString();
      return null;
    }
  }
  
  // Send password reset email
  Future<bool> resetPassword(String email) async {
    _ref.read(authLoadingProvider.notifier).state = true;
    _ref.read(authErrorProvider.notifier).state = null;
    
    try {
      await _authService.resetPassword(email);
      _ref.read(authLoadingProvider.notifier).state = false;
      return true;
    } catch (e) {
      _ref.read(authLoadingProvider.notifier).state = false;
      _ref.read(authErrorProvider.notifier).state = e.toString();
      return false;
    }
  }
}

// Auth notifier provider
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService, ref);
});