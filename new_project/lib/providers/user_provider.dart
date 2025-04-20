import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belediye_iletisim_merkezi/models/user.dart';
import 'package:belediye_iletisim_merkezi/services/api_service.dart';

// State Notifier for user settings
class UserNotifier extends StateNotifier<AsyncValue<User?>> {
  final ApiService _apiService;
  
  UserNotifier(this._apiService) : super(const AsyncValue.loading()) {
    loadCurrentUser();
  }
  
  Future<void> loadCurrentUser() async {
    state = const AsyncValue.loading();
    try {
      final user = await _apiService.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  Future<void> updateUserProfile(
    String name,
    String email,
    {String? profileImageUrl}
  ) async {
    try {
      state.whenData((user) async {
        if (user == null) return;
        
        state = const AsyncValue.loading();
        
        final updatedUser = await _apiService.updateUserProfile(
          userId: user.id.toString(),
          name: name,
          email: email,
          profileImageUrl: profileImageUrl,
        );
        
        if (updatedUser is User) {
          state = AsyncValue.data(updatedUser);
        } else if (updatedUser is Map<String, dynamic>) {
          state = AsyncValue.data(User.fromJson(updatedUser));
        }
      });
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  Future<void> updateUserLocation(
    String? cityId,
    String? districtId,
  ) async {
    try {
      state.whenData((user) async {
        if (user == null) return;
        
        state = const AsyncValue.loading();
        
        final updatedUser = await _apiService.updateUserLocation(
          userId: user.id.toString(),
          cityId: cityId ?? "0",
          districtId: districtId,
        );
        
        if (updatedUser is User) {
          state = AsyncValue.data(updatedUser);
        } else if (updatedUser is Map<String, dynamic>) {
          state = AsyncValue.data(User.fromJson(updatedUser));
        }
      });
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final userProviderProvider = StateNotifierProvider<UserNotifier, AsyncValue<User?>>((ref) {
  final apiService = ApiService();
  return UserNotifier(apiService);
});