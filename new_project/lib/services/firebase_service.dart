import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Firebase çekirdek hizmetlerini başlatmak ve yönetmek için kullanılan servis sınıfı.
/// 
/// Bu sınıf, Firebase'in temel özelliklerini başlatır ve yapılandırır.
class FirebaseService {
  static bool _isInitialized = false;
  
  /// Firebase başlatıldı mı kontrol eder
  static bool get isInitialized => _isInitialized;
  
  /// Firebase'i başlatır ve yapılandırır.
  /// 
  /// Uygulama başladığında çağrılmalıdır.
  static Future<void> initialize() async {
    // Zaten başlatılmışsa tekrar başlatma
    if (_isInitialized) return;
    
    try {
      // Firebase seçenekleri olmadan options: DefaultFirebaseOptions.currentPlatform
      // kullanılamaz, bu yüzden basit başlatma yapılıyor
      await Firebase.initializeApp();
      _isInitialized = true;
      debugPrint('Firebase başarıyla başlatıldı');
    } catch (e) {
      debugPrint('Firebase başlatılırken hata oluştu: $e');
      // Uygulama Firebase olmadan da çalışabilir
    }
  }
  
  /// Firebase'in kullanılabilir olup olmadığını kontrol eder.
  /// 
  /// Firebase'in doğru şekilde başlatıldığını ve kullanılabilir olduğunu doğrulamak için kullanılır.
  /// 
  /// [true] Firebase kullanılabilir ise, [false] aksi halde döner.
  static bool isFirebaseAvailable() {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (e) {
      debugPrint('Firebase kontrolü sırasında hata: $e');
      return false;
    }
  }
}