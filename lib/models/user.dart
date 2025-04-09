class User {
  final String id;
  final String name;
  final String email;
  final bool isVerified;
  final String? cityId;
  final String? districtId;
  final String? profileImageUrl;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.isVerified,
    this.cityId,
    this.districtId,
    this.profileImageUrl,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      name: json['name'],
      email: json['email'],
      isVerified: json['is_verified'] ?? false,
      cityId: json['city_id']?.toString(),
      districtId: json['district_id']?.toString(),
      profileImageUrl: json['profile_image_url'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'is_verified': isVerified,
      'city_id': cityId,
      'district_id': districtId,
      'profile_image_url': profileImageUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}