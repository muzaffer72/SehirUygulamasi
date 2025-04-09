class Comment {
  final String id;
  final String postId;
  final String userId;
  final String content;
  final int likeCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    required this.likeCount,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      postId: json['post_id'],
      userId: json['user_id'],
      content: json['content'],
      likeCount: json['like_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'content': content,
      'like_count': likeCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  Comment copyWith({
    String? id,
    String? postId,
    String? userId,
    String? content,
    int? likeCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Comment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      likeCount: likeCount ?? this.likeCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}