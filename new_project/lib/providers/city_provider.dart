import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belediye_iletisim_merkezi/models/city.dart';
import 'package:belediye_iletisim_merkezi/models/district.dart';
import 'package:belediye_iletisim_merkezi/services/api_service.dart';

final citiesProvider = FutureProvider<List<City>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getCities();
});

final selectedCityProvider = StateProvider<City?>((ref) => null);

final districtsProvider = FutureProvider.family<List<District>, String>((ref, cityId) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getDistricts(cityId);
});

final selectedDistrictProvider = StateProvider<District?>((ref) => null);

final cityProfileProvider = FutureProvider.family<City, String>((ref, cityId) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getCityProfile(cityId);
});

final districtProfileProvider = FutureProvider.family<District, String>((ref, districtId) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getDistrictProfile(districtId);
});
