import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikayet_var/models/post.dart';
import 'package:sikayet_var/services/api_service.dart';
import 'package:sikayet_var/widgets/post_card.dart';
import 'package:sikayet_var/models/category.dart';

class FilteredPostsScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> filterData;

  const FilteredPostsScreen({
    Key? key,
    required this.filterData,
  }) : super(key: key);

  @override
  ConsumerState<FilteredPostsScreen> createState() => _FilteredPostsScreenState();
}

class _FilteredPostsScreenState extends ConsumerState<FilteredPostsScreen> {
  final ApiService _apiService = ApiService();
  List<Post> _posts = [];
  bool _isLoading = true;
  String _title = 'Filtrelenmiş Gönderiler';

  @override
  void initState() {
    super.initState();
    _loadFilteredPosts();
    _setScreenTitle();
  }

  void _setScreenTitle() {
    final filterType = widget.filterData['filterType'] as String;
    
    switch (filterType) {
      case 'status':
        final statusText = widget.filterData['statusText'] as String;
        _title = '$statusText Gönderiler';
        break;
      case 'category':
        final categoryName = widget.filterData['categoryName'] as String;
        _title = 'Kategori: $categoryName';
        break;
      case 'type':
        final typeText = widget.filterData['typeText'] as String;
        _title = '$typeText Gönderileri';
        break;
      case 'city':
        final cityName = widget.filterData['cityName'] as String;
        _title = '$cityName Gönderileri';
        break;
      case 'district':
        final districtName = widget.filterData['districtName'] as String;
        final cityName = widget.filterData['cityName'] as String;
        _title = '$districtName, $cityName Gönderileri';
        break;
      default:
        _title = 'Filtrelenmiş Gönderiler';
    }
  }

  Future<void> _loadFilteredPosts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final filterType = widget.filterData['filterType'] as String;
      List<Post> filteredPosts = [];
      
      switch (filterType) {
        case 'status':
          final status = widget.filterData['statusValue'] as PostStatus;
          // String'e dönüştürüyoruz
          final statusStr = status.toString().split('.').last;
          filteredPosts = await _apiService.getPosts(status: statusStr);
          break;
        case 'category':
          final categoryId = widget.filterData['categoryId'] as int;
          // String'e dönüştürüyoruz
          filteredPosts = await _apiService.getPosts(categoryId: categoryId.toString());
          break;
        case 'type':
          final type = widget.filterData['typeValue'] as PostType;
          filteredPosts = await _apiService.getPosts(type: type);
          break;
        case 'city':
          final cityId = widget.filterData['cityId'] as int;
          filteredPosts = await _apiService.getPosts(cityId: cityId);
          break;
        case 'district':
          final districtId = widget.filterData['districtId'] as int;
          filteredPosts = await _apiService.getPosts(districtId: districtId);
          break;
        default:
          filteredPosts = await _apiService.getPosts();
      }
      
      setState(() {
        _posts = filteredPosts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gönderiler yüklenirken bir hata oluştu: $e')),
      );
    }
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
              // Gelecekte ek filtreleme seçenekleri için
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Gelişmiş filtreleme yakında eklenecek')),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _posts.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 16),
                  itemCount: _posts.length,
                  itemBuilder: (context, index) {
                    final post = _posts[index];
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
                        await _apiService.likePost(post.id);
                        _loadFilteredPosts(); // Yeniden yükle
                      },
                      onHighlight: () async {
                        await _apiService.highlightPost(post.id);
                        _loadFilteredPosts(); // Yeniden yükle
                      },
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
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
            'Bu filtrelere uygun gönderi bulunmamaktadır',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Geri Dön'),
          ),
        ],
      ),
    );
  }
}