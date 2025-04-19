import 'package:flutter/material.dart';
import 'package:belediye_iletisim_merkezi/models/post.dart';
import 'package:belediye_iletisim_merkezi/models/category.dart';
import 'package:belediye_iletisim_merkezi/services/api_service.dart';
import 'package:belediye_iletisim_merkezi/widgets/post_card.dart';
import 'package:belediye_iletisim_merkezi/widgets/app_shimmer.dart';

class FilteredPostsScreen extends StatefulWidget {
  final Map<String, dynamic>? filterParams;
  
  const FilteredPostsScreen({
    Key? key,
    this.filterParams,
  }) : super(key: key);

  @override
  State<FilteredPostsScreen> createState() => _FilteredPostsScreenState();
}

class _FilteredPostsScreenState extends State<FilteredPostsScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  List<Post> _posts = [];
  String _title = 'Filtreli Gönderiler';
  
  @override
  void initState() {
    super.initState();
    _setTitleFromFilter();
    _loadPosts();
  }
  
  void _setTitleFromFilter() {
    final params = widget.filterParams;
    if (params == null) return;
    
    if (params['categoryId'] != null) {
      _apiService.getCategoryById(params['categoryId']).then((category) {
        if (mounted && category != null) {
          setState(() {
            _title = '${category.name} Gönderileri';
          });
        }
      });
    } else if (params['cityId'] != null) {
      _apiService.getCityNameById(params['cityId']).then((cityName) {
        if (mounted && cityName != null) {
          setState(() {
            _title = '$cityName Gönderileri';
          });
        }
      });
    } else if (params['status'] != null) {
      final status = PostStatus.values.firstWhere(
        (s) => s.toString().split('.').last == params['status'],
        orElse: () => PostStatus.awaitingSolution,
      );
      setState(() {
        switch (status) {
          case PostStatus.awaitingSolution:
            _title = 'Çözüm Bekleyen Gönderiler';
            break;
          case PostStatus.inProgress:
            _title = 'İşleme Alınan Gönderiler';
            break;
          case PostStatus.solved:
            _title = 'Çözülmüş Gönderiler';
            break;
          case PostStatus.rejected:
            _title = 'Reddedilen Gönderiler';
            break;
        }
      });
    } else if (params['type'] != null) {
      final type = PostType.values.firstWhere(
        (t) => t.toString().split('.').last == params['type'],
        orElse: () => PostType.problem,
      );
      setState(() {
        switch (type) {
          case PostType.problem:
            _title = 'Sorunlar';
            break;
          case PostType.suggestion:
            _title = 'Öneriler';
            break;
          case PostType.announcement:
            _title = 'Duyurular';
            break;
          case PostType.general:
            _title = 'Genel Paylaşımlar';
            break;
        }
      });
    }
  }
  
  Future<void> _loadPosts() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final posts = await _apiService.getFilteredPosts(widget.filterParams ?? {});
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gönderiler yüklenirken bir hata oluştu: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _refreshPosts() async {
    await _loadPosts();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Filtreleme modalı göster
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPosts,
        child: _isLoading
            ? _buildLoadingState()
            : _posts.isEmpty
                ? _buildEmptyState()
                : _buildPostsList(),
      ),
    );
  }
  
  Widget _buildLoadingState() {
    return ListView.builder(
      itemCount: 5,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: AppShimmer(
            child: Card(
              child: SizedBox(
                height: 200,
                width: double.infinity,
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.inbox,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Hiç gönderi bulunamadı',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Seçtiğiniz kriterlere uygun gönderi bulunmuyor.',
            style: TextStyle(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _refreshPosts,
            icon: const Icon(Icons.refresh),
            label: const Text('Yenile'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPostsList() {
    return ListView.builder(
      itemCount: _posts.length,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        final post = _posts[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: PostCard(
            post: post,
            onTap: () {
              Navigator.pushNamed(
                context,
                '/post_detail',
                arguments: post.id,
              );
            },
            onLike: () async {
              try {
                await _apiService.likePost(post.id);
                setState(() {
                  _posts[index] = post.copyWith(
                    likes: post.likes + 1,
                  );
                });
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Beğeni gönderilirken bir hata oluştu: $e'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            onHighlight: () {
              // Öne çıkarma işlemi
            },
            onComment: () {
              Navigator.pushNamed(
                context,
                '/post_detail',
                arguments: post.id,
              );
            },
          ),
        );
      },
    );
  }
}