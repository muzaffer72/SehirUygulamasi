import 'package:flutter/material.dart';

/// Firebase bildirim servisi
/// Bu sınıf şu an için sadece boş metodlar içeriyor, Firebase kurulduğunda
/// gerçek implementasyonu eklenecek.
class FirebaseNotificationService {
  static bool _initialized = false;
  
  /// Bildirimlerin etkin olup olmadığını kontrol eder
  static Future<bool> areNotificationsEnabled() async {
    // Şu an için her zaman true döndürelim
    return true;
  }
  
  /// Bildirim servisini başlatır
  static Future<void> initialize() async {
    if (_initialized) return;
    
    debugPrint('FirebaseNotificationService: initialize çağrıldı (Firebase olmadan)');
    
    _initialized = true;
  }
  
  /// FCM token'ı alır
  static Future<String?> getToken() async {
    // Şu an için boş bir string döndürelim
    return 'mock-fcm-token';
  }
  
  /// FCM token'ı sunucuya kaydetmek için kullanılır
  static Future<void> saveTokenToDatabase(String token) async {
    debugPrint('FCM token sunucuya kaydedildi (sahte): $token');
  }
  
  /// Kullanıcı ID'si ile FCM token ilişkilendirmek için kullanılır
  static Future<void> saveUserIdWithToken(String userId) async {
    final token = await getToken();
    if (token != null) {
      debugPrint('Kullanıcı ID ile FCM token ilişkilendirildi (sahte): $userId, $token');
    }
  }
  
  /// Abonelikten çıkmak için kullanılır
  static Future<void> unsubscribeFromTopic(String topic) async {
    debugPrint('Konudan abonelik çıkıldı (sahte): $topic');
  }
  
  /// Konuya abone olmak için kullanılır
  static Future<void> subscribeToTopic(String topic) async {
    debugPrint('Konuya abone olundu (sahte): $topic');
  }
}