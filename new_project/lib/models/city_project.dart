class CityProject {
  final int id;
  final String name;
  final String description;
  final String type;
  final String? status;
  final String? statusDisplay;
  final String? startDate;
  final String? endDate;
  final double? budget;
  final String? imageUrl;

  CityProject({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    this.status,
    this.statusDisplay,
    this.startDate,
    this.endDate,
    this.budget,
    this.imageUrl,
  });

  factory CityProject.fromJson(Map<String, dynamic> json) {
    return CityProject(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? 'other',
      status: json['status'],
      statusDisplay: json['status_display'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      budget: json['budget']?.toDouble(),
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'status': status,
      'status_display': statusDisplay,
      'start_date': startDate,
      'end_date': endDate,
      'budget': budget,
      'image_url': imageUrl,
    };
  }
}