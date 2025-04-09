import 'package:flutter/material.dart';
import 'lib/services/location_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ŞikayetVar Konum Testi',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          primary: Colors.blue,
          secondary: Colors.amber,
        ),
        useMaterial3: true,
      ),
      home: const LocationTestPage(),
    );
  }
}

class LocationTestPage extends StatefulWidget {
  const LocationTestPage({Key? key}) : super(key: key);

  @override
  State<LocationTestPage> createState() => _LocationTestPageState();
}

class _LocationTestPageState extends State<LocationTestPage> {
  final LocationService _locationService = LocationService();
  String _locationInfo = "Konum bilgisi henüz alınmadı";
  String _permissionStatus = "İzin durumu bilinmiyor";
  Map<String, double> _currentLocation = {'latitude': 0, 'longitude': 0};
  String _address = "";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  // Konum izinlerini kontrol et
  Future<void> _checkPermission() async {
    setState(() {
      _isLoading = true;
    });

    try {
      bool hasPermission = await _locationService.checkPermission();
      setState(() {
        _permissionStatus = hasPermission 
            ? "Konum izni var ✓" 
            : "Konum izni yok ✗";
      });
    } catch (e) {
      setState(() {
        _permissionStatus = "İzin kontrolünde hata: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Konum izni iste
  Future<void> _requestPermission() async {
    setState(() {
      _isLoading = true;
    });

    try {
      bool permissionGranted = await _locationService.requestPermission();
      setState(() {
        _permissionStatus = permissionGranted 
            ? "Konum izni verildi ✓" 
            : "Konum izni reddedildi ✗";
      });
    } catch (e) {
      setState(() {
        _permissionStatus = "İzin isteğinde hata: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Konum al
  Future<void> _getLocation() async {
    setState(() {
      _isLoading = true;
      _locationInfo = "Konum alınıyor...";
    });

    try {
      Map<String, double> location = await _locationService.getCurrentLocation();
      
      setState(() {
        _currentLocation = location;
        _locationInfo = "Enlem: ${location['latitude']}, Boylam: ${location['longitude']}";
      });
      
      // Adres bilgisini al
      if (location['latitude'] != 0 && location['longitude'] != 0) {
        _getAddress(location['latitude']!, location['longitude']!);
      }
    } catch (e) {
      setState(() {
        _locationInfo = "Konum alınamadı: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Adres bilgisi al
  Future<void> _getAddress(double latitude, double longitude) async {
    setState(() {
      _address = "Adres bilgisi alınıyor...";
    });

    try {
      String address = await _locationService.getAddressFromCoordinates(latitude, longitude);
      setState(() {
        _address = address;
      });
    } catch (e) {
      setState(() {
        _address = "Adres bilgisi alınamadı: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ŞikayetVar Konum Testi', 
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('SDK 35 Konum Servisi',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Android SDK 35 ile uyumlu konum servisleri test ediliyor'),
                    const Divider(),
                    Text('İzin Durumu: $_permissionStatus',
                      style: TextStyle(
                        color: _permissionStatus.contains("✓") 
                          ? Colors.green 
                          : Colors.red
                      )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Konum Bilgisi',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(_locationInfo),
                    if (_address.isNotEmpty) ...[
                      const Divider(),
                      const Text('Adres:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(_address),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _requestPermission,
              child: const Text('Konum İzni İste'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _getLocation,
              child: const Text('Konumu Al'),
            ),
            if (_isLoading) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
            ],
            const SizedBox(height: 24),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Teknik Bilgiler', 
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('Android SDK: 35'),
                    Text('Konum Servisi: SDK 35 özel entegrasyonu'),
                    Text('Geocoding: 2.2.2'),
                    Text('Google Maps: 2.10.1'),
                    Divider(),
                    Text('Bu testler, Android SDK 35 gereksinimlerini karşılamak için yapılan güncellemelerin doğru çalıştığını doğrulamak için tasarlanmıştır.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}