import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/notification_model.dart';
import './firebase_notification_service.dart';

/// Bildirim servisi - HTTP tabanlı bildirim yönetimi için
class NotificationService {
  static const String _baseUrl = '/api/notifications';
  
  /// Kullanıcının bildirimlerini getirir
  static Future<List<NotificationModel>> getUserNotifications() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/user'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((data) => NotificationModel.fromJson(data)).toList();
      } else {
        throw Exception('Bildirimler yüklenemedi: ${response.body}');
      }
    } catch (e) {
      throw Exception('Bildirimler yüklenemedi: $e');
    }
  }
  
  /// Bildirimi okundu olarak işaretler
  static Future<void> markAsRead(int notificationId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/mark-read/$notificationId'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode != 200) {
        throw Exception('Bildirim okundu olarak işaretlenemedi: ${response.body}');
      }
    } catch (e) {
      throw Exception('Bildirim okundu olarak işaretlenemedi: $e');
    }
  }
  
  /// Tüm bildirimleri okundu olarak işaretler
  static Future<void> markAllAsRead() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/mark-all-read'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode != 200) {
        throw Exception('Bildirimler okundu olarak işaretlenemedi: ${response.body}');
      }
    } catch (e) {
      throw Exception('Bildirimler okundu olarak işaretlenemedi: $e');
    }
  }
  
  /// Bildirimi siler
  static Future<void> deleteNotification(int notificationId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/$notificationId'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode != 200) {
        throw Exception('Bildirim silinemedi: ${response.body}');
      }
    } catch (e) {
      throw Exception('Bildirim silinemedi: $e');
    }
  }
  
  /// Tüm bildirimleri siler
  static Future<void> deleteAllNotifications() async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/all'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode != 200) {
        throw Exception('Bildirimler silinemedi: ${response.body}');
      }
    } catch (e) {
      throw Exception('Bildirimler silinemedi: $e');
    }
  }
  
  /// Okunmamış bildirim sayısını getirir
  static Future<int> getUnreadCount() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/unread-count'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return jsonData['count'] ?? 0;
      } else {
        throw Exception('Okunmamış bildirim sayısı alınamadı: ${response.body}');
      }
    } catch (e) {
      throw Exception('Okunmamış bildirim sayısı alınamadı: $e');
    }
  }
  
  /// Yeni bildirim oluşturur (yalnızca yöneticiler için)
  static Future<void> createNotification({
    required String title,
    required String content,
    required String type,
    required String notificationType,
    required String scopeType,
    int? scopeId,
    String? imageUrl,
    String? actionUrl,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/create'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': title,
          'content': content,
          'type': type,
          'notification_type': notificationType,
          'scope_type': scopeType,
          'scope_id': scopeId,
          'image_url': imageUrl,
          'action_url': actionUrl,
        }),
      );
      
      if (response.statusCode != 201) {
        throw Exception('Bildirim oluşturulamadı: ${response.body}');
      }
    } catch (e) {
      throw Exception('Bildirim oluşturulamadı: $e');
    }
  }
  
  /// Bildirim ayarlarını sunucudan getirir
  static Future<Map<String, bool>> getNotificationSettings() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/settings'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final Map<String, bool> settings = {};
        
        jsonData.forEach((key, value) {
          if (value is bool) {
            settings[key] = value;
          } else if (value is int) {
            settings[key] = value == 1;
          }
        });
        
        return settings;
      } else {
        // Veritabanından ayarlar alınamazsa yerel ayarları kullan
        return FirebaseNotificationService.getNotificationSettings();
      }
    } catch (e) {
      // Hata durumunda yerel ayarları kullan
      return FirebaseNotificationService.getNotificationSettings();
    }
  }
  
  /// Bildirim ayarlarını günceller
  static Future<void> updateNotificationSettings(Map<String, bool> settings) async {
    try {
      // Hem yerel hem de sunucu ayarlarını güncelle
      for (final entry in settings.entries) {
        await FirebaseNotificationService.setNotificationTypeEnabled(entry.key, entry.value);
      }
      
      // Ana bildirim ayarını güncelle
      if (settings.containsKey('all_notifications')) {
        await FirebaseNotificationService.setNotificationsEnabled(settings['all_notifications']!);
      }
      
      // Sunucu ayarlarını güncelle
      final response = await http.post(
        Uri.parse('$_baseUrl/settings'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(settings),
      );
      
      if (response.statusCode != 200) {
        throw Exception('Bildirim ayarları güncellenemedi: ${response.body}');
      }
    } catch (e) {
      throw Exception('Bildirim ayarları güncellenemedi: $e');
    }
  }
}