/// Veritabanındaki bildirim modeli.
/// 
/// Bu sınıf, API'den alınan bildirimleri temsil eder.
/// AppNotification sınıfı artık notification_model.dart dosyasında 
/// birleştirilmiştir. Bu dosya eski versiyondur.
class ApiNotification {
  final String id;
  final String userId;
  final String title;
  final String content;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final String? relatedPostId;
  final String? relatedCommentId;
  
  ApiNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.relatedPostId,
    this.relatedCommentId,
  });
  
  factory ApiNotification.fromJson(Map<String, dynamic> json) {
    return ApiNotification(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      title: json['title'],
      content: json['content'],
      type: json['type'],
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      relatedPostId: json['related_post_id']?.toString(),
      relatedCommentId: json['related_comment_id']?.toString(),
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
      'created_at': createdAt.toIso8601String(),
      'related_post_id': relatedPostId,
      'related_comment_id': relatedCommentId,
    };
  }
}