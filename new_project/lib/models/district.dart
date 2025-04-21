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
      // İlçe yanıtını detaylı loglayalım
      print('District JSON içeriği: $json');
      
      // ID değerini kontrol et
      final id = json['id'] != null 
          ? json['id'].toString() 
          : (json['district_id'] != null ? json['district_id'].toString() : '0');
          
      // İsim değerini kontrol et
      final name = json['name'] != null 
          ? json['name'].toString() 
          : (json['district_name'] != null ? json['district_name'].toString() : 'Bilinmeyen İlçe');
          
      // City ID değerini kontrol et
      final cityId = json['city_id'] != null 
          ? json['city_id'].toString() 
          : '0';
      
      print('District parsed - ID: $id, Name: $name, CityID: $cityId');
      
      return District(
        id: id,
        name: name,
        cityId: cityId,
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