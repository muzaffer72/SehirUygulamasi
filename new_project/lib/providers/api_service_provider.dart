import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belediye_iletisim_merkezi/services/api_service.dart';

// API Service provider tanımı
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());