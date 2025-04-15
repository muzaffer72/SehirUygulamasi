import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/notification_model.dart';
import 'firebase_notification_service.dart';

/// ŞikayetVar uygulaması için bildirim yönetim servisi.
/// 
/// Bu sınıf, uygulama içindeki tüm bildirim işlemlerini yönetir.
/// Firebase bildirimlerini alır, işler, saklar ve uygulama içinde gösterilmesini sağlar.
class NotificationService {
  static const String _storageKey = 'sikayet_var_notifications';
  static final List<NotificationModel> _notifications = [];
  
  /// Yeni bildirim geldiğinde tetiklenen stream
  static final StreamController<NotificationModel> _notificationController = 
      StreamController<NotificationModel>.broadcast();
  
  /// Bildirim listesi değiştiğinde tetiklenen stream
  static final StreamController<List<NotificationModel>> _notificationsListController = 
      StreamController<List<NotificationModel>>.broadcast();
  
  /// Yeni bildirim geldiğinde dinlemek için stream
  static Stream<NotificationModel> get onNotification => _notificationController.stream;
  
  /// Bildirim listesi değiştiğinde dinlemek için stream
  static Stream<List<NotificationModel>> get notifications => _notificationsListController.stream;
  
  /// Okunmamış bildirim sayısı
  static int get unreadCount => _notifications.where((n) => !n.isRead).length;
  
  /// Bildirimleri başlatır.
  /// 
  /// Firebase bildirim servisini başlatır, saklanan bildirimleri yükler,
  /// ve bildirim dinleyicilerini ayarlar.
  static Future<void> initialize() async {
    // Saklanan bildirimleri yükle
    await _loadSavedNotifications();
    
    // Firebase bildirim servisini başlat
    await FirebaseNotificationService.initialize();
    
    // Bildirim streams'ini yayınla
    _notificationsListController.add(_notifications);
    
    // TODO: Bildirim işleyicilerini Firebase servisi ile bağla
    // Bu kısım, FCM'den gelen bildirimleri alıp _addNotification metoduna iletecek
    
    debugPrint('Bildirim servisi başlatıldı');
  }
  
  /// Yerel depodan kaydedilmiş bildirimleri yükler.
  static Future<void> _loadSavedNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? notificationsJson = prefs.getString(_storageKey);
      
      if (notificationsJson != null && notificationsJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(notificationsJson);
        
        _notifications.clear();
        _notifications.addAll(
          decoded.map((item) => NotificationModel.fromJson(item)).toList()
        );
        
        // Yeni bildirimleri tarihe göre sırala
        _sortNotifications();
        
        debugPrint('${_notifications.length} bildirim yüklendi');
      }
    } catch (e) {
      debugPrint('Bildirimler yüklenirken hata: $e');
    }
  }
  
  /// Bildirimleri tarihe göre sıralar (en yeniden en eskiye).
  static void _sortNotifications() {
    _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
  
  /// Bildirimleri yerel depoya kaydeder.
  static Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> notificationsMap = 
          _notifications.map((n) => n.toJson()).toList();
      
      await prefs.setString(_storageKey, jsonEncode(notificationsMap));
      debugPrint('Bildirimler kaydedildi');
    } catch (e) {
      debugPrint('Bildirimler kaydedilirken hata: $e');
    }
  }
  
  /// Yeni bildirim ekler.
  /// 
  /// Bildirim zaten mevcutsa, içeriğini günceller.
  static Future<void> addNotification(NotificationModel notification) async {
    // Aynı ID'ye sahip önceki bildirimi bul
    final existingIndex = _notifications.indexWhere((n) => n.id == notification.id);
    
    if (existingIndex >= 0) {
      // Var olan bildirimi güncelle
      _notifications[existingIndex] = notification;
    } else {
      // Yeni bildirim ekle
      _notifications.add(notification);
    }
    
    // Bildirimleri sırala ve kaydet
    _sortNotifications();
    await _saveNotifications();
    
    // Stream'leri güncelle
    _notificationController.add(notification);
    _notificationsListController.add(_notifications);
    
    debugPrint('Bildirim eklendi: ${notification.title}');
  }
  
  /// Bildirimi okundu olarak işaretler.
  static Future<void> markAsRead(int notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    
    if (index >= 0 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      
      // Değişiklikleri kaydet ve stream'leri güncelle
      await _saveNotifications();
      _notificationsListController.add(_notifications);
      
      debugPrint('Bildirim okundu olarak işaretlendi: $notificationId');
    }
  }
  
  /// Tüm bildirimleri okundu olarak işaretler.
  static Future<void> markAllAsRead() async {
    bool anyUnread = _notifications.any((n) => !n.isRead);
    
    if (anyUnread) {
      final updatedNotifications = <NotificationModel>[];
      
      for (var notification in _notifications) {
        if (!notification.isRead) {
          updatedNotifications.add(notification.copyWith(isRead: true));
        } else {
          updatedNotifications.add(notification);
        }
      }
      
      _notifications.clear();
      _notifications.addAll(updatedNotifications);
      
      // Değişiklikleri kaydet ve stream'leri güncelle
      await _saveNotifications();
      _notificationsListController.add(_notifications);
      
      debugPrint('Tüm bildirimler okundu olarak işaretlendi');
    }
  }
  
  /// Bildirimi siler.
  static Future<void> deleteNotification(int notificationId) async {
    final initialLength = _notifications.length;
    _notifications.removeWhere((n) => n.id == notificationId);
    
    if (_notifications.length < initialLength) {
      // Değişiklikleri kaydet ve stream'leri güncelle
      await _saveNotifications();
      _notificationsListController.add(_notifications);
      
      debugPrint('Bildirim silindi: $notificationId');
    }
  }
  
  /// Tüm bildirimleri siler.
  static Future<void> clearAllNotifications() async {
    if (_notifications.isNotEmpty) {
      _notifications.clear();
      
      // Değişiklikleri kaydet ve stream'leri güncelle
      await _saveNotifications();
      _notificationsListController.add(_notifications);
      
      debugPrint('Tüm bildirimler silindi');
    }
  }
  
  /// Firebase bildirimi aldığında çağrılacak işleyici.
  static Future<void> handleFirebaseMessage(Map<String, dynamic> message) async {
    debugPrint('Firebase bildirimi alındı: $message');
    
    try {
      // Firebase mesajından AppNotification oluştur
      final notification = _createNotificationFromFirebaseMessage(message);
      await addNotification(notification);
    } catch (e) {
      debugPrint('Firebase bildirimi işlenirken hata: $e');
    }
  }
  
  /// Firebase mesajından NotificationModel nesnesi oluşturur
  static NotificationModel _createNotificationFromFirebaseMessage(Map<String, dynamic> message) {
    final Map<String, dynamic> data = message['data'] ?? {};
    final Map<String, dynamic> notification = message['notification'] ?? {};
    
    final String title = notification['title'] ?? data['title'] ?? 'Yeni Bildirim';
    final String messageText = notification['body'] ?? data['message'] ?? '';
    final String type = data['type'] ?? 'general';
    
    // Ek veriler
    final Map<String, dynamic> extraData = {...data};
    // title ve message'ı extraData'dan çıkar
    extraData.remove('title');
    extraData.remove('message');
    extraData.remove('type');
    
    return NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      message: messageText,
      type: type,
      data: extraData.isNotEmpty ? extraData : null,
      createdAt: DateTime.now(),
      isRead: false,
    );
  }
  
  /// Belirli bir bildirim türüne abone olur.
  /// 
  /// Örneğin, "announcements", "city_X", "district_Y" gibi konulara abone olabilir.
  static Future<void> subscribeTopic(String topic) async {
    await FirebaseNotificationService.subscribeToTopic(topic);
    debugPrint('$topic konusuna abone olundu');
  }
  
  /// Belirli bir bildirim türünden aboneliği kaldırır.
  static Future<void> unsubscribeTopic(String topic) async {
    await FirebaseNotificationService.unsubscribeFromTopic(topic);
    debugPrint('$topic konusundan abonelik kaldırıldı');
  }
}