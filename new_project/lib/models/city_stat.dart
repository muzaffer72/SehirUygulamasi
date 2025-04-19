class CityStat {
  final int id;
  final String title;
  final String value;
  final String? type;
  final String? unit;
  final String? icon;
  final int? order;

  CityStat({
    required this.id,
    required this.title,
    required this.value,
    this.type,
    this.unit,
    this.icon,
    this.order,
  });

  factory CityStat.fromJson(Map<String, dynamic> json) {
    return CityStat(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      value: json['value']?.toString() ?? '0',
      type: json['type'],
      unit: json['unit'],
      icon: json['icon'],
      order: json['order'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'value': value,
      'type': type,
      'unit': unit,
      'icon': icon,
      'order': order,
    };
  }
}