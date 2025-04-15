import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';

/// Uygulama genelinde konum servislerini yönetmek için kullanılan sınıf.
/// Bu sınıf, Android SDK 35 ile uyumlu konum hizmetleri sağlar.
/// Bu sınıf, Replit web ortamında test için geçici veri sağlar.
class LocationService {
  // Singleton pattern
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();
  
  bool _hasPermission = false;
  final Random _random = Random();
  
  /// Konum izinlerini kontrol eder
  Future<bool> checkPermission() async {
    // Web simülasyonu 
    if (kIsWeb) {
      return _hasPermission;
    }
    
    try {
      // Gerçek cihazda izinleri kontrol etme kodu burada olacak
      // Şu an web'de test ediyoruz
      return _hasPermission;
    } catch (e) {
      print('Konum izni kontrolünde hata: $e');
      return false;
    }
  }
  
  /// Konum izni ister
  Future<bool> requestPermission() async {
    // Web simülasyonu
    if (kIsWeb) {
      _hasPermission = true;
      return true;
    }
    
    try {
      // Gerçek cihazda izin isteme kodu burada olacak
      // Şu an web'de test ediyoruz
      _hasPermission = true;
      return true;
    } catch (e) {
      print('Konum izni isteğinde hata: $e');
      return false;
    }
  }
  
  /// Lokasyon izinlerini kontrol edip, izin yoksa isteyecek bir yardımcı metod
  Future<bool> handleLocationPermission() async {
    // İzinleri kontrol et
    if (!await checkPermission()) {
      final permissionGranted = await requestPermission();
      if (!permissionGranted) {
        return false;
      }
    }
    
    return true;
  }
  
  /// Güncel konumu alır (Web'de simülasyon için Türkiye'deki bir konum döndürür)
  /// 
  /// Başarısız olduğunda latitude ve longitude değerleri 0 olur.
  Future<Map<String, double>> getCurrentLocation() async {
    try {
      // İzinleri kontrol et ve gerekirse iste
      final hasPermission = await handleLocationPermission();
      if (!hasPermission) {
        return {'latitude': 0, 'longitude': 0};
      }
      
      // Web'de test için Türkiye'deki bir konum döndür
      if (kIsWeb) {
        // Ankara: 39.9208, 32.8541 çevresinde bir konum
        final latitude = 39.9208 + (_random.nextDouble() - 0.5) / 10;
        final longitude = 32.8541 + (_random.nextDouble() - 0.5) / 10;
        
        return {
          'latitude': latitude,
          'longitude': longitude
        };
      }
      
      // Gerçek cihazda konum alma kodu burada olacak
      // Şu an web'de test ediyoruz
      return {'latitude': 0, 'longitude': 0};
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