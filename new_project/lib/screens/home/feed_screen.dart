import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belediye_iletisim_merkezi/models/post.dart';
import 'package:belediye_iletisim_merkezi/providers/post_provider.dart';
import 'package:belediye_iletisim_merkezi/widgets/filter_bar.dart';
import 'package:belediye_iletisim_merkezi/widgets/post_card.dart';
import 'package:belediye_iletisim_merkezi/widgets/survey_slider.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    
    // Başlangıçta gönderi yükleme - admin panel entegrasyonu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialPosts();
    });
  }
  
  Future<void> _loadInitialPosts() async {
    setState(() {
      _isLoading = true;
    });
    
    print('Loading initial posts');
    
    try {
      // Filtreleri kontrol et (genellikle başlangıçta boş olur)
      final filters = ref.read(postFiltersProvider);
      
      // Filtre varsa filtreli yükle, yoksa tümünü yükle
      if (filters.hasFilters) {
        await ref.read(postsProvider.notifier).filterPosts(
          cityId: filters.cityId,
          districtId: filters.districtId,
          categoryId: filters.categoryId,
          refresh: true,
        );
      } else {
        await ref.read(postsProvider.notifier).loadPosts(refresh: true);
      }
    } catch (e) {
      print('Error loading initial posts: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gönderiler yüklenirken bir hata oluştu')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }
  
  void _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent - 100 &&
        !_scrollController.position.outOfRange &&
        !_isLoading) {
      _loadMoreData();
    }
  }
  
  Future<void> _loadMoreData() async {
    // Only do this if we have posts already
    final posts = ref.read(postsProvider);
    if (posts.isEmpty) return;
    
    setState(() {
      _isLoading = true;
    });
    
    // Get the filters
    final filters = ref.read(postFiltersProvider);
    
    // Load more posts - refresh = false yaparak mevcut verilere ekle
    await ref.read(postsProvider.notifier).filterPosts(
      cityId: filters.cityId,
      districtId: filters.districtId,
      categoryId: filters.categoryId,
      refresh: false, // Yani sayfa, mevcut verilere ekle
    );
    
    setState(() {
      _isLoading = false;
    });
  }
  
  Future<void> _refreshData() async {
    final filters = ref.read(postFiltersProvider);
    
    // refresh = true yaparak yeniden yükle
    await ref.read(postsProvider.notifier).filterPosts(
      cityId: filters.cityId,
      districtId: filters.districtId,
      categoryId: filters.categoryId,
      refresh: true, // Tam yenileme, verileri sıfırla
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final posts = ref.watch(postsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('ŞikayetVar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bildirimler yakında eklenecek')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Bar
          FilterBar(
            onFilterApplied: (cityId, districtId, categoryId) {
              // State güncellemesi
              ref.read(cityFilterProvider.notifier).state = cityId;
              ref.read(districtFilterProvider.notifier).state = districtId;
              ref.read(categoryFilterProvider.notifier).state = categoryId;
              
              // API ile filtreleme
              print('Applying filters: cityId=$cityId, districtId=$districtId, categoryId=$categoryId');
              ref.read(postsProvider.notifier).filterPosts(
                cityId: cityId,
                districtId: districtId,
                categoryId: categoryId,
                refresh: true, // Filtreler değiştiğinde yeniden yükle
              );
            },
            onFilterCleared: () {
              // State temizleme
              ref.read(cityFilterProvider.notifier).state = null;
              ref.read(districtFilterProvider.notifier).state = null;
              ref.read(categoryFilterProvider.notifier).state = null;
              
              // Tüm gönderileri yeniden yükle
              print('Clearing all filters, reloading posts');
              ref.read(postsProvider.notifier).loadPosts(refresh: true);
            },
          ),
          
          // Feed Content
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshData,
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // Survey Slider
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                            child: Text(
                              'Aktif Anketler',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                          const SurveySlider(),
                        ],
                      ),
                    ),
                  ),
                  
                  // Post List Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Güncel Gönderiler',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.sort),
                            onPressed: () {
                              _showSortingOptions(context);
                            },
                            tooltip: 'Sıralama',
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Posts List
                  if (posts.isEmpty)
                    const SliverFillRemaining(
                      child: Center(
                        child: Text('Henüz gönderi yok'),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index == posts.length) {
                            return _isLoading
                                ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                : const SizedBox.shrink();
                          }
                          
                          final post = posts[index];
                          return PostCard(
                            post: post,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/post_detail',
                                arguments: post,
                              );
                            },
                            onLike: () async {
                              await ref.read(postsProvider.notifier).likePost(post.id);
                            },
                            onHighlight: () async {
                              await ref.read(postsProvider.notifier).highlightPost(post.id);
                            },
                          );
                        },
                        childCount: posts.length + 1,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showSortingOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Sıralama',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.schedule),
                title: const Text('En Son'),
                onTap: () {
                  Navigator.pop(context);
                  _sortPosts('latest');
                },
              ),
              ListTile(
                leading: const Icon(Icons.trending_up),
                title: const Text('En Popüler'),
                onTap: () {
                  Navigator.pop(context);
                  _sortPosts('popular');
                },
              ),
              ListTile(
                leading: const Icon(Icons.star),
                title: const Text('Öne Çıkanlar'),
                onTap: () {
                  Navigator.pop(context);
                  _sortPosts('highlighted');
                },
              ),
              ListTile(
                leading: const Icon(Icons.warning),
                title: const Text('Sadece Şikayetler'),
                onTap: () {
                  Navigator.pop(context);
                  _filterPostsByType(PostType.problem);
                },
              ),
              ListTile(
                leading: const Icon(Icons.lightbulb),
                title: const Text('Sadece Öneriler'),
                onTap: () {
                  Navigator.pop(context);
                  _filterPostsByType(PostType.general);
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  void _sortPosts(String sortBy) {
    // Mevcut filtreleri al
    final filters = ref.read(postFiltersProvider);
    
    // API ile gönderileri sırala
    print('Sorting posts by: $sortBy');
    ref.read(postsProvider.notifier).filterPosts(
      cityId: filters.cityId,
      districtId: filters.districtId,
      categoryId: filters.categoryId,
      sortBy: sortBy,
      refresh: true,
    );
    
    // Kullanıcıya bildirim göster
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gönderiler "$sortBy" olarak sıralandı')),
    );
  }
  
  void _filterPostsByType(PostType type) {
    // Mevcut filtreleri al
    final filters = ref.read(postFiltersProvider);
    final typeStr = type == PostType.problem ? 'problem' : 'general';
    
    // API ile gönderileri filtrele
    print('Filtering posts by type: $typeStr');
    ref.read(postsProvider.notifier).filterPosts(
      cityId: filters.cityId,
      districtId: filters.districtId,
      categoryId: filters.categoryId,
      type: typeStr,
      refresh: true,
    );
    
    // Kullanıcıya bildirim göster
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          type == PostType.problem
              ? 'Sadece şikayetler gösteriliyor'
              : 'Sadece öneriler gösteriliyor',
        ),
      ),
    );
  }
}