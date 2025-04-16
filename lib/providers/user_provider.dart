import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikayet_var/models/user.dart';
import 'package:sikayet_var/services/api_service.dart';

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
          user.id.toString(),
          {
            'name': name,
            'email': email,
            if (profileImageUrl != null) 'profile_image_url': profileImageUrl,
          },
        );
        
        state = AsyncValue.data(updatedUser);
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
        
        final updatedUser = await _apiService.updateUserLocationWithDetails(
          user.id.toString(),
          {
            if (cityId != null) 'city_id': cityId,
            if (districtId != null) 'district_id': districtId,
          },
        );
        
        state = AsyncValue.data(updatedUser);
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