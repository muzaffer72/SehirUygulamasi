import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'utils/constants.dart';
import 'utils/theme.dart';
import 'services/firebase_notification_service.dart';

// Auth provider tanımı
final currentUserProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

// Provider for current theme mode
final themeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

class BelediyeIletisimApp extends ConsumerStatefulWidget {
  const BelediyeIletisimApp({Key? key}) : super(key: key);

  @override
  ConsumerState<BelediyeIletisimApp> createState() => _BelediyeIletisimAppState();
}

class _BelediyeIletisimAppState extends ConsumerState<BelediyeIletisimApp> {
  @override
  void initState() {
    super.initState();
    _loadThemePreference();
    _checkNotificationPreferences();
  }
  
  // Bildirim ayarlarını kontrol et
  Future<void> _checkNotificationPreferences() async {
    bool notificationsEnabled = await FirebaseNotificationService.areNotificationsEnabled();
    debugPrint('Bildirimler aktif mi: $notificationsEnabled');
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
      title: 'Belediye İletişim',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: currentUser != null ? const HomeScreen() : const LoginScreen(),
    );
  }
}