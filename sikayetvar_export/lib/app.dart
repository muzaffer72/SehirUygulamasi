import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sikayet_var/providers/auth_provider.dart';
import 'package:sikayet_var/screens/auth/login_screen.dart';
import 'package:sikayet_var/screens/home/home_screen.dart';
import 'package:sikayet_var/utils/constants.dart';
import 'package:sikayet_var/utils/theme.dart';

// Provider for current theme mode
final themeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

class SikayetVarApp extends ConsumerStatefulWidget {
  const SikayetVarApp({Key? key}) : super(key: key);

  @override
  ConsumerState<SikayetVarApp> createState() => _SikayetVarAppState();
}

class _SikayetVarAppState extends ConsumerState<SikayetVarApp> {
  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }
  
  // Load theme preference from SharedPreferences
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString(Constants.themeKey);
    
    if (themeString != null) {
      ThemeMode themeMode;
      
      switch (themeString) {
        case 'light':
          themeMode = ThemeMode.light;
          break;
        case 'dark':
          themeMode = ThemeMode.dark;
          break;
        default:
          themeMode = ThemeMode.system;
      }
      
      ref.read(themeProvider.notifier).state = themeMode;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final currentUser = ref.watch(currentUserProvider);
    
    return MaterialApp(
      title: 'ŞikayetVar',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: currentUser != null ? const HomeScreen() : const LoginScreen(),
    );
  }
}