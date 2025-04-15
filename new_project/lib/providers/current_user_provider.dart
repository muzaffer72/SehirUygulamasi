import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikayet_var/models/user.dart';
import 'package:sikayet_var/services/api_service.dart';

// Streamlined provider for current user
final currentUserProvider = FutureProvider<User?>((ref) async {
  final apiService = ApiService();
  return apiService.getCurrentUser();
});