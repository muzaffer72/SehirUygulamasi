import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikayet_var/models/user.dart';
import 'package:sikayet_var/providers/api_service_provider.dart';
import 'package:sikayet_var/providers/auth_provider.dart';

// Current user provider
final currentUserProvider = FutureProvider<User?>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  final authState = ref.watch(authStateProvider);
  
  if (authState.isAuthenticated && authState.userId != null) {
    try {
      return await apiService.getUserById(authState.userId!);
    } catch (e) {
      // Handle error
      return null;
    }
  }
  
  return null;
});