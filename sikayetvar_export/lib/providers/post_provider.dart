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
  
  Future<void> loadPosts() async {
    final posts = await _apiService.getPosts();
    state = posts;
  }
  
  Future<void> filterPosts({
    String? cityId,
    String? districtId,
    String? categoryId,
  }) async {
    final posts = await _apiService.getPosts(
      cityId: cityId,
      districtId: districtId,
      categoryId: categoryId,
    );
    state = posts;
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
  return await apiService.getPostById(postId);
});