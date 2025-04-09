import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikayet_var/screens/home/home_screen.dart';
import 'package:sikayet_var/screens/home/profile_screen.dart';
import 'package:sikayet_var/screens/posts/create_post_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const HomeScreen(),
    const SizedBox(), // This will be replaced by create post action
    const ProfileScreen(),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentIndex == 1 ? Container() : _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex == 1 ? 0 : _currentIndex, // Never highlight the center button
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle, size: 32),
            label: 'Yeni',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
  
  void _onTabTapped(int index) {
    if (index == 1) {
      // This is the create post button
      _showCreatePostModal();
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }
  
  void _showCreatePostModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Yeni Paylaşım',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.warning_rounded, color: Colors.red),
                ),
                title: const Text('Şikayet'),
                subtitle: const Text('Belediye/valilik ile ilgili bir sorun bildir'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreatePostScreen(
                        type: PostType.problem,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lightbulb_outline, color: Colors.green),
                ),
                title: const Text('Öneri'),
                subtitle: const Text('Belediye/valilik için bir öneri paylaş'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreatePostScreen(
                        type: PostType.general,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}