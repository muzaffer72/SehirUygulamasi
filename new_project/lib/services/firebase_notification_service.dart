import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// ŞikayetVar uygulaması için Firebase Cloud Messaging servisi.
/// 
/// Bu sınıf, Firebase bildirimlerini yönetir ve yerel bildirimleri göstermek için
/// flutter_local_notifications paketini kullanır.
class FirebaseNotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static FlutterLocalNotificationsPlugin? _localNotifications;
  
  static String? _fcmToken;
  static bool _isInitialized = false;
  
  /// Bildirimlerin etkin olup olmadığını kontrol eder
  static Future<bool> areNotificationsEnabled() async {
    if (Platform.isIOS) {
      final settings = await _messaging.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    } else if (Platform.isAndroid) {
      // Android'de izinler genellikle varsayılan olarak verilir
      // Yine de kontrol etmek isteyebilirsiniz
      return true;
    }
    return false;
  }
  
  /// Firebase bildirim servisini başlatır.
  /// 
  /// Gerekli izinleri ister, FCM token'ı alır, bildirim kanallarını oluşturur,
  /// ve bildirim dinleyicilerini ayarlar.
  static Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }
    
    try {
      // Firebase'i başlat (daha önce başlatılmadıysa)
      await Firebase.initializeApp();
      
      // Bildirim izinleri
      if (Platform.isIOS || Platform.isMacOS) {
        await _messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
      }
      
      // FCM token'ı al
      _fcmToken = await _messaging.getToken();
      debugPrint('FCM Token: $_fcmToken');
      
      // Token yenilenme dinleyicisi
      _messaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        debugPrint('FCM Token yenilendi: $newToken');
        // TODO: Yeni token'ı sunucuya kaydet
      });
      
      // Yerel bildirimleri ayarla
      await _setupLocalNotifications();
      
      // Bildirim dinleyicilerini ayarla
      _setupNotificationListeners();
      
      _isInitialized = true;
      debugPrint('Firebase bildirim servisi başlatıldı');
    } catch (e) {
      debugPrint('Firebase bildirim servisi başlatılamadı: $e');
    }
  }
  
  /// Flutter Local Notifications plugin'ini ayarlar.
  static Future<void> _setupLocalNotifications() async {
    _localNotifications = FlutterLocalNotificationsPlugin();
    
    // Bildirim kanallarını oluştur (sadece Android için)
    if (Platform.isAndroid) {
      const androidInitialize = AndroidInitializationSettings('ic_launcher');
      
      const initializationSettings = InitializationSettings(
        android: androidInitialize,
        iOS: DarwinInitializationSettings(),
      );
      
      await _localNotifications?.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          // TODO: Bildirime tıklama olayını işle
          debugPrint('Yerel bildirime tıklandı: ${response.payload}');
        },
      );
      
      // Android için yüksek öncelikli bildirim kanalı oluştur
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel',
        'Önemli Bildirimler',
        description: 'Bu kanal önemli bildirimler için kullanılır',
        importance: Importance.high,
      );
      
      await _localNotifications
          ?.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }
  
  /// Firebase bildirim dinleyicilerini ayarlar.
  static void _setupNotificationListeners() {
    // Uygulama arka planda veya kapalı iken gelen bildirimler için
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // Uygulama açıkken gelen bildirimler için
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _processMessage(message);
    });
    
    // Bildirime tıklandığında
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Bildirime tıklandı: ${message.notification?.title}');
      // TODO: Bildirime tıklama olayını işle (ekran açma vb.)
    });
  }
  
  /// Arka planda gelen Firebase mesajlarını işlemek için işleyici.
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // Uygulamanın arka planda veya kapalı olması durumunda çağrılır
    await Firebase.initializeApp();
    
    debugPrint('Arka planda bildirim alındı: ${message.notification?.title}');
    // Arka planda bildirimler otomatik olarak bildirim çekmecesine eklenir,
    // bu nedenle ek işlem yapmaya gerek yok
  }
  
  /// Firebase'den gelen bildirimi işler ve gerekirse yerel bildirim gösterir.
  static Future<void> _processMessage(RemoteMessage message) async {
    debugPrint('Ön planda bildirim alındı: ${message.notification?.title}');
    
    final notification = message.notification;
    final android = message.notification?.android;
    final data = message.data;
    
    if (notification != null && _localNotifications != null) {
      // Uygulama ön plandayken yerel bildirim göster
      await _localNotifications?.show(
        notification.hashCode,
        notification.title ?? data['title'] ?? 'Yeni Bildirim',
        notification.body ?? data['message'] ?? '',
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'Önemli Bildirimler',
            channelDescription: 'Bu kanal önemli bildirimler için kullanılır',
            importance: Importance.high,
            priority: Priority.high,
            icon: android?.smallIcon ?? 'ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data.toString(),
      );
    }
    
    // TODO: Bildirim servisine mesajı ilet
    // await NotificationService.handleFirebaseMessage(message.data);
  }
  
  /// Belirtilen konuya abone olur.
  /// 
  /// Abone olunan konuya gönderilen bildirimler kullanıcıya iletilir.
  static Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    debugPrint('Abone olundu: $topic');
  }
  
  /// Belirtilen konudan aboneliği kaldırır.
  static Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    debugPrint('Abonelik kaldırıldı: $topic');
  }
  
  /// Mevcut FCM token'ını döndürür.
  static String? get fcmToken => _fcmToken;
}