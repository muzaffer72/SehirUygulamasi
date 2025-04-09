import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikayet_var/models/post.dart';
import 'package:sikayet_var/services/post_service.dart';

// Provider for all posts
final postsProvider = StateNotifierProvider<PostsNotifier, List<Post>>((ref) {
  return PostsNotifier();
});

// Provider for filtered posts
final filteredPostsProvider = StateProvider<List<Post>>((ref) {
  return ref.watch(postsProvider);
});

// Providers for filter parameters
final cityFilterProvider = StateProvider<String?>((ref) => null);
final districtFilterProvider = StateProvider<String?>((ref) => null);
final categoryFilterProvider = StateProvider<String?>((ref) => null);
final typeFilterProvider = StateProvider<PostType?>((ref) => null);
final statusFilterProvider = StateProvider<PostStatus?>((ref) => null);
final sortByProvider = StateProvider<String?>((ref) => 'latest');

// Provider that combines all filters
final postFiltersProvider = Provider((ref) {
  return PostFilters(
    cityId: ref.watch(cityFilterProvider),
    districtId: ref.watch(districtFilterProvider),
    categoryId: ref.watch(categoryFilterProvider),
    type: ref.watch(typeFilterProvider),
    status: ref.watch(statusFilterProvider),
    sortBy: ref.watch(sortByProvider),
  );
});

class PostFilters {
  final String? cityId;
  final String? districtId;
  final String? categoryId;
  final PostType? type;
  final PostStatus? status;
  final String? sortBy;

  PostFilters({
    this.cityId,
    this.districtId,
    this.categoryId,
    this.type,
    this.status,
    this.sortBy,
  });

  bool get hasFilters =>
      cityId != null ||
      districtId != null ||
      categoryId != null ||
      type != null ||
      status != null ||
      (sortBy != null && sortBy != 'latest');
}

class PostsNotifier extends StateNotifier<List<Post>> {
  final PostService _postService = PostService();

  PostsNotifier() : super([]) {
    loadPosts();
  }

  Future<void> loadPosts() async {
    try {
      final posts = await _postService.getPosts();
      state = posts;
    } catch (e) {
      // Handle error
      print('Error loading posts: $e');
    }
  }

  Future<void> filterPosts({
    String? cityId,
    String? districtId,
    String? categoryId,
    String? sortBy,
    PostType? type,
    PostStatus? status,
  }) async {
    try {
      final posts = await _postService.filterPosts(
        cityId: cityId,
        districtId: districtId,
        categoryId: categoryId,
        sortBy: sortBy,
        type: type,
        status: status,
      );
      state = posts;
    } catch (e) {
      // Handle error
      print('Error filtering posts: $e');
    }
  }

  Future<Post?> getPostById(String id) async {
    try {
      // First check if we already have this post in state
      final existingPost = state.firstWhere(
        (post) => post.id == id,
        orElse: () => Post(
          id: '',
          userId: '',
          title: '',
          content: '',
          categoryId: '',
          type: PostType.problem,
          imageUrls: [],
          likeCount: 0,
          commentCount: 0,
          highlightCount: 0,
          isAnonymous: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      if (existingPost.id.isNotEmpty) {
        return existingPost;
      }

      // Otherwise fetch it
      final post = await _postService.getPostById(id);
      return post;
    } catch (e) {
      // Handle error
      print('Error getting post: $e');
      return null;
    }
  }

  Future<void> createPost(Post post) async {
    try {
      final newPost = await _postService.createPost(post);
      state = [newPost, ...state];
    } catch (e) {
      // Handle error
      print('Error creating post: $e');
    }
  }

  Future<void> likePost(String postId) async {
    try {
      await _postService.likePost(postId);
      
      // Update the post in the state
      state = state.map((post) {
        if (post.id == postId) {
          return post.copyWith(likeCount: post.likeCount + 1);
        }
        return post;
      }).toList();
    } catch (e) {
      // Handle error
      print('Error liking post: $e');
    }
  }

  Future<void> highlightPost(String postId) async {
    try {
      await _postService.highlightPost(postId);
      
      // Update the post in the state
      state = state.map((post) {
        if (post.id == postId) {
          return post.copyWith(highlightCount: post.highlightCount + 1);
        }
        return post;
      }).toList();
    } catch (e) {
      // Handle error
      print('Error highlighting post: $e');
    }
  }

  Future<void> updatePostStatus(String postId, PostStatus status) async {
    try {
      await _postService.updatePostStatus(postId, status);
      
      // Update the post in the state
      state = state.map((post) {
        if (post.id == postId) {
          return post.copyWith(status: status);
        }
        return post;
      }).toList();
    } catch (e) {
      // Handle error
      print('Error updating post status: $e');
    }
  }
}