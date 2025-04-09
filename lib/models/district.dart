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
    return District(
      id: json['id'].toString(),
      name: json['name'],
      cityId: json['city_id'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'city_id': cityId,
    };
  }
}