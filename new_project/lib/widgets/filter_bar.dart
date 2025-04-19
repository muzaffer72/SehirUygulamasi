import 'package:flutter/material.dart';
import 'package:belediye_iletisim_merkezi/models/category.dart';
import 'package:belediye_iletisim_merkezi/models/city.dart';
import 'package:belediye_iletisim_merkezi/models/district.dart';
import 'package:belediye_iletisim_merkezi/services/api_service.dart';

class FilterBar extends StatefulWidget {
  final Function(String?, String?, String?) onFilterApplied;
  final VoidCallback onFilterCleared;
  // Yeni özellikler: Sadece şehir veya ilçe görüntüleme
  final bool cityOnly;
  final bool districtOnly;
  
  const FilterBar({
    Key? key,
    required this.onFilterApplied,
    required this.onFilterCleared,
    this.cityOnly = false,
    this.districtOnly = false,
  }) : super(key: key);

  @override
  State<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  final ApiService _apiService = ApiService();
  
  String? _selectedCityId;
  String? _selectedDistrictId;
  String? _selectedCategoryId;
  
  bool _isExpanded = false;
  bool _hasFilters = false;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Filter bar header
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.filter_list),
                const SizedBox(width: 8),
                const Text(
                  'Filtrele',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_hasFilters)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Aktif',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Icon(
                  _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                ),
              ],
            ),
          ),
        ),
        
        // Filter options
        if (_isExpanded)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Şehir ekranında gösterilecek filtreler
                if (!widget.districtOnly)
                FutureBuilder(
                  future: _apiService.getCities(),
                  builder: (context, AsyncSnapshot<List<City>> snapshot) {
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
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('Tümü'),
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
                    );
                  },
                ),
                if (!widget.districtOnly) const SizedBox(height: 16),
                
                // İlçe filtresi (şehir ekranında bu gösterilmeyecek, ilçe ekranında gösterilecek)
                if (!widget.cityOnly && (widget.districtOnly || _selectedCityId != null))
                  FutureBuilder(
                    future: _apiService.getDistrictsByCityId(_selectedCityId ?? ''),
                    builder: (context, AsyncSnapshot<List<District>> snapshot) {
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
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('Tümü'),
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
                if (!widget.cityOnly && (widget.districtOnly || _selectedCityId != null)) const SizedBox(height: 16),
                
                // Kategori filtresi (her iki ekranda da gösterilecek)
                FutureBuilder(
                  future: _apiService.getCategories(),
                  builder: (context, AsyncSnapshot<List<Category>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text('Kategori verisi bulunamadı');
                    }
                    
                    final categories = snapshot.data!;
                    
                    return DropdownButtonFormField<String>(
                      value: _selectedCategoryId,
                      decoration: const InputDecoration(
                        labelText: 'Kategori',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('Tümü'),
                        ),
                        ...categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category.id,
                            child: Text(category.name),
                          );
                        }).toList(),
                      ],
                      onChanged: (newValue) {
                        setState(() {
                          _selectedCategoryId = newValue;
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),
                
                // Filter action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Clear filters
                    OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _selectedCityId = null;
                          _selectedDistrictId = null;
                          _selectedCategoryId = null;
                          _hasFilters = false;
                        });
                        widget.onFilterCleared();
                      },
                      child: const Text('Temizle'),
                    ),
                    const SizedBox(width: 16),
                    
                    // Apply filters
                    ElevatedButton(
                      onPressed: () {
                        final hasActiveFilters = _selectedCityId != null || 
                                             _selectedDistrictId != null || 
                                             _selectedCategoryId != null;
                        
                        setState(() {
                          _hasFilters = hasActiveFilters;
                          _isExpanded = false;
                        });
                        
                        widget.onFilterApplied(
                          _selectedCityId,
                          _selectedDistrictId,
                          _selectedCategoryId,
                        );
                      },
                      child: const Text('Uygula'),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}