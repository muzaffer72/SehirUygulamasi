import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:belediye_iletisim_merkezi/models/comment.dart';
import 'package:belediye_iletisim_merkezi/utils/profanity_filter.dart';

class CommentService {
  final String baseUrl;
  final http.Client _client;

  CommentService({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  // Yorumları getir
  Future<List<Comment>> getCommentsByPostId(String postId) async {
    final response = await _client.get(Uri.parse('$baseUrl/posts/$postId/comments'));
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Comment.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load comments: ${response.body}');
    }
  }
  
  // Yorum ekle
  Future<Comment> addComment(String postId, String userId, String content) async {
    // Küfür kontrolü
    final containsProfanity = ProfanityFilter.containsProfanity(content);
    
    final response = await _client.post(
      Uri.parse('$baseUrl/comments'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'post_id': postId,
        'user_id': userId,
        'content': content,
        'is_hidden': containsProfanity, // Küfür içeriyorsa otomatik gizlenir
      }),
    );
    
    if (response.statusCode == 201) {
      return Comment.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to add comment: ${response.body}');
    }
  }
  
  // Yorumu beğen
  Future<Comment> likeComment(String commentId) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/comments/$commentId/like'),
      headers: {'Content-Type': 'application/json'},
    );
    
    if (response.statusCode == 200) {
      return Comment.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to like comment: ${response.body}');
    }
  }
  
  // Yorumu gizle
  Future<Comment> hideComment(String commentId) async {
    final response = await _client.put(
      Uri.parse('$baseUrl/comments/$commentId/hide'),
      headers: {'Content-Type': 'application/json'},
    );
    
    if (response.statusCode == 200) {
      return Comment.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to hide comment: ${response.body}');
    }
  }
  
  // Yorumu göster
  Future<Comment> showComment(String commentId) async {
    final response = await _client.put(
      Uri.parse('$baseUrl/comments/$commentId/show'),
      headers: {'Content-Type': 'application/json'},
    );
    
    if (response.statusCode == 200) {
      return Comment.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to show comment: ${response.body}');
    }
  }
  
  // Yorumu sil
  Future<void> deleteComment(String commentId) async {
    final response = await _client.delete(
      Uri.parse('$baseUrl/comments/$commentId'),
    );
    
    if (response.statusCode != 204) {
      throw Exception('Failed to delete comment: ${response.body}');
    }
  }
}