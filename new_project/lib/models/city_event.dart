class CityEvent {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;
  final String? date;
  final String? location;

  CityEvent({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.date,
    this.location,
  });

  factory CityEvent.fromJson(Map<String, dynamic> json) {
    return CityEvent(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      date: json['date'],
      location: json['location'],
    );
  }
}