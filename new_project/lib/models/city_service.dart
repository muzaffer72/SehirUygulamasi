class CityService {
  final int id;
  final String name;
  final String description;
  final String type;
  final String category;

  CityService({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.category,
  });

  factory CityService.fromJson(Map<String, dynamic> json) {
    return CityService(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? 'active',
      category: json['category'] ?? 'genel',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'category': category,
    };
  }
}