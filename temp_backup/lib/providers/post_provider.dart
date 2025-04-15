import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikayet_var/models/post.dart';
import 'package:sikayet_var/services/api_service.dart';
import 'package:sikayet_var/providers/auth_provider.dart';
import 'package:sikayet_var/providers/api_service_provider.dart';

// Post filters providers
final cityFilterProvider = StateProvider<String?>((ref) => null);
final districtFilterProvider = StateProvider<String?>((ref) => null);
final categoryFilterProvider = StateProvider<String?>((ref) => null);

// Filter info provider
class PostFilters {
  final String? cityId;
  final String? districtId;
  final String? categoryId;
  
  PostFilters({
    this.cityId,
    this.districtId,
    this.categoryId,
  });
  
  bool get hasFilters => cityId != null || districtId != null || categoryId != null;
  
  PostFilters copyWith({
    String? cityId,
    String? districtId,
    String? categoryId,
  }) {
    return PostFilters(
      cityId: cityId ?? this.cityId,
      districtId: districtId ?? this.districtId,
      categoryId: categoryId ?? this.categoryId,
    );
  }
}

final postFiltersProvider = Provider<PostFilters>((ref) {
  final cityId = ref.watch(cityFilterProvider);
  final districtId = ref.watch(districtFilterProvider);
  final categoryId = ref.watch(categoryFilterProvider);
  
  return PostFilters(
    cityId: cityId,
    districtId: districtId,
    categoryId: categoryId,
  );
});

// Posts notifier
class PostsNotifier extends StateNotifier<List<Post>> {
  final ApiService _apiService;
  
  PostsNotifier(this._apiService) : super([]);
  
  int _currentPage = 1;
  final int _postsPerPage = 10;
  bool _isLastPage = false;
  
  Future<void> loadPosts({bool refresh = true}) async {
    try {
      if (refresh) {
        _currentPage = 1;
        _isLastPage = false;
      }
      
      print('Loading posts page $_currentPage');
      final posts = await _apiService.getPosts(
        page: _currentPage,
        limit: _postsPerPage
      );
      
      print('Loaded ${posts.length} posts');
      
      if (posts.isEmpty) {
        _isLastPage = true;
      }
      
      if (refresh) {
        state = posts;
      } else {
        // Sadece yeni gönderileri ekle, duplicate önle
        final currentIds = state.map((post) => post.id).toSet();
        final uniqueNewPosts = posts.where((post) => !currentIds.contains(post.id)).toList();
        state = [...state, ...uniqueNewPosts];
      }
      
      // Sonraki sayfa için hazırlık
      if (posts.length < _postsPerPage) {
        _isLastPage = true;
      } else {
        _currentPage++;
      }
    } catch (e) {
      print('Error loading posts: $e');
      // Hata durumunda boş liste kullanma
      if (refresh) {
        state = [];
      }
    }
  }
  
  Future<void> filterPosts({
    String? cityId,
    String? districtId,
    String? categoryId,
    String? type,
    String? sortBy,
    bool refresh = true,
  }) async {
    try {
      if (refresh) {
        _currentPage = 1;
        _isLastPage = false;
      }
      
      print('Filtering posts page $_currentPage');
      print('Filters: cityId=$cityId, districtId=$districtId, categoryId=$categoryId, type=$type, sortBy=$sortBy');
      
      final posts = await _apiService.getPosts(
        cityId: cityId,
        districtId: districtId, 
        categoryId: categoryId,
        type: type != null ? type == 'problem' ? PostType.problem : PostType.general : null,
        page: _currentPage,
        limit: _postsPerPage,
      );
      
      print('Filtered posts count: ${posts.length}');
      
      if (posts.isEmpty) {
        _isLastPage = true;
      }
      
      if (refresh) {
        state = posts;
      } else {
        // Sadece yeni gönderileri ekle, duplicate önle
        final currentIds = state.map((post) => post.id).toSet();
        final uniqueNewPosts = posts.where((post) => !currentIds.contains(post.id)).toList();
        state = [...state, ...uniqueNewPosts];
      }
      
      // Sonraki sayfa için hazırlık
      if (posts.length < _postsPerPage) {
        _isLastPage = true;
      } else {
        _currentPage++;
      }
    } catch (e) {
      print('Error filtering posts: $e');
      // Hata durumunda boş liste kullanma
      if (refresh) {
        state = [];
      }
    }
  }
  
  Future<void> likePost(String postId) async {
    await _apiService.likePost(postId);
    
    state = state.map((post) {
      if (post.id == postId) {
        return post.copyWith(
          likes: post.likes + 1,
        );
      }
      return post;
    }).toList();
  }
  
  Future<void> highlightPost(String postId) async {
    await _apiService.highlightPost(postId);
    
    state = state.map((post) {
      if (post.id == postId) {
        return post.copyWith(
          highlights: post.highlights + 1,
        );
      }
      return post;
    }).toList();
  }
}

// Posts provider
final postsProvider = StateNotifierProvider<PostsNotifier, List<Post>>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return PostsNotifier(apiService);
});

// Post detail provider
final postDetailProvider = FutureProvider.family<Post, String>((ref, postId) async {
  final apiService = ref.watch(apiServiceProvider);
  final post = await apiService.getPostById(postId);
  return post;
});