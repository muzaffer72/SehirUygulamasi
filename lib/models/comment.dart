class Comment {
  final String id;
  final String postId;
  final String userId;
  final String content;
  final int likeCount;
  final bool isHidden;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    required this.likeCount,
    this.isHidden = false,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'].toString(),
      postId: json['post_id'].toString(),
      userId: json['user_id'].toString(),
      content: json['content'],
      likeCount: json['like_count'] ?? 0,
      isHidden: json['is_hidden'] ?? false,
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
      'is_hidden': isHidden,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Comment copyWith({
    String? id,
    String? postId,
    String? userId,
    String? content,
    int? likeCount,
    bool? isHidden,
    DateTime? createdAt,
  }) {
    return Comment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      likeCount: likeCount ?? this.likeCount,
      isHidden: isHidden ?? this.isHidden,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}