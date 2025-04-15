import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikayet_var/models/city_profile.dart';
import 'package:sikayet_var/providers/api_service_provider.dart';

// Şehir profil bilgisini getiren provider
final cityProfileProvider = FutureProvider.family<CityProfile?, dynamic>(
  (ref, cityId) async {
    final apiService = ref.watch(apiServiceProvider);
    // cityId'nin hem int hem de String olabilmesi için dönüşüm yapılıyor
    return apiService.getCityProfile(cityId);
  },
);

// Şehir listesini getiren provider
final cityListProvider = FutureProvider<List<dynamic>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  // Burada getCitiesAsObjects kullanarak City objelerini alalım
  return apiService.getCitiesAsObjects();
});

// Belirli bir şehre ait ilçe listesini getiren provider
final districtsByCityProvider = FutureProvider.family<List<dynamic>, dynamic>(
  (ref, cityId) async {
    final apiService = ref.watch(apiServiceProvider);
    final cityIdStr = cityId.toString();
    return apiService.getDistrictsByCityId(cityIdStr);
  },
);