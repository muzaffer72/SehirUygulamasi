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
  final bool isActive;

  PoliticalParty({
    required this.id,
    required this.name,
    required this.shortName,
    required this.color,
    required this.logoUrl,
    required this.problemSolvingRate,
    this.cityCount = 0,
    this.districtCount = 0,
    this.complaintCount = 0,
    this.solvedCount = 0,
    DateTime? lastUpdated,
    this.isActive = true,
  }) : this.lastUpdated = lastUpdated ?? DateTime.now();

  factory PoliticalParty.fromJson(Map<String, dynamic> json) {
    return PoliticalParty(
      id: json['id'],
      name: json['name'],
      shortName: json['short_name'],
      color: json['color'],
      logoUrl: json['logo_url'],
      problemSolvingRate: json['problem_solving_rate']?.toDouble() ?? 0.0,
      cityCount: json['city_count'] ?? 0,
      districtCount: json['district_count'] ?? 0,
      complaintCount: json['complaint_count'] ?? 0,
      solvedCount: json['solved_count'] ?? 0,
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'])
          : null,
      isActive: json['is_active'] ?? true,
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
      'is_active': isActive,
    };
  }

  // Demo veriler (API hazır olmadığında gösterim amaçlı)
  static List<PoliticalParty> getDemoParties() {
    return [
      PoliticalParty(
        id: 1,
        name: 'Adalet ve Kalkınma Partisi',
        shortName: 'AK Parti',
        color: '#FFA500',
        logoUrl: 'assets/images/parties/akp.png',
        problemSolvingRate: 68.5,
        cityCount: 45,
        districtCount: 562,
        complaintCount: 12750,
        solvedCount: 8734,
      ),
      PoliticalParty(
        id: 2,
        name: 'Cumhuriyet Halk Partisi',
        shortName: 'CHP',
        color: '#FF0000',
        logoUrl: 'assets/images/parties/chp.png',
        problemSolvingRate: 71.2,
        cityCount: 22,
        districtCount: 234,
        complaintCount: 8540,
        solvedCount: 6080,
      ),
      PoliticalParty(
        id: 3,
        name: 'Milliyetçi Hareket Partisi',
        shortName: 'MHP',
        color: '#FF4500',
        logoUrl: 'assets/images/parties/mhp.png',
        problemSolvingRate: 57.8,
        cityCount: 8,
        districtCount: 102,
        complaintCount: 3240,
        solvedCount: 1872,
      ),
      PoliticalParty(
        id: 4,
        name: 'İyi Parti',
        shortName: 'İYİ Parti',
        color: '#1E90FF',
        logoUrl: 'assets/images/parties/iyi.png',
        problemSolvingRate: 63.4,
        cityCount: 3,
        districtCount: 25,
        complaintCount: 980,
        solvedCount: 621,
      ),
      PoliticalParty(
        id: 5,
        name: 'Demokratik Sol Parti',
        shortName: 'DSP',
        color: '#FF69B4',
        logoUrl: 'assets/images/parties/dsp.png',
        problemSolvingRate: 52.1,
        cityCount: 1,
        districtCount: 5,
        complaintCount: 320,
        solvedCount: 167,
      ),
      PoliticalParty(
        id: 6,
        name: 'Yeniden Refah Partisi',
        shortName: 'YRP',
        color: '#006400',
        logoUrl: 'assets/images/parties/yrp.png',
        problemSolvingRate: 44.3,
        cityCount: 0,
        districtCount: 3,
        complaintCount: 85,
        solvedCount: 38,
      ),
    ];
  }
}