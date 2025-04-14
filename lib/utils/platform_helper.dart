import 'package:flutter/foundation.dart' show kIsWeb;

/// Platform yardımcı fonksiyonları
/// Bu sınıf, platformlar arası uyumluluk için yardımcı metotlar içerir
class PlatformHelper {
  /// Uygulamanın web platformunda çalışıp çalışmadığını kontrol eder
  static bool isRunningOnWeb() {
    return kIsWeb;
  }

  /// Uygulamanın mobil platformda çalışıp çalışmadığını kontrol eder
  static bool isRunningOnMobile() {
    return !kIsWeb;
  }

  /// Web platformuna özgü özellikleri güvenli bir şekilde kontrol eder
  /// Web'de çalışmayan kodun Android/iOS'ta hata vermesini önler
  static T runOnWebOnly<T>(T Function() webCallback, T defaultValue) {
    if (kIsWeb) {
      try {
        return webCallback();
      } catch (e) {
        return defaultValue;
      }
    }
    return defaultValue;
  }
}