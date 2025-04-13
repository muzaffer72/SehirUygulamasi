import 'dart:convert';

class PoliticalParty {
  final int id;
  final String name;
  final String shortName;
  final String? description;
  final String logoUrl;
  final String color;
  final bool isActive;
  final int? foundedYear;
  final String? website;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double problemSolvingRate; // Çözüm oranı (%)
  final int totalMunicipalityCount; // Toplam belediye sayısı
  final double averageSatisfactionRate; // Memnuniyet oranı (%)
  final int totalAwards; // Toplam ödül sayısı
  final int goldAwards; // Altın ödül sayısı
  final int silverAwards; // Gümüş ödül sayısı
  final int bronzeAwards; // Bronz ödül sayısı

  PoliticalParty({
    required this.id,
    required this.name,
    required this.shortName,
    this.description,
    required this.logoUrl,
    required this.color,
    required this.isActive,
    this.foundedYear,
    this.website,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    required this.problemSolvingRate,
    required this.totalMunicipalityCount,
    required this.averageSatisfactionRate,
    required this.totalAwards,
    required this.goldAwards,
    required this.silverAwards,
    required this.bronzeAwards,
  });

  factory PoliticalParty.fromJson(Map<String, dynamic> json) {
    return PoliticalParty(
      id: json['id'],
      name: json['name'],
      shortName: json['short_name'],
      description: json['description'],
      logoUrl: json['logo_url'],
      color: json['color'],
      isActive: json['is_active'],
      foundedYear: json['founded_year'],
      website: json['website'],
      sortOrder: json['sort_order'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      problemSolvingRate: double.parse(json['problem_solving_rate']?.toString() ?? '0'),
      totalMunicipalityCount: json['total_municipality_count'] ?? 0,
      averageSatisfactionRate: double.parse(json['average_satisfaction_rate']?.toString() ?? '0'),
      totalAwards: json['total_awards'] ?? 0,
      goldAwards: json['gold_awards'] ?? 0,
      silverAwards: json['silver_awards'] ?? 0,
      bronzeAwards: json['bronze_awards'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'short_name': shortName,
      'description': description,
      'logo_url': logoUrl,
      'color': color,
      'is_active': isActive,
      'founded_year': foundedYear,
      'website': website,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'problem_solving_rate': problemSolvingRate,
      'total_municipality_count': totalMunicipalityCount,
      'average_satisfaction_rate': averageSatisfactionRate,
      'total_awards': totalAwards,
      'gold_awards': goldAwards,
      'silver_awards': silverAwards,
      'bronze_awards': bronzeAwards,
    };
  }

  // Demo amaçlı örnek veriler
  static List<PoliticalParty> getDemoParties() {
    return [
      PoliticalParty(
        id: 1,
        name: 'Adalet ve Kalkınma Partisi',
        shortName: 'AKP',
        description: 'Adalet ve Kalkınma Partisi, merkez-sağ bir partidir.',
        logoUrl: 'assets/party_logos/akp_logo.svg',
        color: '#FFA500',
        isActive: true,
        foundedYear: 2001,
        website: 'https://www.akparti.org.tr',
        sortOrder: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        problemSolvingRate: 72.5,
        totalMunicipalityCount: 25,
        averageSatisfactionRate: 68.0,
        totalAwards: 12,
        goldAwards: 5,
        silverAwards: 4,
        bronzeAwards: 3,
      ),
      PoliticalParty(
        id: 2,
        name: 'Cumhuriyet Halk Partisi',
        shortName: 'CHP',
        description: 'Cumhuriyet Halk Partisi, sosyal demokrat bir partidir.',
        logoUrl: 'assets/party_logos/chp_logo.svg',
        color: '#E30A17',
        isActive: true,
        foundedYear: 1923,
        website: 'https://www.chp.org.tr',
        sortOrder: 2,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        problemSolvingRate: 68.2,
        totalMunicipalityCount: 21,
        averageSatisfactionRate: 65.5,
        totalAwards: 10,
        goldAwards: 3,
        silverAwards: 5,
        bronzeAwards: 2,
      ),
      PoliticalParty(
        id: 3,
        name: 'Milliyetçi Hareket Partisi',
        shortName: 'MHP',
        description: 'Milliyetçi Hareket Partisi, milliyetçi bir partidir.',
        logoUrl: 'assets/party_logos/mhp_logo.svg',
        color: '#0000FF',
        isActive: true,
        foundedYear: 1969,
        website: 'https://www.mhp.org.tr',
        sortOrder: 3,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        problemSolvingRate: 65.8,
        totalMunicipalityCount: 18,
        averageSatisfactionRate: 63.0,
        totalAwards: 8,
        goldAwards: 2,
        silverAwards: 3,
        bronzeAwards: 3,
      ),
      PoliticalParty(
        id: 4,
        name: 'İyi Parti',
        shortName: 'İYİP',
        description: 'İyi Parti, merkez sağ bir partidir.',
        logoUrl: 'assets/party_logos/iyip_logo.svg',
        color: '#00BFFF',
        isActive: true,
        foundedYear: 2017,
        website: 'https://iyiparti.org.tr',
        sortOrder: 4,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        problemSolvingRate: 63.5,
        totalMunicipalityCount: 10,
        averageSatisfactionRate: 61.5,
        totalAwards: 5,
        goldAwards: 1,
        silverAwards: 2,
        bronzeAwards: 2,
      ),
      PoliticalParty(
        id: 5,
        name: 'Halkların Demokratik Partisi',
        shortName: 'HDP',
        description: 'Halkların Demokratik Partisi, sol görüşlü bir partidir.',
        logoUrl: 'assets/party_logos/hdp_logo.svg',
        color: '#800080',
        isActive: true,
        foundedYear: 2012,
        website: 'https://www.hdp.org.tr',
        sortOrder: 5,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        problemSolvingRate: 60.5,
        totalMunicipalityCount: 8,
        averageSatisfactionRate: 59.0,
        totalAwards: 3,
        goldAwards: 0,
        silverAwards: 1,
        bronzeAwards: 2,
      ),
    ];
  }
}