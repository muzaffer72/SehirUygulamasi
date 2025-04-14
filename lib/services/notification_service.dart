import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/user.dart';
import '../utils/storage_helper.dart';
import '../utils/api_helper.dart';

class NotificationService {
  /// Bildirim türleri
  static const String TYPE_LIKE = 'like';
  static const String TYPE_COMMENT = 'comment';
  static const String TYPE_REPLY = 'reply';
  static const String TYPE_MENTION = 'mention';
  static const String TYPE_SYSTEM = 'system';
  static const String TYPE_STATUS_UPDATE = 'status_update';
  static const String TYPE_AWARD = 'award';

  /// Kullanıcıya otomatik bildirim gönderir (beğeni, yorum vb.)
  static Future<bool> sendInteractionNotification({
    required int userId,
    required String type,
    required String title,
    required String content,
    String? imageUrl,
    String? actionUrl,
    int? relatedId,
  }) async {
    try {
      // API endpoint
      final url = '${AppConfig.apiBaseUrl}/notifications/create';
      
      // Bildirim verileri
      final Map<String, dynamic> data = {
        'user_id': userId,
        'type': type,
        'title': title,
        'content': content,
        'notification_type': 'interaction',
        'scope_type': 'user',
        'is_sent': true,
      };
      
      // İsteğe bağlı alanlar
      if (imageUrl != null) data['image_url'] = imageUrl;
      if (actionUrl != null) data['action_url'] = actionUrl;
      if (relatedId != null) data['related_id'] = relatedId;
      
      // Kimlik doğrulama token'ı
      final token = await StorageHelper.getToken();
      
      // API'ye istek gönder
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Bildirim gönderirken hata: $e');
      return false;
    }
  }
  
  /// Beğeni bildirimi gönderir
  static Future<bool> sendLikeNotification({
    required int receiverId,
    required String contentType, // post, comment, vb.
    required int contentId,
    required String senderName,
  }) async {
    final title = 'Yeni Beğeni';
    final content = '$senderName, ${contentType == 'post' ? 'gönderinizi' : 'yorumunuzu'} beğendi';
    
    return sendInteractionNotification(
      userId: receiverId,
      type: TYPE_LIKE,
      title: title,
      content: content,
      relatedId: contentId,
      actionUrl: '/detail/$contentId',
    );
  }
  
  /// Yorum bildirimi gönderir
  static Future<bool> sendCommentNotification({
    required int receiverId,
    required int postId,
    required int commentId,
    required String senderName,
    required String commentPreview,
  }) async {
    final title = 'Yeni Yorum';
    final content = '$senderName: $commentPreview';
    
    return sendInteractionNotification(
      userId: receiverId,
      type: TYPE_COMMENT,
      title: title,
      content: content,
      relatedId: postId,
      actionUrl: '/detail/$postId',
    );
  }
  
  /// Yanıt bildirimi gönderir
  static Future<bool> sendReplyNotification({
    required int receiverId,
    required int postId,
    required int commentId,
    required String senderName,
    required String replyPreview,
  }) async {
    final title = 'Yeni Yanıt';
    final content = '$senderName: $replyPreview';
    
    return sendInteractionNotification(
      userId: receiverId,
      type: TYPE_REPLY,
      title: title,
      content: content,
      relatedId: commentId,
      actionUrl: '/detail/$postId',
    );
  }
  
  /// Kullanıcı bahsetme bildirimi gönderir
  static Future<bool> sendMentionNotification({
    required int receiverId,
    required int postId,
    required String senderName,
    required String contentPreview,
  }) async {
    final title = 'Sizden Bahsedildi';
    final content = '$senderName sizi bir gönderide etiketledi: $contentPreview';
    
    return sendInteractionNotification(
      userId: receiverId,
      type: TYPE_MENTION,
      title: title,
      content: content,
      relatedId: postId,
      actionUrl: '/detail/$postId',
    );
  }
  
  /// Durum güncellemesi bildirimi gönderir
  static Future<bool> sendStatusUpdateNotification({
    required int receiverId,
    required int postId,
    required String title,
    required String content,
  }) async {
    return sendInteractionNotification(
      userId: receiverId,
      type: TYPE_STATUS_UPDATE,
      title: title,
      content: content,
      relatedId: postId,
      actionUrl: '/detail/$postId',
    );
  }
  
  /// Kullanıcının okunmamış bildirim sayısını getirir
  static Future<int> getUnreadNotificationCount() async {
    try {
      final response = await ApiHelper.get('/notifications/unread/count');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['count'] ?? 0;
      }
      return 0;
    } catch (e) {
      print('Okunmamış bildirim sayısı alınırken hata: $e');
      return 0;
    }
  }
  
  /// Kullanıcının bildirimlerini getirir
  static Future<List<dynamic>> getNotifications({int page = 1, int limit = 20}) async {
    try {
      final response = await ApiHelper.get('/notifications?page=$page&limit=$limit');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['notifications'] ?? [];
      }
      return [];
    } catch (e) {
      print('Bildirimler alınırken hata: $e');
      return [];
    }
  }
  
  /// Bildirimi okundu olarak işaretler
  static Future<bool> markAsRead(int notificationId) async {
    try {
      final response = await ApiHelper.post('/notifications/read/$notificationId', {});
      return response.statusCode == 200;
    } catch (e) {
      print('Bildirim okundu olarak işaretlenirken hata: $e');
      return false;
    }
  }
  
  /// Tüm bildirimleri okundu olarak işaretler
  static Future<bool> markAllAsRead() async {
    try {
      final response = await ApiHelper.post('/notifications/read-all', {});
      return response.statusCode == 200;
    } catch (e) {
      print('Tüm bildirimler okundu olarak işaretlenirken hata: $e');
      return false;
    }
  }
}