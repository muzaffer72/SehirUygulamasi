class Category {
  final String id;
  final String name;
  final String? description;
  final String? iconName;
  final List<Category>? subCategories;
  
  Category({
    required this.id,
    required this.name,
    this.description,
    this.iconName,
    this.subCategories,
  });
  
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      iconName: json['icon_name'],
      subCategories: json['sub_categories'] != null
          ? (json['sub_categories'] as List)
              .map((subCategory) => Category.fromJson(subCategory))
              .toList()
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon_name': iconName,
      'sub_categories':
          subCategories?.map((subCategory) => subCategory.toJson()).toList(),
    };
  }
}