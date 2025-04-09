enum PostStatus {
  awaitingSolution,
  inProgress,
  solved,
  rejected,
}

class Post {
  final String id;
  final String title;
  final String content;
  final String userId;
  final String categoryId;
  final String? cityId;
  final String? districtId;
  final PostStatus status;
  final int likes;
  final int highlights;
  final DateTime createdAt;
  final List<String>? imageUrls;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.userId,
    required this.categoryId,
    this.cityId,
    this.districtId,
    required this.status,
    required this.likes,
    required this.highlights,
    required this.createdAt,
    this.imageUrls,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    PostStatus parseStatus(String status) {
      switch (status) {
        case 'awaitingSolution':
          return PostStatus.awaitingSolution;
        case 'inProgress':
          return PostStatus.inProgress;
        case 'solved':
          return PostStatus.solved;
        case 'rejected':
          return PostStatus.rejected;
        default:
          return PostStatus.awaitingSolution;
      }
    }

    return Post(
      id: json['id'].toString(),
      title: json['title'],
      content: json['content'],
      userId: json['user_id'].toString(),
      categoryId: json['category_id'].toString(),
      cityId: json['city_id']?.toString(),
      districtId: json['district_id']?.toString(),
      status: parseStatus(json['status']),
      likes: json['likes'] ?? 0,
      highlights: json['highlights'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      imageUrls: json['image_urls'] != null
          ? List<String>.from(json['image_urls'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    String statusToString(PostStatus status) {
      switch (status) {
        case PostStatus.awaitingSolution:
          return 'awaitingSolution';
        case PostStatus.inProgress:
          return 'inProgress';
        case PostStatus.solved:
          return 'solved';
        case PostStatus.rejected:
          return 'rejected';
      }
    }

    return {
      'id': id,
      'title': title,
      'content': content,
      'user_id': userId,
      'category_id': categoryId,
      'city_id': cityId,
      'district_id': districtId,
      'status': statusToString(status),
      'likes': likes,
      'highlights': highlights,
      'created_at': createdAt.toIso8601String(),
      'image_urls': imageUrls,
    };
  }

  Post copyWith({
    String? id,
    String? title,
    String? content,
    String? userId,
    String? categoryId,
    String? cityId,
    String? districtId,
    PostStatus? status,
    int? likes,
    int? highlights,
    DateTime? createdAt,
    List<String>? imageUrls,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      cityId: cityId ?? this.cityId,
      districtId: districtId ?? this.districtId,
      status: status ?? this.status,
      likes: likes ?? this.likes,
      highlights: highlights ?? this.highlights,
      createdAt: createdAt ?? this.createdAt,
      imageUrls: imageUrls ?? this.imageUrls,
    );
  }
}