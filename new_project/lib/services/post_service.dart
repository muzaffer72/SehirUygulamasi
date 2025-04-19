import 'package:belediye_iletisim_merkezi/models/post.dart';
import 'package:belediye_iletisim_merkezi/services/api_service.dart';

class PostService {
  final ApiService _apiService = ApiService();
  
  // Get all posts
  Future<List<Post>> getPosts() async {
    return _apiService.getPosts();
  }
  
  // Get post by ID
  Future<Post> getPostById(String id) async {
    return _apiService.getPostById(id);
  }
  
  // Create a new post
  Future<Post> createPost(Post post) async {
    return _apiService.createPost(post);
  }
  
  // Filter posts
  Future<List<Post>> filterPosts({
    String? cityId,
    String? districtId,
    String? categoryId,
    String? sortBy,
    PostType? type,
    PostStatus? status,
  }) async {
    return _apiService.filterPosts(
      cityId: cityId,
      districtId: districtId,
      categoryId: categoryId,
      sortBy: sortBy,
      type: type,
      status: status,
    );
  }
  
  // Like a post
  Future<void> likePost(String postId) async {
    return _apiService.likePost(postId);
  }
  
  // Highlight a post
  Future<void> highlightPost(String postId) async {
    return _apiService.highlightPost(postId);
  }
  
  // Update a post status
  Future<void> updatePostStatus(String postId, PostStatus status) async {
    return _apiService.updatePostStatus(postId, status);
  }
}