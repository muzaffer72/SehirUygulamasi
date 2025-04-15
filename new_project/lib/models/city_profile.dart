import 'dart:ui';
import 'package:flutter/material.dart';

class CityProfile {
  final String id;
  final String name;
  final int population;
  final String governmentType;
  final double problemSolvingRate;
  final String? description;
  final String? imageUrl;
  final List<District> districts;
  final List<CategoryStat> categories;
  final int complaintCount;
  final int solvedComplaintCount;
  final int pendingComplaintCount;
  final int rejectedComplaintCount;
  final Mayor? mayor;
  final String? phone;
  final String? email;
  final String? address;
  final String? website;

  CityProfile({
    required this.id,
    required this.name,
    required this.population,
    required this.governmentType,
    required this.problemSolvingRate,
    this.description,
    this.imageUrl,
    required this.districts,
    required this.categories,
    required this.complaintCount,
    required this.solvedComplaintCount,
    required this.pendingComplaintCount,
    required this.rejectedComplaintCount,
    this.mayor,
    this.phone,
    this.email,
    this.address,
    this.website,
  });

  factory CityProfile.fromJson(Map<String, dynamic> json) {
    List<District> districts = [];
    if (json['districts'] != null) {
      districts = List<District>.from(
          json['districts'].map((district) => District.fromJson(district)));
    }

    List<CategoryStat> categories = [];
    if (json['categories'] != null) {
      categories = List<CategoryStat>.from(
          json['categories'].map((category) => CategoryStat.fromJson(category)));
    }

    return CityProfile(
      id: json['id'].toString(),
      name: json['name'],
      population: json['population'] ?? 0,
      governmentType: json['government_type'] ?? 'Belediye',
      problemSolvingRate: (json['problem_solving_rate'] ?? 0).toDouble(),
      description: json['description'],
      imageUrl: json['image_url'],
      districts: districts,
      categories: categories,
      complaintCount: json['complaint_count'] ?? 0,
      solvedComplaintCount: json['solved_complaint_count'] ?? 0,
      pendingComplaintCount: json['pending_complaint_count'] ?? 0,
      rejectedComplaintCount: json['rejected_complaint_count'] ?? 0,
      mayor: json['mayor'] != null ? Mayor.fromJson(json['mayor']) : null,
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      website: json['website'],
    );
  }

  // Veri bulunamazsa örnek veri döndüren fabrika methodu
  factory CityProfile.fallback() {
    return CityProfile(
      id: '0',
      name: 'Bilinmeyen Şehir',
      population: 0,
      governmentType: 'Belediye',
      problemSolvingRate: 0,
      districts: [],
      categories: [],
      complaintCount: 0,
      solvedComplaintCount: 0,
      pendingComplaintCount: 0,
      rejectedComplaintCount: 0,
    );
  }
}

class District {
  final String id;
  final String name;
  final int population;
  final String? imageUrl;

  District({
    required this.id,
    required this.name,
    required this.population,
    this.imageUrl,
  });

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json['id'].toString(),
      name: json['name'],
      population: json['population'] ?? 0,
      imageUrl: json['image_url'],
    );
  }
}

class CategoryStat {
  final String id;
  final String name;
  final int complaintCount;
  final Color? color;

  CategoryStat({
    required this.id,
    required this.name,
    required this.complaintCount,
    this.color,
  });

  factory CategoryStat.fromJson(Map<String, dynamic> json) {
    // Renk değeri hexadecimal string olarak gelebilir
    Color? categoryColor;
    if (json['color'] != null) {
      try {
        categoryColor = Color(int.parse(json['color'].replaceAll('#', '0xFF')));
      } catch (e) {
        categoryColor = Colors.blue;
      }
    }

    return CategoryStat(
      id: json['id'].toString(),
      name: json['name'],
      complaintCount: json['complaint_count'] ?? 0,
      color: categoryColor,
    );
  }
}

class Mayor {
  final String id;
  final String name;
  final String? imageUrl;
  final String? party;
  final String termStart;
  final String? termEnd;
  final String? bio;

  Mayor({
    required this.id,
    required this.name,
    this.imageUrl,
    this.party,
    required this.termStart,
    this.termEnd,
    this.bio,
  });

  factory Mayor.fromJson(Map<String, dynamic> json) {
    return Mayor(
      id: json['id'].toString(),
      name: json['name'],
      imageUrl: json['image_url'],
      party: json['party'],
      termStart: json['term_start'] ?? '',
      termEnd: json['term_end'],
      bio: json['bio'],
    );
  }
}