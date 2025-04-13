// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiHelper {
  /// Web uygulaması için mevcut URL'den API adresini oluşturur
  static String getApiBaseUrl() {
    if (kIsWeb) {
      // Web'de çalışırken protokol ve host'u ayır, port değerini değiştir
      final protocol = html.window.location.protocol; // "http:" veya "https:"
      final hostname = html.window.location.hostname; // "domain.com" veya "localhost" 
      
      // API proxy 9000 portundan yayınlanıyor (api yolsuz)
      return '$protocol//$hostname:9000';
    } else {
      // Mobilde sabit URL kullanıyoruz (api yolsuz)
      return 'https://workspace.replit.app';
    }
  }
}