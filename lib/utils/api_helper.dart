// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiHelper {
  /// Web uygulaması için mevcut URL'den API adresini oluşturur
  static String getApiBaseUrl() {
    if (kIsWeb) {
      // Web'de çalışırken window.location.origin değerini kullanıyoruz
      final origin = html.window.location.origin;
      // Admin panel adresi (/api endpointi) kullan
      return '$origin:3000/api';
    } else {
      // Mobilde sabit URL kullanıyoruz
      return 'https://workspace.replit.app/api';
    }
  }
}