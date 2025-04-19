import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belediye_iletisim_merkezi/models/post.dart';
import 'package:belediye_iletisim_merkezi/models/city_profile.dart';
import 'package:belediye_iletisim_merkezi/providers/post_provider.dart' as post_provider;
import 'package:belediye_iletisim_merkezi/providers/theme_provider.dart';
import 'package:belediye_iletisim_merkezi/widgets/filter_bar.dart' as filter_widgets;
import 'package:belediye_iletisim_merkezi/widgets/post_card.dart';
import 'package:belediye_iletisim_merkezi/widgets/survey_slider.dart';
import 'package:belediye_iletisim_merkezi/widgets/best_municipality_banner.dart';
import 'package:belediye_iletisim_merkezi/widgets/app_shimmer.dart';
import 'package:belediye_iletisim_merkezi/widgets/create_post_fab.dart';
import 'package:belediye_iletisim_merkezi/screens/posts/post_detail_screen.dart';
import 'package:belediye_iletisim_merkezi/screens/notifications/notifications_screen.dart';
import 'package:belediye_iletisim_merkezi/screens/profile/profile_screen.dart';
import 'package:belediye_iletisim_merkezi/screens/create_post/create_post_screen.dart';
import 'package:belediye_iletisim_merkezi/services/api_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scrollController = ScrollController();
  bool _isLoading = false;
  bool _isLoadingMore = false;
  
  @override
  void initState() {
    super.initState();
    _loadPosts();
    
    // Sonsuz kaydırma için scroll listener ekle
    _scrollController.addListener(_scrollListener);
  }
  
  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }
  
  // Kaydırma dinleyicisi
  void _scrollListener() {
    // Sayfanın altına yaklaşıldığında yeni gönderiler yükle
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 500 && 
        !_isLoading && 
        !_isLoadingMore) {
      _loadMorePosts();
    }
  }
  
  // İlk yükleme
  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await ref.read(post_provider.postsProvider.notifier).loadPosts();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gönderiler yüklenirken bir hata oluştu: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
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
  
  // Daha fazla gönderi yükle
  Future<void> _loadMorePosts() async {
    print('Yeni gönderiler yükleniyor...');
    
    setState(() {
      _isLoadingMore = true;
    });
    
    try {
      // Mevcut filtreleri al
      final filters = ref.read(post_provider.postFiltersProvider);
      
      if (filters.hasFilters) {
        // Filtreler varsa, filtreli içeriği devam ettir
        await ref.read(post_provider.postsProvider.notifier).filterPosts(
          cityId: filters.cityId,
          districtId: filters.districtId,
          categoryId: filters.categoryId,
          refresh: false, // Önemli: Mevcut içeriği değiştirmeden ekleme yapmak için
        );
      } else {
        // Filtre yoksa standart içeriği devam ettir
        await ref.read(post_provider.postsProvider.notifier).loadPosts(refresh: false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Daha fazla gönderi yüklenirken hata oluştu: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }
  
  Future<void> _applyFilters({
    String? cityId,
    String? districtId,
    String? categoryId,
  }) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Update filter providers
      ref.read(post_provider.cityFilterProvider.notifier).state = cityId;
      ref.read(post_provider.districtFilterProvider.notifier).state = districtId;
      ref.read(post_provider.categoryFilterProvider.notifier).state = categoryId;
      
      // Apply filters
      await ref.read(post_provider.postsProvider.notifier).filterPosts(
        cityId: cityId,
        districtId: districtId,
        categoryId: categoryId,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Filtreler uygulanırken bir hata oluştu: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
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
  
  void _clearFilters() {
    ref.read(post_provider.cityFilterProvider.notifier).state = null;
    ref.read(post_provider.districtFilterProvider.notifier).state = null;
    ref.read(post_provider.categoryFilterProvider.notifier).state = null;
    
    _loadPosts();
  }
  
  @override
  Widget build(BuildContext context) {
    final posts = ref.watch(post_provider.postsProvider);
    final filters = ref.watch(post_provider.postFiltersProvider);
    final selectedIndex = 0; // Default ana ekran sekmesi
    
    return Scaffold(
      // Twitter tarzı AppBar
      appBar: AppBar(
        elevation: 0.5,
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Image.asset(
          'assets/images/app_logo.png',
          height: 32,
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[200],
              child: Icon(Icons.person, size: 20, color: Colors.grey[600]),
            ),
          ),
        ),
        actions: [
          // Yeni Twitter tarzı ikon butonları
          IconButton(
            icon: const Icon(Icons.search, size: 22),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Arama özelliği yakında eklenecek')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, size: 22),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsScreen()),
              );
            },
          ),
        ],
      ),
      
      // Bu çift bottom navigation bar'ı kaldırdık
      // Ana uygulama içindeki genel bottom navigation bar kullanılacak
      
      // Gönderi oluşturma FAB - Twitter benzeri
      floatingActionButton: CreatePostFAB(
        onPressed: () {
          // Yeni Gönderi oluşturma sayfasına yönlendir
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreatePostScreen(postType: PostType.problem),
            ),
          );
        },
      ),
      
      // Gövde - RefreshIndicator ile çekme yenileme özelliği
      body: RefreshIndicator(
        onRefresh: _loadPosts,
        color: Theme.of(context).colorScheme.primary,
        child: Column(
          children: [
            // Filtre çubuğu - daha minimal, Twitter tarzı
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.withOpacity(0.2),
                    width: 0.5,
                  ),
                ),
              ),
              child: filter_widgets.FilterBar(
                onFilterApplied: (cityId, districtId, categoryId) {
                  _applyFilters(
                    cityId: cityId,
                    districtId: districtId,
                    categoryId: categoryId,
                  );
                },
                onFilterCleared: _clearFilters,
              ),
            ),
            
            // İçerik kısmı
            Expanded(
              child: _isLoading
                  ? _buildLoadingShimmer()
                  : posts.isEmpty
                      ? _buildEmptyState(filters.hasFilters)
                      : ListView.separated(
                          controller: _scrollController,
                          itemCount: posts.length + 3, // +1 for survey, +1 for banner, +1 for loading indicator
                          separatorBuilder: (context, index) => const Divider(height: 1, thickness: 0.5),
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return const SurveySlider();
                            }
                            
                            if (index == 1) {
                              // Ayın Belediyesi Banner'ı - daha modern tasarım
                              return const BestMunicipalityBanner(
                                cityName: "İstanbul",
                                awardMonth: "Nisan",
                                awardScore: 92,
                                awardText: "Hızlı şikayet çözüm oranı",
                              );
                            }
                            
                            // Son eleman loading indicator
                            if (index == posts.length + 2) {
                              return _isLoadingMore 
                                ? Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                  )
                                : const SizedBox(height: 60); // Boşluk
                            }
                            
                            // Twitter tarzı post card
                            final post = posts[index - 2];
                            return PostCard(
                              post: post,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PostDetailScreen(
                                      id: post.id,
                                    ),
                                  ),
                                );
                              },
                              onLike: () {
                                ref.read(post_provider.postsProvider.notifier).likePost(post.id);
                                // Küçük bir dokunsal geri bildirim de ekleyelim
                                HapticFeedback.lightImpact();
                              },
                              onHighlight: () {
                                ref.read(post_provider.postsProvider.notifier).highlightPost(post.id);
                                HapticFeedback.mediumImpact();
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Yükleme durumu için shimmer efekti
  Widget _buildLoadingShimmer() {
    return ListView.separated(
      itemCount: 5,
      separatorBuilder: (context, index) => const Divider(height: 1, thickness: 0.5),
      itemBuilder: (context, index) {
        return const AppShimmer(
          child: SizedBox(
            height: 200,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(radius: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 12, width: 100),
                            SizedBox(height: 8),
                            SizedBox(height: 10, width: 150),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  SizedBox(height: 12, width: double.infinity),
                  SizedBox(height: 8),
                  SizedBox(height: 12, width: double.infinity),
                  SizedBox(height: 8),
                  SizedBox(height: 12, width: 200),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(height: 20, width: 60),
                      SizedBox(height: 20, width: 60),
                      SizedBox(height: 20, width: 60),
                      SizedBox(height: 20, width: 60),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildEmptyState(bool hasFilters) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasFilters ? Icons.filter_list : Icons.forum_outlined,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            hasFilters
                ? 'Filtrelere uygun gönderi bulunamadı'
                : 'Henüz gönderi bulunmuyor',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            hasFilters
                ? 'Farklı filtreler deneyebilir veya filtreleri temizleyebilirsiniz'
                : 'İlk gönderiyi oluşturmak için sağ alttaki + butonuna tıklayın',
            style: TextStyle(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (hasFilters)
            ElevatedButton(
              onPressed: _clearFilters,
              child: const Text('Filtreleri Temizle'),
            ),
        ],
      ),
    );
  }
}