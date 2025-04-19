class User {
  final int id;
  final String email;
  final String name;
  final String? username;
  final String? bio;
  final String? phone;
  final String? profileImageUrl;
  final String? coverImageUrl;
  final int? cityId;
  final String? cityName;
  final String? districtId;
  final String? districtName;
  final int? postCount;
  final int? followersCount;
  final int? followingCount;
  final int? points;
  final String? role;
  final bool isVerified;
  final String? lastActivity;
  final String? createdAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.username,
    this.bio,
    this.phone,
    this.profileImageUrl,
    this.coverImageUrl,
    this.cityId,
    this.cityName,
    this.districtId,
    this.districtName,
    this.postCount,
    this.followersCount,
    this.followingCount,
    this.points,
    this.role,
    this.isVerified = false,
    this.lastActivity,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      username: json['username'],
      bio: json['bio'],
      phone: json['phone'],
      profileImageUrl: json['profile_image_url'],
      coverImageUrl: json['cover_image_url'],
      cityId: json['city_id'] is String ? int.parse(json['city_id']) : json['city_id'],
      cityName: json['city_name'],
      districtId: json['district_id']?.toString(),
      districtName: json['district_name'],
      postCount: json['post_count'] is String ? int.parse(json['post_count']) : json['post_count'],
      followersCount: json['followers_count'] is String ? int.parse(json['followers_count']) : json['followers_count'],
      followingCount: json['following_count'] is String ? int.parse(json['following_count']) : json['following_count'],
      points: json['points'] is String ? int.parse(json['points']) : json['points'],
      role: json['role'],
      isVerified: json['is_verified'] == 1 || json['is_verified'] == '1' || json['is_verified'] == true,
      lastActivity: json['last_activity'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'username': username,
      'bio': bio,
      'phone': phone,
      'profile_image_url': profileImageUrl,
      'cover_image_url': coverImageUrl,
      'city_id': cityId,
      'city_name': cityName,
      'district_id': districtId,
      'district_name': districtName,
      'post_count': postCount,
      'followers_count': followersCount,
      'following_count': followingCount,
      'points': points,
      'role': role,
      'is_verified': isVerified ? 1 : 0,
      'last_activity': lastActivity,
      'created_at': createdAt,
    };
  }

  User copyWith({
    int? id,
    String? email,
    String? name,
    String? username,
    String? bio,
    String? phone,
    String? profileImageUrl,
    String? coverImageUrl,
    int? cityId,
    String? cityName,
    String? districtId,
    String? districtName,
    int? postCount,
    int? followersCount,
    int? followingCount,
    int? points,
    String? role,
    bool? isVerified,
    String? lastActivity,
    String? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      cityId: cityId ?? this.cityId,
      cityName: cityName ?? this.cityName,
      districtId: districtId ?? this.districtId,
      districtName: districtName ?? this.districtName,
      postCount: postCount ?? this.postCount,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      points: points ?? this.points,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      lastActivity: lastActivity ?? this.lastActivity,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}