import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/city_profile.dart';
import '../../services/api_service.dart';
import '../../widgets/app_shimmer.dart';
import '../location/city_profile_screen.dart';

// Şehir listesi için basit bir provider
final citiesProvider = FutureProvider<List<CityProfile>>((ref) async {
  final apiService = ApiService();
  final cities = await apiService.getCities();
  // City -> CityProfile dönüşümü yap
  return cities.map((city) => CityProfile(
    id: city.id,
    cityId: city.id,
    name: city.name,
    complaintCount: city.complaintCount ?? 0,
    districtCount: city.districtCount ?? 0,
    problemSolvingRate: city.solutionRate,
  )).toList();
});

class CitiesListScreen extends ConsumerWidget {
  const CitiesListScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final citiesAsyncValue = ref.watch(citiesProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Şehirler'),
        elevation: 0.5,
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Şehir arama özelliği yakında!'))
              );
            },
          ),
        ],
      ),
      body: citiesAsyncValue.when(
        data: (cities) => _buildCitiesList(context, cities),
        loading: () => _buildLoadingShimmer(),
        error: (error, stack) => _buildErrorWidget(context, error),
      ),
    );
  }
  
  Widget _buildCitiesList(BuildContext context, List<CityProfile> cities) {
    if (cities.isEmpty) {
      return const Center(
        child: Text('Henüz şehir bilgisi bulunmuyor.'),
      );
    }
    
    return ListView.builder(
      itemCount: cities.length,
      itemBuilder: (context, index) {
        final city = cities[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(city.name.substring(0, 1)),
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            ),
            title: Text(city.name),
            subtitle: Text('${city.complaintCount} şikayet, ${city.districtCount} ilçe'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Şehirin performans puanı
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getScoreColor(city.problemSolvingRate ?? 0.0),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '%${(city.problemSolvingRate ?? 0.0).toInt()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
            onTap: () {
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => CityProfileScreen(
                    cityId: city.id,
                    cityName: city.name,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
  
  Color _getScoreColor(double score) {
    if (score >= 75) {
      return Colors.green[600]!;
    } else if (score >= 50) {
      return Colors.orange[600]!;
    } else {
      return Colors.red[600]!;
    }
  }
  
  Widget _buildLoadingShimmer() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return const Card(
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: AppShimmer(
            child: ListTile(
              leading: CircleAvatar(),
              title: SizedBox(height: 12, width: 100),
              subtitle: SizedBox(height: 8, width: 150),
              trailing: SizedBox(width: 50),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildErrorWidget(BuildContext context, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 60,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          const Text(
            'Şehir bilgileri yüklenirken bir hata oluştu',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Provider'ı yenileyin
              // ignore: deprecated_member_use
              context.findAncestorStateOfType<ProviderState>()?.refresh(citiesProvider);
            },
            child: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }
}