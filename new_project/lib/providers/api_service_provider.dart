import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikayet_var/services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});