/// Uygulama içinde kullanılacak bildirim modeli.
/// 
/// Firebase'den gelen bildirim verisini uygulamada kullanılacak forma dönüştürür.
class NotificationModel {
  /// Bildirim ID'si
  final String id;
  
  /// Bildirim başlığı
  final String title;
  
  /// Bildirim mesajı
  final String message;
  
  /// Bildirim verileri (JSON olarak)
  final Map<String, dynamic>? data;
  
  /// Bildirim tarihi
  final DateTime timestamp;
  
  /// Bildirim okundu mu?
  bool isRead;
  
  /// Bildirim tipi (örn. "complaint", "announcement", "message", vb.)
  final String type;
  
  /// Bildirimle ilgili hedef sayfa
  final String? targetRoute;
  
  /// Bildirimle ilgili hedef ID (ör. şikayet ID'si)
  final String? targetId;
  
  /// Bildirim oluşturucu
  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    this.data,
    required this.timestamp,
    this.isRead = false,
    required this.type,
    this.targetRoute,
    this.targetId,
  });
  
  /// Firebase bildirim verisinden NotificationModel oluşturur.
  factory NotificationModel.fromFirebaseMessage(Map<String, dynamic> message) {
    final data = message['data'] as Map<String, dynamic>? ?? {};
    
    return NotificationModel(
      id: data['notification_id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message['notification']?['title'] ?? data['title'] ?? 'Bildirim',
      message: message['notification']?['body'] ?? data['message'] ?? '',
      data: data,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        int.tryParse(data['timestamp'] ?? '') ?? DateTime.now().millisecondsSinceEpoch
      ),
      type: data['type'] ?? 'general',
      targetRoute: data['target_route'],
      targetId: data['target_id'],
    );
  }
  
  /// Map formatından NotificationModel oluşturur.
  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      data: map['data'],
      timestamp: map['timestamp'] is DateTime 
        ? map['timestamp'] 
        : DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      isRead: map['isRead'] ?? false,
      type: map['type'] ?? 'general',
      targetRoute: map['targetRoute'],
      targetId: map['targetId'],
    );
  }
  
  /// NotificationModel'i Map formatına dönüştürür.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'data': data,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isRead': isRead,
      'type': type,
      'targetRoute': targetRoute,
      'targetId': targetId,
    };
  }
}