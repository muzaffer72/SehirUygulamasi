import 'package:flutter_localization/flutter_localization.dart';
import 'package:geocoding/geocoding.dart';

/// Uygulama genelinde konum servislerini yönetmek için kullanılan sınıf.
/// Bu sınıf, flutter_localization paketini kullanarak platform bağımsız konum 
/// işlemlerini sağlar ve Android SDK 35 ile tam uyumludur.
class LocationService {
  // Singleton pattern
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();
  
  // Konum kütüphanesi
  final FlutterLocalization _localization = FlutterLocalization.instance;
  
  /// Konum servisinin etkin olup olmadığını kontrol eder
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await _localization.isLocationServiceEnabled();
    } catch (e) {
      print('Konum servisi kontrolünde hata: $e');
      return false;
    }
  }
  
  /// Konum servisini etkinleştirmeyi ister
  Future<bool> requestLocationService() async {
    try {
      return await _localization.requestLocationService();
    } catch (e) {
      print('Konum servisi isteğinde hata: $e');
      return false;
    }
  }
  
  /// Konum izinlerini kontrol eder
  Future<bool> checkPermission() async {
    try {
      final status = await _localization.checkLocationPermission();
      return status == LocationPermissionStatus.granted;
    } catch (e) {
      print('Konum izni kontrolünde hata: $e');
      return false;
    }
  }
  
  /// Konum izni ister
  Future<bool> requestPermission() async {
    try {
      final status = await _localization.requestLocationPermission();
      return status == LocationPermissionStatus.granted;
    } catch (e) {
      print('Konum izni isteğinde hata: $e');
      return false;
    }
  }
  
  /// Lokasyon izinlerini kontrol edip, izin yoksa isteyecek bir yardımcı metod
  Future<bool> handleLocationPermission() async {
    // Servisin açık olup olmadığını kontrol et
    if (!await isLocationServiceEnabled()) {
      final serviceEnabled = await requestLocationService();
      if (!serviceEnabled) {
        return false;
      }
    }
    
    // İzinleri kontrol et
    if (!await checkPermission()) {
      final permissionGranted = await requestPermission();
      if (!permissionGranted) {
        return false;
      }
    }
    
    return true;
  }
  
  /// Güncel konumu alır
  /// 
  /// Başarısız olduğunda latitude ve longitude değerleri 0 olur.
  Future<Map<String, double>> getCurrentLocation() async {
    try {
      // İzinleri kontrol et ve gerekirse iste
      final hasPermission = await handleLocationPermission();
      if (!hasPermission) {
        return {'latitude': 0, 'longitude': 0};
      }
      
      // Konumu al
      final locationData = await _localization.getCurrentLocation();
      return {
        'latitude': locationData.latitude ?? 0,
        'longitude': locationData.longitude ?? 0
      };
    } catch (e) {
      print('Konum alınamadı: $e');
      return {'latitude': 0, 'longitude': 0};
    }
  }
  
  /// Koordinatlardan adres bilgisi alır
  Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isEmpty) {
        return "Adres bulunamadı";
      }
      
      Placemark place = placemarks[0];
      final parts = <String>[];
      
      if (place.street?.isNotEmpty == true) parts.add(place.street!);
      if (place.locality?.isNotEmpty == true) parts.add(place.locality!);
      if (place.subAdministrativeArea?.isNotEmpty == true) parts.add(place.subAdministrativeArea!);
      if (place.administrativeArea?.isNotEmpty == true) parts.add(place.administrativeArea!);
      if (place.country?.isNotEmpty == true) parts.add(place.country!);
      
      return parts.join(", ");
    } catch (e) {
      print('Adres bulunamadı: $e');
      return "Adres alınamadı";
    }
  }
  
  /// Adres bilgisinden koordinat alır
  Future<Map<String, double>?> getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isEmpty) {
        return null;
      }
      
      return {
        'latitude': locations[0].latitude,
        'longitude': locations[0].longitude
      };
    } catch (e) {
      print('Koordinat bulunamadı: $e');
      return null;
    }
  }
}