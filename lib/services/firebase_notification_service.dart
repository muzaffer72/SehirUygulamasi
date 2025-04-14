import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'firebase_service.dart';

/// Firebase Cloud Messaging ile bildirim altyapısını yöneten sınıf.
/// 
/// Bu sınıf, FCM (Firebase Cloud Messaging) bildirimleri için gerekli yapılandırmaları yapar,
/// bildirim izinlerini yönetir ve gelen bildirimleri işler.
class FirebaseNotificationService {
  /// Firebase Messaging instance
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  
  /// Flutter yerel bildirim eklentisi instance
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = 
    FlutterLocalNotificationsPlugin();
  
  /// Android için bildirim kanalı ID
  static const String _androidChannelId = 'sikayet_var_channel';
  
  /// Android için bildirim kanalı adı
  static const String _androidChannelName = 'ŞikayetVar Bildirimleri';
  
  /// Android için bildirim kanalı açıklaması
  static const String _androidChannelDescription = 'ŞikayetVar uygulaması bildirim kanalı';

  /// Bildirim servisini başlatır ve gerekli yapılandırmaları yapar.
  /// 
  /// Uygulama başlatıldığında, `main.dart` dosyasından çağrılmalıdır.
  static Future<void> initialize() async {
    if (!FirebaseService.isFirebaseAvailable()) {
      debugPrint('Firebase kullanılamıyor, bildirim servisi başlatılamadı');
      return;
    }
    
    // Bildirim izinlerini al
    await _requestPermissions();
    
    // Yerel bildirimleri yapılandır
    await _setupLocalNotifications();
    
    // Ön plan bildirimleri için yapılandırma
    await _setupForegroundNotifications();
    
    // Bildirim tıklama işleyicisini ayarla
    _setupNotificationHandlers();
    
    // FCM token değişikliği takibi
    _setupTokenRefresh();
    
    debugPrint('Firebase bildirim servisi başarıyla başlatıldı');
  }
  
  /// Kullanıcı bildirim izinlerini ister.
  static Future<void> _requestPermissions() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    
    debugPrint('Bildirim izin durumu: ${settings.authorizationStatus}');
  }
  
  /// Flutter yerel bildirim eklentisini yapılandırır.
  static Future<void> _setupLocalNotifications() async {
    // Android için başlangıç ayarları
    const AndroidInitializationSettings androidInitializationSettings = 
      AndroidInitializationSettings('@drawable/ic_notification');
    
    // iOS için başlangıç ayarları
    const DarwinInitializationSettings iosInitializationSettings = 
      DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
    
    // Tüm platformlar için başlangıç ayarları
    const InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );
    
    // Eklentiyi yapılandır
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    
    // Android için bildirim kanalı oluştur
    if (Platform.isAndroid) {
      await _createAndroidNotificationChannel();
    }
  }
  
  /// Android için bildirim kanalı oluşturur.
  static Future<void> _createAndroidNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _androidChannelId,
      _androidChannelName,
      description: _androidChannelDescription,
      importance: Importance.high,
    );
    
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }
  
  /// Ön planda (uygulama açıkken) gösterilecek bildirimler için yapılandırma.
  static Future<void> _setupForegroundNotifications() async {
    // Uygulama açıkken gelen bildirimleri göster
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    
    // Ön planda gelen bildirimleri işle
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  }
  
  /// FCM token değişikliklerini takip eder ve yeni tokeni sunucuya gönderir.
  static void _setupTokenRefresh() {
    FirebaseMessaging.instance.onTokenRefresh.listen((String token) {
      debugPrint('FCM token yenilendi: $token');
      _sendTokenToServer(token);
    });
    
    // İlk token'ı al ve sunucuya gönder
    _firebaseMessaging.getToken().then((String? token) {
      if (token != null) {
        debugPrint('FCM token: $token');
        _sendTokenToServer(token);
      }
    });
  }
  
  /// FCM token'ı backend sunucusuna gönderir.
  static Future<void> _sendTokenToServer(String token) async {
    // TODO: Tokeni API'ye göndererek kullanıcı ile ilişkilendir
    // API çağrısı burada yapılacak
    debugPrint('Token sunucuya gönderildi: $token');
  }
  
  /// Ön planda (uygulama açıkken) gelen bildirimleri işler.
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Ön planda bildirim alındı: ${message.notification?.title}');
    
    // Bildirim içeriği kontrolü
    if (message.notification != null && 
        message.notification!.title != null && 
        message.notification!.body != null) {
      
      await _showLocalNotification(
        title: message.notification!.title!,
        body: message.notification!.body!,
        payload: jsonEncode(message.data),
      );
    }
  }
  
  /// Yerel bildirim gösterir.
  static Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _androidChannelId,
      _androidChannelName,
      channelDescription: _androidChannelDescription,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@drawable/ic_notification',
      color: const Color(0xFF1976D2),
    );
    
    final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
    
    await _flutterLocalNotificationsPlugin.show(
      0, // Bildirim ID
      title,
      body,
      platformDetails,
      payload: payload,
    );
  }
  
  /// Bildirim tıklandığında tetiklenen işleyici.
  static void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final Map<String, dynamic> data = jsonDecode(response.payload!);
        debugPrint('Bildirim tıklandı, veri: $data');
        
        // TODO: Bildirim tıklama işlemleri (ör. ilgili ekrana yönlendirme)
        
      } catch (e) {
        debugPrint('Bildirim verisi ayrıştırılırken hata: $e');
      }
    }
  }
  
  /// Bildirim işleyicilerini ayarlar.
  static void _setupNotificationHandlers() {
    // Arkaplanda iken bildirime tıklandığında
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Arkaplanda bildirim tıklandı: ${message.notification?.title}');
      
      // TODO: Tıklanan bildirime göre ilgili sayfaya yönlendirme
    });
    
    // Uygulama tamamen kapalıyken bildirime tıklanarak açıldığında
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint('Uygulama bildirimden açıldı: ${message.notification?.title}');
        
        // TODO: Tıklanan bildirime göre ilgili sayfaya yönlendirme
      }
    });
  }
  
  /// Belirli bir konuya abone olur.
  static Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    debugPrint('$topic konusuna abone olundu');
  }
  
  /// Belirli bir konudan aboneliği kaldırır.
  static Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    debugPrint('$topic konusundan abonelik kaldırıldı');
  }
}