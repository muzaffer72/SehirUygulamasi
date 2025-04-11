import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

// Auth state
enum AuthStatus {
  initial,
  unauthenticated,
  authenticating,
  authenticated,
  error,
}

// Auth state class to hold auth data and status
class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}

// Auth notifier that manages the auth state
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(AuthState()) {
    // Check if the user is already logged in when the provider is initialized
    checkAuth();
  }

  // Check if the user is already authenticated
  Future<void> checkAuth() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      
      if (isLoggedIn) {
        final user = await _authService.getCurrentUser();
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        );
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Login the user
  Future<void> login(String email, String password) async {
    try {
      state = state.copyWith(status: AuthStatus.authenticating);
      
      final user = await _authService.login(email, password);
      
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Register a new user
  Future<void> register(
    String name,
    String email,
    String password,
    String? cityId,
    String? districtId,
  ) async {
    try {
      state = state.copyWith(status: AuthStatus.authenticating);
      
      final user = await _authService.register(
        name,
        email,
        password,
        cityId,
        districtId,
      );
      
      // After registration, login the user
      await login(email, password);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Logout the user
  Future<void> logout() async {
    try {
      await _authService.logout();
      
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Update user profile (just the basic fields for now)
  Future<void> updateProfile(String name, String email) async {
    try {
      if (state.user == null) {
        throw Exception('User not authenticated');
      }
      
      // In a real app, this would call an API to update the user's profile
      // For now, we'll just update the local state
      final updatedUser = state.user!.copyWith(
        name: name,
        email: email,
      );
      
      state = state.copyWith(
        user: updatedUser,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
}

// Provider for the auth service
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Provider for the auth state
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});