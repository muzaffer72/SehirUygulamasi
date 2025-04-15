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
    return User(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      username: json['username'],
      phone: json['phone'],
      bio: json['bio'],
      profileImageUrl: json['profile_image_url'],
      coverImageUrl: json['cover_image_url'],
      cityId: json['city_id']?.toString() ?? '0',
      districtId: json['district_id']?.toString(),
      cityName: json['city_name'],
      districtName: json['district_name'],
      postCount: json['post_count'] ?? 0,
      followersCount: json['followers_count'] ?? 0,
      followingCount: json['following_count'] ?? 0,
      solutionCount: json['solution_count'] ?? 0,
      role: json['role'] ?? 'user',
      isVerified: json['is_verified'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'])
          : null,
    );
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