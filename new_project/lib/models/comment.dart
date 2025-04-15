import 'package:belediye_iletisim_merkezi/models/user.dart';

class Comment {
  final String id;
  final String content;
  final String postId;
  final String userId;
  final DateTime createdAt;
  final User? user;
  final int likes;
  final bool isOfficial;

  Comment({
    required this.id,
    required this.content,
    required this.postId,
    required this.userId,
    required this.createdAt,
    this.user,
    this.likes = 0,
    this.isOfficial = false,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'].toString(),
      content: json['content'],
      postId: json['post_id'].toString(),
      userId: json['user_id'].toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      likes: json['likes'] ?? 0,
      isOfficial: json['is_official'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'post_id': postId,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'likes': likes,
      'is_official': isOfficial,
    };
  }

  Comment copyWith({
    String? id,
    String? content,
    String? postId,
    String? userId,
    DateTime? createdAt,
    User? user,
    int? likes,
    bool? isOfficial,
  }) {
    return Comment(
      id: id ?? this.id,
      content: content ?? this.content,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      user: user ?? this.user,
      likes: likes ?? this.likes,
      isOfficial: isOfficial ?? this.isOfficial,
    );
  }
}