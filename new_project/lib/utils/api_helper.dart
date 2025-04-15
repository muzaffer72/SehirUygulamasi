import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiHelper {
  /// Web uygulaması veya mobil için API adresini oluşturur
  static String getApiBaseUrl() {
    if (kIsWeb) {
      // Web'de çalışırken API proxy adresini kullanıyoruz
      // Şu anki adresten Replit'in ana adresini ayıklıyoruz
      final url = Uri.base.toString();
      final parts = url.split('.');
      if (parts.length >= 2) {
        // Bu ana proje adresidir, örn: https://workspace.guzelimbatmanli.repl.co
        return '$url/api';
      }
      // Eğer ayıklama işlemi başarısız olursa sabit adres kullan
      return 'https://workspace.guzelimbatmanli.repl.co/api';
    } else {
      // Lokalde geliştirme yaparken localhost kullan
      if (kDebugMode) {
        return 'http://0.0.0.0:9000/api';
      }
      
      // Gerçek cihazda çalışırken Replit projesinin canlı adresini kullan
      return 'https://workspace.guzelimbatmanli.repl.co/api';
    }
  }
  
  /// Medya dosya URL'lerini düzenler (görseller, belgeler vb.)
  static String fixMediaUrl(String? url) {
    if (url == null || url.isEmpty) {
      return 'assets/images/placeholder.png'; // Varsayılan görsel
    }
    
    // URL zaten tam bir adres ise (http veya https ile başlıyorsa) olduğu gibi bırak
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    
    // URL dosya yolu ise (örn: /uploads/image.jpg) API adresine ekle
    if (url.startsWith('/')) {
      // Admin panel host adresine ekle (uploads klasörü admin panelde)
      final baseUrlWithoutApi = getApiBaseUrl().replaceAll('/api', '');
      final hostParts = baseUrlWithoutApi.split('://');
      final protocol = hostParts[0]; // http veya https
      final host = hostParts[1].split('/')[0]; // örn: workspace.guzelimbatmanli.repl.co
      
      return '$protocol://$host$url';
    }
    
    // Diğer durumlarda olduğu gibi bırak
    return url;
  }
  
  /// Debug modda olup olmadığımızı kontrol et 
  static bool get kDebugMode {
    bool inDebugMode = false;
    
    // Debug modunu kontrol etmek için assert kullanılır
    assert((){
      inDebugMode = true;
      return true;
    }());
    
    return inDebugMode;
  }
}