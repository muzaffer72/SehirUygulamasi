class Notification {
  final int id;
  final int userId;
  final String title;
  final String content;
  final String type;
  final bool isRead;
  final int? sourceId;
  final String? sourceType;
  final String? data;
  final bool isArchived;
  final String? groupId;
  final DateTime createdAt;

  Notification({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.type,
    required this.isRead,
    this.sourceId,
    this.sourceType,
    this.data,
    required this.isArchived,
    this.groupId,
    required this.createdAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      content: json['content'],
      type: json['type'],
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      sourceId: json['source_id'],
      sourceType: json['source_type'],
      data: json['data'],
      isArchived: json['is_archived'] == 1 || json['is_archived'] == true,
      groupId: json['group_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'content': content,
      'type': type,
      'is_read': isRead ? 1 : 0,
      'source_id': sourceId,
      'source_type': sourceType,
      'data': data,
      'is_archived': isArchived ? 1 : 0,
      'group_id': groupId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}