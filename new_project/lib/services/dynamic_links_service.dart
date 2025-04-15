import 'package:flutter/material.dart';

// Firebase kullanılmayan geçici dynamic link implementasyonu
typedef DynamicLinkCallback = void Function(Uri);

class DynamicLinksService {
  static final DynamicLinksService _instance = DynamicLinksService._internal();
  factory DynamicLinksService() => _instance;
  DynamicLinksService._internal();

  // Callbacks
  List<DynamicLinkCallback> _callbacks = [];

  // Mock dynamic link servisi
  void initialize() async {
    debugPrint('DynamicLinksService: initialize çağrıldı (Firebase olmadan)');
    // Burada asıl uygulamada Firebase işlemleri olacak
  }

  // Callback ekleme
  void addListener(DynamicLinkCallback callback) {
    _callbacks.add(callback);
  }

  // Callback çıkarma
  void removeListener(DynamicLinkCallback callback) {
    _callbacks.remove(callback);
  }

  // Gelen dynamic link'i handle etme
  void _handleDynamicLink(Uri dynamicLinkData) {
    debugPrint('Dinamik bağlantı alındı: $dynamicLinkData');
    
    for (var callback in _callbacks) {
      callback(dynamicLinkData);
    }
  }

  // Post için link oluşturma
  Future<String> createPostLink(String postId, String title, String imageUrl) async {
    final uri = Uri.parse('https://belediyeiletisim.page.link/?link=https://belediyeiletisim.com/post/$postId&apn=com.example.belediye_iletisim_merkezi');
    return uri.toString();
  }

  // Şehir profili için link oluşturma
  Future<String> createCityProfileLink(String cityId, String cityName) async {
    final uri = Uri.parse('https://belediyeiletisim.page.link/?link=https://belediyeiletisim.com/city/$cityId&apn=com.example.belediye_iletisim_merkezi');
    return uri.toString();
  }

  // Test amaçlı dinamik link oluşturma
  void simulateDynamicLink(String path) {
    final Uri uri = Uri.parse('https://belediyeiletisim.com$path');
    _handleDynamicLink(uri);
  }
}