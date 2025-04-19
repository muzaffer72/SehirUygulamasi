import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belediye_iletisim_merkezi/models/user.dart';
import 'package:belediye_iletisim_merkezi/services/api_service.dart';

// Streamlined provider for current user
final currentUserProvider = FutureProvider<User?>((ref) async {
  final apiService = ApiService();
  return apiService.getCurrentUser();
});