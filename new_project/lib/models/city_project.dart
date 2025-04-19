class CityProject {
  final int id;
  final String name;
  final String? description;
  final String? status;  // planned, in-progress, completed
  final double? budget;
  final String? startDate;
  final String? endDate;
  final String? imageUrl;
  final String? location;
  final double? completionRate;
  final String? projectManager;

  CityProject({
    required this.id,
    required this.name,
    this.description,
    this.status,
    this.budget,
    this.startDate,
    this.endDate,
    this.imageUrl,
    this.location,
    this.completionRate,
    this.projectManager,
  });

  factory CityProject.fromJson(Map<String, dynamic> json) {
    return CityProject(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      status: json['status'],
      budget: json['budget'] != null ? double.tryParse(json['budget'].toString()) : null,
      startDate: json['start_date'],
      endDate: json['end_date'],
      imageUrl: json['image_url'],
      location: json['location'],
      completionRate: json['completion_rate'] != null ? double.tryParse(json['completion_rate'].toString()) : null,
      projectManager: json['project_manager'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': status,
      'budget': budget,
      'start_date': startDate,
      'end_date': endDate,
      'image_url': imageUrl,
      'location': location,
      'completion_rate': completionRate,
      'project_manager': projectManager,
    };
  }
}