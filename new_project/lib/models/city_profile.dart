class CityProfile {
  final String id;
  final String cityId;
  final String name;
  final String? description;
  final String? mayor;
  final String? mayorPhoto;
  final String? population;
  final String? area;
  final String? established;
  final String? website;
  final String? phone;
  final String? email;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? logoUrl;
  final String? bannerUrl;
  final String? videoUrl;
  final int totalComplaints;
  final int solvedComplaints;
  final int activeComplaints;
  final int totalSuggestions;
  final double satisfactionRate;
  final double responseRate;
  final double problemSolvingRate;
  final int averageResponseTime;

  CityProfile({
    required this.id,
    required this.cityId,
    required this.name,
    this.description,
    this.mayor,
    this.mayorPhoto,
    this.population,
    this.area,
    this.established,
    this.website,
    this.phone,
    this.email,
    this.address,
    this.latitude,
    this.longitude,
    this.logoUrl,
    this.bannerUrl,
    this.videoUrl,
    this.totalComplaints = 0,
    this.solvedComplaints = 0,
    this.activeComplaints = 0,
    this.totalSuggestions = 0,
    this.satisfactionRate = 0.0,
    this.responseRate = 0.0,
    this.problemSolvingRate = 0.0,
    this.averageResponseTime = 0,
  });

  factory CityProfile.fromJson(Map<String, dynamic> json) {
    return CityProfile(
      id: json['id'].toString(),
      cityId: json['city_id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      mayor: json['mayor'],
      mayorPhoto: json['mayor_photo'],
      population: json['population']?.toString(),
      area: json['area']?.toString(),
      established: json['established'],
      website: json['website'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      logoUrl: json['logo_url'],
      bannerUrl: json['banner_url'],
      videoUrl: json['video_url'],
      totalComplaints: json['total_complaints'] ?? 0,
      solvedComplaints: json['solved_complaints'] ?? 0,
      activeComplaints: json['active_complaints'] ?? 0,
      totalSuggestions: json['total_suggestions'] ?? 0,
      satisfactionRate: json['satisfaction_rate']?.toDouble() ?? 0.0,
      responseRate: json['response_rate']?.toDouble() ?? 0.0,
      problemSolvingRate: json['problem_solving_rate']?.toDouble() ?? 0.0,
      averageResponseTime: json['average_response_time'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'city_id': cityId,
      'name': name,
      'description': description,
      'mayor': mayor,
      'mayor_photo': mayorPhoto,
      'population': population,
      'area': area,
      'established': established,
      'website': website,
      'phone': phone,
      'email': email,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'logo_url': logoUrl,
      'banner_url': bannerUrl,
      'video_url': videoUrl,
      'total_complaints': totalComplaints,
      'solved_complaints': solvedComplaints,
      'active_complaints': activeComplaints,
      'total_suggestions': totalSuggestions,
      'satisfaction_rate': satisfactionRate,
      'response_rate': responseRate,
      'problem_solving_rate': problemSolvingRate,
      'average_response_time': averageResponseTime,
    };
  }

  // Memnuniyet oranını yüzde olarak formatla
  String get formattedSatisfactionRate => '%${(satisfactionRate * 100).toStringAsFixed(1)}';

  // Yanıt oranını yüzde olarak formatla  
  String get formattedResponseRate => '%${(responseRate * 100).toStringAsFixed(1)}';

  // Problem çözme oranını yüzde olarak formatla
  String get formattedProblemSolvingRate => '%${(problemSolvingRate * 100).toStringAsFixed(1)}';

  // Ortalama yanıt süresini gün cinsinden formatla
  String get formattedResponseTime {
    if (averageResponseTime < 24) {
      return '$averageResponseTime saat';
    } else {
      final days = (averageResponseTime / 24).floor();
      return '$days gün';
    }
  }

  // Nüfus ve alan bilgisine göre nüfus yoğunluğunu hesapla
  String? get populationDensity {
    if (population == null || area == null) return null;
    
    try {
      final populationValue = int.parse(population!);
      final areaValue = double.parse(area!);
      
      if (areaValue == 0) return null;
      
      final density = (populationValue / areaValue).round();
      return '$density kişi/km²';
    } catch (e) {
      return null;
    }
  }

  CityProfile copyWith({
    String? id,
    String? cityId,
    String? name,
    String? description,
    String? mayor,
    String? mayorPhoto,
    String? population,
    String? area,
    String? established,
    String? website,
    String? phone,
    String? email,
    String? address,
    double? latitude,
    double? longitude,
    String? logoUrl,
    String? bannerUrl,
    String? videoUrl,
    int? totalComplaints,
    int? solvedComplaints,
    int? activeComplaints,
    int? totalSuggestions,
    double? satisfactionRate,
    double? responseRate,
    double? problemSolvingRate,
    int? averageResponseTime,
  }) {
    return CityProfile(
      id: id ?? this.id,
      cityId: cityId ?? this.cityId,
      name: name ?? this.name,
      description: description ?? this.description,
      mayor: mayor ?? this.mayor,
      mayorPhoto: mayorPhoto ?? this.mayorPhoto,
      population: population ?? this.population,
      area: area ?? this.area,
      established: established ?? this.established,
      website: website ?? this.website,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      logoUrl: logoUrl ?? this.logoUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      totalComplaints: totalComplaints ?? this.totalComplaints,
      solvedComplaints: solvedComplaints ?? this.solvedComplaints,
      activeComplaints: activeComplaints ?? this.activeComplaints,
      totalSuggestions: totalSuggestions ?? this.totalSuggestions,
      satisfactionRate: satisfactionRate ?? this.satisfactionRate,
      responseRate: responseRate ?? this.responseRate,
      problemSolvingRate: problemSolvingRate ?? this.problemSolvingRate,
      averageResponseTime: averageResponseTime ?? this.averageResponseTime,
    );
  }
}