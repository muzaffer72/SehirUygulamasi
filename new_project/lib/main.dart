import 'dart:async';
import 'dart:async' show Zone;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'app.dart';
import 'services/firebase_service.dart';
import 'services/notification_service.dart';
import 'models/notification_model.dart';
import 'providers/post_provider.dart' as post_provider;
import 'providers/auth_provider.dart';
import 'models/post.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/create_post/create_post_screen.dart';
import 'screens/location/city_profile_screen.dart';
import 'screens/posts/post_detail_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/explore/explore_screen.dart';
import 'screens/cities/cities_list_screen.dart';
import 'screens/surveys/surveys_screen.dart';
import 'pages/notification_settings_page.dart';
import 'utils/timeago_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/auth_provider.dart';

// Yükleme durumu için provider
final isLoadingProvider = StateProvider<bool>((ref) => false);

// Zone uyumsuzluğu hatasını çözmek için bu değişken tanımlanıyor
Zone? _initializationZone;

void main() async {
  // Önce mevcut zonu kaydet
  _initializationZone = Zone.current;
  
  // Aynı zonda Flutter bağlamını başlat
  _initializationZone!.run(() {
    WidgetsFlutterBinding.ensureInitialized();
  });
  
  // Timeago kütüphanesini Türkçe dil desteği ile yapılandır
  configureTimeAgo();
  
  // Firebase servislerini başlat
  await FirebaseService.initialize();
  
  // Bildirim servisini başlat
  await NotificationService.initialize();
  
  // SharedPreferences instance oluştur
  final prefs = await SharedPreferences.getInstance();
  
  // Zone uyumsuzluğunu önlemek için aynı zonda runApp çağrısı yapılıyor
  runZonedGuarded(() {
    // Aynı zonda çalıştırıyoruz
    _initializationZone!.run(() {
      // Riverpod ile uygulamayı başlat
      runApp(
        ProviderScope(
          overrides: [
            // SharedPreferences sağlayıcısı
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const BelediyeIletisimApp(),
        ),
      );
    });
  }, (error, stack) {
    // Hata loglama işlemleri
    debugPrint('Kritik hata: $error');
    debugPrint('Stack trace: $stack');
  });
}

/// Belediye İletişim ana uygulama sınıfı
class BelediyeIletisimApp extends StatelessWidget {
  const BelediyeIletisimApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Belediye İletişim',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          brightness: Brightness.dark,
        ),
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
      home: const IletisimHomePage(),
    );
  }
}

/// Geliştirilmiş ana sayfa
class IletisimHomePage extends StatefulWidget {
  const IletisimHomePage({Key? key}) : super(key: key);

  @override
  State<IletisimHomePage> createState() => _IletisimHomePageState();
}

class _IletisimHomePageState extends State<IletisimHomePage> {
  int _selectedIndex = 0;
  bool _hasNotification = true; // Örnek bildirim göstergesi
  
  @override
  void initState() {
    super.initState();
  }
  
  @override
  void dispose() {
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // Ekranlar
    final List<Widget> _screens = [
      const HomeScreen(),
      const ExploreScreen(),
      const CitiesListScreen(),
      const SurveysScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: _screens[_selectedIndex],
      
      // Twitter tarzı bottom navigation bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 8.0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Keşfet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_city_outlined),
            activeIcon: Icon(Icons.location_city),
            label: 'Şehirler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.poll_outlined),
            activeIcon: Icon(Icons.poll),
            label: 'Anketler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      
      // Twitter tarzı gönderi oluşturma FAB
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreatePostScreen(postType: PostType.general)),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        heroTag: 'mainScreenFab',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
  
  void _showSearchModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, controller) {
            return Column(
              children: [
                Container(
                  height: 6,
                  width: 50,
                  margin: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Şehir veya şikayet ara...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: controller,
                    children: [
                      for (var i = 1; i <= 10; i++)
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: i % 2 == 0 
                                ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                                : Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                            child: i % 3 == 0 
                                ? const Icon(Icons.location_city)
                                : const Icon(Icons.comment),
                          ),
                          title: Text(i % 3 == 0 ? 'İstanbul Büyükşehir Belediyesi' : 'Park sorunu çözümü'),
                          subtitle: Text(i % 3 == 0 ? 'Belediye Profili' : 'Yeşil alanların bakımı'),
                          onTap: () => Navigator.pop(context),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  Widget _buildTabContent(int index) {
    switch (index) {
      case 0:
        return _buildFeedTab();
      case 1:
        return _buildSurveyTab();
      case 2:
        return _buildCityProfilesTab();
      default:
        return const Center(child: Text('İçerik bulunamadı'));
    }
  }
  
  Widget _buildFeedTab() {
    return Consumer(
      builder: (context, ref, child) {
        // API'den gönderileri al
        final postsNotifier = ref.watch(post_provider.postsProvider.notifier);
        final posts = ref.watch(post_provider.postsProvider);
        
        // Veri yükleme durumunu izle
        final isLoading = ref.watch(isLoadingProvider);
        
        // İlk yüklemede verileri çek
        if (posts.isEmpty && !isLoading) {
          // Yükleme işlemini post-frame callback ile yap (build sırasında state değiştirmemek için)
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // Yükleme durumunu güncelle
            ref.read(isLoadingProvider.notifier).state = true;
            
            // Verileri al
            postsNotifier.loadPosts().then((_) {
              // Yükleme tamamlandı
              if (ref.read(isLoadingProvider.notifier).mounted) {
                ref.read(isLoadingProvider.notifier).state = false;
              }
            }).catchError((error) {
              // Hata durumunda da yükleme durumunu güncelle
              if (ref.read(isLoadingProvider.notifier).mounted) {
                ref.read(isLoadingProvider.notifier).state = false;
              }
              print("Veri yükleme hatası: $error");
            });
          });
        }
        
        // Eğer veri yükleniyorsa veya henüz yüklenmediyse loading göster
        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        // Eğer hata varsa veya veri yoksa
        if (posts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 50,
                  color: Colors.grey[500],
                ),
                const SizedBox(height: 16),
                const Text('Gönderi bulunamadı'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => postsNotifier.loadPosts(),
                  child: const Text('Tekrar Dene'),
                ),
              ],
            ),
          );
        }
        
        // API'den gelen postları göster
        return RefreshIndicator(
          onRefresh: () => postsNotifier.loadPosts(),
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: posts.length + 1, // +1 anket kartı için
            itemBuilder: (context, index) {
              if (index == 0) {
                return Card(
                  clipBehavior: Clip.antiAlias,
                  elevation: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 150,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.poll_outlined,
                                size: 40,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Şehrinizin Sorunlarını Belirleyin',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              ElevatedButton(
                                onPressed: () {},
                                child: const Text('Ankete Katıl'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              // Asıl içerik (API'den gelen gönderi)
              final post = posts[index - 1]; // Anket kartını hesaba katmak için -1
              
              // Gönderi sahibi kullanıcının baş harfi (avatar için)
              final userInitial = post.userId.isNotEmpty ? 
                post.userId.substring(0, 1).toUpperCase() : '?';
              
              // Durum ikonu belirle
              IconData statusIcon;
              Color statusColor;
              
              switch (post.status) {
                case PostStatus.awaitingSolution:
                  statusIcon = Icons.schedule;
                  statusColor = Colors.orange;
                  break;
                case PostStatus.inProgress:
                  statusIcon = Icons.engineering;
                  statusColor = Colors.blue;
                  break;
                case PostStatus.solved:
                  statusIcon = Icons.check_circle;
                  statusColor = Colors.green;
                  break;
                case PostStatus.rejected:
                  statusIcon = Icons.cancel;
                  statusColor = Colors.red;
                  break;
              }
              
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        child: Text(userInitial),
                      ),
                      title: Text(post.title),
                      subtitle: Text(
                        '${post.createdAt.day} ${_getMonthName(post.createdAt.month)} ${post.createdAt.year}',
                      ),
                      trailing: Icon(
                        statusIcon,
                        color: statusColor,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        post.content,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                    if (post.imageUrls != null && post.imageUrls!.isNotEmpty)
                      Container(
                        height: 200,
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          image: DecorationImage(
                            image: NetworkImage(post.imageUrls!.first),
                            fit: BoxFit.cover,
                            onError: (exception, stackTrace) {
                              // Hata durumunda placeholder göster
                            },
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.thumb_up_outlined),
                                onPressed: () {},
                              ),
                              Text('${post.likeCount}'),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.comment_outlined),
                                onPressed: () {},
                              ),
                              Text('${post.commentCount}'),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.share_outlined),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
  
  // Ay isimlerini Türkçe olarak döndüren yardımcı fonksiyon
  String _getMonthName(int month) {
    const months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    return months[month - 1];
  }
  
  Widget _buildSurveyTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.poll,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Belediye Anketi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  index % 2 == 0
                      ? 'Mahallenizde en çok hangi hizmetin iyileştirilmesini istersiniz?'
                      : 'Şehir içi ulaşım hizmetlerinden memnuniyet düzeyiniz nedir?',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '12.324 kişi katıldı • 3 gün kaldı',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(40),
                  ),
                  child: const Text('Ankete Katıl'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildCityProfilesTab() {
    final cities = ['İstanbul', 'Ankara', 'İzmir', 'Antalya', 'Bursa', 'Adana'];
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cities.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            children: [
              Container(
                height: 120,
                color: Colors.grey[300],
                child: Center(
                  child: Icon(
                    Icons.location_city,
                    size: 50,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cities[index],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 18,
                          color: Colors.amber[700],
                        ),
                        Icon(
                          Icons.star,
                          size: 18,
                          color: Colors.amber[700],
                        ),
                        Icon(
                          Icons.star,
                          size: 18,
                          color: Colors.amber[700],
                        ),
                        Icon(
                          Icons.star_half,
                          size: 18,
                          color: Colors.amber[700],
                        ),
                        Icon(
                          Icons.star_border,
                          size: 18,
                          color: Colors.amber[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${3.5 + (index * 0.1).round() * 0.1})',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            const Icon(Icons.check_circle_outline),
                            const SizedBox(height: 4),
                            Text(
                              '${67 + index * 3}%',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Text(
                              'Çözüm Oranı',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Icon(Icons.timer_outlined),
                            const SizedBox(height: 4),
                            Text(
                              '${4 - index % 3} gün',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Text(
                              'Yanıt Süresi',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Icon(Icons.thumb_up_outlined),
                            const SizedBox(height: 4),
                            Text(
                              '${72 + index * 4}%',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Text(
                              'Memnuniyet',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(40),
                      ),
                      child: const Text('Profili İncele'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  // İkinci build metodu kaldırıldı - duplicate hatasını çözmek için
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color.withOpacity(0.2),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// Bildirim modeli sınıfı için önceki tanımdan vazgeçildi
/// Artık lib/models/notification_model.dart kullanılıyor
///
/// Bu sınıf silindi ve modeline referans yapıldı
/// Bkz: import 'models/notification_model.dart';