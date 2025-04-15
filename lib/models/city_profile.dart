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
  final String? contactPhone;
  final String? contactEmail;
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
  final String? politicalParty;
  final String? politicalPartyLogoUrl;
  final String? info;
  final int? totalPosts;
  final int? totalSolvedIssues;
  final double? solutionRate;

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
    this.contactPhone,
    this.contactEmail,
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
    this.politicalParty,
    this.politicalPartyLogoUrl,
    this.info,
    this.totalPosts,
    this.totalSolvedIssues,
    this.solutionRate,
  });

  factory CityProfile.fromJson(Map<String, dynamic> json) {
    return CityProfile(
      id: json['id']?.toString() ?? '',
      cityId: json['city_id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      mayor: json['mayor'],
      mayorPhoto: json['mayor_photo'],
      population: json['population']?.toString(),
      area: json['area']?.toString(),
      established: json['established'],
      website: json['website'],
      contactPhone: json['contact_phone'] ?? json['phone'],
      contactEmail: json['contact_email'] ?? json['email'],
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
      politicalParty: json['political_party'],
      politicalPartyLogoUrl: json['political_party_logo_url'],
      info: json['info'],
      totalPosts: json['total_posts'],
      totalSolvedIssues: json['total_solved_issues'],
      solutionRate: json['solution_rate']?.toDouble(),
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
      'contact_phone': contactPhone,
      'contact_email': contactEmail,
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
      'political_party': politicalParty,
      'political_party_logo_url': politicalPartyLogoUrl,
      'info': info,
      'total_posts': totalPosts,
      'total_solved_issues': totalSolvedIssues,
      'solution_rate': solutionRate,
    };
  }
}