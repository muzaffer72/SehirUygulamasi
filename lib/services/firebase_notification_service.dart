import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/notification_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Firebase Cloud Messaging servisi
/// Firebase entegrasyonu tamamlandığında kullanılacak olan FCM bildirim servisi
class FirebaseNotificationService {
  static const String FCM_PREF_KEY = 'fcm_token';
  static const String NOTIFICATION_ENABLED_KEY = 'notifications_enabled';
  
  // Bildirim ayarları için varsayılan değerler
  static const Map<String, bool> DEFAULT_NOTIFICATION_SETTINGS = {
    'all_notifications': true,       // Tüm bildirimler
    'new_replies': true,             // Yeni yanıtlar
    'comments': true,                // Yorumlar
    'likes': true,                   // Beğeniler
    'status_updates': true,          // Durum güncellemeleri
    'announcements': true,           // Duyurular
    'local_notifications': true,     // Yerel bildirimler (ilçe/şehir)
  };

  /// FCM token'ı kaydeder
  static Future<void> saveFcmToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(FCM_PREF_KEY, token);
    
    // Token'ı API'ye gönder
    await _updateTokenOnServer(token);
  }

  /// Kaydedilmiş FCM token'ı getirir
  static Future<String?> getFcmToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(FCM_PREF_KEY);
  }

  /// Bildirimlerin açık olup olmadığını kontrol eder
  static Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(NOTIFICATION_ENABLED_KEY) ?? true; // Varsayılan olarak açık
  }

  /// Bildirimleri açıp/kapatır
  static Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(NOTIFICATION_ENABLED_KEY, enabled);
    
    // Sunucuya bildirim tercihini gönder
    _updateNotificationPreferences();
  }

  /// Bir bildirim türünün açık olup olmadığını kontrol eder
  static Future<bool> isNotificationTypeEnabled(String notificationType) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(notificationType) ?? 
           DEFAULT_NOTIFICATION_SETTINGS[notificationType] ?? 
           true;
  }

  /// Bildirim türünü açıp/kapatır
  static Future<void> setNotificationTypeEnabled(String notificationType, bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(notificationType, enabled);
    
    // Sunucuya bildirim tercihlerini gönder
    _updateNotificationPreferences();
  }

  /// Tüm bildirim ayarlarını getirir
  static Future<Map<String, bool>> getNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, bool> settings = {};
    
    // Varsayılan değerleri ekle
    settings.addAll(DEFAULT_NOTIFICATION_SETTINGS);
    
    // Kaydedilmiş değerleri ekle
    for (final key in DEFAULT_NOTIFICATION_SETTINGS.keys) {
      if (prefs.containsKey(key)) {
        settings[key] = prefs.getBool(key)!;
      }
    }
    
    // Ana bildirim ayarı
    settings['all_notifications'] = await areNotificationsEnabled();
    
    return settings;
  }

  /// Bildirim tercihlerini sunucuya günceller
  static Future<void> _updateNotificationPreferences() async {
    try {
      final fcmToken = await getFcmToken();
      if (fcmToken == null) return;
      
      final settings = await getNotificationSettings();
      final enabled = settings['all_notifications'] ?? true;
      
      final response = await http.post(
        Uri.parse('/api/notifications/preferences'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'fcm_token': fcmToken,
          'enabled': enabled,
          'preferences': settings,
        }),
      );
      
      // Yanıtı kontrol et
      if (response.statusCode != 200) {
        print('Bildirim tercihleri güncellenirken hata oluştu: ${response.body}');
      }
    } catch (e) {
      print('Bildirim tercihleri güncellenirken hata: $e');
    }
  }

  /// FCM token'ı sunucuya günceller
  static Future<void> _updateTokenOnServer(String token) async {
    try {
      final response = await http.post(
        Uri.parse('/api/notifications/register-token'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'fcm_token': token,
          'device_type': Platform.isAndroid ? 'android' : 'ios',
        }),
      );
      
      // Yanıtı kontrol et
      if (response.statusCode != 200) {
        print('FCM token güncellenirken hata oluştu: ${response.body}');
      }
    } catch (e) {
      print('FCM token güncellenirken hata: $e');
    }
  }
}