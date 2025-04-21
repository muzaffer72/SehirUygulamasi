import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/city_profile/city_profile_screen.dart';
import 'screens/posts/filtered_posts_screen.dart';
import 'screens/posts/post_detail_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'utils/constants.dart';
import 'utils/theme.dart';
import 'services/firebase_notification_service.dart';
import 'services/dynamic_links_service.dart';

// Authentication provider
final currentUserProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

// Theme mode provider
final themeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

// App loading state provider
final appLoadingProvider = StateProvider<bool>((ref) => true);

class BelediyeIletisimApp extends ConsumerStatefulWidget {
  const BelediyeIletisimApp({Key? key}) : super(key: key);

  @override
  ConsumerState<BelediyeIletisimApp> createState() => _BelediyeIletisimAppState();
}

class _BelediyeIletisimAppState extends ConsumerState<BelediyeIletisimApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }
  
  // Initialize app services and preferences
  Future<void> _initializeApp() async {
    await _loadThemePreference();
    await _initNotificationService();
    await _initDynamicLinks();
    
    // Simulate app loading - in real app we'd check for auth, load initial data, etc.
    await Future.delayed(const Duration(milliseconds: 500));
    ref.read(appLoadingProvider.notifier).state = false;
  }
  
  // Initialize notification service
  Future<void> _initNotificationService() async {
    bool notificationsEnabled = await FirebaseNotificationService.areNotificationsEnabled();
    debugPrint('Bildirimler aktif mi: $notificationsEnabled');
    
    // Setup notification handlers
    await FirebaseNotificationService.initialize();
    
    // Bildirim yönetimini kurulduğunda bu fonksiyonları ekleyeceğiz
    // Not: Firebase implementasyonu şu an için yokken bu kısmı yorum satırı haline getiriyoruz
    /*
    FirebaseNotificationService.onForegroundMessage = (message) {
      debugPrint('Ön planda bildirim alındı: ${message.notification?.title}');
      // Show in-app notification
    };
    
    FirebaseNotificationService.onMessageOpenedApp = (message) {
      debugPrint('Bildirim tıklanarak uygulama açıldı');
      // Navigate to appropriate screen based on notification data
      _handleNotificationNavigation(message.data);
    };
    */
  }
  
  // Initialize dynamic links service
  Future<void> _initDynamicLinks() async {
    final dynamicLinksService = DynamicLinksService();
    dynamicLinksService.initialize();
    
    // Uri'leri dinlemek için listener ekliyoruz
    dynamicLinksService.addListener((uri) {
      debugPrint('Dinamik bağlantı alındı: $uri');
      _handleDeepLink(uri);
    });
    
    // Test amaçlı simüle edilmiş örnek bir link:
    // dynamicLinksService.simulateDynamicLink('/post/123');
  }
  
  // Handle navigation from notification
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    if (data.containsKey('post_id')) {
      _navigatorKey.currentState?.pushNamed(
        '/post_detail',
        arguments: data['post_id'],
      );
    } else if (data.containsKey('notification_screen')) {
      _navigatorKey.currentState?.pushNamed('/notifications');
    }
  }
  
  // Handle deep link navigation
  void _handleDeepLink(Uri link) {
    // Parse link path components
    final pathSegments = link.pathSegments;
    
    if (pathSegments.isEmpty) return;
    
    if (pathSegments[0] == 'post' && pathSegments.length > 1) {
      _navigatorKey.currentState?.pushNamed(
        '/post_detail',
        arguments: pathSegments[1],
      );
    } else if (pathSegments[0] == 'city' && pathSegments.length > 1) {
      _navigatorKey.currentState?.pushNamed(
        '/city_profile',
        arguments: int.tryParse(pathSegments[1]),
      );
    }
  }
  
  // Load theme preference
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
    final isLoading = ref.watch(appLoadingProvider);
    
    return MaterialApp(
      title: 'Belediye İletişim',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      navigatorKey: _navigatorKey,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr', 'TR'),
        Locale('en', 'US'),
      ],
      // Splash screen while loading
      home: isLoading 
          ? _buildSplashScreen() 
          : currentUser != null ? const HomeScreen() : const LoginScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/post_detail') {
          return MaterialPageRoute(
            builder: (context) => PostDetailScreen(
              id: settings.arguments as String,
            ),
          );
        } else if (settings.name == '/city_profile') {
          return MaterialPageRoute(
            builder: (context) => CityProfileScreen(
              cityId: settings.arguments.toString(),
            ),
          );
        } else if (settings.name == '/filtered_posts') {
          return MaterialPageRoute(
            builder: (context) => FilteredPostsScreen(
              filterParams: settings.arguments as Map<String, dynamic>,
            ),
          );
        }
        return null;
      },
    );
  }
  
  // Splash screen widget
  Widget _buildSplashScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade700,
              Colors.blue.shade900,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/app_logo_white.png',
                width: 120,
                height: 120,
              ),
              const SizedBox(height: 24),
              const Text(
                'Belediye İletişim',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Şehrinize Sesinizi Duyurun',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}