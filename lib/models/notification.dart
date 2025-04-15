enum NotificationType {
  system,
  post,
  like,
  comment,
  status,
  satisfaction,
  beforeAfter,
}

class Notification {
  final String id;
  final String title;
  final String message;
  final String userId;
  final NotificationType type;
  final String? relatedId;
  final bool isRead;
  final bool isArchived;
  final String? groupId;
  final DateTime createdAt;
  
  Notification({
    required this.id,
    required this.title,
    required this.message,
    required this.userId,
    required this.type,
    this.relatedId,
    this.isRead = false,
    this.isArchived = false,
    this.groupId,
    required this.createdAt,
  });
  
  factory Notification.fromJson(Map<String, dynamic> json) {
    NotificationType parseType(String type) {
      switch (type) {
        case 'system':
          return NotificationType.system;
        case 'post':
          return NotificationType.post;
        case 'like':
          return NotificationType.like;
        case 'comment':
          return NotificationType.comment;
        case 'status':
          return NotificationType.status;
        case 'satisfaction':
          return NotificationType.satisfaction;
        case 'beforeAfter':
          return NotificationType.beforeAfter;
        default:
          return NotificationType.system;
      }
    }
    
    return Notification(
      id: json['id'].toString(),
      title: json['title'],
      message: json['message'],
      userId: json['user_id'].toString(),
      type: parseType(json['type']),
      relatedId: json['related_id']?.toString(),
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      isArchived: json['is_archived'] == 1 || json['is_archived'] == true,
      groupId: json['group_id']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
  
  Map<String, dynamic> toJson() {
    String typeToString(NotificationType type) {
      switch (type) {
        case NotificationType.system:
          return 'system';
        case NotificationType.post:
          return 'post';
        case NotificationType.like:
          return 'like';
        case NotificationType.comment:
          return 'comment';
        case NotificationType.status:
          return 'status';
        case NotificationType.satisfaction:
          return 'satisfaction';
        case NotificationType.beforeAfter:
          return 'beforeAfter';
      }
    }
    
    return {
      'id': id,
      'title': title,
      'message': message,
      'user_id': userId,
      'type': typeToString(type),
      'related_id': relatedId,
      'is_read': isRead ? 1 : 0,
      'is_archived': isArchived ? 1 : 0,
      'group_id': groupId,
      'created_at': createdAt.toIso8601String(),
    };
  }
  
  Notification copyWith({
    String? id,
    String? title,
    String? message,
    String? userId,
    NotificationType? type,
    String? relatedId,
    bool? isRead,
    bool? isArchived,
    String? groupId,
    DateTime? createdAt,
  }) {
    return Notification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      relatedId: relatedId ?? this.relatedId,
      isRead: isRead ?? this.isRead,
      isArchived: isArchived ?? this.isArchived,
      groupId: groupId ?? this.groupId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}