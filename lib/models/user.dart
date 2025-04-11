class User {
  final int id;
  final String name;
  final String email;
  final bool isVerified;
  final int? cityId;
  final int? districtId;
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
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      isVerified: json['is_verified'] ?? false,
      cityId: json['city_id'],
      districtId: json['district_id'],
      createdAt: json['created_at'],
      userLevel: json['user_level'] ?? 'newUser',
      points: json['points'] ?? 0,
      totalPosts: json['total_posts'] ?? 0,
      totalComments: json['total_comments'] ?? 0,
      profilePhotoUrl: json['profile_photo_url'],
      solvedIssues: json['solved_issues'] ?? 0,
      badge: json['badge'],
    );
  }

  // Method to convert a User instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
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
    bool? isVerified,
    int? cityId,
    int? districtId,
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