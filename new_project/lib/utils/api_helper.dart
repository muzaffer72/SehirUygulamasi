import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiHelper {
  /// Web uygulaması veya mobil için API adresini oluşturur
  static String getApiBaseUrl() {
    if (kIsWeb) {
      // Web'de çalışırken API proxy adresini kullanıyoruz
      return 'http://0.0.0.0:9000/api';
    } else {
      // Mobilde API proxy adresini kullanıyoruz
      return 'http://0.0.0.0:9000/api';
    }
  }
}