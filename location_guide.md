# Konum Paketleri Geçiş ve Güncelleme Rehberi

Bu rehber, uygulamamızda derleme sorunları nedeniyle konum paketlerinde yapılan değişiklikleri açıklar. Tüm geliştirici ekibinin bu rehberi takip etmesi önemlidir.

## Neden Değişiklik Yapıldı?

Geolocator ve location paketleri, özellikle Android'de Gradle, Kotlin ve Flutter SDK uyumsuzluğu sorunları yaratıyordu. Location paketi eski bir Kotlin sürümüne (1.4.20) bağımlı olduğu için, modern Android Gradle eklentisiyle uyumlu değildi. Bu nedenle kendi konum servisimizi oluşturmaya ve alternatif paketler kullanmaya karar verdik.

## Paket Değişiklikleri

```yaml
# İlk durum
google_maps_flutter: ^2.5.0
geolocator: ^10.0.1

# Ara geçiş (sorunlar yaşadık)
google_maps_flutter: ^2.4.0
location: ^4.4.0  # Eski Kotlin sürümü kullanıyor (1.4.20)
geocoding: ^2.1.1

# Son durum - SDK 35 ile uyumlu
google_maps_flutter: ^2.5.0
flutter_localization: ^0.1.14  # Modern alternatif
geocoding: ^2.1.1
```

## Konum Servisi Kullanım Kılavuzu

### Eski Geolocator Kullanımı

```dart
import 'package:geolocator/geolocator.dart';

// Konum izinlerini kontrol etme ve izin isteme
Future<bool> _handleLocationPermission() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return false;
  }
  
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return false;
    }
  }
  
  if (permission == LocationPermission.deniedForever) {
    return false;
  }
  
  return true;
}

// Konum almak için:
Position position = await Geolocator.getCurrentPosition(
  desiredAccuracy: LocationAccuracy.high
);
```

### Yeni Location Paketi Kullanımı:

```dart
import 'package:location/location.dart';

Location location = Location();

// Konum izinlerini kontrol etme ve izin isteme
Future<bool> _handleLocationPermission() async {
  bool serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await location.requestService();
    if (!serviceEnabled) {
      return false;
    }
  }
  
  PermissionStatus permissionStatus = await location.hasPermission();
  if (permissionStatus == PermissionStatus.denied) {
    permissionStatus = await location.requestPermission();
    if (permissionStatus != PermissionStatus.granted) {
      return false;
    }
  }
  
  return true;
}

// Konum almak için:
LocationData locationData = await location.getLocation();
```

### flutter_localization Kullanımı (Son Güncelleme):

```dart
import 'package:flutter_localization/flutter_localization.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  // Konum servisimizi oluşturalım
  final FlutterLocalization _localization = FlutterLocalization.instance;
  
  // Konum izinleri kontrolü
  Future<bool> checkPermission() async {
    final status = await _localization.checkLocationPermission();
    return status == LocationPermissionStatus.granted;
  }
  
  // Konum izni isteme
  Future<bool> requestPermission() async {
    final status = await _localization.requestLocationPermission();
    return status == LocationPermissionStatus.granted;
  }
  
  // Güncel konum alma
  Future<Map<String, double>> getCurrentLocation() async {
    try {
      if (!await checkPermission()) {
        final permissionGranted = await requestPermission();
        if (!permissionGranted) {
          return {'latitude': 0, 'longitude': 0};
        }
      }
      
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
}

// Geocoding (Adres Bulma) Kullanımı:
import 'package:geocoding/geocoding.dart';

// Koordinatlardan adres bulma
Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
  List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
  Placemark place = placemarks[0];
  
  return "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
}

// Adresten koordinat bulma
Future<List<Location>> getCoordinatesFromAddress(String address) async {
  return await locationFromAddress(address);
}
```

## Kod Değişiklik Listesi

Aşağıdaki dosyalarda konum paketi uygulamalarını güncellemek gerekmektedir:

1. `lib/services/location_service.dart` - Yeni LocationService sınıfı ekleyin
2. `lib/screens/maps/map_screen.dart` - LocationService sınıfını kullanacak şekilde güncelleyin
3. `lib/screens/posts/create_post_screen.dart` - Konum alma mantığını güncelleyin
4. `lib/providers/location_provider.dart` - Yeni konum servisiyle çalışacak şekilde güncelleyin

## Yeni Konum Servisi Sınıfı

Uygulamanın tümünde kullanılabilecek merkezi bir lokasyon servisi oluşturmanızı öneriyoruz:

```dart
// lib/services/location_service.dart

import 'package:flutter_localization/flutter_localization.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();
  
  final FlutterLocalization _localization = FlutterLocalization.instance;
  
  // ... diğer metodlar ...
}
```

## Geliştirici Notları

1. FlutterLocalization paketi kullanımı daha modern ve Android SDK 35 ile uyumludur.
2. Paket farklı bir API sunar, bu nedenle arayüzü kendi servisimizle standardize ettik.
3. Geocoding paketi hala kullanılabilir, değişiklik gerekmez ve adresten konuma ve konumdan adrese dönüşüm için kullanılır.

## Sorun Giderme

- Eğer Android derlemeleriyle ilgili sorunlar devam ederse, `android/jdk-fix.bat` scriptini çalıştırın.
- iOS için extra bir konfigürasyon gerekirse, `ios/Runner/Info.plist` dosyasında gerekli izinlerin eklendiğinden emin olun.

---

**Not**: Tüm konum kullanımlarını yeni API'ye göre düzenlemeye dikkat edin. Eski geolocator kodları uygulamanın çökmesine neden olabilir.