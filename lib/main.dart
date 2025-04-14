import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'services/firebase_service.dart';

void main() async {
  // Widget binding'in başlatılması
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase servislerini başlat
  final firebaseService = FirebaseService();
  await firebaseService.initialize();
  
  // Uygulama başlat
  runApp(
    const ProviderScope(
      child: SikayetVarApp(),
    ),
  );
}