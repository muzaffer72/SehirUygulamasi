import 'package:flutter/material.dart';

class PoliticalParty {
  final int id;
  final String name;
  final String shortName;
  final String color;
  final String logoUrl;
  final double problemSolvingRate;
  final int cityCount;
  final int districtCount;
  final int complaintCount;
  final int solvedCount;
  final DateTime lastUpdated;

  PoliticalParty({
    required this.id,
    required this.name,
    required this.shortName,
    required this.color,
    required this.logoUrl,
    required this.problemSolvingRate,
    required this.cityCount,
    required this.districtCount,
    required this.complaintCount,
    required this.solvedCount,
    required this.lastUpdated,
  });

  factory PoliticalParty.fromJson(Map<String, dynamic> json) {
    return PoliticalParty(
      id: json['id'],
      name: json['name'],
      shortName: json['short_name'],
      color: json['color'],
      logoUrl: json['logo_url'],
      problemSolvingRate: json['problem_solving_rate'].toDouble(),
      cityCount: json['city_count'],
      districtCount: json['district_count'],
      complaintCount: json['complaint_count'],
      solvedCount: json['solved_count'],
      lastUpdated: DateTime.parse(json['last_updated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'short_name': shortName,
      'color': color,
      'logo_url': logoUrl,
      'problem_solving_rate': problemSolvingRate,
      'city_count': cityCount,
      'district_count': districtCount,
      'complaint_count': complaintCount,
      'solved_count': solvedCount,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  // İlgili parti rengini hex değerinden Flutter Color nesnesine dönüştüren metod
  Color getPartyColor() {
    // Hex renk kodunu (örn. #FF5733) ayrıştır
    String hexColor = color.replaceAll("#", "");
    
    // Hex değerini int formatına çevir
    int colorValue = int.parse(hexColor, radix: 16);
    
    // 0xFF değerini ekleyerek tam ARGB formatına getir
    colorValue = colorValue + 0xFF000000;
    
    return Color(colorValue);
  }

  // Çözüm oranına göre renk döndüren yardımcı metod
  Color getRateColor() {
    if (problemSolvingRate >= 70) {
      return Color(0xFF4CAF50); // Yeşil
    } else if (problemSolvingRate >= 50) {
      return Color(0xFFFFC107); // Sarı/Turuncu
    } else {
      return Color(0xFFF44336); // Kırmızı
    }
  }

  // Başarı oranını formatlanmış bir string olarak döndürme
  String getFormattedRate() {
    return "%${problemSolvingRate.toStringAsFixed(1)}";
  }
}