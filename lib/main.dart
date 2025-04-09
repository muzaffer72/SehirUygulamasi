import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services if needed
  // await Firebase.initializeApp();
  
  runApp(
    const ProviderScope(
      child: SikayetVarApp(),
    ),
  );
}
