class NotificationModel {
  final int id;
  final int userId;
  final String title;
  final String content;
  final String type;
  final String notificationType;
  final String scopeType;
  final int? scopeId;
  final int? relatedId;
  final String? imageUrl;
  final String? actionUrl;
  final DateTime createdAt;
  bool isRead;
  final int? createdBy;
  final String? senderName;
  final String? senderUsername;
  final String? senderAvatar;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.type,
    required this.notificationType,
    required this.scopeType,
    this.scopeId,
    this.relatedId,
    this.imageUrl,
    this.actionUrl,
    required this.createdAt,
    required this.isRead,
    this.createdBy,
    this.senderName,
    this.senderUsername,
    this.senderAvatar,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      content: json['content'],
      type: json['type'],
      notificationType: json['notification_type'] ?? 'interaction',
      scopeType: json['scope_type'] ?? 'user',
      scopeId: json['scope_id'],
      relatedId: json['related_id'],
      imageUrl: json['image_url'],
      actionUrl: json['action_url'],
      createdAt: DateTime.parse(json['created_at']),
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      createdBy: json['created_by'],
      senderName: json['sender_name'],
      senderUsername: json['sender_username'],
      senderAvatar: json['sender_avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'content': content,
      'type': type,
      'notification_type': notificationType,
      'scope_type': scopeType,
      'scope_id': scopeId,
      'related_id': relatedId,
      'image_url': imageUrl,
      'action_url': actionUrl,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
      'created_by': createdBy,
      'sender_name': senderName,
      'sender_username': senderUsername,
      'sender_avatar': senderAvatar,
    };
  }
}