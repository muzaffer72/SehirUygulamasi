import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belediye_iletisim_merkezi/models/post.dart';
import 'package:belediye_iletisim_merkezi/models/city_profile.dart';
import 'package:belediye_iletisim_merkezi/providers/post_provider.dart';
import 'package:belediye_iletisim_merkezi/widgets/filter_bar.dart';
import 'package:belediye_iletisim_merkezi/widgets/post_card.dart';
import 'package:belediye_iletisim_merkezi/widgets/survey_slider.dart';
import 'package:belediye_iletisim_merkezi/widgets/best_municipality_banner.dart';
import 'package:belediye_iletisim_merkezi/screens/posts/post_detail_screen.dart';

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
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('ŞikayetVar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Arama özelliği yakında eklenecek')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bildirim özelliği yakında eklenecek')),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadPosts,
        child: Column(
          children: [
            // Filter bar
            FilterBar(
              onFilterApplied: (cityId, districtId, categoryId) {
                _applyFilters(
                  cityId: cityId,
                  districtId: districtId,
                  categoryId: categoryId,
                );
              },
              onFilterCleared: _clearFilters,
            ),
            
            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : posts.isEmpty
                      ? _buildEmptyState(filters.hasFilters)
                      : ListView.builder(
                          controller: _scrollController,
                          itemCount: posts.length + 2, // +1 for survey, +1 for municipality banner
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return const SurveySlider();
                            }
                            
                            if (index == 1) {
                              // Ayın Belediyesi Banner'ı
                              return const BestMunicipalityBanner(
                                cityName: "İstanbul",
                                awardMonth: "Nisan",
                                awardScore: 92,
                                awardText: "Hızlı şikayet çözüm oranı",
                              );
                            }
                            
                            final post = posts[index - 2];
                            return PostCard(
                              post: post,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PostDetailScreen(post: post),
                                  ),
                                );
                              },
                              onLike: () {
                                ref.read(postsProvider.notifier).likePost(post.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Gönderi beğenildi')),
                                );
                              },
                              onHighlight: () {
                                ref.read(postsProvider.notifier).highlightPost(post.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Gönderi öne çıkarıldı')),
                                );
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