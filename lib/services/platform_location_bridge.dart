import 'dart:io';
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
    if (Platform.isAndroid || Platform.isIOS) {
      return true;
    }
    
    // Diğer platformlarda (macOS, Windows, Linux) daha sınırlı destek olabilir
    return false;
  }
  
  /// Platform için doğru izin mesajını döndürür
  String getPermissionRationaleMessage() {
    if (kIsWeb) {
      return "Web tarayıcınızda konum servislerine izin vererek size yakın şikayetleri görüntüleyebilirsiniz.";
    } else if (Platform.isAndroid) {
      return "Size yakın şikayetleri görebilmek ve şikayetlerinize konum ekleyebilmek için konum iznine ihtiyacımız var.";
    } else if (Platform.isIOS) {
      return "Konum bilgileriniz sadece size yakın şikayetleri göstermek ve şikayetlerinize konum eklemek için kullanılacaktır.";
    } else {
      return "Konum özelliklerini kullanmak için izin vermeniz gerekiyor.";
    }
  }
  
  /// Platform bazlı izin durumlarını yönetir ve kullanıcıya uygun mesaj döndürür
  String getPermissionDeniedMessage() {
    if (kIsWeb) {
      return "Konum iznini reddettiniz. Ayarlardan tarayıcı konum iznini etkinleştirmelisiniz.";
    } else if (Platform.isAndroid) {
      return "Konum iznini reddettiniz. Uygulama ayarlarından 'İzinler' bölümüne giderek konum iznini etkinleştirebilirsiniz.";
    } else if (Platform.isIOS) {
      return "Konum iznini reddettiniz. Telefonunuzun Ayarlar > Gizlilik > Konum Servisleri bölümünden uygulamaya izin vermelisiniz.";
    } else {
      return "Konum izni reddedildi. Sistem ayarlarından izinleri değiştirebilirsiniz.";
    }
  }
  
  /// Platformun varsayılan konum doğruluğunu döndürür
  String getDefaultLocationAccuracy() {
    if (Platform.isAndroid) {
      return "high"; // Android'de yüksek doğruluk kullanırız
    } else if (Platform.isIOS) {
      return "best"; // iOS'ta "best" tercih edilir
    } else {
      return "medium"; // Diğer platformlarda orta hassasiyet yeterlidir
    }
  }
}