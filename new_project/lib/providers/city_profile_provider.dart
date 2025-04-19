import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../models/city_profile.dart';
import '../models/city.dart';
import '../models/district.dart';

// API Service provider
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

// Şehir profil bilgisini getiren provider
final cityProfileProvider = FutureProvider.family<CityProfile?, dynamic>(
  (ref, cityId) async {
    final apiService = ref.watch(apiServiceProvider);
    // cityId'nin hem int hem de String olabilmesi için
    final cityIdStr = cityId.toString();
    return await apiService.getCityProfileById(cityIdStr);
  },
);

// Şehir listesini getiren provider
final cityListProvider = FutureProvider<List<City>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getCitiesAsObjects();
});

// Belirli bir şehre ait ilçe listesini getiren provider
final districtsByCityProvider = FutureProvider.family<List<District>, dynamic>(
  (ref, cityId) async {
    final apiService = ref.watch(apiServiceProvider);
    final cityIdStr = cityId.toString();
    return apiService.getDistrictsByCityIdAsObjects(cityIdStr);
  },
);