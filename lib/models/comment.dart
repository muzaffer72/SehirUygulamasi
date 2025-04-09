class Comment {
  final String id;
  final String postId;
  final String userId;
  final String content;
  final int likeCount;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    required this.likeCount,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'].toString(),
      postId: json['post_id'].toString(),
      userId: json['user_id'].toString(),
      content: json['content'],
      likeCount: json['like_count'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
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
    };
  }
}