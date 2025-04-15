// Bu dosya, Flutter Web için debug fonksiyonlarıyla ilgili 
// çakışmaları çözmeye yardımcı olur
import 'package:flutter/foundation.dart';

/// Debug modu için güvenli izleme fonksiyonu
void safeLog(String message) {
  if (kDebugMode) {
    print(message);
  }
}

/// Debug registerExtension sorunlarını çözmek için
class SafeDebugUtils {
  static bool _initialized = false;
  
  /// Güvenli bir şekilde debug araçlarını başlatır
  static void initialize() {
    if (_initialized) return;
    
    // Platform-bağımsız debug log fonksiyonu
    safeLog('Debug modu aktif: ${DateTime.now()}');
    
    _initialized = true;
  }
  
  /// Web platformunda debug registerExtension sorunlarını önlemek için güvenli çağırma fonksiyonu
  static void safeRegisterExtension(String name, Function callback) {
    // Web platformunda dart:developer registerExtension çağrıları sorun çıkarıyor
    // bu nedenle bir şey yapmıyoruz
    if (kDebugMode) {
      safeLog('Extension kayıt isteği yoksayıldı: $name');
    }
  }
}