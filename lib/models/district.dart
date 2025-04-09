class District {
  final String id;
  final String name;
  final String cityId;
  final String? code;
  
  District({
    required this.id,
    required this.name,
    required this.cityId,
    this.code,
  });
  
  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json['id'],
      name: json['name'],
      cityId: json['city_id'],
      code: json['code'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'city_id': cityId,
      'code': code,
    };
  }
}