enum PostType { problem, general }
enum PostStatus { solved, awaitingSolution }

class Post {
  final String id;
  final String userId;
  final String title;
  final String content;
  final String categoryId;
  final String? subCategoryId;
  final PostType type;
  final PostStatus? status; // Only for problem posts
  final String cityId;
  final String districtId;
  final List<String> imageUrls;
  final int likeCount;
  final int commentCount;
  final int highlightCount;
  final bool isAnonymous;
  final DateTime createdAt;
  final DateTime updatedAt;

  Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.categoryId,
    this.subCategoryId,
    required this.type,
    this.status,
    required this.cityId,
    required this.districtId,
    required this.imageUrls,
    required this.likeCount,
    required this.commentCount,
    required this.highlightCount,
    required this.isAnonymous,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      content: json['content'],
      categoryId: json['category_id'],
      subCategoryId: json['sub_category_id'],
      type: json['type'] == 'problem' ? PostType.problem : PostType.general,
      status: json['status'] == null
          ? null
          : json['status'] == 'solved'
              ? PostStatus.solved
              : PostStatus.awaitingSolution,
      cityId: json['city_id'],
      districtId: json['district_id'],
      imageUrls: json['image_urls'] != null
          ? List<String>.from(json['image_urls'])
          : [],
      likeCount: json['like_count'] ?? 0,
      commentCount: json['comment_count'] ?? 0,
      highlightCount: json['highlight_count'] ?? 0,
      isAnonymous: json['is_anonymous'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'content': content,
      'category_id': categoryId,
      'sub_category_id': subCategoryId,
      'type': type == PostType.problem ? 'problem' : 'general',
      'status': status == null
          ? null
          : status == PostStatus.solved
              ? 'solved'
              : 'awaiting_solution',
      'city_id': cityId,
      'district_id': districtId,
      'image_urls': imageUrls,
      'like_count': likeCount,
      'comment_count': commentCount,
      'highlight_count': highlightCount,
      'is_anonymous': isAnonymous,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Post copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    String? categoryId,
    String? subCategoryId,
    PostType? type,
    PostStatus? status,
    String? cityId,
    String? districtId,
    List<String>? imageUrls,
    int? likeCount,
    int? commentCount,
    int? highlightCount,
    bool? isAnonymous,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      categoryId: categoryId ?? this.categoryId,
      subCategoryId: subCategoryId ?? this.subCategoryId,
      type: type ?? this.type,
      status: status ?? this.status,
      cityId: cityId ?? this.cityId,
      districtId: districtId ?? this.districtId,
      imageUrls: imageUrls ?? this.imageUrls,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      highlightCount: highlightCount ?? this.highlightCount,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}