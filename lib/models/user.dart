enum UserLevel {
  newUser,     // 0-100 puan - Yeni Kullanıcı
  contributor, // 101-500 puan - Şehrini Seven
  active,      // 501-1000 puan - Şehir Sevdalısı
  expert,      // 1001-2000 puan - Şehir Aşığı
  master       // 2000+ puan - Şehir Uzmanı
}

class User {
  final String id;
  final String name;
  final String email;
  final String? profileImageUrl;
  final String? bio;
  final String? cityId;
  final String? districtId;
  final bool isVerified;
  final int points;
  final int postCount;
  final int commentCount;
  final UserLevel level;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
    this.bio,
    this.cityId,
    this.districtId,
    required this.isVerified,
    this.points = 0,
    this.postCount = 0,
    this.commentCount = 0,
    this.level = UserLevel.newUser,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      name: json['name'],
      email: json['email'],
      profileImageUrl: json['profile_image_url'],
      bio: json['bio'],
      cityId: json['city_id']?.toString(),
      districtId: json['district_id']?.toString(),
      isVerified: json['is_verified'] ?? false,
      points: json['points'] ?? 0,
      postCount: json['post_count'] ?? 0,
      commentCount: json['comment_count'] ?? 0,
      level: _getUserLevel(json['points'] ?? 0),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  static UserLevel _getUserLevel(int points) {
    if (points >= 2000) return UserLevel.master;
    if (points >= 1001) return UserLevel.expert;
    if (points >= 501) return UserLevel.active;
    if (points >= 101) return UserLevel.contributor;
    return UserLevel.newUser;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profile_image_url': profileImageUrl,
      'bio': bio,
      'city_id': cityId,
      'district_id': districtId,
      'is_verified': isVerified,
      'points': points,
      'post_count': postCount,
      'comment_count': commentCount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? profileImageUrl,
    String? bio,
    String? cityId,
    String? districtId,
    bool? isVerified,
    int? points,
    int? postCount,
    int? commentCount,
    UserLevel? level,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
      cityId: cityId ?? this.cityId,
      districtId: districtId ?? this.districtId,
      isVerified: isVerified ?? this.isVerified,
      points: points ?? this.points,
      postCount: postCount ?? this.postCount,
      commentCount: commentCount ?? this.commentCount,
      level: level ?? this.level,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String getLevelName() {
    switch (level) {
      case UserLevel.newUser:
        return "Yeni Kullanıcı";
      case UserLevel.contributor:
        return "Şehrini Seven";
      case UserLevel.active:
        return "Şehir Sevdalısı";
      case UserLevel.expert:
        return "Şehir Aşığı";
      case UserLevel.master:
        return "Şehir Uzmanı";
    }
  }
}