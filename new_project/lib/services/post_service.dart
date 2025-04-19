import 'package:belediye_iletisim_merkezi/models/post.dart';
import 'package:belediye_iletisim_merkezi/services/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belediye_iletisim_merkezi/providers/api_service_provider.dart';

class PostService {
  final ApiService _apiService;
  
  // Constructor that takes an ApiService instance
  PostService(this._apiService);
  
  // Factory constructor to create PostService from a ProviderRef
  factory PostService.fromRef(ProviderRef ref) {
    final apiService = ref.read(apiServiceProvider);
    return PostService(apiService);
  }
  
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
    return _apiService.createPost(
      title: post.title,
      content: post.content,
      type: post.type,
      categoryId: post.categoryId,
      cityId: post.cityId,
      districtId: post.districtId,
      isAnonymous: post.isAnonymous,
      imageUrls: post.imageUrls,
    );
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
    Map<String, dynamic> filterParams = {};
    
    if (cityId != null) filterParams['cityId'] = cityId;
    if (districtId != null) filterParams['districtId'] = districtId;
    if (categoryId != null) filterParams['categoryId'] = categoryId;
    if (sortBy != null) filterParams['sortBy'] = sortBy;
    if (type != null) filterParams['type'] = type.index;
    if (status != null) filterParams['status'] = status.index;
    
    return _apiService.getFilteredPosts(filterParams);
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
  Future<Post> updatePostStatus(String postId, PostStatus status) async {
    return _apiService.updatePost(
      id: postId,
      status: status.index,
    );
  }
}