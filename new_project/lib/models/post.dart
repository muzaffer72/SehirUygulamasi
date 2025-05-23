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
  final String? username;
  final String? profileImageUrl;
  final bool isLiked; // Kullanıcı tarafından beğenilip beğenilmediği
  
  // Ek bilgiler - şehir, ilçe, kategori adları
  final String? cityName;     // Şehir adı
  final String? districtName; // İlçe adı
  final String? categoryName; // Kategori adı
  final String? userEmail;    // Kullanıcı e-postası
  

  
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
  
  // Konum bilgisi var mı kontrolü
  bool get hasLocationInfo => cityId != null || cityName != null;
  
  // Kullanıcı bilgisi var mı kontrolü
  bool get hasUserInfo => userId != "0" && (username != null || userEmail != null);

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
    this.username,
    this.profileImageUrl,
    this.cityName,
    this.districtName,
    this.categoryName,
    this.userEmail,
    this.isLiked = false,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    // Admin panel format desteği için JSON'daki anahtar isimlerini kontrol edelim
    Map<String, dynamic> data = {...json};
    
    // Admin panel keys mapping
    final keyMap = {
      'post_id': 'id',
      'post_title': 'title',
      'post_content': 'content',
      'post_status': 'status',
      'post_type': 'type',
      'user_name': 'user_name',  // ekstra bilgi, depolanmayacak
      'like_count': 'likes',
      'highlight_count': 'highlights',
      'comments_count': 'comment_count',
      'anonymous': 'is_anonymous',
      'post_date': 'created_at',
      'post_images': 'image_urls',
      'post_video': 'video_url',
      'satisfaction_score': 'satisfaction_rating',
      
      // PostgreSQL API yanıt formatı için ek mapping
      'city_name': 'city_name',
      'district_name': 'district_name',
      'category_name': 'category_name',
      'user_email': 'user_email',
      'user_username': 'user_username',
    };
    
    // Admin panel anahtar isimlerini standart isimlere dönüştürme
    keyMap.forEach((adminKey, standardKey) {
      if (json.containsKey(adminKey) && !json.containsKey(standardKey)) {
        data[standardKey] = json[adminKey];
      }
    });
    
    // Media URLs formatı için
    if (json.containsKey('media') && json['media'] is List) {
      final List<dynamic> mediaList = json['media'];
      List<String> imageUrlsList = [];
      
      for (var media in mediaList) {
        if (media is Map && media.containsKey('url')) {
          imageUrlsList.add(media['url']);
        } else if (media is String) {
          imageUrlsList.add(media);
        }
      }
      
      if (imageUrlsList.isNotEmpty) {
        data['image_urls'] = imageUrlsList;
      }
    }
    
    // Uyumlu olmayan field tipleri için düzenleme
    // PostgreSQL'den gelen boolean değerleri düzelt
    if (data.containsKey('is_anonymous') && data['is_anonymous'] is String) {
      data['is_anonymous'] = data['is_anonymous'].toString().toLowerCase() == 't' ||
                            data['is_anonymous'].toString().toLowerCase() == 'true' ||
                            data['is_anonymous'].toString() == '1';
    }
    
    // PostStatus parsing with better error handling
    PostStatus parseStatus(dynamic status) {
      if (status == null) return PostStatus.awaitingSolution;
      
      // Convert to string if numeric
      if (status is int) {
        switch (status) {
          case 0: return PostStatus.awaitingSolution;
          case 1: return PostStatus.inProgress;
          case 2: return PostStatus.solved;
          case 3: return PostStatus.rejected;
          default: return PostStatus.awaitingSolution;
        }
      }
      
      // Handle string representation 
      final statusStr = status.toString().toLowerCase().trim();
      
      if (statusStr.contains('await') || statusStr == '0') {
        return PostStatus.awaitingSolution;
      } else if (statusStr.contains('progress') || statusStr == '1') {
        return PostStatus.inProgress;
      } else if (statusStr.contains('solve') || statusStr == '2') {
        return PostStatus.solved;
      } else if (statusStr.contains('reject') || statusStr == '3') {
        return PostStatus.rejected;
      }
      
      return PostStatus.awaitingSolution;
    }
    
    // PostType parsing with better error handling
    PostType parseType(dynamic type) {
      if (type == null) return PostType.problem;
      
      // Convert to string if numeric
      if (type is int) {
        switch (type) {
          case 0: return PostType.problem;
          case 1: return PostType.suggestion;
          case 2: return PostType.announcement;
          case 3: return PostType.general;
          default: return PostType.problem;
        }
      }
      
      // Handle string representation
      final typeStr = type.toString().toLowerCase().trim();
      
      if (typeStr.contains('problem') || typeStr == '0') {
        return PostType.problem;
      } else if (typeStr.contains('suggest') || typeStr == '1') {
        return PostType.suggestion; 
      } else if (typeStr.contains('announce') || typeStr == '2') {
        return PostType.announcement;
      } else if (typeStr.contains('general') || typeStr == '3') {
        return PostType.general;
      }
      
      return PostType.problem;
    }
    
    // Tarih formatı düzenlemesi
    DateTime parseDateTime(dynamic dateValue) {
      if (dateValue == null) return DateTime.now();
      
      if (dateValue is String) {
        try {
          return DateTime.parse(dateValue);
        } catch (e) {
          print('Date parsing error: $e for value: $dateValue');
          return DateTime.now();
        }
      } else if (dateValue is int) {
        // Unix timestamp
        return DateTime.fromMillisecondsSinceEpoch(dateValue * 1000);
      }
      
      return DateTime.now();
    }
    
    try {
      // Şehir ve ilçe adı bilgilerini kontrol et
      final String? cityName = data['city_name'] as String?;
      final String? districtName = data['district_name'] as String?;
      final String? categoryName = data['category_name'] as String?;
      
      // Kullanıcı bilgilerini kontrol et
      String? username = data['username'] as String?;
      // Eğer username değeri null ise, user_name veya user_username alanlarını kontrol et
      if (username == null) {
        username = data['user_name'] as String?;
        if (username == null) {
          username = data['user_username'] as String?;
        }
      }
      
      // Kullanıcı e-posta bilgisini kontrol et
      final String? userEmail = data['user_email'] as String?;
      
      return Post(
        id: (data['id'] ?? '0').toString(),
        title: data['title'] ?? 'Başlıksız Gönderi',
        content: data['content'] ?? '',
        userId: (data['user_id'] ?? '0').toString(),
        categoryId: (data['category_id'] ?? '0').toString(),
        cityId: data['city_id']?.toString(),
        districtId: data['district_id']?.toString(),
        status: parseStatus(data['status']),
        type: parseType(data['type']),
        likes: data['likes'] != null ? (data['likes'] is int ? data['likes'] : int.tryParse(data['likes'].toString()) ?? 0) : 
              data['like_count'] != null ? (data['like_count'] is int ? data['like_count'] : int.tryParse(data['like_count'].toString()) ?? 0) : 0,
        highlights: data['highlights'] != null ? (data['highlights'] is int ? data['highlights'] : int.tryParse(data['highlights'].toString()) ?? 0) : 
                  data['highlight_count'] != null ? (data['highlight_count'] is int ? data['highlight_count'] : int.tryParse(data['highlight_count'].toString()) ?? 0) : 0,
        commentCount: data['comment_count'] != null ? (data['comment_count'] is int ? data['comment_count'] : int.tryParse(data['comment_count'].toString()) ?? 0) : 
                    data['comments_count'] != null ? (data['comments_count'] is int ? data['comments_count'] : int.tryParse(data['comments_count'].toString()) ?? 0) : 0,
        isAnonymous: data['is_anonymous'] ?? data['anonymous'] ?? false,
        createdAt: parseDateTime(data['created_at'] ?? data['post_date']),
        imageUrls: data['image_urls'] is List 
            ? List<String>.from(data['image_urls'])
            : null,
        videoUrl: data['video_url'] ?? data['post_video'],
        satisfactionRating: data['satisfaction_rating'] != null
            ? int.tryParse(data['satisfaction_rating'].toString())
            : data['satisfaction_score'] != null
                ? int.tryParse(data['satisfaction_score'].toString())
                : null,
        username: username,
        profileImageUrl: data['profile_image_url'],
        cityName: cityName,
        districtName: districtName,
        categoryName: categoryName,
        userEmail: userEmail,
        isLiked: data['is_liked'] == true || data['liked_by_user'] == true || data['liked'] == true,
      );
    } catch (e) {
      print('Error parsing Post from JSON: $e');
      print('Problematic JSON: $json');
      
      // Fallback to minimal valid post
      return Post(
        id: (json['id'] ?? '0').toString(),
        title: json['title'] ?? 'Hatalı Gönderi',
        content: json['content'] ?? 'İçerik yüklenirken hata oluştu.',
        userId: (json['user_id'] ?? '0').toString(),
        categoryId: (json['category_id'] ?? '0').toString(),
        status: PostStatus.awaitingSolution,
        likes: 0,
        highlights: 0,
        createdAt: DateTime.now(),
      );
    }
  }

  Map<String, dynamic> toJson() {
    // Status string conversion
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
    
    // Type string conversion
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
    
    // Admin panel ile uyumlu formatlar
    Map<String, dynamic> standardFormat = {
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
      'username': username,
      'profile_image_url': profileImageUrl,
      'city_name': cityName,
      'district_name': districtName,
      'category_name': categoryName,
      'user_email': userEmail,
    };
    
    // Admin panel formatı için ek alanlar ekle
    Map<String, dynamic> adminFormat = {
      'post_id': id,
      'post_title': title,
      'post_content': content,
      'post_status': statusToString(status),
      'post_type': typeToString(type),
      'like_count': likes,
      'highlight_count': highlights,
      'comments_count': commentCount,
      'anonymous': isAnonymous,
      'post_date': createdAt.toIso8601String(),
    };
    
    // İki formatı birleştir (Admin panel ve standart API)
    return {...standardFormat, ...adminFormat};
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
    String? username,
    String? profileImageUrl,
    String? cityName,
    String? districtName,
    String? categoryName,
    String? userEmail,
    bool? isLiked,
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
      username: username ?? this.username,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      cityName: cityName ?? this.cityName,
      districtName: districtName ?? this.districtName,
      categoryName: categoryName ?? this.categoryName,
      userEmail: userEmail ?? this.userEmail,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}