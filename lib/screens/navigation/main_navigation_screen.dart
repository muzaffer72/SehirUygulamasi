import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikayet_var/models/post.dart';
import 'package:sikayet_var/providers/auth_provider.dart';
import 'package:sikayet_var/providers/post_provider.dart';
import 'package:sikayet_var/providers/user_provider.dart';
import 'package:sikayet_var/screens/home/dashboard_screen.dart';
import 'package:sikayet_var/screens/home/feed_screen.dart';
import 'package:sikayet_var/screens/profile/profile_screen.dart';
import 'package:sikayet_var/screens/search/search_screen.dart';
import 'package:sikayet_var/screens/surveys/surveys_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 0;
  
  // Define screens ahead of time
  late final List<Widget> _screens;
  
  @override
  void initState() {
    super.initState();
    _screens = [
      const FeedScreen(),
      const SearchScreen(),
      const SurveysScreen(),
      const DashboardScreen(),
      const ProfileScreen(),
    ];
    
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(postsProvider.notifier).loadPosts();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider).value;
    
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Ara',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.how_to_vote_outlined),
            activeIcon: Icon(Icons.how_to_vote),
            label: 'Anketler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Panelim',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0 || _currentIndex == 3
          ? FloatingActionButton(
              onPressed: () {
                _showCreatePostOptions(context);
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
  
  void _showCreatePostOptions(BuildContext context) {
    final currentUser = ref.read(currentUserProvider).value;
    
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen önce giriş yapın'),
        ),
      );
      
      // Switch to profile tab
      setState(() {
        _currentIndex = 4;
      });
      
      return;
    }
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Ne paylaşmak istersiniz?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_rounded,
                      color: Colors.red,
                    ),
                  ),
                  title: const Text('Şikayet'),
                  subtitle: const Text('Sorun bildirin, çözüm arayın'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/create_problem');
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lightbulb_outline,
                      color: Colors.green,
                    ),
                  ),
                  title: const Text('Öneri'),
                  subtitle: const Text('Fikir paylaşın, görüş bildirin'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/create_suggestion');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}