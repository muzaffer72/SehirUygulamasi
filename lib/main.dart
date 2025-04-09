import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikayet_var/screens/screens.dart';
import 'package:sikayet_var/utils/constants.dart';
import 'package:sikayet_var/utils/theme.dart';
import 'package:timeago/timeago.dart' as timeago;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Configure time ago localization
  timeago.setLocaleMessages('tr', timeago.TrMessages());
  timeago.setDefaultLocale('tr');
  
  // Run app
  runApp(
    const ProviderScope(
      child: SikayetVarApp(),
    ),
  );
}

class SikayetVarApp extends ConsumerWidget {
  const SikayetVarApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Add theme selector based on shared preferences
    final isDarkMode = false;
    
    return MaterialApp(
      title: Constants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: const MainNavigationScreen(),
    );
  }
}