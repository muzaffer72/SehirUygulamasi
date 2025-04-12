class CityService {
  final int id;
  final String name;
  final String? description;
  final String? type; // 'active' veya 'inactive'
  final String? category;

  CityService({
    required this.id,
    required this.name,
    this.description,
    this.type,
    this.category,
  });

  factory CityService.fromJson(Map<String, dynamic> json) {
    return CityService(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: json['type'],
      category: json['category'],
    );
  }
}