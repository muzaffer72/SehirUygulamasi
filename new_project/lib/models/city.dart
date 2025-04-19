class City {
  final String id;
  final String name;
  final String? description;
  final String? contactPhone;
  final String? contactEmail;
  final String? logoUrl;

  City({
    required this.id,
    required this.name,
    this.description,
    this.contactPhone,
    this.contactEmail,
    this.logoUrl,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'].toString(),
      name: json['name'],
      description: json['description'],
      contactPhone: json['contact_phone'] ?? json['phone'],
      contactEmail: json['contact_email'] ?? json['email'],
      logoUrl: json['logo_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'contact_phone': contactPhone,
      'contact_email': contactEmail,
      'logo_url': logoUrl,
    };
  }
}