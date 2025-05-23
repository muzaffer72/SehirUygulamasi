import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/location/city_profile_screen.dart';
import 'screens/location/district_profile_screen.dart';
import 'utils/constants.dart';
import 'utils/theme.dart';
import 'services/firebase_notification_service.dart';

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
    _checkNotificationPreferences();
    
    // Auth durumunu kontrol et
    ref.read(authProvider.notifier).checkAuth();
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
    final authState = ref.watch(authProvider);
    
    return MaterialApp(
      title: 'ŞikayetVar',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: authState.status == AuthStatus.authenticated 
          ? const HomeScreen() 
          : const LoginScreen(),
      // Genel rotaları tanımlama
      routes: {
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/city_profile') {
          // Daha esnek giriş tipi kontrolü
          String cityId;
          
          // Debugging bilgisi
          print("Şehir profili route argümanı: ${settings.arguments} (${settings.arguments.runtimeType})");
          
          if (settings.arguments is String) {
            cityId = settings.arguments as String;
          } else if (settings.arguments is int) {
            cityId = (settings.arguments as int).toString();
          } else if (settings.arguments == null) {
            // Eğer argüman yoksa, varsayılan değeri kullanalım
            cityId = '0';
          } else {
            // Diğer tüm tiplerde toString() kullanalım
            cityId = settings.arguments.toString();
          }
          return MaterialPageRoute(
            builder: (context) => CityProfileScreen(cityId: cityId),
          );
        } else if (settings.name == '/district_profile') {
          // Daha esnek giriş tipi kontrolü
          String districtId;
          
          // Debugging bilgisi
          print("İlçe profili route argümanı: ${settings.arguments} (${settings.arguments.runtimeType})");
          
          if (settings.arguments is String) {
            districtId = settings.arguments as String;
          } else if (settings.arguments is int) {
            districtId = (settings.arguments as int).toString();
          } else if (settings.arguments == null) {
            // Eğer argüman yoksa, varsayılan değeri kullanalım
            districtId = '0';
          } else {
            // Diğer tüm tiplerde toString() kullanalım
            districtId = settings.arguments.toString();
          }
          return MaterialPageRoute(
            builder: (context) => DistrictProfileScreen(districtId: districtId),
          );
        }
        
        // Eğer bir route bulamazsak onUnknownRoute işlevselliği ekleyelim
        print("Bilinmeyen route: ${settings.name} ile argümanlar: ${settings.arguments}");
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(
              child: Text('Sayfa bulunamadı: ${settings.name}'),
            ),
          ),
        );
      },
    );
  }
}