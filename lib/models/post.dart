enum PostStatus {
  awaitingSolution,
  inProgress,
  solved,
  rejected,
}

enum PostType {
  problem,
  suggestion,
  announcement,
  general,
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
  final PostType type;
  final int likes;
  final int highlights;
  final int commentCount;
  final bool isAnonymous;
  final DateTime createdAt;
  final List<String>? imageUrls;
  final String? videoUrl;
  final int? satisfactionRating;
  
  // Widget'lar için getter'lar
  int get likeCount => likes;
  int get highlightCount => highlights;
  
  // Memnuniyet puanı getter
  int? get userSatisfactionRating => satisfactionRating;
  
  // Memnuniyet puanı kontrolü
  bool get hasSatisfactionRating => satisfactionRating != null && satisfactionRating! > 0;
  
  // Post çözülmüş mü kontrolü
  bool get isSolved => status == PostStatus.solved;
  
  // Memnuniyet puanı verilebilir mi
  bool get canRateSatisfaction => isSolved && !hasSatisfactionRating;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.userId,
    required this.categoryId,
    this.cityId,
    this.districtId,
    required this.status,
    this.type = PostType.problem,
    required this.likes,
    required this.highlights,
    this.commentCount = 0,
    this.isAnonymous = false,
    required this.createdAt,
    this.imageUrls,
    this.videoUrl,
    this.satisfactionRating,
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
    
    PostType parseType(String? type) {
      switch (type) {
        case 'problem':
          return PostType.problem;
        case 'suggestion':
          return PostType.suggestion;
        case 'announcement':
          return PostType.announcement;
        case 'general':
          return PostType.general;
        default:
          return PostType.problem;
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
      type: parseType(json['type']),
      likes: json['likes'] ?? 0,
      highlights: json['highlights'] ?? 0,
      commentCount: json['comment_count'] ?? 0,
      isAnonymous: json['is_anonymous'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      imageUrls: json['image_urls'] != null
          ? List<String>.from(json['image_urls'])
          : null,
      videoUrl: json['video_url'],
      satisfactionRating: json['satisfaction_rating'] != null
          ? int.tryParse(json['satisfaction_rating'].toString())
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
    
    String typeToString(PostType type) {
      switch (type) {
        case PostType.problem:
          return 'problem';
        case PostType.suggestion:
          return 'suggestion';
        case PostType.announcement:
          return 'announcement';
        case PostType.general:
          return 'general';
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
      'type': typeToString(type),
      'likes': likes,
      'highlights': highlights,
      'comment_count': commentCount,
      'is_anonymous': isAnonymous,
      'created_at': createdAt.toIso8601String(),
      'image_urls': imageUrls,
      'video_url': videoUrl,
      'satisfaction_rating': satisfactionRating,
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
    PostType? type,
    int? likes,
    int? highlights,
    int? commentCount,
    bool? isAnonymous,
    DateTime? createdAt,
    List<String>? imageUrls,
    String? videoUrl,
    int? satisfactionRating,
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
      type: type ?? this.type,
      likes: likes ?? this.likes,
      highlights: highlights ?? this.highlights,
      commentCount: commentCount ?? this.commentCount,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      createdAt: createdAt ?? this.createdAt,
      imageUrls: imageUrls ?? this.imageUrls,
      videoUrl: videoUrl ?? this.videoUrl,
      satisfactionRating: satisfactionRating ?? this.satisfactionRating,
    );
  }
}