import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belediye_iletisim_merkezi/providers/auth_provider.dart';

// Auth işlemlerini kontrol eden provider
final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  final authNotifier = ref.watch(authProvider.notifier);
  return AuthController(authNotifier);
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthNotifier _authNotifier;

  AuthController(this._authNotifier) : super(const AsyncValue.data(null));

  // Giriş işlemi
  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _authNotifier.login(email, password);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Kayıt işlemi
  Future<void> signUp(
    String email,
    String password,
    String username,
    String cityId,
    String districtId,
    String? anonymousName,
  ) async {
    state = const AsyncValue.loading();
    try {
      await _authNotifier.register(
        name: anonymousName ?? username,
        email: email,
        password: password,
        cityId: int.parse(cityId),
        districtId: districtId,
        phone: null, // Telefon alanı opsiyonel
      );
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Çıkış işlemi
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _authNotifier.logout();
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
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
    state = const AsyncValue.loading();
    try {
      await _authNotifier.updateProfile(
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
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}