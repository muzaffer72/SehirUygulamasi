class Category {
  final String id;
  final String name;
  final String? description;
  final String? iconName;
  final List<SubCategory>? subCategories;

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
              .map((e) => SubCategory.fromJson(e))
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
      'sub_categories': subCategories?.map((e) => e.toJson()).toList(),
    };
  }
}

class SubCategory {
  final String id;
  final String name;
  final String categoryId;
  final String? description;
  final String? iconName;

  SubCategory({
    required this.id,
    required this.name,
    required this.categoryId,
    this.description,
    this.iconName,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['id'],
      name: json['name'],
      categoryId: json['category_id'],
      description: json['description'],
      iconName: json['icon_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category_id': categoryId,
      'description': description,
      'icon_name': iconName,
    };
  }
}