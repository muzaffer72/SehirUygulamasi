import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikayet_var/models/post.dart';
import 'package:sikayet_var/providers/post_provider.dart';
import 'package:sikayet_var/widgets/filter_bar.dart';
import 'package:sikayet_var/widgets/post_card.dart';
import 'package:sikayet_var/widgets/survey_slider.dart';

// Post filtreleme state'leri için provider'lar
final cityFilterProvider = StateProvider<String?>((ref) => null);
final districtFilterProvider = StateProvider<String?>((ref) => null);
final categoryFilterProvider = StateProvider<String?>((ref) => null);

// Filtre değerlerini birleştiren provider
final postFiltersProvider = Provider<PostFilter>((ref) {
  final cityId = ref.watch(cityFilterProvider);
  final districtId = ref.watch(districtFilterProvider);
  final categoryId = ref.watch(categoryFilterProvider);
  
  return PostFilter(
    cityId: cityId,
    districtId: districtId,
    categoryId: categoryId,
  );
});

// Filtre değerlerini taşıyan model sınıfı
class PostFilter {
  final String? cityId;
  final String? districtId;
  final String? categoryId;
  
  PostFilter({
    this.cityId,
    this.districtId,
    this.categoryId,
  });
}

class CityFeedScreen extends ConsumerStatefulWidget {
  const CityFeedScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CityFeedScreen> createState() => _CityFeedScreenState();
}

class _CityFeedScreenState extends ConsumerState<CityFeedScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    
    // İlk yüklemede şehir filtresiyle gönderileri getir
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final filters = ref.read(postFiltersProvider);
      // Şehir bazlı filtreleme yap - şehir belirtilmeli, ilçe boş olmalı
      if (filters.cityId != null) {
        ref.read(postsProvider.notifier).filterPosts(
          cityId: filters.cityId,
          districtId: null, // İlçe filtresini kullanma
          categoryId: filters.categoryId,
        );
      }
    });
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
    
    // Simulate loading more data
    await Future.delayed(const Duration(seconds: 1));
    
    // Get the filters
    final filters = ref.read(postFiltersProvider);
    
    // Load more posts with city filter only (no district)
    await ref.read(postsProvider.notifier).filterPosts(
      cityId: filters.cityId,
      districtId: null, // No district filter for city view
      categoryId: filters.categoryId,
    );
    
    setState(() {
      _isLoading = false;
    });
  }
  
  Future<void> _refreshData() async {
    final filters = ref.read(postFiltersProvider);
    
    await ref.read(postsProvider.notifier).filterPosts(
      cityId: filters.cityId,
      districtId: null, // No district filter for city view
      categoryId: filters.categoryId,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final posts = ref.watch(postsProvider);
    final filters = ref.watch(postFiltersProvider);
    final cityId = filters.cityId; // Aktif şehir ID'si
    
    return Scaffold(
      body: Column(
        children: [
          // Filtrele kısmını gizledik
          
          // Geri kalan içerik
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshData,
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // Şehir Başlığı (Eğer şehir seçiliyse)
                  if (cityId != null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_city,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Şehir Gönderileri',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  
                  // Anket Slider
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                            child: Text(
                              'Şehir Anketleri',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          const SurveySlider(filterType: 'city'),
                        ],
                      ),
                    ),
                  ),
                  
                  // Post Listesi Başlığı
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Şehir Gönderileri',
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
                  
                  // Post Listesi
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
    // Gerçek uygulamada, bu fonksiyon sıralama parametreleriyle bir API çağrısı yapacak
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Şehir gönderileri "$sortBy" olarak sıralandı')),
    );
  }
  
  void _filterPostsByType(PostType type) {
    // Gerçek uygulamada, bu fonksiyon filtre parametreleriyle bir API çağrısı yapacak
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          type == PostType.problem
              ? 'Sadece şehir şikayetleri gösteriliyor'
              : 'Sadece şehir önerileri gösteriliyor',
        ),
      ),
    );
  }
}