import 'package:flutter/material.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

typedef DynamicLinkCallback = void Function(PendingDynamicLinkData);

/// Firebase Dinamik Bağlantı servisi
/// Uygulama içi derin bağlantıları (deep linking) yönetir
class DynamicLinksService {
  static FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
  static DynamicLinkCallback? _onDynamicLink;

  /// Servis başlatma
  static Future<void> initialize({
    required DynamicLinkCallback onDynamicLink,
  }) async {
    _onDynamicLink = onDynamicLink;

    // Uygulama başlatıldığında bekleyen herhangi bir dinamik bağlantı var mı kontrol et
    final PendingDynamicLinkData? initialLink = await dynamicLinks.getInitialLink();
    
    if (initialLink != null) {
      _handleDynamicLink(initialLink);
    }

    // Uygulama arka planda veya kapalıyken gelen dinamik bağlantıları dinle
    dynamicLinks.onLink.listen((dynamicLinkData) {
      _handleDynamicLink(dynamicLinkData);
    }).onError((error) {
      debugPrint('Dinamik bağlantı dinleme hatası: $error');
    });
  }

  /// Dinamik bağlantıyı işle
  static void _handleDynamicLink(PendingDynamicLinkData dynamicLinkData) {
    final Uri deepLink = dynamicLinkData.link;
    debugPrint('Alınan dinamik bağlantı: $deepLink');
    
    if (_onDynamicLink != null) {
      _onDynamicLink!(dynamicLinkData);
    }
  }

  /// Gönderi paylaşım bağlantısı oluşturma 
  static Future<Uri> createPostShareLink(String postId, {
    String title = 'Bu gönderiye göz atın',
    String description = 'Belediye İletişim uygulamasında bir gönderi paylaşıldı',
    String imageUrl = '',
  }) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://belediyeiletisim.page.link',
      link: Uri.parse('https://belediyeiletisim.com/post/$postId'),
      androidParameters: const AndroidParameters(
        packageName: 'com.belediyeiletisim.app',
        minimumVersion: 0,
      ),
      iosParameters: const IOSParameters(
        bundleId: 'com.belediyeiletisim.app',
        minimumVersion: '0',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: title,
        description: description,
        imageUrl: imageUrl.isNotEmpty ? Uri.parse(imageUrl) : null,
      ),
    );

    final ShortDynamicLink shortLink = await dynamicLinks.buildShortLink(parameters);
    return shortLink.shortUrl;
  }

  /// Şehir paylaşım bağlantısı oluşturma
  static Future<Uri> createCityShareLink(int cityId, String cityName, {
    String imageUrl = '',
  }) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://belediyeiletisim.page.link',
      link: Uri.parse('https://belediyeiletisim.com/city/$cityId'),
      androidParameters: const AndroidParameters(
        packageName: 'com.belediyeiletisim.app',
        minimumVersion: 0,
      ),
      iosParameters: const IOSParameters(
        bundleId: 'com.belediyeiletisim.app',
        minimumVersion: '0',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: '$cityName Şehir Profili',
        description: '$cityName hakkında şikayetleri, önerileri ve çözüm istatistiklerini görün',
        imageUrl: imageUrl.isNotEmpty ? Uri.parse(imageUrl) : null,
      ),
    );

    final ShortDynamicLink shortLink = await dynamicLinks.buildShortLink(parameters);
    return shortLink.shortUrl;
  }
}