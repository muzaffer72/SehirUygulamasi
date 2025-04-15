import 'dart:convert';

class NotificationModel {
  final int id;
  final int? userId;
  final String title;
  final String message;
  final String type;
  final Map<String, dynamic>? data;
  final DateTime createdAt;
  final bool isRead;

  NotificationModel({
    required this.id,
    this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.data,
    required this.createdAt,
    this.isRead = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      message: json['message'],
      type: json['type'],
      data: json['data'] != null 
          ? json['data'] is String 
              ? jsonDecode(json['data']) 
              : json['data']
          : null,
      createdAt: DateTime.parse(json['created_at']),
      isRead: json['is_read'] == 1 || json['is_read'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type,
      'data': data != null ? jsonEncode(data) : null,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead ? 1 : 0,
    };
  }

  NotificationModel copyWith({
    int? id,
    int? userId,
    String? title,
    String? message,
    String? type,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}