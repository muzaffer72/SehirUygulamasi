class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? profilePhotoUrl;
  final String? cityId;
  final String? districtId;
  final bool isAdmin;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profilePhotoUrl,
    this.cityId,
    this.districtId,
    required this.isAdmin,
    required this.createdAt,
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
      isAdmin: json['is_admin'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
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
      'is_admin': isAdmin,
      'created_at': createdAt.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profilePhotoUrl,
    String? cityId,
    String? districtId,
    bool? isAdmin,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      cityId: cityId ?? this.cityId,
      districtId: districtId ?? this.districtId,
      isAdmin: isAdmin ?? this.isAdmin,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}