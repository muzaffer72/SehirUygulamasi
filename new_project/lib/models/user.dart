import 'package:flutter/material.dart';

class User {
  final String id;
  final String name;
  final String? username;
  final String? email;
  final String? phone;
  final String? profileImageUrl;
  final String? coverImageUrl;
  final String? bio;
  final bool isVerified;
  final bool isAdmin;
  final DateTime createdAt;
  final int postCount;
  final int followerCount;
  final int followingCount;
  final int cityId;
  final String? cityName;
  final String? districtName;

  User({
    required this.id,
    required this.name,
    this.username,
    this.email,
    this.phone,
    this.profileImageUrl,
    this.coverImageUrl,
    this.bio,
    this.isVerified = false,
    this.isAdmin = false,
    required this.createdAt,
    this.postCount = 0,
    this.followerCount = 0,
    this.followingCount = 0,
    required this.cityId,
    this.cityName,
    this.districtName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      name: json['name'] ?? 'İsimsiz Kullanıcı',
      username: json['username'],
      email: json['email'],
      phone: json['phone'],
      profileImageUrl: json['profile_image_url'],
      coverImageUrl: json['cover_image_url'],
      bio: json['bio'],
      isVerified: json['is_verified'] ?? false,
      isAdmin: json['is_admin'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      postCount: json['post_count'] ?? 0,
      followerCount: json['follower_count'] ?? 0,
      followingCount: json['following_count'] ?? 0,
      cityId: int.tryParse(json['city_id']?.toString() ?? '0') ?? 0,
      cityName: json['city_name'],
      districtName: json['district_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'phone': phone,
      'profile_image_url': profileImageUrl,
      'cover_image_url': coverImageUrl,
      'bio': bio,
      'is_verified': isVerified,
      'is_admin': isAdmin,
      'created_at': createdAt.toIso8601String(),
      'post_count': postCount,
      'follower_count': followerCount,
      'following_count': followingCount,
      'city_id': cityId,
      'city_name': cityName,
      'district_name': districtName,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? username,
    String? email,
    String? phone,
    String? profileImageUrl,
    String? coverImageUrl,
    String? bio,
    bool? isVerified,
    bool? isAdmin,
    DateTime? createdAt,
    int? postCount,
    int? followerCount,
    int? followingCount,
    int? cityId,
    String? cityName,
    String? districtName,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      bio: bio ?? this.bio,
      isVerified: isVerified ?? this.isVerified,
      isAdmin: isAdmin ?? this.isAdmin,
      createdAt: createdAt ?? this.createdAt,
      postCount: postCount ?? this.postCount,
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount ?? this.followingCount,
      cityId: cityId ?? this.cityId,
      cityName: cityName ?? this.cityName,
      districtName: districtName ?? this.districtName,
    );
  }
}