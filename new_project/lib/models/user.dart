class User {
  final int id;
  final String email;
  final String name;
  final String? username;
  final String? bio;
  final String? phone;
  final String? profileImageUrl;
  final String? coverImageUrl;
  final String? cityId; // String tipine dönüştürüldü, API tutarlılığı için
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
    // ID her zaman tam sayıdır, ancak API'den string veya int olarak gelebilir
    int userId = 0;
    try {
      if (json['id'] is String) {
        userId = int.parse(json['id']);
      } else if (json['id'] is int) {
        userId = json['id'];
      }
    } catch (e) {
      print('User ID parse hatası: $e');
    }
    
    // Profil fotoğrafı için alternatif alanları kontrol et
    String? profileImage = json['profile_image_url'] ?? json['profile_photo_url'] ?? json['avatar'];
    
    // PostgreSQL veritabanı uyumu için post_count veya total_posts kullan
    int? postCountVal;
    try {
      if (json['post_count'] != null) {
        postCountVal = json['post_count'] is String ? int.parse(json['post_count']) : json['post_count'];
      } else if (json['total_posts'] != null) {
        postCountVal = json['total_posts'] is String ? int.parse(json['total_posts']) : json['total_posts'];
      }
    } catch (e) {
      print('Post count parse hatası: $e');
    }
    
    // Puan için alternatif alanları kontrol et
    int? pointsVal;
    try {
      if (json['points'] != null) {
        pointsVal = json['points'] is String ? int.parse(json['points']) : json['points'];
      }
    } catch (e) {
      print('Points parse hatası: $e');
    }
    
    // Kullanıcı rolü için user_level veya level kullan
    String? roleVal = json['role'] ?? json['user_level'] ?? json['level'];
    
    return User(
      id: userId,
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      username: json['username'],
      bio: json['bio'],
      phone: json['phone'],
      profileImageUrl: profileImage,
      coverImageUrl: json['cover_image_url'],
      cityId: json['city_id']?.toString(),
      cityName: json['city_name'],
      districtId: json['district_id']?.toString(),
      districtName: json['district_name'],
      postCount: postCountVal,
      followersCount: json['followers_count'] is String ? int.parse(json['followers_count'] ?? '0') : json['followers_count'],
      followingCount: json['following_count'] is String ? int.parse(json['following_count'] ?? '0') : json['following_count'],
      points: pointsVal,
      role: roleVal,
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
    String? cityId, // int -> String tipine dönüştürüldü
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