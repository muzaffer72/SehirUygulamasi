import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/notification_model.dart';
import 'firebase_notification_service.dart';

/// Firebase arka plan mesaj işleyici
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Eğer gerekirse, mesaj verileriyle işlem yapılabilir.
  debugPrint("Arka planda mesaj alındı: ${message.messageId}");
}

/// Ana Firebase servisi - Firebase Core ve Messaging için merkezi kontrol noktası
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  bool _initialized = false;

  bool get isInitialized => _initialized;

  /// Firebase servislerini başlat
  Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      // Firebase'i başlat
      await Firebase.initializeApp();
      
      // Arka plan işleyiciyi ayarla
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      
      // Bildirim izinlerini al
      if (Platform.isIOS || Platform.isAndroid) {
        NotificationSettings settings = await _messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
        );
        
        debugPrint('Firebase bildirim izni durumu: ${settings.authorizationStatus}');
        
        // iOS için özel ayarlar
        if (Platform.isIOS) {
          await _messaging.setForegroundNotificationPresentationOptions(
            alert: true,
            badge: true,
            sound: true,
          );
        }
      }
      
      // FCM Token'ı al ve kaydedilmesini sağla
      _messaging.getToken().then((token) {
        if (token != null) {
          debugPrint('FCM Token: $token');
          FirebaseNotificationService.saveFcmToken(token);
        }
      });
      
      // Token yenilenme olayını dinle
      _messaging.onTokenRefresh.listen((token) {
        debugPrint('FCM Token yenilendi: $token');
        FirebaseNotificationService.saveFcmToken(token);
      });
      
      // Önplan mesaj olayını dinle
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      
      // Bildirime tıklayarak uygulamanın açılma olayını dinle
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
      
      // Uygulama başlangıçta bildirimle açıldıysa kontrol et
      _checkInitialMessage();
      
      _initialized = true;
      debugPrint('Firebase servisleri başarıyla başlatıldı');
    } catch (e) {
      debugPrint('Firebase servisleri başlatılırken hata: $e');
    }
  }

  /// Önplan mesaj olayı işleyici
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Önplanda mesaj alındı: ${message.messageId}');
    
    // Bildirim verilerini işle ve yerel bildirim göster
    if (message.notification != null) {
      // Bildirim modelini oluştur ve sakla
      _saveNotificationToLocal(message);
    }
  }

  /// Bildirime tıklayarak açılma işleyici
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('Bildirime tıklanarak uygulama açıldı: ${message.messageId}');
    
    // Bildirim verilerini işle ve ilgili sayfaya yönlendir
    _processNotificationNavigation(message);
  }

  /// Başlangıç mesajını kontrol et (uygulama kapalıyken bildirim gelirse)
  Future<void> _checkInitialMessage() async {
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    
    if (initialMessage != null) {
      debugPrint('Uygulama bildirimle başlatıldı: ${initialMessage.messageId}');
      _processNotificationNavigation(initialMessage);
    }
  }

  /// Bildirimi yerel depolamaya kaydet
  Future<void> _saveNotificationToLocal(RemoteMessage message) async {
    try {
      // Bildirim modelini oluştur
      final notification = NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch, // Geçici ID
        userId: 0, // Kullanıcı ID'si sonra alınacak
        title: message.notification?.title ?? 'Yeni Bildirim',
        content: message.notification?.body ?? '',
        type: message.data['type'] ?? 'system',
        notificationType: message.data['notification_type'] ?? 'system',
        scopeType: message.data['scope_type'] ?? 'user',
        scopeId: int.tryParse(message.data['scope_id'] ?? '0'),
        relatedId: int.tryParse(message.data['related_id'] ?? '0'),
        imageUrl: message.data['image_url'],
        actionUrl: message.data['action_url'],
        createdAt: DateTime.now(),
        isRead: false,
        createdBy: int.tryParse(message.data['created_by'] ?? '0'),
        senderName: message.data['sender_name'],
        senderUsername: message.data['sender_username'],
        senderAvatar: message.data['sender_avatar'],
      );
      
      // Bildirimi yerel depolamaya kaydet
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getStringList('local_notifications') ?? [];
      
      notificationsJson.add(notification.toJson().toString());
      
      await prefs.setStringList('local_notifications', notificationsJson);
    } catch (e) {
      debugPrint('Bildirim yerel depolamaya kaydedilirken hata: $e');
    }
  }

  /// Bildirim navigasyonunu işle
  void _processNotificationNavigation(RemoteMessage message) {
    // Bildirime tıklanınca nereye gidileceğini belirle
    final actionUrl = message.data['action_url'];
    final notificationType = message.data['notification_type'] ?? 'system';
    final relatedId = int.tryParse(message.data['related_id'] ?? '0');
    
    // NavigationService veya GlobalKey ile navigator kullanarak yönlendirme yapılabilir
    // Bu kısım uygulama gereksinimine göre geliştirilecek
    debugPrint('Bildirime tıklanınca açılacak sayfa: $actionUrl');
  }
}