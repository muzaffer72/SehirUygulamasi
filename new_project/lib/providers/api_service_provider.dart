import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belediye_iletisim_merkezi/services/api_service.dart';
import 'package:belediye_iletisim_merkezi/services/post_service.dart';

// API Service provider tanımı
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

// Post Service provider tanımı
final postServiceProvider = Provider<PostService>((ref) {
  return PostService.fromRef(ref);
});