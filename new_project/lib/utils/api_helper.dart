import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiHelper {
  // API baz URL'ini döndürür
  static String getBaseUrl() {
    if (kIsWeb) {
      // Web platformu için
      return _getWebApiBaseUrl();
    } else if (Platform.isAndroid) {
      // Android için
      return _getAndroidApiBaseUrl();
    } else if (Platform.isIOS) {
      // iOS için
      return _getIOSApiBaseUrl();
    } else {
      // Diğer platformlar için
      return _getWebApiBaseUrl();
    }
  }
  
  // Web platformu için API URL'i
  static String _getWebApiBaseUrl() {
    // Web'de aynı domain'de çalışacak şekilde ("/api" prefix ile)
    return '';
  }
  
  // Android platformu için API URL'i
  static String _getAndroidApiBaseUrl() {
    // Yerel geliştirme için
    if (kDebugMode) {
      // Emülatör için 10.0.2.2 (localhost yerine)
      return 'http://10.0.2.2:9000';
    }
    // Gerçek cihazlar için
    return 'https://workspace.guzelimbatmanli.repl.co/api';
  }
  
  // iOS platformu için API URL'i
  static String _getIOSApiBaseUrl() {
    // Yerel geliştirme için
    if (kDebugMode) {
      return 'http://localhost:9000';
    }
    // Gerçek cihazlar için
    return 'https://workspace.guzelimbatmanli.repl.co/api';
  }
  
  // API yolunu standart hale getir
  static String normalizePath(String path) {
    // Yolun başında '/' varsa kaldır
    if (path.startsWith('/')) {
      path = path.substring(1);
    }
    return path;
  }
  
  // HTTP hata kodlarını kontrol et
  static bool isSuccessResponse(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }
  
  // HTTP yanıt kodlarına göre hata mesajı döndür
  static String getErrorMessageForStatusCode(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Geçersiz istek formatı (400)';
      case 401:
        return 'Yetkilendirme hatası, lütfen tekrar giriş yapın (401)';
      case 403:
        return 'Bu işlem için yetkiniz bulunmuyor (403)';
      case 404:
        return 'İstenen kaynak bulunamadı (404)';
      case 422:
        return 'Doğrulama hatası (422)';
      case 429:
        return 'Çok fazla istek gönderildi, lütfen daha sonra tekrar deneyin (429)';
      case 500:
        return 'Sunucu hatası (500)';
      case 503:
        return 'Servis geçici olarak kullanılamıyor (503)';
      default:
        return 'Bir hata oluştu: $statusCode';
    }
  }
}