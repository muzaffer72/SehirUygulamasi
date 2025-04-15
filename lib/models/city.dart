class City {
  final String id;
  final String name;
  final String? description;
  final String? logoUrl;
  final String? info;
  final String? politicalParty;
  final String? politicalPartyLogoUrl;
  final String? website;
  final String? contactPhone;
  final String? contactEmail;

  City({
    required this.id,
    required this.name,
    this.description,
    this.logoUrl,
    this.info,
    this.politicalParty,
    this.politicalPartyLogoUrl,
    this.website,
    this.contactPhone,
    this.contactEmail,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      logoUrl: json['logo_url'],
      info: json['info'],
      politicalParty: json['political_party'],
      politicalPartyLogoUrl: json['political_party_logo_url'],
      website: json['website'],
      contactPhone: json['contact_phone'] ?? json['phone'],
      contactEmail: json['contact_email'] ?? json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'logo_url': logoUrl,
      'info': info,
      'political_party': politicalParty,
      'political_party_logo_url': politicalPartyLogoUrl,
      'website': website,
      'contact_phone': contactPhone,
      'contact_email': contactEmail,
    };
  }
}