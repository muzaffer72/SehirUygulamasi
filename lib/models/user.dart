class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? profilePhotoUrl;
  final String cityId;
  final String districtId;
  final List<String> roles;
  final DateTime createdAt;
  final bool isVerified;
  
  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profilePhotoUrl,
    required this.cityId,
    required this.districtId,
    required this.roles,
    required this.createdAt,
    required this.isVerified,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      profilePhotoUrl: json['profile_photo_url'],
      cityId: json['city_id'],
      districtId: json['district_id'],
      roles: List<String>.from(json['roles'] ?? []),
      createdAt: DateTime.parse(json['created_at']),
      isVerified: json['is_verified'] ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profile_photo_url': profilePhotoUrl,
      'city_id': cityId,
      'district_id': districtId,
      'roles': roles,
      'created_at': createdAt.toIso8601String(),
      'is_verified': isVerified,
    };
  }
  
  bool get isAdmin => roles.contains('admin');
  bool get isModerator => roles.contains('moderator');
  
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profilePhotoUrl,
    String? cityId,
    String? districtId,
    List<String>? roles,
    DateTime? createdAt,
    bool? isVerified,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      cityId: cityId ?? this.cityId,
      districtId: districtId ?? this.districtId,
      roles: roles ?? this.roles,
      createdAt: createdAt ?? this.createdAt,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}