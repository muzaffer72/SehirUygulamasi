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
    try {
      // API'den gelen tüm olası alan isimlerini kontrol et ve güvenli şekilde dönüştür
      return City(
        id: json['id']?.toString() ?? '0',
        name: json['name']?.toString() ?? 'Bilinmeyen Şehir',
        description: json['description']?.toString(),
        contactPhone: (json['contact_phone'] ?? json['phone'])?.toString(),
        contactEmail: (json['contact_email'] ?? json['email'])?.toString(),
        logoUrl: json['logo_url']?.toString(),
        // Yeni eklenen alanlar için güvenli dönüşüm
        complaintCount: _parseIntSafely(json['complaint_count'] ?? json['total_complaints']),
        districtCount: _parseIntSafely(json['district_count']),
        solutionRate: _parseDoubleSafely(json['solution_rate'] ?? json['problem_solving_rate']),
      );
    } catch (e) {
      print('Error parsing City from JSON: $e - JSON: $json');
      // Hata durumunda varsayılan bir şehir döndür
      return City(
        id: '0',
        name: 'Hata - Şehir Yüklenemedi',
      );
    }
  }
  
  // Int değerlerini güvenli şekilde ayrıştırma
  static int? _parseIntSafely(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
  
  // Double değerlerini güvenli şekilde ayrıştırma
  static double? _parseDoubleSafely(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
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