import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sikayet_var/models/post.dart';
import 'package:sikayet_var/utils/constants.dart';

class PostService {
  final String baseUrl = Constants.apiBaseUrl;
  final http.Client _client = http.Client();
  
  // Get all posts
  Future<List<Post>> getPosts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      
      final response = await _client.get(
        Uri.parse('$baseUrl/posts'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(Constants.networkTimeout);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        return data.map((json) => Post.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load posts');
      }
    } catch (e) {
      // For development/demo purposes
      if (e is SocketException || e is HttpException || e is TimeoutException) {
        await Future.delayed(const Duration(seconds: 1));
        return _getMockPosts();
      }
      throw Exception('Failed to load posts: $e');
    }
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
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      
      // Build query parameters
      final queryParams = <String, String>{};
      if (cityId != null) queryParams['city_id'] = cityId;
      if (districtId != null) queryParams['district_id'] = districtId;
      if (categoryId != null) queryParams['category_id'] = categoryId;
      if (sortBy != null) queryParams['sort_by'] = sortBy;
      if (type != null) {
        queryParams['type'] = type == PostType.problem ? 'problem' : 'general';
      }
      if (status != null) {
        queryParams['status'] = status == PostStatus.solved ? 'solved' : 'awaiting_solution';
      }
      
      final uri = Uri.parse('$baseUrl/posts')
          .replace(queryParameters: queryParams);
      
      final response = await _client.get(
        uri,
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(Constants.networkTimeout);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        return data.map((json) => Post.fromJson(json)).toList();
      } else {
        throw Exception('Failed to filter posts');
      }
    } catch (e) {
      // For development/demo purposes
      if (e is SocketException || e is HttpException || e is TimeoutException) {
        await Future.delayed(const Duration(seconds: 1));
        
        final mockPosts = _getMockPosts();
        
        // Apply filters to mock data
        List<Post> filteredPosts = mockPosts;
        
        if (cityId != null) {
          filteredPosts = filteredPosts.where((post) => post.cityId == cityId).toList();
        }
        
        if (districtId != null) {
          filteredPosts = filteredPosts.where((post) => post.districtId == districtId).toList();
        }
        
        if (categoryId != null) {
          filteredPosts = filteredPosts.where((post) => post.categoryId == categoryId).toList();
        }
        
        if (type != null) {
          filteredPosts = filteredPosts.where((post) => post.type == type).toList();
        }
        
        if (status != null) {
          filteredPosts = filteredPosts.where((post) => post.status == status).toList();
        }
        
        // Sort
        if (sortBy == 'popular') {
          filteredPosts.sort((a, b) => b.likeCount.compareTo(a.likeCount));
        } else {
          // Default to newest
          filteredPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        }
        
        return filteredPosts;
      }
      throw Exception('Failed to filter posts: $e');
    }
  }
  
  // Like a post
  Future<void> likePost(String postId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      
      final response = await _client.post(
        Uri.parse('$baseUrl/posts/$postId/like'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(Constants.networkTimeout);
      
      if (response.statusCode != 200) {
        throw Exception('Failed to like post');
      }
    } catch (e) {
      // For development/demo purposes
      if (e is SocketException || e is HttpException || e is TimeoutException) {
        await Future.delayed(const Duration(milliseconds: 500));
        return; // Simulate success
      }
      throw Exception('Failed to like post: $e');
    }
  }
  
  // Highlight a post
  Future<void> highlightPost(String postId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      
      final response = await _client.post(
        Uri.parse('$baseUrl/posts/$postId/highlight'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(Constants.networkTimeout);
      
      if (response.statusCode != 200) {
        throw Exception('Failed to highlight post');
      }
    } catch (e) {
      // For development/demo purposes
      if (e is SocketException || e is HttpException || e is TimeoutException) {
        await Future.delayed(const Duration(milliseconds: 500));
        return; // Simulate success
      }
      throw Exception('Failed to highlight post: $e');
    }
  }
  
  // Create a post
  Future<Post> createPost(Post post) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      
      final response = await _client.post(
        Uri.parse('$baseUrl/posts'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(post.toJson()),
      ).timeout(Constants.networkTimeout);
      
      if (response.statusCode == 201) {
        return Post.fromJson(json.decode(response.body)['data']);
      } else {
        throw Exception('Failed to create post');
      }
    } catch (e) {
      // For development/demo purposes
      if (e is SocketException || e is HttpException || e is TimeoutException) {
        await Future.delayed(const Duration(seconds: 1));
        
        // Create a new mock post with proper ID
        return Post(
          id: 'post_${DateTime.now().millisecondsSinceEpoch}',
          userId: post.userId,
          title: post.title,
          content: post.content,
          categoryId: post.categoryId,
          subCategoryId: post.subCategoryId,
          type: post.type,
          status: post.status,
          cityId: post.cityId,
          districtId: post.districtId,
          imageUrls: post.imageUrls,
          likeCount: 0,
          commentCount: 0,
          highlightCount: 0,
          isAnonymous: post.isAnonymous,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
      throw Exception('Failed to create post: $e');
    }
  }
  
  // Update post status (mark as solved or pending)
  Future<void> updatePostStatus(String postId, PostStatus status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      
      final response = await _client.patch(
        Uri.parse('$baseUrl/posts/$postId/status'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'status': status == PostStatus.solved ? 'solved' : 'awaiting_solution',
        }),
      ).timeout(Constants.networkTimeout);
      
      if (response.statusCode != 200) {
        throw Exception('Failed to update post status');
      }
    } catch (e) {
      // For development/demo purposes
      if (e is SocketException || e is HttpException || e is TimeoutException) {
        await Future.delayed(const Duration(milliseconds: 500));
        return; // Simulate success
      }
      throw Exception('Failed to update post status: $e');
    }
  }
  
  // Mock data for development/demo
  List<Post> _getMockPosts() {
    return [
      Post(
        id: 'post_1',
        userId: 'user_123',
        title: 'Caddelerde asfalt çalışması gerekiyor',
        content: 'Merkezdeki caddelerde oluşan derin çukurlar araçlara zarar veriyor. Belediyenin acilen asfalt çalışması yapması gerekiyor.',
        categoryId: 'category_1', // Altyapı
        subCategoryId: 'subcategory_1', // Yol Çalışmaları
        type: PostType.problem,
        status: PostStatus.awaitingSolution,
        cityId: 'city_1', // İstanbul
        districtId: 'district_1', // Kadıköy
        imageUrls: ['https://via.placeholder.com/300?text=Bozuk+Asfalt'],
        likeCount: 42,
        commentCount: 15,
        highlightCount: 23,
        isAnonymous: false,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Post(
        id: 'post_2',
        userId: 'user_456',
        title: 'Çöpler düzenli toplanmıyor',
        content: 'Son iki haftadır mahallemizdeki çöp konteynerleri düzenli olarak boşaltılmıyor. Kötü koku ve sağlık sorunları yaşıyoruz.',
        categoryId: 'category_2', // Temizlik
        subCategoryId: 'subcategory_2', // Çöp Toplama
        type: PostType.problem,
        status: PostStatus.awaitingSolution,
        cityId: 'city_1', // İstanbul
        districtId: 'district_2', // Beşiktaş
        imageUrls: ['https://via.placeholder.com/300?text=Dolu+Çöp+Konteyneri'],
        likeCount: 75,
        commentCount: 28,
        highlightCount: 35,
        isAnonymous: true,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        updatedAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      Post(
        id: 'post_3',
        userId: 'user_789',
        title: 'Yeni park alanı önerisi',
        content: 'Merkez mahallesinde bulunan boş arazi çocuklar için güzel bir park alanına dönüştürülebilir. Bu konuda belediyenin bir çalışma yapması çevre sakinlerini çok mutlu edecektir.',
        categoryId: 'category_3', // Yeşil Alan
        subCategoryId: 'subcategory_3', // Park ve Bahçeler
        type: PostType.general,
        status: null,
        cityId: 'city_2', // Ankara
        districtId: 'district_5', // Çankaya
        imageUrls: ['https://via.placeholder.com/300?text=Boş+Arazi'],
        likeCount: 128,
        commentCount: 45,
        highlightCount: 63,
        isAnonymous: false,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      Post(
        id: 'post_4',
        userId: 'user_123',
        title: 'Trafik ışıkları çalışmıyor',
        content: 'Ana caddedeki trafik ışıkları arızalı ve bu durum trafik kazalarına neden olabilir. Özellikle okul çıkış saatlerinde çok tehlikeli durumlar oluşuyor.',
        categoryId: 'category_4', // Trafik
        subCategoryId: 'subcategory_4', // Trafik Işıkları
        type: PostType.problem,
        status: PostStatus.solved,
        cityId: 'city_3', // İzmir
        districtId: 'district_8', // Karşıyaka
        imageUrls: ['https://via.placeholder.com/300?text=Bozuk+Trafik+Işığı'],
        likeCount: 37,
        commentCount: 12,
        highlightCount: 18,
        isAnonymous: false,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now().subtract(const Duration(days: 13)),
      ),
      Post(
        id: 'post_5',
        userId: 'user_456',
        title: 'Sokak hayvanları için mama istasyonu kurulmalı',
        content: 'Mahallemizde çok sayıda sokak hayvanı bulunuyor. Belediyenin düzenli olarak kontrol edilen mama ve su istasyonları kurması gerekiyor.',
        categoryId: 'category_5', // Sosyal Hizmetler
        subCategoryId: 'subcategory_5', // Sokak Hayvanları
        type: PostType.general,
        status: null,
        cityId: 'city_1', // İstanbul
        districtId: 'district_3', // Beyoğlu
        imageUrls: [],
        likeCount: 89,
        commentCount: 32,
        highlightCount: 47,
        isAnonymous: true,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }
}