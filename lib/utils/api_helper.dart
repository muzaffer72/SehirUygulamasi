import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiHelper {
  /// Web uygulaması veya mobil için API adresini oluşturur
  static String getApiBaseUrl() {
    if (kIsWeb) {
      // Web'de çalışırken dinamik URL oluşturucuyu kullanırız
      // ÖNEMLİ: dart:html kütüphanesi Web platform dışında kullanılamaz
      // Bu nedenle web platformunda çalışan JS kodu ile URL oluşturulması gerekiyor
      // window.location.protocol ve window.location.hostname değerleri JS tarafında alınacak
      
      // Bu web için fallback değeri - normalde kullanılmaz çünkü JS kodu çalışır
      return 'https://workspace.replit.app';
    } else {
      // Mobilde sabit URL kullanıyoruz (api yolsuz)
      return 'https://workspace.replit.app';
    }
  }
}