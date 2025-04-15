import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belediye_iletisim_merkezi/models/post.dart';
import 'package:belediye_iletisim_merkezi/models/city_profile.dart';
import 'package:belediye_iletisim_merkezi/providers/post_provider.dart';
import 'package:belediye_iletisim_merkezi/providers/theme_provider.dart';
import 'package:belediye_iletisim_merkezi/widgets/filter_bar.dart';
import 'package:belediye_iletisim_merkezi/widgets/post_card.dart';
import 'package:belediye_iletisim_merkezi/widgets/survey_slider.dart';
import 'package:belediye_iletisim_merkezi/widgets/best_municipality_banner.dart';
import 'package:belediye_iletisim_merkezi/widgets/app_shimmer.dart';
import 'package:belediye_iletisim_merkezi/widgets/create_post_fab.dart';
import 'package:belediye_iletisim_merkezi/screens/posts/post_detail_screen.dart';
import 'package:belediye_iletisim_merkezi/screens/notifications/notifications_screen.dart';
import 'package:belediye_iletisim_merkezi/screens/profile/profile_screen.dart';
import 'package:belediye_iletisim_merkezi/services/api_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scrollController = ScrollController();
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadPosts();
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await ref.read(postsProvider.notifier).loadPosts();
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
      ref.read(cityFilterProvider.notifier).state = cityId;
      ref.read(districtFilterProvider.notifier).state = districtId;
      ref.read(categoryFilterProvider.notifier).state = categoryId;
      
      // Apply filters
      await ref.read(postsProvider.notifier).filterPosts(
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
    ref.read(cityFilterProvider.notifier).state = null;
    ref.read(districtFilterProvider.notifier).state = null;
    ref.read(categoryFilterProvider.notifier).state = null;
    
    _loadPosts();
  }
  
  @override
  Widget build(BuildContext context) {
    final posts = ref.watch(postsProvider);
    final filters = ref.watch(postFiltersProvider);
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
          child: CircleAvatar(
            backgroundImage: const AssetImage('assets/images/default_avatar.png'),
            radius: 16,
            backgroundColor: Colors.grey[200],
            onBackgroundImageError: (e, stackTrace) {
              debugPrint('Avatar yükleme hatası: $e');
            },
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
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
      
      // Twitter tarzı bottom navigation bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 8.0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Keşfet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_city_outlined),
            activeIcon: Icon(Icons.location_city),
            label: 'Şehirler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.poll_outlined),
            activeIcon: Icon(Icons.poll),
            label: 'Anketler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        onTap: (index) {
          // Gerçek bir uygulamada farklı sayfalara yönlendirme yapılır
          if (index == 0) {
            // Zaten ana sayfadayız
          } else if (index == 1) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Keşfet sayfası yakında!'))
            );
          } else if (index == 2) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Şehirler sayfası yakında!'))
            );
          } else if (index == 3) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Anketler sayfası yakında!'))
            );
          } else if (index == 4) {
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => const ProfileScreen())
            );
          }
        },
      ),
      
      // Gönderi oluşturma FAB - Twitter benzeri
      floatingActionButton: CreatePostFAB(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gönderi oluşturma yakında!'))
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
              child: FilterBar(
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
                          itemCount: posts.length + 2, // +1 for survey, +1 for municipality banner
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
                            
                            // Twitter tarzı post card
                            final post = posts[index - 2];
                            return PostCard(
                              post: post,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PostDetailScreen(
                                      postId: post.id,
                                    ),
                                  ),
                                );
                              },
                              onLike: () {
                                ref.read(postsProvider.notifier).likePost(post.id);
                                // Küçük bir dokunsal geri bildirim de ekleyelim
                                HapticFeedback.lightImpact();
                              },
                              onHighlight: () {
                                ref.read(postsProvider.notifier).highlightPost(post.id);
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