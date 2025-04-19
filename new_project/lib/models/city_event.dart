class CityEvent {
  final int id;
  final String name;
  final String description;
  final String? date;
  final String? location;
  final String? imageUrl;

  CityEvent({
    required this.id,
    required this.name,
    required this.description,
    this.date,
    this.location,
    this.imageUrl,
  });

  factory CityEvent.fromJson(Map<String, dynamic> json) {
    return CityEvent(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      date: json['date'],
      location: json['location'],
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'date': date,
      'location': location,
      'image_url': imageUrl,
    };
  }
}