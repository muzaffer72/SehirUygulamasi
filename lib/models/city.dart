class City {
  final String id;
  final String name;
  final String? logoUrl;
  final int districtCount;
  final int population;
  final String? mayor;
  final String? politicalParty;
  final String? politicalPartyLogoUrl;

  City({
    required this.id,
    required this.name,
    this.logoUrl,
    required this.districtCount,
    required this.population,
    this.mayor,
    this.politicalParty,
    this.politicalPartyLogoUrl,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'],
      name: json['name'],
      logoUrl: json['logo_url'],
      districtCount: json['district_count'],
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
      'logo_url': logoUrl,
      'district_count': districtCount,
      'population': population,
      'mayor': mayor,
      'political_party': politicalParty,
      'political_party_logo_url': politicalPartyLogoUrl,
    };
  }
}