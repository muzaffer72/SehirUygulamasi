class District {
  final String id;
  final String name;
  final String cityId;

  District({
    required this.id,
    required this.name,
    required this.cityId,
  });

  factory District.fromJson(Map<String, dynamic> json) {
    try {
      return District(
        id: json['id']?.toString() ?? '0',
        name: json['name']?.toString() ?? 'Bilinmeyen İlçe',
        cityId: json['city_id']?.toString() ?? '0',
      );
    } catch (e) {
      print('Error parsing District from JSON: $e - JSON: $json');
      // Hata durumunda varsayılan bir ilçe döndür
      return District(
        id: '0',
        name: 'Hata - İlçe Yüklenemedi',
        cityId: '0',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'city_id': cityId,
    };
  }
}