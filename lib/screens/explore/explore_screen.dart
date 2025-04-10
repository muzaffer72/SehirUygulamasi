import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:sikayet_var/models/city.dart';
import 'package:sikayet_var/models/district.dart';
import 'package:sikayet_var/models/post.dart';
import 'package:sikayet_var/providers/city_provider.dart';
import 'package:sikayet_var/providers/post_provider.dart';
import 'package:sikayet_var/screens/location/city_profile_screen.dart';
import 'package:sikayet_var/screens/location/district_profile_screen.dart';
import 'package:sikayet_var/screens/posts/post_detail_screen.dart';
import 'package:sikayet_var/widgets/post_card.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> with SingleTickerProviderStateMixin {
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<TabController>('_tabController', _tabController));
  }
  
  @override
  void activate() {
    super.activate();
  }
  late TabController _tabController;
  String? _selectedCityId;
  String? _selectedDistrictId;
  String? _selectedCategoryId;
  PostType? _selectedType;
  PostStatus? _selectedStatus;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _applyFilters();
      }
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    ref.read(postsProvider.notifier).filterPosts(
      cityId: _selectedCityId,
      districtId: _selectedDistrictId,
      categoryId: _selectedCategoryId,
      type: _selectedType,
      status: _selectedStatus,
      sortBy: _tabController.index == 0 ? 'newest' : 
              _tabController.index == 1 ? 'popular' : 'highlighted',
    );
  }

  @override
  Widget build(BuildContext context) {
    final citiesAsync = ref.watch(citiesProvider);
    final districtsAsync = _selectedCityId == null 
        ? const AsyncValue<List<District>>.data([]) 
        : ref.watch(districtsProvider(_selectedCityId!));
    final postsAsync = ref.watch(postsProvider);
    
    // Mock categories for now - in a real app these would come from the API
    final categories = [
      {'id': 'cat_1', 'name': 'Altyapı'},
      {'id': 'cat_2', 'name': 'Ulaşım'},
      {'id': 'cat_3', 'name': 'Parklar'},
      {'id': 'cat_4', 'name': 'Temizlik'},
      {'id': 'cat_5', 'name': 'Güvenlik'},
      {'id': 'cat_6', 'name': 'Diğer'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keşfet'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'En Yeni'),
            Tab(text: 'Popüler'),
            Tab(text: 'Öne Çıkan'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filter section
          Card(
            margin: const EdgeInsets.all(8.0),
            child: ExpansionTile(
              title: const Text('Filtreler'),
              subtitle: Text(
                _getActiveFiltersText(),
                style: const TextStyle(fontSize: 12),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // City dropdown
                      const Text('Şehir:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      citiesAsync.when(
                        data: (cities) => DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                          value: _selectedCityId,
                          hint: const Text('Şehir seçin'),
                          isExpanded: true,
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('Tümü'),
                            ),
                            ...cities.map((city) => DropdownMenuItem<String>(
                              value: city.id,
                              child: Text(city.name),
                            )).toList(),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedCityId = value;
                              _selectedDistrictId = null; // Reset district when city changes
                            });
                            _applyFilters();
                          },
                        ),
                        loading: () => const SizedBox(
                          height: 48,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (_, __) => const Text('Şehirler yüklenemedi'),
                      ),
                      const SizedBox(height: 16),
                      
                      // District dropdown (only if city is selected)
                      if (_selectedCityId != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('İlçe:', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            districtsAsync.when(
                              data: (districts) => DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  isDense: true,
                                  border: OutlineInputBorder(),
                                ),
                                value: _selectedDistrictId,
                                hint: const Text('İlçe seçin'),
                                isExpanded: true,
                                items: [
                                  const DropdownMenuItem<String>(
                                    value: null,
                                    child: Text('Tümü'),
                                  ),
                                  ...districts.map((district) => DropdownMenuItem<String>(
                                    value: district.id,
                                    child: Text(district.name),
                                  )).toList(),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedDistrictId = value;
                                  });
                                  _applyFilters();
                                },
                              ),
                              loading: () => const SizedBox(
                                height: 48,
                                child: Center(child: CircularProgressIndicator()),
                              ),
                              error: (_, __) => const Text('İlçeler yüklenemedi'),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      
                      // Category dropdown
                      const Text('Kategori:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedCategoryId,
                        hint: const Text('Kategori seçin'),
                        isExpanded: true,
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('Tümü'),
                          ),
                          ...categories.map((category) => DropdownMenuItem<String>(
                            value: category['id'],
                            child: Text(category['name']!),
                          )).toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCategoryId = value;
                          });
                          _applyFilters();
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Post type selection
                      const Text('Gönderi Tipi:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Flexible(
                            child: RadioListTile<PostType?>(
                              title: const Text('Tümü'),
                              value: null,
                              groupValue: _selectedType,
                              contentPadding: EdgeInsets.zero,
                              onChanged: (value) {
                                setState(() {
                                  _selectedType = value;
                                });
                                _applyFilters();
                              },
                            ),
                          ),
                          Flexible(
                            child: RadioListTile<PostType>(
                              title: const Text('Genel'),
                              value: PostType.general,
                              groupValue: _selectedType,
                              contentPadding: EdgeInsets.zero,
                              onChanged: (value) {
                                setState(() {
                                  _selectedType = value;
                                  _selectedStatus = null; // Reset status for general posts
                                });
                                _applyFilters();
                              },
                            ),
                          ),
                          Flexible(
                            child: RadioListTile<PostType>(
                              title: const Text('Sorun'),
                              value: PostType.problem,
                              groupValue: _selectedType,
                              contentPadding: EdgeInsets.zero,
                              onChanged: (value) {
                                setState(() {
                                  _selectedType = value;
                                });
                                _applyFilters();
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      // Status selection (only for problem type)
                      if (_selectedType == PostType.problem)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            const Text('Durum:', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Flexible(
                                  child: RadioListTile<PostStatus?>(
                                    title: const Text('Tümü'),
                                    value: null,
                                    groupValue: _selectedStatus,
                                    contentPadding: EdgeInsets.zero,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedStatus = value;
                                      });
                                      _applyFilters();
                                    },
                                  ),
                                ),
                                Flexible(
                                  child: RadioListTile<PostStatus>(
                                    title: const Text('Bekleyen'),
                                    value: PostStatus.awaitingSolution,
                                    groupValue: _selectedStatus,
                                    contentPadding: EdgeInsets.zero,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedStatus = value;
                                      });
                                      _applyFilters();
                                    },
                                  ),
                                ),
                                Flexible(
                                  child: RadioListTile<PostStatus>(
                                    title: const Text('Çözüldü'),
                                    value: PostStatus.solved,
                                    groupValue: _selectedStatus,
                                    contentPadding: EdgeInsets.zero,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedStatus = value;
                                      });
                                      _applyFilters();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      
                      const SizedBox(height: 16),
                      
                      // Reset filters button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _selectedCityId = null;
                              _selectedDistrictId = null;
                              _selectedCategoryId = null;
                              _selectedType = null;
                              _selectedStatus = null;
                            });
                            _applyFilters();
                          },
                          icon: const Icon(Icons.clear),
                          label: const Text('Filtreleri Temizle'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Locations section
          if (_selectedCityId == null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: Text(
                      'Populer Şehirler:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 120,
                    child: citiesAsync.when(
                      data: (cities) {
                        // Sort by issue count or use a subset
                        final popularCities = cities.take(10).toList();
                        
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: popularCities.length,
                          itemBuilder: (context, index) {
                            final city = popularCities[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CityProfileScreen(cityId: city.id),
                                  ),
                                );
                              },
                              child: Container(
                                width: 100,
                                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundImage: city.logoUrl != null
                                          ? NetworkImage(city.logoUrl!)
                                          : null,
                                      child: city.logoUrl == null
                                          ? const Icon(Icons.location_city, size: 30)
                                          : null,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      city.name,
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${city.solvedIssuesCount}/${city.totalIssuesCount}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: city.solutionRate > 0.7 ? Colors.green : 
                                              city.solutionRate > 0.4 ? Colors.orange : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (_, __) => const Center(child: Text('Şehirler yüklenemedi')),
                    ),
                  ),
                ],
              ),
            ),
          
          // Posts list
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Most recent posts
                _buildPostsList(postsAsync),
                
                // Popular posts (most liked)
                _buildPostsList(postsAsync),
                
                // Highlighted posts
                _buildPostsList(postsAsync),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPostsList(AsyncValue<List<Post>> postsAsync) {
    return RefreshIndicator(
      onRefresh: () async {
        _applyFilters();
      },
      child: postsAsync.when(
        data: (posts) {
          if (posts.isEmpty) {
            return const Center(
              child: Text('Bu kriterlere uygun gönderi bulunamadı'),
            );
          }
          
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return PostCard(
                post: post,
                onTap: () {
                  ref.read(selectedPostProvider.notifier).state = post;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostDetailScreen(post: post),
                    ),
                  );
                },
                onLike: () {
                  ref.read(postsProvider.notifier).likePost(post.id);
                },
                onHighlight: () {
                  ref.read(postsProvider.notifier).highlightPost(post.id);
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Gönderiler yüklenirken bir hata oluştu: $error'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _applyFilters,
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _getActiveFiltersText() {
    final List<String> activeFilters = [];
    
    if (_selectedCityId != null) {
      activeFilters.add('Şehir');
    }
    
    if (_selectedDistrictId != null) {
      activeFilters.add('İlçe');
    }
    
    if (_selectedCategoryId != null) {
      activeFilters.add('Kategori');
    }
    
    if (_selectedType != null) {
      activeFilters.add(_selectedType == PostType.problem ? 'Sorun' : 'Genel');
    }
    
    if (_selectedStatus != null) {
      activeFilters.add(_selectedStatus == PostStatus.solved ? 'Çözüldü' : 'Bekliyor');
    }
    
    if (activeFilters.isEmpty) {
      return 'Aktif filtre yok';
    }
    
    return 'Aktif filtreler: ${activeFilters.join(', ')}';
  }
}
