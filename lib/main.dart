import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'services/firebase_service.dart';
import 'services/notification_service.dart';
import 'models/notification_model.dart';

void main() async {
  // Flutter bağlamını başlat
  WidgetsFlutterBinding.ensureInitialized();
  
  // Hata yakalama için global işleyici
  runZonedGuarded(() async {
    // Firebase servislerini başlat
    await FirebaseService.initialize();
    
    // Bildirim servisini başlat
    await NotificationService.initialize();
    
    // Riverpod ile uygulamayı başlat
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

/// ŞikayetVar ana uygulama sınıfı
class SikayetVarApp extends StatelessWidget {
  const SikayetVarApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ŞikayetVar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      // Türkçe dil desteği
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr', 'TR'), // Türkçe
        Locale('en', 'US'), // İngilizce
      ],
      locale: const Locale('tr', 'TR'),
      
      // Ana sayfa
      home: const HomeScreen(),
    );
  }
}

/// Geçici ana sayfa
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ŞikayetVar'),
        actions: [
          // Bildirim butonu
          IconButton(
            icon: const Badge(
              label: Text('N'),
              child: Icon(Icons.notifications),
            ),
            onPressed: () {
              // TODO: Bildirimler sayfasını aç
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'ŞikayetVar',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Belediye ve Valiliğe yönelik şikayet platformu',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Bildirim test butonu
                NotificationService.addNotification(
                  NotificationModel.fromMap({
                    'id': DateTime.now().millisecondsSinceEpoch.toString(),
                    'title': 'Test Bildirimi',
                    'message': 'Bu bir test bildirimidir.',
                    'timestamp': DateTime.now(),
                    'type': 'test',
                  }),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Test bildirimi oluşturuldu')),
                );
              },
              child: const Text('Test Bildirimi Gönder'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bildirim modeli sınıfı için önceki tanımdan vazgeçildi
/// Artık lib/models/notification_model.dart kullanılıyor
///
/// Bu sınıf silindi ve modeline referans yapıldı
/// Bkz: import 'package:sikayet_var/models/notification_model.dart';