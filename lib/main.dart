import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'app.dart'; // Ana uygulama için SikayetVarApp sınıfını içe aktarıyoruz
import 'services/firebase_service.dart';
import 'services/notification_service.dart';

void main() async {
  // Flutter bağlamını başlat
  WidgetsFlutterBinding.ensureInitialized();
  
  // Hata yakalama için global işleyici
  runZonedGuarded(() async {
    // Firebase servislerini başlat
    await FirebaseService.initialize();
    
    // Bildirim servisini başlat
    await NotificationService.initialize();
    
    // Riverpod ile uygulamayı başlat - SikayetVarApp ile başlatıyoruz
    runApp(
      const ProviderScope(
        child: SikayetVarApp(),
      ),
    );
  }, (error, stack) {
    // Hata loglama işlemleri
    debugPrint('Kritik hata: $error');
    debugPrint('Stack trace: $stack');
  });
}

/// Bildirim modeli sınıfı için önceki tanımdan vazgeçildi
/// Artık lib/models/notification_model.dart kullanılıyor
///
/// Bu sınıf silindi ve modeline referans yapıldı
/// Bkz: import 'models/notification_model.dart';