// Flutter Local Notifications uyumluluk düzeltmesi
// Bu dosyayı lib klasörü içinde bir yere ekleyin ve main.dart'tan çağırın

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    // Android için initialization settings
    AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');

    // Initialization settings objesi
    InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    // Plugin'i initialize et
    await notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Bildirime tıklandığında işlem yapabilirsiniz
        print('Bildirime tıklandı: ${details.payload}');
      },
    );
  }

  // Örnek yerel bildirim gösterme
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      return notificationsPlugin.show(
        id,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'basic_channel',
            'Basic Notifications',
            channelDescription: 'Temel bildirimler için kanal',
            importance: Importance.max,
            priority: Priority.high,
            // BigPictureStyle için resim eklemekten kaçının
            // Icon kullanımında API düzeyine dikkat edin
          ),
        ),
        payload: payload,
      );
    } catch (e) {
      print('Bildirim gösterme hatası: $e');
    }
  }
}