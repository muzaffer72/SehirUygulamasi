import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikayet_var/models/category.dart';
import 'package:sikayet_var/models/city.dart';
import 'package:sikayet_var/models/district.dart';
import 'package:sikayet_var/providers/auth_provider.dart';
import 'package:sikayet_var/services/api_service.dart';

class FilterBar extends ConsumerStatefulWidget {
  final Function(String?, String?, String?) onFilterApplied;
  final Function() onFilterCleared;

  const FilterBar({
    Key? key,
    required this.onFilterApplied,
    required this.onFilterCleared,
  }) : super(key: key);

  @override
  ConsumerState<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends ConsumerState<FilterBar> {
  String? _selectedCityId;
  String? _selectedDistrictId;
  String? _selectedCategoryId;
  bool _isExpanded = false;
  
  final ApiService _apiService = ApiService();
  
  @override
  void initState() {
    super.initState();
    
    // Initialize filters with current user's city/district if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser != null && currentUser.cityId != null) {
        setState(() {
          _selectedCityId = currentUser.cityId;
          _selectedDistrictId = currentUser.districtId;
        });
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter bar header
        InkWell(
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filtreleme ve Sıralama',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                ),
              ],
            ),
          ),
        ),
        
        // Expanded filter options
        if (_isExpanded)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // City dropdown
                _buildCityDropdown(),
                const SizedBox(height: 16),
                
                // District dropdown (only if city is selected)
                if (_selectedCityId != null) _buildDistrictDropdown(),
                if (_selectedCityId != null) const SizedBox(height: 16),
                
                // Category dropdown
                _buildCategoryDropdown(),
                const SizedBox(height: 24),
                
                // Filter action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: _clearFilters,
                      child: const Text('Temizle'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _applyFilters,
                      child: const Text('Uygula'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        
        // Applied filters indicator
        if (_hasActiveFilters())
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            child: Row(
              children: [
                const Icon(Icons.filter_list, size: 16),
                const SizedBox(width: 8),
                const Text('Aktif filtreler:'),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getActiveFiltersText(),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.clear, size: 16),
                  onPressed: _clearFilters,
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
      ],
    );
  }
  
  Widget _buildCityDropdown() {
    return FutureBuilder(
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
            prefixIcon: Icon(Icons.location_city),
          ),
          hint: const Text('Şehir seçin'),
          isExpanded: true,
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
    );
  }
  
  Widget _buildDistrictDropdown() {
    if (_selectedCityId == null) {
      return const SizedBox.shrink();
    }
    
    return FutureBuilder(
      future: _apiService.getDistrictsByCityId(_selectedCityId!),
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
            prefixIcon: Icon(Icons.location_on),
          ),
          hint: const Text('İlçe seçin'),
          isExpanded: true,
          items: districts.map((district) {
            return DropdownMenuItem<String>(
              value: district.id,
              child: Text(district.name),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedDistrictId = newValue;
            });
          },
        );
      },
    );
  }
  
  Widget _buildCategoryDropdown() {
    return FutureBuilder(
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
            prefixIcon: Icon(Icons.category),
          ),
          hint: const Text('Kategori seçin'),
          isExpanded: true,
          items: categories.map((category) {
            return DropdownMenuItem<String>(
              value: category.id,
              child: Text(category.name),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedCategoryId = newValue;
            });
          },
        );
      },
    );
  }
  
  void _applyFilters() {
    widget.onFilterApplied(
      _selectedCityId,
      _selectedDistrictId,
      _selectedCategoryId,
    );
    
    // Close the filter panel after applying
    setState(() {
      _isExpanded = false;
    });
  }
  
  void _clearFilters() {
    setState(() {
      _selectedCityId = null;
      _selectedDistrictId = null;
      _selectedCategoryId = null;
    });
    
    widget.onFilterCleared();
    
    // Close the filter panel after clearing
    setState(() {
      _isExpanded = false;
    });
  }
  
  bool _hasActiveFilters() {
    return _selectedCityId != null || 
           _selectedDistrictId != null || 
           _selectedCategoryId != null;
  }
  
  String _getActiveFiltersText() {
    List<String> filters = [];
    
    if (_selectedCityId != null) {
      filters.add('Şehir');
    }
    
    if (_selectedDistrictId != null) {
      filters.add('İlçe');
    }
    
    if (_selectedCategoryId != null) {
      filters.add('Kategori');
    }
    
    return filters.join(', ');
  }
}