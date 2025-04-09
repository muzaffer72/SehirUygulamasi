import 'package:sikayet_var/models/district.dart';

class City {
  final String id;
  final String name;
  final String? code;
  final List<District>? districts;
  
  City({
    required this.id,
    required this.name,
    this.code,
    this.districts,
  });
  
  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      districts: json['districts'] != null
          ? (json['districts'] as List)
              .map((district) => District.fromJson(district))
              .toList()
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'districts': districts?.map((district) => district.toJson()).toList(),
    };
  }
}