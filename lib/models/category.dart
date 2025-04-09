class Category {
  final String id;
  final String name;
  final String? iconName;

  Category({
    required this.id,
    required this.name,
    this.iconName,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'].toString(),
      name: json['name'],
      iconName: json['icon_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon_name': iconName,
    };
  }
}