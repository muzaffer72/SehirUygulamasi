import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikayet_var/models/city.dart';
import 'package:sikayet_var/models/district.dart';
import 'package:sikayet_var/models/user.dart';
import 'package:sikayet_var/providers/auth_provider.dart';
import 'package:sikayet_var/providers/user_provider.dart';
import 'package:sikayet_var/screens/home/city_feed_screen.dart';
import 'package:sikayet_var/services/api_service.dart';

class LocationSettingsScreen extends ConsumerStatefulWidget {
  const LocationSettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LocationSettingsScreen> createState() => _LocationSettingsScreenState();
}

class _LocationSettingsScreenState extends ConsumerState<LocationSettingsScreen> {
  final ApiService _apiService = ApiService();
  String? _selectedCityId;
  String? _selectedDistrictId;
  bool _isLoading = false;
  bool _saveDefaultLocation = false;
  
  @override
  void initState() {
    super.initState();
    
    // Mevcut kullanıcı ayarlarını yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUser = ref.read(currentUserProvider).value;
      if (currentUser != null) {
        setState(() {
          _selectedCityId = currentUser.cityId;
          _selectedDistrictId = currentUser.districtId;
          _saveDefaultLocation = currentUser.cityId != null || currentUser.districtId != null;
        });
      }
      
      // Ana ekran filtrelerini de önceden ayarlanmış değerlere göre ayarla
      ref.read(cityFilterProvider.notifier).state = _selectedCityId;
      ref.read(districtFilterProvider.notifier).state = _selectedDistrictId;
    });
  }
  
  Future<void> _saveLocationSettings() async {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konum ayarlarını kaydetmek için giriş yapın')),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Ana ekran filtrelerini kullanıcı tercihlerine göre ayarla
      ref.read(cityFilterProvider.notifier).state = _saveDefaultLocation ? _selectedCityId : null;
      ref.read(districtFilterProvider.notifier).state = _saveDefaultLocation ? _selectedDistrictId : null;
      
      // Kullanıcı profilini güncelle (tercihleri kaydet)
      if (_saveDefaultLocation) {
        await ref.read(authNotifierProvider.notifier).updateUserLocation(
          currentUser.id,
          _selectedCityId,
          _selectedDistrictId,
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Konum ayarları kaydedildi')),
        );
      } else {
        // Varsayılan konum tercihlerini temizle
        await ref.read(authNotifierProvider.notifier).updateUserLocation(
          currentUser.id,
          null,
          null,
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Konum ayarları temizlendi')),
        );
      }
      
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(currentUserProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konum Ayarları'),
      ),
      body: userState.when(
        data: (User? user) {
          if (user == null) {
            return const Center(
              child: Text('Konum ayarlarını kullanmak için giriş yapın'),
            );
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bilgi kutusu
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Konum Tercihleri',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Ana sayfada gösterilecek varsayılan şehir ve ilçeyi burada belirleyebilirsiniz. Bu seçim, uygulamayı açtığınızda ilgili bölgeye ait gönderileri görmenizi sağlar.',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Varsayılan konum kullanma seçeneği
                SwitchListTile(
                  title: const Text('Varsayılan Konum Kullan'),
                  subtitle: const Text('Ana sayfada belirlediğiniz konumdaki içerikleri göster'),
                  value: _saveDefaultLocation,
                  activeColor: Theme.of(context).colorScheme.primary,
                  onChanged: (value) {
                    setState(() {
                      _saveDefaultLocation = value;
                    });
                  },
                ),
                const Divider(),
                const SizedBox(height: 16),
                
                if (_saveDefaultLocation) ...[
                  const Text(
                    'Varsayılan Konumunuz',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Şehir seçimi
                  FutureBuilder<List<City>>(
                    future: _apiService.getCities(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('Şehir verisi bulunamadı');
                      }
                      
                      final cities = snapshot.data!;
                      
                      return DropdownButtonFormField<String>(
                        value: _selectedCityId,
                        decoration: const InputDecoration(
                          labelText: 'Şehir',
                          prefixIcon: Icon(Icons.location_city),
                          border: OutlineInputBorder(),
                        ),
                        items: cities.map((city) {
                          return DropdownMenuItem<String>(
                            value: city.id,
                            child: Text(city.name),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedCityId = newValue;
                            _selectedDistrictId = null; // Reset district when city changes
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // İlçe seçimi (şehir seçiliyse)
                  if (_selectedCityId != null)
                    FutureBuilder<List<District>>(
                      future: _apiService.getDistrictsByCityId(_selectedCityId!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Text('İlçe verisi bulunamadı');
                        }
                        
                        final districts = snapshot.data!;
                        
                        return DropdownButtonFormField<String>(
                          value: _selectedDistrictId,
                          decoration: const InputDecoration(
                            labelText: 'İlçe',
                            prefixIcon: Icon(Icons.location_on),
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('İlçe seçin (İsteğe bağlı)'),
                            ),
                            ...districts.map((district) {
                              return DropdownMenuItem<String>(
                                value: district.id,
                                child: Text(district.name),
                              );
                            }).toList(),
                          ],
                          onChanged: (newValue) {
                            setState(() {
                              _selectedDistrictId = newValue;
                            });
                          },
                        );
                      },
                    ),
                  const SizedBox(height: 24),
                ],
                
                // Kaydetme butonu
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveLocationSettings,
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Ayarları Kaydet'),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text('Hata: $error'),
        ),
      ),
    );
  }
}