import '../models/user.dart';

enum AuthStatus {
  initial,
  unauthenticated,
  authenticating,
  authenticated,
  error
}

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;
  final bool isLoggedIn;

  AuthState({
    required this.status,
    this.user,
    this.errorMessage,
    this.isLoggedIn = false,
  });

  factory AuthState.initial() {
    return AuthState(
      status: AuthStatus.initial,
    );
  }

  factory AuthState.authenticating() {
    return AuthState(
      status: AuthStatus.authenticating,
    );
  }

  factory AuthState.authenticated(User user) {
    return AuthState(
      status: AuthStatus.authenticated,
      user: user,
      isLoggedIn: true,
    );
  }

  factory AuthState.unauthenticated() {
    return AuthState(
      status: AuthStatus.unauthenticated,
    );
  }

  factory AuthState.error(String message) {
    return AuthState(
      status: AuthStatus.error,
      errorMessage: message,
    );
  }

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
    bool? isLoggedIn,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}