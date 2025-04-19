import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Ana sayfadaki filtreleme çubuğu
class FilterBar extends ConsumerStatefulWidget {
  final void Function(String? cityId, String? districtId, String? categoryId)? onFilterApplied;
  final VoidCallback? onFilterCleared;

  const FilterBar({
    Key? key,
    this.onFilterApplied,
    this.onFilterCleared,
  }) : super(key: key);

  @override
  ConsumerState<FilterBar> createState() => _FilterBarState();
}

// Filtre seçimleri için simple provider'lar
final cityFilterProvider = StateProvider<String?>((ref) => null);
final districtFilterProvider = StateProvider<String?>((ref) => null);
final categoryFilterProvider = StateProvider<String?>((ref) => null);

// Tüm filtre kombinasyonu için bir provider
final postFiltersProvider = Provider<PostFilters>((ref) {
  final cityId = ref.watch(cityFilterProvider);
  final districtId = ref.watch(districtFilterProvider);
  final categoryId = ref.watch(categoryFilterProvider);
  
  return PostFilters(
    cityId: cityId,
    districtId: districtId,
    categoryId: categoryId,
  );
});

class PostFilters {
  final String? cityId;
  final String? districtId;
  final String? categoryId;
  
  const PostFilters({
    this.cityId,
    this.districtId,
    this.categoryId,
  });
  
  bool get hasFilters => cityId != null || districtId != null || categoryId != null;
}

class _FilterBarState extends ConsumerState<FilterBar> {
  // Kategoriler için örnek veri
  final List<Map<String, dynamic>> _categories = [
    {'id': '1', 'name': 'Temizlik', 'icon': Icons.cleaning_services},
    {'id': '2', 'name': 'Trafik', 'icon': Icons.traffic},
    {'id': '3', 'name': 'Ulaşım', 'icon': Icons.directions_bus},
    {'id': '4', 'name': 'Park & Bahçe', 'icon': Icons.park},
    {'id': '5', 'name': 'Güvenlik', 'icon': Icons.shield},
    {'id': '6', 'name': 'Altyapı', 'icon': Icons.construction},
    {'id': '7', 'name': 'Eğitim', 'icon': Icons.school},
    {'id': '8', 'name': 'Sağlık', 'icon': Icons.local_hospital},
  ];
  
  // Şehirler için örnek veri
  final List<Map<String, dynamic>> _cities = [
    {'id': '34', 'name': 'İstanbul'},
    {'id': '6', 'name': 'Ankara'},
    {'id': '35', 'name': 'İzmir'},
    {'id': '16', 'name': 'Bursa'},
    {'id': '1', 'name': 'Adana'},
    {'id': '42', 'name': 'Konya'},
    {'id': '7', 'name': 'Antalya'},
    {'id': '55', 'name': 'Samsun'},
  ];
  
  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(postFiltersProvider);
    
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          // Şehir filtreleme butonu
          _buildFilterButton(
            label: filters.cityId != null 
                ? _cities.firstWhere((c) => c['id'] == filters.cityId)['name'] 
                : 'Şehir',
            icon: Icons.location_city,
            isActive: filters.cityId != null,
            onTap: _showCityFilterSheet,
          ),
          
          // Kategori filtreleme butonu
          _buildFilterButton(
            label: filters.categoryId != null 
                ? _categories.firstWhere((c) => c['id'] == filters.categoryId)['name'] 
                : 'Kategori',
            icon: Icons.category,
            isActive: filters.categoryId != null,
            onTap: _showCategoryFilterSheet,
          ),
          
          const Spacer(),
          
          // Filtre temizleme butonu
          if (filters.hasFilters)
            IconButton(
              icon: const Icon(Icons.clear, size: 18),
              onPressed: () {
                // Tüm filtreleri temizle
                ref.read(cityFilterProvider.notifier).state = null;
                ref.read(districtFilterProvider.notifier).state = null;
                ref.read(categoryFilterProvider.notifier).state = null;
                
                // Callback'i çağır
                widget.onFilterCleared?.call();
              },
              tooltip: 'Filtreleri Temizle',
            ),
        ],
      ),
    );
  }
  
  Widget _buildFilterButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isActive 
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive 
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                  : Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: isActive 
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: isActive 
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[700],
                  fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showCityFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 16),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text(
                    'Şehir Seçin',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ref.read(cityFilterProvider.notifier).state = null;
                      
                      // Callback'i çağır
                      widget.onFilterApplied?.call(
                        null,
                        ref.read(districtFilterProvider),
                        ref.read(categoryFilterProvider),
                      );
                    },
                    child: const Text('Temizle'),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: _cities.length,
                itemBuilder: (context, index) {
                  final city = _cities[index];
                  final selected = ref.read(cityFilterProvider) == city['id'];
                  
                  return ListTile(
                    title: Text(city['name']),
                    leading: const Icon(Icons.location_city),
                    trailing: selected 
                        ? Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                    selected: selected,
                    onTap: () {
                      Navigator.pop(context);
                      ref.read(cityFilterProvider.notifier).state = city['id'];
                      
                      // Callback'i çağır
                      widget.onFilterApplied?.call(
                        city['id'],
                        ref.read(districtFilterProvider),
                        ref.read(categoryFilterProvider),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
  
  void _showCategoryFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 16),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text(
                    'Kategori Seçin',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ref.read(categoryFilterProvider.notifier).state = null;
                      
                      // Callback'i çağır
                      widget.onFilterApplied?.call(
                        ref.read(cityFilterProvider),
                        ref.read(districtFilterProvider),
                        null,
                      );
                    },
                    child: const Text('Temizle'),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final selected = ref.read(categoryFilterProvider) == category['id'];
                  
                  return InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      ref.read(categoryFilterProvider.notifier).state = category['id'];
                      
                      // Callback'i çağır
                      widget.onFilterApplied?.call(
                        ref.read(cityFilterProvider),
                        ref.read(districtFilterProvider),
                        category['id'],
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selected
                              ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                              : Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            category['icon'],
                            size: 20,
                            color: selected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              category['name'],
                              style: TextStyle(
                                color: selected
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey[800],
                                fontWeight: selected ? FontWeight.w500 : FontWeight.normal,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (selected)
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}