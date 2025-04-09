import 'package:flutter/foundation.dart';

/// Platform özel konum işlemleri gerekiyorsa kullanılacak yardımcı sınıf.
/// Web ve mobil platformlar arasındaki farkları yönetmek için kullanılır.
class PlatformLocationBridge {
  // Singleton pattern
  static final PlatformLocationBridge _instance = PlatformLocationBridge._internal();
  factory PlatformLocationBridge() => _instance;
  PlatformLocationBridge._internal();
  
  /// Platformun konum özelliklerini destekleyip desteklemediğini kontrol eder
  bool get isLocationSupported {
    // Web'de konum özellikleri farklı çalışır, HTML5 Geolocation API kullanılır
    if (kIsWeb) {
      return true;
    }
    
    // Android ve iOS'ta tam destek var
    // Not: Web'de Platform.isAndroid ve Platform.isIOS hata oluşturacaktır
    // Bu yüzden Platform sınıfını import etmiyoruz
    return true; // SDK 35 ile tüm platformlarda destekleniyor
  }
  
  /// Platform için doğru izin mesajını döndürür
  String getPermissionRationaleMessage() {
    if (kIsWeb) {
      return "Web tarayıcınızda konum servislerine izin vererek size yakın şikayetleri görüntüleyebilirsiniz.";
    } else {
      // Platform detection göre farklı mesajlar kullanabiliriz
      return "Size yakın şikayetleri görebilmek ve şikayetlerinize konum ekleyebilmek için konum iznine ihtiyacımız var.";
    }
  }
  
  /// Platform bazlı izin durumlarını yönetir ve kullanıcıya uygun mesaj döndürür
  String getPermissionDeniedMessage() {
    if (kIsWeb) {
      return "Konum iznini reddettiniz. Ayarlardan tarayıcı konum iznini etkinleştirmelisiniz.";
    } else {
      // Platform detection göre farklı mesajlar kullanabiliriz
      return "Konum iznini reddettiniz. Uygulama ayarlarından konum izinlerini etkinleştirmelisiniz.";
    }
  }
  
  /// Platformun varsayılan konum doğruluğunu döndürür
  String getDefaultLocationAccuracy() {
    if (kIsWeb) {
      return "medium"; // Web'de orta hassasiyet kullanırız
    } else {
      // Platform detection göre farklı değerler kullanabiliriz
      return "high"; // Mobil platformlarda yüksek doğruluk kullanırız
    }
  }
}