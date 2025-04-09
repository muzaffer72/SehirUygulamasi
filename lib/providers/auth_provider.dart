import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikayet_var/models/user.dart';
import 'package:sikayet_var/services/auth_service.dart';

// Provider for the current authenticated user
final currentUserProvider = StateProvider<User?>((ref) => null);

// Provider for the auth notifier
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final Ref _ref;
  final AuthService _authService = AuthService();

  AuthNotifier(this._ref) : super(const AsyncValue.loading()) {
    _checkCurrentUser();
  }

  Future<void> _checkCurrentUser() async {
    try {
      final user = await _authService.getCurrentUser();
      state = AsyncValue.data(user);
      _ref.read(currentUserProvider.notifier).state = user;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      _ref.read(currentUserProvider.notifier).state = null;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      state = const AsyncValue.loading();
      final user = await _authService.login(email, password);
      state = AsyncValue.data(user);
      _ref.read(currentUserProvider.notifier).state = user;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      _ref.read(currentUserProvider.notifier).state = null;
      rethrow;
    }
  }

  Future<void> register(String name, String email, String password, {
    String? phone,
    String? cityId,
    String? districtId,
  }) async {
    try {
      state = const AsyncValue.loading();
      final user = await _authService.register(
        name,
        email,
        password,
        phone: phone,
        cityId: cityId,
        districtId: districtId,
      );
      state = AsyncValue.data(user);
      _ref.read(currentUserProvider.notifier).state = user;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      _ref.read(currentUserProvider.notifier).state = null;
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      state = const AsyncValue.loading();
      await _authService.logout();
      state = const AsyncValue.data(null);
      _ref.read(currentUserProvider.notifier).state = null;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> updateProfile(User user) async {
    try {
      state = const AsyncValue.loading();
      final updatedUser = await _authService.updateProfile(user);
      state = AsyncValue.data(updatedUser);
      _ref.read(currentUserProvider.notifier).state = updatedUser;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      state = const AsyncValue.loading();
      await _authService.resetPassword(email);
      state = AsyncValue.data(_ref.read(currentUserProvider));
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }
}