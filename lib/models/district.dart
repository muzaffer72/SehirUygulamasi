class District {
  final String id;
  final String name;
  final String cityId;
  final String? logoUrl;
  final int population;
  final String? mayor;
  final String? politicalParty;
  final String? politicalPartyLogoUrl;

  District({
    required this.id,
    required this.name,
    required this.cityId,
    this.logoUrl,
    required this.population,
    this.mayor,
    this.politicalParty,
    this.politicalPartyLogoUrl,
  });

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json['id'],
      name: json['name'],
      cityId: json['city_id'],
      logoUrl: json['logo_url'],
      population: json['population'],
      mayor: json['mayor'],
      politicalParty: json['political_party'],
      politicalPartyLogoUrl: json['political_party_logo_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'city_id': cityId,
      'logo_url': logoUrl,
      'population': population,
      'mayor': mayor,
      'political_party': politicalParty,
      'political_party_logo_url': politicalPartyLogoUrl,
    };
  }
}