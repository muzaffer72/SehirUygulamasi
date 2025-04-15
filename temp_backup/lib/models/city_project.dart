class CityProject {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;
  final String? status; // 'tamamlandı', 'devam ediyor', 'planlama', 'ertelendi'
  final String? startDate;
  final String? endDate;
  final String? budget;

  CityProject({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.status,
    this.startDate,
    this.endDate,
    this.budget,
  });

  factory CityProject.fromJson(Map<String, dynamic> json) {
    return CityProject(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      status: json['status'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      budget: json['budget'],
    );
  }
}