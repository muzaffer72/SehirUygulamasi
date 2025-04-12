class CityStat {
  final int id;
  final String name;
  final String? value;
  final String type; // 'demografi', 'ekonomi', 'egitim', 'altyapi'

  CityStat({
    required this.id,
    required this.name,
    this.value,
    required this.type,
  });

  factory CityStat.fromJson(Map<String, dynamic> json) {
    return CityStat(
      id: json['id'],
      name: json['name'],
      value: json['value'],
      type: json['type'],
    );
  }
}