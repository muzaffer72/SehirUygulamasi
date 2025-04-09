import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikayet_var/models/post.dart';
import 'package:sikayet_var/providers/post_provider.dart';
import 'package:sikayet_var/services/api_service.dart';

class FilterBar extends ConsumerStatefulWidget {
  const FilterBar({Key? key}) : super(key: key);

  @override
  ConsumerState<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends ConsumerState<FilterBar> {
  String? _selectedCityId;
  String? _selectedDistrictId;
  String? _selectedCategoryId;
  PostType? _selectedType;
  PostStatus? _selectedStatus;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Gönderileri Filtrele',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          // Post type filter
          const Text('Gönderi Tipi', style: TextStyle(fontWeight: FontWeight.w500)),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('Tümü'),
                selected: _selectedType == null,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedType = null;
                    });
                  }
                },
              ),
              FilterChip(
                label: const Text('Şikayet'),
                selected: _selectedType == PostType.problem,
                onSelected: (selected) {
                  setState(() {
                    _selectedType = selected ? PostType.problem : null;
                  });
                },
              ),
              FilterChip(
                label: const Text('Genel'),
                selected: _selectedType == PostType.general,
                onSelected: (selected) {
                  setState(() {
                    _selectedType = selected ? PostType.general : null;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Status filter (only for problem posts)
          if (_selectedType == PostType.problem) ...[
            const Text('Durum', style: TextStyle(fontWeight: FontWeight.w500)),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('Tümü'),
                  selected: _selectedStatus == null,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedStatus = null;
                      });
                    }
                  },
                ),
                FilterChip(
                  label: const Text('Çözüm Bekliyor'),
                  selected: _selectedStatus == PostStatus.awaitingSolution,
                  onSelected: (selected) {
                    setState(() {
                      _selectedStatus = selected ? PostStatus.awaitingSolution : null;
                    });
                  },
                ),
                FilterChip(
                  label: const Text('Çözüldü'),
                  selected: _selectedStatus == PostStatus.solved,
                  onSelected: (selected) {
                    setState(() {
                      _selectedStatus = selected ? PostStatus.solved : null;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          
          // Location filter
          const Text('Konum', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedCityId,
                  decoration: const InputDecoration(
                    labelText: 'İl',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _selectedCityId = value;
                      _selectedDistrictId = null; // Reset district when city changes
                    });
                  },
                  items: _buildCityDropdownItems(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedDistrictId,
                  decoration: const InputDecoration(
                    labelText: 'İlçe',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _selectedDistrictId = value;
                    });
                  },
                  items: _buildDistrictDropdownItems(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Category filter
          const Text('Kategori', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedCategoryId,
            decoration: const InputDecoration(
              labelText: 'Kategori',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onChanged: (value) {
              setState(() {
                _selectedCategoryId = value;
              });
            },
            items: _buildCategoryDropdownItems(),
          ),
          const SizedBox(height: 24),
          
          // Apply filters button
          ElevatedButton(
            onPressed: _applyFilters,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Filtreleri Uygula'),
          ),
          const SizedBox(height: 8),
          
          // Clear filters button
          TextButton(
            onPressed: _clearFilters,
            child: const Text('Filtreleri Temizle'),
          ),
        ],
      ),
    );
  }
  
  List<DropdownMenuItem<String>>? _buildCityDropdownItems() {
    final apiService = ApiService();
    final cities = apiService.getMockCities();
    
    return [
      const DropdownMenuItem<String>(
        value: null,
        child: Text('Tüm İller'),
      ),
      ...cities.map((city) {
        return DropdownMenuItem<String>(
          value: city.id,
          child: Text(city.name),
        );
      }).toList(),
    ];
  }
  
  List<DropdownMenuItem<String>>? _buildDistrictDropdownItems() {
    if (_selectedCityId == null) {
      return [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('Önce İl Seçin'),
        ),
      ];
    }
    
    final apiService = ApiService();
    final districts = apiService.getMockDistricts().where(
      (district) => district.cityId == _selectedCityId,
    ).toList();
    
    return [
      const DropdownMenuItem<String>(
        value: null,
        child: Text('Tüm İlçeler'),
      ),
      ...districts.map((district) {
        return DropdownMenuItem<String>(
          value: district.id,
          child: Text(district.name),
        );
      }).toList(),
    ];
  }
  
  List<DropdownMenuItem<String>>? _buildCategoryDropdownItems() {
    final apiService = ApiService();
    final categories = apiService.getMockCategories();
    
    return [
      const DropdownMenuItem<String>(
        value: null,
        child: Text('Tüm Kategoriler'),
      ),
      ...categories.map((category) {
        return DropdownMenuItem<String>(
          value: category.id,
          child: Text(category.name),
        );
      }).toList(),
    ];
  }
  
  void _applyFilters() {
    // Close the bottom sheet
    Navigator.pop(context);
    
    // Apply filters using the provider
    ref.read(postsProvider.notifier).filterPosts(
      cityId: _selectedCityId,
      districtId: _selectedDistrictId,
      categoryId: _selectedCategoryId,
      type: _selectedType,
      status: _selectedStatus,
    );
  }
  
  void _clearFilters() {
    setState(() {
      _selectedCityId = null;
      _selectedDistrictId = null;
      _selectedCategoryId = null;
      _selectedType = null;
      _selectedStatus = null;
    });
  }
}