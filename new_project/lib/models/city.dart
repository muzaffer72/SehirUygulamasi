class City {
  final String id;
  final String name;
  final String? description;
  final String? contactPhone;
  final String? contactEmail;
  final String? logoUrl;
  final int? complaintCount; // Şikayet sayısı
  final int? districtCount;  // İlçe sayısı
  final double? solutionRate; // Çözüm oranı

  City({
    required this.id,
    required this.name,
    this.description,
    this.contactPhone,
    this.contactEmail,
    this.logoUrl,
    this.complaintCount,
    this.districtCount,
    this.solutionRate,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    // API'den gelen tüm olası alan isimlerini kontrol et
    return City(
      id: json['id'].toString(),
      name: json['name'],
      description: json['description'],
      contactPhone: json['contact_phone'] ?? json['phone'],
      contactEmail: json['contact_email'] ?? json['email'],
      logoUrl: json['logo_url'],
      // Yeni eklenen alanlar
      complaintCount: json['complaint_count'] ?? json['total_complaints'],
      districtCount: json['district_count'],
      solutionRate: json['solution_rate'] != null ? 
          (json['solution_rate'] is int ? 
              json['solution_rate'].toDouble() : 
              json['solution_rate']) : 
          json['problem_solving_rate']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'contact_phone': contactPhone,
      'contact_email': contactEmail,
      'logo_url': logoUrl,
      'complaint_count': complaintCount,
      'district_count': districtCount,
      'solution_rate': solutionRate,
    };
  }
}