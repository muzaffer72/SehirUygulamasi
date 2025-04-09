import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikayet_var/models/post.dart';
import 'package:sikayet_var/services/post_service.dart';

// Post service provider
final postServiceProvider = Provider<PostService>((ref) {
  return PostService();
});

// Provider for the current filter options
final postFilterProvider = StateProvider<Map<String, dynamic>>((ref) {
  return {
    'cityId': null,
    'districtId': null,
    'categoryId': null,
    'sortBy': 'newest', // or 'popular'
    'type': null, // PostType.problem or PostType.general
    'status': null, // PostStatus.solved or PostStatus.awaitingSolution
    'isFiltered': false,
  };
});

// Provider for the loading state of posts
final postsLoadingProvider = StateProvider<bool>((ref) => false);

// Provider for the error state of posts
final postsErrorProvider = StateProvider<String?>((ref) => null);

// Posts notifier class
class PostsNotifier extends StateNotifier<List<Post>> {
  final PostService _postService;
  final Ref _ref;
  
  PostsNotifier(this._postService, this._ref) : super([]) {
    // Load posts when instantiated
    loadPosts();
  }
  
  // Load all posts
  Future<void> loadPosts() async {
    _ref.read(postsLoadingProvider.notifier).state = true;
    _ref.read(postsErrorProvider.notifier).state = null;
    
    try {
      final posts = await _postService.getPosts();
      state = posts;
      _ref.read(postsLoadingProvider.notifier).state = false;
    } catch (e) {
      _ref.read(postsLoadingProvider.notifier).state = false;
      _ref.read(postsErrorProvider.notifier).state = e.toString();
    }
  }
  
  // Filter posts
  Future<void> filterPosts({
    String? cityId,
    String? districtId,
    String? categoryId,
    String? sortBy,
    PostType? type,
    PostStatus? status,
  }) async {
    _ref.read(postsLoadingProvider.notifier).state = true;
    _ref.read(postsErrorProvider.notifier).state = null;
    
    // Update filter state
    _ref.read(postFilterProvider.notifier).state = {
      'cityId': cityId,
      'districtId': districtId,
      'categoryId': categoryId,
      'sortBy': sortBy ?? 'newest',
      'type': type,
      'status': status,
      'isFiltered': cityId != null || districtId != null || categoryId != null || type != null || status != null,
    };
    
    try {
      final filteredPosts = await _postService.filterPosts(
        cityId: cityId,
        districtId: districtId,
        categoryId: categoryId,
        sortBy: sortBy,
        type: type,
        status: status,
      );
      state = filteredPosts;
      _ref.read(postsLoadingProvider.notifier).state = false;
    } catch (e) {
      _ref.read(postsLoadingProvider.notifier).state = false;
      _ref.read(postsErrorProvider.notifier).state = e.toString();
    }
  }
  
  // Clear filters
  Future<void> clearFilters() async {
    _ref.read(postFilterProvider.notifier).state = {
      'cityId': null,
      'districtId': null,
      'categoryId': null,
      'sortBy': 'newest',
      'type': null,
      'status': null,
      'isFiltered': false,
    };
    
    await loadPosts();
  }
  
  // Like a post
  Future<void> likePost(String postId) async {
    try {
      await _postService.likePost(postId);
      
      // Update local state
      state = state.map((post) {
        if (post.id == postId) {
          return post.copyWith(
            likeCount: post.likeCount + 1,
          );
        }
        return post;
      }).toList();
    } catch (e) {
      _ref.read(postsErrorProvider.notifier).state = e.toString();
    }
  }
  
  // Highlight a post
  Future<void> highlightPost(String postId) async {
    try {
      await _postService.highlightPost(postId);
      
      // Update local state
      state = state.map((post) {
        if (post.id == postId) {
          return post.copyWith(
            highlightCount: post.highlightCount + 1,
          );
        }
        return post;
      }).toList();
    } catch (e) {
      _ref.read(postsErrorProvider.notifier).state = e.toString();
    }
  }
  
  // Create a new post
  Future<Post?> createPost(Post post) async {
    _ref.read(postsLoadingProvider.notifier).state = true;
    _ref.read(postsErrorProvider.notifier).state = null;
    
    try {
      final newPost = await _postService.createPost(post);
      
      // Add to local state
      state = [newPost, ...state];
      
      _ref.read(postsLoadingProvider.notifier).state = false;
      return newPost;
    } catch (e) {
      _ref.read(postsLoadingProvider.notifier).state = false;
      _ref.read(postsErrorProvider.notifier).state = e.toString();
      return null;
    }
  }
  
  // Update post status
  Future<void> updatePostStatus(String postId, PostStatus status) async {
    try {
      await _postService.updatePostStatus(postId, status);
      
      // Update local state
      state = state.map((post) {
        if (post.id == postId) {
          return post.copyWith(
            status: status,
          );
        }
        return post;
      }).toList();
    } catch (e) {
      _ref.read(postsErrorProvider.notifier).state = e.toString();
    }
  }
}

// Posts Provider
final postsProvider = StateNotifierProvider<PostsNotifier, List<Post>>((ref) {
  final postService = ref.watch(postServiceProvider);
  return PostsNotifier(postService, ref);
});

// Provider for selecting a single post by ID
final selectedPostProvider = Provider.family<Post?, String>((ref, postId) {
  final posts = ref.watch(postsProvider);
  return posts.firstWhere((post) => post.id == postId, orElse: () => null);
});