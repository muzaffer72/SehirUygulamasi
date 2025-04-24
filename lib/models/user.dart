class User {
  final int id;
  final String name;
  final String email;
  final String? username;
  final bool isVerified;
  final String? cityId;
  final String? districtId;
  final String? createdAt;
  final String? userLevel;
  final int points;
  final int totalPosts;
  final int totalComments;
  final String? profilePhotoUrl;
  final int solvedIssues;
  final String? badge;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.username,
    this.isVerified = false,
    this.cityId,
    this.districtId,
    this.createdAt,
    this.userLevel = 'newUser',
    this.points = 0,
    this.totalPosts = 0,
    this.totalComments = 0,
    this.profilePhotoUrl,
    this.solvedIssues = 0,
    this.badge,
  });

  // Factory constructor to create a User from a JSON map
  factory User.fromJson(Map<String, dynamic> json) {
    // ID değerini düzgün şekilde alalım
    int userId;
    if (json['id'] is String) {
      userId = int.tryParse(json['id']) ?? 0;
    } else {
      userId = json['id'] ?? 0;
    }
    
    // Profile image URL için farklı alan isimlerini kontrol edelim
    String? profileImage = json['profile_photo_url'] ?? 
                          json['profile_image_url'] ?? 
                          json['profile_image'] ?? 
                          json['avatar'];
    
    return User(
      id: userId,
      name: json['name'] ?? 'Kullanıcı',
      email: json['email'] ?? '',
      username: json['username'],
      isVerified: json['is_verified'] == true || json['is_verified'] == 1,
      cityId: json['city_id']?.toString(),
      districtId: json['district_id']?.toString(),
      createdAt: json['created_at'],
      userLevel: json['user_level'] ?? json['level'] ?? 'newUser',
      points: json['points'] is String 
              ? int.tryParse(json['points']) ?? 0 
              : json['points'] ?? 0,
      totalPosts: json['total_posts'] is String 
                  ? int.tryParse(json['total_posts']) ?? 0 
                  : (json['total_posts'] ?? json['post_count'] ?? 0),
      totalComments: json['total_comments'] is String 
                    ? int.tryParse(json['total_comments']) ?? 0 
                    : (json['total_comments'] ?? json['comment_count'] ?? 0),
      profilePhotoUrl: profileImage,
      solvedIssues: json['solved_issues'] is String 
                    ? int.tryParse(json['solved_issues']) ?? 0 
                    : json['solved_issues'] ?? 0,
      badge: json['badge'],
    );
  }

  // Method to convert a User instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'username': username,
      'is_verified': isVerified,
      'city_id': cityId,
      'district_id': districtId,
      'created_at': createdAt,
      'user_level': userLevel,
      'points': points,
      'total_posts': totalPosts,
      'total_comments': totalComments,
      'profile_photo_url': profilePhotoUrl,
      'solved_issues': solvedIssues,
      'badge': badge,
    };
  }

  // Create a copy of this user with updated attributes
  User copyWith({
    int? id,
    String? name,
    String? email,
    String? username,
    bool? isVerified,
    String? cityId,
    String? districtId,
    String? createdAt,
    String? userLevel,
    int? points,
    int? totalPosts,
    int? totalComments,
    String? profilePhotoUrl,
    int? solvedIssues,
    String? badge,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      username: username ?? this.username,
      isVerified: isVerified ?? this.isVerified,
      cityId: cityId ?? this.cityId,
      districtId: districtId ?? this.districtId,
      createdAt: createdAt ?? this.createdAt,
      userLevel: userLevel ?? this.userLevel,
      points: points ?? this.points,
      totalPosts: totalPosts ?? this.totalPosts,
      totalComments: totalComments ?? this.totalComments,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      solvedIssues: solvedIssues ?? this.solvedIssues,
      badge: badge ?? this.badge,
    );
  }
}