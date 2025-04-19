class User {
  final String id;
  final String name;
  final String email;
  final String? username;
  final String? phone;
  final String? bio;
  final String? profileImageUrl;
  final String? coverImageUrl;
  final String cityId;
  final String? districtId;
  final String? cityName;
  final String? districtName;
  final int postCount;
  final int followersCount;
  final int followingCount;
  final int solutionCount;
  final String? role; // 'user', 'moderator', 'admin'
  final bool isVerified;
  final DateTime createdAt;
  final DateTime? lastLogin;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.username,
    this.phone,
    this.bio,
    this.profileImageUrl,
    this.coverImageUrl,
    required this.cityId,
    this.districtId,
    this.cityName,
    this.districtName,
    this.postCount = 0,
    this.followersCount = 0,
    this.followingCount = 0,
    this.solutionCount = 0,
    this.role = 'user',
    this.isVerified = false,
    required this.createdAt,
    this.lastLogin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    try {
      // API'den gelen veriyi güvenli bir şekilde dönüştür
      return User(
        id: json['id']?.toString() ?? '0',
        name: json['name']?.toString() ?? 'İsimsiz Kullanıcı',
        email: json['email']?.toString() ?? '',
        username: json['username']?.toString(),
        phone: json['phone']?.toString(),
        bio: json['bio']?.toString(),
        profileImageUrl: json['profile_image_url']?.toString(),
        coverImageUrl: json['cover_image_url']?.toString(),
        cityId: json['city_id']?.toString() ?? '0',
        districtId: json['district_id']?.toString(),
        cityName: json['city_name']?.toString(),
        districtName: json['district_name']?.toString(),
        postCount: _parseIntSafely(json['post_count']),
        followersCount: _parseIntSafely(json['followers_count']),
        followingCount: _parseIntSafely(json['following_count']),
        solutionCount: _parseIntSafely(json['solution_count']),
        role: json['role']?.toString() ?? 'user',
        isVerified: json['is_verified'] == true || json['is_verified'] == 1 || json['is_verified'] == '1',
        createdAt: json['created_at'] != null
            ? _parseDateTimeSafely(json['created_at'].toString())
            : DateTime.now(),
        lastLogin: json['last_login'] != null
            ? _parseDateTimeSafely(json['last_login'].toString())
            : null,
      );
    } catch (e) {
      print('Error parsing User from JSON: $e - JSON: $json');
      // Hata durumunda varsayılan bir kullanıcı döndür
      return User(
        id: '0',
        name: 'Hata - Kullanıcı Yüklenemedi',
        email: '',
        cityId: '0',
        createdAt: DateTime.now(),
      );
    }
    
  }
  
  // Int değerlerini güvenli şekilde ayrıştırma
  static int _parseIntSafely(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        return 0;
      }
    }
    return 0;
  }
  
  // DateTime değerlerini güvenli şekilde ayrıştırma
  static DateTime _parseDateTimeSafely(String value) {
    try {
      return DateTime.parse(value);
    } catch (e) {
      return DateTime.now();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'username': username,
      'phone': phone,
      'bio': bio,
      'profile_image_url': profileImageUrl,
      'cover_image_url': coverImageUrl,
      'city_id': cityId,
      'district_id': districtId,
      'city_name': cityName,
      'district_name': districtName,
      'post_count': postCount,
      'followers_count': followersCount,
      'following_count': followingCount,
      'solution_count': solutionCount,
      'role': role,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? username,
    String? phone,
    String? bio,
    String? profileImageUrl,
    String? coverImageUrl,
    String? cityId,
    String? districtId,
    String? cityName,
    String? districtName,
    int? postCount,
    int? followersCount,
    int? followingCount,
    int? solutionCount,
    String? role,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      username: username ?? this.username,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      cityId: cityId ?? this.cityId,
      districtId: districtId ?? this.districtId,
      cityName: cityName ?? this.cityName,
      districtName: districtName ?? this.districtName,
      postCount: postCount ?? this.postCount,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      solutionCount: solutionCount ?? this.solutionCount,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}