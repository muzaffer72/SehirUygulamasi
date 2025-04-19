class CityService {
  final int id;
  final String name;
  final String? description;
  final String? type;  // active, passive, planned
  final String? category;
  final String? iconUrl;

  CityService({
    required this.id,
    required this.name,
    this.description,
    this.type,
    this.category,
    this.iconUrl,
  });

  factory CityService.fromJson(Map<String, dynamic> json) {
    return CityService(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      type: json['type'],
      category: json['category'],
      iconUrl: json['icon_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'category': category,
      'icon_url': iconUrl,
    };
  }
}