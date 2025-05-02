import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Bu sınıf, flutter_local_notifications paketini kullanarak
/// yerel bildirimler göstermek için kullanılır.
/// 
/// API 33 ve sonrası ile uyumlu çalışması için optimize edilmiştir
/// ve eski sürümlerle geriye dönük uyumluluğu destekler.
class LocalNotificationsHelper {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  
  static final AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'Yüksek Öncelikli Bildirimler',
    description: 'Bu kanal önemli bildirimleri göstermek için kullanılır',
    importance: Importance.high,
  );

  /// Bildirim servisi başlatılıyor
  static Future<void> init() async {
    try {
      // Android için bildirim ayarları
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS için bildirim ayarları
      final DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
      );

      // Bildirim servisi başlatma
      final InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
      );

      // Android bildirim kanalını oluştur
      if (Platform.isAndroid) {
        await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(_channel);
      }

      debugPrint('Yerel bildirim servisi başlatıldı');
    } catch (e) {
      debugPrint('Yerel bildirim servisi başlatılırken hata: $e');
    }
  }

  /// Normal bildirim göster
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      await _flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: payload,
      );
      debugPrint('Bildirim gösterildi: $title');
    } catch (e) {
      debugPrint('Bildirim gösterilirken hata: $e');
    }
  }

  /// Resimli bildirim göster
  static Future<void> showBigPictureNotification({
    required int id,
    required String title,
    required String body,
    required String imagePath,
    String? payload,
  }) async {
    try {
      final BigPictureStyleInformation bigPictureStyleInformation =
          BigPictureStyleInformation(
        FilePathAndroidBitmap(imagePath),
        contentTitle: title,
        summaryText: body,
        hideExpandedLargeIcon: true,
      );

      final AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        channelDescription: _channel.description,
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        styleInformation: bigPictureStyleInformation,
        icon: '@mipmap/ic_launcher',
      );

      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: const DarwinNotificationDetails(),
      );

      await _flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );

      debugPrint('Resimli bildirim gösterildi: $title');
    } catch (e) {
      debugPrint('Resimli bildirim gösterilirken hata: $e');
      // Hata oluşursa normal bildirim göster
      await showNotification(id: id, title: title, body: body, payload: payload);
    }
  }

  /// Tüm bildirimleri temizle
  static Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
    debugPrint('Tüm bildirimler temizlendi');
  }

  /// Bir bildirimi iptal et
  static Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
    debugPrint('$id ID\'li bildirim iptal edildi');
  }

  /// iOS için eski versiyon desteği (iOS 10'dan önce)
  static void _onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {
    debugPrint('iOS yerel bildirimi alındı: id=$id, title=$title, body=$body, payload=$payload');
  }

  /// Bildirime tıklanınca yapılacak işlemler
  static void _onDidReceiveNotificationResponse(NotificationResponse notificationResponse) {
    final String? payload = notificationResponse.payload;
    debugPrint('Kullanıcı bildirime tıkladı: $payload');
    
    // Bildirime tıklanınca yapılacak işlemleri burada gerçekleştir
    // Örnek: Navigator.push(), spesifik bir sayfaya yönlendirme, vb.
  }
}