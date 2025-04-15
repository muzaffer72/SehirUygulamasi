import 'dart:convert';

class BeforeAfterRecord {
  final int id;
  final int postId;
  final String beforeImage;
  final String afterImage;
  final String? beforeDescription;
  final String? afterDescription;
  final DateTime createdAt;
  final DateTime? updatedAt;

  BeforeAfterRecord({
    required this.id,
    required this.postId,
    required this.beforeImage,
    required this.afterImage,
    this.beforeDescription,
    this.afterDescription,
    required this.createdAt,
    this.updatedAt,
  });

  factory BeforeAfterRecord.fromJson(Map<String, dynamic> json) {
    return BeforeAfterRecord(
      id: json['id'],
      postId: json['post_id'],
      beforeImage: json['before_image'],
      afterImage: json['after_image'],
      beforeDescription: json['before_description'],
      afterDescription: json['after_description'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'before_image': beforeImage,
      'after_image': afterImage,
      'before_description': beforeDescription,
      'after_description': afterDescription,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  static List<BeforeAfterRecord> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => BeforeAfterRecord.fromJson(json)).toList();
  }
}