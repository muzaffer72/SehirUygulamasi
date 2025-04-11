import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikayet_var/models/city.dart';
import 'package:sikayet_var/models/district.dart';
import 'package:sikayet_var/providers/auth_provider.dart';
import 'package:sikayet_var/providers/user_provider.dart';
import 'package:sikayet_var/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationSettingsScreen extends ConsumerStatefulWidget {
  const LocationSettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LocationSettingsScreen> createState() => _LocationSettingsScreenState();
}

class _LocationSettingsScreenState extends ConsumerState<LocationSettingsScreen> {
  final ApiService _apiService = ApiService();
  
  String? _selectedCityId;
  String? _selectedDistrictId;
  
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadUserLocation();
  }
  
  Future<void> _loadUserLocation() async {
    setState(() {
      _isLoading = true;
    });
    
    final prefs = await SharedPreferences.getInstance();
    
    // Try to get location from user profile first
    final authState = ref.read(authProvider);
    
    if (authState.status == AuthStatus.authenticated && authState.user != null) {
      setState(() {
        _selectedCityId = authState.user!.cityId != null ? authState.user!.cityId.toString() : null;
        _selectedDistrictId = authState.user!.districtId != null ? authState.user!.districtId.toString() : null;
      });
    }
    
    // If not available in user profile, check saved preferences
    setState(() {
      if (_selectedCityId == null) {
        _selectedCityId = prefs.getString('selectedCityId');
      }
      
      if (_selectedDistrictId == null) {
        _selectedDistrictId = prefs.getString('selectedDistrictId');
      }
    });
    
    setState(() {
      _isLoading = false;
    });
  }
  
  Future<void> _saveLocationPreferences() async {
    setState(() {
      _isLoading = true;
    });
    
    final prefs = await SharedPreferences.getInstance();
    
    // Save to preferences
    if (_selectedCityId != null) {
      await prefs.setString('selectedCityId', _selectedCityId!);
    } else {
      await prefs.remove('selectedCityId');
    }
    
    if (_selectedDistrictId != null) {
      await prefs.setString('selectedDistrictId', _selectedDistrictId!);
    } else {
      await prefs.remove('selectedDistrictId');
    }
    
    // Update user in database if logged in
    final authState = ref.read(authProvider);
    
    if (authState.status == AuthStatus.authenticated && authState.user != null) {
      try {
        // Assuming there's a user provider for updating user info
        await ref.read(userProviderProvider.notifier).updateUserLocation(
          _selectedCityId != null ? int.parse(_selectedCityId!) : null,
          _selectedDistrictId != null ? int.parse(_selectedDistrictId!) : null,
        );
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Konum tercihleri güncellendi'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Konum güncellenirken hata oluştu: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Konum tercihleri kaydedildi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
    
    setState(() {
      _isLoading = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konum Ayarları'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _selectedCityId == null ? null : _saveLocationPreferences,
            tooltip: 'Kaydet',
          ),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Information card
                  Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
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
                                'Konum Hakkında',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Belirlediğiniz konum, size özel içerik gösterilmesinde ve anketlerde kullanılacaktır. '
                            'İlçe seçimi isteğe bağlıdır. İlçe seçmezseniz, sadece şehir kapsamındaki içerikler gösterilir.',
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const Text(
                    'Varsayılan Konum',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Uygulama içerisinde göreceğiniz içerikler ve anketler için varsayılan konumunuzu seçin.',
                  ),
                  const SizedBox(height: 16),
                  
                  // City selection
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
                      
                      // Add "Tüm Türkiye" option at the top
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Şehir',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedCityId,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              hintText: 'Şehir seçin',
                              prefixIcon: Icon(Icons.location_city),
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Text('Tüm Türkiye'),
                              ),
                              ...cities.map((city) {
                                return DropdownMenuItem<String>(
                                  value: city.id,
                                  child: Text(city.name),
                                );
                              }).toList(),
                            ],
                            onChanged: (newValue) {
                              setState(() {
                                _selectedCityId = newValue;
                                _selectedDistrictId = null; // Reset district when city changes
                              });
                            },
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // District selection (only if city is selected)
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
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'İlçe (İsteğe bağlı)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _selectedDistrictId,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                hintText: 'İlçe seçin (İsteğe bağlı)',
                                prefixIcon: Icon(Icons.location_on),
                                border: OutlineInputBorder(),
                              ),
                              items: [
                                const DropdownMenuItem<String>(
                                  value: null,
                                  child: Text('İlçe Seçmeyin - Tüm İl'),
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
                            ),
                          ],
                        );
                      },
                    ),
                ],
              ),
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: _selectedCityId == null ? null : _saveLocationPreferences,
            child: _isLoading 
                ? const CircularProgressIndicator() 
                : const Text('Konum Ayarlarını Kaydet'),
          ),
        ),
      ),
    );
  }
}