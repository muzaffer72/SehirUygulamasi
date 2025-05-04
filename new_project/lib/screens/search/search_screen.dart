import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belediye_iletisim_merkezi/models/category.dart';
import 'package:belediye_iletisim_merkezi/models/post.dart';
import 'package:belediye_iletisim_merkezi/services/api_service.dart';
import 'package:belediye_iletisim_merkezi/widgets/post_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  
  // Arama sonuçları ve kategoriler
  List<Post> _searchResults = [];
  List<Category> _categories = [];
  List<String> _recentSearches = [];
  List<Map<String, dynamic>> _trendingSearches = [
    {'text': 'Sokak Lambaları', 'count': 2450},
    {'text': 'Çöp Toplama', 'count': 1830},
    {'text': 'Yol Çalışması', 'count': 1640},
    {'text': 'Park ve Bahçeler', 'count': 1520},
    {'text': 'Gürültü Kirliliği', 'count': 1480},
    {'text': 'Toplu Taşıma', 'count': 1350},
    {'text': 'Su Kesintisi', 'count': 1240},
    {'text': 'İnternet Altyapısı', 'count': 1120},
  ];
  
  // Durum değişkenleri
  bool _isLoading = false;
  bool _hasSearched = false;
  String _currentFilter = '';
  bool _showFilters = false;
  
  // Tab controller
  late TabController _tabController;
  int _selectedTabIndex = 0;
  
  @override
  void initState() {
    super.initState();
    
    // Son aramalar
    _loadRecentSearches();
    
    // Tab Controller başlat
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
    
    // Kategorileri yükle
    _loadCategories();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }
  
  // Son aramaları yükle - gerçek uygulamada SharedPreferences kullanılabilir
  void _loadRecentSearches() {
    setState(() {
      _recentSearches = [
        'İşitme engelliler için trafik lambası',
        'Toplu taşıma durakları',
        'Sokak hayvanları barınağı',
        'Metro istasyonu girişleri',
      ];
    });
  }
  
  // Aramaları kaydet - gerçek uygulamada SharedPreferences kullanılabilir
  void _saveSearch(String query) {
    if (query.isEmpty) return;
    
    setState(() {
      // Eğer zaten varsa önce kaldır
      _recentSearches.remove(query);
      
      // Listeye ekle
      _recentSearches.insert(0, query);
      
      // Son 5 aramayı tut
      if (_recentSearches.length > 5) {
        _recentSearches = _recentSearches.sublist(0, 5);
      }
    });
  }
  
  Future<void> _loadCategories() async {
    try {
      final categories = await _apiService.getCategories();
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      // Hata yönetimi gerekirse
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kategoriler yüklenirken hata: $e')),
        );
      }
    }
  }
  
  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    
    // Aramayı kaydet
    _saveSearch(query);
    
    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });
    
    try {
      // API'den arama sonuçlarını al
      final results = await _apiService.searchPosts(query: query, filter: _currentFilter);
      
      setState(() {
        _searchResults = results;
        _tabController.animateTo(2); // Sonuçlar sekmesine geç
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Arama yapılırken bir hata oluştu: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _searchByCategory(Category category) async {
    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _searchController.text = 'Kategori: ${category.name}';
    });
    
    try {
      final posts = await _apiService.getPosts(categoryId: category.id);
      
      setState(() {
        _searchResults = posts;
        _tabController.animateTo(2); // Sonuçlar sekmesine geç
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Arama yapılırken bir hata oluştu: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Filtre işlemleri
  void _applyFilter(String filter) {
    setState(() {
      _currentFilter = filter;
      _showFilters = false;
    });
    
    // Eğer zaten bir arama yapılmışsa, filtreyi uygula
    if (_hasSearched) {
      _performSearch();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _hasSearched && _tabController.index == 2
            ? TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Şikayet veya öneri ara...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear, color: Colors.white70),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _hasSearched = false;
                        _tabController.animateTo(0);
                      });
                    },
                  ),
                ),
                style: TextStyle(color: Colors.white),
                onSubmitted: (_) => _performSearch(),
              )
            : const Text('Ara'),
        actions: [
          if (_hasSearched && _tabController.index == 2)
            IconButton(
              icon: Icon(Icons.filter_list),
              onPressed: () {
                setState(() {
                  _showFilters = !_showFilters;
                });
              },
            ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              if (_hasSearched && _tabController.index == 2) {
                _performSearch();
              } else {
                setState(() {
                  _tabController.animateTo(0);
                });
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'ARAMA', icon: Icon(Icons.search)),
            Tab(text: 'KATEGORİLER', icon: Icon(Icons.category)),
            Tab(text: 'SONUÇLAR', icon: Icon(Icons.format_list_bulleted)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filtreler
          if (_showFilters && _hasSearched)
            Container(
              color: Colors.grey[100],
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filtreleme Seçenekleri',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('Tümü', ''),
                        _buildFilterChip('Çözüm Bekleyenler', 'awaiting'),
                        _buildFilterChip('İşlemdekiler', 'processing'),
                        _buildFilterChip('Çözülenler', 'solved'),
                        _buildFilterChip('En Yeniler', 'newest'),
                        _buildFilterChip('En Popüler', 'popular'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
          // Tab içerikleri
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSearchTab(),
                _buildCategoriesTab(),
                _buildResultsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Arama sekmesi
  Widget _buildSearchTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Arama çubuğu
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Şikayet veya öneri ara...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _performSearch(),
          ),
          
          const SizedBox(height: 24),
          
          // Son aramalar
          if (_recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Son Aramalar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _recentSearches = [];
                    });
                  },
                  child: const Text('Temizle'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentSearches.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(_recentSearches[index]),
                  trailing: const Icon(Icons.north_west, size: 16),
                  onTap: () {
                    _searchController.text = _recentSearches[index];
                    _performSearch();
                  },
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                );
              },
            ),
            const Divider(height: 32),
          ],
          
          // Trend aramalar
          const Text(
            'Trend Aramalar',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _trendingSearches.length,
            itemBuilder: (context, index) {
              final item = _trendingSearches[index];
              return ListTile(
                leading: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: index < 3 ? Theme.of(context).colorScheme.primary : Colors.grey,
                  ),
                ),
                title: Text(item['text']),
                trailing: Text(
                  '${item['count']}+',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                onTap: () {
                  _searchController.text = item['text'];
                  _performSearch();
                },
                contentPadding: EdgeInsets.zero,
                dense: true,
              );
            },
          ),
        ],
      ),
    );
  }
  
  // Kategoriler sekmesi
  Widget _buildCategoriesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kategorilere Göre Ara',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Ana kategoriler
          _categories.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    return _buildCategoryCard(category);
                  },
                ),
          
          const SizedBox(height: 32),
          
          // Popüler etiketler
          const Text(
            'Popüler Etiketler',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSearchChip('Sokak Lambaları', 3240),
              _buildSearchChip('Çöp Toplama', 2870),
              _buildSearchChip('Yol Çalışması', 2450),
              _buildSearchChip('Park ve Bahçeler', 1980),
              _buildSearchChip('Gürültü Kirliliği', 1750),
              _buildSearchChip('Toplu Taşıma', 1650),
              _buildSearchChip('Su Kesintisi', 1520),
              _buildSearchChip('İnternet Altyapısı', 1340),
              _buildSearchChip('Çukur Şikayeti', 1230),
              _buildSearchChip('Engelli Yolları', 1180),
              _buildSearchChip('Temiz Su', 1150),
              _buildSearchChip('Ağaçlandırma', 1120),
            ],
          ),
        ],
      ),
    );
  }
  
  // Sonuçlar sekmesi
  Widget _buildResultsTab() {
    // Eğer henüz arama yapılmamışsa
    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Arama yapmak için arama çubuğunu kullanın',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    // Yükleniyor durumu
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    // Sonuç bulunamadı
    if (_searchResults.isEmpty) {
      return _buildEmptyResults();
    }
    
    // Sonuçları göster
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final post = _searchResults[index];
        return PostCard(
          post: post,
          onTap: () {
            Navigator.pushNamed(
              context,
              '/post_detail',
              arguments: post,
            ).then((_) {
              // Sayfa dönüşünde yeniden yükle (beğeniler için)
              if (_hasSearched) _performSearch();
            });
          },
          onLike: () async {
            // API üzerinden beğeni işlemi
            final success = await _apiService.likePost(post.id);
            if (success && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    post.isLiked 
                        ? 'Beğeniniz kaldırıldı' 
                        : 'Gönderi beğenildi'
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
              
              // Verileri yenile
              if (_hasSearched) _performSearch();
            }
          },
          onComment: () {
            // Yorum sayfasına yönlendir
            Navigator.pushNamed(
              context,
              '/post_detail',
              arguments: post,
            ).then((_) {
              // Sayfa dönüşünde yeniden yükle (yorumlar için)
              if (_hasSearched) _performSearch();
            });
          },
        );
      },
    );
  }
  
  Widget _buildEmptyResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Sonuç bulunamadı',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Farklı anahtar kelimeler deneyebilir veya\nkategorilerden arama yapabilirsiniz',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () {
              setState(() {
                _hasSearched = false;
                _searchController.clear();
                _tabController.animateTo(0);
              });
            },
            child: const Text('Aramaya Dön'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCategoryCard(Category category) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _searchByCategory(category),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getCategoryIcon(category.iconName),
                color: Theme.of(context).colorScheme.primary,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                category.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSearchChip(String label, int count) {
    return ActionChip(
      avatar: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        radius: 8,
        child: Text(
          count.toString().length > 3 ? 'K+' : '+',
          style: TextStyle(
            fontSize: 8,
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      label: Text(label),
      labelStyle: TextStyle(fontSize: 12),
      onPressed: () {
        _searchController.text = label;
        _performSearch();
      },
      backgroundColor: Colors.grey[200],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
  
  Widget _buildFilterChip(String label, String value) {
    final isSelected = _currentFilter == value;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => _applyFilter(value),
        backgroundColor: Colors.white,
        selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected 
              ? Theme.of(context).colorScheme.primary
              : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
  
  IconData _getCategoryIcon(String? iconName) {
    switch (iconName) {
      case 'build':
        return Icons.build;
      case 'nature':
        return Icons.nature;
      case 'directions_bus':
        return Icons.directions_bus;
      case 'cleaning_services':
        return Icons.cleaning_services;
      case 'water':
        return Icons.water_drop;
      case 'electric':
        return Icons.electric_bolt;
      case 'school':
        return Icons.school;
      case 'medical':
        return Icons.medical_services;
      case 'sport':
        return Icons.sports;
      case 'wifi':
        return Icons.wifi;
      case 'accessibility':
        return Icons.accessibility;
      default:
        return Icons.category;
    }
  }
}