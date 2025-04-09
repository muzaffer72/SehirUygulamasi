import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikayet_var/models/user.dart';
import 'package:sikayet_var/services/api_service.dart';

final userNotifierProvider = StateNotifierProvider<UserNotifier, AsyncValue<List<User>>>(
  (ref) => UserNotifier(ApiService()),
);

final userByIdProvider = Provider.family<AsyncValue<User>, String>(
  (ref, userId) {
    final usersState = ref.watch(userNotifierProvider);
    
    return usersState.when(
      data: (users) {
        final user = users.firstWhere(
          (user) => user.id == userId,
          orElse: () => throw Exception('User not found'),
        );
        return AsyncValue.data(user);
      },
      loading: () => const AsyncValue.loading(),
      error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
    );
  },
);

class UserNotifier extends StateNotifier<AsyncValue<List<User>>> {
  final ApiService _apiService;
  
  UserNotifier(this._apiService) : super(const AsyncValue.loading()) {
    loadUsers();
  }
  
  Future<void> loadUsers() async {
    try {
      final users = await _apiService.getUsers();
      state = AsyncValue.data(users);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  Future<User> getUserById(String id) async {
    try {
      final user = await _apiService.getUserById(id);
      // Kullanıcı listesini güncelle
      state.whenData((users) {
        final index = users.indexWhere((u) => u.id == id);
        if (index >= 0) {
          final updatedUsers = [...users];
          updatedUsers[index] = user;
          state = AsyncValue.data(updatedUsers);
        } else {
          state = AsyncValue.data([...users, user]);
        }
      });
      return user;
    } catch (e) {
      throw e;
    }
  }
  
  Future<User> updateUserPoints(String userId, int points) async {
    try {
      // Kullanıcıyı bul
      final userValue = await getUserById(userId);
      
      // Puanları güncelle
      final updatedUser = await _apiService.updateUser(userId, {
        'points': userValue.points + points,
      });
      
      // Listeyi güncelle
      state.whenData((users) {
        final updatedUsers = users.map((user) {
          return user.id == userId ? updatedUser : user;
        }).toList();
        state = AsyncValue.data(updatedUsers);
      });
      
      return updatedUser;
    } catch (e) {
      throw e;
    }
  }
  
  Future<User> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      final updatedUser = await _apiService.updateUser(userId, data);
      
      // Listeyi güncelle
      state.whenData((users) {
        final updatedUsers = users.map((user) {
          return user.id == userId ? updatedUser : user;
        }).toList();
        state = AsyncValue.data(updatedUsers);
      });
      
      return updatedUser;
    } catch (e) {
      throw e;
    }
  }
}