class Comment {
  final String id;
  final String postId;
  final String userId;
  final String content;
  final int likeCount;
  final bool isHidden;
  final DateTime createdAt;
  final List<Comment>? replies;
  final bool isAnonymous;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    required this.likeCount,
    this.isHidden = false,
    required this.createdAt,
    this.replies,
    this.isAnonymous = false,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    List<Comment>? replies;
    if (json['replies'] != null) {
      replies = (json['replies'] as List)
          .map((reply) => Comment.fromJson(reply))
          .toList();
    }
    
    return Comment(
      id: json['id'].toString(),
      postId: json['post_id'].toString(),
      userId: json['user_id'].toString(),
      content: json['content'],
      likeCount: json['like_count'] ?? 0,
      isHidden: json['is_hidden'] ?? false,
      isAnonymous: json['is_anonymous'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      replies: replies,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'content': content,
      'like_count': likeCount,
      'is_hidden': isHidden,
      'is_anonymous': isAnonymous,
      'created_at': createdAt.toIso8601String(),
    };
    
    if (replies != null) {
      data['replies'] = replies!.map((reply) => reply.toJson()).toList();
    }
    
    return data;
  }

  Comment copyWith({
    String? id,
    String? postId,
    String? userId,
    String? content,
    int? likeCount,
    bool? isHidden,
    bool? isAnonymous,
    DateTime? createdAt,
    List<Comment>? replies,
  }) {
    return Comment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      likeCount: likeCount ?? this.likeCount,
      isHidden: isHidden ?? this.isHidden,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      createdAt: createdAt ?? this.createdAt,
      replies: replies ?? this.replies,
    );
  }
}