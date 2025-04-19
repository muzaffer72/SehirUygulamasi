import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belediye_iletisim_merkezi/models/city.dart';
import 'package:belediye_iletisim_merkezi/providers/city_profile_provider.dart';
import 'package:belediye_iletisim_merkezi/providers/api_service_provider.dart';
import 'package:belediye_iletisim_merkezi/screens/cities/city_profile_screen.dart';

class CitiesListScreen extends ConsumerWidget {
  const CitiesListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final citiesAsync = ref.watch(cityListProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Şehirler'),
        elevation: 2,
      ),
      body: citiesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Şehirler yüklenirken hata oluştu: $error'),
        ),
        data: (cities) {
          return _buildCitiesList(context, cities);
        },
      ),
    );
  }
  
  Widget _buildCitiesList(BuildContext context, List<dynamic> cities) {
    // Şehirleri alfabetik olarak sırala
    cities.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cities.length,
      itemBuilder: (context, index) {
        final city = cities[index];
        final cityId = int.parse(city['id'].toString());
        final cityName = city['name'] as String;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                cityName.substring(0, 1),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              cityName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: city['district_count'] != null 
              ? Text('${city['district_count']} ilçe')
              : null,
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CityProfileScreen(
                    cityId: cityId,
                    cityName: cityName,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}